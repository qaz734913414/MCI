using UnityEngine;

namespace MyFramework
{
    public abstract class Main : MonoBehaviour
    {
        [MFWAttributeRename("App资源加载方式")]
        public AppResModel AppResModel;
        protected virtual void SetConfig()
        {
            AppConfig.AppResModel = AppResModel;
        }

        protected virtual void StartApp()
        {
            Manager_ManagerModel.Instance.StartModel<ResourceModel>();
        }
    }
}

