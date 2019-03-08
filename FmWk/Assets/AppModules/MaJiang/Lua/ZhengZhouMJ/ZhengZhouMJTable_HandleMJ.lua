--加载操作牌
function ZhengZhouMJMainView:LoadHandleMJ()
    self.HandleMJ = {}
    for i=1,4 do
        self.HandleMJ[i] = {}
        self.HandleMJ[i].Prent = self.Desk:Find("GameRoot/GameHandleMJ/Player" .. tostring(i))
        self.HandleMJ[i].OperatMJs = {}
        for j=1,4 do
            local OperatMJ = {}
            OperatMJ.Obj = self:InstantionGameObject(self.OperatMJ, self.HandleMJ[i].Prent, tostring(j))
            OperatMJ.Obj:SetLocalPosition(1.25*(j-1), 0, 0)
            OperatMJ.MJs = {}
            for n=1,4 do
                local mjobj = OperatMJ.Obj:GetTransform():Find("MJ"..tostring(n)).gameObject
                local MJ = MJCard.new(0,mjobj)
                MJ:SetLayer("3D");
                table.insert(OperatMJ.MJs,MJ)
            end
            table.insert(self.HandleMJ[i].OperatMJs,OperatMJ)
        end
    end
end

function ZhengZhouMJMainView:InitHandleMJ()
    for i1,v1 in ipairs(self.HandleMJ) do
        for i2,v2 in ipairs(v1.OperatMJs) do
           for i3,v3 in ipairs(v2.MJs) do
               v3:Hide()
           end
        end
    end
end

--操作牌恢复
function ZhengZhouMJMainView:RestoreGameHandleMJ(GameData)
    for i=1,4 do
        self:HandleMJRestoreToChairId(i,GameData);
    end
end
    
------------------------------------------------业务逻辑--------------------------------------------


function ZhengZhouMJMainView:HandleMJRestoreToChairId(ChairId,GameData)
    for i1,v1 in ipairs(GameData.Table.Players[ChairId].HandleMJ) do
        if v1.Type == ZhengZhouMJ.MJHandleType.MAHJSTATOUCH then --碰
            self:ShowPengMJ(ChairId,self.HandleMJ[ChairId].OperatMJs[i1],v1)
        elseif v1.Type == ZhengZhouMJ.MJHandleType.MAHJSTAABAR or v1.Type == ZhengZhouMJ.MJHandleType.MAHJSTAREPAIRBAR then     --明杠或者补杠
            self:ShowMingGMJ(ChairId,self.HandleMJ[ChairId].OperatMJs[i1],v1)
        elseif v1.Type == ZhengZhouMJ.MJHandleType.MAHJSTADARKBAR then --暗杠
            self:ShowAingGMJ(ChairId,self.HandleMJ[ChairId].OperatMJs[i1],v1)
        end
    end
end

--碰牌
function ZhengZhouMJMainView:HandleMJ_PenPai(ChairId,GameData)
    local Index = #GameData.Table.Players[ChairId].HandleMJ
    self:ShowPengMJ(ChairId,self.HandleMJ[ChairId].OperatMJs[Index],GameData.Table.Players[ChairId].HandleMJ[Index])
end

--明杠
function ZhengZhouMJMainView:HandleMJ_MGang(ChairId,GameData)
    local Index = #GameData.Table.Players[ChairId].HandleMJ
    self:ShowMingGMJ(ChairId,self.HandleMJ[ChairId].OperatMJs[Index],GameData.Table.Players[ChairId].HandleMJ[Index])
end

--补牌
function ZhengZhouMJMainView:HandleMJ_BGang(ChairId,MJ,GameData)
    local Index = 0
    for i,v in ipairs(GameData.Table.Players[ChairId].HandleMJ) do
        if v.MJs[1] == MJ then
            Index = i
            break
        end
    end
    if Index ~= 0 then
        self:ShowMingGMJ(ChairId,self.HandleMJ[ChairId].OperatMJs[Index],GameData.Table.Players[ChairId].HandleMJ[Index])
    end
end

--暗牌
function ZhengZhouMJMainView:HandleMJ_AGang(ChairId,GameData)
    local Index = #GameData.Table.Players[ChairId].HandleMJ
    self:ShowAingGMJ(ChairId,self.HandleMJ[ChairId].OperatMJs[Index],GameData.Table.Players[ChairId].HandleMJ[Index])
end

