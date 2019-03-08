function DouDiZhuMainView:LoadOperat()
    self.DaoJiShiCoroutine = nil
    self.LeftTime = 0

    self.PlayerOperat = self:Find("PlayerOperat")
    self.Operat = {}
    self.Operat["NoChuPai"] = self.PlayerOperat:Find("NoChuPai_Butt")
    self.Operat["DaoJiShi"] = self.PlayerOperat:Find("DaoJiShi")
    self.Operat["TiShi"] = self.PlayerOperat:Find("TiShi_Butt")
    self.Operat["ChuPai"] = self.PlayerOperat:Find("ChuPai_Butt")
    self.Operat["YaoBuQi"] = self.PlayerOperat:Find("YaoBuQi_Butt")
    self.Operat["NoChuPai"]:SetOnClick(function(evt, go, args)
        DouDiZhu.RequestChuPaiPass()
        self:ClearSelectPk()
        --self:HideOperatView()
    end)
    self.Operat["TiShi"]:SetOnClick(function(evt, go, args)
        self:TiShiClick()
    end)
    self.Operat["ChuPai"]:SetOnClick(function(evt, go, args)
        self:SendPlayerChuPai()
        --self:HideOperatView()
    end)
    self.Operat["YaoBuQi"] :SetOnClick(function(evt, go, args)
        DouDiZhu.RequestChuPaiPass()
        self:ClearSelectPk()
       -- self:HideOperatView()
    end)

    self.CallScoreGroup = self:Find("CallScoreGroup")
    self.CallScore = {}
    self.CallScore["DontCall"] = self.CallScoreGroup:Find("DontCall_Butt")
    self.CallScore["DaoJiShi"] = self.CallScoreGroup:Find("DaoJiShi")
    self.CallScore["CallOne"] = self.CallScoreGroup:Find("CallOne_Butt")
    self.CallScore["CallOneNo"] = self.CallScoreGroup:Find("CallOne_NoButt")
    self.CallScore["CallTwo"] = self.CallScoreGroup:Find("CallTwo_Butt")
    self.CallScore["CallTwoNo"] = self.CallScoreGroup:Find("CallTwo_NoButt")
    self.CallScore["CallThree"] = self.CallScoreGroup:Find("CallThree_Butt")
    self.CallScore["DontCall"]:SetOnClick(function(evt, go, args)
        self:HideCallScore()
        DouDiZhu.RequestLandlord(0)
    end)
    self.CallScore["CallOne"]:SetOnClick(function(evt, go, args)
        self:HideCallScore()
        DouDiZhu.RequestLandlord(1)
    end)
    self.CallScore["CallTwo"]:SetOnClick(function(evt, go, args)
        self:HideCallScore()
        DouDiZhu.RequestLandlord(2)
    end)
    self.CallScore["CallThree"]:SetOnClick(function(evt, go, args)
        self:HideCallScore()
        DouDiZhu.RequestLandlord(3)
    end)
end

function DouDiZhuMainView:OperatInit()
    self.PlayerOperat.gameObject:SetActive(false)
    self.CallScoreGroup.gameObject:SetActive(false)
end


----------------------------------------------------------------------------------------------------
function DouDiZhuMainView:RestoreOperat(GameData)
    if GameData.Table.GameStatus == DouDiZhu.GameState.CallScore  then
        if GameData.Table.CurrOperatChairId == 1 then
            self:ShowCallScore(GameData.Table.BankerCallScore,GameData.Table.OperationLeftTime)
        end
    elseif GameData.Table.GameStatus == DouDiZhu.GameState.InGame  then
        if GameData.Table.CurrOperatChairId == 1 then
            self:ShowOperatView(GameData,GameData.Table.OperationLeftTime)
        end
    end
end

function DouDiZhuMainView:ShowCallScore(CurCallScore,Time)
    for i,v in ipairs(self.CallScore) do
        v.gameObject:SetActive(false)
    end
    self.CallScoreGroup.gameObject:SetActive(true)
    self.CallScore["DontCall"].gameObject:SetActive(true)
    self:ShowTimer(self.CallScore["DaoJiShi"],Time)
    if CurCallScore == 0 then
        self.CallScore["CallOne"].gameObject:SetActive(true)
        self.CallScore["CallOneNo"].gameObject:SetActive(false)
        self.CallScore["CallTwo"].gameObject:SetActive(true)
        self.CallScore["CallTwoNo"].gameObject:SetActive(false)
        self.CallScore["CallThree"].gameObject:SetActive(true)
    elseif CurCallScore == 1 then
        self.CallScore["CallOne"].gameObject:SetActive(false)
        self.CallScore["CallOneNo"].gameObject:SetActive(true)
        self.CallScore["CallTwo"].gameObject:SetActive(true)
        self.CallScore["CallTwoNo"].gameObject:SetActive(false)
        self.CallScore["CallThree"].gameObject:SetActive(true)
    elseif CurCallScore == 2 then
        self.CallScore["CallOne"].gameObject:SetActive(false)
        self.CallScore["CallOneNo"].gameObject:SetActive(true)
        self.CallScore["CallTwo"].gameObject:SetActive(false)
        self.CallScore["CallTwoNo"].gameObject:SetActive(true)
        self.CallScore["CallThree"].gameObject:SetActive(true)
    end
