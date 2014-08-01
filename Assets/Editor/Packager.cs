using UnityEditor;
using UnityEngine;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;

public class Packager {
    public static string platform = string.Empty;
    static List<string> paths = new List<string>();
    static List<string> files = new List<string>();

    ///-----------------------------------------------------------
    static string[] exts = { ".txt", ".xml", ".lua", ".assetbundle" };
    static bool CanCopy(string ext) {   //能不能复制
        foreach (string e in exts) {
            if (ext.Equals(e)) return true;
        }
        return false;
    }

    /// <summary>
    /// 载入素材
    /// </summary>
    static UnityEngine.Object LoadAsset(string file) {
        if (file.EndsWith(".lua")) file += ".txt";
        return AssetDatabase.LoadMainAssetAtPath("Assets/Builds/" + file);
    }

    /// <summary>
    /// 生成绑定素材
    /// </summary>
    [MenuItem("Game/Build Bundle Resource")]
    public static void BuildAssetResource() {
        UpdateResource();               //先更新资源
        Object mainAsset = null;        //主素材名，单个
        Object[] addiAssets = null;     //附加素材名，多个
        string assetfile = string.Empty;  //素材文件名

        BuildAssetBundleOptions options = BuildAssetBundleOptions.UncompressedAssetBundle | BuildAssetBundleOptions.CollectDependencies |
                                          BuildAssetBundleOptions.CompleteAssets | BuildAssetBundleOptions.DeterministicAssetBundle;

        BuildTarget target;
        if (Application.platform == RuntimePlatform.OSXEditor) {
            target = BuildTarget.iPhone;
        } else {
            target = BuildTarget.Android;
        }
        string assetPath = Application.dataPath + "/StreamingAssets/asset/" + target + "/";
        if (!Directory.Exists(assetPath)) Directory.CreateDirectory(assetPath);

        ///-----------------------------生成共享的Lua资源---------------------------------------
        addiAssets = new Object[3];   //附加脚本素材
        addiAssets[0] = LoadAsset("Common/Scripts/define.lua");
        addiAssets[1] = LoadAsset("Common/Scripts/functions.lua");
        addiAssets[2] = LoadAsset("Backup/Scripts/BackupPanel.lua");

        assetfile = assetPath + "common.assetbundle";
        BuildPipeline.BuildAssetBundle(null, addiAssets, assetfile, options, target);

        ///-----------------------------生成共享的关联性素材绑定-------------------------------------
        BuildPipeline.PushAssetDependencies();

        assetfile = assetPath + "shared.assetbundle";
        mainAsset = LoadAsset("Shared/Atlas/Dialog.prefab");
        BuildPipeline.BuildAssetBundle(mainAsset, null, assetfile, options, target);

        ///------------------------------生成BackupPanel素材绑定-----------------------------------
        BuildPipeline.PushAssetDependencies();
        mainAsset = LoadAsset("Backup/Prefabs/BackupPanel.prefab");
        assetfile = assetPath + "backup.assetbundle";
        BuildPipeline.BuildAssetBundle(mainAsset, null, assetfile, options, target);
        BuildPipeline.PopAssetDependencies();

        ///-------------------------------刷新---------------------------------------
        BuildPipeline.PopAssetDependencies();
        AssetDatabase.Refresh();
    }

    /// <summary>
    /// 更新资源:把lua文件生成txt
    /// </summary>
    static void UpdateResource() {
        paths.Clear(); files.Clear();
        Recursive(AppDataPath + "/Builds/");

        for (int i = 0; i < files.Count; i++) {
            string file = files[i];
            if (!file.EndsWith(".lua")) continue;

            string newfile = file + ".txt";
            if (File.Exists(newfile)) File.Delete(newfile);

            string[] oldContent = File.ReadAllLines(file);
            List<string> newContent = new List<string>();
            for (int j = 0; j < oldContent.Length; j++) {
                string str = oldContent[j].Trim();
                if (str.StartsWith("--")) continue; //如果是注释行，调过，不写入文件
                newContent.Add(oldContent[j]);
            }
            File.WriteAllLines(newfile, newContent.ToArray(), System.Text.Encoding.UTF8);
        }
        AssetDatabase.Refresh();
    }

    /// <summary>
    /// 数据目录
    /// </summary>
    static string AppDataPath {
        get { return Application.dataPath.ToLower(); }
    }

    /// <summary>
    /// 遍历目录及其子目录
    /// </summary>
    static void Recursive(string path) {
        string[] names = Directory.GetFiles(path);
        string[] dirs = Directory.GetDirectories(path);
        foreach (string filename in names) {
            string ext = Path.GetExtension(filename);
            if (ext.Equals(".meta")) continue;
            files.Add(filename.Replace('\\', '/'));
        }
        foreach (string dir in dirs) {
            paths.Add(dir.Replace('\\', '/'));
            Recursive(dir);
        }
    }
}