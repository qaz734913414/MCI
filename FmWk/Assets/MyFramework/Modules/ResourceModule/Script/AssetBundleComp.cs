using UnityEngine;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.IO;

namespace MyFramework
{
    /// <summary>
    /// AssetBundle 加载方式
    /// </summary>
    public class AssetBundleComp : ModelCompBase<ResourceModel>
    {
        private Dictionary<string, Dictionary<string, AssetBundle>> Bundles;
        private Dictionary<string, Dictionary<string, UnityEngine.Object>> Assets;
        AppBuileInfo ResourceInfo;

        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            base.Load(_ModelContorl, _Agr);
            Bundles = new Dictionary<string, Dictionary<string, AssetBundle>>();
            Assets = new Dictionary<string, Dictionary<string, UnityEngine.Object>>();
            ResourceInfo = JsonConvert.DeserializeObject<AppBuileInfo>(FilesTools.ReadFileToStr(AppConfig.AppAssetBundleAddress + "/AssetInfo.json"));
            LoadEnd();
        }

        /// <summary>
        /// 加载资源文件
        /// </summary>
        /// <typeparam name="T">加载资源类型</typeparam>
        /// <param name="bundleOrPath">资源相对路径</param>
        /// <param name="assetName">资源名称</param>
        /// <param name="IsSave">是否保存</param>
        /// <returns></returns>
        public T LoadAsset<T>(string ModelName, string BundlePath, string AssetName) where T : UnityEngine.Object
        {
            string Key = string.Empty;
            if (AssetName != null)
                Key = BundlePath + "/" + AssetName;
            else
                Key = BundlePath;
            if (!Assets.ContainsKey(ModelName))
            {
                Assets[ModelName] = new Dictionary<string, UnityEngine.Object>();
            }
            if (Assets[ModelName].ContainsKey(Key))
            {
                return Assets[ModelName][Key] as T;
            }
            else
            {
                AssetBundle bundle = LoadAssetBundle(ModelName, BundlePath);
                if (bundle != null)
                {
                    T ret = null;
                    if (AssetName != null)
                        ret = bundle.LoadAsset<T>(GetAssetName(bundle, AssetName));
                    else
                        ret = bundle.LoadAllAssets<T>()[0];

                    if (null != ret)
                    {
                        Assets[ModelName][Key] = ret;
                        return ret;
                    }
                    else
                    {
                        LoggerHelper.Error("Asset文件不存在 ModelName = " + ModelName + " BundleName = " + BundlePath + " AssetName = " + AssetName);
                    }
                }
            }
            return null;
        }
        /// <summary>
        /// 加载bundle文件
        /// </summary>
        /// <param name="bundleName">bundle名称</param>
        /// <returns></returns>
        public AssetBundle LoadAssetBundle(string ModelName, string BundleName)
        {
            if (!Bundles.ContainsKey(ModelName))
            {
                Bundles[ModelName] = new Dictionary<string, AssetBundle>();
            }
            if (Bundles[ModelName].ContainsKey(BundleName))
            {
                return Bundles[ModelName][BundleName];
            }
            else
            {
                string bundlepath = (ModelName + "/" + BundleName + AppConfig.ResFileSuffix).ToLower();
                if (ResourceInfo.AppResInfo.ContainsKey(bundlepath))
                {
                    ResBuileInfo Resinfo = ResourceInfo.AppResInfo[bundlepath];
                    for (int i = 0; i < Resinfo.Dependencies.Length; i++)
                    {
                        string _modelname = Resinfo.Dependencies[i].Substring(0, Resinfo.Dependencies[i].IndexOf("/"));
                        string _bundlename = Resinfo.Dependencies[i].Substring(_modelname.Length + 1);
                        _bundlename = _bundlename.Substring(0, _bundlename.IndexOf("."));
                        LoadAssetBundle(_modelname, _bundlename);
                    }
                    string path = Path.Combine(AppConfig.AppAssetBundleAddress, bundlepath);
                    if (File.Exists(path))
                    {
                        Bundles[ModelName][BundleName] = AssetBundle.LoadFromFile(path);
                        return Bundles[ModelName][BundleName];
                    }
                    else
                    {
                        LoggerHelper.Error("Bundle文件不存在 ModelName = " + ModelName + " BundleName = " + BundleName);
                    }
                }
            }
            return null;
        }
        
        /// <summary>
        /// 获取资源名称
        /// </summary>
        /// <param name="bundle"></param>
        /// <param name="assetName"></param>
        /// <returns></returns>
        static string GetAssetName(AssetBundle bundle, string assetName)
        {
            if (assetName.IndexOf('/') >= 0)
            {
                if (assetName.IndexOf('.') >= 0)
                {
                    assetName = bundle.name + assetName;
                }
                else
                {
                    assetName = assetName.Substring(assetName.LastIndexOf('/') + 1);
                }
            }
            return assetName.ToLower();
        }



        public void UnloadAsset(string ModelName, string BundlePath, string AssetName)
        {
            if (Assets.ContainsKey(ModelName))
            {
                string Key = BundlePath + "/" + AssetName;
                if (Assets[ModelName].ContainsKey(Key))
                {
                    Resources.UnloadAsset(Assets[ModelName][Key]);
                }
                Assets[ModelName].Remove(Key);
            }
        }

        public void UnloadBundle(string ModelName, string BundleName)
        {
            if (Bundles.ContainsKey(ModelName))
            {
                if (Bundles[ModelName].ContainsKey(BundleName))
                {
                    Bundles[ModelName][BundleName].Unload(false);
                    Bundles[ModelName].Remove(BundleName);
                }
            }
        }

        public void UnloadModel(string ModelName)
        {
            if (Bundles.ContainsKey(ModelName))
            {
                foreach (var item in Bundles[ModelName])
                {
                    item.Value.Unload(true);
                }
                Bundles.Remove(ModelName);
            }
            if (Assets.ContainsKey(ModelName))
            {
                foreach (var item in Assets[ModelName])
                {
                    Resources.UnloadAsset(item.Value);
                }
                Assets.Remove(ModelName);
            }
        }

    }
}