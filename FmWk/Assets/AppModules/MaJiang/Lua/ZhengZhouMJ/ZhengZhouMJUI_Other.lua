function ZhengZhouMJMainView:LoadOtherUI()
    self:LoadLeftBottom()
    self:LoadLeftTop()
    self:LoadRightTop()
    self:LoadCenterUI()
    self:LoadBottom()
    self:LoadGameEffect()
end

--加载界面左下方UI对象
function ZhengZhouMJMainView:LoadLeftBottom()
    self.bt_dengpao = self:Find("LeftBottomUI/bt_dengpao")  --查看听牌信息
    self.ChatButt = self:Find("LeftBottomUI/ChatButt")
    self.ChatRoot = self:Find("LeftBottomUI/ChatRoot")
    self.ChatVoiceBtnGroup = self:Find("LeftBottomUI/ChatVoiceBtnGroup")
    self.bt_dengpao:SetOnClick(function(evt, go, args)
        local GameData = ZhengZhouMJ.GetGameData()
        self:ShowPlayerTingDataView(GameData.Table.Players[1].TingData,true)
    end)
    self.ChatButt:SetOnClick(function(obj, evt, go, args)
		ChatManager.HandleChatComponent(self.ChatRoot, GameNames.ZhengZhouMJ);
    end)
    self.ChatVoiceBtnGroup.gameObject:SetActive(false)
end

--加载界面左上方方UI对象
function ZhengZhouMJMainView:LoadLeftTop()
    self.MoreButt = self:Find("LeftTopUI/MoreButt")         --更多
    self.MoreView = self:Find("LeftTopUI/MoreView")         --更多界面
    self.bt_tuoguan = self:Find("LeftTopUI/MoreView/bg/bt_tuoguan")      --托管
    self.bt_breakup = self:Find("LeftTopUI/MoreView/bg/bt_breakup")      --解散
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
        local GameData = ZhengZhouMJ.GetGameData()
        CtrlManager.OpenCtrl(GameNames.GameCenter, CtrlNames.SettingPanel, {fankui=true, help=true, account=false}, {gameId = GameData.GameId});
    end)
    self.bt_tuoguan:SetOnClick(function(evt, go, args)
        ZhengZhouMJ.SendIsTrustFlag(1)
    end)
    self.bt_breakup:SetOnClick(function(evt, go, args)
        local JieSan = ZhengZhouMJ.CanDisbandNow()
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
        local GameData = ZhengZhouMJ.GetGameData()
		CtrlManager.OpenCtrl(GameNames.Shared, CtrlNames.CommonGameRule, GameData.GameRuleInfoStrList)
    end)
    DismissManager.Initialize()         --初始化解散界面
end

--加载界面右上方方UI对象
function ZhengZhouMJMainView:LoadRightTop()
    self.bt_back = self:Find("RightTopUI/TopInfo/bt_back")           --返回
    self.JuNumObj = self:Find("RightTopUI/TopInfo/RoomInfo/JuNum")
    self.JuNumLabel =  self.JuNumObj:Find("JuNumLabel"):GetComponent("Text")
    self.MJLeftObj = self:Find("RightTopUI/TopInfo/RoomInfo/MJLeftNum")
    self.MJLeftNum =  self.MJLeftObj:Find("MJLeftNum"):GetComponent("Text")
    self.bt_back:SetOnClick(function(evt, go, args)
        local GameData = ZhengZhouMJ.GetGameData()
        --if GameData.IntoGameNum == GameData.AllGameNum or GameData.RoomResultData then     --房间结束
        if  GameData.RoomResultData then
            self.iCtrl:OnCallExitGame()
        else
            self.iCtrl:CallExitGame()
        end
    end)
    self.LaiZiTips = self:Find("RightTopUI/LaiZiTips")
    self.LaiZis = {}
    self.LaiZis[1] = {}
    self.LaiZis[1].Obj = self:Find("RightTopUI/LaiZiTips/LaiZi1")
    self.LaiZis[1].MJ = self:CreateUIMJ(self.LaiZis[1].Obj:Find("Card"),0);  
    self.LaiZis[2] = {}
    self.LaiZis[2].Obj = self:Find("RightTopUI/LaiZiTips/LaiZi2")
    self.LaiZis[2].MJ = self:CreateUIMJ(self.LaiZis[2].Obj:Find("Card"),0);  
