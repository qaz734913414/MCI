function DouDiZhuMainView:LoadOtherUI()
    self:LoadLeftBottom()
    self:LoadLeftTop()
    self:LoadRightTop()
    self:LoadCenterUI()
    self:LoadTopUI()
    self:LoadBottom()
    self:LoadGameEffect()
end

--加载界面左下方UI对象
function DouDiZhuMainView:LoadLeftBottom()
    self.ChatButt = self:Find("LeftBottomUI/ChatButt")
    self.ChatRoot = self:Find("LeftBottomUI/ChatRoot")
    self.ChatVoiceBtnGroup = self:Find("LeftBottomUI/ChatVoiceBtnGroup_1")
    self.ChatButt:SetOnClick(function(obj, evt, go, args)
		ChatManager.HandleChatComponent(self.ChatRoot, GameNames.DouDiZhu);
    end)
    self.ChatVoiceBtnGroup.gameObject:SetActive(false)
end

--加载界面左上方方UI对象
function DouDiZhuMainView:LoadLeftTop()
    self.MoreButt = self:Find("LeftTopUI/MoreButt")                         --更多
    self.MoreView = self:Find("LeftTopUI/MoreView")                         --更多界面
    self.bt_tuoguan = self:Find("LeftTopUI/MoreView/bg/bt_tuoguan")         --托管
    self.bt_breakup = self:Find("LeftTopUI/MoreView/bg/bt_breakup")         --解散
    self.bt_wanfa = self:Find("LeftTopUI/MoreView/bg/bt_wanfa")
    self.bt_setting = self:Find("LeftTopUI/MoreView/bg/bt_setting")
    self.IsOpenMoreView = false
    self.MoreButt:SetOnClick(function(evt, go, args)
        if self.IsOpenMoreView then
            self.MoreView:DOScale(0,0.3)
        else
            self.MoreView:DOScale(1,0.3)
        end
        self.IsOpenMoreView = not self.IsOpenMoreView
    end)
    self.bt_setting:SetOnClick(function(evt, go, args)
        local GameData = DouDiZhu.GetGameData()
        CtrlManager.OpenCtrl(GameNames.GameCenter, CtrlNames.SettingPanel, {fankui=true, help=true, account=false}, {gameId = GameData.GameId});
    end)
    self.bt_tuoguan:SetOnClick(function(evt, go, args)
        DouDiZhu.SendIsTrustFlag(1)
    end)
    self.bt_breakup:SetOnClick(function(evt, go, args)
        local JieSan = DouDiZhu.CanDisbandNow()
        if JieSan == 1 then
			TipsView.Show("确认需要解散房间吗？", function ()
				DismissManager.DismissReq()
				self.iCtrl:OnCallExitGame()
            end, nil, true)
        elseif JieSan == 2 then
            ToastView.Show("你不是房主当前无权解散房间!");
		else
			if DismissManager.CanApplyDismiss() == true then
				DissmissRoomTipsView.Show("申请解散房间，需要其他玩家同意。是否解散房间？", 
					function ()
                        DismissManager.ApplyDismissReq();
					end, nil);
			else
				ToastView.Show("每一小局只能发起一次解散申请!");
			end
		end
    end)
    self.bt_wanfa:SetOnClick(function(evt, go, args)
        local GameData = DouDiZhu.GetGameData()
		CtrlManager.OpenCtrl(GameNames.Shared, CtrlNames.CommonGameRule, GameData.GameRuleInfoStrList)
    end)
    DismissManager.Initialize()         --初始化解散界面
end

--加载界面右上方方UI对象
function DouDiZhuMainView:LoadRightTop()
    self.bt_back = self:Find("RightTopUI/TopInfo/bt_back")           --返回
    self.bt_back:SetOnClick(function(evt, go, args)
        local GameData = DouDiZhu.GetGameData()
        --if GameData.IntoGameNum == GameData.AllGameNum or GameData.RoomResultData then     --房间结束
        if GameData.RoomResultData then     --房间结束
            self.iCtrl:OnCallExitGame()
        else
            self.iCtrl:CallExitGame()
        end
    end)
end

