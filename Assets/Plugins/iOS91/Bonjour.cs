using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class Bonjour {

	/* Interface to native implementation */
	[DllImport ("__Internal")]
	private static extern void U3dNdInit(int appId, string appKey);
	[DllImport ("__Internal")]
	private static extern void U3dNdPause();
	[DllImport ("__Internal")]
	private static extern void U3dNdSetAppId (int appId);
	[DllImport ("__Internal")]
	private static extern void U3dNdSetAppKey (string appKey);
	[DllImport ("__Internal")]
	private static extern int U3dNdLogin (int nFlag);
	[DllImport ("__Internal")]
	private static extern int U3dNdSetDebugMode (int nFlag);
	[DllImport ("__Internal")]
	private static extern int U3dNdCheckUpdate (int nFlag);
	[DllImport ("__Internal")]
	private static extern int U3dNdSearchPayResult (string cooOrderSerial);
	[DllImport ("__Internal")]
	private static extern int U3dNdUniPay (string cooOrderSerial,string productId,string productName,double productPrice,double productOriginalPrice,int productCount,string payDescription);
	[DllImport ("__Internal")]
	private static extern int U3dNdUniPayAsyn (string cooOrderSerial,string productId,string productName,double productPrice,double productOriginalPrice,int productCount,string payDescription);
	[DllImport ("__Internal")]
	private static extern int U3dNdUniPayForCoin (string cooOrderSerial,int needPayCoins,string payDescription);
	[DllImport ("__Internal")]
	private static extern int U3dNdSetScreenOrientation (int orientation);//orientation 0:竖屏 1:横屏朝左 2:竖屏朝下 3:横屏朝右;
	[DllImport ("__Internal")]
	private static extern int U3dNdLogout (int nFlag);//nFlag 标识（按位标识）0,表示注销；1，表示注销，并清除自动登录;
	[DllImport ("__Internal")]
	private static extern bool U3dNdIsLogined ();
	[DllImport ("__Internal")]
	private static extern bool U3dNdEnterPlatform (int nFlag);
	[DllImport ("__Internal")]
	private static extern bool U3dNdUserFeedBack ();
	[DllImport ("__Internal")]
	private static extern bool U3dNdEnterRecharge (int nFlag, string content);
	[DllImport ("__Internal")]
	private static extern long U3dNdGetUin();
	[DllImport ("__Internal")]
	private static extern long U3dNdGetNickname();
	[DllImport ("__Internal")]
	private static extern long U3dNdGetSession();
    [DllImport("__Internal")]
    private static extern void U3dNdShowToolBar();
    [DllImport("__Internal")]
    private static extern void U3dNdHideToolBar();
	/* Public interface for use inside C# / JS code */
	
	// Starts lookup for some bonjour registered service inside specified domain
    public static void init(int appId, string appKey) {
        // Call plugin only when running on real device
        if (Application.platform != RuntimePlatform.WindowsEditor && 
            Application.platform != RuntimePlatform.OSXEditor && 
            Application.platform != RuntimePlatform.Android)
            U3dNdInit(appId, appKey);
    }
    public static void pause() {
        U3dNdPause();
    }
    public static void setAppId(int appId) {
        // Call plugin only when running on real device
        if (Application.platform != RuntimePlatform.WindowsEditor && 
            Application.platform != RuntimePlatform.OSXEditor && 
            Application.platform != RuntimePlatform.Android)
            U3dNdSetAppId(appId);
    }
    public static void setAppKey(string appKey) {
        if (Application.platform != RuntimePlatform.WindowsEditor && 
            Application.platform != RuntimePlatform.OSXEditor && 
            Application.platform != RuntimePlatform.Android)
            U3dNdSetAppKey(appKey);
    }
	public static void login(){
			U3dNdLogin(0);			
	}
    public static void debugMode() {
        if (Application.platform != RuntimePlatform.WindowsEditor && 
            Application.platform != RuntimePlatform.OSXEditor && 
            Application.platform != RuntimePlatform.Android)
            U3dNdSetDebugMode(0);
    }
    public static void searchPayResult(string cooOrderSerial) {
        U3dNdSearchPayResult(cooOrderSerial);
    }
    public static void uniPay(string cooOrderSerial, string productId, string productName, double productPrice, double productOriginalPrice, int productCount, string payDescription) {
        U3dNdUniPay(cooOrderSerial, productId, productName, productPrice, productOriginalPrice, productCount, payDescription);
    }
    public static void uniPayAsyn(string cooOrderSerial, string productId, string productName, double productPrice, double productOriginalPrice, int productCount, string payDescription) {
        U3dNdUniPayAsyn(cooOrderSerial, productId, productName, productPrice, productOriginalPrice, productCount, payDescription);
    }
	public static void payForCoin(string cooOrderSerial,int needPayCoins,string payDescription){
        U3dNdUniPayForCoin(cooOrderSerial, needPayCoins, payDescription);			
	}
	public static void U3dNdSetScreenOrientation(){
        U3dNdSetScreenOrientation(1);
	}
	public static void loginOut(int autologin){
        U3dNdLogout(autologin);
	}
	public static bool isLogined(){
        return U3dNdIsLogined();
	}
	public static void enter91(){
        U3dNdEnterPlatform(0);
	}
	public static void enterFeedback(){
        U3dNdUserFeedBack();
	}
	public static void enterRecharge(){
        U3dNdEnterRecharge(0, "");
	}
	public static bool checkUpdate(){
        if (Application.platform != RuntimePlatform.WindowsEditor && 
            Application.platform != RuntimePlatform.OSXEditor && 
            Application.platform != RuntimePlatform.Android) {
            U3dNdCheckUpdate(0);
            return false;
        } else {
            return true;
        }
	}
	public static long getPlayerID(){
		return U3dNdGetUin();
	}
	public static long getNickName(){
		return U3dNdGetNickname();
	}
	public static long getSession(){
		return U3dNdGetSession();
	}
    public static void showToolBar() {
        U3dNdShowToolBar();
    }
    public static void hideToolBar() {
        U3dNdHideToolBar();
    }
}
