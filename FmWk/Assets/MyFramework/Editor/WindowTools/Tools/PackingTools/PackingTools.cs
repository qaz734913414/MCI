using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace MyFramework.Tools
{
    public class PackingTools : CompositeTools
    {
        public PackingConfig Config;
        public PackingTools(EditorWindow _MyWindow)
            : base(_MyWindow)
        {
            string ConfigPath = Path.Combine(MyFramework.Tools.ToolsConfig.RelativeEditorResources, "PackingToolsSetting.asset");
            if (File.Exists(ConfigPath))
            {
                Config = AssetDatabase.LoadAssetAtPath(ConfigPath, typeof(PackingConfig)) as PackingConfig;
            }
            else
            {
                Config = new PackingConfig();
                AssetDatabase.CreateAsset(Config,ConfigPath);
            }
            Tools = new Dictionary<string, BaseTools>
            {
                { "资源编译", new AssetCompilation(_MyWindow,this)}
            };
        }

        public void AddNewResourceCatalog(string _Path)
        {
            ResourceCatalog mCatalog = new ResourceCatalog
            {
                Name = PathTools.GetPathFolderName(_Path),
                Path = _Path
            };
            Config.ResourceCatalog.Add(mCatalog);
            RetrievalModelResourceDirectory(mCatalog, mCatalog.Path);
            EditorUtility.SetDirty(Config);
        }

        public void RemoveResourceCatalog(string _Path)
        {
            for (int i = 0; i < Config.ResourceCatalog.Count; i++)
            {
                if (Config.ResourceCatalog[i].Path == _Path)
                {
                    RemoveResourceModelBuildConfig(Config.ResourceCatalog[i]);
                    Config.ResourceCatalog.RemoveAt(i);
                    return;
                }
            }
        }

        /// <summary>
        /// 检索模块资源目录
        /// </summary>
        /// <param name="_Path"></param>
        private void RetrievalModelResourceDirectory(ResourceCatalog _Catalog,string _Path)
        {
            string[] fileList = Directory.GetFileSystemEntries(_Path);
            foreach (string file in fileList)
            {
                if (Directory.Exists(file))
                {
                    if (file.EndsWith("Module"))
                    {
                        ResourceModelConfig ModelConfig = new ResourceModelConfig(_Catalog.Path, file);
                        if (ModelConfig.NodelType != ResourceBuildNodelType.UselessNodel)
                        {
                            AddResourceModelBuildConfig(ModelConfig);
                        }
                    }
                    else
                    {
                        RetrievalModelResourceDirectory(_Catalog, file);
                    }
                }
            }
        }

        /// <summary>
        /// 添加模块资源编译配置
        /// </summary>
        /// <param name="_Config"></param>
        private void AddResourceModelBuildConfig(ResourceModelConfig _Config)
        {
            for (int i = 0; i < Config.ModelBuildConfig.Count; i++)
            {
                if (Config.ModelBuildConfig[i].Name == _Config.Name)
                {
                    Config.ModelBuildConfig[i].MergeConfig(_Config);
                    return;
                }
            }
            Config.ModelBuildConfig.Add(_Config);
        }

        /// <summary>
        /// 移除关联的模块配置信息
        /// </summary>
        /// <param name="_Catalog"></param>
        private void RemoveResourceModelBuildConfig(ResourceCatalog _Catalog)
        {
            List<ResourceModelConfig> Temp = new List<ResourceModelConfig>();
            foreach (var item in Config.ModelBuildConfig)
            {
                item.SplitConfig(_Catalog.Path);
                if (item.NodelType == ResourceBuildNodelType.UselessNodel)
                {
                    Temp.Add(item);
                }
            }
            foreach (var item in Temp)
            {
                Config.ModelBuildConfig.Remove(item);
            }
        }

        /// <summary>
        /// 刷新模块列表
        /// </summary>
        public void RefreshModelConfig()
        {
            Config.ModelBuildConfig.Clear();
            foreach (var Item in Config.ResourceCatalog)
            {
                RetrievalModelResourceDirectory(Item, Item.Path);
            }
        }

        /// <summary>
        /// 编译资源模块
        /// </summary>
        public void BuildResourceModel()
        {
            BuildTarget BuildTargetPlatform = BuildTarget.StandaloneWindows;
            switch (Config.BuildPlatform)
            {
                case AppPlatform.Android:
                    BuildTargetPlatform = BuildTarget.Android;
                    break;
                case AppPlatform.IOS:
                    BuildTargetPlatform = BuildTarget.iOS;
                    break;
                case AppPlatform.Windows:
                    BuildTargetPlatform = BuildTarget.StandaloneWindows;
                    break;
                default:
                    BuildTargetPlatform = BuildTarget.StandaloneWindows;
                    break;
            }
            AppBuileInfo BuildInfo = new AppBuileInfo();
            foreach (var item in Config.ModelBuildConfig)
            {
                if (item.IsSelection)
                {
                    RetrievalResourceBuildInfo(item, ref BuildInfo);
                }
            }
            AssetBundleBuild[] builds = new AssetBundleBuild[BuildInfo.AppResInfo.Count];
            List<string> BuilderKeys = new List<string>(BuildInfo.AppResInfo.Keys);
            for (int i = 0; i < BuilderKeys.Count; i++)
            {
                builds[i] = new AssetBundleBuild
                {
                    assetBundleName = BuilderKeys[i],
                    assetNames = BuildInfo.AppResInfo[BuilderKeys[i]].Assets.ToArray()
                };
            }
            AssetBundleManifest BundleInfo = BuildPipeline.BuildAssetBundles(Config.ResourceOutPath, builds, BuildAssetBundleOptions.None, BuildTargetPlatform);
            if (BundleInfo != null)
            {
                WriteAppBuilderInfo(BundleInfo, BuildInfo);
                FilesTools.ClearDirFile(Config.ResourceOutPath, new string[] { AppConfig.ResFileSuffix, ".json" });
                AssetDatabase.Refresh();
            }else {
                LoggerHelper.Error("卧槽哦，啥逼情况啊");
            }
 
        }

        private void RetrievalResourceBuildInfo(ResourceItemConfig _Item, ref AppBuileInfo _BuildInfo)
        {
            string AssetBundleName = _Item.AssetBundleName.ToLower() + AppConfig.ResFileSuffix;
            if (!_BuildInfo.AppResInfo.ContainsKey(AssetBundleName))
            {
                _BuildInfo.AppResInfo[AssetBundleName] = new ResBuileInfo
                {
                    Id = AssetBundleName,
                    Model = _Item.ModelName,
                    Assets = new List<string>()
                };
            }
            if (_Item.NodelType == ResourceBuildNodelType.ResourcesItemNodel)
            {
                _BuildInfo.AppResInfo[AssetBundleName].Assets.Add(_Item.Path.Substring(AppConfig.PlatformRoot.Length + 1));
            }
            else
            {
                foreach (var item in _Item.ChildBuildItem)
                {
                    RetrievalResourceBuildInfo(item, ref _BuildInfo);
                }
            }
        }

        public void WriteAppBuilderInfo(AssetBundleManifest BundleManifest, AppBuileInfo BuildInfo)
        {
            string[] AssetBundles = BundleManifest.GetAllAssetBundles();
            for (int i = 0; i < AssetBundles.Length; i++)
            {
                if (BuildInfo.AppResInfo.ContainsKey(AssetBundles[i]))
                {
                    ResBuileInfo BuildeInfo = BuildInfo.AppResInfo[AssetBundles[i]];
                    FileInfo fiInput = new FileInfo(Config.ResourceOutPath + "/" + BuildeInfo.Id);
                    BuildeInfo.Size = fiInput.Length / 1024.0f;
                    BuildeInfo.Md5 = BundleManifest.GetAssetBundleHash(AssetBundles[i]).ToString();
                    BuildeInfo.IsNeedUpdata = false;
                    string[] Dependencie = BundleManifest.GetDirectDependencies(AssetBundles[i]);
                    BuildeInfo.Dependencies = new string[Dependencie.Length];
                    for (int n = 0; n < Dependencie.Length; n++)
                    {
                        BuildeInfo.Dependencies[n] = Dependencie[n];
                    }
                }
                else
                {
                    LoggerHelper.Error("No AssetBundles Key=" + AssetBundles[i]);
                }

            }
            string Json = JsonConvert.SerializeObject(BuildInfo);
            FilesTools.WriteStrToFile(Config.ResourceOutPath + "/AssetInfo.json", Json);
        }
    }
}