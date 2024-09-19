#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Build;


/*     This class will increment the iOS build number on each build - this is useful for uploading builds
    to TestFlight (iOS) as it requires a more recent build number on each iteration */
public class IncrementBundleVersionCode : IPreprocessBuild
{
    public int callbackOrder { get { return 0; } }
    public void OnPreprocessBuild(BuildTarget target, string path)
    {
        PlayerSettings.Android.bundleVersionCode = PlayerSettings.Android.bundleVersionCode + 1;
    }
}
#endif