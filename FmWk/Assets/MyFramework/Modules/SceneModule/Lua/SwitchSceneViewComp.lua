local SwitchSceneViewComp = Class.define("SwitchSceneViewComp",BaseModelViewComp);

function SwitchSceneViewComp:ctor(...)
	self:super(SwitchSceneViewComp,"ctor",...);
end

function SwitchSceneViewComp:Load(_Model,...)
	self:super(SwitchSceneViewComp,"Load",_Model,...);
	self.Progress = self:OnSubmit("Progress","Slider");
	self.Describe = self:OnSubmit("Describe","Text");
	self:Hide();
	self:LoadEnd()
end

function SwitchSceneViewComp:StartLoadChanage()
	self:Show();
end

function SwitchSceneViewComp:UpdataProgress(Progress,Describe)
    self.Progress.value = Progress;
    self.Describe.text = Describe;
end

function SwitchSceneViewComp:EndLoadChanage()
	self:Hide();
end

return SwitchSceneViewComp