local ServiceTCPComp = Class.define("ServiceTCPComp",BaseModelComp)


function ServiceTCPComp:Load(...)
	self.socket = require("LuaManagerModel.ToLua.socket")
    self:super(ServiceTCPComp,"Load",...);
    self:LoadEnd();
end

function ServiceTCPComp:Start(...)
	self:Connect();
	self:super(ServiceTCPComp,"Start",...);
end


--连接服务器
function ServiceTCPComp:Connect()
	local sock = assert(self.socket.connect(self.MyModel.Ip, self.MyModel.Port))
	sock:settimeout(5)
	print("连接服务器"..tostring(sock))
end

return ServiceTCPComp;