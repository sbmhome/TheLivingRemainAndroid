using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using System.IO;
using System.Linq;
using System.Xml.Linq;
using UnityEngine;

public class PostProcessBuild : IPostprocessBuildWithReport
{
    public int callbackOrder => 9999;

    public void OnPostprocessBuild(BuildReport report)
    {
        return;
        
        Debug.Log("FFS Update AndroidManifest");
        if (report.summary.platform != BuildTarget.Android) return;
        
        Debug.Log("FFS 2");

        string manifestPath = Path.Combine(report.summary.outputPath, "AndroidManifest.xml");
        
        
        
        
        
        Debug.Log("FFS TRY PATH");
        
        string[] possiblePaths = {
            Path.Combine(report.summary.outputPath, "src", "main", "AndroidManifest.xml"),
            Path.Combine(report.summary.outputPath, "launcher", "src", "main", "AndroidManifest.xml"),
            Path.Combine(report.summary.outputPath, "AndroidManifest.xml"),
            Path.Combine(Application.dataPath, "..", "Temp", "GradleOut", "launcher", "src", "main", "AndroidManifest.xml")
        };

        foreach (var path in possiblePaths)
        {
            if (File.Exists(path))
            {
                Debug.Log($"✅ Found AndroidManifest.xml at: {path}");
                manifestPath = path;
                break;
            }
        }
        
        Debug.Log("FFS TRY PATH END");
        
        
        
        
        

        if (!File.Exists(manifestPath))
        {
            UnityEngine.Debug.LogError("AndroidManifest.xml not found! Check the build process.");
            Debug.Log("FFS 3");
            return;
        }
        Debug.Log("FFS 4");
        XDocument doc = XDocument.Load(manifestPath);
        XElement root = doc.Element("manifest");
        XNamespace android = "http://schemas.android.com/apk/res/android";

        if (root == null)
        {
            UnityEngine.Debug.LogError("Failed to parse AndroidManifest.xml.");
            Debug.Log("FFS 5");
            return;
        }
        Debug.Log("FFS 6");
        // Check if permissions already exist before adding
        bool hasInternet = root.Elements("uses-permission")
            .Any(e => e.Attribute(android + "name")?.Value == "android.permission.INTERNET");

        bool hasNetworkState = root.Elements("uses-permission")
            .Any(e => e.Attribute(android + "name")?.Value == "android.permission.ACCESS_NETWORK_STATE");

        if (!hasInternet)
        {
            root.Add(new XElement("uses-permission", new XAttribute(android + "name", "android.permission.INTERNET")));
            Debug.Log("FFS 7");
        }
        Debug.Log("FFS 8");
        if (!hasNetworkState)
        {
            root.Add(new XElement("uses-permission", new XAttribute(android + "name", "android.permission.ACCESS_NETWORK_STATE")));
            Debug.Log("FFS 9");
        }
        Debug.Log("FFS 10");

        // Save the updated manifest
        doc.Save(manifestPath);

        Debug.Log("Successfully added INTERNET and ACCESS_NETWORK_STATE permissions to AndroidManifest.xml.");
    }
}


