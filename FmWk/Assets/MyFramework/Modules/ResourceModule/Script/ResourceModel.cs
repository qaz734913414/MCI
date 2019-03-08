
namespace MyFramework
{
    /// <summary>
    /// 资源管理模块
    /// </summary>
    public class ResourceModel : ManagerContorBase<ResourceModel>
    {
        private AssetBundleComp BundleResComp;
#if UNITY_EDITOR
        private EditorResourComp EditorResComp;
#endif
        public override void Load(params object[] _Agr)
        {
            BundleResComp = AddComp<AssetBundleComp>();
#if UNITY_EDITOR
            EditorResComp = AddComp<EditorResourComp>();
#endif
            base.Load(_Agr);
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
            if (AppConfig.AppResModel == AppResModel.AssetBundleModel)
            {
                return BundleResComp.LoadAsset<T>(ModelName, BundlePath, AssetName);
            }
            else
            {
#if UNITY_EDITOR
                return EditorResComp.LoadAsset<T>(ModelName, BundlePath, AssetName);
#else
                return null;
#endif
            }
        }
        #region 清除资源
        public void UnloadAsset(string ModelName,string BundlePath,string AssetName)
        {
            if (AppConfig.AppResModel == AppResModel.AssetBundleModel)
            {
                BundleResComp.UnloadAsset(ModelName, BundlePath, AssetName);
            }
            else
            {
#if UNITY_EDITOR
                EditorResComp.UnloadAsset(ModelName, BundlePath, AssetName);
#endif
            }

        }

        public void UnloadBundle(string ModelName, string BundleName)
        {
            BundleResComp.UnloadBundle(ModelName, BundleName);
        }

        public void UnloadModel(string ModelName)
        {
            if (AppConfig.AppResModel == AppResModel.AssetBundleModel)
            {
                BundleResComp.UnloadModel(ModelName);
            }
            else
            {
#if UNITY_EDITOR
                EditorResComp.UnloadModel(ModelName);
#endif
            }

        }

#endregion

    }
}