end

--加载界面中间UI对象
function ZhengZhouMJMainView:LoadCenterUI()
    self.JieSuanButt =  self:Find("CenterUI/PlayerButts/JieSuanButt")           --结算详情
    self.InvateButt = self:Find("CenterUI/PlayerButts/InvateButt")              --邀请
    self.ReadyButt = self:Find("CenterUI/PlayerButts/ReadyButt")                --准备
    self.ContinueButt = self:Find("CenterUI/PlayerButts/ContinueButt")          --继续游戏
    self.ComeAgainButt = self:Find("CenterUI/PlayerButts/ComeAgainButt")        --再来一局
    self.JieSuanButt:SetOnClick(function(evt, go, args)                         --显示结算详情
        CtrlManager.ReOpenCtrl(GameNames.ZhengZhouMJ,CtrlNames.ZhengZhouMJGameResult)
    end)
    self.InvateButt:SetOnClick(function(evt, go, args)    
        ZhengZhouMJ.WXInvate()
    end)
    self.ReadyButt:SetOnClick(function(evt, go, args)
        ZhengZhouMJ.SendReadyState(1);
    end)
    self.ContinueButt:SetOnClick(function(evt, go, args)
        ZhengZhouMJ.GameContinue()
        ZhengZhouMJ.SendReadyState(1);
        self.ContinueButt.gameObject:SetActive(false)
    end)
    self.ComeAgainButt:SetOnClick(function(evt, go, args)
        self.ComeAgainButt.gameObject:SetActive(false)
        self.JieSuanButt.gameObject:SetActive(false)
        ZhengZhouMJ.GameComeAgain()
    end)
    self.PlayerOperatTips = self:Find("CenterUI/PlayerOperatTips")
    self.PlayerOperatTipsLable = self.PlayerOperatTips:Find("bg01/Tips"):GetComponent("Text")
    self.DaPiaoGroup = self:Find("CenterUI/DaPiaoGroup")
    for i=1,4 do
        self.DaPiaoGroup:Find(tostring(i-1)):SetOnClick(function(evt, go, args)
            ZhengZhouMJ.SendDaPiao(i-1)
        end)
    end
    self.TingDataView = self:Find("CenterUI/TingDataView")
    self.TingDataViewBg = self.TingDataView:Find("Bg"):GetComponent("RectTransform")
    self.TingDataViewMask = self.TingDataView:Find("Mask")
    self.TingDataViewLeftNum = self.TingDataView:Find("LeftNum"):GetComponent("Text")
    self.TingDataViewMJView = self.TingDataView:Find("MJView"):GetComponent("RectTransform")
    self.TingDataViewGurid =self.TingDataView:Find("MJView/Viewport/Content")
    self.TingDataViewItme =self.TingDataView:Find("Item")
    self.TingDataViewMask:SetOnClick(function(evt, go, args)    
        self:ShowPlayerTingDataView(nil,false)
    end)
end

function ZhengZhouMJMainView:LoadBottom()
    self.TrustFlagVire = self:Find("Bottom/TrustFlagVire")
    self.CancelTrustFlagButt = self.TrustFlagVire:Find("CancelTrustFlagButt")
    self.CancelTrustFlagButt:SetOnClick(function(evt, go, args)
        ZhengZhouMJ.SendIsTrustFlag(0)
    end)
end
     

--加载游戏特效
function ZhengZhouMJMainView:LoadGameEffect()
    self.GameBeginEffect = self:Find("GameEffect/GameBegin")
    self.GameLiuJuEffect = self:Find("GameEffect/GameLiuJu")
    self.GameEndEffect = self:Find("GameEffect/GameEnd")
    self.FanLaiZiEffect = self:Find("GameEffect/FanLaiZiEffect")
    self.FanLaiZiEffectPos = self.FanLaiZiEffect.position
