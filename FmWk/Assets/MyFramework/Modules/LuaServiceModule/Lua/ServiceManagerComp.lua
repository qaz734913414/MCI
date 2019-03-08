local ServiceManagerComp = Class.define("ServiceManagerComp",BaseModelComp)


function ServiceManagerComp:Load(...)
    self:super(ServiceManagerComp,"Load",...);
    self.Services = {}
    self:LoadEnd();
end

function ServiceManagerComp:RegisteredService(ComId,Service)
	if not self.Services[ComId] then
		self.Services[ComId] = {}
	end
	table.insert(self.Services[ComId],Service);
end

function ServiceManagerComp:UnRegisteredService(ComId,Service)
	if self.Services[ComId] then
		for i = #self.Services[ComId] , 1 , -1 do
			if self.Services[ComId][i] == Service then
				table.remove(self.Services[ComId],i)
			end
		end
	end
end

function ServiceManagerComp:DealMessage(ComId,MsgId,buffer)
	if self.Services[ComId] then
		for i,v in ipairs(self.Services[ComId]) do
			v:DealMessage(ComId,MsgId,buffer);
		end
	else
		print("消息处理组件没有注册 ComId = "..ComId)
	end
end

return ServiceManagerComp;