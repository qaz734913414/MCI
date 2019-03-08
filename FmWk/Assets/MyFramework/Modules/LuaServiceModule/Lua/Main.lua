module ("LuaServiceModel", package.seeall);
require "LuaServiceModel.IServiceBase";
local ModelControl = Class.new(require "LuaServiceModel.ServiceModel")

function New(_csobj)
	ModelControl:New(_csobj)
end

function Load(...)
	ModelControl:Load(Ip,Port)
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

function RegisteredService(ComId,IServiceBase)
	ModelControl:RegisteredService(ComId,IServiceBase)
end
function UnRegisteredService(ComId,IServiceBase)
	ModelControl:UnRegisteredService(ComId,IServiceBase)
end

function Send(ComId,MsgId,Msg)
	ModelControl:Send(ComId,MsgId,Msg)
end

function DealMessage(ComId,MsgId,buffer)
	ModelControl:DealMessage(ComId,MsgId,buffer)
end

----------------------------------------
