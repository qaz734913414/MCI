MJCard = class()

function MJCard:ctor(Value,Obj)
    self.Value = Value
    self.CValue = 0
    self.IsTing = false
    self.IsSelect = false
    self.IsLaiZi = false
    self.Obj = Obj
    self.MJObj = self.Obj:GetTransform():Find("MJ").gameObject
    self.LaiZi = self.Obj:GetTransform():Find("MJ/LaiZi").gameObject
    self.Material = self.MJObj:GetComponent("Renderer").material
    self:SetValue(Value)
end

function MJCard:GetObj()
    return self.Obj
end

function MJCard:GetValue()
    return self.Value
end

function MJCard:GetCValue()
    return self.CValue
end

--麻将uv偏移 0.25 0.1111111  
function MJCard:SetValue(Value)
    self.Value = Value
    local t,v
    if Value and Value ~= 0 then
        t,v = math.modf(Value/16)
        v = v*16
    else    --无效牌
        t = 11
    end
    
    local OffsetX,OffsetY
    if t <= 3 then
        OffsetX = (v-1)*0.1111111
        OffsetY = (4 - t)*0.25
        self.CValue = (t-1)*10 + v
    else
        OffsetX = (t-4)*0.1111111
        OffsetY = 0
        self.CValue = (t-3) + 30
    end
    self.Material:SetTextureScale("_MainTex",Vector2(0.1111111,0.25))
    self.Material:SetTextureOffset("_MainTex",Vector2(OffsetX, OffsetY))
end

function MJCard:SetSelect(IsSelect)
    self.IsSelect = IsSelect;
    if self.IsSelect then
        self.Obj:GetTransform():DOLocalMoveY(-0.1, 0.1)
    else
        self.Obj:GetTransform():DOLocalMoveY(0, 0.1)
    end
end

function MJCard:GetSelect()
    return self.IsSelect
end

function MJCard:Relation(Value)
    if self.Value == Value then
        self.Material:SetColor("_Color",Color(0.6,1,1,1))
    end
end

function MJCard:ClearRelation()
    self.Material:SetColor("_Color",Color(1,1,1,1))
end

function MJCard:SetLaiZi(IsLaiZi)
    self.IsLaiZi = IsLaiZi
    self.LaiZi:SetActive(self.IsLaiZi)
end

function MJCard:GetLaiZi(IsLaiZi)
    return self.IsLaiZi
end

function MJCard:SetTing(IsTing)
    self.IsTing = IsTing
    if self.IsTing then
        self.Material:SetColor("_Color",Color(0.6,0.6,0.6,1))
    else
        self.Material:SetColor("_Color",Color(1,1,1,1))
    end
end

function MJCard:GetTing()
    return self.IsTing
end

function MJCard:ShowCanTing(IsCanTing)
    if not self.CanTing then
        self.CanTing = self.Obj:GetTransform():Find("MJ/TingTips").gameObject
        self.CanTing.layer = LayerMask.NameToLayer("2D");
    end
    self.CanTing:SetActive(IsCanTing)
end

function MJCard:SetGray()
    self.Material:SetColor("_Color",Color(0.6,0.6,0.6,1))
end

function MJCard:IsShow()
    return self.MJObj.activeSelf
end

function MJCard:Hide()
    self.MJObj:SetActive(false)
    self.LaiZi:SetActive(false)
end

function MJCard:Show()
    self.MJObj:SetActive(true)
end

function MJCard:SetLayer(layer)
    self.Obj.layer = LayerMask.NameToLayer(layer);
    self.MJObj.layer = LayerMask.NameToLayer(layer);
    self.LaiZi.layer = LayerMask.NameToLayer(layer);
end

function MJCard:AddAnimator(AnimatorController)
    self.Animator =  self.Obj:AddComponent(typeof(UnityEngine.Animator))
    self.Animator.runtimeAnimatorController = AnimatorController
end

function MJCard:PlayAnim(AnimName)
    if self.Animator then
        self.Animator:Play(AnimName,-1,0)
        self.Animator:Update(0)
    end
end

--设置mj的座位记录当前麻将的位置
function MJCard:SetSeat(TargetPos,IsReturnTo)
    self.SeatPos = TargetPos
    if IsReturnTo then
        self.Obj:SetLocalPosition(self.SeatPos.x,self.SeatPos.y,self.SeatPos.z)
    end
end

function MJCard:ReturnTo()
    self.Obj:SetLocalPosition(self.SeatPos.x,self.SeatPos.y,self.SeatPos.z)
end


function MJCard:DOLocalMove(TargetPos,MoveTime)
    self.Obj:GetTransform():DOLocalMove(TargetPos, MoveTime)
end