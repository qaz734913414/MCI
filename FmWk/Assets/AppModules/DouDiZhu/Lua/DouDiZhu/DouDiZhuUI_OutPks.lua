function DouDiZhuMainView:LoadOutPKs()
    self.OutPkObj = self:Find("OutPks")
    self.OutPks = {}
    for i=1,3 do
        self.OutPks[i] = {}
        self.OutPks[i].Prent = self.OutPkObj:Find("Player" .. tostring(i))
        self.OutPks[i].Pks = {}
        for j=1,20 do
            local obj = self:InstantionGameObject(self.PKPrefab,self.OutPks[i].Prent, tostring(j))
            local Pk = self:NewPk(obj,0)
            table.insert(self.OutPks[i].Pks,Pk)
        end
    end
    self.LastComb = nil
end

function DouDiZhuMainView:InitOutPK()
    for i,v in ipairs(self.OutPks) do
        for i1,v1 in ipairs(v.Pks) do
            v1.Hide()
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------------
function DouDiZhuMainView:RestoreOutPKs(GameData)
    if GameData.Table.GameStatus == DouDiZhu.GameState.InGame  then
        if GameData.Table.LastChuPaiChairId ~= 0 then
            self:PlayerOutPks(GameData.Table.LastChuPaiChairId,GameData.Table.LastChuPaiPks,GameData,false)
        end
    end
end

function DouDiZhuMainView:HideOutPKs(ChairId)
    for i1,v1 in ipairs(self.OutPks[ChairId].Pks) do
        v1.Hide()
    end
    self.PlayerInfos[ChairId].CallScoreEffect.gameObject:SetActive(false)
end

function DouDiZhuMainView:PlayerOutPks(ChairId,Pks,GameData,IsPlayEffect)
    print("显示玩家出牌 PlayerOutPks ChairId"..ChairId)

    --self:InitOutPK()
    print("显示玩家出牌 PlayerOutPks 2")
    for i,v in ipairs(Pks) do
        self.OutPks[ChairId].Pks[i].SetValue(v)
        self.OutPks[ChairId].Pks[i].Show()
    end

    if GameData.Table.BankerChairId == ChairId then
        self.OutPks[ChairId].Pks[#Pks].SetDiZhu()
    end

    local Pks = {}
    for i1,v1 in ipairs(self.OutPks[ChairId].Pks) do
        if v1.IsShow() then
            table.insert(Pks,v1)
        end
    end
    print("显示玩家出牌 PlayerOutPks 3")
    self.LastComb = BrandType.new(Pks)

    print("显示玩家出牌 PlayerOutPks 10 = "..self.LastComb.type)
    if IsPlayEffect then
        self:PlayOutEffect(ChairId,Pks,GameData)
    end
end

function DouDiZhuMainView:PlayOutEffect(ChairId,Pks,GameData)
    if self.LastComb.type ==  POKETYPE.POKE_SINGLECARD then      --单牌
        self:PlaySound_ChuDanPai(ChairId,Pks[1].PValue,GameData)
    elseif self.LastComb.type ==  POKETYPE.POKE_SUB then         --对子
        self:PlaySound_ChuDuiZi(ChairId,Pks[1].PValue,GameData)
    elseif self.LastComb.type ==  POKETYPE.POKE_ROCKET then      --火箭
        self:PlaySound_ChuHuoJian(ChairId,GameData)
        self.HuoJian.gameObject:SetActive(false)
        self.HuoJian.gameObject:SetActive(true)
        self:PlayMultiple(ChairId,GameData)
    elseif self.LastComb.type ==  POKETYPE.POKE_BOMB then        --炸弹
        self:PlaySound_ChuZhaDan(ChairId,GameData)
        self.ZaDanEffect[ChairId].gameObject:SetActive(false)
        self.ZaDanEffect[ChairId].gameObject:SetActive(true)
        self:PlayMultiple(ChairId,GameData)
    elseif self.LastComb.type ==  POKETYPE.POKE_PLANEADDSIN or self.LastComb.type ==  POKETYPE.POKE_PLANEADDSUM or self.LastComb.type ==  POKETYPE.POKE_THREESHUNZI then        --飞机
        self:PlaySound_ChuFeiJi(ChairId,GameData)
        self.FeiJi.gameObject:SetActive(false)
        self.FeiJi.gameObject:SetActive(true)
    elseif self.LastComb.type ==  POKETYPE.POKE_SUBSHUNZI then        --连对
        self:PlaySound_ChuLianDui(ChairId,GameData)  
        self.LianDuiEffect[ChairId].gameObject:SetActive(false)
        self.LianDuiEffect[ChairId].gameObject:SetActive(true)
    elseif self.LastComb.type ==  POKETYPE.POKE_SHUNZI then        --顺子
        self:PlaySound_ChuSunZi(ChairId,GameData)
        self.SunZiEffect[ChairId].gameObject:SetActive(false)
        self.SunZiEffect[ChairId].gameObject:SetActive(true)
    elseif self.LastComb.type ==  POKETYPE.POKE_THREECARDS then        --三张
        self:PlaySound_ChuSanZhang(ChairId,GameData)
    elseif self.LastComb.type ==  POKETYPE.POKE_THREEBELTONE then      --三代一
        self:PlaySound_ChuSanDaiYi(ChairId,GameData)
    elseif self.LastComb.type ==  POKETYPE.POKE_THREEBELTSUB then      --三代一对
        self:PlaySound_ChuSanDaiYiDui(ChairId,GameData)
    elseif self.LastComb.type ==  POKETYPE.POKE_BOMBADDSIN then        --四代二
        self:PlaySound_ChuSiDaire(ChairId,GameData)
    elseif self.LastComb.type ==  POKETYPE.POKE_BOMBADDSUM then        --四代两对
        self:PlaySound_ChuSiDailiangdui(ChairId,GameData)
    end
end

function DouDiZhuMainView:OutShowResult(GameData)
    for i,v in ipairs(self.OutPks) do
        if i ~= GameData.Table.CurrOperatChairId then
            for i1,v1 in ipairs(v.Pks) do
                v1.Hide()
            end
        end
    end
end