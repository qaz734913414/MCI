local ViewManagerModel = Class.define("ViewManagerModel",BaseModel)


function ViewManagerModel:New(_csobj)
	self:super(ViewManagerModel,"New", _csobj);
    self.mUIRoot = nil
    self.mLowUIRoot = nil                --//底优先级显示节点
    self.mNormalUIRoot = nil            --//中优先级显示节点
    self.mHightUIRoot = nil              --//高优先级显示节点
    self.mViewSzie = nil                 --//UI界面尺寸
    self.mMatch = nil                    --//UI适配权重
end

function ViewManagerModel:getter_LowUIRoot()
    return self.mLowUIRoot;
end
function ViewManagerModel:getter_NormalUIRoot()
    return self.mNormalUIRoot;
end
function ViewManagerModel:getter_HightUIRoot()
    return self.mHightUIRoot;
end
function ViewManagerModel:getter_ViewSzie()
    return self.mViewSzie;
end

function ViewManagerModel:Load(agr1,agr2)
	self.mViewSzie = agr1
	self.mMatch = agr2
	self:CreateUIRoot();
	self:super(ViewManagerModel,"Load",nil);
end

function ViewManagerModel:Close()
    GameObject.Destroy(self.mUIRoot);
end

function ViewManagerModel:CreateUIRoot()
    self.mUIRoot = GameObject.New("UIRoot");
    GameObject.DontDestroyOnLoad(self.mUIRoot);
    self.mLowUIRoot = CommonTools.CreateChild(self.mUIRoot,"LowUIRoot", typeof(UnityEngine.Canvas), typeof(UnityEngine.UI.CanvasScaler), typeof(UnityEngine.UI.GraphicRaycaster));
    local _cm0 = CommonTools.CreateChild(self.mLowUIRoot,"Camera", typeof(Camera)):GetComponent("Camera");
    _cm0.orthographic = true;
    _cm0.clearFlags = UnityEngine.CameraClearFlags.Depth;
    _cm0.nearClipPlane = -100;
    _cm0.farClipPlane = 100;
    _cm0.orthographicSize = 20;
    local _ca0 = self.mLowUIRoot:GetComponent("Canvas");
    _ca0.renderMode = UnityEngine.RenderMode.ScreenSpaceCamera;
    _ca0.worldCamera = _cm0;
    _ca0.sortingOrder = 0;
    local _cs0 = self.mLowUIRoot:GetComponent("CanvasScaler");
    _cs0.uiScaleMode = UnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize;
    _cs0.referenceResolution = self.mViewSzie;
    _cs0.matchWidthOrHeight = self.mMatch;


    self.mNormalUIRoot = CommonTools.CreateChild(self.mUIRoot,"NormalUIRoot", typeof(UnityEngine.Canvas), typeof(UnityEngine.UI.CanvasScaler), typeof(UnityEngine.UI.GraphicRaycaster));
    local _cm1 = CommonTools.CreateChild(self.mNormalUIRoot,"Camera", typeof(Camera)):GetComponent("Camera");
    _cm1.orthographic = true;
    _cm1.clearFlags = UnityEngine.CameraClearFlags.Depth;
    _cm1.nearClipPlane = -100;
    _cm1.farClipPlane = 100;
    _cm1.orthographicSize = 20;
    local _ca1 = self.mNormalUIRoot:GetComponent("Canvas");
    _ca1.renderMode = UnityEngine.RenderMode.ScreenSpaceCamera;
    _ca1.worldCamera = _cm1;
    _ca1.sortingOrder = 1;
    local _cs1 = self.mNormalUIRoot:GetComponent("CanvasScaler");
    _cs1.uiScaleMode = UnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize;
    _cs1.referenceResolution = self.mViewSzie;
    _cs1.matchWidthOrHeight = self.mMatch;


    self.mHightUIRoot = CommonTools.CreateChild(self.mUIRoot,"HightUIRoot", typeof(UnityEngine.Canvas), typeof(UnityEngine.UI.CanvasScaler), typeof(UnityEngine.UI.GraphicRaycaster));
    local _cm2 = CommonTools.CreateChild(self.mHightUIRoot,"Camera", typeof(Camera)):GetComponent("Camera");
    _cm2.orthographic = true;
    _cm2.clearFlags = UnityEngine.CameraClearFlags.Depth;
    _cm2.nearClipPlane = -100;
    _cm2.farClipPlane = 100;
    _cm2.orthographicSize = 20;
    local _ca2 = self.mHightUIRoot:GetComponent("Canvas");
    _ca2.renderMode = UnityEngine.RenderMode.ScreenSpaceCamera;
    _ca2.worldCamera = _cm2;
    _ca2.sortingOrder = 2;
    local _cs2 = self.mHightUIRoot:GetComponent("CanvasScaler");
    _cs2.uiScaleMode = UnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize;
    _cs2.referenceResolution = self.mViewSzie;
    _cs2.matchWidthOrHeight = self.mMatch;

    local EventSystem = CommonTools.CreateChild(self.mUIRoot,"EventSystem", typeof(UnityEngine.EventSystems.EventSystem), typeof(UnityEngine.EventSystems.StandaloneInputModule));
end

return ViewManagerModel