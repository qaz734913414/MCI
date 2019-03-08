function DouDiZhuMainView:LoadHandPKs()
    self.HandPk = self:Find("HandPks")
    self.HandPks = {}
    for i=1,3 do
        self.HandPks[i] = {}
        self.HandPks[i].Prent = self.HandPk:Find("Player" .. tostring(i))
        self.HandPks[i].PrentGrid = self.HandPks[i].Prent:GetComponent("GridLayoutGroup")
        self.HandPks[i].Player1NumObj = self.HandPk:Find("PlayerNum" .. tostring(i))
        self.HandPks[i].Player1NumLabel = self.HandPks[i].Player1NumObj:Find("Text"):GetComponent("Text")
        self.HandPks[i].Pks = {}
        for j=1,20 do
            local obj = self:InstantionGameObject(self.PKPrefab,self.HandPks[i].Prent, tostring(j))
            local Pk = self:NewPk(obj,0)
            if i == 1 then
                -- local Pos = Vector3(55*(j-1) - 550, 0, 0)
                -- obj:SetLocalPosition(Pos.x,Pos.y,Pos.z)
                -- obj:SetOnClick(function(evt, go, args)    
                --     self:HandPKOnClick(Pk)
                -- end)
                obj:SetOnHover(function(evt, go ,args ,state)
                    if state then
                        self:HandPKOnHover(Pk)
                    end
                end)
                obj:SetOnPress(function(evt, go ,args ,state)
                    self:HandPKOnPress(Pk,state)
                end)
            end
            table.insert(self.HandPks[i].Pks,Pk)
        end
    end
    self.RecommendList = nil
    self.RecommendIndex = 0
    self.IsPress = false
end

function DouDiZhuMainView:InitHandPK()
    for i,v in ipairs(self.HandPks) do
        for i1,v1 in ipairs(v.Pks) do
            if i == 1 then
                v1.SetSelect(false)
            end
            v1.Hide()
        end
        v.Prent.gameObject:SetActive(false)
        v.Player1NumObj.gameObject:SetActive(false)
    end
    self.HandPks[1].Prent.gameObject:SetActive(true)
end

