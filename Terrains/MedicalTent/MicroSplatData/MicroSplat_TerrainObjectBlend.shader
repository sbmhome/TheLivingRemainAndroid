//////////////////////////////////////////////////////
// MicroSplat
// Copyright (c) Jason Booth
//
// Auto-generated shader code, don't hand edit!
//   Compiled with MicroSplat 3.4
//   Unity : 2017.4.24f1
//   Platform : WindowsEditor
//   RenderLoop : Surface Shader
//////////////////////////////////////////////////////

Shader "MicroSplat/Terrain-MedicalTent_BlendWithTerrain" {
   Properties {
      [HideInInspector] _Control0 ("Control0", 2D) = "red" {}
      [HideInInspector] _Control1 ("Control1", 2D) = "black" {}
      

      // Splats
      [NoScaleOffset]_Diffuse ("Diffuse Array", 2DArray) = "white" {}
      [NoScaleOffset]_NormalSAO ("Normal Array", 2DArray) = "bump" {}
      [NoScaleOffset]_PerTexProps("Per Texture Properties", 2D) = "black" {}
      [NoScaleOffset]_PerPixelNormal("Per Pixel Normal", 2D) = "bump" {}
      [HideInInspector] _TerrainHolesTexture("Holes Map (RGB)", 2D) = "white" {}
      _Contrast("Blend Contrast", Range(0.01, 0.99)) = 0.4
      _UVScale("UV Scales", Vector) = (45, 45, 0, 0)


      [NoScaleOffset]_SmoothAO ("Smooth AO Array", 2DArray) = "black" {}


      // terrain
      [NoScaleOffset]_NormalNoise("Normal Noise", 2D) = "bump" {}
      _NormalNoiseScaleStrength("Normal Scale", Vector) = (8, 0.5, 0, 0)

      [NoScaleOffset]_NormalNoise2("Normal Noise 2", 2D) = "bump" {}
      _NormalNoiseScaleStrength2("Normal Scale 2", Vector) = (8, 0.5, 0, 0)

      
      [HideInInspector]_TerrainDesc("Terrain Desc", 2D) = "black" {}
      [HideInInspector]_TerrainBounds("Terrain Bounds", Vector) = (0,0,512,512)
      [PerRendererData]_TerrainBlendParams("Terrain Blend Distance", Vector) = (1, 0.4, 0, 0)



      [NoScaleOffset]_NormalOriginal ("Normal(from original)", 2D) = "bump" {}
      _TBNoiseScale("Noise Scale", Float) = 1

      _TriplanarContrast("Triplanar Contrast", Range(1.0, 8)) = 4
      _TriplanarUVScale("Triplanar UV Scale", Vector) = (1, 1, 0, 0)

   }

   CGINCLUDE
   ENDCG

   SubShader {
      Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+100" "SplatCount" = "8"}
      Cull Back
      ZTest LEqual
      BLEND ONE ONE
      CGPROGRAM
      #pragma exclude_renderers d3d9
      #include "UnityCG.cginc"
      #include "AutoLight.cginc"
      #include "Lighting.cginc"
      #include "UnityPBSLighting.cginc"
      #include "UnityStandardBRDF.cginc"

      #pragma surface blendSurf TerrainBlendable fullforwardshadows addshadow decal:blend


      #pragma target 3.5
      #pragma multi_compile_local __ _ALPHATEST_ON



      #define _MICROSPLAT 1
      #define _USEGRADMIP 1
      #define _PACKINGHQ 1
      #define _MAX3LAYER 1
      #define _MAX8TEXTURES 1
      #define _PERTEXUVSCALEOFFSET 1
      #define _PERTEXHEIGHTOFFSET 1
      #define _PERTEXTINT 1
      #define _PERTEXNORMSTR 1
      #define _PERTEXSMOOTHSTR 1
      #define _BRANCHSAMPLES 1
      #define _BRANCHSAMPLESAGR 1
      #define _NORMALNOISE 1
      #define _PERTEXNORMALNOISESTRENGTH 1
      #define _NORMALNOISE2 1
      #define _TERRAINBLENDING 1
      #define _TBNOISE 1
      #define _TBOBJECTNORMALBLEND 1
      #define _TRIPLANAR 1
      #define _MSRENDERLOOP_SURFACESHADER 1

      #define _MSRENDERLOOP_SURFACESHADER 1
      #define _TERRAINBLENDABLESHADER 1


      
      float4 _TerrainBounds;
      float4 _TerrainDesc_TexelSize;

      half4 _TerrainBlendParams;
      half4 _SlopeBlendParams;
      half4 _SnowBlendParams;
      half4 _FeatureFilters;

      half _TBNoiseScale;

      



      #if _MESHSUBARRAY
         half4 _MeshSubArrayIndexes;
      #endif


      #if _USEEMISSIVEMETAL
         half _EmissiveMult;
      #endif

      float4 _UVScale; // scale and offset

      float2 _ToonTerrainSize;

      half _Contrast;
      
      float3 _gGlitterLightDir;
      float3 _gGlitterLightWorldPos;
      half3 _gGlitterLightColor;

       #if _VSSHADOWMAP
         float4 gVSSunDirection;
      #endif

      #if _FORCELOCALSPACE && _PLANETVECTORS
         float4x4 _PQSToLocal;
      #endif

      #if _ORIGINSHIFT
         float4x4 _GlobalOriginMTX;
      #endif

      float4 _Control0_TexelSize;
      float4 _CustomControl0_TexelSize;
      float4 _PerPixelNormal_TexelSize;

      #if _CONTROLNOISEUV || _GLOBALNOISEUV
         float2 _NoiseUVParams;
      #endif





         #if _DETAILNOISE
         half3 _DetailNoiseScaleStrengthFade;
         #endif

         #if _DISTANCENOISE
         half4 _DistanceNoiseScaleStrengthFade;
         #endif

         #if _DISTANCERESAMPLE
         float3  _ResampleDistanceParams;
         
            #if _DISTANCERESAMPLENOFADE || _DISTANCERESAMPLENOISE
               half _DistanceResampleConstant;
            #endif
            #if _DISTANCERESAMPLENOISE
               float2 _DistanceResampleNoiseParams;
            #endif
         #endif

         #if _NORMALNOISE
         half2 _NormalNoiseScaleStrength;
         #endif

         #if _NORMALNOISE2
         half2 _NormalNoiseScaleStrength2;
         #endif

         #if _NORMALNOISE3
         half2 _NormalNoiseScaleStrength3;
         #endif
         
         #if _NOISEHEIGHT
            half2 _NoiseHeightData; // scale, amp
         #endif

         #if _NOISEUV
            half2 _NoiseUVData; // scale, amp
         #endif
         


      float _TriplanarContrast;
      float4 _TriplanarUVScale;


      // dynamic branching helpers, for regular and aggressive branching
      // debug mode shows how many samples using branching will save us. 
      //
      // These macros are always used instead of the UNITY_BRANCH macro
      // to maintain debug displays and allow branching to be disabled
      // on as granular level as we want. 
      
      #if _BRANCHSAMPLES
         #if _DEBUG_BRANCHCOUNT_WEIGHT || _DEBUG_BRANCHCOUNT_TOTAL
            float _branchWeightCount;
            #define MSBRANCH(w) if (w > 0) _branchWeightCount++; if (w > 0)
         #else
            #define MSBRANCH(w) UNITY_BRANCH if (w > 0)
         #endif
      #else
         #if _DEBUG_BRANCHCOUNT_WEIGHT || _DEBUG_BRANCHCOUNT_TOTAL
            float _branchWeightCount;
            #define MSBRANCH(w) if (w > 0) _branchWeightCount++;
         #else
            #define MSBRANCH(w) 
         #endif
      #endif
      
      #if _BRANCHSAMPLESAGR
         #if _DEBUG_BRANCHCOUNT_TRIPLANAR || _DEBUG_BRANCHCOUNT_CLUSTER || _DEBUG_BRANCHCOUNT_OTHER ||_DEBUG_BRANCHCOUNT_TOTAL
            float _branchTriplanarCount;
            float _branchClusterCount;
            float _branchOtherCount;
            #define MSBRANCHTRIPLANAR(w) if (w > 0.001) _branchTriplanarCount++; if (w > 0.001)
            #define MSBRANCHCLUSTER(w) if (w > 0.001) _branchClusterCount++; if (w > 0.001)
            #define MSBRANCHOTHER(w) if (w > 0.001) _branchOtherCount++; if (w > 0.001)
         #else
            #define MSBRANCHTRIPLANAR(w) UNITY_BRANCH if (w > 0.001)
            #define MSBRANCHCLUSTER(w) UNITY_BRANCH if (w > 0.001)
            #define MSBRANCHOTHER(w) UNITY_BRANCH if (w > 0.001)
         #endif
      #else
         #if _DEBUG_BRANCHCOUNT_TRIPLANAR || _DEBUG_BRANCHCOUNT_CLUSTER || _DEBUG_BRANCHCOUNT_OTHER || _DEBUG_BRANCHCOUNT_TOTAL
            float _branchTriplanarCount;
            float _branchClusterCount;
            float _branchOtherCount;
            #define MSBRANCHTRIPLANAR(w) if (w > 0.001) _branchTriplanarCount++;
            #define MSBRANCHCLUSTER(w) if (w > 0.001) _branchClusterCount++;
            #define MSBRANCHOTHER(w) if (w > 0.001) _branchOtherCount++;
         #else
            #define MSBRANCHTRIPLANAR(w)
            #define MSBRANCHCLUSTER(w)
            #define MSBRANCHOTHER(w)
         #endif
      #endif

      #if _DEBUG_SAMPLECOUNT
         int _sampleCount;
         #define COUNTSAMPLE { _sampleCount++; }
      #else
         #define COUNTSAMPLE
      #endif

      #if _DEBUG_PROCLAYERS
         int _procLayerCount;
         #define COUNTPROCLAYER { _procLayerCount++; }
      #else
         #define COUNTPROCLAYER
      #endif


      #if _DEBUG_USE_TOPOLOGY
         UNITY_DECLARE_TEX2D_NOSAMPLER(_DebugWorldPos);
         UNITY_DECLARE_TEX2D_NOSAMPLER(_DebugWorldNormal);
      #endif
      

      // splat
      UNITY_DECLARE_TEX2DARRAY(_Diffuse);
      float4 _Diffuse_TexelSize;
      UNITY_DECLARE_TEX2DARRAY(_NormalSAO);
      float4 _NormalSAO_TexelSize;

      #if _CONTROLNOISEUV || _GLOBALNOISEUV
         UNITY_DECLARE_TEX2D_NOSAMPLER(_NoiseUV);
      #endif

      #if _PACKINGHQ
         UNITY_DECLARE_TEX2DARRAY(_SmoothAO);
         float4 _SmoothAO_TexelSize;
      #endif

      #if _USESPECULARWORKFLOW
         UNITY_DECLARE_TEX2DARRAY(_Specular);
         float4 _Specular_TexelSize;
      #endif

      #if _USEEMISSIVEMETAL
         UNITY_DECLARE_TEX2DARRAY(_EmissiveMetal);
         float4 _EmissiveMetal_TexelSize;
      #endif

      
      UNITY_DECLARE_TEX2D_NOSAMPLER(_PerPixelNormal);
      
      UNITY_DECLARE_TEX2D(_Control0);
      #if _CUSTOMSPLATTEXTURES
         UNITY_DECLARE_TEX2D(_CustomControl0);
         #if !_MAX4TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_CustomControl1);
         #endif
         #if !_MAX4TEXTURES && !_MAX8TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_CustomControl2);
         #endif
         #if !_MAX4TEXTURES && !_MAX8TEXTURES && !_MAX12TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_CustomControl3);
         #endif
         #if _MAX20TEXTURES || _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_CustomControl4);
         #endif
         #if _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_CustomControl5);
         #endif
         #if _MAX28TEXTURES || _MAX32TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_CustomControl6);
         #endif
         #if _MAX32TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_CustomControl7);
         #endif
      #else
         #if !_MAX4TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_Control1);
         #endif
         #if !_MAX4TEXTURES && !_MAX8TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_Control2);
         #endif
         #if !_MAX4TEXTURES && !_MAX8TEXTURES && !_MAX12TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_Control3);
         #endif
         #if _MAX20TEXTURES || _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_Control4);
         #endif
         #if _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_Control5);
         #endif
         #if _MAX28TEXTURES || _MAX32TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_Control6);
         #endif
         #if _MAX32TEXTURES
         UNITY_DECLARE_TEX2D_NOSAMPLER(_Control7);
         #endif
      #endif

      sampler2D_float _PerTexProps;
   



      struct TriGradMipFormat
      {
         float4 d0;
         float4 d1;
         float4 d2;
      };

      half InverseLerp(half x, half y, half v) { return (v-x)/max(y-x, 0.001); }
      half2 InverseLerp(half2 x, half2 y, half2 v) { return (v-x)/max(y-x, half2(0.001, 0.001)); }
      half3 InverseLerp(half3 x, half3 y, half3 v) { return (v-x)/max(y-x, half3(0.001, 0.001, 0.001)); }
      half4 InverseLerp(half4 x, half4 y, half4 v) { return (v-x)/max(y-x, half4(0.001, 0.001, 0.001, 0.001)); }
      

      // 2019.3 holes
      #ifdef _ALPHATEST_ON
          UNITY_DECLARE_TEX2D(_TerrainHolesTexture);

          void ClipHoles(float2 uv)
          {
              float hole = UNITY_SAMPLE_TEX2D(_TerrainHolesTexture, uv).r;
              COUNTSAMPLE
              clip(hole < 0.5f ? -1 : 1);
          }
      #endif

      
      #if _TRIPLANAR
         #if _USEGRADMIP
            #define MIPFORMAT TriGradMipFormat
            #define INITMIPFORMAT (TriGradMipFormat)0;
            #define MIPFROMATRAW float4
         #else
            #define MIPFORMAT float3
            #define INITMIPFORMAT 0;
            #define MIPFROMATRAW float3
         #endif
      #else
         #if _USEGRADMIP
            #define MIPFORMAT float4
            #define INITMIPFORMAT 0;
            #define MIPFROMATRAW float4
         #else
            #define MIPFORMAT float
            #define INITMIPFORMAT 0;
            #define MIPFROMATRAW float
         #endif
      #endif

      float2 RotateUV(float2 uv, float amt)
      {
         uv -=0.5;
         float s = sin ( amt);
         float c = cos ( amt );
         float2x2 mtx = float2x2( c, -s, s, c);
         mtx *= 0.5;
         mtx += 0.5;
         mtx = mtx * 2-1;
         uv = mul ( uv, mtx );
         uv += 0.5;
         return uv;
      }

      float4 DecodeToFloat4(float v)
      {
         uint vi = (uint)(v * (256.0f * 256.0f * 256.0f * 256.0f));
         int ex = (int)(vi / (256 * 256 * 256) % 256);
         int ey = (int)((vi / (256 * 256)) % 256);
         int ez = (int)((vi / (256)) % 256);
         int ew = (int)(vi % 256);
         float4 e = float4(ex / 255.0, ey / 255.0, ez / 255.0, ew / 255.0);
         return e;
      }

      struct Input 
      {
         float2 uv_Control0;
         #if (_MICROMESH && _MESHUV2)
         float2 uv2_Diffuse;
         #endif

         float3 viewDir;
         float3 worldPos;
         float3 worldNormal;
         #if _TERRAINBLENDING
         float4 color : COLOR;
         #endif
         #if _MSRENDERLOOP_SURFACESHADER
         INTERNAL_DATA
         #else
         float3x3 TBN;
         #endif

         #if _MICRODIGGERMESH || _MICROVERTEXMESH
            fixed4 w0;
            #if !_MAX4TEXTURES
               fixed4 w1;
            #endif
            #if !_MAX4TEXTURES && !_MAX8TEXTURES
               fixed4 w2;
            #endif
            #if !_MAX4TEXTURES && !_MAX8TEXTURES && !_MAX12TEXTURES
               fixed4 w3;
            #endif
            #if _MAX20TEXTURES || _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
               fixed4 w4;
            #endif
            #if _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
               fixed4 w5;
            #endif
            #if (_MAX28TEXTURES || _MAX32TEXTURES) && !_STREAMS && !_LAVA && !_WETNESS && !_PUDDLES
               fixed4 w6;
            #endif

            #if _STEAMS || _WETNESS || _LAVA || _PUDDLES
               fixed4 s0;
            #endif

         #endif
      };
      
      struct TriplanarConfig
      {
         float3x3 uv0;
         float3x3 uv1;
         float3x3 uv2;
         float3x3 uv3;
         half3 pN;
         half3 pN0;
         half3 pN1;
         half3 pN2;
         half3 pN3;
         half3 axisSign;
         Input IN;
      };


      struct Config
      {
         float2 uv;
         float3 uv0;
         float3 uv1;
         float3 uv2;
         float3 uv3;

         half4 cluster0;
         half4 cluster1;
         half4 cluster2;
         half4 cluster3;

      };


      struct MicroSplatLayer
      {
         half3 Albedo;
         half3 Normal;
         half Smoothness;
         half Occlusion;
         half Metallic;
         half Height;
         half3 Emission;
         #if _USESPECULARWORKFLOW
         half3 Specular;
         #endif
         half Alpha;
         
      };


      struct appdata 
      {
         float4 vertex : POSITION;
         float4 tangent : TANGENT;
         float3 normal : NORMAL;
         float2 texcoord : TEXCOORD0;
         float4 texcoord1 : TEXCOORD1;
         float4 texcoord2 : TEXCOORD2;
         #if _TERRAINBLENDING || _MICRODIGGERMESH || _MICROVERTEXMESH
         fixed4 color : COLOR;
         #endif
         UNITY_VERTEX_INPUT_INSTANCE_ID
         UNITY_VERTEX_OUTPUT_STEREO
      };


      // raw, unblended samples from arrays
      struct RawSamples
      {
         half4 albedo0;
         half4 albedo1;
         half4 albedo2;
         half4 albedo3;
         half4 normSAO0;
         half4 normSAO1;
         half4 normSAO2;
         half4 normSAO3;
         #if _USEEMISSIVEMETAL || _GLOBALEMIS || _GLOBALSMOOTHAOMETAL || _PERTEXSSS
            half4 emisMetal0;
            half4 emisMetal1;
            half4 emisMetal2;
            half4 emisMetal3;
         #endif
         #if _USESPECULARWORKFLOW
            half3 specular0;
            half3 specular1;
            half3 specular2;
            half3 specular3;
         #endif
      };

      void InitRawSamples(inout RawSamples s)
      {
         s.normSAO0 = half4(0,0,0,1);
         s.normSAO1 = half4(0,0,0,1);
         s.normSAO2 = half4(0,0,0,1);
         s.normSAO3 = half4(0,0,0,1);
      }

       float3 GetGlobalLightDir(Input i)
      {
         float3 lightDir = float3(1,0,0);

         #if _MSRENDERLOOP_UNITYHD || PASS_DEFERRED
            lightDir = normalize(_gGlitterLightDir.xyz);
         #elif _MSRENDERLOOP_UNITYLD
            lightDir = GetMainLight().direction;
         #else
            #ifndef USING_DIRECTIONAL_LIGHT
               lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
            #else
               lightDir = normalize(_WorldSpaceLightPos0.xyz);
            #endif
         #endif
         return lightDir;
      }

      float3 GetGlobalLightDirTS(Input i)
      {
         float3 lightDirWS = GetGlobalLightDir(i);
        
         #if _MSRENDERLOOP_UNITYHD || _MSRENDERLOOP_UNITYLD
            return mul( i.TBN, lightDirWS).xyz;
         #else
            float3 t2w0 = WorldNormalVector(i, float3(1,0,0));
            float3 t2w1 = WorldNormalVector(i, float3(0,1,0));
            float3 t2w2 = WorldNormalVector(i, float3(0,0,1));
            float3x3 t2w = float3x3(t2w0, t2w1, t2w2);
            return mul( t2w, lightDirWS).xyz;
         #endif
      }
      
      half3 GetGlobalLightColor()
      {
         #if _MSRENDERLOOP_UNITYHD || PASS_DEFERRED
            return _gGlitterLightColor;
         #elif _MSRENDERLOOP_UNITYLD
            return normalize(GetMainLight().color);
         #else
            return _LightColor0.rgb;
         #endif
      }



      half3 FuzzyShade(half3 color, half3 normal, half coreMult, half edgeMult, half power, float3 viewDir)
      {
         half dt = saturate(dot(viewDir, normal));
         half dark = 1.0 - (coreMult * dt);
         half edge = pow(1-dt, power) * edgeMult;
         return color * (dark + edge);
      }

      half3 ComputeSSS(Input i, float3 V, float3 N, half3 tint, half thickness, half distortion, half scale, half power)
      {
         float3 L = GetGlobalLightDir(i);
         half3 lightColor = GetGlobalLightColor();
         float3 H = normalize(L + N * distortion);
         float VdotH = pow(saturate(dot(V, -H)), power) * scale;
         float3 I =  (VdotH) * thickness;
         return lightColor * I * tint;
      }


      #if _MAX2LAYER
         inline half BlendWeights(half s1, half s2, half s3, half s4, half4 w)      { return s1 * w.x + s2 * w.y; }
         inline half2 BlendWeights(half2 s1, half2 s2, half2 s3, half2 s4, half4 w) { return s1 * w.x + s2 * w.y; }
         inline half3 BlendWeights(half3 s1, half3 s2, half3 s3, half3 s4, half4 w) { return s1 * w.x + s2 * w.y; }
         inline half4 BlendWeights(half4 s1, half4 s2, half4 s3, half4 s4, half4 w) { return s1 * w.x + s2 * w.y; }
      #elif _MAX3LAYER
         inline half BlendWeights(half s1, half s2, half s3, half s4, half4 w)      { return s1 * w.x + s2 * w.y + s3 * w.z; }
         inline half2 BlendWeights(half2 s1, half2 s2, half2 s3, half2 s4, half4 w) { return s1 * w.x + s2 * w.y + s3 * w.z; }
         inline half3 BlendWeights(half3 s1, half3 s2, half3 s3, half3 s4, half4 w) { return s1 * w.x + s2 * w.y + s3 * w.z; }
         inline half4 BlendWeights(half4 s1, half4 s2, half4 s3, half4 s4, half4 w) { return s1 * w.x + s2 * w.y + s3 * w.z; }
      #else
         inline half BlendWeights(half s1, half s2, half s3, half s4, half4 w)      { return s1 * w.x + s2 * w.y + s3 * w.z + s4 * w.w; }
         inline half2 BlendWeights(half2 s1, half2 s2, half2 s3, half2 s4, half4 w) { return s1 * w.x + s2 * w.y + s3 * w.z + s4 * w.w; }
         inline half3 BlendWeights(half3 s1, half3 s2, half3 s3, half3 s4, half4 w) { return s1 * w.x + s2 * w.y + s3 * w.z + s4 * w.w; }
         inline half4 BlendWeights(half4 s1, half4 s2, half4 s3, half4 s4, half4 w) { return s1 * w.x + s2 * w.y + s3 * w.z + s4 * w.w; }
      #endif

      #if _MAX3LAYER
         #define SAMPLE_PER_TEX(varName, pixel, config, defVal) \
            half4 varName##0 = defVal; \
            half4 varName##1 = defVal; \
            half4 varName##2 = defVal; \
            half4 varName##3 = defVal; \
            varName##0 = tex2Dlod(_PerTexProps, float4(config.uv0.z/32, pixel/32, 0, 0)); \
            varName##1 = tex2Dlod(_PerTexProps, float4(config.uv1.z/32, pixel/32, 0, 0)); \
            varName##2 = tex2Dlod(_PerTexProps, float4(config.uv2.z/32, pixel/32, 0, 0)); \

      #elif _MAX2LAYER
         #define SAMPLE_PER_TEX(varName, pixel, config, defVal) \
            half4 varName##0 = defVal; \
            half4 varName##1 = defVal; \
            half4 varName##2 = defVal; \
            half4 varName##3 = defVal; \
            varName##0 = tex2Dlod(_PerTexProps, float4(config.uv0.z/32, pixel/32, 0, 0)); \
            varName##1 = tex2Dlod(_PerTexProps, float4(config.uv1.z/32, pixel/32, 0, 0)); \

      #else
         #define SAMPLE_PER_TEX(varName, pixel, config, defVal) \
            half4 varName##0 = tex2Dlod(_PerTexProps, float4(config.uv0.z/32, pixel/32, 0, 0)); \
            half4 varName##1 = tex2Dlod(_PerTexProps, float4(config.uv1.z/32, pixel/32, 0, 0)); \
            half4 varName##2 = tex2Dlod(_PerTexProps, float4(config.uv2.z/32, pixel/32, 0, 0)); \
            half4 varName##3 = tex2Dlod(_PerTexProps, float4(config.uv3.z/32, pixel/32, 0, 0)); \

      #endif
      
      half3 BlendNormal3(half3 n1, half3 n2)
      {
         n1.z += 1;
         n2.xy = -n2.xy;

         return n1 * dot(n1, n2) / n1.z - n2;
      }
      
      half2 TransformTriplanarNormal(Input IN, float3x3 t2w, half3 axisSign, half3 absVertNormal,
               half3 pN, half2 a0, half2 a1, half2 a2)
      {
         a0 = a0 * 2 - 1;
         a1 = a1 * 2 - 1;
         a2 = a2 * 2 - 1;
         
         a0.x *= axisSign.x;
         a1.x *= axisSign.y;
         a2.x *= axisSign.z;
         
         half3 n0 = half3(a0.xy, 1);
         half3 n1 = half3(a1.xy, 1);
         half3 n2 = half3(a2.xy, 1);
         
         n0 = BlendNormal3(half3(IN.worldNormal.zy, absVertNormal.x), n0);
         n1 = BlendNormal3(half3(IN.worldNormal.xz, absVertNormal.y), n1);
         n2 = BlendNormal3(half3(IN.worldNormal.xy, absVertNormal.z), n2);
  
         n0.z *= axisSign.x;
         n1.z *= axisSign.y;
         n2.z *= -axisSign.z;
  
         half3 worldNormal = (n0.zyx * pN.x + n1.xzy * pN.y + n2.xyz * pN.z );
         return mul(t2w, worldNormal).xy;
      }
      
      // funcs
      
      inline half MSLuminance(half3 rgb)
      {
         #ifdef UNITY_COLORSPACE_GAMMA
            return dot(rgb, half3(0.22, 0.707, 0.071));
         #else
            return dot(rgb, half3(0.0396819152, 0.458021790, 0.00609653955));
         #endif
      }
      
      
      float2 Hash2D( float2 x )
      {
          float2 k = float2( 0.3183099, 0.3678794 );
          x = x*k + k.yx;
          return -1.0 + 2.0*frac( 16.0 * k*frac( x.x*x.y*(x.x+x.y)) );
      }

      float Noise2D(float2 p )
      {
         float2 i = floor( p );
         float2 f = frac( p );
         
         float2 u = f*f*(3.0-2.0*f);

         return lerp( lerp( dot( Hash2D( i + float2(0.0,0.0) ), f - float2(0.0,0.0) ), 
                           dot( Hash2D( i + float2(1.0,0.0) ), f - float2(1.0,0.0) ), u.x),
                      lerp( dot( Hash2D( i + float2(0.0,1.0) ), f - float2(0.0,1.0) ), 
                           dot( Hash2D( i + float2(1.0,1.0) ), f - float2(1.0,1.0) ), u.x), u.y);
      }
      
      float FBM2D(float2 uv)
      {
         float f = 0.5000*Noise2D( uv ); uv *= 2.01;
         f += 0.2500*Noise2D( uv ); uv *= 1.96;
         f += 0.1250*Noise2D( uv ); 
         return f;
      }
      
      float3 Hash3D( float3 p )
      {
         p = float3( dot(p,float3(127.1,311.7, 74.7)),
                 dot(p,float3(269.5,183.3,246.1)),
                 dot(p,float3(113.5,271.9,124.6)));

         return -1.0 + 2.0*frac(sin(p)*437.5453123);
      }

      float Noise3D( float3 p )
      {
         float3 i = floor( p );
         float3 f = frac( p );
         
         float3 u = f*f*(3.0-2.0*f);

         return lerp( lerp( lerp( dot( Hash3D( i + float3(0.0,0.0,0.0) ), f - float3(0.0,0.0,0.0) ), 
                                dot( Hash3D( i + float3(1.0,0.0,0.0) ), f - float3(1.0,0.0,0.0) ), u.x),
                           lerp( dot( Hash3D( i + float3(0.0,1.0,0.0) ), f - float3(0.0,1.0,0.0) ), 
                                dot( Hash3D( i + float3(1.0,1.0,0.0) ), f - float3(1.0,1.0,0.0) ), u.x), u.y),
                      lerp( lerp( dot( Hash3D( i + float3(0.0,0.0,1.0) ), f - float3(0.0,0.0,1.0) ), 
                                dot( Hash3D( i + float3(1.0,0.0,1.0) ), f - float3(1.0,0.0,1.0) ), u.x),
                           lerp( dot( Hash3D( i + float3(0.0,1.0,1.0) ), f - float3(0.0,1.0,1.0) ), 
                                dot( Hash3D( i + float3(1.0,1.0,1.0) ), f - float3(1.0,1.0,1.0) ), u.x), u.y), u.z );
      }
      
      float FBM3D(float3 uv)
      {
         float f = 0.5000*Noise3D( uv ); uv *= 2.01;
         f += 0.2500*Noise3D( uv ); uv *= 1.96;
         f += 0.1250*Noise3D( uv ); 
         return f;
      }
      
      half2 BlendNormal2(half2 base, half2 blend) { return normalize(half3(base.xy + blend.xy, 1)).xy; } 
      half3 BlendOverlay(half3 base, half3 blend) { return (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend))); }
      half3 BlendMult2X(half3  base, half3 blend) { return (base * (blend * 2)); }
      half3 BlendLighterColor(half3 s, half3 d) { return (s.x + s.y + s.z > d.x + d.y + d.z) ? s : d; } 
      
      float GetSaturation(float3 c)
      {
         float mi = min(min(c.x, c.y), c.z);
         float ma = max(max(c.x, c.y), c.z);
         return (ma - mi)/(ma + 1e-7);
      }

      // Better Color Lerp, does not have darkening issue
      float3 BetterColorLerp(float3 a, float3 b, float x)
      {
         float3 ic = lerp(a, b, x) + float3(1e-6,0.0,0.0);
         float sd = abs(GetSaturation(ic) - lerp(GetSaturation(a), GetSaturation(b), x));
    
         float3 dir = normalize(float3(2.0 * ic.x - ic.y - ic.z, 2.0 * ic.y - ic.x - ic.z, 2.0 * ic.z - ic.y - ic.x));
         float lgt = dot(float3(1.0, 1.0, 1.0), ic);
    
         float ff = dot(dir, normalize(ic));
    
         const float dsp_str = 1.5;
         ic += dsp_str * dir * sd * ff * lgt;
         return saturate(ic);
      }
      
      
      half4 ComputeWeights(half4 iWeights, half h0, half h1, half h2, half h3, half contrast)
      {
          #if _DISABLEHEIGHTBLENDING
             return iWeights;
          #else
             // compute weight with height map
             //half4 weights = half4(iWeights.x * h0, iWeights.y * h1, iWeights.z * h2, iWeights.w * h3);
             half4 weights = half4(iWeights.x * max(h0,0.001), iWeights.y * max(h1,0.001), iWeights.z * max(h2,0.001), iWeights.w * max(h3,0.001));
             
             // Contrast weights
             half maxWeight = max(max(weights.x, max(weights.y, weights.z)), weights.w);
             half transition = max(contrast * maxWeight, 0.0001);
             half threshold = maxWeight - transition;
             half scale = 1.0 / transition;
             weights = saturate((weights - threshold) * scale);
             // Normalize weights.
             half weightScale = 1.0f / (weights.x + weights.y + weights.z + weights.w);
             weights *= weightScale;
             return weights;
          #endif
      }

      half HeightBlend(half h1, half h2, half slope, half contrast)
      {
         #if _DISABLEHEIGHTBLENDING
            return slope;
         #else
            h2 = 1 - h2;
            half tween = saturate((slope - min(h1, h2)) / max(abs(h1 - h2), 0.001)); 
            half blend = saturate( ( tween - (1-contrast) ) / max(contrast, 0.001));
            return blend;
         #endif
      }

      #if _MAX4TEXTURES
         #define TEXCOUNT 4
      #elif _MAX8TEXTURES
         #define TEXCOUNT 8
      #elif _MAX12TEXTURES
         #define TEXCOUNT 12
      #elif _MAX20TEXTURES
         #define TEXCOUNT 20
      #elif _MAX24TEXTURES
         #define TEXCOUNT 24
      #elif _MAX28TEXTURES
         #define TEXCOUNT 28
      #elif _MAX32TEXTURES
         #define TEXCOUNT 32
      #else
         #define TEXCOUNT 16
      #endif


      void Setup(out half4 weights, float2 uv, out Config config, fixed4 w0, fixed4 w1, fixed4 w2, fixed4 w3, fixed4 w4, fixed4 w5, fixed4 w6, fixed4 w7, float3 worldPos)
      {
         config = (Config)0;
         half4 indexes = 0;

         config.uv = uv;

         #if _WORLDUV
         uv = worldPos.xz;
         #endif

         #if _DISABLESPLATMAPS
            float2 scaledUV = uv;
         #else
            float2 scaledUV = uv * _UVScale.xy + _UVScale.zw;
         #endif

         // if only 4 textures, and blending 4 textures, skip this whole thing..
         // this saves about 25% of the ALU of the base shader on low end. However if
         // we rely on sorted texture weights (distance resampling) we have to sort..
         float4 defaultIndexes = float4(0,1,2,3);
         #if _MESHSUBARRAY
            defaultIndexes = _MeshSubArrayIndexes;
         #endif

         #if _MESHSUBARRAY || (_MAX4TEXTURES && !_MAX3LAYER && !_MAX2LAYER && !_DISTANCERESAMPLE && !_POM)
            weights = w0;
            config.uv0 = float3(scaledUV, defaultIndexes.x);
            config.uv1 = float3(scaledUV, defaultIndexes.y);
            config.uv2 = float3(scaledUV, defaultIndexes.z);
            config.uv3 = float3(scaledUV, defaultIndexes.w);
            return;
         #endif

         #if _DISABLESPLATMAPS
            weights = float4(1,0,0,0);
            return;
         #else
            fixed splats[TEXCOUNT];

            splats[0] = w0.x;
            splats[1] = w0.y;
            splats[2] = w0.z;
            splats[3] = w0.w;
            #if !_MAX4TEXTURES
               splats[4] = w1.x;
               splats[5] = w1.y;
               splats[6] = w1.z;
               splats[7] = w1.w;
            #endif
            #if !_MAX4TEXTURES && !_MAX8TEXTURES
               splats[8] = w2.x;
               splats[9] = w2.y;
               splats[10] = w2.z;
               splats[11] = w2.w;
            #endif
            #if !_MAX4TEXTURES && !_MAX8TEXTURES && !_MAX12TEXTURES
               splats[12] = w3.x;
               splats[13] = w3.y;
               splats[14] = w3.z;
               splats[15] = w3.w;
            #endif
            #if _MAX20TEXTURES || _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
               splats[16] = w4.x;
               splats[17] = w4.y;
               splats[18] = w4.z;
               splats[19] = w4.w;
            #endif
            #if _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
               splats[20] = w5.x;
               splats[21] = w5.y;
               splats[22] = w5.z;
               splats[23] = w5.w;
            #endif
            #if _MAX28TEXTURES || _MAX32TEXTURES
               splats[24] = w6.x;
               splats[25] = w6.y;
               splats[26] = w6.z;
               splats[27] = w6.w;
            #endif
            #if _MAX32TEXTURES
               splats[28] = w7.x;
               splats[29] = w7.y;
               splats[30] = w7.z;
               splats[31] = w7.w;
            #endif



            weights[0] = 0;
            weights[1] = 0;
            weights[2] = 0;
            weights[3] = 0;
            indexes[0] = 0;
            indexes[1] = 0;
            indexes[2] = 0;
            indexes[3] = 0;

            int i = 0;
            for (i = 0; i < TEXCOUNT; ++i)
            {
               fixed w = splats[i];
               if (w >= weights[0])
               {
                  weights[3] = weights[2];
                  indexes[3] = indexes[2];
                  weights[2] = weights[1];
                  indexes[2] = indexes[1];
                  weights[1] = weights[0];
                  indexes[1] = indexes[0];
                  weights[0] = w;
                  indexes[0] = i;
               }
               else if (w >= weights[1])
               {
                  weights[3] = weights[2];
                  indexes[3] = indexes[2];
                  weights[2] = weights[1];
                  indexes[2] = indexes[1];
                  weights[1] = w;
                  indexes[1] = i;
               }
               else if (w >= weights[2])
               {
                  weights[3] = weights[2];
                  indexes[3] = indexes[2];
                  weights[2] = w;
                  indexes[2] = i;
               }
               else if (w >= weights[3])
               {
                  weights[3] = w;
                  indexes[3] = i;
               }
            }

            // clamp and renormalize
            #if _MAX2LAYER
            weights.zw = 0;
            weights.xy *= (1.0 / (weights.x + weights.y));
            #elif _MAX3LAYER
            weights.w = 0;
            weights.xyz *= (1.0 / (weights.x + weights.y + weights.z));
            #elif !_DISABLEHEIGHTBLENDING || _NORMALIZEWEIGHTS // prevents black when painting, which the unity shader does not prevent.
            weights = normalize(weights);
            #endif

            config.uv0 = float3(scaledUV, indexes.x);
            config.uv1 = float3(scaledUV, indexes.y);
            config.uv2 = float3(scaledUV, indexes.z);
            config.uv3 = float3(scaledUV, indexes.w);


         #endif //_DISABLESPLATMAPS


      }
      
      float ComputeMipLevel(float2 uv, float2 textureSize)
      {
         uv *= textureSize;
         float2  dx_vtc        = ddx(uv);
         float2  dy_vtc        = ddy(uv);
         float delta_max_sqr   = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
         return 0.5 * log2(delta_max_sqr);
      }

      inline fixed2 UnpackNormal2(fixed4 packednormal)
      {
          return packednormal.wy * 2 - 1;
         
      }

      half3 TriplanarHBlend(half h0, half h1, half h2, half3 pN, half contrast)
      {
         half3 blend = pN / dot(pN, half3(1,1,1));
         float3 heights = float3(h0, h1, h2) + (blend * 3.0);
         half height_start = max(max(heights.x, heights.y), heights.z) - contrast;
         half3 h = max(heights - height_start.xxx, half3(0,0,0));
         blend = h / dot(h, half3(1,1,1));
         return blend;
      }
      

      void ClearAllButAlbedo(inout MicroSplatLayer o, half3 display)
      {
         o.Albedo = display.rgb;
         o.Normal = half3(0, 0, 1);
         o.Smoothness = 0;
         o.Occlusion = 1;
         o.Emission = 0;
         o.Metallic = 0;
         o.Height = 0;
         #if _USESPECULARWORKFLOW
         o.Specular = 0;
         #endif

      }

      void ClearAllButAlbedo(inout MicroSplatLayer o, half display)
      {
         o.Albedo = half3(display, display, display);
         o.Normal = half3(0, 0, 1);
         o.Smoothness = 0;
         o.Occlusion = 1;
         o.Emission = 0;
         o.Metallic = 0;
         o.Height = 0;
         #if _USESPECULARWORKFLOW
         o.Specular = 0;
         #endif

      }

     

      half MicroShadow(float3 lightDir, half3 normal, half ao, half strength)
      {
         half shadow = saturate(abs(dot(normal, lightDir)) + (ao * ao * 2.0) - 1.0);
         return 1 - ((1-shadow) * strength);
      }
      

      void DoDebugOutput(inout MicroSplatLayer l)
      {
         #if _DEBUG_OUTPUT_ALBEDO
            ClearAllButAlbedo(l, l.Albedo);
         #elif _DEBUG_OUTPUT_NORMAL
            // oh unit shader compiler normal stripping, how I hate you so..
            // must multiply by albedo to stop the normal from being white. Why, fuck knows?
            ClearAllButAlbedo(l, float3(l.Normal.xy * 0.5 + 0.5, l.Normal.z * saturate(l.Albedo.z+1)));
         #elif _DEBUG_OUTPUT_SMOOTHNESS
            ClearAllButAlbedo(l, l.Smoothness.xxx * saturate(l.Albedo.z+1));
         #elif _DEBUG_OUTPUT_METAL
            ClearAllButAlbedo(l, l.Metallic.xxx * saturate(l.Albedo.z+1));
         #elif _DEBUG_OUTPUT_AO
            ClearAllButAlbedo(l, l.Occlusion.xxx * saturate(l.Albedo.z+1));
         #elif _DEBUG_OUTPUT_EMISSION
            ClearAllButAlbedo(l, l.Emission * saturate(l.Albedo.z+1));
         #elif _DEBUG_OUTPUT_HEIGHT
            ClearAllButAlbedo(l, l.Height.xxx * saturate(l.Albedo.z+1));
         #elif _DEBUG_OUTPUT_SPECULAR && _USESPECULARWORKFLOW
            ClearAllButAlbedo(l, l.Specular * saturate(l.Albedo.z+1));
         #elif _DEBUG_BRANCHCOUNT_WEIGHT
            ClearAllButAlbedo(l, _branchWeightCount / 12 * saturate(l.Albedo.z + 1));
         #elif _DEBUG_BRANCHCOUNT_TRIPLANAR
            ClearAllButAlbedo(l, _branchTriplanarCount / 24 * saturate(l.Albedo.z + 1));
         #elif _DEBUG_BRANCHCOUNT_CLUSTER
            ClearAllButAlbedo(l, _branchClusterCount / 12 * saturate(l.Albedo.z + 1));
         #elif _DEBUG_BRANCHCOUNT_OTHER
            ClearAllButAlbedo(l, _branchOtherCount / 8 * saturate(l.Albedo.z + 1));
         #elif _DEBUG_BRANCHCOUNT_TOTAL
            l.Albedo.r = _branchWeightCount / 12;
            l.Albedo.g = _branchTriplanarCount / 24;
            l.Albedo.b = _branchClusterCount / 12;
            ClearAllButAlbedo(l, (l.Albedo.r + l.Albedo.g + l.Albedo.b + (_branchOtherCount / 8)) / 4); 
         #elif _DEBUG_OUTPUT_MICROSHADOWS
            ClearAllButAlbedo(l,l.Albedo); 
         #elif _DEBUG_SAMPLECOUNT
            float sdisp = (float)_sampleCount / max(_SampleCountDiv, 1);
            half3 sdcolor = float3(sdisp, sdisp > 1 ? 1 : 0, 0);
            ClearAllButAlbedo(l, sdcolor * saturate(l.Albedo.z + 1));
         #elif _DEBUG_PROCLAYERS
            ClearAllButAlbedo(l, (float)_procLayerCount / (float)_PCLayerCount * saturate(l.Albedo.z + 1));
         #endif
      }


      // man I wish unity would wrap everything instead of only what they use. Just seems like a landmine for
      // people like myself.. especially as they keep changing things around and I have to figure out all the new defines
      // and handle changes across Unity versions, which would be automatically handled if they just wrapped these themselves without
      // as much complexity..

      #if (UNITY_VERSION >= 201810 && (defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (SHADER_TARGET_SURFACE_ANALYSIS && !SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))) || (UNITY_VERSION < 201810 && (defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL))) 
           #define MICROSPLAT_SAMPLE_TEX2D_LOD(tex,coord, lod) tex.SampleLevel (sampler##tex,coord, lod)
           #define MICROSPLAT_SAMPLE_TEX2D_SAMPLER_LOD(tex,samplertex,coord, lod) tex.SampleLevel (sampler##samplertex,coord, lod)
        #else
           #define MICROSPLAT_SAMPLE_TEX2D_LOD(tex,coord,lod) tex2D (tex,coord,0,lod)
           #define MICROSPLAT_SAMPLE_TEX2D_SAMPLER_LOD(tex,samplertex,coord,lod) tex2D (tex,coord,0,lod)
        #endif
     


        #if (UNITY_VERSION >= 201810 && (defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (SHADER_TARGET_SURFACE_ANALYSIS && !SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))) || (UNITY_VERSION < 201810 && (defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL))) 
           #define MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(tex,coord,dx,dy) tex.SampleGrad (sampler##tex,coord,dx,dy)
        #elif defined(SHADER_API_D3D9)
           #define MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(tex,coord,dx,dy) half4(0,1,0,0) 
        #elif defined(UNITY_COMPILER_HLSL2GLSL) || defined(SHADER_TARGET_SURFACE_ANALYSIS)
           #define MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(tex,coord,dx,dy) texCUBEgrad (tex,coord,float3(dx.x,dx.y,0),float3(dy.x,dy.y,0))
        #elif defined(SHADER_API_GLES)
           #define MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(tex,coord,dx,dy) half4(1,1,0,0)
        #elif defined(SHADER_API_D3D11_9X)
           #define MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(tex,coord,dx,dy) half4(0,1,1,0) 
        #else
           #define MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(tex,coord,dx,dy) half4(0,0,1,0) 
        #endif
        
        #if (UNITY_VERSION >= 201810 && (defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (SHADER_TARGET_SURFACE_ANALYSIS && !SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))) || (UNITY_VERSION < 201810 && (defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL))) 
           #define MICROSPLAT_SAMPLE_TEX2D_SAMPLER_GRAD(tex,samp,coord,dx,dy) tex.SampleGrad (sampler##samp,coord,dx,dy)
        #elif defined(SHADER_API_D3D9)
           #define MICROSPLAT_SAMPLE_TEX2D_SAMPLER_GRAD(tex,samp,coord,dx,dy) half4(0,1,0,0) 
        #elif defined(UNITY_COMPILER_HLSL2GLSL) || defined(SHADER_TARGET_SURFACE_ANALYSIS)
           #define MICROSPLAT_SAMPLE_TEX2D_SAMPLER_GRAD(tex,samp,coord,dx,dy) half4(1,0,1,0)
        #elif defined(SHADER_API_GLES)
           #define MICROSPLAT_SAMPLE_TEX2D_SAMPLER_GRAD(tex,samp,coord,dx,dy) half4(1,1,0,0)
        #elif defined(SHADER_API_D3D11_9X)
           #define MICROSPLAT_SAMPLE_TEX2D_SAMPLER_GRAD(tex,samp,coord,dx,dy) half4(0,1,1,0) 
        #else
           #define MICROSPLAT_SAMPLE_TEX2D_SAMPLER_GRAD(tex,samp,coord,dx,dy) half4(0,0,1,0) 
        #endif
      

      #if _USELODMIP
         #define MICROSPLAT_SAMPLE(tex, u, l) UNITY_SAMPLE_TEX2DARRAY_LOD(tex, u, l.x)
      #elif _USEGRADMIP
         #define MICROSPLAT_SAMPLE(tex, u, l) MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(tex, u, l.xy, l.zw)
      #else
         #define MICROSPLAT_SAMPLE(tex, u, l) UNITY_SAMPLE_TEX2DARRAY(tex, u)
      #endif

      #if _USELODMIP
         #define MICROSPLAT_SAMPLE(tex, u, l) UNITY_SAMPLE_TEX2DARRAY_LOD(tex, u, l.x)
      #elif _USEGRADMIP
         #define MICROSPLAT_SAMPLE(tex, u, l) MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(tex, u, l.xy, l.zw)
      #else
         #define MICROSPLAT_SAMPLE(tex, u, l) UNITY_SAMPLE_TEX2DARRAY(tex, u)
      #endif


      #define MICROSPLAT_SAMPLE_DIFFUSE(u, cl, l) MICROSPLAT_SAMPLE(_Diffuse, u, l)
      #define MICROSPLAT_SAMPLE_EMIS(u, cl, l) MICROSPLAT_SAMPLE(_EmissiveMetal, u, l)
      #define MICROSPLAT_SAMPLE_DIFFUSE_LOD(u, cl, l) UNITY_SAMPLE_TEX2DARRAY_LOD(_Diffuse, u, l)
      

      #if _PACKINGHQ
         #define MICROSPLAT_SAMPLE_NORMAL(u, cl, l) half4(MICROSPLAT_SAMPLE(_NormalSAO, u, l).ga, MICROSPLAT_SAMPLE(_SmoothAO, u, l).ga).brag
      #else
         #define MICROSPLAT_SAMPLE_NORMAL(u, cl, l) MICROSPLAT_SAMPLE(_NormalSAO, u, l)
      #endif

      #if _USESPECULARWORKFLOW
         #define MICROSPLAT_SAMPLE_SPECULAR(u, cl, l) MICROSPLAT_SAMPLE(_Specular, u, l)
      #endif
      




      void PrepTriplanar(float3 n, float3 worldPos, Config c, inout TriplanarConfig tc, half4 weights, inout MIPFORMAT albedoLOD, inout MIPFORMAT normalLOD, inout MIPFORMAT emisLOD)
      {
         #if _TRIPLANARLOCALSPACE && !_FORCELOCALSPACE
            worldPos = mul(unity_WorldToObject, float4(worldPos, 1));
            n = mul(unity_WorldToObject, float4(n, 1)).xyz;
         #endif
         
         tc.pN = pow(abs(n), abs(_TriplanarContrast));
         tc.pN = tc.pN / (tc.pN.x + tc.pN.y + tc.pN.z);
     
         // Get the sign (-1 or 1) of the surface normal
         half3 axisSign = n < 0 ? -1 : 1;
         axisSign.z *= -1;
         tc.axisSign = axisSign;
         tc.uv0 = float3x3(c.uv0, c.uv0, c.uv0);
         tc.uv1 = float3x3(c.uv1, c.uv1, c.uv1);
         tc.uv2 = float3x3(c.uv2, c.uv2, c.uv2);
         tc.uv3 = float3x3(c.uv3, c.uv3, c.uv3);
         tc.pN0 = tc.pN;
         tc.pN1 = tc.pN;
         tc.pN2 = tc.pN;
         tc.pN3 = tc.pN;



         float2 uscale = 0.1 * _TriplanarUVScale.xy; // closer values to terrain scales..
         
         
         
         tc.uv0[0].xy = (worldPos.zy * uscale + _TriplanarUVScale.zw);
         tc.uv0[1].xy = (worldPos.xz * uscale + _TriplanarUVScale.zw);
         tc.uv0[2].xy = (worldPos.xy * uscale + _TriplanarUVScale.zw);
         tc.uv0[0].x *= axisSign.x;
         tc.uv0[1].x *= axisSign.y;
         tc.uv0[2].x *= axisSign.z;

         tc.uv1[0].xy = tc.uv0[0].xy;
         tc.uv1[1].xy = tc.uv0[1].xy;
         tc.uv1[2].xy = tc.uv0[2].xy;

         tc.uv2[0].xy = tc.uv0[0].xy;
         tc.uv2[1].xy = tc.uv0[1].xy;
         tc.uv2[2].xy = tc.uv0[2].xy;

         tc.uv3[0].xy = tc.uv0[0].xy;
         tc.uv3[1].xy = tc.uv0[1].xy;
         tc.uv3[2].xy = tc.uv0[2].xy;
         
         #if _USEGRADMIP
            albedoLOD.d0 = float4(ddx(tc.uv0[0].xy), ddy(tc.uv0[0].xy));
            albedoLOD.d1 = float4(ddx(tc.uv0[1].xy), ddy(tc.uv0[1].xy));
            albedoLOD.d2 = float4(ddx(tc.uv0[2].xy), ddy(tc.uv0[2].xy));
            normalLOD = albedoLOD;
            emisLOD = albedoLOD;
         #elif _USELODMIP
            albedoLOD.x = ComputeMipLevel(tc.uv0[0].xy, _Diffuse_TexelSize.zw);
            albedoLOD.y = ComputeMipLevel(tc.uv0[1].xy, _Diffuse_TexelSize.zw);
            albedoLOD.z = ComputeMipLevel(tc.uv0[2].xy, _Diffuse_TexelSize.zw);
            normalLOD = albedoLOD;
            emisLOD = albedoLOD;
         #endif
         
         
         #if _PERTEXUVSCALEOFFSET
            SAMPLE_PER_TEX(ptUVScale, 0.5, c, half4(1,1,0,0));
            tc.uv0[0].xy = tc.uv0[0].xy * ptUVScale0.xy + ptUVScale0.zw;
            tc.uv0[1].xy = tc.uv0[1].xy * ptUVScale0.xy + ptUVScale0.zw;
            tc.uv0[2].xy = tc.uv0[2].xy * ptUVScale0.xy + ptUVScale0.zw;

            tc.uv1[0].xy = tc.uv1[0].xy * ptUVScale1.xy + ptUVScale1.zw;
            tc.uv1[1].xy = tc.uv1[1].xy * ptUVScale1.xy + ptUVScale1.zw;
            tc.uv1[2].xy = tc.uv1[2].xy * ptUVScale1.xy + ptUVScale1.zw;

            #if !_MAX2LAYER
               tc.uv2[0].xy = tc.uv2[0].xy * ptUVScale2.xy + ptUVScale2.zw;
               tc.uv2[1].xy = tc.uv2[1].xy * ptUVScale2.xy + ptUVScale2.zw;
               tc.uv2[2].xy = tc.uv2[2].xy * ptUVScale2.xy + ptUVScale2.zw;
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               tc.uv3[0].xy = tc.uv3[0].xy * ptUVScale3.xy + ptUVScale3.zw;
               tc.uv3[1].xy = tc.uv3[1].xy * ptUVScale3.xy + ptUVScale3.zw;
               tc.uv3[2].xy = tc.uv3[2].xy * ptUVScale3.xy + ptUVScale3.zw;
            #endif
            
            #if _USEGRADMIP
               albedoLOD.d0 = albedoLOD.d0 * ptUVScale0.xyxy * weights.x + 
                  albedoLOD.d0 * ptUVScale1.xyxy * weights.y + 
                  albedoLOD.d0 * ptUVScale2.xyxy * weights.z + 
                  albedoLOD.d0 * ptUVScale3.xyxy * weights.w;
               
               albedoLOD.d1 = albedoLOD.d1 * ptUVScale0.xyxy * weights.x + 
                  albedoLOD.d1 * ptUVScale1.xyxy * weights.y + 
                  albedoLOD.d1 * ptUVScale2.xyxy * weights.z + 
                  albedoLOD.d1 * ptUVScale3.xyxy * weights.w;
               
               albedoLOD.d2 = albedoLOD.d2 * ptUVScale0.xyxy * weights.x + 
                  albedoLOD.d2 * ptUVScale1.xyxy * weights.y + 
                  albedoLOD.d2 * ptUVScale2.xyxy * weights.z + 
                  albedoLOD.d2 * ptUVScale3.xyxy * weights.w;
                       
               
               normalLOD.d0 = albedoLOD.d0;
               normalLOD.d1 = albedoLOD.d1;
               normalLOD.d2 = albedoLOD.d2;
               
               #if _USEEMISSIVEMETAL
                  emisLOD.d0 = albedoLOD.d0;
                  emisLOD.d1 = albedoLOD.d1;
                  emisLOD.d2 = albedoLOD.d2;
               #endif
            #endif
         #else
            #if _USEGRADMIP
               albedoLOD.d0 = albedoLOD.d0 * weights.x + 
                  albedoLOD.d0 * weights.y + 
                  albedoLOD.d0 * weights.z + 
                  albedoLOD.d0 * weights.w;
               
               albedoLOD.d1 = albedoLOD.d1 * weights.x + 
                  albedoLOD.d1 * weights.y + 
                  albedoLOD.d1 * weights.z + 
                  albedoLOD.d1 * weights.w;
               
               albedoLOD.d2 = albedoLOD.d2 * weights.x + 
                  albedoLOD.d2 * weights.y + 
                  albedoLOD.d2 * weights.z + 
                  albedoLOD.d2 * weights.w;
                       
               
               normalLOD.d0 = albedoLOD.d0;
               normalLOD.d1 = albedoLOD.d1;
               normalLOD.d2 = albedoLOD.d2;
               
               #if _USEEMISSIVEMETAL
                  emisLOD.d0 = albedoLOD.d0;
                  emisLOD.d1 = albedoLOD.d1;
                  emisLOD.d2 = albedoLOD.d2;
               #endif
            #endif
         #endif

         #if _PERTEXUVROTATION
            SAMPLE_PER_TEX(ptUVRot, 16.5, c, half4(0,0,0,0));
            tc.uv0[0].xy = RotateUV(tc.uv0[0].xy, ptUVRot0.x);
            tc.uv0[1].xy = RotateUV(tc.uv0[1].xy, ptUVRot0.y);
            tc.uv0[2].xy = RotateUV(tc.uv0[2].xy, ptUVRot0.z);
            
            tc.uv1[0].xy = RotateUV(tc.uv1[0].xy, ptUVRot1.x);
            tc.uv1[1].xy = RotateUV(tc.uv1[1].xy, ptUVRot1.y);
            tc.uv1[2].xy = RotateUV(tc.uv1[2].xy, ptUVRot1.z);
            #if !_MAX2LAYER
               tc.uv2[0].xy = RotateUV(tc.uv2[0].xy, ptUVRot2.x);
               tc.uv2[1].xy = RotateUV(tc.uv2[1].xy, ptUVRot2.y);
               tc.uv2[2].xy = RotateUV(tc.uv2[2].xy, ptUVRot2.z);
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               tc.uv3[0].xy = RotateUV(tc.uv3[0].xy, ptUVRot3.x);
               tc.uv3[1].xy = RotateUV(tc.uv3[1].xy, ptUVRot3.y);
               tc.uv3[2].xy = RotateUV(tc.uv3[2].xy, ptUVRot3.z);
            #endif
         #endif
         

      }
         

         #if _DETAILNOISE
         UNITY_DECLARE_TEX2D_NOSAMPLER(_DetailNoise);
         #endif

         #if _DISTANCENOISE
         UNITY_DECLARE_TEX2D_NOSAMPLER(_DistanceNoise);
         #endif

         #if _NORMALNOISE
         UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalNoise);
         #endif

         #if _NORMALNOISE2
         UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalNoise2);
         #endif

         #if _NORMALNOISE3
         UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalNoise3);
         #endif
         
         #if _NOISEHEIGHT
         UNITY_DECLARE_TEX2D_NOSAMPLER(_NoiseHeight);
         #endif

         #if _NOISEUV
         UNITY_DECLARE_TEX2D_NOSAMPLER(_NoiseUV);
         #endif

         struct AntiTileTriplanarConfig
         {
            float3 pn;
            float2 uv0;
            float2 uv1;
            float2 uv2;
         };
         
         void PrepAntiTileTriplanarConfig(inout AntiTileTriplanarConfig tc, float3 worldPos, float3 normal)
         {
            tc.pn = pow(abs(normal), 0.7);
            tc.pn = tc.pn / (tc.pn.x + tc.pn.y + tc.pn.z);
            
            half3 axisSign = sign(normal);

            tc.uv0 = worldPos.zy * axisSign.x;
            tc.uv1 = worldPos.xz * axisSign.y;
            tc.uv2 = worldPos.xy * axisSign.z;
         }
         
         #if _ANTITILETRIPLANAR
            #define AntiTileTriplanarSample(tex, uv, tc, scale) (UNITY_SAMPLE_TEX2D_SAMPLER(tex, _Diffuse, tc.uv0 * scale) * tc.pn.x + UNITY_SAMPLE_TEX2D_SAMPLER(tex, _Diffuse, tc.uv1 * scale) * tc.pn.y + UNITY_SAMPLE_TEX2D_SAMPLER(tex, _Diffuse, tc.uv2 * scale) * tc.pn.z)
         #else
            #define AntiTileTriplanarSample(tex, uv, tc, scale) UNITY_SAMPLE_TEX2D_SAMPLER(tex, _Diffuse, uv * scale)
         #endif

         #if _ANTITILETRIPLANAR
            #define AntiTileTriplanarSampleLOD(tex, uv, tc, scale) (MICROSPLAT_SAMPLE_TEX2D_SAMPLER_LOD(tex, _Diffuse, tc.uv0 * scale, 0) * tc.pn.x + MICROSPLAT_SAMPLE_TEX2D_SAMPLER_LOD(tex, _Diffuse, tc.uv1 * scale, 0) * tc.pn.y + MICROSPLAT_SAMPLE_TEX2D_SAMPLER_LOD(tex, _Diffuse, tc.uv2 * scale, 0) * tc.pn.z)
         #else
            #define AntiTileTriplanarSampleLOD(tex, uv, tc, scale) MICROSPLAT_SAMPLE_TEX2D_SAMPLER_LOD(tex, _Diffuse, uv * scale, 0)
         #endif
         

         
         #if _NOISEHEIGHT
         
         void ApplyNoiseHeight(inout RawSamples s, float2 uv, Config config, float3 worldPos, float3 worldNormal)
         {
            float2 offset = float2(0.27, 0.17);

            half freq0 = _NoiseHeightData.x;
            half freq1 = _NoiseHeightData.x;
            half freq2 = _NoiseHeightData.x;
            half freq3 = _NoiseHeightData.x;

            half amp0 = _NoiseHeightData.y;
            half amp1 = _NoiseHeightData.y;
            half amp2 = _NoiseHeightData.y;
            half amp3 = _NoiseHeightData.y;

            #if _PERTEXNOISEHEIGHTFREQ || _PERTEXNOISEHEIGHTAMP
               SAMPLE_PER_TEX(pt, 22.5, config, half4(1, 0, 1, 0));

               #if _PERTEXNOISEHEIGHTFREQ
                  freq0 += pt0.r;
                  freq1 += pt1.r;
                  freq2 += pt2.r;
                  freq3 += pt3.r;
               #endif
               #if _PERTEXNOISEHEIGHTAMP
                  amp0 *= pt0.g;
                  amp1 *= pt1.g;
                  amp2 *= pt2.g;
                  amp3 *= pt3.g;
               #endif
            #endif

            AntiTileTriplanarConfig tc = (AntiTileTriplanarConfig)0;
            UNITY_INITIALIZE_OUTPUT(AntiTileTriplanarConfig,tc);
            
            #if _ANTITILETRIPLANAR
                PrepAntiTileTriplanarConfig(tc, worldPos, worldNormal);
            #endif
            

            half noise0 = AntiTileTriplanarSample(_NoiseHeight, uv, tc, freq0 + config.uv0.z * offset).g - 0.5;
            COUNTSAMPLE
            half noise1 = AntiTileTriplanarSample(_NoiseHeight, uv, tc, freq1 + config.uv1.z * offset).g - 0.5;
            COUNTSAMPLE
            half noise2 = 0;
            half noise3 = 0;
           
            #if !_MAXLAYER2
               noise2 = AntiTileTriplanarSample(_NoiseHeight, uv, tc, freq2 + config.uv2.z * offset).g - 0.5;
               COUNTSAMPLE
            #endif
            #if !_MAXLAYER2 && !_MAXLAYER3
               noise3 = AntiTileTriplanarSample(_NoiseHeight, uv, tc, freq3 + config.uv3.z * offset).g - 0.5;
               COUNTSAMPLE
            #endif

            s.albedo0.a = saturate(s.albedo0.a + noise0 * amp0);
            s.albedo1.a = saturate(s.albedo1.a + noise1 * amp1);
            s.albedo2.a = saturate(s.albedo2.a + noise2 * amp2);
            s.albedo3.a = saturate(s.albedo3.a + noise3 * amp3);
         }

         void ApplyNoiseHeightLOD(inout half h0, inout half h1, inout half h2, inout half h3, float2 uv, Config config, float3 worldPos, float3 worldNormal)
         {
            float2 offset = float2(0.27, 0.17);

            half freq0 = _NoiseHeightData.x;
            half freq1 = _NoiseHeightData.x;
            half freq2 = _NoiseHeightData.x;
            half freq3 = _NoiseHeightData.x;

            half amp0 = _NoiseHeightData.y;
            half amp1 = _NoiseHeightData.y;
            half amp2 = _NoiseHeightData.y;
            half amp3 = _NoiseHeightData.y;

            #if _PERTEXNOISEHEIGHTFREQ || _PERTEXNOISEHEIGHTAMP
               SAMPLE_PER_TEX(pt, 22.5, config, half4(1, 0, 1, 0));

               #if _PERTEXNOISEHEIGHTFREQ
                  freq0 += pt0.r;
                  freq1 += pt1.r;
                  freq2 += pt2.r;
                  freq3 += pt3.r;
               #endif
               #if _PERTEXNOISEHEIGHTAMP
                  amp0 *= pt0.g;
                  amp1 *= pt1.g;
                  amp2 *= pt2.g;
                  amp3 *= pt3.g;
               #endif
            #endif
            
            AntiTileTriplanarConfig tc = (AntiTileTriplanarConfig)0;
            UNITY_INITIALIZE_OUTPUT(AntiTileTriplanarConfig,tc);
            
            #if _ANTITILETRIPLANAR
                PrepAntiTileTriplanarConfig(tc, worldPos, worldNormal);
            #endif
            
            
            half noise0 = AntiTileTriplanarSampleLOD(_NoiseHeight, uv, tc, freq0 + config.uv0.z * offset).g;
            half noise1 = AntiTileTriplanarSampleLOD(_NoiseHeight, uv, tc, freq1 + config.uv1.z * offset).g;
            half noise2 = 0;
            half noise3 = 0;
           
            #if !_MAXLAYER2
               noise2 = AntiTileTriplanarSampleLOD(_NoiseHeight, uv, tc, freq2 + config.uv2.z * offset).g;
            #endif
            #if !_MAXLAYER2 && !_MAXLAYER3
               noise3 = AntiTileTriplanarSampleLOD(_NoiseHeight, uv, tc, freq3 + config.uv3.z * offset).g;
            #endif

            h0 = saturate(h0 + noise0 * amp0);
            h1 = saturate(h1 + noise1 * amp1);
            h2 = saturate(h2 + noise2 * amp2);
            h3 = saturate(h3 + noise3 * amp3);
         }
         #endif


         void DistanceResample(inout RawSamples o, Config config, TriplanarConfig tc, float camDist, float3 viewDir, half4 fxLevels, MIPFORMAT mipLevel, float3 worldPos, half4 weights, float3 worldNormal)
         {
         #if _DISTANCERESAMPLE

            
            #if _DISTANCERESAMPLENOFADE
               float distanceBlend = 1;
            #elif _DISTANCERESAMPLENOISE
               #if _TRIPLANAR
                  float distanceBlend = 1 + FBM3D(worldPos * _DistanceResampleNoiseParams.x) * _DistanceResampleNoiseParams.y;
               #else
                  float distanceBlend = 1 + FBM2D(config.uv * _DistanceResampleNoiseParams.x) * _DistanceResampleNoiseParams.y;
               #endif // triplanar
            #else
               float distanceBlend = saturate((camDist - _ResampleDistanceParams.y) / (_ResampleDistanceParams.z - _ResampleDistanceParams.y));
            #endif
            
            float dblend0 = distanceBlend;
            float dblend1 = distanceBlend;
            float dblend2 = 0;
            float dblend3 = 0;

            #if _DISTANCERESAMPLEMAXLAYER3
               dblend2 = distanceBlend;
               dblend3 = 0;
            #elif _DISTANCERESAMPLEMAXLAYER4
               dblend2 = distanceBlend;
               dblend3 = distanceBlend;
            #endif
            
            float uvScale0 = _ResampleDistanceParams.x;
            float uvScale1 = _ResampleDistanceParams.x;
            float uvScale2 = _ResampleDistanceParams.x;
            float uvScale3 = _ResampleDistanceParams.x;


            #if _PERTEXDISTANCERESAMPLEUVSCALE
               SAMPLE_PER_TEX(uvsc, 13.5, config, half4(1.0, 1.0, 1.0, 1.0));
               uvScale0 *= uvsc0.w;
               uvScale1 *= uvsc1.w;
               uvScale2 *= uvsc2.w;
               uvScale3 *= uvsc3.w;
            #endif
            

            #if _PERTEXDISTANCERESAMPLEUVSCALE && _USEGRADMIP && !_TRIPLANAR
                  mipLevel.xy = ddx(config.uv0.xy);
                  mipLevel.zw = ddy(config.uv0.xy);
                  mipLevel = mipLevel * uvScale0 * weights.x + 
                             mipLevel * uvScale1 * weights.y + 
                             mipLevel * uvScale2 * weights.z + 
                             mipLevel * uvScale3 * weights.w;
            #endif
            
            config.uv0.xy *= uvScale0;
            config.uv1.xy *= uvScale1;
            config.uv2.xy *= uvScale2;
            config.uv3.xy *= uvScale3;
            
            #if _TRIPLANAR
               tc.uv0[0].xy *= uvScale0;
               tc.uv1[0].xy *= uvScale1;
               tc.uv2[0].xy *= uvScale2;
               tc.uv3[0].xy *= uvScale3;

               tc.uv0[1].xy *= uvScale0;
               tc.uv1[1].xy *= uvScale1;
               tc.uv2[1].xy *= uvScale2;
               tc.uv3[1].xy *= uvScale3;

               tc.uv0[2].xy *= uvScale0;
               tc.uv1[2].xy *= uvScale1;
               tc.uv2[2].xy *= uvScale2;
               tc.uv3[2].xy *= uvScale3;
            #endif
            

            #if _TRIPLANAR
               #if _USEGRADMIP
                  mipLevel.d0 *= uvScale0;
                  mipLevel.d1 *= uvScale0;
                  mipLevel.d2 *= uvScale0;
               #elif _USELODMIP
                  mipLevel.x = ComputeMipLevel(tc.uv0[0], _Diffuse_TexelSize.zw);
                  mipLevel.y = ComputeMipLevel(tc.uv0[1], _Diffuse_TexelSize.zw);
                  mipLevel.z = ComputeMipLevel(tc.uv0[2], _Diffuse_TexelSize.zw);
               #endif
            #else
               #if _USEGRADMIP && !_PERTEXDISTANCERESAMPLEUVSCALE
                  mipLevel.xy = ddx(config.uv0.xy);
                  mipLevel.zw = ddy(config.uv0.xy);
               #elif _USELODMIP
                  mipLevel = ComputeMipLevel(config.uv0.xy, _Diffuse_TexelSize.zw);
               #endif
            #endif


            

            half4 albedo0 = 0;
            half4 albedo1 = 0;
            half4 albedo2 = 0;
            half4 albedo3 = 0;


            #if _DISTANCERESAMPLENORMAL
               half4 nsao0 = half4(0, 0, 0, 1);
               half4 nsao1 = half4(0, 0, 0, 1);
               half4 nsao2 = half4(0, 0, 0, 1);
               half4 nsao3 = half4(0, 0, 0, 1);
            #endif

            #if _PERTEXDISTANCERESAMPLESTRENGTH
               SAMPLE_PER_TEX(strs, 4.5, config, half4(1.0, 1.0, 1.0, 0.0));
               dblend0 *= strs0.b;
               dblend1 *= strs1.b;
               dblend2 *= strs2.b;
               dblend3 *= strs3.b;
            #endif

            // normalize weights
            //half4 blends = normalize(half4(dblend0, dblend1, dblend2, dblend3));
            //dblend0 = blends.x;
            //dblend1 = blends.y;
            //dblend2 = blends.z;
            //dblend3 = blends.w;

            // scale for effects
            #if _STREAMS || _PUDDLES || _LAVA
               half fac = 1.0 - min(fxLevels.y + fxLevels.z + fxLevels.w, 1.0f);
               dblend0 *= fac;
               dblend1 *= fac;
               dblend2 *= fac;
               dblend3 *= fac;
            #endif

            #if _TRIPLANAR
               #if _USEGRADMIP
                  float4 d0 = mipLevel.d0;
                  float4 d1 = mipLevel.d1;
                  float4 d2 = mipLevel.d2;
               #else
                  MIPFORMAT d0 = mipLevel;
                  MIPFORMAT d1 = mipLevel;
                  MIPFORMAT d2 = mipLevel;
               #endif
            MSBRANCHOTHER(dblend0)
            {
               half4 a0 = half4(0,0,0,0.0);
               half4 a1 = half4(0,0,0,0.0);
               half4 a2 = half4(0,0,0,0.0);
               half4 n0 = half4(0.5,0.5,0,1);
               half4 n1 = half4(0.5,0.5,0,1);
               half4 n2 = half4(0.5,0.5,0,1);
               #if _RESAMPLECLUSTERS && (_TEXTURECLUSTER2 || _TEXTURECLUSTER3 || _STOCHASTIC)
                  MSBRANCHTRIPLANAR(tc.pN0.x)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                       a0 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv0[0], config.cluster0, d0);
                       COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        n0 = MICROSPLAT_SAMPLE_NORMAL(tc.uv0[0], config.cluster0, d0).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.y)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a1 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv0[1], config.cluster0, d1);
                        COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        n1 = MICROSPLAT_SAMPLE_NORMAL(tc.uv0[1], config.cluster0, d1).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.z)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a2 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv0[2], config.cluster0, d2);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        n2 = MICROSPLAT_SAMPLE_NORMAL(tc.uv0[2], config.cluster0, d2).garb;
                        COUNTSAMPLE
                     #endif
                  }
               #else
                  MSBRANCHTRIPLANAR(tc.pN0.x)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a0 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv0[0], d0);
                        COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        n0 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv0[0], d0).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.y)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a1 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv0[1], d1);
                        COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        n1 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv0[1], d1).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.z)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a2 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv0[2], d2);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        n2 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv0[2], d2).garb;
                        COUNTSAMPLE
                     #endif
                  }
               #endif // _RESAMPLECLUSTERS && (_TEXTURECLUSTER2 || _TEXTURECLUSTER3 || _STOCHASTIC)

               #if !_DISTANCERESAMPLENOALBEDO
                  albedo0 = a0 * tc.pN0.x + a1 * tc.pN0.y + a2 * tc.pN0.z;
               #endif

               #if _DISTANCERESAMPLENORMAL
                  nsao0 = n0 * tc.pN0.x + n1 * tc.pN0.y + n2 * tc.pN0.z;
               #endif // _DISTANCERESAMPLENORMAL
            }
            MSBRANCHOTHER(weights.y * dblend1)
            {
               half4 a0 = half4(0,0,0,0.0);
               half4 a1 = half4(0,0,0,0.0);
               half4 a2 = half4(0,0,0,0.0);
               half4 n0 = half4(0.5,0.5,0,1);
               half4 n1 = half4(0.5,0.5,0,1);
               half4 n2 = half4(0.5,0.5,0,1);

               #if _RESAMPLECLUSTERS && (_TEXTURECLUSTER2 || _TEXTURECLUSTER3 || _STOCHASTIC)
                  MSBRANCHTRIPLANAR(tc.pN0.x)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a0 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv1[0], config.cluster1, d0);
                        COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        n0 = MICROSPLAT_SAMPLE_NORMAL(tc.uv1[0], config.cluster1, d0).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.y)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a1 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv1[1], config.cluster1, d1);
                        COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        n1 = MICROSPLAT_SAMPLE_NORMAL(tc.uv1[1], config.cluster1, d1).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.z)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a2 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv1[2], config.cluster1, d2);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        n2 = MICROSPLAT_SAMPLE_NORMAL(tc.uv1[2], config.cluster1, d2).garb;
                        COUNTSAMPLE
                     #endif
                  }
               #else
                  MSBRANCHTRIPLANAR(tc.pN1.x)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a0 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv1[0], d0);
                        COUNTSAMPLE
                     #endif
                     
                     #if _DISTANCERESAMPLENORMAL
                        n0 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv1[0], d0).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN1.y)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a1 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv1[1], d1);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        n1 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv1[1], d1).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN1.z)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a2 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv1[2], d2);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        n2 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv1[2], d2).garb;
                        COUNTSAMPLE
                     #endif
                  }
               #endif // #if _RESAMPLECLUSTERS && (_TEXTURECLUSTER2 || _TEXTURECLUSTER3 || _STOCHASTIC)

               #if !_DISTANCERESAMPLENOALBEDO
                  albedo1 = a0 * tc.pN1.x + a1 * tc.pN1.y + a2 * tc.pN1.z;
               #endif

               #if _DISTANCERESAMPLENORMAL
                  nsao1 = n0 * tc.pN0.x + n1 * tc.pN0.y + n2 * tc.pN0.z;
               #endif // _DISTANCERESAMPLENORMAL
            }

            #if _DISTANCERESAMPLEMAXLAYER3 || _DISTANCERESAMPLEMAXLAYER4
            MSBRANCHOTHER(weights.z * dblend2)
            {
               half4 a0 = half4(0,0,0,0.0);
               half4 a1 = half4(0,0,0,0.0);
               half4 a2 = half4(0,0,0,0.0);
               half4 n0 = half4(0.5,0.5,0,1);
               half4 n1 = half4(0.5,0.5,0,1);
               half4 n2 = half4(0.5,0.5,0,1);

               #if _RESAMPLECLUSTERS && (_TEXTURECLUSTER2 || _TEXTURECLUSTER3 || _STOCHASTIC)
                  MSBRANCHTRIPLANAR(tc.pN0.x)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a0 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv2[0], config.cluster2, d0);
                        COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        n0 = MICROSPLAT_SAMPLE_NORMAL(tc.uv2[0], config.cluster2, d0).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.y)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a1 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv2[1], config.cluster2, d1);
                        COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        n1 = MICROSPLAT_SAMPLE_NORMAL(tc.uv2[1], config.cluster2, d1).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.z)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a2 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv2[2], config.cluster2, d2);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        n2 = MICROSPLAT_SAMPLE_NORMAL(tc.uv2[2], config.cluster2, d2).garb;
                        COUNTSAMPLE
                     #endif
                  }
               #else
                  MSBRANCHTRIPLANAR(tc.pN1.x)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a0 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv2[0], d0);
                        COUNTSAMPLE
                     #endif
                     
                     #if _DISTANCERESAMPLENORMAL
                        n0 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv2[0], d0).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN1.y)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a1 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv2[1], d1);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        n1 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv2[1], d1).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN1.z)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a2 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv2[2], d2);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        n2 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv2[2], d2).garb;
                        COUNTSAMPLE
                     #endif
                  }
               #endif // #if _RESAMPLECLUSTERS && (_TEXTURECLUSTER2 || _TEXTURECLUSTER3 || _STOCHASTIC)

               #if !_DISTANCERESAMPLENOALBEDO
                  albedo2 = a0 * tc.pN1.x + a1 * tc.pN1.y + a2 * tc.pN1.z;
               #endif

               #if _DISTANCERESAMPLENORMAL
                  nsao2 = n0 * tc.pN0.x + n1 * tc.pN0.y + n2 * tc.pN0.z;
               #endif // _DISTANCERESAMPLENORMAL
            }
            #endif // _DISTANCERESAMPLEMAXLAYER3 ||  _DISTANCERESAMPLEMAXLAYER4
            #if _DISTANCERESAMPLEMAXLAYER4
            MSBRANCHOTHER(weights.w * dblend3)
            {
               half4 a0 = half4(0,0,0,0.0);
               half4 a1 = half4(0,0,0,0.0);
               half4 a2 = half4(0,0,0,0.0);
               half4 n0 = half4(0.5,0.5,0,1);
               half4 n1 = half4(0.5,0.5,0,1);
               half4 n2 = half4(0.5,0.5,0,1);

               #if _RESAMPLECLUSTERS && (_TEXTURECLUSTER2 || _TEXTURECLUSTER3 || _STOCHASTIC)
                  MSBRANCHTRIPLANAR(tc.pN0.x)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a0 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv3[0], config.cluster3, d0);
                        COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        n0 = MICROSPLAT_SAMPLE_NORMAL(tc.uv3[0], config.cluster3, d0).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.y)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a1 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv3[1], config.cluster3, d1);
                        COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        n1 = MICROSPLAT_SAMPLE_NORMAL(tc.uv3[1], config.cluster3, d1).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.z)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a2 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv3[2], config.cluster3, d2);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        n2 = MICROSPLAT_SAMPLE_NORMAL(tc.uv3[2], config.cluster3, d2).garb;
                        COUNTSAMPLE
                     #endif
                  }
               #else
                  MSBRANCHTRIPLANAR(tc.pN1.x)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a0 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv3[0], d0);
                        COUNTSAMPLE
                     #endif
                     
                     #if _DISTANCERESAMPLENORMAL
                        n0 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv3[0], d0).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN1.y)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a1 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv3[1], d1);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        n1 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv3[1], d1).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHTRIPLANAR(tc.pN1.z)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        a2 = MICROSPLAT_SAMPLE(_Diffuse, tc.uv3[2], d2);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        n2 = MICROSPLAT_SAMPLE(_NormalSAO, tc.uv3[2], d2).garb;
                        COUNTSAMPLE
                     #endif
                  }
               #endif // #if _RESAMPLECLUSTERS && (_TEXTURECLUSTER2 || _TEXTURECLUSTER3 || _STOCHASTIC)

               #if !_DISTANCERESAMPLENOALBEDO
                  albedo3 = a0 * tc.pN1.x + a1 * tc.pN1.y + a2 * tc.pN1.z;
               #endif

               #if _DISTANCERESAMPLENORMAL
                  nsao3 = n0 * tc.pN0.x + n1 * tc.pN0.y + n2 * tc.pN0.z;
               #endif // _DISTANCERESAMPLENORMAL
            }
            #endif


            #else // _TRIPLANAR
               #if _RESAMPLECLUSTERS && (_TEXTURECLUSTER2 || _TEXTURECLUSTER3 || _STOCHASTIC)
                  MSBRANCHOTHER(dblend0)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        albedo0 = MICROSPLAT_SAMPLE_DIFFUSE(config.uv0, config.cluster0, mipLevel);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        nsao0 = MICROSPLAT_SAMPLE_NORMAL(config.uv0, config.cluster0, mipLevel).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHOTHER(weights.y * dblend1)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        albedo1 = MICROSPLAT_SAMPLE_DIFFUSE(config.uv1, config.cluster1, mipLevel);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        nsao1 = MICROSPLAT_SAMPLE_NORMAL(config.uv1, config.cluster1, mipLevel).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  #if _DISTANCERESAMPLEMAXLAYER3 || _DISTANCERESAMPLEMAXLAYER4
                  MSBRANCHOTHER(weights.z * dblend2)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        albedo2 = MICROSPLAT_SAMPLE_DIFFUSE(config.uv2, config.cluster2, mipLevel);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        nsao2 = MICROSPLAT_SAMPLE_NORMAL(config.uv2, config.cluster2, mipLevel).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  #endif
                  #if _DISTANCERESAMPLEMAXLAYER4
                  MSBRANCHOTHER(weights.w * dblend3)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        albedo3 = MICROSPLAT_SAMPLE_DIFFUSE(config.uv3, config.cluster3, mipLevel);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        nsao3 = MICROSPLAT_SAMPLE_NORMAL(config.uv3, config.cluster3, mipLevel).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  #endif

               #else
                  MSBRANCHOTHER(dblend0)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        albedo0 = MICROSPLAT_SAMPLE(_Diffuse, config.uv0, mipLevel);
                        COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        nsao0 = MICROSPLAT_SAMPLE(_NormalSAO, config.uv0, mipLevel).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  MSBRANCHOTHER(weights.y * dblend1)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        albedo1 = MICROSPLAT_SAMPLE(_Diffuse, config.uv1, mipLevel);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        nsao1 = MICROSPLAT_SAMPLE(_NormalSAO, config.uv1, mipLevel).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  #if _DISTANCERESAMPLEMAXLAYER3 || _DISTANCERESAMPLEMAXLAYER4
                  MSBRANCHOTHER(weights.z * dblend2)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        albedo2 = MICROSPLAT_SAMPLE(_Diffuse, config.uv2, mipLevel);
                        COUNTSAMPLE
                     #endif
                     #if _DISTANCERESAMPLENORMAL
                        nsao2 = MICROSPLAT_SAMPLE(_NormalSAO, config.uv2, mipLevel).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  #endif
                  #if _DISTANCERESAMPLEMAXLAYER4
                  MSBRANCHOTHER(weights.w * dblend3)
                  {
                     #if !_DISTANCERESAMPLENOALBEDO
                        albedo3 = MICROSPLAT_SAMPLE(_Diffuse, config.uv3, mipLevel);
                        COUNTSAMPLE
                     #endif

                     #if _DISTANCERESAMPLENORMAL
                        nsao3 = MICROSPLAT_SAMPLE(_NormalSAO, config.uv3, mipLevel).garb;
                        COUNTSAMPLE
                     #endif
                  }
                  #endif
               #endif // _RESAMPLECLUSTERS && (_TEXTURECLUSTER2 || _TEXTURECLUSTER3)
            #endif // _TRIPLANAR
            
            #if _DISTANCERESAMPLEHEIGHTBLEND
               dblend0 = HeightBlend(o.albedo0.a, albedo0.a, dblend0, _Contrast);
               dblend1 = HeightBlend(o.albedo1.a, albedo1.a, dblend1, _Contrast);
               #if _DISTANCERESAMPLEMAXLAYER3 || _DISTANCERESAMPLEMAXLAYER4
                  dblend2 = HeightBlend(o.albedo2.a, albedo1.a, dblend2, _Contrast);
               #endif
               #if _DISTANCERESAMPLEMAXLAYER4
                  dblend3 = HeightBlend(o.albedo3.a, albedo1.a, dblend3, _Contrast);
               #endif
            #endif

            #if !_DISTANCERESAMPLENOALBEDO
               #if _DISTANCERESAMPLENOFADE || _DISTANCERESAMPLENOISE
                  #if _DISTANCERESAMPLEALBEDOBLENDOVERLAY
                     o.albedo0.rgb = lerp(o.albedo0.rgb, BlendOverlay(o.albedo0.rgb, albedo0.rgb), dblend0 * _DistanceResampleAlbedoStrength);
                     o.albedo1.rgb = lerp(o.albedo1.rgb, BlendOverlay(o.albedo1.rgb, albedo1.rgb), dblend1 * _DistanceResampleAlbedoStrength);
                     #if _DISTANCERESAMPLEMAXLAYER3 || _DISTANCERESAMPLEMAXLAYER4
                        o.albedo2.rgb = lerp(o.albedo2.rgb, BlendOverlay(o.albedo2.rgb, albedo2.rgb), dblend2 * _DistanceResampleAlbedoStrength);
                     #endif
                     #if _DISTANCERESAMPLEMAXLAYER4
                        o.albedo3.rgb = lerp(o.albedo3.rgb, BlendOverlay(o.albedo3.rgb, albedo3.rgb), dblend3 * _DistanceResampleAlbedoStrength);
                     #endif
                  #elif _DISTANCERESAMPLEALBEDOBLENDLIGHTERCOLOR
                     o.albedo0.rgb = lerp(o.albedo0.rgb, BlendLighterColor(o.albedo0.rgb, albedo0.rgb), dblend0 * _DistanceResampleAlbedoStrength);
                     o.albedo1.rgb = lerp(o.albedo1.rgb, BlendLighterColor(o.albedo1.rgb, albedo1.rgb), dblend1 * _DistanceResampleAlbedoStrength);
                     #if _DISTANCERESAMPLEMAXLAYER3 || _DISTANCERESAMPLEMAXLAYER4
                        o.albedo2.rgb = lerp(o.albedo2.rgb, BlendLighterColor(o.albedo2.rgb, albedo2.rgb), dblend2 * _DistanceResampleAlbedoStrength);
                     #endif
                     #if _DISTANCERESAMPLEMAXLAYER4
                        o.albedo3.rgb = lerp(o.albedo3.rgb, BlendLighterColor(o.albedo3.rgb, albedo3.rgb), dblend3 * _DistanceResampleAlbedoStrength);
                     #endif
                  #else
                     o.albedo0 = lerp(o.albedo0, albedo0, dblend0 * _DistanceResampleAlbedoStrength);
                     o.albedo1 = lerp(o.albedo1, albedo1, dblend1 * _DistanceResampleAlbedoStrength);
                     #if _DISTANCERESAMPLEMAXLAYER3 || _DISTANCERESAMPLEMAXLAYER4
                        o.albedo2 = lerp(o.albedo2, albedo2, dblend2 * _DistanceResampleAlbedoStrength);
                     #endif
                     #if _DISTANCERESAMPLEMAXLAYER4
                        o.albedo3 = lerp(o.albedo3, albedo3, dblend3 * _DistanceResampleAlbedoStrength);
                     #endif
                  #endif
               #else
                  o.albedo0 = lerp(o.albedo0, albedo0, dblend0 * _DistanceResampleAlbedoStrength);
                  o.albedo1 = lerp(o.albedo1, albedo1, dblend1 * _DistanceResampleAlbedoStrength);
                  #if _DISTANCERESAMPLEMAXLAYER3 || _DISTANCERESAMPLEMAXLAYER4
                     o.albedo2 = lerp(o.albedo2, albedo2, dblend2 * _DistanceResampleAlbedoStrength);
                  #endif
                  #if _DISTANCERESAMPLEMAXLAYER4
                     o.albedo3 = lerp(o.albedo3, albedo3, dblend3 * _DistanceResampleAlbedoStrength);
                  #endif
               #endif
            #endif

            #if _DISTANCERESAMPLENORMAL
               nsao0.xy *= 2;
               nsao1.xy *= 2;
               nsao0.xy -= 1;
               nsao1.xy -= 1;
               nsao0.xy *= _DistanceResampleNormalStrength;
               nsao1.xy *= _DistanceResampleNormalStrength;
               o.normSAO0.xy = lerp(o.normSAO0.xy, BlendNormal2(o.normSAO0.xy, nsao0.xy), dblend0);
               o.normSAO1.xy = lerp(o.normSAO1.xy, BlendNormal2(o.normSAO1.xy, nsao1.xy), dblend1);
               o.normSAO0.zw = lerp(o.normSAO0.zw, nsao0.zw, dblend0);
               o.normSAO1.zw = lerp(o.normSAO1.zw, nsao1.zw, dblend1);

               #if _DISTANCERESAMPLEMAXLAYER3 || _DISTANCERESAMPLEMAXLAYER4
                  nsao2.xy *= 2;
                  nsao2.xy -= 1;
                  nsao2.xy *= _DistanceResampleNormalStrength;
                  o.normSAO2.xy = lerp(o.normSAO2.xy, BlendNormal2(o.normSAO2.xy, nsao2.xy), dblend2);
                  o.normSAO2.zw = lerp(o.normSAO2.zw, nsao2.zw, dblend2);
               #endif
               #if _DISTANCERESAMPLEMAXLAYER4
                  o.normSAO3.xy = lerp(o.normSAO3.xy, BlendNormal2(o.normSAO3.xy, nsao3.xy), dblend3);
                  o.normSAO3.zw = lerp(o.normSAO3.zw, nsao3.zw, dblend3);
               #endif

            #endif

         #endif // _DISTANCERESAMPLE
         }

         // non-pertex
         void ApplyDetailDistanceNoise(inout half3 albedo, inout half4 normSAO, Config config, float camDist, float3 worldPos, float3 normal)
         {
            AntiTileTriplanarConfig tc = (AntiTileTriplanarConfig)0;
            UNITY_INITIALIZE_OUTPUT(AntiTileTriplanarConfig,tc);
            
            #if _ANTITILETRIPLANAR
                PrepAntiTileTriplanarConfig(tc, worldPos, normal);
            #endif
            
            #if _DETAILNOISE && !_PERTEXDETAILNOISESTRENGTH 
            {
               float2 uv = config.uv;
               #if _WORLDUV
                  uv = worldPos.xz;
               #endif

               MSBRANCHOTHER(_DetailNoiseScaleStrengthFade.z - camDist)
               {
                  half3 noise = AntiTileTriplanarSample(_DetailNoise, uv, tc, _UVScale.xy * _DetailNoiseScaleStrengthFade.x).rgb;
                  COUNTSAMPLE
                  
                  float fade = 1.0 - saturate((_DetailNoiseScaleStrengthFade.z - camDist) / _DetailNoiseScaleStrengthFade.z);
                  fade = 1.0 - (fade*fade);
                  fade *= _DetailNoiseScaleStrengthFade.y;

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  normSAO.xy += ((noise.xy-0.25) * fade);
               }
            }
            #endif
            #if _DISTANCENOISE && !_PERTEXDISTANCENOISESTRENGTH
            {
               MSBRANCHOTHER(camDist - _DistanceNoiseScaleStrengthFade.z)
               {       
                  float2 uv = config.uv;
                  #if _WORLDUV
                     uv = worldPos.xz;
                  #endif
               
                  uv *= _DistanceNoiseScaleStrengthFade.x;    
                  half3 noise = AntiTileTriplanarSample(_DistanceNoise, uv, tc, _UVScale.xy * _DistanceNoiseScaleStrengthFade.x).rgb;
                  COUNTSAMPLE

                  float fade = saturate ((camDist - _DistanceNoiseScaleStrengthFade.z) / _DistanceNoiseScaleStrengthFade.w);
                  fade *= _DistanceNoiseScaleStrengthFade.y;

                  albedo = lerp(albedo, BlendMult2X(albedo, noise.zzz), fade);
                  noise *= 0.5;
                  normSAO.xy += ((noise.xy-0.25) * fade);
                 
               }
            }
            #endif

            #if _NORMALNOISE && !_PERTEXNORMALNOISESTRENGTH
            {
               float2 uv = config.uv;
               #if _WORLDUV
                  uv = worldPos.xz;
               #endif
               half2 noise = UnpackNormal2(AntiTileTriplanarSample(_NormalNoise, uv, tc, _NormalNoiseScaleStrength.xx));
               COUNTSAMPLE

               normSAO.xy = lerp(normSAO.xy, BlendNormal2(normSAO.xy, noise.xy), _NormalNoiseScaleStrength.y);
            }
            #endif

            #if _NORMALNOISE2 && !_PERTEXNORMALNOISESTRENGTH2
            {
               float2 uv = config.uv;
               #if _WORLDUV
                  uv = worldPos.xz;
               #endif
               half2 noise = UnpackNormal2(AntiTileTriplanarSample(_NormalNoise2, uv, tc, _NormalNoiseScaleStrength2.xx));
               COUNTSAMPLE
               normSAO.xy = lerp(normSAO.xy, BlendNormal2(normSAO.xy, noise.xy), _NormalNoiseScaleStrength2.y);
            }
            #endif

            #if _NORMALNOISE3 && !_PERTEXNORMALNOISESTRENGTH3
            {
               float2 uv = config.uv;
               #if _WORLDUV
                  uv = worldPos.xz;
               #endif
               half2 noise = UnpackNormal2(AntiTileTriplanarSample(_NormalNoise3, uv, tc, _NormalNoiseScaleStrength3.xx));
               COUNTSAMPLE
               normSAO.xy = lerp(normSAO.xy, BlendNormal2(normSAO.xy, noise.xy), _NormalNoiseScaleStrength3.y);
            }
            #endif
         }

         // per tex version

         void ApplyDetailDistanceNoisePerTex(inout RawSamples o, Config config, float camDist, float3 worldPos, float3 normal)
         {
            AntiTileTriplanarConfig tc = (AntiTileTriplanarConfig)0;
            UNITY_INITIALIZE_OUTPUT(AntiTileTriplanarConfig,tc);
            
            #if _ANTITILETRIPLANAR
                PrepAntiTileTriplanarConfig(tc, worldPos, normal);
            #endif
         
            #if _PERTEXDETAILNOISESTRENGTH || _PERTEXDISTANCENOISESTRENGTH
            SAMPLE_PER_TEX(strs, 4.5, config, half4(1.0, 1.0, 1.0, 1.0));
            #endif
            
            float2 uv = config.uv;
            #if _WORLDUV
               uv = worldPos.xz;
            #endif

            #if _DETAILNOISE && _PERTEXDETAILNOISESTRENGTH
            {
               MSBRANCHOTHER(_DetailNoiseScaleStrengthFade.z - camDist)
               {
                  half3 noise = AntiTileTriplanarSample(_DetailNoise, uv, tc, _UVScale.xy * _DetailNoiseScaleStrengthFade.x);
                  COUNTSAMPLE
                  
                  half fade = 1.0 - saturate((_DetailNoiseScaleStrengthFade.z - camDist) / _DetailNoiseScaleStrengthFade.z);
                  fade = 1.0 - (fade*fade);
                  fade *= _DetailNoiseScaleStrengthFade.y;

   
                  o.albedo0.rgb = lerp(o.albedo0.rgb, BlendMult2X(o.albedo0.rgb, noise.zzz), fade * strs0.x);
                  o.albedo1.rgb = lerp(o.albedo1.rgb, BlendMult2X(o.albedo1.rgb, noise.zzz), fade * strs1.x);
                  #if !_MAX2LAYER
                  o.albedo2.rgb = lerp(o.albedo2.rgb, BlendMult2X(o.albedo2.rgb, noise.zzz), fade * strs2.x);
                  #endif
                  #if !_MAX2LAYER && !_MAX3LAYER
                  o.albedo3.rgb = lerp(o.albedo3.rgb, BlendMult2X(o.albedo3.rgb, noise.zzz), fade * strs3.x);
                  #endif


                  noise.xy *= 0.5;
                  noise.xy -= 0.25;
                  o.normSAO0.xy += noise.xy * fade * strs0.x;
                  o.normSAO1.xy += noise.xy * fade * strs1.x;
                  #if !_MAX2LAYER
                  o.normSAO2.xy += noise.xy * fade * strs2.x;
                  #endif
                  #if !_MAX2LAYER && !_MAX3LAYER
                  o.normSAO3.xy += noise.xy * fade * strs3.x;
                  #endif
               }
            }
            #endif
            #if _DISTANCENOISE && _PERTEXDISTANCENOISESTRENGTH
            {
               MSBRANCHOTHER(camDist - _DistanceNoiseScaleStrengthFade.z)
               {
                  half3 noise = AntiTileTriplanarSample(_DistanceNoise, uv, tc, _UVScale.xy * _DistanceNoiseScaleStrengthFade.x);
                  COUNTSAMPLE

                  float fade = saturate ((camDist - _DistanceNoiseScaleStrengthFade.z) / _DistanceNoiseScaleStrengthFade.w);
                  fade *= _DistanceNoiseScaleStrengthFade.y;

                  o.albedo0.rgb = lerp(o.albedo0.rgb, BlendMult2X(o.albedo0.rgb, noise.zzz), fade * strs0.y);
                  o.albedo1.rgb = lerp(o.albedo1.rgb, BlendMult2X(o.albedo1.rgb, noise.zzz), fade * strs1.y);
                  #if !_MAX2LAYER
                  o.albedo2.rgb = lerp(o.albedo2.rgb, BlendMult2X(o.albedo2.rgb, noise.zzz), fade * strs2.y);
                  #endif
                  #if !_MAX2LAYER && !_MAX3LAYER
                  o.albedo3.rgb = lerp(o.albedo3.rgb, BlendMult2X(o.albedo3.rgb, noise.zzz), fade * strs3.y);
                  #endif

                  noise.xy *= 0.5;
                  noise.xy -= 0.25;
                  o.normSAO0.xy += noise.xy * fade * strs0.y;
                  o.normSAO1.xy += noise.xy * fade * strs1.y;
                  #if !_MAX2LAYER
                  o.normSAO2.xy += noise.xy * fade * strs2.y;
                  #endif
                  #if !_MAX2LAYER && !_MAX3LAYER
                  o.normSAO3.xy += noise.xy * fade * strs3.y;
                  #endif
               }
            }
            #endif


            #if _PERTEXNORMALNOISESTRENGTH
            SAMPLE_PER_TEX(noiseStrs, 7.5, config, half4(0.5, 0.5, 0.5, 0.5));
            #endif

            #if _NORMALNOISE && _PERTEXNORMALNOISESTRENGTH
            {
               half2 noise = UnpackNormal2(AntiTileTriplanarSample(_NormalNoise, uv, tc, _NormalNoiseScaleStrength.xx));
               COUNTSAMPLE

               o.normSAO0.xy = lerp(o.normSAO0.xy, BlendNormal2(o.normSAO0.xy, noise.xy), _NormalNoiseScaleStrength.y * noiseStrs0.x);
               o.normSAO1.xy = lerp(o.normSAO1.xy, BlendNormal2(o.normSAO1.xy, noise.xy), _NormalNoiseScaleStrength.y * noiseStrs1.x);
               #if !_MAX2LAYER
               o.normSAO2.xy = lerp(o.normSAO2.xy, BlendNormal2(o.normSAO2.xy, noise.xy), _NormalNoiseScaleStrength.y * noiseStrs2.x);
               #endif
               #if !_MAX2LAYER && !_MAX3LAYER
               o.normSAO3.xy = lerp(o.normSAO3.xy, BlendNormal2(o.normSAO3.xy, noise.xy), _NormalNoiseScaleStrength.y * noiseStrs3.x);
               #endif
            }
            #endif

            #if _NORMALNOISE2 && _PERTEXNORMALNOISESTRENGTH

            {
               half2 noise = UnpackNormal2(AntiTileTriplanarSample(_NormalNoise2, uv, tc, _NormalNoiseScaleStrength2.xx));
               COUNTSAMPLE

               o.normSAO0.xy = lerp(o.normSAO0.xy, BlendNormal2(o.normSAO0.xy, noise.xy), _NormalNoiseScaleStrength2.y * noiseStrs0.y);
               o.normSAO1.xy = lerp(o.normSAO1.xy, BlendNormal2(o.normSAO1.xy, noise.xy), _NormalNoiseScaleStrength2.y * noiseStrs1.y);
               #if !_MAX2LAYER
               o.normSAO2.xy = lerp(o.normSAO2.xy, BlendNormal2(o.normSAO2.xy, noise.xy), _NormalNoiseScaleStrength2.y * noiseStrs2.y);
               #endif
               #if !_MAX2LAYER && !_MAX3LAYER
               o.normSAO3.xy = lerp(o.normSAO3.xy, BlendNormal2(o.normSAO3.xy, noise.xy), _NormalNoiseScaleStrength2.y * noiseStrs3.y);
               #endif
            }
            #endif

            #if _NORMALNOISE3 && _PERTEXNORMALNOISESTRENGTH
            {
               half2 noise =  UnpackNormal2(AntiTileTriplanarSample(_NormalNoise3, uv, tc, _NormalNoiseScaleStrength3.xx));
               COUNTSAMPLE

               o.normSAO0.xy = lerp(o.normSAO0.xy, BlendNormal2(o.normSAO0.xy, noise.xy), _NormalNoiseScaleStrength3.y * noiseStrs0.z);
               o.normSAO1.xy = lerp(o.normSAO1.xy, BlendNormal2(o.normSAO1.xy, noise.xy), _NormalNoiseScaleStrength3.y * noiseStrs1.z);
               #if !_MAX2LAYER
               o.normSAO2.xy = lerp(o.normSAO2.xy, BlendNormal2(o.normSAO2.xy, noise.xy), _NormalNoiseScaleStrength3.y * noiseStrs2.z);
               #endif
               #if !_MAX2LAYER && !_MAX3LAYER
               o.normSAO3.xy = lerp(o.normSAO3.xy, BlendNormal2(o.normSAO3.xy, noise.xy), _NormalNoiseScaleStrength3.y * noiseStrs3.z);
               #endif
            }

            #endif

         }
         
        


