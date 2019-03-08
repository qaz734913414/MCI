local SwitchSceneModel = Class.define("SwitchSceneModel",BaseModel)
function SwitchSceneModel:New(_csobj)
	self:super(SwitchSceneModel,"New", _csobj);
end

function SwitchSceneModel:Load(...)
	self.CSModelObj:LoadResourceComp()
	self.ViewComp = self:AddComp("SwitchSceneViewComp",require "LuaSwitchSceneModel.SwitchSceneViewComp","SwitchSceneView",3)
	self.ChangeSceneComp = self:AddComp("SceneChedulerComp",require "LuaSwitchSceneModel.SceneChedulerComp")
	self:super(SwitchSceneModel,"Load",...);
end

function SwitchSceneModel:ChangeScene(SceneLoadComp)
    self.ChangeSceneComp:ChangeScene(SceneLoadComp);
end

function SwitchSceneModel:StartLoadChanage()
	self.ViewComp:StartLoadChanage();
end 

function SwitchSceneModel:UpdataProgress(Progress,Describe)
	self.ViewComp:UpdataProgress(Progress,Describe);
end

function SwitchSceneModel:EndLoadChanage()
	self.ViewComp:EndLoadChanage();
end

return SwitchSceneModel