--显示碰牌牌组
function ZhengZhouMJMainView:ShowPengMJ(ChairId,HandleMJ,HandleMJData)
    if (ChairId - 1) == HandleMJData.SourceChairId or (ChairId == 1 and HandleMJData.SourceChairId == 4)  then     --碰上家
        HandleMJ.MJs[1]:GetObj().transform.localPosition = Vector3(0,0,-0.05)
        HandleMJ.MJs[2]:GetObj().transform.localPosition = Vector3(0.35,0,0) 
        HandleMJ.MJs[3]:GetObj().transform.localPosition = Vector3(0.65,0,0)
        HandleMJ.MJs[1]:GetObj().transform.localRotation = Quaternion.Euler(-90,-90,0);
        HandleMJ.MJs[2]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
        HandleMJ.MJs[3]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
    elseif math.abs(ChairId - HandleMJData.SourceChairId)  == 2 then
        HandleMJ.MJs[1]:GetObj().transform.localPosition = Vector3(0,0,0)
        HandleMJ.MJs[2]:GetObj().transform.localPosition = Vector3(0.35,0,-0.05) 
        HandleMJ.MJs[3]:GetObj().transform.localPosition = Vector3(0.7,0,0)
        HandleMJ.MJs[1]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
        HandleMJ.MJs[2]:GetObj().transform.localRotation = Quaternion.Euler(-90,-90,0);
        HandleMJ.MJs[3]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
    else
        HandleMJ.MJs[1]:GetObj().transform.localPosition = Vector3(0,0,0)
        HandleMJ.MJs[2]:GetObj().transform.localPosition = Vector3(0.3,0,0) 
        HandleMJ.MJs[3]:GetObj().transform.localPosition = Vector3(0.65,0,-0.05)
        HandleMJ.MJs[1]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
        HandleMJ.MJs[2]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
        HandleMJ.MJs[3]:GetObj().transform.localRotation = Quaternion.Euler(-90,-90,0);
    end
    HandleMJ.MJs[1]:SetValue(HandleMJData.MJs[1])
    HandleMJ.MJs[1]:SetLaiZi(ZhengZhouMJ.IsLaiZi(HandleMJData.MJs[1]))
    HandleMJ.MJs[1]:Show()
    HandleMJ.MJs[2]:SetValue(HandleMJData.MJs[1])
    HandleMJ.MJs[2]:SetLaiZi(ZhengZhouMJ.IsLaiZi(HandleMJData.MJs[1]))
    HandleMJ.MJs[2]:Show()
    HandleMJ.MJs[3]:SetValue(HandleMJData.MJs[1])
    HandleMJ.MJs[3]:SetLaiZi(ZhengZhouMJ.IsLaiZi(HandleMJData.MJs[1]))
    HandleMJ.MJs[3]:Show()
end


--显示明杠或者补杠牌组
function ZhengZhouMJMainView:ShowMingGMJ(ChairId,HandleMJ,HandleMJData)
    if (ChairId - 1) == HandleMJData.SourceChairId or (ChairId == 1 and HandleMJData.SourceChairId == 4)  then     --碰上家
        HandleMJ.MJs[1]:GetObj().transform.localPosition = Vector3(0,0,-0.05)
        HandleMJ.MJs[2]:GetObj().transform.localPosition = Vector3(0.35,0,0) 
        HandleMJ.MJs[3]:GetObj().transform.localPosition = Vector3(0.65,0,0)
        HandleMJ.MJs[4]:GetObj().transform.localPosition = Vector3(0.0,0,0.25)
        HandleMJ.MJs[1]:GetObj().transform.localRotation = Quaternion.Euler(-90,-90,0);
        HandleMJ.MJs[2]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
        HandleMJ.MJs[3]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
        HandleMJ.MJs[4]:GetObj().transform.localRotation = Quaternion.Euler(-90,-90,0);
    elseif math.abs(ChairId - HandleMJData.SourceChairId)  == 2 then
        HandleMJ.MJs[1]:GetObj().transform.localPosition = Vector3(0,0,0)
        HandleMJ.MJs[2]:GetObj().transform.localPosition = Vector3(0.35,0,-0.05)

        HandleMJ.MJs[3]:GetObj().transform.localPosition = Vector3(0.7,0,0)
        HandleMJ.MJs[4]:GetObj().transform.localPosition = Vector3(0.35,0,0.25)
        HandleMJ.MJs[1]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
        HandleMJ.MJs[2]:GetObj().transform.localRotation = Quaternion.Euler(-90,-90,0);
        HandleMJ.MJs[3]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
        HandleMJ.MJs[4]:GetObj().transform.localRotation = Quaternion.Euler(-90,-90,0);
    else
        HandleMJ.MJs[1]:GetObj().transform.localPosition = Vector3(0,0,0)
        HandleMJ.MJs[2]:GetObj().transform.localPosition = Vector3(0.3,0,0) 
        HandleMJ.MJs[3]:GetObj().transform.localPosition = Vector3(0.65,0,-0.05)
        HandleMJ.MJs[4]:GetObj().transform.localPosition = Vector3(0.65,0,0.25)
        HandleMJ.MJs[1]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
        HandleMJ.MJs[2]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
        HandleMJ.MJs[3]:GetObj().transform.localRotation = Quaternion.Euler(-90,-90,0);
        HandleMJ.MJs[4]:GetObj().transform.localRotation = Quaternion.Euler(-90,-90,0);
    end
    HandleMJ.MJs[1]:SetValue(HandleMJData.MJs[1])
    HandleMJ.MJs[1]:SetLaiZi(ZhengZhouMJ.IsLaiZi(HandleMJData.MJs[1]))
    HandleMJ.MJs[1]:Show()
    HandleMJ.MJs[2]:SetValue(HandleMJData.MJs[1])
    HandleMJ.MJs[2]:SetLaiZi(ZhengZhouMJ.IsLaiZi(HandleMJData.MJs[1]))
    HandleMJ.MJs[2]:Show()
    HandleMJ.MJs[3]:SetValue(HandleMJData.MJs[1])
    HandleMJ.MJs[3]:SetLaiZi(ZhengZhouMJ.IsLaiZi(HandleMJData.MJs[1]))
    HandleMJ.MJs[3]:Show()
    HandleMJ.MJs[4]:SetValue(HandleMJData.MJs[1])
    HandleMJ.MJs[4]:SetLaiZi(ZhengZhouMJ.IsLaiZi(HandleMJData.MJs[1]))
    HandleMJ.MJs[4]:Show()
