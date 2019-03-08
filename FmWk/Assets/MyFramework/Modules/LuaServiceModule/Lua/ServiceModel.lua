local ServiceModel = Class.define("ServiceModel",BaseModel)

function ServiceModel:Load(...)
	self.ServicesComp = self:AddComp("ServiceManagerComp",require "LuaServiceModel.ServiceManagerComp")
	self:super(ServiceModel,"Load",...);
end

function ServiceModel:RegisteredService(ComId,Service)
	self.ServicesComp:RegisteredService(ComId,Service);
end

function ServiceModel:UnRegisteredService(ComId,Service)
	self.ServicesComp:UnRegisteredService(ComId,Service);
end

--处理消息
function ServiceModel:DealMessage(ComId,MsgId,buffer)
	self.ServicesComp:DealMessage(ComId,MsgId,buffer)
end

function ServiceModel:Send(ComId,MsgId,Msg)
	self.CSObj:SendMessage(ComId,MsgId,Msg:SerializeToString());
end
return ServiceModel