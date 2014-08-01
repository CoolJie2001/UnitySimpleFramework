using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PanelManager : MonoBehaviour {
    private Transform parent;
    ///排除列表
    ///Lua可以通过ioo.panelManager.excludes来添加删除
    public List<string> excludes = new List<string>(); 

    Transform Parent {
        get {
            if (parent == null) {
                parent = Camera.main.transform;
            }
            return parent;
        }
    }

    /// <summary>
    /// 创建面板，请求资源管理器
    /// </summary>
    /// <param name="type"></param>
    public void CreatePanel(string name) {
        io.resourceManager.RequestResource(name); 
    }

    /// <summary>
    /// 请求资源回调函数
    /// </summary>
    public void OnRequestResource(string type, AssetBundle bundle, string text = null) {
        StartCreatePanel(type, bundle, text);
    }

    /// <summary>
    /// 创建面板
    /// </summary>
    void StartCreatePanel(string name, AssetBundle bundle, string text = null) {
        name += "Panel";   //面板与处理器分开处理

        GameObject prefab = bundle.Load(name) as GameObject;
        if (Parent.FindChild(name) != null || prefab == null) return;

        GameObject go = Instantiate(prefab) as GameObject;
        go.name = name;
        go.transform.parent = Parent;
        go.transform.localScale = Vector3.one;
        go.transform.localPosition = Vector3.zero;

        bool canAdd = true;
        for (int i = 0; i < excludes.Count; i++) {
            if (name.Equals(excludes[i])) { canAdd = false; break; }
        }
        if (canAdd) {
            go.AddComponent<BaseLua>().OnInit(bundle);
        }

        if (go == null) {
            if (Debug.isDebugBuild) Debug.LogError("OnCreatePanel :>" + name + " error!~");
            return;
        }
        if (Debug.isDebugBuild) Debug.Log("OnCreatePanel------>>>>" + name);
    }
}
