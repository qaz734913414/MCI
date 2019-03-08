using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace MyFramework
{
    public enum AppPlatform
    {
        IOS,
        Android,
        Windows,
    }
    public enum AppResModel
    {
        DebugModel,
        AssetBundleModel,
    }

    public static class AppConfig 
    {
        public static AppResModel AppResModel = AppResModel.DebugModel;

        public static AppPlatform TargetPlatform = AppPlatform.Windows;

        public static string Ip = "127.0.0.1";

        public static int Port = 7777;

        public static int UdpPort = 7778;

        public static string ResFileSuffix = ".1dao";

        public const string mAppExternalAddress = "AppResources";

        public const string mAppResourcesTemp = "AppResourcesTemp";

        /// <summary>
        /// 平台沙盒存储根目录
        /// </summary>
        public static string PlatformRoot
        {
            get
            {
                switch (Application.platform)
                {
                    case RuntimePlatform.IPhonePlayer:
                        return Application.persistentDataPath;
                    case RuntimePlatform.Android:
                        return Application.persistentDataPath;
                    case RuntimePlatform.WindowsPlayer:
                        return Application.persistentDataPath;
                    case RuntimePlatform.WindowsEditor:
                        return Application.dataPath.Substring(0, Application.dataPath.Length - "Assets/".Length);
                    default:
                        return Application.dataPath.Substring(0, Application.dataPath.Length - "Assets/".Length);
                }
            }
        }

        public static string GetstreamingAssetsPath
        {
            get
            {
                switch (Application.platform)
                {
                    case RuntimePlatform.IPhonePlayer:
                        return Application.streamingAssetsPath;
                    case RuntimePlatform.Android:
                        return Application.streamingAssetsPath;
                    case RuntimePlatform.WindowsPlayer:
                        return Application.streamingAssetsPath;
                    case RuntimePlatform.WindowsEditor:
                        return Application.streamingAssetsPath;
                    default:
                        return Application.streamingAssetsPath;
                }
            }
        }

        /// <summary>
        /// App外部根目录
        /// </summary>
        public static string AppLuaAddress
        {
            get
            {
#if UNITY_EDITOR
                return Path.Combine(Application.dataPath, "Resources");
#else
                return Path.Combine(PlatformRoot, mAppExternalAddress);
#endif
            }
        }


        public static string AppAssetBundleTemp
        {
            get
            {
                return Path.Combine(PlatformRoot, mAppResourcesTemp);
            }
        }

        public static string AppAssetBundleAddress
        {
            get
            {
                return Path.Combine(PlatformRoot, mAppExternalAddress);
            }
        }
    }
}

