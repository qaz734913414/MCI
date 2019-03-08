ClassView(PanelNames.ZhengZhouMJGameResultView, GameNames.ZhengZhouMJ, UILayer.PanelHigh)

function ZhengZhouMJGameResultView:OnCreate()
    self.Winbg = self:Find("Winbg")
    self.Losebg = self:Find("Losebg")
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
    for i=1,4 do
        self.Player[i] = {}
        if i == 1 then
            self.Player[i].PlayerIcon = self:Find("PlayerIcon")
            self.Player[i].WinIntegral = self:Find("WinIntegral"):GetComponent("Text")
            self.Player[i].LoseIntegral = self:Find("LoseIntegral"):GetComponent("Text")
            self.Player[i].LiuShuiGrid = self:Find("Scroll View/Viewport/Content")
            self.Player[i].LiuShuiItem = self:Find("Scroll View/Viewport/Content/LiuShuiItem")
            self.Player[i].NoLiuShui = self:Find("NoLiuShui")
        else
            self.Player[i].PlayerObj = self:Find("PlayerInfo/Player"..i)
            self.Player[i].PlayerIcon = self.Player[i].PlayerObj:Find("PlayerIcon")
            self.Player[i].PlayerName = self.Player[i].PlayerObj:Find("Name"):GetComponent("Text")
            self.Player[i].GoldIcon1 = self.Player[i].PlayerObj:Find("GoldIcon1")
            self.Player[i].GoldIcon2 = self.Player[i].PlayerObj:Find("GoldIcon2")
            self.Player[i].WinIntegral = self.Player[i].PlayerObj:Find("WinIntegral"):GetComponent("Text")
            self.Player[i].LoseIntegral = self.Player[i].PlayerObj:Find("LoseIntegral"):GetComponent("Text")
            self.Player[i].CurrencyIcon = self.Player[i].PlayerObj:Find("CurrencyIcon")
            self.Player[i].PoCanSign = self.Player[i].PlayerObj:Find("PoCanSign")
            self.Player[i].DiPaoSign = self.Player[i].PlayerObj:Find("DiPaoSign")
            self.Player[i].BankerSign = self.Player[i].PlayerObj:Find("BankerSign")
        end
    end
    self:UpDataView()
end

function ZhengZhouMJGameResultView:UpDataView()
    local GameData = ZhengZhouMJ.GetGameData()
    if not GameData.Table.GameResultData then
        self:BackClick()
        return
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
        self:PlaySound("mj_effect_shengli")
        self.Winbg.gameObject:SetActive(true)
    else
        self:PlaySound("mj_effect_shibai")
        self.Losebg.gameObject:SetActive(true)
    end
    for i=1,4 do
        if  GameData.Table.GameResultData.PlayerData[i] then
            self:GetWebIconImage(GameData.Table.Players[i].PlayerInfo.UserSex,GameData.Table.Players[i].PlayerInfo.Imageurl, self.Player[i].PlayerIcon)

            if GameData.Table.GameResultData.PlayerData[i].Integral >= 0 then
                self.Player[i].WinIntegral.gameObject:SetActive(true)
                self.Player[i].WinIntegral.text = "+"..tostring(GameData.Table.GameResultData.PlayerData[i].Integral) 
            else
                self.Player[i].LoseIntegral.gameObject:SetActive(true)
                self.Player[i].LoseIntegral.text = tostring(GameData.Table.GameResultData.PlayerData[i].Integral) 
            end
            if i == 1 then
                if #GameData.Table.Players[1].FlowingData > 0 then
                    for i,v in ipairs(GameData.Table.Players[1].FlowingData) do
                        local obj = self:InstantionGameObject(self.Player[1].LiuShuiItem, self.Player[1].LiuShuiGrid,tostring(i))
                        local ItemObj = nil
                        if v.Integral >= 0 then
                            ItemObj = obj:GetTransform():Find("Win")
                        else
                            ItemObj = obj:GetTransform():Find("Lose")
                        end
                        ItemObj.gameObject:SetActive(true)
                        ItemObj:Find("Type"):GetComponent("Text").text = v.Title
                        ItemObj:Find("Multiple"):GetComponent("Text").text = v.Multiple.."倍"
                        if GameData.RoomRule.SettleType == 2 then
                            ItemObj:Find("Integral"):GetComponent("Text").text = "金币 :"..(v.Integral >= 0 and "+" or "")..v.Integral
                        else
                            ItemObj:Find("Integral"):GetComponent("Text").text = "积分 :"..(v.Integral >= 0 and "+" or "")..v.Integral
                        end
                        ItemObj:Find("TargetChair"):GetComponent("Text").text = v.ProdPlayer
                        obj.gameObject:SetActive(true)
                    end
                else
                    self.Player[1].NoLiuShui.gameObject:SetActive(true)
                end 
            else
                self.Player[i].GoldIcon1.gameObject:SetActive(GameData.RoomRule.SettleType == 1)
                self.Player[i].GoldIcon2.gameObject:SetActive(GameData.RoomRule.SettleType == 2)
                self.Player[i].PlayerName.text = tostring(GameData.Table.Players[i].PlayerInfo.UserName) 
                self.Player[i].BankerSign.gameObject:SetActive(GameData.Table.BankerChairId == i)
                self.Player[i].PoCanSign.gameObject:SetActive(GameData.RoomRule.SettleType == 2 and GameData.Table.Players[i].Score <= 0)
                self.Player[i].DiPaoSign.gameObject:SetActive(GameData.Table.GameResultData.PlayerData[i].PointPanFlag)
            end
        else
            self.Player[i].PlayerObj.gameObject:SetActive(false)
        end
    end
end


function ZhengZhouMJGameResultView:BackClick()
    CtrlManager.CloseCtrl(CtrlNames.ZhengZhouMJGameResult)
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):BackMainView()
end

--继续游戏
function ZhengZhouMJGameResultView:ContinueButtClick()
    ZhengZhouMJ.GameContinue()
    CtrlManager.CloseCtrl(CtrlNames.ZhengZhouMJGameResult)
end


function ZhengZhouMJGameResultView:ExitButtClick()
	CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):OnCallExitGame()
    CtrlManager.CloseCtrl(CtrlNames.ZhengZhouMJGameResult)
end

function ZhengZhouMJGameResultView:ComeAgainButtClick()
    ZhengZhouMJ.GameComeAgain()
    CtrlManager.CloseCtrl(CtrlNames.ZhengZhouMJGameResult)
end