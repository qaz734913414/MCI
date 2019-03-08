LuaGameObject = Class.define("LuaGameObject")

function LuaGameObject:ctor(_Obj)
    self._Obj = _Obj
end

--查找子对象
function LuaGameObject:Find(target)
     local tmpobj = LuaHelpTools.Find(self._Obj,target)
     if tmpobj and tmpobj ~= "" then
     	return Class.new(LuaGameObject,tmpobj)
     end
     return nil
end

function LuaGameObject:GetComponent(CompName)
	return self._Obj:GetComponent(CompName)
end

--获取子对象的组件
function LuaGameObject:OnSubmit(target,CompName)
    return LuaHelpTools.OnSubmit(self._Obj,target,CompName)
end

--添加单击事件
function LuaGameObject:AddClick(target,func)
	LuaHelpTools.AddClick(self._Obj,target,func)
end
function LuaGameObject:AddEvent(target,eventtype,func)
	LuaHelpTools.AddEvent(self._Obj,target,eventtype,func)
end

function LuaGameObject:Show()
    self._Obj:SetActive(true)
end

function LuaGameObject:Hide()
    self._Obj:SetActive(false)
end

function LuaGameObject:Destroy()
    GameObject.Destroy(self._Obj)
end