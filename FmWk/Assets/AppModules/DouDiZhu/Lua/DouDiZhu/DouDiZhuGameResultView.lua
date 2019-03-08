ClassView(PanelNames.DouDiZhuGameResultView, GameNames.DouDiZhu, UILayer.PanelHigh)

function DouDiZhuGameResultView:OnCreate()
    self.Winbg = self:Find("Winbg")
    self.Losebg = self:Find("Losebg")
    self.SocreType = self:Find("SocreType")
    self.CoinType = self:Find("CoinType")
    self.BackButt = self:Find("BackButt")
    self.ContinueButt = self:Find("ContinueButt")
    self.ExitRommButt = self:Find("ExitRommButt")
    self.ComeAgainButt = self:Find("ComeAgainButt")
    self.BackButt:SetOnClick(function(evt, go, args)
        self:BackClick()
    end)
    self.ContinueButt:SetOnClick(function(evt, go, args)
        self:ContinueButtClick()
    end)
    self.ExitRommButt:SetOnClick(function(evt, go, args)
        self:ExitButtClick()
    end)
    self.ComeAgainButt:SetOnClick(function(evt, go, args)
        self:ComeAgainButtClick()
    end)

    self.Player={}
    for i=1,3 do
        self.Player[i] = {}
        self.Player[i].PlayerObj = self:Find("PlayerInfo/PlayerItem"..i)
        self.Player[i].DiZhuSgin = self.Player[i].PlayerObj:Find("DiZhuSgin")
        self.Player[i].PlayerIcon = self.Player[i].PlayerObj:Find("PlayerIcon")
        self.Player[i].PlayerName = self.Player[i].PlayerObj:Find("Name"):GetComponent("Text")
        self.Player[i].PlayerDiFen = self.Player[i].PlayerObj:Find("DiFen"):GetComponent("Text")
        self.Player[i].PlayerMultiple = self.Player[i].PlayerObj:Find("Multiple"):GetComponent("Text")
        self.Player[i].PlayerScore = self.Player[i].PlayerObj:Find("Score"):GetComponent("Text")
        self.Player[i].FeiDing = self.Player[i].PlayerObj:Find("FeiDing")
        self.Player[i].PoCan = self.Player[i].PlayerObj:Find("PoCan")
    end
    self:UpDataView()
end
--FFF5DDFF
function DouDiZhuGameResultView:UpDataView()
    local GameData = DouDiZhu.GetGameData()
    if not GameData.Table.GameResultData then
        self:BackClick()
        return
    end
    if GameData.RoomRule.SettleType == 2 then
        self.SocreType.gameObject:SetActive(false)
        self.CoinType.gameObject:SetActive(true)
    else
        self.SocreType.gameObject:SetActive(true)
        self.CoinType.gameObject:SetActive(false)
    end

    if GameData.IsClubRoom and GameData.RoomRule.SettleType == 2 and GameData.AllGameNum == 1 then      --俱乐部金币模式下 小结算显示再来一局
        self.ContinueButt.gameObject:SetActive(true)
        self.ExitRommButt.gameObject:SetActive(false)
        self.ComeAgainButt.gameObject:SetActive(false)
    else
        if GameData.RoomResultData then --已经大结算了
            self.ContinueButt.gameObject:SetActive(false)
            self.ExitRommButt.gameObject:SetActive(true)
            self.ComeAgainButt.gameObject:SetActive(false)
        else
            self.ContinueButt.gameObject:SetActive(true)
            self.ExitRommButt.gameObject:SetActive(false)
            self.ComeAgainButt.gameObject:SetActive(false)
        end
    end

    if GameData.Table.GameResultData.PlayerData[1].Integral >= 0 then
        self:PlaySound("Audio_You_Win")
        self.Winbg.gameObject:SetActive(true)
    else
        self:PlaySound("Audio_You_Lose")
        self.Losebg.gameObject:SetActive(true)
    end
    for i=1,3 do
        if  GameData.Table.GameResultData.PlayerData[i] then
            self:GetWebIconImage(GameData.Table.Players[i].PlayerInfo.UserSex,GameData.Table.Players[i].PlayerInfo.Imageurl, self.Player[i].PlayerIcon)
            self.Player[i].PlayerName.text = tostring(GameData.Table.Players[i].PlayerInfo.UserName)
            self.Player[i].PlayerDiFen.text = tostring(GameData.RoomRule.EndPointType)
            self.Player[i].PlayerMultiple.text = tostring(GameData.Table.GameResultData.PlayerData[i].Multiple)
            self.Player[i].DiZhuSgin.gameObject:SetActive(GameData.Table.BankerChairId == i)
            self.Player[i].PlayerScore.text = tostring(GameData.Table.GameResultData.PlayerData[i].Integral)
            self.Player[i].FeiDing.gameObject:SetActive(GameData.Table.GameResultData.PlayerData[i].OverFlag)
            self.Player[i].PoCan.gameObject:SetActive(GameData.RoomRule.SettleType == 2 and GameData.Table.Players[i].Score <= 0)
        end
    end
end


function DouDiZhuGameResultView:BackClick()
    CtrlManager.CloseCtrl(CtrlNames.DouDiZhuGameResult)
    CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):BackMainView()
end

--继续游戏
function DouDiZhuGameResultView:ContinueButtClick()
    DouDiZhu.GameContinue()
    CtrlManager.CloseCtrl(CtrlNames.DouDiZhuGameResult)
end


function DouDiZhuGameResultView:ExitButtClick()
	CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):OnCallExitGame()
    CtrlManager.CloseCtrl(CtrlNames.DouDiZhuGameResult)
end

function DouDiZhuGameResultView:ComeAgainButtClick()
    DouDiZhu.GameComeAgain()
    CtrlManager.CloseCtrl(CtrlNames.DouDiZhuGameResult)
end