--加载界面中间UI对象
function DouDiZhuMainView:LoadCenterUI()
    self.JieSuanButt =  self:Find("CenterUI/PlayerButts/JieSuanButt")           --结算详情
    self.InvateButt = self:Find("CenterUI/PlayerButts/InvateButt")              --邀请
    self.ReadyButt = self:Find("CenterUI/PlayerButts/ReadyButt")                --准备
    self.ContinueButt = self:Find("CenterUI/PlayerButts/ContinueButt")          --继续游戏
    self.ComeAgainButt = self:Find("CenterUI/PlayerButts/ComeAgainButt")        --再来一局
    self.JieSuanButt:SetOnClick(function(evt, go, args)                         --显示结算详情
        CtrlManager.ReOpenCtrl(GameNames.DouDiZhu,CtrlNames.DouDiZhuGameResult)
    end)
    self.InvateButt:SetOnClick(function(evt, go, args)    
        DouDiZhu.WXInvate()
    end)
    self.ReadyButt:SetOnClick(function(evt, go, args)
        DouDiZhu.SendReadyState(1);
    end)
    self.ContinueButt:SetOnClick(function(evt, go, args)
        DouDiZhu.GameContinue()
        DouDiZhu.SendReadyState(1);
        self.ContinueButt.gameObject:SetActive(false)
    end)
    self.ComeAgainButt:SetOnClick(function(evt, go, args)
        self.ComeAgainButt.gameObject:SetActive(false)
        self.JieSuanButt.gameObject:SetActive(false)
        DouDiZhu.GameComeAgain()
    end)
    self.RoomId = self:Find("BackGround/GameInfo/RoomId"):GetComponent("Text")
    self.PlayerOperatTips = self:Find("CenterUI/PlayerOperatTips")
    self.PlayerOperatTipsLable = self.PlayerOperatTips:Find("bg01/Tips"):GetComponent("Text")
end

--加载顶部UI
function DouDiZhuMainView:LoadTopUI()
    self.AhandPks = {}
    self.DiFen = self:Find("TopUI/RoomInfo/DiFen"):GetComponent("Text")
    self.BeiShu = self:Find("TopUI/RoomInfo/BeiShu"):GetComponent("Text")
    self.AhandPksObjs = self:Find("TopUI/RoomInfo/AhandPks")
    for i=1,3 do
        self.AhandPks[i] = self:NewPk(self.AhandPksObjs:Find("pk0"..tostring(i)),0)
    end
end

function DouDiZhuMainView:LoadBottom()
    self.JuNumLabel =  self:Find("Bottom/JuNum/JuNumLabel"):GetComponent("Text")
    self.TrustFlagVire = self:Find("Bottom/TrustFlagVire")
    self.CancelTrustFlagButt = self.TrustFlagVire:Find("CancelTrustFlagButt")
    self.CancelTrustFlagButt:SetOnClick(function(evt, go, args)
        DouDiZhu.SendIsTrustFlag(0)
    end)
end

--加载游戏特效
function DouDiZhuMainView:LoadGameEffect()
    self.GameBeginEffect = self:Find("GameEffect/GameBegin")
    self.GameEndEffect = self:Find("GameEffect/GameEnd")
    self.DiZhuEffect = self:Find("GameEffect/DiZhuEffect")
    self.ZaDanEffect = {}
    self.SunZiEffect = {}
    self.LianDuiEffect = {}
    self.MultipleEffect = {}
    for i=1,3 do
        self.ZaDanEffect[i] = self:Find("GameEffect/PlayerEffect/Player"..i.."/ChuTypeEffect/zhadan")
        self.SunZiEffect[i] = self:Find("GameEffect/PlayerEffect/Player"..i.."/ChuTypeEffect/shunzi")
        self.LianDuiEffect[i] = self:Find("GameEffect/PlayerEffect/Player"..i.."/ChuTypeEffect/liandui")
        self.MultipleEffect[i] = self:Find("GameEffect/PlayerEffect/Player"..i.."/MultipleEffect")
    end
    self.ChunTian = self:Find("GameEffect/ChunTian")
    self.FeiJi = self:Find("GameEffect/FeiJi")
    self.HuoJian = self:Find("GameEffect/HuoJian")
end

