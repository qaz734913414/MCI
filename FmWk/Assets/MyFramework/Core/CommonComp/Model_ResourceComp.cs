using UnityEngine;
using System.Collections.Generic;
using System;
using System.IO;

namespace MyFramework
{ 
    /// <summary>
    /// 模块资源组件
    /// </summary>
    public class Model_ResourceComp : ModelCompBase
    {
        #region 构架
        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)                                           
        {
            base.Load(_ModelContorl);
            base.LoadEnd();
        }
        public override void Close()
        {
            if(ResourceModel.Instance != null)
                ResourceModel.Instance.UnloadModel(MyCentorl.ModelName);
            base.Close();
        }
        #endregion

        public T LoadAsset<T>(string BundleName, string AssetName) where T : UnityEngine.Object
        {
            string ModelName = MyCentorl.ModelName;
            if (AppConfig.AppResModel == AppResModel.AssetBundleModel)
            {
                ModelName = ModelName.ToLower();
                BundleName = BundleName.ToLower();
                if (AssetName != null)
                    AssetName = AssetName.ToLower();
            }
            if (ResourceModel.Instance != null)
            {
                return ResourceModel.Instance.LoadAsset<T>(MyCentorl.ModelName, BundleName, AssetName);
            }
            else
            {
                LoggerHelper.Error("ResourceModel No Load");
                return null;
            }
        }

        public void UnloadAsset(string BundleName, string AssetName)
        {
            string ModelName = MyCentorl.ModelName;
            if (AppConfig.AppResModel == AppResModel.AssetBundleModel)
            {
                ModelName = ModelName.ToLower();
                BundleName = BundleName.ToLower();
                AssetName = AssetName.ToLower();
            }
            ResourceModel.Instance.UnloadAsset(MyCentorl.ModelName, BundleName, AssetName);
        }

        public void UnloadBundle(string BundleName)
        {
            string ModelName = MyCentorl.ModelName;
            if (AppConfig.AppResModel == AppResModel.AssetBundleModel)
            {
                ModelName = ModelName.ToLower();
                BundleName = BundleName.ToLower();
            }
            ResourceModel.Instance.UnloadBundle(MyCentorl.ModelName, BundleName);
        }

    }
}
