module ("LuaViewManagerModel", package.seeall);

UILevel =
{
    LowUI=1,                  --//一般用于app的业务逻辑界面
    NormalUI=2,               --//一般用于比业务逻辑界面高一级的弹出框类似界面
    HightUI=3,                --//一般用于类似与退出游街的弹窗界面
}


local ModelControl = Class.new(require "LuaViewManagerModel.ViewManagerModel")

function New(_csobj)
	ModelControl:New(_csobj)
end

function Load(agr1,agr2)
	ModelControl:Load(agr1,agr2)
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
------------------------对外接口------------------------
function LowUIRoot()
    return ModelControl.LowUIRoot;
end

function NormalUIRoot()
    return ModelControl.NormalUIRoot;
end

function HightUIRoot()
    return ModelControl.HightUIRoot;
end