end
---------------------------------------------初始化--------------------------------------------
function ZhengZhouMJMainView:InitOtherUI()
    self.bt_back.gameObject:SetActive(false)
    self.JieSuanButt.gameObject:SetActive(false)
    self.ComeAgainButt.gameObject:SetActive(false)
    self.InvateButt.gameObject:SetActive(false)
    self.ReadyButt.gameObject:SetActive(false)
    self.ContinueButt.gameObject:SetActive(false)
    self.bt_dengpao.gameObject:SetActive(false)
    self.PlayerOperatTips.gameObject:SetActive(false)
    self.TingDataView.gameObject:SetActive(false)
    self.TrustFlagVire.gameObject:SetActive(false)
    self.GameBeginEffect.gameObject:SetActive(false)
    self.GameLiuJuEffect.gameObject:SetActive(false)
    self.GameEndEffect.gameObject:SetActive(false)
    self.MJLeftObj.gameObject:SetActive(false)
    self.FanLaiZiEffect.gameObject:SetActive(false)
    self.LaiZis[1].Obj.gameObject:SetActive(false)
    self.LaiZis[2].Obj.gameObject:SetActive(false)
end

function ZhengZhouMJMainView:HideGameEffect()
    self.GameBeginEffect.gameObject:SetActive(false)
    self.GameLiuJuEffect.gameObject:SetActive(false)
    self.GameEndEffect.gameObject:SetActive(false)
end

--刷新剩余牌
function ZhengZhouMJMainView:UpDataLeftMJNum(GameData)
    self.MJLeftNum.text = tostring(self:GetLeftMJNum())
end

--播放UI赖子动画
function ZhengZhouMJMainView:PlayUIlaiZiEffect(GameData)
    for i,v in ipairs(GameData.Table.LaiZis) do
        if v ~= 0 then
            local obj = self.FanLaiZiEffect:Find("MJs/Card"..i)
            local MJ = self:CreateUIMJ(obj,v)
            obj.gameObject:SetActive(true)
        end
    end
    self.FanLaiZiEffect.position = self.FanLaiZiEffectPos 
    self.FanLaiZiEffect.localScale = Vector3.one
    self.FanLaiZiEffect:Find("bg01").gameObject:SetActive(true)
    self.FanLaiZiEffect:Find("bg02").gameObject:SetActive(true)
    self.FanLaiZiEffect.gameObject:SetActive(true)
    WaitForSeconds(1)
    self.FanLaiZiEffect:Find("bg01").gameObject:SetActive(false)
    self.FanLaiZiEffect:Find("bg02").gameObject:SetActive(false)
    self.FanLaiZiEffect:DOMove(self.LaiZiTips.position, 0.6)
    self.FanLaiZiEffect:DOScale(0.5, 0.6)
    WaitForSeconds(0.6)
    self.FanLaiZiEffect.gameObject:SetActive(false)
    self:SetLaiZis(GameData)
end

--设置赖子
function ZhengZhouMJMainView:SetLaiZis(GameData)
    for i,v in ipairs(GameData.Table.LaiZis) do
        if v ~= 0 then
           self.LaiZis[i].Obj.gameObject:SetActive(true)
           self.LaiZis[i].MJ.SetValue(v)
        end
    end
end

function ZhengZhouMJMainView:HidePlayerTingDataView()
    self.IsShowTingDataView = false
    self.TingDataViewItems = nil
    self.TingDataView.gameObject:SetActive(false)
    self.TingDataViewGurid:RemoveAllChild()
end

