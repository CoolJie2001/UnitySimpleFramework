using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

public class Const {   
    public static bool BetaMode = false;                        //封测模式-用于标示支付
    public static bool DebugMode = true;                        //调试模式-用于内部测试
    public static bool InnerNetMode = true;                     //内网模式-使用内网模式

    public static int TimerInterval = 1;

    public static TextAsset[] luaScripts;                       //Lua公共脚本

    public static string UserId = string.Empty;                 //用户ID
    public static string AppName = "GameApp";                   //应用程序名称
    public static string AppPrefix = AppName + "_";             //应用程序前缀
    public static string ResDirectory = "game/";                //资源目录
}
