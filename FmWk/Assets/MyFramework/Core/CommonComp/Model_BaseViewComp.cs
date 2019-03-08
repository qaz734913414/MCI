using UnityEngine;

namespace MyFramework
{
    /// <summary>
    /// 模块界面基础组件
    /// </summary>
    public abstract class Model_BaseViewComp : ModelCompBase
    {
        protected UILevel ShowLevel = UILevel.LowUI;
        public GameObject UIGameobject;
        #region 框架构造
        /// <summary>
        /// 基础界面组件
        /// </summary>
        /// <param name="_ModelContorl"></param>
        /// <param name="_Agr">第一个参数 资源根路径</param>
        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            base.Load(_ModelContorl);
            string PrefabName = (string)_Agr[0];
            GameObject UIRoot = null;
            switch (ShowLevel)
            {
                case UILevel.LowUI:
                    UIRoot = ViewManagerModel.Instance.LowUIRoot;
                    break;
                case UILevel.NormalUI:
                    UIRoot = ViewManagerModel.Instance.NormalUIRoot;
                    break;
                case UILevel.HightUI:
                    UIRoot = ViewManagerModel.Instance.HightUIRoot;
                    break;
            }
            UIGameobject = MyCentorl.CreateObj("Prefab", PrefabName,UIRoot);
            RectTransform rectTrans = UIGameobject.GetComponent<RectTransform>();
            rectTrans.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 0, 0);
            rectTrans.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Top, 0, 0);
            rectTrans.anchorMin = Vector2.zero;
            rectTrans.anchorMax = Vector2.one;
        }

        public override void Close()
        {
            GameObject.Destroy(UIGameobject);
            base.Close();
        }
        #endregion

        public void Show()
        {
            UIGameobject.SetActive(true);
        }

        public void Hide()
        {
            UIGameobject.SetActive(false);
        }
    }


    /// <summary>
    /// 模块界面基础组件
    /// </summary>
    public class Model_BaseViewComp<C> : ModelCompBase<C> where C: ModelContorlBase, new()
    {
        protected UILevel ShowLevel = UILevel.LowUI;
        public GameObject UIGameobject;
        #region 框架构造
        /// <summary>
        /// 基础界面组件
        /// </summary>
        /// <param name="_ModelContorl"></param>
        /// <param name="_Agr">第一个参数 资源根路径</param>
        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            base.Load(_ModelContorl);
            string PrefabName = (string)_Agr[0];
            GameObject UIRoot = null;
            switch (ShowLevel)
            {
                case UILevel.LowUI:
                    UIRoot = ViewManagerModel.Instance.LowUIRoot;
                    break;
                case UILevel.NormalUI:
                    UIRoot = ViewManagerModel.Instance.NormalUIRoot;
                    break;
                case UILevel.HightUI:
                    UIRoot = ViewManagerModel.Instance.HightUIRoot;
                    break;
            }
            UIGameobject = MyCentorl.CreateObj("Prefab", PrefabName, UIRoot);
            if (UIGameobject != null)
            {
                RectTransform rectTrans = UIGameobject.GetComponent<RectTransform>();
                rectTrans.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Left, 0, 0);
                rectTrans.SetInsetAndSizeFromParentEdge(RectTransform.Edge.Top, 0, 0);
                rectTrans.anchorMin = Vector2.zero;
                rectTrans.anchorMax = Vector2.one;
            }
            else
            {
                LoggerHelper.Error("ViewComp Load Error:Model"+MyCentorl.ModelName +"; View:"+ PrefabName);
            }
        }

        public override void Close()
        {
            GameObject.Destroy(UIGameobject);
            base.Close();
        }
        #endregion

        public void Show()
        {
            UIGameobject.SetActive(true);
        }

        public void Hide()
        {
            UIGameobject.SetActive(false);
        }
    }

}
