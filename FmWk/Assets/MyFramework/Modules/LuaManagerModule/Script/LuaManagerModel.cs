using System.IO;
using LuaInterface;
using UnityEngine;
using System;

namespace MyFramework
{
    public class LuaManagerModel : ManagerContorBase<LuaManagerModel>
    {
        protected LuaState lua;
        private LuaManagerModelFileComp FileComp;

        #region 框架接口
        public LuaManagerModel()
        {
            DetectionLocalVersion();
            lua = new LuaState();
            FileComp = AddComp<LuaManagerModelFileComp>();
        }

        /// <summary>
        /// 校验App版本是否有效
        /// </summary>
        public void DetectionLocalVersion()
        {
            if (AppConfig.AppResModel == AppResModel.AssetBundleModel)
            {
                if (!PlayerPrefs.HasKey("Configuration" + Application.version))
                {
                    FilesTools.CopyDirFile(Application.streamingAssetsPath, AppConfig.AppAssetBundleAddress);
                    PlayerPrefs.SetInt("Configuration" + Application.version, 1);
                }
            }
        }

        public override void Load(params object[] _Agr)
        {
            lua.LuaSetTop(0);
            LuaBinder.Bind(lua);
            OpenLibs();
            DelegateFactory.Init();
            LuaCoroutine.Register(lua, Manager_ManagerModel.Instance);
            base.Load(_Agr);
        }
        #region lua第三方插件

        /// <summary>
        /// 初始化加载第三方库
        /// </summary>
        public void OpenLibs()
        {
            lua.OpenLibs(LuaDLL.luaopen_pb);
            lua.OpenLibs(LuaDLL.luaopen_struct);
            lua.OpenLibs(LuaDLL.luaopen_lpeg);
#if UNITY_STANDALONE_OSX || UNITY_EDITOR_OSX
        luaState.OpenLibs(LuaDLL.luaopen_bit);
#endif
            if (LuaConst.openLuaSocket)
            {
                OpenLuaSocket();
            }

            if (LuaConst.openLuaDebugger)
            {
                OpenZbsDebugger();
            }
            OpenCJson();

        }

        //cjson 比较特殊，只new了一个table，没有注册库，这里注册一下
        protected void OpenCJson()
        {
            lua.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
            lua.OpenLibs(LuaDLL.luaopen_cjson);
            lua.LuaSetField(-2, "cjson");

            lua.OpenLibs(LuaDLL.luaopen_cjson_safe);
            lua.LuaSetField(-2, "cjson.safe");
        }

        protected void OpenLuaSocket()
        {
            LuaConst.openLuaSocket = true;

            lua.BeginPreLoad();
            lua.RegFunction("socket.core", LuaOpen_Socket_Core);
            lua.RegFunction("mime.core", LuaOpen_Mime_Core);
            lua.EndPreLoad();
        }

        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int LuaOpen_Socket_Core(IntPtr L)
        {
            return LuaDLL.luaopen_socket_core(L);
        }

        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int LuaOpen_Mime_Core(IntPtr L)
        {
            return LuaDLL.luaopen_mime_core(L);
        }


        public void OpenZbsDebugger(string ip = "localhost")
        {
            if (!Directory.Exists(LuaConst.zbsDir))
            {
                Debugger.LogWarning("ZeroBraneStudio not install or LuaConst.zbsDir not right");
                return;
            }

            if (!LuaConst.openLuaSocket)
            {
                OpenLuaSocket();
            }

            if (!string.IsNullOrEmpty(LuaConst.zbsDir))
            {
                lua.AddSearchPath(LuaConst.zbsDir);
            }

            lua.LuaDoString(string.Format("DebugServerIp = '{0}'", ip), "@LuaClient.cs");
        }

        #endregion

        public override void Start(params object[] _Agr)
        {
            AddLuaModel("LuaManagerModel");
            DoFile("ToLua/tolua");
            lua.Start();
            base.Start(_Agr);
            DoFile("Main");
        }
        public override void Close()
        {
            RemoveLuaModel("LuaManagerModel");
            lua.LuaClose();
            base.Close();
        }
        #endregion

        public void AddLuaModel(string ModelName)
        {
            FileComp.AddLuaModel(ModelName);
        }

        public void RemoveLuaModel(string ModelName)
        {
            FileComp.AddLuaModel(ModelName);
        }

        public string FindFile(string ModelFileName)
        {
            return FileComp.FindFile(ModelFileName);
        }

        public byte[] ReadFile(string ModelFileName)
        {
            return FileComp.ReadFile(ModelFileName);
        }

        public void DoFile(string ModelName,string FileName)
        {
            if (State == ModelBaseState.Start)
            {
                byte[] buffer = FileComp.ReadFile(ModelName, FileName);
                if (buffer != null)
                {
                    lua.LuaLoadBuffer(buffer, Path.Combine(ModelName, FileName));
                }
            }
            else
            {
                LoggerHelper.Error("LuaManagerModelControl No Start:" + Path.Combine(ModelName, FileName));
            }
        }

        private void DoFile(string FileName)
        {
            byte[] buffer = FileComp.ReadFile("LuaManagerModel", FileName);
            if (buffer != null)
            {
                lua.LuaLoadBuffer(buffer, Path.Combine("LuaManagerModel", FileName));
            }
        }


        public LuaTable GetTable(string fullPath)
        {
            return lua.GetTable(fullPath);
        }
        public LuaFunction GetFunction(string fullPath)
        {
            return lua.GetFunction(fullPath);
        }

    }
}