end

function DouDiZhuMainView:ShowOperatView(GameData,Time)
    print("显示操作按钮 1")
    self.PlayerOperat.gameObject:SetActive(true)
    
    local Pks = {}
    for i1,v1 in ipairs(self.HandPks[1].Pks) do
        if v1.IsShow() then
            table.insert(Pks,v1)
        end
    end
    print("显示操作按钮 2")
    local taker = HandPknalysis.new(Pks)
    

    if GameData.Table.LastChuPaiChairId == 1  then   --上一次出牌是自己
        self.RecommendList = taker:GetTakeOverList(nil)
        print("显示操作按钮 4")
        self.RecommendIndex = 1
        self.Operat["NoChuPai"].gameObject:SetActive(false)
        self.Operat["TiShi"].gameObject:SetActive(true)
        self.Operat["ChuPai"].gameObject:SetActive(true)
        self.Operat["YaoBuQi"].gameObject:SetActive(false)
        self:ShowTimer(self.Operat["DaoJiShi"],Time)
    elseif GameData.Table.LastChuPaiChairId == 0 then   --第一次出牌
        print("显示操作按钮 3")
        self.RecommendList = taker:GetTakeOverList(nil)
        print("显示操作按钮 4")
        self.RecommendIndex = 1
        self.Operat["NoChuPai"].gameObject:SetActive(false)
        self.Operat["TiShi"].gameObject:SetActive(true)
        self.Operat["ChuPai"].gameObject:SetActive(true)
        self.Operat["YaoBuQi"].gameObject:SetActive(false)
        self:ShowTimer(self.Operat["DaoJiShi"],Time)
    else
        print("显示操作按钮 3")
        self.RecommendList = taker:GetTakeOverList(self.LastComb)
        print("显示操作按钮 4")
        self.RecommendIndex = 1
        print("显示操作按钮 2")
        if self.RecommendList and #self.RecommendList > 0 then
            self.Operat["NoChuPai"].gameObject:SetActive(true)
            self.Operat["TiShi"].gameObject:SetActive(true)
            self.Operat["ChuPai"].gameObject:SetActive(true)
            self.Operat["YaoBuQi"].gameObject:SetActive(false)
            self:ShowTimer(self.Operat["DaoJiShi"],Time)
        else
            self.Operat["NoChuPai"].gameObject:SetActive(false)
            self.Operat["TiShi"].gameObject:SetActive(false)
            self.Operat["ChuPai"].gameObject:SetActive(false)
            self.Operat["YaoBuQi"].gameObject:SetActive(true)
            self:ShowTimer(self.Operat["DaoJiShi"],GameData.Table.OverNotRiseTime)
        end
    end
    print("显示操作按钮 end")
end

function DouDiZhuMainView:HideCallScore()
    StopCoroutine(self.DaoJiShiCoroutine)
    self.CallScoreGroup.gameObject:SetActive(false)
end

function DouDiZhuMainView:HideOperatView()
    StopCoroutine(self.DaoJiShiCoroutine)
    self.PlayerOperat.gameObject:SetActive(false)
end

function DouDiZhuMainView:ShowTimer(TimerObj,Time)
    TimerObj.gameObject:SetActive(true)
    local TimerAnim = TimerObj:Find("PlayTimer"):GetComponent("Animator")
    TimerAnim:Play("daojishi",-1,0)
    TimerAnim:Update(0)
    TimerAnim.enabled = false
    local DaoJiShiLabel = TimerObj:Find("PlayTimer/Txt"):GetComponent("Text")
    self.LeftTime = Time
    DaoJiShiLabel.text = string.format("%02d", self.LeftTime)
    DaoJiShiLabel.gameObject:SetActive(true)
    StopCoroutine(self.DaoJiShiCoroutine)
    self.DaoJiShiCoroutine =  StartCoroutine(function()
        while self.LeftTime > 0 do
            WaitForSeconds(1)
            self.LeftTime = self.LeftTime - 1
            DaoJiShiLabel.text = string.format("%02d", self.LeftTime)
            if self.LeftTime < 10 then
                TimerAnim.enabled = true
            end
            if self.LeftTime < 3 then
                self:PlaySound("shi1")
            end 
        end
    end)
end