-- --显示玩家听牌数据界面
function ZhengZhouMJMainView:ShowPlayerTingDataView(HuData,IsMask)
   
    if not self.IsShowTingDataView and not self.TingDataViewItems and  HuData and #HuData >0 then
        local Count = #HuData
        self.TingDataViewItems = {}
        self.TingDataView.gameObject:SetActive(true)
        self.TingDataViewMask.gameObject:SetActive(IsMask)
        self.IsShowTingDataView = true
        local AllNum = 0
        for i,v in ipairs(HuData) do
            local Item = {}
            Item.Data = v
            local obj = self:InstantionGameObject(self.TingDataViewItme, self.TingDataViewGurid, tostring(i))
            obj.gameObject:SetActive(true)
            local MJ = self:CreateUIMJ(obj:Find("Card"),v.MJ)
            local BieShu = obj:Find("BeiShu"):GetComponent("Text")
            local LeftNumObj = obj:Find("LeftNum")
            local LeftNumText = LeftNumObj:Find("Text"):GetComponent("Text")
            BieShu.text = v.Multiple.."倍"
            LeftNumText.text = tostring(v.LeftNum)
            if v.LeftNum <= 0 then
                LeftNumObj.gameObject:SetActive(false)
                MJ.SetGray(true)
            end
            Item.MJ = MJ
            Item.BieShu = BieShu
            Item.LeftNumObj = LeftNumObj
            Item.LeftNumText = LeftNumText
            AllNum = AllNum + v.LeftNum
            table.insert( self.TingDataViewItems,Item)
        end
        self.TingDataViewLeftNum.text = tostring(AllNum)
        if Count >= 9 then Count = 9 end    --当长度大于4个的时候这个时候 采用滑动方式
        self.TingDataViewMJView.sizeDelta = Vector2(Count*110,164)
        self.TingDataViewBg.sizeDelta = Vector2(130+Count*110,200)
        self.TingDataView.gameObject:SetLocalPosition((Count-1)*-55, -150, 0)
    else
        self.TingDataViewItems = nil
        self.TingDataViewGurid:RemoveAllChild()
        self.TingDataView.gameObject:SetActive(false)
        self.IsShowTingDataView = false
    end
end


function ZhengZhouMJMainView:UpDatePlayerTingDataView()
    if self.IsShowTingDataView then
        local AllNum = 0
        for i,v in ipairs(self.TingDataViewItems) do
            v.Data.LeftNum = ZhengZhouMJ.GetLeftMJNum(v.Data.MJ)
            if v.Data.LeftNum <= 0 then
                v.LeftNumObj.gameObject:SetActive(false)
                v.MJ.SetGray(true)
            else
                v.LeftNumText.text = tostring(v.Data.LeftNum)
            end
            AllNum = AllNum + v.Data.LeftNum
        end
        self.TingDataViewLeftNum.text = tostring(AllNum)
    end
end

--创建UI麻将类对象
function ZhengZhouMJMainView:CreateUIMJ(_MJObj,_Value)
    local MJ={MJObj =_MJObj, Value = _Value}
    MJ.MJImage = MJ.MJObj:Find("MJ"):GetComponent("Image")
    MJ.LaiZi = MJ.MJObj:Find("LaiZi").gameObject
    MJ.SetValue = function(Value)
        if Value == 0 then return end
        local t,v
        if Value and Value ~= 0 then
            t,v = math.modf(Value/16)
            v = v*16
        else    
            t = 11
        end
        if t <= 3 then
            MJ.CValue = (t-1)*10 + v
        else
            MJ.CValue = (t-3) + 30
        end
        self:LoadBundleSprite(GameNames.ZhengZhouMJ,"UIMJ_"..MJ.CValue, function (sprite)
            MJ.MJImage.sprite = sprite
        end)
        MJ.LaiZi:SetActive(ZhengZhouMJ.IsLaiZi(Value))
    end
    MJ.SetGray = function(IsGray)
        if IsGray then
            MJ.MJImage.color = Color(0.5,0.5,0.5,1)
        else
            MJ.MJImage.color = Color(1,1,1,1)
        end
    end
    MJ.SetValue(MJ.Value)
    return MJ
end