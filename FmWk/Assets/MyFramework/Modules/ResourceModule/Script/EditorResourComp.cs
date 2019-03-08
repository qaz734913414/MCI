#if UNITY_EDITOR
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using MyFramework.Tools;

namespace MyFramework
{
    public class EditorResourComp : ModelCompBase<ResourceModel>
    {
        private Dictionary<string, Dictionary<string, UnityEngine.Object>> Assets;
        public PackingConfig Config; 
        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            base.Load(_ModelContorl, _Agr);
            Assets = new Dictionary<string, Dictionary<string, Object>>();
            string ConfigPath = Path.Combine(ToolsConfig.RelativeEditorResources, "PackingToolsSetting.asset");
            Config = AssetDatabase.LoadAssetAtPath<PackingConfig>(ConfigPath);
            if (Config == null)
            {
                LoggerHelper.Error("资源编译配置文件没有生成 PackingConfig = null");
            }
            LoadEnd();
        }

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
                for (int i = 0; i < Config.ResourceCatalog.Count; i++)
                {
                    string _Path = Path.Combine(Config.ResourceCatalog[i].Path, ModelName + "/" + BundlePath);
                    if (PathTools.IsDirectory(_Path))
                    {
                        string FileName = GetAssetPathToPath(_Path, AssetName);
                        if (FileName != string.Empty)
                        {
                            T obj = AssetDatabase.LoadAssetAtPath<T>(FileName);
                            return obj;
                        }
                    }
                }
            }
            return null;
        }

        /// <summary>
        /// 獲取目錄下的資源文件
        /// </summary>
        /// <param name="_Directory"></param>
        /// <param name="_FileName"></param>
        /// <returns></returns>
        private string GetAssetPathToPath(string _Directory, string _FileName)
        {
            string[] fileList = Directory.GetFileSystemEntries(_Directory);
            foreach (string file in fileList)
            {
                if (File.Exists(file))
                {
                    string FileName = PathTools.GetPathFolderName(file);
                    FileName = FileName.Substring(0, FileName.IndexOf("."));
                    if (FileName == _FileName)
                    {
                        return file.Substring(Application.dataPath.Length - "Assets".Length); ;
                    }
                }
            }
            return string.Empty;
        }


        #region 卸載資源

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

        public void UnloadModel(string ModelName)
        {
            if (Assets.ContainsKey(ModelName))
            {
                foreach (var item in Assets[ModelName])
                {
                    Resources.UnloadAsset(item.Value);
                }
                Assets.Remove(ModelName);
            }
        }

        #endregion
    }
}
#endif