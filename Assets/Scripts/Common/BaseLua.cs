using UnityEngine;
using LuaInterface;
using System.Collections;
using System.Collections.Generic;

public class BaseLua : MonoBehaviour {
    private string data = null;
    private bool initialize = false;
    private LuaState lua = null;
    private AssetBundle bundle;
    /// <summary>
    /// lua面板
    /// </summary>
    public static List<string> luaNames = new List<string>();
    Dictionary<string, LuaFunction> functions = new Dictionary<string, LuaFunction>();

    protected void Start() {
        CallMethod("Start");
    }

    protected void OnClick() {
        CallMethod("OnClick");
    }

    protected void OnClickEvent(GameObject go) {
        CallMethod("OnClick", go);
    }

    public void OnWeb(int key, object value) {
        CallMethod("OnWeb", key, value);
    }

    public void OnSocket(int key, ByteBuffer buffer) {
        CallMethod("OnSocket", key, buffer);
    }

    /// <summary>
    /// 初始化面板
    /// </summary>
    public void OnInit(AssetBundle bundle, string text = null) {
        InitPanel(); this.bundle = bundle; //初始化
        this.data = text;   //初始化附加参数
        if (Debug.isDebugBuild) Debug.LogWarning("OnInit---->>>text:>" + text);
    }

    /// <summary>
    /// 获取一个GameObject资源
    /// </summary>
    /// <param name="name"></param>
    public GameObject GetGameObject(string name) {
        if (bundle == null) return null;
        return bundle.Load(name, typeof(GameObject)) as GameObject;
    }

    /// <summary>
    /// 获取一个无类型资源
    /// </summary>
    public UnityEngine.Object GetUntypeObject(string name) {
        if (bundle == null) return null;
        return bundle.Load(name);
    }

    /// <summary>
    /// 等待时间
    /// </summary>
    /// <param name="time"></param>
    public void Wait(float time) {
        StartCoroutine(OnWait(time));
    }

    IEnumerator OnWait(float time) {
        yield return new WaitForSeconds(time);
        CallMethod("resume");
    }

    //-----------------------------------------------
    /// <summary>
    /// 初始化
    /// </summary>
    protected void InitObject() {
        if (initialize) return;  //初始化过就退出
        initialize = true;

        lua = new LuaState();
        TextAsset[] scripts = Const.luaScripts;
        foreach (TextAsset code in scripts) {
            lua.DoString(code.text);
            if (Debug.isDebugBuild) Debug.LogWarning("LoadLua---->>>>" + code.name);
        }
        SetLuaData(lua);
    }

    /// <summary>
    /// 初始化面板
    /// </summary>
    protected void InitPanel() {
        if (initialize) return;  //初始化过就退出
        initialize = true;
        if (luaNames.Count == 0) return;

        bool runLua = false;
        string name = gameObject.name;

        for (int i = 0; i < luaNames.Count; i++) {
            if (luaNames[i].Equals(name)) {
                runLua = true;
                break;
            }
        }
        if (!runLua) return;    //不能允许lua

        object o = Global.LuaObjects[name];
        if (o == null) return;
        lua = o as LuaState;
        SetLuaData(lua);    //把transform跟gameObject传递给Lua    

        ///关联界面上所有按钮消息
        UIButton[] buttons = GetComponentsInChildren<UIButton>();
        for (int i = 0; i < buttons.Length; i++) {
            EventDelegate.Add(buttons[i].onClick, OnClick);
        }
    }

    /// <summary>
    /// 初始化lua脚本
    /// </summary>
    public void InitScript(TextAsset code) {
        lua.DoString(code.text);
    }

    /// <summary>
    /// 设置Lua数据
    /// </summary>
    protected void SetLuaData(LuaState lua) {
        lua["transform"] = transform;
        lua["gameObject"] = gameObject;
    }

    /// <summary>
    /// 执行Lua方法-无参数
    /// </summary>
    protected object[] CallMethod(string func) {
        if (lua == null) return null;
        if (!functions.ContainsKey(func)) {
            functions[func] = lua.GetFunction(func);
        }
        if (functions[func] != null) {
            return functions[func].Call();
        }
        return null;
    }

    /// <summary>
    /// 执行Lua方法-Socket消息
    /// </summary>
    protected object[] CallMethod(string func, GameObject go) {
        if (lua == null) return null;
        if (!functions.ContainsKey(func)) {
            functions[func] = lua.GetFunction(func);
        }
        if (functions[func] != null) {
            return functions[func].Call(go);
        }
        return null;
    }

    /// <summary>
    /// 执行Lua方法-Socket消息
    /// </summary>
    protected object[] CallMethod(string func, int key, ByteBuffer buffer) {
        if (lua == null) return null;
        if (!functions.ContainsKey(func)) {
            functions[func] = lua.GetFunction(func);
        }
        if (functions[func] != null) {
            return functions[func].Call(key, buffer);
        }
        return null;
    }

    /// <summary>
    /// 执行Lua方法-Web消息
    /// </summary>
    protected object[] CallMethod(string func, int key, object value) {
        if (lua == null) return null;
        if (!functions.ContainsKey(func)) {
            functions[func] = lua.GetFunction(func);
        }
        if (functions[func] != null) {
            return functions[func].Call(key, value);
        }
        return null;
    }

    //-----------------------------------------------------------------
    protected void OnDestroy() {
        CallMethod("OnDestroy");
        if (bundle) {
            bundle.Unload(true);
            bundle = null;  //销毁素材
        }
        Util.ClearMemory();
    }
}