------------------------------------------------------业务接口----------------------------------------------------
--初始化
function DouDiZhuMainView:InitOtherUI()
    self.bt_back.gameObject:SetActive(false)
    self.JieSuanButt.gameObject:SetActive(false)
    self.ComeAgainButt.gameObject:SetActive(false)
    self.InvateButt.gameObject:SetActive(false)
    self.ReadyButt.gameObject:SetActive(false)
    self.ContinueButt.gameObject:SetActive(false)
    self.PlayerOperatTips.gameObject:SetActive(false)
    self.TrustFlagVire.gameObject:SetActive(false)
    self.GameBeginEffect.gameObject:SetActive(false)
    self.GameEndEffect.gameObject:SetActive(false)
    self.DiZhuEffect.gameObject:SetActive(false)
    self.ChunTian.gameObject:SetActive(false)
    self.FeiJi.gameObject:SetActive(false)
    self.HuoJian.gameObject:SetActive(false)
    for i=1,3 do
        self.ZaDanEffect[i].gameObject:SetActive(false)
        self.SunZiEffect[i].gameObject:SetActive(false)
        self.LianDuiEffect[i].gameObject:SetActive(false)
    end
    self.BeiShu.text = "倍数: 0"
    for i,v in ipairs(self.AhandPks) do
       v.SetValue(0)
    end
end

--恢复
function DouDiZhuMainView:RestoreOtherUI(GameData)
    self.RoomId.text = "房间号 : "..GameData.RoomId
    self.JuNumLabel.text = GameData.IntoGameNum.."/"..GameData.AllGameNum.."局"
    self.DiFen.text = "底分: "..GameData.RoomRule.EndPointType
    self.BeiShu.text = "倍数: "..tostring(GameData.Table.BankerCallScore*math.pow(2,GameData.Table.MultipleNum))
    for i,v in ipairs(GameData.Table.AhandPks) do
        self.AhandPks[i].SetValue(v)
    end
    print("恢复 OtherUI 1")
    if GameData.Table.GameStatus == DouDiZhu.GameState.STEPNULL then
        if GameData.RoomRule.SettleType == 2 then
            self.bt_back.gameObject:SetActive(true)
        else
            self.bt_breakup.gameObject:SetActive(GameData.IntoGameNum > 0)
        end
        if GameData.IntoGameNum == 0 then
            self.InvateButt.gameObject:SetActive(GameData.CurrPlayerNum < GameData.GamePlayerNum)
            self.bt_back.gameObject:SetActive(true)
            if GameData.CreaterChairId == 1 then                                    --在未开具之前只有房主有权解散房间
                self.bt_breakup.gameObject:SetActive(true)
            end
        end
        if not GameData.Table.Players[1].IsReady then                                        --自己未准备
            self.ReadyButt.gameObject:SetActive(true)
        end
    else
        self.bt_breakup.gameObject:SetActive(GameData.AllGameNum > 1)
        if GameData.Table.Players[1].IsTrustFlag then
            self.TrustFlagVire.gameObject:SetActive(true)
        end
        if GameData.Table.GameStatus == DouDiZhu.GameState.FaPai then
            
        else
            if GameData.Table.GameStatus == DouDiZhu.GameState.CallScore then
                
            else

            end
        end
    end
end

function DouDiZhuMainView:HideGameEffect()
    self.GameBeginEffect.gameObject:SetActive(false)
    self.GameEndEffect.gameObject:SetActive(false)
end

function DouDiZhuMainView:ShowAhandPks(GameData)
    print("AhandPks 1")
    self.BeiShu.text = "倍数: "..tostring(GameData.Table.BankerCallScore*math.pow(2,GameData.Table.MultipleNum))
    print("AhandPks 2")
    for i,v in ipairs(GameData.Table.AhandPks) do
        print("AhandPks "..v)
        self.AhandPks[i].SetValue(v)
    end
    print("AhandPks 3")
end

--播放倍数动画
function DouDiZhuMainView:PlayMultiple(ChairId,GameData)
    StartCoroutine(function()
        WaitForSeconds(1)
        self.MultipleEffect[ChairId].gameObject:SetActive(true)
        local MultipleNum = self.MultipleEffect[ChairId]:Find("Num")
        MultipleNum:DOScale(2, 0.5)
        WaitForSeconds(1)
        MultipleNum:DOMove(self.BeiShu:GetTransform().position, 0.8)
        MultipleNum:DOScale(0, 0.8)
        WaitForSeconds(0.8)
        self.BeiShu.text = "倍数: "..tostring(GameData.Table.BankerCallScore*math.pow(2,GameData.Table.MultipleNum))
        self.MultipleEffect[ChairId].gameObject:SetActive(false)
        MultipleNum.gameObject:SetLocalPosition(0,0, 0)
    end)
end