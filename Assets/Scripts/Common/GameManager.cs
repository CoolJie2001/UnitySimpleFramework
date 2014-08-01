using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;

public class GameManager : BaseLua {

    /// <summary>
    /// 初始化游戏管理器
    /// </summary>
    void Awake () {
        Init();
    }

    /// <summary>
    /// 初始化
    /// </summary>
    void Init() {
        InitManagers(); 
        DontDestroyOnLoad(gameObject);  //防止销毁自己
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
    }

    /// <summary>
    /// 帧频更新
    /// </summary>
    void Update() {
    }

    /// <summary>
    /// 初始化管理器
    /// </summary>
    public void InitManagers() {
        Util.Add<PanelManager>(gameObject);
        Util.Add<MusicManager>(gameObject);
        Util.Add<TimerManager>(gameObject);
        Util.Add<ResourceManager>(gameObject);
    }

    /// <summary>
    /// 资源初始化结束
    /// </summary>
    public void OnResourceInited() {
        InitObject();
        StartCoroutine(OnReqLuainfo()); //加载服务器端Lua配置
    }

    /// <summary>
    /// 请求服务器Lua信息
    /// </summary>
    IEnumerator OnReqLuainfo() {
        string text = "BackupPanel";
        string[] luapanels = text.Split(',');   //分割lua面板

        //---------------------Lua面板---------------------------
        Global.LuaObjects.Clear();  //加载预先的对象并初始化Lua脚本
        foreach (string panel in luapanels) {
            string name = panel.Trim();
            if (string.IsNullOrEmpty(name)) continue;
            BaseLua.luaNames.Add(name);  //缓存起来

            LuaState lua = new LuaState();
            TextAsset[] scripts = Const.luaScripts;
            foreach (TextAsset code in scripts) {
                lua.DoString(code.text);
            }
            TextAsset script = io.resourceManager.LoadScript(name + ".lua");
            if (script != null) lua.DoString(script.text);  //加载对象Lua脚本
            Global.LuaObjects.Add(name, lua);   //加入对象池

            if (Debug.isDebugBuild) Debug.LogWarning("LoadLua---->>>>" + name + ".lua");
            yield return 0;
        }
        //------------------------------------------------------------
        io.panelManager.CreatePanel("Backup");  //创建面板
    }

    /// <summary>
    /// 析构函数
    /// </summary>
    void OnDestroy() {
        if (Debug.isDebugBuild) print("~GameManager was destroyed");
    }
}
