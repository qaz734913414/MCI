ModelCompState = 
{
    Close = -1,          --//关闭状态
    Loading = 0,        --//加载中状态
    LoadEnd = 1,        --//加载完成状态
    Start = 2,          --//启动状态
}

BaseModelComp = Class.define("BaseModelComp");

function BaseModelComp:getter_State()
    return self._State;
end

function BaseModelComp:getter_MyModel()
    return self._MyModel;
end

function BaseModelComp:_ctor()
    self._State = ModelCompState.Close;
end

function BaseModelComp:ctor(...)
	self._State = ModelCompState.Close;
end

function BaseModelComp:Load(_Model,...)
	self._MyModel = _Model;
	self._State = ModelCompState.Loading;
end

function BaseModelComp:LoadEnd()
    self._State = ModelCompState.LoadEnd;
    self._MyModel:LoadEnd()
end

function BaseModelComp:Start(...)
	self._State = ModelCompState.Start;
end

function BaseModelComp:Close()
	self._State = ModelCompState.Close;
end