-----------------------------------------游戏业务逻辑------------------------------------------
function DouDiZhuMainView:RestoreHandPKs(GameData)
    if GameData.Table.GameStatus > DouDiZhu.GameState.STEPNULL  then
        for i,v in ipairs(GameData.Table.Players) do
            for i1,v1 in ipairs(v.HandPKs) do
                self.HandPks[i].Pks[i1].SetValue(v1)
                self.HandPks[i].Pks[i1].Show()
                if i == 1 then
                    local Pos = Vector3(60*(i1-1) - (#v.HandPKs*60)/2, 0, 0)
                    self.HandPks[i].Pks[i1].Obj:SetLocalPosition(Pos.x,Pos.y,Pos.z)
                end
            end
            if i ~= 1 then
                self.HandPks[i].Player1NumObj.gameObject:SetActive(true)
            end
            self.HandPks[i].Player1NumLabel.text = tostring(#v.HandPKs)
        end
        if GameData.Table.BankerChairId == 1 then
            self.HandPks[1].Pks[#GameData.Table.Players[1].HandPKs].SetDiZhu()
        end
    end
end
--发手牌
function DouDiZhuMainView:HandFaPai(ChairId,Index,Value)
    self.HandPks[ChairId].Player1NumObj.gameObject:SetActive(true)
    self.HandPks[ChairId].Player1NumLabel.text = tostring(Index)
    self.HandPks[ChairId].Pks[Index].SetValue(Value)
    self.HandPks[ChairId].Pks[Index].Show()
    if ChairId == 1 then
        for i=1,Index do
            local Pos = Vector3(60*(i-1) - (Index*60)/2, 0, 0)
            self.HandPks[ChairId].Pks[i].Obj:SetLocalPosition(Pos.x,Pos.y,Pos.z)
        end
    end
end
--设置地主
function DouDiZhuMainView:SetHandPkLandlord(ChairId,GameData)
    for i1,v1 in ipairs(GameData.Table.Players[ChairId].HandPKs) do
        self.HandPks[ChairId].Pks[i1].SetValue(v1)
        self.HandPks[ChairId].Pks[i1].Show()
        if ChairId == 1 then
            local Pos = Vector3(60*(i1-1) - (20*60)/2, 0, 0)
            self.HandPks[ChairId].Pks[i1].Obj:SetLocalPosition(Pos.x,Pos.y,Pos.z)
            if v1 == GameData.Table.AhandPks[1] or v1 == GameData.Table.AhandPks[2] or v1 == GameData.Table.AhandPks[3] then
                print("播放地主牌动画")
                self.HandPks[ChairId].Pks[i1].PlayDiPai()
            end
        end
    end
    if GameData.Table.BankerChairId == 1 then
        self.HandPks[1].Pks[20].SetDiZhu()
    end
    self.HandPks[ChairId].Player1NumLabel.text = tostring(#GameData.Table.Players[ChairId].HandPKs)
end
--排序手牌
function DouDiZhuMainView:SortPlayerHandPks(GameData)
    DouDiZhu.SortHandPks(1)
    StartCoroutine(function()
        for i1,v1 in ipairs(self.HandPks[1].Pks) do
            v1.Obj:GetTransform():DOLocalMove(Vector3(0, 0, 0), 0.3)
        end
        WaitForSeconds(0.6)
        for i1,v1 in ipairs(self.HandPks[1].Pks) do
            v1.Hide()
        end
        for i1,v1 in ipairs(GameData.Table.Players[1].HandPKs) do
            self.HandPks[1].Pks[i1].SetValue(v1)
            self.HandPks[1].Pks[i1].Show()
            local Pos = Vector3(60*(i1-1) - (17*60)/2, 0, 0)
            self.HandPks[1].Pks[i1].Obj:GetTransform():DOLocalMove(Pos, 0.5)
        end
    end)
end

--Pk点击
function DouDiZhuMainView:HandPKOnClick(PK)
    print("点击 pk = "..PK.Value)
    PK.SetSelect(not PK.GetSelect())
end

function DouDiZhuMainView:HandPKOnPress(Pk,IsPress)
    self.IsPress = IsPress
    if self.IsPress then
        Pk.SetPress(not Pk.GetPress())
    else
        --local Tmp = {}
        for i1,v1 in ipairs(self.HandPks[1].Pks) do
            if v1.IsShow() and v1.GetPress() then
                v1.SetPress(false)
                v1.SetSelect(not v1.GetSelect())
                --if v1.GetSelect() then
                    --table.insert( Tmp,v1)
                --end
            end
        end
        -- local taker = HandPknalysis.new(Tmp)
        -- local RecommendList = taker:GetTakeOverList(nil)
        -- if RecommendList and #RecommendList > 0 then
        --     local Pks = RecommendList[1]
        --     for i1,v1 in ipairs(Tmp) do
        --         v1.SetSelect(false)
        --         for i2,v2 in ipairs(Pks) do
        --             if v1.Value == v2.Value then
        --                 v1.SetSelect(true)
        --             end
        --         end
        --     end
        -- end
    end
end

function DouDiZhuMainView:HandPKOnHover(PK)
    if self.IsPress then
        PK.SetPress(not PK.GetPress())
    end
end

function DouDiZhuMainView:TiShiClick()
    if not self.RecommendList or #self.RecommendList == 0 then
        return
    end
    self.RecommendIndex = self.RecommendIndex % #self.RecommendList;
    self.RecommendIndex = self.RecommendIndex == 0 and #self.RecommendList or self.RecommendIndex
    local Pks = self.RecommendList[self.RecommendIndex]
    for i1,v1 in ipairs(self.HandPks[1].Pks) do
        if v1.IsShow() then
            v1.SetSelect(false)
            for i2,v2 in ipairs(Pks) do
                if v1.Value == v2.Value then
                    v1.SetSelect(true)
                    break
                end
            end
        end
    end
    self.RecommendIndex = self.RecommendIndex + 1
end

--发送出牌消息
function DouDiZhuMainView:SendPlayerChuPai()
    local Pks = {}
    for i1,v1 in ipairs(self.HandPks[1].Pks) do
        if v1.IsShow() and v1.GetSelect() then
            table.insert(Pks,v1)
        end
    end
    local Brand = BrandType.new(Pks)

    if Brand.type ==  POKETYPE.POKE_INVALID then
        ToastView.Show("牌型不符合规范!请重新选择");
    else
        DouDiZhu.RequestChuPai(Brand.type,Brand:GetServerValueList())
    end
end

--玩家出牌
function DouDiZhuMainView:HandPKChuPai(ChairId,PaiPks,GameData)

    for i1,v1 in ipairs(PaiPks) do
        for i2,v2 in ipairs(self.HandPks[ChairId].Pks) do
            if v1 == v2.Value then
                v2.Hide()
            end
        end
    end
    if ChairId == 1 then
        local tmp = {}
        for i2,v2 in ipairs(self.HandPks[ChairId].Pks) do
            if v2.IsShow() then
                table.insert(tmp,v2)
            end
        end
        for i,v in ipairs(tmp) do
            local Pos = Vector3(55*(i-1) - (#tmp*55)/2, 0, 0)
            v.Obj:GetTransform():DOLocalMove(Pos, 0.3)
        end
        if #tmp > 0 and GameData.Table.BankerChairId == 1 then
            tmp[#tmp].SetDiZhu()
        end
    else
        self.HandPks[ChairId].Player1NumLabel.text = tostring(#GameData.Table.Players[ChairId].HandPKs)
    end
end


function DouDiZhuMainView:ClearSelectPk()
    for i1,v1 in ipairs(self.HandPks[1].Pks) do
        v1.SetSelect(false)
    end
end

function DouDiZhuMainView:LiangPai()
    for i,v in ipairs(self.HandPks) do
        v.Player1NumObj.gameObject:SetActive(false)
        v.Prent.gameObject:SetActive(true)
    end
end