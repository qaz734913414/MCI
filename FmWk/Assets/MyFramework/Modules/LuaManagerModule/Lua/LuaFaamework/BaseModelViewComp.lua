BaseModelViewComp = Class.define("BaseModelViewComp",BaseModelComp);

function BaseModelViewComp:ctor(...)
	if #... > 0 then
		self.ViewName = select("1",...)
		self.UILevel = select("2",...)
	end
	self:super(BaseModelViewComp,"ctor",...);
end

function BaseModelViewComp:Load(_Model,...)
	self:super(BaseModelViewComp,"Load",_Model,...)
    local UIRoot = nil;
    if self.UILevel == 3 then
        UIRoot = LuaViewManagerModel.HightUIRoot();
    elseif self.UILevel == 2 then
    	UIRoot = LuaViewManagerModel.NormalUIRoot();
    else 
    	UIRoot = LuaViewManagerModel.LowUIRoot();
	end
	local UIobj = self._MyModel:CreateObj("Prefab",self.ViewName,UIRoot)
	self.UIGameObject = Class.new(LuaGameObject,UIobj)
	local rectTrans = self.UIGameObject:GetComponent("RectTransform");
    rectTrans:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, 0, 0);
    rectTrans:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Top, 0, 0);
    rectTrans.anchorMin = UnityEngine.Vector2.zero;
    rectTrans.anchorMax = UnityEngine.Vector2.one;
end

function BaseModelViewComp:Start(...)
	self:super(BaseModelViewComp,"Start",...)
end

function BaseModelViewComp:Close()
	GameObject.Destroy(self.UIGameObject)
	self:super(BaseModelViewComp,"Close")
end

function BaseModelViewComp:Show()
	self.UIGameObject:Show()
end

function BaseModelViewComp:Hide()
	self.UIGameObject:Hide()
end

--查找子对象
function BaseModelViewComp:Find(target)
    return self.UIGameObject:Find(target)
end

--获取子对象的组件
function BaseModelViewComp:OnSubmit(target,CompName)
	return self.UIGameObject:OnSubmit(target,CompName)
end

--添加单击事件
function BaseModelViewComp:AddClick(target,func)
	self.UIGameObject:AddClick(target,func)
end

--添加事件
function BaseModelViewComp:AddEvent(target,eventtype,func)
	self.UIGameObject:AddEvent(target,eventtype,func)
end