end

--显示暗杠牌组
function ZhengZhouMJMainView:ShowAingGMJ(ChairId,HandleMJ,HandleMJData)
    local GameData = ZhengZhouMJ.GetGameData()
    HandleMJ.MJs[1]:GetObj().transform.localPosition = Vector3(0,0,0)
    HandleMJ.MJs[2]:GetObj().transform.localPosition = Vector3(0.3,0,0) 
    HandleMJ.MJs[3]:GetObj().transform.localPosition = Vector3(0.6,0,0)
    HandleMJ.MJs[4]:GetObj().transform.localPosition = Vector3(0.9,0,0)
    HandleMJ.MJs[1]:GetObj().transform.localRotation = Quaternion.Euler(90,180,0);
    HandleMJ.MJs[2]:GetObj().transform.localRotation = Quaternion.Euler(90,180,0);
    HandleMJ.MJs[3]:GetObj().transform.localRotation = Quaternion.Euler(90,180,0);
    if GameData.Table.HavePlayerTing then
        HandleMJ.MJs[4]:GetObj().transform.localRotation = Quaternion.Euler(-90,0,0);
    else
        HandleMJ.MJs[4]:GetObj().transform.localRotation = Quaternion.Euler(90,180,0);
    end
    HandleMJ.MJs[1]:SetValue(HandleMJData.MJs[1])
    HandleMJ.MJs[1]:SetLaiZi(ZhengZhouMJ.IsLaiZi(HandleMJData.MJs[1]))
    HandleMJ.MJs[1]:Show()
    HandleMJ.MJs[2]:SetValue(HandleMJData.MJs[1])
    HandleMJ.MJs[2]:SetLaiZi(ZhengZhouMJ.IsLaiZi(HandleMJData.MJs[1]))
    HandleMJ.MJs[2]:Show()
    HandleMJ.MJs[3]:SetValue(HandleMJData.MJs[1])
    HandleMJ.MJs[3]:SetLaiZi(ZhengZhouMJ.IsLaiZi(HandleMJData.MJs[1]))
    HandleMJ.MJs[3]:Show()
    HandleMJ.MJs[4]:SetValue(HandleMJData.MJs[1])
    HandleMJ.MJs[4]:SetLaiZi(ZhengZhouMJ.IsLaiZi(HandleMJData.MJs[1]))
    HandleMJ.MJs[4]:Show()
end


function ZhengZhouMJMainView:FindHandleMJRelationMJ(Value)
    local GameData = ZhengZhouMJ.GetGameData()
    local CheckRelationMJ = function(HandleMJ,_Value)
        for j,v in ipairs(HandleMJ.MJs) do
           if v:IsShow() then
                v:Relation(_Value)
           end
        end
    end
    for i=1,4 do
        for i1,v1 in ipairs(GameData.Table.Players[i].HandleMJ) do
            if v1.Type == ZhengZhouMJ.MJHandleType.MAHJSTATOUCH or v1.Type == ZhengZhouMJ.MJHandleType.MAHJSTAABAR or v1.Type == ZhengZhouMJ.MJHandleType.MAHJSTAREPAIRBAR then     --明杠或者补杠
                CheckRelationMJ(self.HandleMJ[i].OperatMJs[i1],Value)
            end
        end
    end
end

function ZhengZhouMJMainView:ClearHandleMJRelationMJ()
    local GameData = ZhengZhouMJ.GetGameData()
    local CheckRelationMJ = function(HandleMJ)
        for j,v in ipairs(HandleMJ.MJs) do
           if v:IsShow() then
                v:ClearRelation()
           end
        end
    end
    for i=1,4 do
        for i1,v1 in ipairs(GameData.Table.Players[i].HandleMJ) do
            if v1.Type == ZhengZhouMJ.MJHandleType.MAHJSTATOUCH or v1.Type == ZhengZhouMJ.MJHandleType.MAHJSTAABAR or v1.Type == ZhengZhouMJ.MJHandleType.MAHJSTAREPAIRBAR then     --明杠或者补杠
                CheckRelationMJ(self.HandleMJ[i].OperatMJs[i1])
            end
        end
    end
end