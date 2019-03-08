IServiceBase = Class.define("IServiceBase",BaseModelComp)

function IServiceBase:Load(_Model,_Message_Map,_Message_Pb)
	self:super(IServiceBase,"Load",_Model);
	self.Map = _Message_Map;
	self.Pb = _Message_Pb;
	self:LoadEnd();
end

function MakeMessage(id,buffer)
	if id and Pb then
    	local mesName = self.Map[id]
        local msg = self.Pb[mesName]
        if msg then
            msg = msg()
            if buffer and buffer ~= "" then
                msg:ParseFromString(buffer)
            end
            return msg
        end
	end
	error("MakeMessage Error Model"..self.MyModel.className.."id:"..id)
end


function IServiceBase:DealMessage(ComId,MsgId,Msg)

end

function IServiceBase:Send(ComId,MsgId,Msg)
	LuaServiceModel.Send(ComId,MsgId,Msg)
end
