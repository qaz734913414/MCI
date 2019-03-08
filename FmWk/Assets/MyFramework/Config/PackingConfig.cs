using UnityEngine;
using System.Collections.Generic;
using System.IO;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace MyFramework.Tools
{
    public enum ResourceBuildNodelType
    {
        UselessNodel,            //无用文件
        ModelNodel,              //模块节点
        FolderNodel,             //文件夹节点
        ResourcesItemNodel,      //资源文件节点
    }

    [System.Serializable]
    public class ResourceCatalog
    {
        public string Name;
        public string Path;
    }

    [System.Serializable]
    public class ResourceModelConfig : ResourceItemConfig
    {
        public bool IsSelection = true;
        public ResourceModelConfig(string _RootName, string _Path)
            :base(_RootName,null,_Path)
        {
            if (NodelType == ResourceBuildNodelType.FolderNodel)
            {
                NodelType = ResourceBuildNodelType.ModelNodel;
                AssetBundleName = Name;
                ModelName = Name;
                RefreshChildViewGUI();
            }
        }

        public void MergeConfig(ResourceModelConfig _Other)
        {
            foreach (var item1 in _Other.ChildBuildItem)
            {
                bool IsKeep = false;
                foreach (var item2 in ChildBuildItem)
                {
                    if (item1.Name == item2.Name)
                    {
                        item2.MergeConfig(item1);
                        IsKeep = true;
                        break;
                    }
                }
                if (!IsKeep)
                {
                    ChildBuildItem.Add(item1);
                }
            }
        }

        public override void OnGUI()
        {
#if UNITY_EDITOR
            EditorGUILayout.BeginHorizontal(GUILayout.ExpandWidth(true));
            EditorGUI.indentLevel = Layer;
            IsSelection = EditorGUILayout.Toggle(IsSelection, GUILayout.Width(10));
            Foldout = EditorGUILayout.Foldout(Foldout, Name);
            EditorGUILayout.Space();
            bool mIsMergeBuild = GUILayout.Toggle(IsMergeBuild, "合并");
            if (mIsMergeBuild != IsMergeBuild)
            {
                IsMergeBuild = mIsMergeBuild;
                RefreshChildViewGUI();
            }
            EditorGUILayout.EndHorizontal();
            if (Foldout)
            {
                foreach (var item in ChildBuildItem)
                {
                    item.OnGUI();
                }
            }
#endif
        }
    }

    [System.Serializable]
    public class ResourceItemConfig
    {
        public string Name;
        public string Path;
        public string RootName;
        public string ModelName;
        public string AssetBundleName;
        public int Layer;
        public ResourceBuildNodelType NodelType;
        public AssetCheckMode UpdateMode;
        public bool Foldout = false;
        public bool IsMergeBuild = true;
        public bool IsShowBuildToogle = true;
        public List<ResourceItemConfig> ChildBuildItem;

        public ResourceItemConfig(string _RootName, ResourceItemConfig _Parent, string _Path)
        {
            RootName = _RootName;
            Path = _Path;
            Name = PathTools.GetPathFolderName(Path);
            ModelName = _Parent == null ? ModelName : _Parent.ModelName;
            Layer = _Parent == null ? 0 : _Parent.Layer + 1; 
            ChildBuildItem = new List<ResourceItemConfig>();
            if (PathTools.IsDirectory(Path))
            {
                string[] fileList = Directory.GetFileSystemEntries(Path);
                foreach (string file in fileList)
                {
                    ResourceItemConfig Item = new ResourceItemConfig(RootName,this,file);
                    if (Item.NodelType != ResourceBuildNodelType.UselessNodel)
                    {
                        ChildBuildItem.Add(Item);
                    }
                }
                if (ChildBuildItem.Count > 0)
                {
                    NodelType = ResourceBuildNodelType.FolderNodel;

                }
                else
                {
                    NodelType = ResourceBuildNodelType.UselessNodel;
                }
            }
            else
            {
                if (PathTools.CheckSuffix(Path, ToolsConfig.CanBuildFileTypes))
                {
                    Name = Name.Substring(0, Name.IndexOf("."));
                    NodelType = ResourceBuildNodelType.ResourcesItemNodel;
                }
                else
                {
                    NodelType = ResourceBuildNodelType.UselessNodel;
                }
            }
        }

        /// <param name="_Other"></param>
        public void MergeConfig(ResourceItemConfig _Other)
        {
            foreach (var item1 in _Other.ChildBuildItem)
            {
                bool IsKeep = false;
                foreach (var item2 in ChildBuildItem)
                {
                    if (item1.Name == item2.Name)
                    {
                        item2.MergeConfig(item1);
                        IsKeep = true;
                        break;
                    }
                }
                if (!IsKeep)
                {
                    ChildBuildItem.Add(item1);
                }
            }
        }

        /// <summary>
        /// 拆分资源列表
        /// </summary>
        /// <param name="RootName"></param>
        public void SplitConfig(string RootName)
        {
            List<ResourceItemConfig> Tmp = new List<ResourceItemConfig>();
            foreach (var item in ChildBuildItem)
            {
                if (item.NodelType == ResourceBuildNodelType.ResourcesItemNodel && item.RootName == RootName)
                {
                    Tmp.Add(item);
                }
                else
                {
                    if (item.NodelType == ResourceBuildNodelType.FolderNodel || item.NodelType == ResourceBuildNodelType.ModelNodel)
                    {
                        item.SplitConfig(RootName);
                        if (item.NodelType == ResourceBuildNodelType.UselessNodel)
                        {
                            Tmp.Add(item);
                        }
                    }

                }
            }
            foreach (var item in Tmp)
            {
                ChildBuildItem.Remove(item);
            }
            if (ChildBuildItem.Count == 0)
            {
                NodelType = ResourceBuildNodelType.UselessNodel;
            }
        }

        public void RefreshViewGUI(ResourceItemConfig Parent)
        {
            if (Parent.IsShowBuildToogle && !Parent.IsMergeBuild)
            {
                IsShowBuildToogle = true;
                IsMergeBuild = true;
                AssetBundleName = Parent.AssetBundleName +"/"+ Name;
            }
            else
            {
                IsShowBuildToogle = false;
                AssetBundleName = Parent.AssetBundleName;
            }
            RefreshChildViewGUI();
        }

        public void RefreshChildViewGUI()
        {
            foreach (var item in ChildBuildItem)
            {
                item.RefreshViewGUI(this);
            }
        }

        public virtual void OnGUI()
        {
#if UNITY_EDITOR
            EditorGUILayout.BeginHorizontal(GUILayout.ExpandWidth(true));
            EditorGUI.indentLevel = Layer;
            if (NodelType == ResourceBuildNodelType.FolderNodel)
            {
                Foldout = EditorGUILayout.Foldout(Foldout, Name);
                EditorGUILayout.Space();
                if (IsShowBuildToogle)
                {
                    bool mIsMergeBuild = GUILayout.Toggle(IsMergeBuild, "合并");
                    if (mIsMergeBuild != IsMergeBuild)
                    {
                        IsMergeBuild = mIsMergeBuild;
                        RefreshChildViewGUI();
                    }
                }
            }
            else
            {
                EditorGUILayout.LabelField(Name);
                EditorGUILayout.Space();
                if (IsShowBuildToogle)
                {
                    IsMergeBuild = GUILayout.Toggle(IsMergeBuild, "打包");
                }
            }
            EditorGUILayout.EndHorizontal();
            if (Foldout)
            {
                foreach (var item in ChildBuildItem)
                {
                    item.OnGUI();
                }
            }
#endif
        }
    }

    public class PackingConfig : ScriptableObject
    {
        public AppPlatform BuildPlatform;
        public string ResourceOutPath;
        public List<ResourceCatalog> ResourceCatalog;
        public List<ResourceModelConfig> ModelBuildConfig;

        public PackingConfig()
        {
            BuildPlatform = AppPlatform.Windows;
            ResourceOutPath = "";
            ResourceCatalog = new List<ResourceCatalog>();
            ModelBuildConfig = new List<ResourceModelConfig>();
        }
    }
}