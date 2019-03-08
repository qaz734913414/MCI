module ("LuaSwitchSceneModel", package.seeall);
require "LuaSwitchSceneModel.ISceneLoadCompBase";
local ModelControl = Class.new(require "LuaSwitchSceneModel.SwitchSceneModel")

function New(_csobj)
	ModelControl:New(_csobj)
end

function Load(...)
	ModelControl:Load(...)
end

function LoadEnd()
	return ModelControl:GetEnd()
end

function Start(...)
	ModelControl:Start(...)
end

function Close()
	ModelControl:Close()
end

--------------------------------------------对外接口-------------------------------------
function ChangeScene(SceneLoadComp)
	ModelControl:ChangeScene(SceneLoadComp)
end