#if UNITY_VERSION >= 201830 && !_TERRAINBLENDABLESHADER && !_MICROMESH && !_MICRODIGGERMESH && !_MICROVERTEXMESH
#if defined(UNITY_INSTANCING_ENABLED) && !defined(SHADER_API_D3D11_9X)
    sampler2D _TerrainHeightmapTexture;
    sampler2D _TerrainNormalmapTexture;
    float4    _TerrainHeightmapRecipSize;   // float4(1.0f/width, 1.0f/height, 1.0f/(width-1), 1.0f/(height-1))
    float4    _TerrainHeightmapScale;       // float4(hmScale.x, hmScale.y / (float)(kMaxHeight), hmScale.z, 0.0f)
#endif
#endif

#if UNITY_VERSION >= 201830 && !_TERRAINBLENDABLESHADER && !_MICROMESH && !_MICRODIGGERMESH && !_MICROVERTEXMESH
UNITY_INSTANCING_BUFFER_START(Terrain)
    UNITY_DEFINE_INSTANCED_PROP(float4, _TerrainPatchInstanceData) // float4(xBase, yBase, skipScale, ~)
UNITY_INSTANCING_BUFFER_END(Terrain)
#endif


     

      // surface shaders + tessellation, do not pass go, or
      // collect $500 - sucks it up and realize you can't use
      // an Input struct, so you have to hack UV coordinates
      // and live with only the magic keywords..
      void vert (
         inout appdata i
         #if (_MICRODIGGERMESH || _MICROVERTEXMESH) && !_TESSDISTANCE
         , out Input IN
         #endif
         ) 
      {
         #if (_MICRODIGGERMESH || _MICROVERTEXMESH) && !_TESSDISTANCE
            IN = (Input)0;
         #endif

         #if !_DEBUG_USE_TOPOLOGY && UNITY_VERSION >= 201830 && !_TERRAINBLENDABLESHADER && !_MICROMESH && !_MICROMESHTERRAIN && !_MICROPOLARISMESH &&!_MICRODIGGERMESH && !_MICROVERTEXMESH && defined(UNITY_INSTANCING_ENABLED) && !defined(SHADER_API_D3D11_9X)

            float2 patchVertex = i.vertex.xy;
            float4 instanceData = UNITY_ACCESS_INSTANCED_PROP(Terrain, _TerrainPatchInstanceData);

            float4 uvscale = instanceData.z * _TerrainHeightmapRecipSize;
            float4 uvoffset = instanceData.xyxy * uvscale;
            uvoffset.xy += 0.5f * _TerrainHeightmapRecipSize.xy;
            float2 sampleCoords = (patchVertex.xy * uvscale.xy + uvoffset.xy);

            float hm = UnpackHeightmap(tex2Dlod(_TerrainHeightmapTexture, float4(sampleCoords, 0, 0)));
            i.vertex.xz = (patchVertex.xy + instanceData.xy) * _TerrainHeightmapScale.xz * instanceData.z;  //(x + xBase) * hmScale.x * skipScale;
            i.vertex.y = hm * _TerrainHeightmapScale.y;
            i.vertex.w = 1.0f;

            i.texcoord.xy = (patchVertex.xy * uvscale.zw + uvoffset.zw);
            
            i.texcoord2.xy = i.texcoord1.xy = i.texcoord.xy;
            
            i.normal = float3(0,1,0);
         #elif _PERPIXNORMAL
            i.normal = float3(0,1,0);
         #endif

         // Digger meshes don't have tangents, so we provide one in the digger case as well.
         #if !_MICROMESH && !_MICROVERTEXMESH && !_MICROPOLARISMESH
            float4 tangent;
            tangent.xyz = cross(UnityObjectToWorldNormal( i.normal ), float3(0,0,1));
            tangent.w = -1;
            i.tangent = tangent;
         #endif

         #if _MICROVERTEXMESH
            EncodeVertex(i, IN);
         #elif _MICRODIGGERMESH
            DiggerEncodeVertex(i, IN);
         #endif

      }




   




      void SampleAlbedo(inout Config config, inout TriplanarConfig tc, inout RawSamples s, MIPFORMAT mipLevel, half4 weights)
      {
         #if _DISABLESPLATMAPS
         return;
         #endif
         #if _TRIPLANAR
            #if _USEGRADMIP
               float4 d0 = mipLevel.d0;
               float4 d1 = mipLevel.d1;
               float4 d2 = mipLevel.d2;
            #elif _USELODMIP
               float d0 = mipLevel.x;
               float d1 = mipLevel.y;
               float d2 = mipLevel.z;
            #else
               MIPFORMAT d0 = mipLevel;
               MIPFORMAT d1 = mipLevel;
               MIPFORMAT d2 = mipLevel;
            #endif
         
            half4 contrasts = _Contrast.xxxx;
            #if _PERTEXTRIPLANARCONTRAST
               SAMPLE_PER_TEX(ptc, 5.5, config, half4(1,0.5,0,0));
               contrasts = half4(ptc0.y, ptc1.y, ptc2.y, ptc3.y);
            #endif


            #if _PERTEXTRIPLANAR
               SAMPLE_PER_TEX(pttri, 9.5, config, half4(0,0,0,0));
            #endif

            {
               // For per-texture triplanar, we modify the view based blending factor of the triplanar
               // such that you get a pure blend of either top down projection, or with the top down projection
               // removed and renormalized. This causes dynamic flow control optimizations to kick in and avoid
               // the extra texture samples while keeping the code simple. Yay..

               // We also only have to do this in the Albedo, because the pN values will be adjusted after the
               // albedo is sampled, causing future samples to use this data. 
              
               #if _PERTEXTRIPLANAR
                  if (pttri0.x > 0.66)
                  {
                     tc.pN0 = half3(0,1,0);
                  }
                  else if (pttri0.x > 0.33)
                  {
                     tc.pN0.y = 0;
                     tc.pN0.xz = normalize(tc.pN0.xz);
                  }
               #endif


               half4 a0 = half4(0,0,0,0);
               half4 a1 = half4(0,0,0,0);
               half4 a2 = half4(0,0,0,0);
               MSBRANCHTRIPLANAR(tc.pN0.x)
               {
                  a0 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv0[0], config.cluster0, d0);
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN0.y)
               {
                  a1 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv0[1], config.cluster0, d1);
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN0.z)
               {
                  a2 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv0[2], config.cluster0, d2);
                  COUNTSAMPLE
               }

               half3 bf = tc.pN0;
               #if _TRIPLANARHEIGHTBLEND
                  bf = TriplanarHBlend(a0.a, a1.a, a2.a, tc.pN0, contrasts.x);
                  tc.pN0 = bf;
               #endif

               s.albedo0 = a0 * bf.x + a1 * bf.y + a2 * bf.z;
            }
            MSBRANCH(weights.y)
            {
               #if _PERTEXTRIPLANAR
                  if (pttri1.x > 0.66)
                  {
                     tc.pN1 = half3(0,1,0);
                  }
                  else if (pttri0.x > 0.33)
                  {
                     tc.pN1.y = 0;
                     tc.pN1.xz = normalize(tc.pN1.xz);
                  }
               #endif

               half4 a0 = half4(0,0,0,0);
               half4 a1 = half4(0,0,0,0);
               half4 a2 = half4(0,0,0,0);
               MSBRANCHTRIPLANAR(tc.pN1.x)
               {
                  a0 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv1[0], config.cluster1, d0);
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN1.y)
               {
                  a1 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv1[1], config.cluster1, d1);
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN1.z)
               {
                  COUNTSAMPLE
                  a2 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv1[2], config.cluster1, d2);
               }
               half3 bf = tc.pN1;
               #if _TRIPLANARHEIGHTBLEND
                  bf = TriplanarHBlend(a0.a, a1.a, a2.a, tc.pN1, contrasts.x);
                  tc.pN1 = bf;
               #endif


               s.albedo1 = a0 * bf.x + a1 * bf.y + a2 * bf.z;
            }
            #if !_MAX2LAYER
            MSBRANCH(weights.z)
            {
               #if _PERTEXTRIPLANAR
                  if (pttri2.x > 0.66)
                  {
                     tc.pN2 = half3(0,1,0);
                  }
                  else if (pttri0.x > 0.33)
                  {
                     tc.pN2.y = 0;
                     tc.pN2.xz = normalize(tc.pN2.xz);
                  }
               #endif

               half4 a0 = half4(0,0,0,0);
               half4 a1 = half4(0,0,0,0);
               half4 a2 = half4(0,0,0,0);
               MSBRANCHTRIPLANAR(tc.pN2.x)
               {
                  a0 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv2[0], config.cluster2, d0);
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN2.y)
               {
                  a1 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv2[1], config.cluster2, d1);
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN2.z)
               {
                  a2 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv2[2], config.cluster2, d2);
                  COUNTSAMPLE
               }

               half3 bf = tc.pN2;
               #if _TRIPLANARHEIGHTBLEND
                  bf = TriplanarHBlend(a0.a, a1.a, a2.a, tc.pN2, contrasts.x);
                  tc.pN2 = bf;
               #endif
               

               s.albedo2 = a0 * bf.x + a1 * bf.y + a2 * bf.z;
            }
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
            MSBRANCH(weights.w)
            {

               #if _PERTEXTRIPLANAR
                  if (pttri3.x > 0.66)
                  {
                     tc.pN3 = half3(0,1,0);
                  }
                  else if (pttri0.x > 0.33)
                  {
                     tc.pN3.y = 0;
                     tc.pN3.xz = normalize(tc.pN3.xz);
                  }
               #endif

               half4 a0 = half4(0,0,0,0);
               half4 a1 = half4(0,0,0,0);
               half4 a2 = half4(0,0,0,0);
               MSBRANCHTRIPLANAR(tc.pN3.x)
               {
                  a0 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv3[0], config.cluster3, d0);
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN3.y)
               {
                  a1 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv3[1], config.cluster3, d1);
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN3.z)
               {
                  a2 = MICROSPLAT_SAMPLE_DIFFUSE(tc.uv3[2], config.cluster3, d2);
                  COUNTSAMPLE
               }

               half3 bf = tc.pN3;
               #if _TRIPLANARHEIGHTBLEND
               bf = TriplanarHBlend(a0.a, a1.a, a2.a, tc.pN3, contrasts.x);
               tc.pN3 = bf;
               #endif

               s.albedo3 = a0 * bf.x + a1 * bf.y + a2 * bf.z;
            }
            #endif

         #else
            s.albedo0 = MICROSPLAT_SAMPLE_DIFFUSE(config.uv0, config.cluster0, mipLevel);
            COUNTSAMPLE

            MSBRANCH(weights.y)
            {
               s.albedo1 = MICROSPLAT_SAMPLE_DIFFUSE(config.uv1, config.cluster1, mipLevel);
               COUNTSAMPLE
            }
            #if !_MAX2LAYER
               MSBRANCH(weights.z)
               {
                  s.albedo2 = MICROSPLAT_SAMPLE_DIFFUSE(config.uv2, config.cluster2, mipLevel);
                  COUNTSAMPLE
               } 
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               MSBRANCH(weights.w)
               {
                  s.albedo3 = MICROSPLAT_SAMPLE_DIFFUSE(config.uv3, config.cluster3, mipLevel);
                  COUNTSAMPLE
               }
            #endif
         #endif

         #if _PERTEXHEIGHTOFFSET || _PERTEXHEIGHTCONTRAST
            SAMPLE_PER_TEX(ptHeight, 10.5, config, 1);

            #if _PERTEXHEIGHTOFFSET
               s.albedo0.a = saturate(s.albedo0.a + ptHeight0.b - 1);
               s.albedo1.a = saturate(s.albedo1.a + ptHeight1.b - 1);
               s.albedo2.a = saturate(s.albedo2.a + ptHeight2.b - 1);
               s.albedo3.a = saturate(s.albedo3.a + ptHeight3.b - 1);
            #endif
            #if _PERTEXHEIGHTCONTRAST
               s.albedo0.a = saturate(pow(s.albedo0.a + 0.5, abs(ptHeight0.a)) - 0.5);
               s.albedo1.a = saturate(pow(s.albedo1.a + 0.5, abs(ptHeight1.a)) - 0.5);
               s.albedo2.a = saturate(pow(s.albedo2.a + 0.5, abs(ptHeight2.a)) - 0.5);
               s.albedo3.a = saturate(pow(s.albedo3.a + 0.5, abs(ptHeight3.a)) - 0.5);
            #endif
         #endif
      }
      
      
      
      void SampleNormal(Config config, TriplanarConfig tc, inout RawSamples s, MIPFORMAT mipLevel, half4 weights)
      {
         #if _DISABLESPLATMAPS
         return;
         #endif

         #if _NONOMALMAP
            s.normSAO0 = half4(0,0, 0, 1);
            s.normSAO1 = half4(0,0, 0, 1);
            s.normSAO2 = half4(0,0, 0, 1);
            s.normSAO3 = half4(0,0, 0, 1);
            return;
         #endif
         
         #if _TRIPLANAR
            #if _USEGRADMIP
               float4 d0 = mipLevel.d0;
               float4 d1 = mipLevel.d1;
               float4 d2 = mipLevel.d2;
            #elif _USELODMIP
               float d0 = mipLevel.x;
               float d1 = mipLevel.y;
               float d2 = mipLevel.z;
            #else
               MIPFORMAT d0 = mipLevel;
               MIPFORMAT d1 = mipLevel;
               MIPFORMAT d2 = mipLevel;
            #endif
            
            half3 absVertNormal = abs(tc.IN.worldNormal);
            float3 t2w0 = WorldNormalVector(tc.IN, float3(1,0,0));
            float3 t2w1 = WorldNormalVector(tc.IN, float3(0,1,0));
            float3 t2w2 = WorldNormalVector(tc.IN, float3(0,0,1));
            float3x3 t2w = float3x3(t2w0, t2w1, t2w2);
            
            
            {
               half4 a0 = half4(0.5, 0.5, 0, 1);
               half4 a1 = half4(0.5, 0.5, 0, 1);
               half4 a2 = half4(0.5, 0.5, 0, 1);
               MSBRANCHTRIPLANAR(tc.pN0.x)
               {
                  a0 = MICROSPLAT_SAMPLE_NORMAL(tc.uv0[0], config.cluster0, d0).garb;
                  COUNTSAMPLE
               }            
               MSBRANCHTRIPLANAR(tc.pN0.y)
               {
                  a1 = MICROSPLAT_SAMPLE_NORMAL(tc.uv0[1], config.cluster0, d1).garb;
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN0.z)
               {
                  a2 = MICROSPLAT_SAMPLE_NORMAL(tc.uv0[2], config.cluster0, d2).garb;
                  COUNTSAMPLE
               }
               

               s.normSAO0.xy = TransformTriplanarNormal(tc.IN, t2w, tc.axisSign, absVertNormal, tc.pN0, a0.xy, a1.xy, a2.xy);
               s.normSAO0.zw = a0.zw * tc.pN0.x + a1.zw * tc.pN0.y + a2.zw * tc.pN0.z;
            }
            MSBRANCH(weights.y)
            {
               half4 a0 = half4(0.5, 0.5, 0, 1);
               half4 a1 = half4(0.5, 0.5, 0, 1);
               half4 a2 = half4(0.5, 0.5, 0, 1);
               MSBRANCHTRIPLANAR(tc.pN1.x)
               {
                  a0 = MICROSPLAT_SAMPLE_NORMAL(tc.uv1[0], config.cluster1, d0).garb;
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN1.y)
               {
                  a1 = MICROSPLAT_SAMPLE_NORMAL(tc.uv1[1], config.cluster1, d1).garb;
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN1.z)
               {
                  a2 = MICROSPLAT_SAMPLE_NORMAL(tc.uv1[2], config.cluster1, d2).garb;
                  COUNTSAMPLE
               }
               

               s.normSAO1.xy = TransformTriplanarNormal(tc.IN, t2w, tc.axisSign, absVertNormal, tc.pN1, a0.xy, a1.xy, a2.xy);
               s.normSAO1.zw = a0.zw * tc.pN1.x + a1.zw * tc.pN1.y + a2.zw * tc.pN1.z;
            }
            #if !_MAX2LAYER
            MSBRANCH(weights.z)
            {
               half4 a0 = half4(0.5, 0.5, 0, 1);
               half4 a1 = half4(0.5, 0.5, 0, 1);
               half4 a2 = half4(0.5, 0.5, 0, 1);

               MSBRANCHTRIPLANAR(tc.pN2.x)
               {
                  a0 = MICROSPLAT_SAMPLE_NORMAL(tc.uv2[0], config.cluster2, d0).garb;
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN2.y)
               {
                  a1 = MICROSPLAT_SAMPLE_NORMAL(tc.uv2[1], config.cluster2, d1).garb;
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN2.z)
               {
                  a2 = MICROSPLAT_SAMPLE_NORMAL(tc.uv2[2], config.cluster2, d2).garb;
                  COUNTSAMPLE
               }
               

               s.normSAO2.xy = TransformTriplanarNormal(tc.IN, t2w, tc.axisSign, absVertNormal, tc.pN2, a0.xy, a1.xy, a2.xy);
               s.normSAO2.zw = a0.zw * tc.pN2.x + a1.zw * tc.pN2.y + a2.zw * tc.pN2.z;
            }
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
            MSBRANCH(weights.w)
            {
               half4 a0 = half4(0.5, 0.5, 0, 1);
               half4 a1 = half4(0.5, 0.5, 0, 1);
               half4 a2 = half4(0.5, 0.5, 0, 1);
               MSBRANCHTRIPLANAR(tc.pN3.x)
               {
                  a0 = MICROSPLAT_SAMPLE_NORMAL(tc.uv3[0], config.cluster3, d0).garb;
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN3.y)
               {
                  a1 = MICROSPLAT_SAMPLE_NORMAL(tc.uv3[1], config.cluster3, d1).garb;
                  COUNTSAMPLE
               }
               MSBRANCHTRIPLANAR(tc.pN3.z)
               {
                  a2 = MICROSPLAT_SAMPLE_NORMAL(tc.uv3[2], config.cluster3, d2).garb;
                  COUNTSAMPLE
               }

               s.normSAO3.xy = TransformTriplanarNormal(tc.IN, t2w, tc.axisSign, absVertNormal, tc.pN3, a0.xy, a1.xy, a2.xy);
               s.normSAO3.zw = a0.zw * tc.pN3.x + a1.zw * tc.pN3.y + a2.zw * tc.pN3.z;
            }
            #endif

         #else
            s.normSAO0 = MICROSPLAT_SAMPLE_NORMAL(config.uv0, config.cluster0, mipLevel).garb;
            COUNTSAMPLE
            s.normSAO0.xy = s.normSAO0.xy * 2 - 1;
            MSBRANCH(weights.y)
            {
               s.normSAO1 = MICROSPLAT_SAMPLE_NORMAL(config.uv1, config.cluster1, mipLevel).garb;
               COUNTSAMPLE
               s.normSAO1.xy = s.normSAO1.xy * 2 - 1;
            }
            #if !_MAX2LAYER
            MSBRANCH(weights.z)
            {
               s.normSAO2 = MICROSPLAT_SAMPLE_NORMAL(config.uv2, config.cluster2, mipLevel).garb;
               COUNTSAMPLE
               s.normSAO2.xy = s.normSAO2.xy * 2 - 1;
            }
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
            MSBRANCH(weights.w)
            {
               s.normSAO3 = MICROSPLAT_SAMPLE_NORMAL(config.uv3, config.cluster3, mipLevel).garb;
               COUNTSAMPLE
               s.normSAO3.xy = s.normSAO3.xy * 2 - 1;
            }
            #endif
         #endif
      }

      void SampleEmis(Config config, TriplanarConfig tc, inout RawSamples s, MIPFORMAT mipLevel, half4 weights)
      {
         #if _DISABLESPLATMAPS
            return;
         #endif
         #if _USEEMISSIVEMETAL
            #if _TRIPLANAR
            
               #if _USEGRADMIP
                  float4 d0 = mipLevel.d0;
                  float4 d1 = mipLevel.d1;
                  float4 d2 = mipLevel.d2;
               #elif _USELODMIP
                  float d0 = mipLevel.x;
                  float d1 = mipLevel.y;
                  float d2 = mipLevel.z;
               #else
                  MIPFORMAT d0 = mipLevel;
                  MIPFORMAT d1 = mipLevel;
                  MIPFORMAT d2 = mipLevel;
               #endif
               {
                  half4 a0 = half4(0, 0, 0, 0);
                  half4 a1 = half4(0, 0, 0, 0);
                  half4 a2 = half4(0, 0, 0, 0);
                  MSBRANCHTRIPLANAR(tc.pN0.x)
                  {
                     a0 = MICROSPLAT_SAMPLE_EMIS(tc.uv0[0], config.cluster0, d0);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.y)
                  {
                     a1 = MICROSPLAT_SAMPLE_EMIS(tc.uv0[1], config.cluster0, d1);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.z)
                  {
                     a2 = MICROSPLAT_SAMPLE_EMIS(tc.uv0[2], config.cluster0, d2);
                     COUNTSAMPLE
                  }
                  s.emisMetal0 = a0 * tc.pN0.x + a1 * tc.pN0.y + a2 * tc.pN0.z;
               }
               MSBRANCH(weights.y)
               {
                  half4 a0 = half4(0, 0, 0, 0);
                  half4 a1 = half4(0, 0, 0, 0);
                  half4 a2 = half4(0, 0, 0, 0);
                  MSBRANCHTRIPLANAR(tc.pN1.x)
                  {
                     a0 = MICROSPLAT_SAMPLE_EMIS(tc.uv1[0], config.cluster1, d0);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN1.y)
                  {
                     a1 = MICROSPLAT_SAMPLE_EMIS(tc.uv1[1], config.cluster1, d1);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN1.z)
                  {
                     a2 = MICROSPLAT_SAMPLE_EMIS(tc.uv1[2], config.cluster1, d2);
                     COUNTSAMPLE
                  }

                  s.emisMetal1 = a0 * tc.pN1.x + a1 * tc.pN1.y + a2 * tc.pN1.z;
               }
               #if !_MAX2LAYER
               MSBRANCH(weights.z)
               {
                  half4 a0 = half4(0, 0, 0, 0);
                  half4 a1 = half4(0, 0, 0, 0);
                  half4 a2 = half4(0, 0, 0, 0);
                  MSBRANCHTRIPLANAR(tc.pN2.x)
                  {
                     a0 = MICROSPLAT_SAMPLE_EMIS(tc.uv2[0], config.cluster2, d0);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN2.y)
                  {
                     a1 = MICROSPLAT_SAMPLE_EMIS(tc.uv2[1], config.cluster2, d1);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN2.z)
                  {
                     a2 = MICROSPLAT_SAMPLE_EMIS(tc.uv2[2], config.cluster2, d2);
                     COUNTSAMPLE
                  }
                  
                  s.emisMetal2 = a0 * tc.pN2.x + a1 * tc.pN2.y + a2 * tc.pN2.z;
               }
               #endif
               #if !_MAX3LAYER || !_MAX2LAYER
               MSBRANCH(weights.w)
               {
                  half4 a0 = half4(0, 0, 0, 0);
                  half4 a1 = half4(0, 0, 0, 0);
                  half4 a2 = half4(0, 0, 0, 0);
                  MSBRANCHTRIPLANAR(tc.pN3.x)
                  {
                     a0 = MICROSPLAT_SAMPLE_EMIS(tc.uv3[0], config.cluster3, d0);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN3.y)
                  {
                     a1 = MICROSPLAT_SAMPLE_EMIS(tc.uv3[1], config.cluster3, d1);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN3.z)
                  {
                     a2 = MICROSPLAT_SAMPLE_EMIS(tc.uv3[2], config.cluster3, d2);
                     COUNTSAMPLE
                  }
                  
                  s.emisMetal3 = a0 * tc.pN3.x + a1 * tc.pN3.y + a2 * tc.pN3.z;
               }
               #endif

            #else
               s.emisMetal0 = MICROSPLAT_SAMPLE_EMIS(config.uv0, config.cluster0, mipLevel);
               COUNTSAMPLE

               MSBRANCH(weights.y)
               {
                  s.emisMetal1 = MICROSPLAT_SAMPLE_EMIS(config.uv1, config.cluster1, mipLevel);
                  COUNTSAMPLE
               }
               #if !_MAX2LAYER
                  MSBRANCH(weights.z)
                  {
                     s.emisMetal2 = MICROSPLAT_SAMPLE_EMIS(config.uv2, config.cluster2, mipLevel);
                     COUNTSAMPLE
                  }
               #endif
               #if !_MAX3LAYER || !_MAX2LAYER
                  MSBRANCH(weights.w)
                  {
                     s.emisMetal3 = MICROSPLAT_SAMPLE_EMIS(config.uv3, config.cluster3, mipLevel);
                     COUNTSAMPLE
                  }
               #endif
            #endif
         #endif
      }
      
      void SampleSpecular(Config config, TriplanarConfig tc, inout RawSamples s, MIPFORMAT mipLevel, half4 weights)
      {
         #if _DISABLESPLATMAPS
            return;
         #endif
         #if _USESPECULARWORKFLOW
            #if _TRIPLANAR

               #if _USEGRADMIP
                  float4 d0 = mipLevel.d0;
                  float4 d1 = mipLevel.d1;
                  float4 d2 = mipLevel.d2;
               #elif _USELODMIP
                  float d0 = mipLevel.x;
                  float d1 = mipLevel.y;
                  float d2 = mipLevel.z;
               #else
                  MIPFORMAT d0 = mipLevel;
                  MIPFORMAT d1 = mipLevel;
                  MIPFORMAT d2 = mipLevel;
               #endif
               {
                  half4 a0 = half4(0, 0, 0, 0);
                  half4 a1 = half4(0, 0, 0, 0);
                  half4 a2 = half4(0, 0, 0, 0);
                  MSBRANCHTRIPLANAR(tc.pN0.x)
                  {
                     a0 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv0[0], config.cluster0, d0);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.y)
                  {
                     a1 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv0[1], config.cluster0, d1);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN0.z)
                  {
                     a2 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv0[2], config.cluster0, d2);
                     COUNTSAMPLE
                  }
                  
                  s.specular0 = a0 * tc.pN0.x + a1 * tc.pN0.y + a2 * tc.pN0.z;
               }
               MSBRANCH(weights.y)
               {
                  half4 a0 = half4(0, 0, 0, 0);
                  half4 a1 = half4(0, 0, 0, 0);
                  half4 a2 = half4(0, 0, 0, 0);
                  MSBRANCHTRIPLANAR(tc.pN1.x)
                  {
                     a0 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv1[0], config.cluster1, d0);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN1.y)
                  {
                     a1 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv1[1], config.cluster1, d1);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN1.z)
                  {
                     a2 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv1[2], config.cluster1, d2);
                     COUNTSAMPLE
                  }
                  
                  s.specular1 = a0 * tc.pN1.x + a1 * tc.pN1.y + a2 * tc.pN1.z;
               }
               #if !_MAX2LAYER
               MSBRANCH(weights.z)
               {
                  half4 a0 = half4(0, 0, 0, 0);
                  half4 a1 = half4(0, 0, 0, 0);
                  half4 a2 = half4(0, 0, 0, 0);
                  MSBRANCHTRIPLANAR(tc.pN2.x)
                  {
                     a0 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv2[0], config.cluster2, d0);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN2.y)
                  {
                     a1 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv2[1], config.cluster2, d1);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN2.z)
                  {
                     a2 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv2[2], config.cluster2, d2);
                     COUNTSAMPLE
                  }
                  
                  s.specular2 = a0 * tc.pN2.x + a1 * tc.pN2.y + a2 * tc.pN2.z;
               }
               #endif
               #if !_MAX3LAYER || !_MAX2LAYER
               MSBRANCH(weights.w)
               {
                  half4 a0 = half4(0, 0, 0, 0);
                  half4 a1 = half4(0, 0, 0, 0);
                  half4 a2 = half4(0, 0, 0, 0);
                  MSBRANCHTRIPLANAR(tc.pN3.x)
                  {
                     a0 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv3[0], config.cluster3, d0);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN3.y)
                  {
                     a1 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv3[1], config.cluster3, d1);
                     COUNTSAMPLE
                  }
                  MSBRANCHTRIPLANAR(tc.pN3.z)
                  {
                     a2 = MICROSPLAT_SAMPLE_SPECULAR(tc.uv3[2], config.cluster3, d2);
                     COUNTSAMPLE
                  }
                  
                  s.specular3 = a0 * tc.pN3.x + a1 * tc.pN3.y + a2 * tc.pN3.z;
               }
               #endif

            #else
               s.specular0 = MICROSPLAT_SAMPLE_SPECULAR(config.uv0, config.cluster0, mipLevel);
               COUNTSAMPLE

               MSBRANCH(weights.y)
               {
                  s.specular1 = MICROSPLAT_SAMPLE_SPECULAR(config.uv1, config.cluster1, mipLevel);
                  COUNTSAMPLE
               }
               #if !_MAX2LAYER
               MSBRANCH(weights.z)
               {
                  s.specular2 = MICROSPLAT_SAMPLE_SPECULAR(config.uv2, config.cluster2, mipLevel);
                  COUNTSAMPLE
               }
               #endif
               #if !_MAX3LAYER || !_MAX2LAYER
               MSBRANCH(weights.w)
               {
                  s.specular3 = MICROSPLAT_SAMPLE_SPECULAR(config.uv3, config.cluster3, mipLevel);
                  COUNTSAMPLE
               }
               #endif
            #endif
         #endif
      }

      MicroSplatLayer Sample(Input i, half4 weights, inout Config config, float camDist, float3 worldNormalVertex)
      {
         MicroSplatLayer o = (MicroSplatLayer)0;
         UNITY_INITIALIZE_OUTPUT(MicroSplatLayer,o);

         RawSamples samples = (RawSamples)0;
         InitRawSamples(samples);

         half4 albedo = 0;
         half4 normSAO = half4(0,0,0,1);
         half4 emisMetal = 0;
         half3 specular = 0;
         
         float worldHeight = i.worldPos.y;
         float3 upVector = float3(0,1,0);

         #if _PLANETVECTORS
            upVector = worldNormalVertex;
            worldHeight = distance(i.worldPos, float3(0,0,0));
         #endif

         #if _GLOBALTINT || _GLOBALNORMALS || _GLOBALSMOOTHAOMETAL || _GLOBALEMIS || _GLOBALSPECULAR
            float globalSlopeFilter = 1;
            #if _GLOBALSLOPEFILTER
               float2 gfilterUV = float2(1 - saturate(dot(worldNormalVertex, upVector) * 0.5 + 0.49), 0.5);
               globalSlopeFilter = UNITY_SAMPLE_TEX2D_SAMPLER(_GlobalSlopeTex, _Diffuse, gfilterUV).a;
            #endif
         #endif

         // declare outside of branchy areas..
         half4 fxLevels = half4(0,0,0,0);
         half burnLevel = 0;
         half wetLevel = 0;
         half3 waterNormalFoam = half3(0, 0, 0);
         half porosity = 0.4;
         float streamFoam = 1.0f;
         half pud = 0;
         half snowCover = 0;
         half SSSThickness = 0;
         half3 SSSTint = half3(1,1,1);
         float traxBuffer = 0;
         float3 traxNormal = 0;
         float2 noiseUV = 0;
         
         

         #if _SPLATFADE
         MSBRANCHOTHER(1 - saturate(camDist - _SplatFade.y))
         {
         #endif

         #if _TRAXSINGLE || _TRAXARRAY || _TRAXNOTEXTURE || _SNOWFOOTSTEPS
            traxBuffer = SampleTraxBuffer(i.worldPos, traxNormal);
         #endif
         
         #if _WETNESS || _PUDDLES || _STREAMS || _LAVA
            #if _MICROMESH
               fxLevels = SampleFXLevels(InverseLerp(_UVMeshRange.xy, _UVMeshRange.zw, config.uv), wetLevel, burnLevel, traxBuffer);
            #elif _MICROVERTEXMESH || _MICRODIGGERMESH 
               fxLevels = ProcessFXLevels(i.s0, traxBuffer);
            #else
               fxLevels = SampleFXLevels(config.uv, wetLevel, burnLevel, traxBuffer);
            #endif
         #endif

         TriplanarConfig tc = (TriplanarConfig)0;
         UNITY_INITIALIZE_OUTPUT(TriplanarConfig,tc);
         

         MIPFORMAT albedoLOD = INITMIPFORMAT
         MIPFORMAT normalLOD = INITMIPFORMAT
         MIPFORMAT emisLOD = INITMIPFORMAT
         MIPFORMAT specLOD = INITMIPFORMAT

         #if _TRIPLANAR && !_DISABLESPLATMAPS
            PrepTriplanar(worldNormalVertex, i.worldPos, config, tc, weights, albedoLOD, normalLOD, emisLOD);
            tc.IN = i;
         #endif
         
         
         #if !_TRIPLANAR && !_DISABLESPLATMAPS
            #if _USELODMIP
               albedoLOD = ComputeMipLevel(config.uv0.xy, _Diffuse_TexelSize.zw);
               normalLOD = ComputeMipLevel(config.uv0.xy, _NormalSAO_TexelSize.zw);
               #if _USEEMISSIVEMETAL
                  emisLOD   = ComputeMipLevel(config.uv0.xy, _EmissiveMetal_TexelSize.zw);
               #endif
               #if _USESPECULARWORKFLOW
                  specLOD = ComputeMipLevel(config.uv0.xy, _Specular_TexelSize.zw);;
               #endif
            #elif _USEGRADMIP
               albedoLOD = float4(ddx(config.uv0.xy), ddy(config.uv0.xy));
               normalLOD = albedoLOD;
               #if _USESPECULARWORKFLOW
                  specLOD = albedoLOD;
               #endif
               #if _USEEMISSIVEMETAL
                  emisLOD = albedoLOD;
               #endif
            #endif
         #endif

         #if _PERTEXCURVEWEIGHT
           SAMPLE_PER_TEX(ptCurveWeight, 19.5, config, half4(0.5,1,1,1));
           weights.x = lerp(smoothstep(0.5 - ptCurveWeight0.r, 0.5 + ptCurveWeight0.r, weights.x), weights.x, ptCurveWeight0.r*2);
           weights.y = lerp(smoothstep(0.5 - ptCurveWeight1.r, 0.5 + ptCurveWeight1.r, weights.y), weights.y, ptCurveWeight1.r*2);
           weights.z = lerp(smoothstep(0.5 - ptCurveWeight2.r, 0.5 + ptCurveWeight2.r, weights.z), weights.z, ptCurveWeight2.r*2);
           weights.w = lerp(smoothstep(0.5 - ptCurveWeight3.r, 0.5 + ptCurveWeight3.r, weights.w), weights.w, ptCurveWeight3.r*2);
           weights = normalize(weights);
         #endif
         

         // uvScale before anything
         #if _PERTEXUVSCALEOFFSET && !_TRIPLANAR && !_DISABLESPLATMAPS
            SAMPLE_PER_TEX(ptUVScale, 0.5, config, half4(1,1,0,0));
            config.uv0.xy = config.uv0.xy * ptUVScale0.rg + ptUVScale0.ba;
            config.uv1.xy = config.uv1.xy * ptUVScale1.rg + ptUVScale1.ba;
            #if !_MAX2LAYER
               config.uv2.xy = config.uv2.xy * ptUVScale2.rg + ptUVScale2.ba;
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               config.uv3.xy = config.uv3.xy * ptUVScale3.rg + ptUVScale3.ba;
            #endif

            // fix for pertex uv scale using gradient sampler and weight blended derivatives
            #if _USEGRADMIP
               albedoLOD = albedoLOD * ptUVScale0.rgrg * weights.x + 
                           albedoLOD * ptUVScale1.rgrg * weights.y + 
                           albedoLOD * ptUVScale2.rgrg * weights.z + 
                           albedoLOD * ptUVScale3.rgrg * weights.w;
               normalLOD = albedoLOD;
               #if _USEEMISSIVEMETAL
                  emisLOD = albedoLOD;
               #endif
               #if _USESPECULARWORKFLOW
                  specLOD = albedoLOD;
               #endif
            #endif
         #endif

         #if _PERTEXUVROTATION && !_TRIPLANAR && !_DISABLESPLATMAPS
            SAMPLE_PER_TEX(ptUVRot, 16.5, config, half4(0,0,0,0));
            config.uv0.xy = RotateUV(config.uv0.xy, ptUVRot0.x);
            config.uv1.xy = RotateUV(config.uv1.xy, ptUVRot1.x);
            #if !_MAX2LAYER
               config.uv2.xy = RotateUV(config.uv2.xy, ptUVRot2.x);
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               config.uv3.xy = RotateUV(config.uv3.xy, ptUVRot0.x);
            #endif
         #endif

         
         o.Alpha = 1;

         
         #if _POM && !_DISABLESPLATMAPS
            DoPOM(i, config, tc, albedoLOD, weights, camDist, worldNormalVertex);
         #endif
         

         SampleAlbedo(config, tc, samples, albedoLOD, weights);

         #if _NOISEHEIGHT
            ApplyNoiseHeight(samples, config.uv, config, i.worldPos, worldNormalVertex);
         #endif
         
         #if _STREAMS || (_PARALLAX && !_DISABLESPLATMAPS)
         half earlyHeight = BlendWeights(samples.albedo0.w, samples.albedo1.w, samples.albedo2.w, samples.albedo3.w, weights);
         #endif

         
         #if _STREAMS
         waterNormalFoam = GetWaterNormal(i, config.uv, worldNormalVertex);
         DoStreamRefract(config, tc, waterNormalFoam, fxLevels.b, earlyHeight);
         #endif

         #if _PARALLAX && !_DISABLESPLATMAPS
            DoParallax(i, earlyHeight, config, tc, samples, weights, camDist);
         #endif


         // Blend results
         #if _PERTEXINTERPCONTRAST && !_DISABLESPLATMAPS
            SAMPLE_PER_TEX(ptContrasts, 1.5, config, 0.5);
            half4 contrast = 0.5;
            contrast.x = ptContrasts0.a;
            contrast.y = ptContrasts1.a;
            #if !_MAX2LAYER
               contrast.z = ptContrasts2.a;
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               contrast.w = ptContrasts3.a;
            #endif
            contrast = clamp(contrast + _Contrast, 0.0001, 1.0); 
            half cnt = contrast.x * weights.x + contrast.y * weights.y + contrast.z * weights.z + contrast.w * weights.w;
            half4 heightWeights = ComputeWeights(weights, samples.albedo0.a, samples.albedo1.a, samples.albedo2.a, samples.albedo3.a, cnt);
         #else
            half4 heightWeights = ComputeWeights(weights, samples.albedo0.a, samples.albedo1.a, samples.albedo2.a, samples.albedo3.a, _Contrast);
         #endif


         #if _PARALLAX || _STREAMS
            SampleAlbedo(config, tc, samples, albedoLOD, heightWeights);
         #endif


         SampleNormal(config, tc, samples, normalLOD, heightWeights);

         #if _USEEMISSIVEMETAL
            SampleEmis(config, tc, samples, emisLOD, heightWeights);
         #endif

         #if _USESPECULARWORKFLOW
            SampleSpecular(config, tc, samples, specLOD, heightWeights);
         #endif

         #if _DISTANCERESAMPLE && !_DISABLESPLATMAPS
            DistanceResample(samples, config, tc, camDist, i.viewDir, fxLevels, albedoLOD, i.worldPos, heightWeights, worldNormalVertex);
         #endif

         // PerTexture sampling goes here, passing the samples structure
         
         #if _PERTEXMICROSHADOWS || _PERTEXFUZZYSHADE
            SAMPLE_PER_TEX(ptFuzz, 17.5, config, half4(0, 0, 1, 1));
         #endif

         #if _PERTEXMICROSHADOWS
            #if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_DEFERRED) || (defined(_MSRENDERLOOP_UNITYLD) && defined(_PASSFORWARD) || _MSRENDERLOOP_UNITYHD)
            {
               half3 lightDir = GetGlobalLightDirTS(i);
               half4 microShadows = half4(1,1,1,1);
               microShadows.x = MicroShadow(lightDir, half3(samples.normSAO0.xy, 1), samples.normSAO0.a, ptFuzz0.a);
               microShadows.y = MicroShadow(lightDir, half3(samples.normSAO1.xy, 1), samples.normSAO1.a, ptFuzz1.a);
               microShadows.z = MicroShadow(lightDir, half3(samples.normSAO2.xy, 1), samples.normSAO2.a, ptFuzz2.a);
               microShadows.w = MicroShadow(lightDir, half3(samples.normSAO3.xy, 1), samples.normSAO3.a, ptFuzz3.a);
               samples.normSAO0.a *= microShadows.x;
               samples.normSAO1.a *= microShadows.y;
               #if !_MAX2LAYER
                  samples.normSAO2.a *= microShadows.z;
               #endif
               #if !_MAX3LAYER || !_MAX2LAYER
                  samples.normSAO3.a *= microShadows.w;
               #endif

               
               #if _DEBUG_OUTPUT_MICROSHADOWS
               o.Albedo = BlendWeights(microShadows.x, microShadows.y, microShadows.z, microShadows.a, heightWeights);
               return o;
               #endif

            }
            #endif

         #endif // _PERTEXMICROSHADOWS


         #if _PERTEXFUZZYSHADE
            
            samples.albedo0.rgb = FuzzyShade(samples.albedo0.rgb, half3(samples.normSAO0.rg, 1), ptFuzz0.r, ptFuzz0.g, ptFuzz0.b, i.viewDir);
            samples.albedo1.rgb = FuzzyShade(samples.albedo1.rgb, half3(samples.normSAO1.rg, 1), ptFuzz1.r, ptFuzz1.g, ptFuzz1.b, i.viewDir);
            #if !_MAX2LAYER
               samples.albedo2.rgb = FuzzyShade(samples.albedo2.rgb, half3(samples.normSAO2.rg, 1), ptFuzz2.r, ptFuzz2.g, ptFuzz2.b, i.viewDir);
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               samples.albedo3.rgb = FuzzyShade(samples.albedo3.rgb, half3(samples.normSAO3.rg, 1), ptFuzz3.r, ptFuzz3.g, ptFuzz3.b, i.viewDir);
            #endif
         #endif

         #if _PERTEXSATURATION && !_DISABLESPLATMAPS
            SAMPLE_PER_TEX(ptSaturattion, 9.5, config, half4(1, 1, 1, 1));
            samples.albedo0.rgb = lerp(MSLuminance(samples.albedo0.rgb), samples.albedo0.rgb, ptSaturattion0.a);
            samples.albedo1.rgb = lerp(MSLuminance(samples.albedo1.rgb), samples.albedo1.rgb, ptSaturattion1.a);
            #if !_MAX2LAYER
               samples.albedo2.rgb = lerp(MSLuminance(samples.albedo2.rgb), samples.albedo2.rgb, ptSaturattion2.a);
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               samples.albedo3.rgb = lerp(MSLuminance(samples.albedo3.rgb), samples.albedo3.rgb, ptSaturattion3.a);
            #endif
         
         #endif
         
         #if _PERTEXTINT && !_DISABLESPLATMAPS
            SAMPLE_PER_TEX(ptTints, 1.5, config, half4(1, 1, 1, 1));
            samples.albedo0.rgb *= ptTints0.rgb;
            samples.albedo1.rgb *= ptTints1.rgb;
            #if !_MAX2LAYER
               samples.albedo2.rgb *= ptTints2.rgb;
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               samples.albedo3.rgb *= ptTints3.rgb;
            #endif
         #endif
         
         #if _PCHEIGHTGRADIENT || _PCHEIGHTHSV || _PCSLOPEGRADIENT || _PCSLOPEHSV
            ProceduralGradients(i, samples, config, worldHeight, worldNormalVertex);
         #endif

         
         

         #if _WETNESS || _PUDDLES || _STREAMS
         porosity = _GlobalPorosity;
         #endif


         #if _PERTEXCOLORINTENSITY
            SAMPLE_PER_TEX(ptCI, 23.5, config, half4(1, 1, 1, 1));
            samples.albedo0.rgb = saturate(samples.albedo0.rgb * (1 + ptCI0.rrr));
            samples.albedo1.rgb = saturate(samples.albedo1.rgb * (1 + ptCI1.rrr));
            #if !_MAX2LAYER
               samples.albedo2.rgb = saturate(samples.albedo2.rgb * (1 + ptCI2.rrr));
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               samples.albedo3.rgb = saturate(samples.albedo3.rgb * (1 + ptCI3.rrr));
            #endif
         #endif

         #if (_PERTEXBRIGHTNESS || _PERTEXCONTRAST || _PERTEXPOROSITY || _PERTEXFOAM) && !_DISABLESPLATMAPS
            SAMPLE_PER_TEX(ptBC, 3.5, config, half4(1, 1, 1, 1));
            #if _PERTEXCONTRAST
               samples.albedo0.rgb = saturate(((samples.albedo0.rgb - 0.5) * ptBC0.g) + 0.5);
               samples.albedo1.rgb = saturate(((samples.albedo1.rgb - 0.5) * ptBC1.g) + 0.5);
               #if !_MAX2LAYER
                 samples.albedo2.rgb = saturate(((samples.albedo2.rgb - 0.5) * ptBC2.g) + 0.5);
               #endif
               #if !_MAX3LAYER || !_MAX2LAYER
                  samples.albedo3.rgb = saturate(((samples.albedo3.rgb - 0.5) * ptBC3.g) + 0.5);
               #endif
            #endif
            #if _PERTEXBRIGHTNESS
               samples.albedo0.rgb = saturate(samples.albedo0.rgb + ptBC0.rrr);
               samples.albedo1.rgb = saturate(samples.albedo1.rgb + ptBC1.rrr);
               #if !_MAX2LAYER
                  samples.albedo2.rgb = saturate(samples.albedo2.rgb + ptBC2.rrr);
               #endif
               #if !_MAX3LAYER || !_MAX2LAYER
                  samples.albedo3.rgb = saturate(samples.albedo3.rgb + ptBC3.rrr);
               #endif
            #endif
            #if _PERTEXPOROSITY
            porosity = BlendWeights(ptBC0.b, ptBC1.b, ptBC2.b, ptBC3.b, heightWeights);
            #endif

            #if _PERTEXFOAM
            streamFoam = BlendWeights(ptBC0.a, ptBC1.a, ptBC2.a, ptBC3.a, heightWeights);
            #endif

         #endif

         #if (_PERTEXNORMSTR || _PERTEXAOSTR || _PERTEXSMOOTHSTR || _PERTEXMETALLIC) && !_DISABLESPLATMAPS
            SAMPLE_PER_TEX(perTexMatSettings, 2.5, config, half4(1.0, 1.0, 1.0, 0.0));
         #endif

         #if _PERTEXNORMSTR && !_DISABLESPLATMAPS
            samples.normSAO0.xy *= perTexMatSettings0.r;
            samples.normSAO1.xy *= perTexMatSettings1.r;
            #if !_MAX2LAYER
               samples.normSAO2.xy *= perTexMatSettings2.r;
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               samples.normSAO3.xy *= perTexMatSettings3.r;
            #endif
         #endif

         #if _PERTEXAOSTR && !_DISABLESPLATMAPS
            samples.normSAO0.a = pow(samples.normSAO0.a, abs(perTexMatSettings0.b));
            samples.normSAO1.a = pow(samples.normSAO1.a, abs(perTexMatSettings1.b));
            #if !_MAX2LAYER
               samples.normSAO2.a = pow(samples.normSAO2.a, abs(perTexMatSettings2.b));
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               samples.normSAO3.a = pow(samples.normSAO3.a, abs(perTexMatSettings3.b));
            #endif
         #endif

         #if _PERTEXSMOOTHSTR && !_DISABLESPLATMAPS
            samples.normSAO0.b += perTexMatSettings0.g;
            samples.normSAO1.b += perTexMatSettings1.g;
            samples.normSAO0.b = saturate(samples.normSAO0.b);
            samples.normSAO1.b = saturate(samples.normSAO1.b);
            #if !_MAX2LAYER
               samples.normSAO2.b += perTexMatSettings2.g;
               samples.normSAO2.b = saturate(samples.normSAO2.b);
            #endif
            #if !_MAX3LAYER || !_MAX2LAYER
               samples.normSAO3.b += perTexMatSettings3.g;
               samples.normSAO3.b = saturate(samples.normSAO3.b);
            #endif
         #endif

         
         #if defined(UNITY_PASS_FORWARDBASE) || defined(UNITY_PASS_DEFERRED) || (defined(_MSRENDERLOOP_UNITYLD) && defined(_PASSFORWARD) || _MSRENDERLOOP_UNITYHD) 
          #if _PERTEXSSS
          {
            SAMPLE_PER_TEX(ptSSS, 18.5, config, half4(1, 1, 1, 1)); // tint, thickness
            
            half4 vals = ptSSS0 * heightWeights.x + ptSSS1 * heightWeights.y + ptSSS2 * heightWeights.z + ptSSS3 * heightWeights.w;
            SSSThickness = vals.a;
            SSSTint = vals.rgb;
          }
          #endif
         #endif

         #if (((_DETAILNOISE && _PERTEXDETAILNOISESTRENGTH) || (_DISTANCENOISE && _PERTEXDISTANCENOISESTRENGTH)) || (_NORMALNOISE && _PERTEXNORMALNOISESTRENGTH)) && !_DISABLESPLATMAPS
         ApplyDetailDistanceNoisePerTex(samples, config, camDist, i.worldPos, worldNormalVertex);
         #endif

         
         #if _GLOBALNOISEUV
            // noise defaults so that a value of 1, 1 is 4 pixels in size and moves the uvs by 1 pixel max.
            #if _CUSTOMSPLATTEXTURES
               noiseUV = (UNITY_SAMPLE_TEX2D_SAMPLER(_NoiseUV, _Diffuse, config.uv * _CustomControl0_TexelSize.zw * 0.2 * _NoiseUVParams.x).ga - 0.5) * _CustomControl0_TexelSize.xy * _NoiseUVParams.y;
            #else
               noiseUV = (UNITY_SAMPLE_TEX2D_SAMPLER(_NoiseUV, _Diffuse, config.uv * _Control0_TexelSize.zw * 0.2 * _NoiseUVParams.x).ga - 0.5) * _Control0_TexelSize.xy * _NoiseUVParams.y;
            #endif
         #endif

         
         #if _TRAXSINGLE || _TRAXARRAY || _TRAXNOTEXTURE
            ApplyTrax(samples, config, i.worldPos, traxBuffer, traxNormal);
         #endif

         #if (_ANTITILEARRAYDETAIL || _ANTITILEARRAYDISTANCE || _ANTITILEARRAYNORMAL) && !_DISABLESPLATMAPS
         ApplyAntiTilePerTex(samples, config, camDist, i.worldPos, worldNormalVertex, heightWeights);
         #endif

         #if _GEOMAP && !_DISABLESPLATMAPS
         GeoTexturePerTex(samples, i.worldPos, worldHeight, config, worldNormalVertex, upVector);
         #endif
         
         #if _GLOBALTINT && _PERTEXGLOBALTINTSTRENGTH && !_DISABLESPLATMAPS
         GlobalTintTexturePerTex(samples, config, camDist, globalSlopeFilter, noiseUV);
         #endif
         
         #if _GLOBALNORMALS && _PERTEXGLOBALNORMALSTRENGTH && !_DISABLESPLATMAPS
         GlobalNormalTexturePerTex(samples, config, camDist, globalSlopeFilter, noiseUV);
         #endif
         
         #if _GLOBALSMOOTHAOMETAL && _PERTEXGLOBALSAOMSTRENGTH && !_DISABLESPLATMAPS
         GlobalSAOMTexturePerTex(samples, config, camDist, globalSlopeFilter, noiseUV);
         #endif

         #if _GLOBALEMIS && _PERTEXGLOBALEMISSTRENGTH && !_DISABLESPLATMAPS
         GlobalEmisTexturePerTex(samples, config, camDist, globalSlopeFilter, noiseUV);
         #endif

         #if _GLOBALSPECULAR && _PERTEXGLOBALSPECULARSTRENGTH && !_DISABLESPLATMAPS && _USESPECULARWORKFLOW
         GlobalSpecularTexturePerTex(samples, config, camDist, globalSlopeFilter, noiseUV);
         #endif

         #if _PERTEXMETALLIC && !_DISABLESPLATMAPS
            half metallic = BlendWeights(perTexMatSettings0.a, perTexMatSettings1.a, perTexMatSettings2.a, perTexMatSettings3.a, heightWeights);
            o.Metallic = metallic;
         #endif

         #if _GLITTER && !_DISABLESPLATMAPS
            DoGlitter(i, samples, config, camDist, worldNormalVertex, i.worldPos);
         #endif
         
         // Blend em..
         #if _DISABLESPLATMAPS
            // If we don't sample from the _Diffuse, then the shader compiler will strip the sampler on
            // some platforms, which will cause everything to break. So we sample from the lowest mip
            // and saturate to 1 to keep the cost minimal. Annoying, but the compiler removes the texture
            // and sampler, even though the sampler is still used.
            albedo = saturate(UNITY_SAMPLE_TEX2DARRAY_LOD(_Diffuse, float3(0,0,0), 12) + 1);
            albedo.a = 0.5; // make height something we can blend with for the combined mesh mode, since it still height blends.
            normSAO = half4(0,0,0,1);
         #else
            albedo = BlendWeights(samples.albedo0, samples.albedo1, samples.albedo2, samples.albedo3, heightWeights);
            normSAO = BlendWeights(samples.normSAO0, samples.normSAO1, samples.normSAO2, samples.normSAO3, heightWeights);
            #if _USEEMISSIVEMETAL && !_DISABLESPLATMAPS
               emisMetal = BlendWeights(samples.emisMetal0, samples.emisMetal1, samples.emisMetal2, samples.emisMetal3, heightWeights);
            #endif

            #if _USESPECULARWORKFLOW && !_DISABLESPLATMAPS
               specular = BlendWeights(samples.specular0, samples.specular1, samples.specular2, samples.specular3, heightWeights);
            #endif
         #endif

         
         // ADVANCEDTERRAIN_ENTRYPOINT 


         #if _MESHOVERLAYSPLATS || _MESHCOMBINED
            o.Alpha = 1.0;
            if (config.uv0.z == _MeshAlphaIndex)
               o.Alpha = 1 - heightWeights.x;
            else if (config.uv1.z == _MeshAlphaIndex)
               o.Alpha = 1 - heightWeights.y;
            else if (config.uv2.z == _MeshAlphaIndex)
               o.Alpha = 1 - heightWeights.z;
            else if (config.uv3.z == _MeshAlphaIndex)
               o.Alpha = 1 - heightWeights.w;
         #endif



         // effects which don't require per texture adjustments and are part of the splats sample go here. 
         // Often, as an optimization, you can compute the non-per tex version of above effects here..


         #if ((_DETAILNOISE && !_PERTEXDETAILNOISESTRENGTH) || (_DISTANCENOISE && !_PERTEXDISTANCENOISESTRENGTH) || (_NORMALNOISE && !_PERTEXNORMALNOISESTRENGTH))
            ApplyDetailDistanceNoise(albedo.rgb, normSAO, config, camDist, i.worldPos, worldNormalVertex);
         #endif

         #if _SPLATFADE
         }
         #endif

         #if _SPLATFADE
            // blend in uniform texture over splat fade range
            // only for planets? Fine on terrain, but may want a switch for this..
            #if _TRIPLANAR && (_PLANETNORMAL || _PLANETNORMAL2)
               

               float3 pN = pow(abs(worldNormalVertex), 0.7);
               pN = pN / (pN.x + pN.y + pN.z);
            
               half3 axisSign = sign(worldNormalVertex);

               float2 uv0 = i.worldPos.zy * axisSign.x * _TriplanarUVScale.xy;
               float2 uv1 = i.worldPos.xz * axisSign.y * _TriplanarUVScale.xy;
               float2 uv2 = i.worldPos.xy * axisSign.z * _TriplanarUVScale.xy;

               float2 sfDX = ddx(uv0);
               float2 sfDY = ddy(uv0);

               MSBRANCHOTHER(camDist - _SplatFade.x)
               {
                  float falloff = saturate(InverseLerp(_SplatFade.x, _SplatFade.y, camDist));
                  half4 sfalb0 = MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(_Diffuse, float3(uv0, _SplatFade.z), sfDX, sfDY);
                  half4 sfalb1 = MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(_Diffuse, float3(uv1, _SplatFade.z), sfDX, sfDY);
                  half4 sfalb2 = MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(_Diffuse, float3(uv2, _SplatFade.z), sfDX, sfDY);
                  COUNTSAMPLE
                  COUNTSAMPLE
                  COUNTSAMPLE
                  albedo.rgb = lerp(albedo.rgb, sfalb0.rgb * pN.x + sfalb1 * pN.y + sfalb2 * pN.z, falloff);

                  #if !_NONOMALMAP
                     half4 sfnormSAO0 = MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(_NormalSAO, float3(uv0, _SplatFade.z), sfDX, sfDY).garb;
                     half4 sfnormSAO1 = MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(_NormalSAO, float3(uv1, _SplatFade.z), sfDX, sfDY).garb;
                     half4 sfnormSAO2 = MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(_NormalSAO, float3(uv2, _SplatFade.z), sfDX, sfDY).garb;
                     COUNTSAMPLE
                     COUNTSAMPLE
                     COUNTSAMPLE
                     half4 sfnormSAO = sfnormSAO0 * pN.x + sfnormSAO1 * pN.y + sfnormSAO2 * pN.z;
                     sfnormSAO.xy = sfnormSAO.xy * 2 - 1;

                     normSAO = lerp(normSAO, sfnormSAO, falloff);
                  #endif
              
               }
            #else // _TRIPLANAR && (_PLANETNORMAL || _PLANETNORMAL2)
            float2 sfDX = ddx(config.uv * _UVScale);
            float2 sfDY = ddy(config.uv * _UVScale);

            MSBRANCHOTHER(camDist - _SplatFade.x)
            {
               float falloff = saturate(InverseLerp(_SplatFade.x, _SplatFade.y, camDist));
               half4 sfalb = MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(_Diffuse, float3(config.uv * _UVScale, _SplatFade.z), sfDX, sfDY);
               COUNTSAMPLE
               albedo.rgb = lerp(albedo.rgb, sfalb.rgb, falloff);

               #if !_NONOMALMAP
                  half4 sfnormSAO = MICROSPLAT_SAMPLE_TEX2DARRAY_GRAD(_NormalSAO, float3(config.uv * _UVScale, _SplatFade.z), sfDX, sfDY).garb;
                  COUNTSAMPLE
                  sfnormSAO.xy = sfnormSAO.xy * 2 - 1;

                  normSAO = lerp(normSAO, sfnormSAO, falloff);
               #endif
              
            }
            #endif
         #endif


         #if _MESHCOMBINED
            SampleMeshCombined(albedo, normSAO, emisMetal, specular, o.Alpha, SSSThickness, SSSTint, config, heightWeights);
         #endif
         
         #if _SCATTER
            ApplyScatter(i, albedo, normSAO, config.uv, camDist);
         #endif

         #if _GEOMAP
            GeoTexture(albedo.rgb, normSAO, i.worldPos, worldHeight, config, worldNormalVertex, upVector);
         #endif

         #if _PLANETALBEDO || _PLANETNORMAL || _PLANETALBEDO2 || _PLANETNORMAL2
            ApplyPlanet(i, albedo, normSAO, config, camDist, i.worldPos, worldNormalVertex);
         #endif


         #if _GLOBALTINT && !_PERTEXGLOBALTINTSTRENGTH
            GlobalTintTexture(albedo.rgb, config, camDist, globalSlopeFilter, noiseUV);
         #endif

         #if _VSGRASSMAP
            VSGrassTexture(albedo.rgb, config, camDist);
         #endif

         #if _GLOBALNORMALS && !_PERTEXGLOBALNORMALSTRENGTH
            GlobalNormalTexture(normSAO, config, camDist, globalSlopeFilter, noiseUV);
         #endif
         
         #if _GLOBALSMOOTHAOMETAL && !_PERTEXGLOBALSAOMSTRENGTH
            GlobalSAOMTexture(normSAO, emisMetal, config, camDist, globalSlopeFilter, noiseUV);
         #endif
         
         #if _GLOBALEMIS && !_PERTEXGLOBALEMISSTRENGTH
            GlobalEmisTexture(emisMetal, config, camDist, globalSlopeFilter, noiseUV);
         #endif

         #if _GLOBALSPECULAR && !_PERTEXGLOBALSPECULARSTRENGTH && _USESPECULARWORKFLOW
            GlobalSpecularTexture(specular.rgb, config, camDist, globalSlopeFilter, noiseUV);
         #endif

        
         
         o.Albedo = albedo.rgb;
         o.Height = albedo.a;
         o.Normal = half3(normSAO.xy, 1);
         o.Smoothness = normSAO.b;
         o.Occlusion = normSAO.a;

         #if _USEEMISSIVEMETAL || _GLOBALSMOOTHAOMETAL || _GLOBALEMIS 
         o.Emission = emisMetal.rgb;
         o.Metallic = emisMetal.a;
	        #if _USEEMISSIVEMETAL
	        o.Emission *= _EmissiveMult;
	        #endif
         #endif

         #if _USESPECULARWORKFLOW
            o.Specular = specular;
         #endif


         


         #if _WETNESS || _PUDDLES || _STREAMS || _LAVA
         pud = DoStreams(i, o, fxLevels, config.uv, porosity, waterNormalFoam, worldNormalVertex, streamFoam, wetLevel, burnLevel, i.worldPos);
         #endif

         
         #if _SNOW
         snowCover = DoSnow(o, config.uv, WorldNormalVector(i, o.Normal), worldNormalVertex, i.worldPos, pud, porosity, camDist, 
            config, weights, SSSTint, SSSThickness, traxBuffer, traxNormal);
         #endif

         #if _PERTEXSSS || _MESHCOMBINEDUSESSS || (_SNOW && _SNOWSSS)
         {
            half3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

            o.Emission += ComputeSSS(i, worldView, WorldNormalVector(i, half3(normSAO.xy, 1)),
               SSSTint, SSSThickness, _SSSDistance, _SSSScale, _SSSPower);
         }
         #endif
         
         #if _SNOWGLITTER
            DoSnowGlitter(i, config, o, camDist, worldNormalVertex, snowCover);
         #endif

         #if _WINDPARTICULATE || _SNOWPARTICULATE
         DoWindParticulate(i, o, config, weights, camDist, worldNormalVertex, snowCover);
         #endif

         o.Normal.z = sqrt(1 - saturate(dot(o.Normal.xy, o.Normal.xy)));

         #if _SPECULARFADE
         {
            float specFade = saturate((i.worldPos.y - _SpecularFades.x) / max(_SpecularFades.y - _SpecularFades.x, 0.0001));
            o.Metallic *= specFade;
            o.Smoothness *= specFade;
         }
         #endif

         #if _VSSHADOWMAP
         VSShadowTexture(o, i, config, camDist);
         #endif
         
         #if _TOONWIREFRAME
         ToonWireframe(config.uv, o.Albedo);
         #endif

         #if _DEBUG_TRAXBUFFER
            ClearAllButAlbedo(o, half3(traxBuffer, 0, 0) * saturate(o.Albedo.z+1));
         #endif
         return o;
      }
      
      void SampleSplats(float2 controlUV, inout fixed4 w0, inout fixed4 w1, inout fixed4 w2, inout fixed4 w3, inout fixed4 w4, inout fixed4 w5, inout fixed4 w6, inout fixed4 w7)
      {
         #if _CUSTOMSPLATTEXTURES
            #if !_MICROMESH
            controlUV = (controlUV * (_CustomControl0_TexelSize.zw - 1.0f) + 0.5f) * _CustomControl0_TexelSize.xy;
            #endif

            #if  _CONTROLNOISEUV
               controlUV += (UNITY_SAMPLE_TEX2D_SAMPLER(_NoiseUV, _Diffuse, controlUV * _CustomControl0_TexelSize.zw * 0.2 * _NoiseUVParams.x).ga - 0.5) * _CustomControl0_TexelSize.xy * _NoiseUVParams.y;
            #endif

            w0 = UNITY_SAMPLE_TEX2D(_CustomControl0, controlUV);
            COUNTSAMPLE

            #if !_MAX4TEXTURES
            w1 = UNITY_SAMPLE_TEX2D_SAMPLER(_CustomControl1, _CustomControl0, controlUV);
            COUNTSAMPLE
            #endif

            #if !_MAX4TEXTURES && !_MAX8TEXTURES
            w2 = UNITY_SAMPLE_TEX2D_SAMPLER(_CustomControl2, _CustomControl0, controlUV);
            COUNTSAMPLE
            #endif

            #if !_MAX4TEXTURES && !_MAX8TEXTURES && !_MAX12TEXTURES
            w3 = UNITY_SAMPLE_TEX2D_SAMPLER(_CustomControl3, _CustomControl0, controlUV);
            COUNTSAMPLE
            #endif

            #if _MAX20TEXTURES || _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
            w4 = UNITY_SAMPLE_TEX2D_SAMPLER(_CustomControl4, _CustomControl0, controlUV);
            COUNTSAMPLE
            #endif

            #if _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
            w5 = UNITY_SAMPLE_TEX2D_SAMPLER(_CustomControl5, _CustomControl0, controlUV);
            COUNTSAMPLE
            #endif

            #if _MAX28TEXTURES || _MAX32TEXTURES
            w6 = UNITY_SAMPLE_TEX2D_SAMPLER(_CustomControl6, _CustomControl0, controlUV);
            COUNTSAMPLE
            #endif

            #if _MAX32TEXTURES
            w7 = UNITY_SAMPLE_TEX2D_SAMPLER(_CustomControl7, _CustomControl0, controlUV);
            COUNTSAMPLE
            #endif
         #else
            #if !_MICROMESH
            controlUV = (controlUV * (_Control0_TexelSize.zw - 1.0f) + 0.5f) * _Control0_TexelSize.xy;
            #endif

            #if  _CONTROLNOISEUV
               controlUV += (UNITY_SAMPLE_TEX2D_SAMPLER(_NoiseUV, _Diffuse, controlUV * _Control0_TexelSize.zw * 0.2 * _NoiseUVParams.x).ga - 0.5) * _Control0_TexelSize.xy * _NoiseUVParams.y;
            #endif

            w0 = UNITY_SAMPLE_TEX2D(_Control0, controlUV);
            COUNTSAMPLE

            #if !_MAX4TEXTURES
            w1 = UNITY_SAMPLE_TEX2D_SAMPLER(_Control1, _Control0, controlUV);
            COUNTSAMPLE
            #endif

            #if !_MAX4TEXTURES && !_MAX8TEXTURES
            w2 = UNITY_SAMPLE_TEX2D_SAMPLER(_Control2, _Control0, controlUV);
            COUNTSAMPLE
            #endif

            #if !_MAX4TEXTURES && !_MAX8TEXTURES && !_MAX12TEXTURES
            w3 = UNITY_SAMPLE_TEX2D_SAMPLER(_Control3, _Control0, controlUV);
            COUNTSAMPLE
            #endif

            #if _MAX20TEXTURES || _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
            w4 = UNITY_SAMPLE_TEX2D_SAMPLER(_Control4, _Control0, controlUV);
            COUNTSAMPLE
            #endif

            #if _MAX24TEXTURES || _MAX28TEXTURES || _MAX32TEXTURES
            w5 = UNITY_SAMPLE_TEX2D_SAMPLER(_Control5, _Control0, controlUV);
            COUNTSAMPLE
            #endif

            #if _MAX28TEXTURES || _MAX32TEXTURES
            w6 = UNITY_SAMPLE_TEX2D_SAMPLER(_Control6, _Control0, controlUV);
            COUNTSAMPLE
            #endif

            #if _MAX32TEXTURES
            w7 = UNITY_SAMPLE_TEX2D_SAMPLER(_Control7, _Control0, controlUV);
            COUNTSAMPLE
            #endif
         #endif
      }   


      

      MicroSplatLayer SurfImpl(Input i, float3 worldNormalVertex)
      {
         // with DrawInstanced on, view dir is incorrect, so we compute it here. Thanks Obama..
         #if !_DEBUG_USE_TOPOLOGY && UNITY_VERSION >= 201830 && !_TERRAINBLENDABLESHADER && !_MICROMESH && !_MICROMESHTERRAIN && !_MICROPOLARISMESH &&!_MICRODIGGERMESH && !_MICROVERTEXMESH && defined(UNITY_INSTANCING_ENABLED) && !defined(SHADER_API_D3D11_9X)
            #if !_MSRENDERLOOP_SURFACESHADER
               i.viewDir = normalize( mul(i.TBN, (_WorldSpaceCameraPos - i.worldPos)) );
            #else
               float3 t2w0 = WorldNormalVector(i, float3(1,0,0));
               float3 t2w1 = WorldNormalVector(i, float3(0,1,0));
               float3 t2w2 = WorldNormalVector(i, float3(0,0,1));
               float3x3 t2w = float3x3(t2w0, t2w1, t2w2);
               i.viewDir = normalize(mul( t2w, (_WorldSpaceCameraPos - i.worldPos)));
            #endif
         #endif


         #if _TERRAINBLENDABLESHADER && _TRIPLANAR
            worldNormalVertex = WorldNormalVector(i, float3(0,0,1));
         #endif
         
         float camDist = distance(_WorldSpaceCameraPos, i.worldPos);
          
         #if _FORCELOCALSPACE
            #if _PLANETVECTORS
                worldNormalVertex = mul(_PQSToLocal, float4(worldNormalVertex, 1)).xyz;
                i.worldPos = i.worldPos + mul(_PQSToLocal, float4(0,0,0,1)).xyz;
             #else
                worldNormalVertex = mul(unity_WorldToObject, float4(worldNormalVertex, 1)).xyz;
                i.worldPos = i.worldPos -  mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz;
             #endif
         #endif

         #if _ORIGINSHIFT
             //worldNormalVertex = mul(_GlobalOriginMTX, float4(worldNormalVertex, 1)).xyz;
             i.worldPos = i.worldPos + mul(_GlobalOriginMTX, float4(0,0,0,1)).xyz;
         #endif

         #if _DEBUG_USE_TOPOLOGY
            i.worldPos = UNITY_SAMPLE_TEX2D_SAMPLER(_DebugWorldPos, _Diffuse, i.uv_Control0);
            worldNormalVertex = UNITY_SAMPLE_TEX2D_SAMPLER(_DebugWorldNormal, _Diffuse, i.uv_Control0);
         #endif

         #if _ALPHABELOWHEIGHT && !_TBDISABLEALPHAHOLES
            ClipWaterLevel(i.worldPos);
         #endif

         #if !_TBDISABLEALPHAHOLES && defined(_ALPHATEST_ON)
            // UNITY 2019.3 holes
            ClipHoles(i.uv_Control0);
         #endif


         float2 origUV = i.uv_Control0;

         #if _MICROMESH && _MESHUV2
         float2 controlUV = i.uv2_Diffuse;
         #else
         float2 controlUV = i.uv_Control0;
         #endif


         #if _MICROMESH
            controlUV = InverseLerp(_UVMeshRange.xy, _UVMeshRange.zw, controlUV);
         #endif

         half4 weights = half4(1,0,0,0);

         Config config = (Config)0;
         UNITY_INITIALIZE_OUTPUT(Config,config);
         config.uv = origUV;

         #if _SPLATFADE
         MSBRANCHOTHER(_SplatFade.y - camDist)
         #endif // _SPLATFADE
         {
            #if _MICRODIGGERMESH && !_PROCEDURALTEXTURE
               DiggerSetup(i, weights, origUV, config, i.worldPos);
            #elif _MICROVERTEXMESH && !_PROCEDURALTEXTURE
               VertexSetup(i, weights, origUV, config, i.worldPos);
            #elif _PROCEDURALTEXTURE && !_DISABLESPLATMAPS && _PROCEDURALBLENDSPLATS && !_MICRODIGGERMESH
               fixed4 w0 = 0; fixed4 w1 = 0; fixed4 w2 = 0; fixed4 w3 = 0; fixed4 w4 = 0; fixed4 w5 = 0; fixed4 w6 = 0; fixed4 w7 = 0;
               SampleSplats(controlUV, w0, w1, w2, w3, w4, w5, w6, w7);
               Setup(weights, origUV, config, w0, w1, w2, w3, w4, w5, w6, w7, i.worldPos);
               float3 up = float3(0,1,0);
               float3 procNormal = worldNormalVertex;
               float height = i.worldPos.y;
               ProceduralSetup(i, i.worldPos, height, procNormal, up, weights, origUV, config, ddx(origUV), ddy(origUV), ddx(i.worldPos), ddy(i.worldPos));
            #elif _PROCEDURALTEXTURE && !_DISABLESPLATMAPS
               float3 up = float3(0,1,0);
               float3 procNormal = worldNormalVertex;
               float height = i.worldPos.y;
               #if _PLANETNORMAL2 || _PLANETNORMAL
                  config.uv = origUV;
                  float2 pnorm = GetPlanetTangentNormal(i, config, camDist, worldNormalVertex);
                  procNormal.xy = pnorm;
                  procNormal.z = sqrt(1 - procNormal.x * procNormal.x - procNormal.y * procNormal.y);
                  procNormal = WorldNormalVector(i, procNormal);
                  up = worldNormalVertex;
                  float3 center = mul(unity_WorldToObject, float3(0,0,0));
                  height = distance(i.worldPos, center); 
              #endif

              ProceduralSetup(i, i.worldPos, height, procNormal, up, weights, origUV, config, ddx(origUV), ddy(origUV), ddx(i.worldPos), ddy(i.worldPos));
            #elif !_DISABLESPLATMAPS && !_MICRODIGGERMESH
               fixed4 w0 = 0; fixed4 w1 = 0; fixed4 w2 = 0; fixed4 w3 = 0; fixed4 w4 = 0; fixed4 w5 = 0; fixed4 w6 = 0; fixed4 w7 = 0;
               SampleSplats(controlUV, w0, w1, w2, w3, w4, w5, w6, w7);
               Setup(weights, origUV, config, w0, w1, w2, w3, w4, w5, w6, w7, i.worldPos);
            #elif _DISABLESPLATMAPS
               Setup(weights, origUV, config, half4(1,0,0,0), 0, 0, 0, 0, 0, 0, 0, i.worldPos);
            #endif
         } // _SPLATFADE else case

         
         #if _TOONFLATTEXTURE
            float2 quv = floor(origUV * _ToonTerrainSize);
            float2 fuv = frac(origUV * _ToonTerrainSize);
            #if !_TOONFLATTEXTUREQUAD
               quv = Hash2D((fuv.x > fuv.y) ? quv : quv * 0.333);
            #endif
            float2 uvq = quv / _ToonTerrainSize;
            config.uv0.xy = uvq;
            config.uv1.xy = uvq;
            config.uv2.xy = uvq;
            config.uv3.xy = uvq;
         #endif
         
         #if (_TEXTURECLUSTER2 || _TEXTURECLUSTER3) && !_DISABLESPLATMAPS
            PrepClusters(origUV, config, i.worldPos, worldNormalVertex);
         #endif

         #if (_ALPHAHOLE || _ALPHAHOLETEXTURE) && !_DISABLESPLATMAPS && !_TBDISABLEALPHAHOLES
         ClipAlphaHole(config, weights);
         #endif


 
         MicroSplatLayer l = Sample(i, weights, config, camDist, worldNormalVertex);


         // Unity has a compiler bug with surface shaders where in some situations it will strip/fuckup
         // i.worldPos or i.viewDir thinking your not using them when you are inside a function. I have
         // fought with this bug so many times it's crazy, reported it and provided repros, and nothing has
         // been done about it. So, make sure these are used, and look like they could have an effect on the final
         // output so the compiler doesn't fuck them up.
         
         // Oh, nice, and it turns out that doing this in the base map shader breaks GI, so only do it in the main
         // shader, which is where we're using i.viewDir for parallax. Fucking hell..

         // AND if triplanar is on, this needs to be run otherwise the UV scale is fucked. I feel like I'm just
         // pushing compiler errors around at this point..
         #if !_MICROSPLATBASEMAP || _TRIPLANAR
            l.Albedo *= saturate(normalize(i.viewDir + i.worldPos) + 9999);
         #endif

         // Further, on windows, sometimes the diffuse sampler gets stripped, so we have to do this crap.
         // We sample from the lowest mip, so it shouldn't cost much, but still, I hate this, wtf..
         l.Albedo *= saturate(UNITY_SAMPLE_TEX2DARRAY_LOD(_Diffuse, config.uv0, 11).r + 2);
         l.Albedo *= saturate(MICROSPLAT_SAMPLE_TEX2D_SAMPLER_LOD(_Control0, _Control0, config.uv, 11).r + 2);

         #if _PROCEDURALTEXTURE
            ProceduralTextureDebugOutput(l, weights, config);
         #endif
         


         return l;

      }



   


      #if _BDRFLAMBERT
      void surf (Input i, inout SurfaceOutput o) 
      #elif _USESPECULARWORKFLOW || _SPECULARFROMMETALLIC

      inline half3 MicroSplatDiffuseAndSpecularFromMetallic (half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
      {
          specColor = lerp (half3(0,0,0), albedo, metallic);
          oneMinusReflectivity = (1-metallic);
          return albedo * oneMinusReflectivity;
      }

      void surf (Input i, inout SurfaceOutputStandardSpecular o)
      #else
      void surf (Input i, inout SurfaceOutputStandard o) 
      #endif
      {
         o.Normal = float3(0,0,1);
         float3 worldNormalVertex = WorldNormalVector(i, float3(0,0,1));
         #if UNITY_VERSION >= 201830 && !_TERRAINBLENDABLESHADER && !_MICROMESH && !_MICRODIGGERMESH && !_MICROVERTEXMESH && defined(UNITY_INSTANCING_ENABLED) && !defined(SHADER_API_D3D11_9X)
            
            float2 sampleCoords = (i.uv_Control0 / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
            #if _TOONHARDEDGENORMAL
               sampleCoords = ToonEdgeUV(sampleCoords);
            #endif
            float3 geomNormal = normalize(tex2D(_TerrainNormalmapTexture, sampleCoords).xyz * 2 - 1);
            worldNormalVertex = geomNormal;
         #elif _PERPIXNORMAL
            float2 perPixUV = i.uv_Control0;
            #if _TOONHARDEDGENORMAL
               perPixUV = ToonEdgeUV(perPixUV);
            #endif
            float3 geomNormal = (UnpackNormal(UNITY_SAMPLE_TEX2D_SAMPLER(_PerPixelNormal, _Diffuse, perPixUV))).xzy;
            worldNormalVertex = geomNormal;
         #endif    
         
         MicroSplatLayer l = SurfImpl(i, worldNormalVertex);

         // always write to o.Normal to keep i.viewDir consistent
         o.Normal = half3(0, 0, 1);

         DoDebugOutput(l);

         o.Albedo = l.Albedo;
         o.Normal = l.Normal;
         o.Emission = l.Emission;
         o.Alpha = l.Alpha;
         #if _BDRFLAMBERT
            o.Specular = l.Occlusion;
            o.Gloss = l.Smoothness;
         #elif _SPECULARFROMMETALLIC
            o.Occlusion = l.Occlusion;
            o.Smoothness = l.Smoothness;
            o.Albedo = MicroSplatDiffuseAndSpecularFromMetallic(l.Albedo, l.Metallic, o.Specular, o.Smoothness);
            o.Smoothness = 1-o.Smoothness;
         #elif _USESPECULARWORKFLOW
            o.Occlusion = l.Occlusion;
            o.Smoothness = l.Smoothness;
            o.Specular = l.Specular;
         #else
            o.Smoothness = l.Smoothness;
            o.Metallic = l.Metallic;
            o.Occlusion = l.Occlusion;
         #endif
         
         
         // per pixel normal
         #if _PERPIXNORMAL || (UNITY_VERSION >= 201830 && !_TERRAINBLENDABLESHADER && !_MICROMESH && !_MICRODIGGERMESH && !_MICROVERTEXMESH && defined(UNITY_INSTANCING_ENABLED) && !defined(SHADER_API_D3D11_9X))
            float3 geomTangent = normalize(cross(geomNormal, float3(0, 0, 1)));
            float3 geomBitangent = normalize(cross(geomTangent, geomNormal));
            o.Normal = o.Normal.x * geomTangent + o.Normal.y * geomBitangent + o.Normal.z * geomNormal;
            o.Normal = o.Normal.xzy;
         #endif
      }

      // for debug shaders
      half4 LightingUnlit(SurfaceOutputStandard s, half3 lightDir, half atten)
      {
         return half4(s.Albedo, 1);
      }


   

      #pragma instancing_options procedural:setup
      #pragma multi_compile GPU_FRUSTUM_ON __

      #if _MSRENDERLOOP_SURFACESHADER
         #include "UnityPBSLighting.cginc"
      #endif

      sampler2D_half _TerrainDesc;
      #if _TBOBJECTNORMALBLEND
      sampler2D _NormalOriginal;
      #endif

      // VS support for indirect rendering

      #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED

         struct IndirectShaderData
         {
            float4x4 PositionMatrix;
            float4x4 InversePositionMatrix;
            float4 ControlData;
         };

         #if defined(SHADER_API_GLCORE) || defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_METAL) || defined(SHADER_API_VULKAN) || defined(SHADER_API_PSSL) || defined(SHADER_API_XBOXONE)
            StructuredBuffer<IndirectShaderData> IndirectShaderDataBuffer;
            StructuredBuffer<IndirectShaderData> VisibleShaderDataBuffer;
         #endif   
      #endif

      void setupScale()
      {
         #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
            #ifdef GPU_FRUSTUM_ON
               unity_ObjectToWorld = VisibleShaderDataBuffer[unity_InstanceID].PositionMatrix;
               unity_WorldToObject = VisibleShaderDataBuffer[unity_InstanceID].InversePositionMatrix;
            #else
               unity_ObjectToWorld = IndirectShaderDataBuffer[unity_InstanceID].PositionMatrix;
               unity_WorldToObject = IndirectShaderDataBuffer[unity_InstanceID].InversePositionMatrix;
            #endif

            #ifdef FAR_CULL_ON_PROCEDURAL_INSTANCING
               #define transformPosition mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz
                  #define distanceToCamera length(transformPosition - _WorldSpaceCameraPos.xyz)
                     float cull = 1.0 - saturate((distanceToCamera - _CullFarStart) / _CullFarDistance);
                     unity_ObjectToWorld = mul(unity_ObjectToWorld, float4x4(cull, 0, 0, 0, 0, cull, 0, 0, 0, 0, cull, 0, 0, 0, 0, 1));
                  #undef transformPosition
               #undef distanceToCamera
            #endif
         #endif
      }

      void setup()
      {
         #ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
            #ifdef GPU_FRUSTUM_ON
               unity_ObjectToWorld = VisibleShaderDataBuffer[unity_InstanceID].PositionMatrix;
               unity_WorldToObject = VisibleShaderDataBuffer[unity_InstanceID].InversePositionMatrix;
            #else
               unity_ObjectToWorld = IndirectShaderDataBuffer[unity_InstanceID].PositionMatrix;
               unity_WorldToObject = IndirectShaderDataBuffer[unity_InstanceID].InversePositionMatrix;
            #endif
         #endif
      }


      struct SurfaceOutputCustom
      {
         fixed3 Albedo;
         fixed3 Normal;
         half3 Emission;
         half Metallic;
         half Smoothness;
         half Occlusion;
         fixed Alpha;
         fixed3 Specular;
         Input input;
      };

      float3 Barycentric(float2 p, float2 a, float2 b, float2 c)
      {
          float2 v0 = b - a;
          float2 v1 = c - a;
          float2 v2 = p - a;
          float d00 = dot(v0, v0);
          float d01 = dot(v0, v1);
          float d11 = dot(v1, v1);
          float d20 = dot(v2, v0);
          float d21 = dot(v2, v1);
          float denom = d00 * d11 - d01 * d01;
          float v = (d11 * d20 - d01 * d21) / denom;
          float w = (d00 * d21 - d01 * d20) / denom;
          float u = 1.0f - v - w;
          return float3(u, v, w);
      }

      float4 SampleTerrainDesc(inout SurfaceOutputCustom s, out float normBlend)
      {
         float2 worldUV = (s.input.worldPos.xz - _TerrainBounds.xy);
         float2 uv = worldUV / max(float2(0.001, 0.001), _TerrainBounds.zw);

         s.input.uv_Control0 = uv;

         float2 ratio = _TerrainDesc_TexelSize.zw / _TerrainBounds.zw;

         float2 uvCorner = worldUV * ratio;

         float2 uvSide = frac(uvCorner);
         uvCorner = floor(uvCorner);

         float2 uvTop = uvCorner + 1;
         uvCorner *= _TerrainDesc_TexelSize.xy;
         uvTop *= _TerrainDesc_TexelSize.xy;

         float2 uv0 = uvCorner;
         float2 uv1 = float2(uvCorner.x, uvTop.y);
         float2 uv2 = float2(uvTop.x, uvTop.y);

         if (uvSide.x > uvSide.y)
         {
            uv2 = uvTop;
         }
         float4 h0 = tex2D(_TerrainDesc, uv0);
         float4 h1 = tex2D(_TerrainDesc, uv1);
         float4 h2 = tex2D(_TerrainDesc, uv2);
         float3 weights = Barycentric(uv, uv0, uv1, uv2);
         float4 th = h0 * weights.x + h1 * weights.y + h2 * weights.z;
         
         th.w += _TerrainBlendParams.z; // add terrain height..
         float d = abs(th.w - s.input.worldPos.y);
         normBlend = saturate(d / _SlopeBlendParams.w);
         th.w = saturate(d / _TerrainBlendParams.x);
         th.w = pow(th.w, abs(_TerrainBlendParams.w));
         clip(0.999-th.w);
         return th;

      }

      float3x3 ComputeTerrainTBN(float4 th, out float3 terrainTangent, out float3 terrainBitangent)
      {
         terrainTangent = (cross(th.xyz, float3(0,0,1)));
         terrainBitangent = (cross(th.xyz, terrainTangent));
         float3x3 tbn = float3x3(terrainTangent, terrainBitangent, th.xyz);
         return tbn;
      }

      float3 GetWorldNormalBlend(SurfaceOutputCustom s, float4 th, float normBlend)
      {
         float3 worldNormalBlend = th.xyz;
         #if _SNOW || _TRIPLANAR
         worldNormalBlend = lerp(th.xyz, WorldNormalVector(s.input, s.input.worldNormal), normBlend);
         #endif
         return worldNormalBlend;
      }



      void DoTerrainLayer(inout SurfaceOutputCustom s, float4 th, inout float3 worldNormalBlend, float3x3 tbn)
      {
         MicroSplatLayer terrainS = (MicroSplatLayer)0;
         terrainS.Normal = half3(0, 1, 0);
         if (_FeatureFilters.x < 1)
         {
            terrainS = SurfImpl(s.input, worldNormalBlend);
            s.Alpha = (1.0-th.w);

            // slope
            #if _TBOBJECTNORMALBLEND
               float3 normalCustom = UnpackNormal (tex2D (_NormalOriginal, s.input.uv_Control0.xy));
               half3 slopeNormal = WorldNormalVector (s.input, normalCustom);
            #else
               half3 slopeNormal = s.input.worldNormal;
            #endif
            slopeNormal.xz += terrainS.Normal.xy * _SlopeBlendParams.z;
            slopeNormal = normalize(slopeNormal);
            half slope = max(0, (dot(slopeNormal, half3(0, 1, 0)) - _SlopeBlendParams.x) * _SlopeBlendParams.y);
            
            half noiseHeight = 0.5;
            
            #if _TBNOISE
               noiseHeight = Noise3D(s.input.worldPos * _TBNoiseScale);
            #elif _TBNOISEFBM
               noiseHeight = FBM3D(s.input.worldPos * _TBNoiseScale);
            #endif


            s.Alpha = min(s.Alpha + slope, 1);
            s.Alpha = lerp(s.Alpha, HeightBlend(noiseHeight, terrainS.Height, s.Alpha, _TerrainBlendParams.y), _TerrainBlendParams.y);
            
            #if !_TBDISABLE_ALPHACONTROL
               s.Alpha *= s.input.color.a;
            #endif
         }


         #if _SNOW
            if (_FeatureFilters.y < 1)
            {
               worldNormalBlend = lerp(worldNormalBlend, half3(0,1,0), _SnowBlendParams.x);
               s.Alpha = max(s.Alpha, DoSnowSimple(terrainS, s.input.uv_Control0, mul(terrainS.Normal, tbn), worldNormalBlend, s.input.worldPos, 0, 0.4));
            }
         #endif

         terrainS.Normal = mul(terrainS.Normal, tbn);

         s.Albedo = terrainS.Albedo;
         s.Normal = terrainS.Normal;
         s.Smoothness = terrainS.Smoothness;
         s.Metallic = terrainS.Metallic;
         s.Occlusion = terrainS.Occlusion;
      }


      float3x3 BlendWithTerrainSRP(inout SurfaceOutputCustom s, inout float3 wsTangent, inout float3 wsBitangent, inout float3 wsNormal)
      {
         float normBlend;
         float4 th = SampleTerrainDesc(s, normBlend);
         float3 tang; float3 bitang;
         float3x3 tbn = ComputeTerrainTBN(th, tang, bitang);
         float3 worldNormalBlend = GetWorldNormalBlend(s, th, normBlend);
         DoTerrainLayer(s, th, worldNormalBlend, tbn);
         wsTangent = lerp(tang, wsTangent, s.Alpha);
         wsBitangent = lerp(bitang, wsBitangent, s.Alpha);
         wsNormal = lerp(th.xyz, wsNormal, s.Alpha);
         return float3x3(th.xyz, wsNormal, wsBitangent);
      }

      void BlendWithTerrain(inout SurfaceOutputCustom s, inout half3 sh)
      {
         float normBlend;
         float4 th = SampleTerrainDesc(s, normBlend);
         float3 tang; float3 bitang;
         float3x3 tbn = ComputeTerrainTBN(th, tang, bitang);
         float3 worldNormalBlend = GetWorldNormalBlend(s, th, normBlend);

         // reconstruct view dir into correct space. 
         // Wish this could be preserved, but ends up in world space for no good reason, so we have to go back
         // to object space, then into tangent again.. 2 extra matrix mul's per pixel.. 

         float3 wsvd = mul(unity_WorldToObject, float4(s.input.viewDir, 1)).xyz;
         s.input.viewDir = mul(tbn,wsvd);


         DoTerrainLayer(s, th, worldNormalBlend, tbn);
      }

      #if _MSRENDERLOOP_SURFACESHADER
         #if _BDRFLAMBERT 
            SurfaceOutput ToStandard(SurfaceOutputCustom s)
            {
               SurfaceOutput o = (SurfaceOutput)0;
               UNITY_INITIALIZE_OUTPUT(SurfaceOutput, o);
               o.Albedo = s.Albedo;
               o.Normal = s.Normal;
               o.Gloss = s.Smoothness;
               o.Specular = s.Occlusion;
               o.Emission = s.Emission;
               o.Alpha = s.Alpha;
               return o;
            }
         #elif _USESPECULARWORKFLOW || _SPECULARFROMMETALLIC
            SurfaceOutputStandardSpecular ToStandard(SurfaceOutputCustom s)
            {
               SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
               UNITY_INITIALIZE_OUTPUT(SurfaceOutputStandardSpecular, o);
               o.Albedo = s.Albedo;
               o.Normal = s.Normal;
               o.Smoothness = s.Smoothness;
               o.Specular = s.Specular;
               o.Occlusion = s.Occlusion;
               o.Emission = s.Emission;
               o.Alpha = s.Alpha;
               return o;
            }

         #else
            SurfaceOutputStandard ToStandard(SurfaceOutputCustom s)
            {
               SurfaceOutputStandard o = (SurfaceOutputStandard)0;
               UNITY_INITIALIZE_OUTPUT(SurfaceOutputStandard, o);
               o.Albedo = s.Albedo;
               o.Normal = s.Normal;
               o.Smoothness = s.Smoothness;
               o.Metallic = s.Metallic;
               o.Occlusion = s.Occlusion;
               o.Emission = s.Emission;
               o.Alpha = s.Alpha;
               return o;
            }
         #endif // _BDRFLAMBERT
      #endif // _MSRENDERLOOP_SURFACESHADER

      #if _MSRENDERLOOP_SURFACESHADER
      inline void LightingTerrainBlendable_GI( inout SurfaceOutputCustom s, UnityGIInput data, inout UnityGI gi )
      {
         BlendWithTerrain(s, data.ambient);
         #if _BDRFLAMBERT
         LightingLambert_GI(ToStandard(s), data, gi);
         #elif _USESPECULARWORKFLOW || _SPECULARFROMMETALLIC
         LightingStandardSpecular_GI(ToStandard(s), data, gi);
         #else
         LightingStandard_GI(ToStandard(s), data, gi );
         #endif
      }

      inline half4 LightingTerrainBlendable( SurfaceOutputCustom s, half3 viewDir, UnityGI gi )
      {
         half3 sh = 0;
         BlendWithTerrain(s, sh);
         #if _BDRFLAMBERT
            return LightingLambert(ToStandard(s), gi);
         #elif _USESPECULARWORKFLOW || _SPECULARFROMMETALLIC
            return LightingStandardSpecular(ToStandard(s), viewDir, gi);
         #else
            return LightingStandard(ToStandard(s), viewDir, gi );
         #endif
      }

      half4 LightingTerrainBlendable_Deferred (SurfaceOutputCustom s, half3 viewDir, UnityGI gi, out half4 outDiffuseOcclusion, out half4 outSpecSmoothness, out half4 outNormal)
      {
         half3 sh = 0;
         BlendWithTerrain(s, sh);
         #if _BDRFLAMBERT
            return LightingLambert_Deferred(ToStandard(s), gi, outDiffuseOcclusion, outSpecSmoothness, outNormal);
         #elif _USESPECULARWORKFLOW || _SPECULARFROMMETALLIC
            return LightingStandardSpecular_Deferred(ToStandard(s), viewDir, gi, outDiffuseOcclusion, outSpecSmoothness, outNormal);
         #else
            return LightingStandard_Deferred(ToStandard(s), viewDir, gi, outDiffuseOcclusion, outSpecSmoothness, outNormal);
         #endif
      }
      #endif

      void blendSurf (Input i, inout SurfaceOutputCustom o) 
      {
         UNITY_INITIALIZE_OUTPUT(SurfaceOutputCustom, o);
         o.input = i;
         o.Normal = float3 (0, 0, 1);
      }


ENDCG

   }
   CustomEditor "MicroSplatBlendableMaterialEditor"
   Fallback "Nature/Terrain/Diffuse"
}
