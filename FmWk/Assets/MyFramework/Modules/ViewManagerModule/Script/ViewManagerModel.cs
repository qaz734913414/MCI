

using UnityEngine;

namespace MyFramework
{
    public enum UILevel
    {
        LowUI,                  //一般用于app的业务逻辑界面
        NormalUI,               //一般用于比业务逻辑界面高一级的弹出框类似界面
        HightUI,                //一般用于类似与退出游街的弹窗界面
    }

    public class ViewManagerModel : ManagerContorBase<ViewManagerModel>
    {
        private GameObject mUIRoot;
        private GameObject mLowUIRoot;                //底优先级显示节点
        private GameObject mNormalUIRoot;             //中优先级显示节点
        private GameObject mHightUIRoot;              //高优先级显示节点
        private Vector2 mViewSzie;                    //UI界面尺寸
        private float mMatch;                         //UI适配权重

        public GameObject LowUIRoot
        {
            get { return mLowUIRoot; }
        }

        public GameObject NormalUIRoot
        {
            get { return mNormalUIRoot; }
        }

        public GameObject HightUIRoot
        {
            get { return mHightUIRoot; }
        }

        public Vector2 ViewSzie
        {
            get { return mViewSzie; }
        }

        public override void Load(params object[] _Agr)
        {
            if (_Agr.Length == 2)
            {
                mViewSzie = (Vector2)_Agr[0];
                mMatch = (float)_Agr[1];
                CreateUIRoot();
            }
            else
            {
                LoggerHelper.Debug("ViewManagerModel 启动参数错误，请检查代码");
            }
            
            base.Load(_Agr);
        }

        private void CreateUIRoot()
        {
            mUIRoot = new GameObject("UIRoot");
            GameObject.DontDestroyOnLoad(mUIRoot);
            mLowUIRoot = mUIRoot.CreateChild("LowUIRoot", typeof(Canvas), typeof(UnityEngine.UI.CanvasScaler), typeof(UnityEngine.UI.GraphicRaycaster));
            Camera _cm0 = mLowUIRoot.CreateChild("Camera", typeof(Camera)).GetComponent<Camera>();
            _cm0.orthographic = true;
            _cm0.clearFlags = CameraClearFlags.Depth;
            _cm0.nearClipPlane = -100;
            _cm0.farClipPlane = 100;
            _cm0.orthographicSize = 20;
            Canvas _ca0 = mLowUIRoot.GetComponent<Canvas>();
            _ca0.renderMode = RenderMode.ScreenSpaceCamera;
            _ca0.worldCamera = _cm0;
            _ca0.sortingOrder = 0;
            UnityEngine.UI.CanvasScaler _cs0 = mLowUIRoot.GetComponent<UnityEngine.UI.CanvasScaler>();
            _cs0.uiScaleMode = UnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize;
            _cs0.referenceResolution = mViewSzie;
            //_cs0.screenMatchMode = UnityEngine.UI.CanvasScaler.ScreenMatchMode.Expand;
            _cs0.matchWidthOrHeight = mMatch;

            mNormalUIRoot = mUIRoot.CreateChild("NormalUIRoot", typeof(Canvas), typeof(UnityEngine.UI.CanvasScaler), typeof(UnityEngine.UI.GraphicRaycaster));
            Camera _cm1 = mNormalUIRoot.CreateChild("Camera", typeof(Camera)).GetComponent<Camera>();
            _cm1.orthographic = true;
            _cm1.clearFlags = CameraClearFlags.Depth;
            _cm1.nearClipPlane = -100;
            _cm1.farClipPlane = 100;
            _cm1.orthographicSize = 20;
            Canvas _ca1 = mNormalUIRoot.GetComponent<Canvas>();
            _ca1.renderMode = RenderMode.ScreenSpaceCamera;
            _ca1.worldCamera = _cm1;
            _ca1.sortingOrder = 1;
            UnityEngine.UI.CanvasScaler _cs1 = mNormalUIRoot.GetComponent<UnityEngine.UI.CanvasScaler>();
            _cs1.uiScaleMode = UnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize;
            _cs1.referenceResolution = mViewSzie;
           // _cs1.screenMatchMode = UnityEngine.UI.CanvasScaler.ScreenMatchMode.Expand;
            _cs1.matchWidthOrHeight = mMatch;


            mHightUIRoot = mUIRoot.CreateChild("HightUIRoot", typeof(Canvas), typeof(UnityEngine.UI.CanvasScaler), typeof(UnityEngine.UI.GraphicRaycaster));
            Camera _cm2 = mHightUIRoot.CreateChild("Camera", typeof(Camera)).GetComponent<Camera>();
            _cm2.orthographic = true;
            _cm2.clearFlags = CameraClearFlags.Depth;
            _cm2.nearClipPlane = -100;
            _cm2.farClipPlane = 100;
            _cm2.orthographicSize = 20;
            Canvas _ca2 = mHightUIRoot.GetComponent<Canvas>();
            _ca2.renderMode = RenderMode.ScreenSpaceCamera;
            _ca2.worldCamera = _cm2;
            _ca2.sortingOrder = 2;
            UnityEngine.UI.CanvasScaler _cs2 = mHightUIRoot.GetComponent<UnityEngine.UI.CanvasScaler>();
            _cs2.uiScaleMode = UnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize;
            _cs2.referenceResolution = mViewSzie;
            //_cs2.screenMatchMode = UnityEngine.UI.CanvasScaler.ScreenMatchMode.Expand;
            _cs2.matchWidthOrHeight = mMatch;

            GameObject EventSystem = mUIRoot.CreateChild("EventSystem", typeof(UnityEngine.EventSystems.EventSystem), typeof(UnityEngine.EventSystems.StandaloneInputModule));
        }
    }
}
