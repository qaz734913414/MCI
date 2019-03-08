
function ZhengZhouMJMainView:LoadOutMJ()
    local deltaX = 0.3
    local deltaY = 0.4
    self.LastMJTips = self.Desk:Find("GameRoot/GameOutMJ/LastMJTips")
    self.OutMJ = {}
    for i=1,4 do
        self.OutMJ[i] = {}
        self.OutMJ[i].Prent = self.Desk:Find("GameRoot/GameOutMJ/Player" .. tostring(i))
        self.OutMJ[i].MJs = {}
        for j=1,3 do
            for n=1,6 do
                local obj = self:InstantionGameObject(self.MJPrefab, self.OutMJ[i].Prent, tostring(j.."_"..n))
                local MJ = MJCard.new(0,obj);
                obj:SetLocalPosition(deltaX*(n-1), deltaY*(j-1), 0)
                obj:GetTransform().localEulerAngles = Vector3(0,0,0)
                MJ:SetLayer("3D")
                table.insert(self.OutMJ[i].MJs,MJ)
            end
            if j == 3 then
                for n=1,4 do
                    local obj = self:InstantionGameObject(self.MJPrefab, self.OutMJ[i].Prent, tostring(j.."_"..n+6))
                    local MJ = MJCard.new(0,obj);
                    obj:SetLocalPosition(deltaX*(n+5), deltaY*(j-1), 0)
                    obj:GetTransform().localEulerAngles = Vector3(0,0,0)
                    MJ:SetLayer("3D")
                    table.insert(self.OutMJ[i].MJs,MJ)
                end
            end
        end
    end
end

--初始化打出牌
function ZhengZhouMJMainView:InitOutMJ()
    self.LastMJTips.gameObject:SetActive(false);
    for i=1,4 do
        for j,v in ipairs(self.OutMJ[i].MJs) do
            v:Hide()
        end
    end
end

--恢复打出牌
function ZhengZhouMJMainView:RestoreGameOutMJ(GameData)
    for i=1,4 do
        for i1,v1 in ipairs(GameData.Table.Players[i].OutMJ) do
            self.OutMJ[i].MJs[i1]:SetValue(v1)
            self.OutMJ[i].MJs[i1]:SetLaiZi(ZhengZhouMJ.IsLaiZi(v1))
            self.OutMJ[i].MJs[i1]:Show()
        end
    end
    if GameData.Table.LastChuPaiChairId ~= 0 then
        local LastIndex = #GameData.Table.Players[GameData.Table.LastChuPaiChairId].OutMJ
        self.LastMJTips.position =  self.OutMJ[GameData.Table.LastChuPaiChairId].MJs[LastIndex]:GetObj():GetTransform().position
        self.LastMJTips.gameObject:SetActive(true);
    end
end

---------------------------------------------------------------------------
function ZhengZhouMJMainView:OutMJChuPai(ChairId,GameData)
    local LastIndex = #GameData.Table.Players[ChairId].OutMJ
    local MJValue = GameData.Table.Players[ChairId].OutMJ[LastIndex]
    self.OutMJ[ChairId].MJs[LastIndex]:SetValue(MJValue)
    self.OutMJ[ChairId].MJs[LastIndex]:SetLaiZi(ZhengZhouMJ.IsLaiZi(MJValue))
    self.OutMJ[ChairId].MJs[LastIndex]:Show()
    self.LastMJTips.position = self.OutMJ[ChairId].MJs[LastIndex]:GetObj():GetTransform().position
    self.LastMJTips.gameObject:SetActive(true);
end

--最后出牌的麻将被拿走
function ZhengZhouMJMainView:LastOutMJToChair(ChairId,GameData)
    local LastIndex = #GameData.Table.Players[GameData.Table.LastChuPaiChairId].OutMJ + 1
    self.OutMJ[GameData.Table.LastChuPaiChairId].MJs[LastIndex]:Hide()
    self.LastMJTips.gameObject:SetActive(false);
    return self.OutMJ[GameData.Table.LastChuPaiChairId].MJs[LastIndex]
end

function ZhengZhouMJMainView:GetLastOutMJTran(GameData)
    local ChairId = GameData.Table.LastChuPaiChairId
    local LastIndex = #GameData.Table.Players[ChairId].OutMJ
    return self.OutMJ[ChairId].MJs[LastIndex]:GetObj():GetTransform()
end

--查找打出牌的关联麻将
function ZhengZhouMJMainView:FindOutRelationMJ(Value)
    for i=1,4 do
        for j,v in ipairs(self.OutMJ[i].MJs) do
           if v:IsShow() then
                v:Relation(Value)
           end
        end
    end
end

function ZhengZhouMJMainView:ClearOutRelationMJ()
    for i=1,4 do
        for j,v in ipairs(self.OutMJ[i].MJs) do
           if v:IsShow() then
                v:ClearRelation()
           end
        end
    end
end