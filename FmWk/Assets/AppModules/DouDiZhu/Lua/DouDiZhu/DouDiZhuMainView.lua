require "Common/ChatManager"

ClassView(PanelNames.DouDiZhuMainView, GameNames.DouDiZhu, UILayer.PanelHigh)

function DouDiZhuMainView:OnCreate()
    self.GameParamsValue = self.args[1][1];
    self:LoadGameRes(function()
        self.PKPrefab = self.DouDiZhuRes["PK"]
        require("DouWan/DouDiZhu/DouDiZhuUI_Player")
        require("DouWan/DouDiZhu/DouDiZhuUI_Other")
        require("DouWan/DouDiZhu/DouDiZhuUI_GPS")
        require("DouWan/DouDiZhu/DouDiZhu_Sound")
        require("DouWan/DouDiZhu/DouDiZhu_PK")
        require("DouWan/DouDiZhu/DouDiZhuUI_HandPks")
        require("DouWan/DouDiZhu/DouDiZhuUI_OutPks")
        require("DouWan/DouDiZhu/DouDiZhu_Operat")
        self:LoadPlayerInfos()
        self:LoadHandPKs()
        self:LoadOutPKs()
        self:LoadOtherUI()
        self:LoadOperat()
        self:LoadGPSView()
        self:LoadSound()
        self:InitUI()
        DouDiZhu.AddEventListener();         
        DouDiZhu.JoinRoomRequest(nil)
    end)
    self:PlayBgSound()
end

function DouDiZhuMainView:LoadGameRes(func)
    self.DouDiZhuRes = {}
    self.Index = 0
    for i,v in ipairs(DouDiZhuPKResConf) do
        if v.restype == 2 then
            self:LoadBundleSprite(GameNames.PokerRes,v.name, function (sprite)
                self.DouDiZhuRes[v.name] = sprite
                self.Index = self.Index + 1
                if self.Index == #DouDiZhuPKResConf then
                    if func then
                        func()
                    end
                end
            end)
        else
            self:LoadBundleObj(GameNames.PokerRes,v.name,function(prefab)
                self.DouDiZhuRes[v.name] = prefab
                self.Index = self.Index + 1
                if self.Index == #DouDiZhuPKResConf then
                    if func then
                        func()
                    end
                end
            end)
        end
    end
end

function DouDiZhuMainView:PlayBgSound()
    local BgSounds= {"game_bg_rapid","bgm2"}
    local Index =  math.random(100)%#BgSounds + 1
    Sound.PlayBackMusic(GameNames.DouDiZhu,BgSounds[Index], true, function (audio)
        self:StartTimer("PlayBgSound",audio.clip.length, function ()
            if audio then
                self:PlayBgSound()
            end
        end, 1)
    end)
end

function DouDiZhuMainView:InitUI()
    self:InitPlayerInfos()   
    self:InitHandPK()     
    self:InitOutPK()                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    self:InitOtherUI()
    self:InitGPS()
    self.OnFaPaiAnim = false
    self.OnJieSuanAnim = false
 end

 --唤醒游戏
function DouDiZhuMainView:AppAwakenGame(GameData)
    self:StopAllCoroutine()
    self:InitUI()
    self:InitDesk()
end

--恢复游戏
function DouDiZhuMainView:RestoreGame(GameData,RoomJieSanData)
    --优先恢复解散场景
    DismissManager.SetApplyDismissUsers(RoomJieSanData.AdvAppSettleUser)
    self:RestorePlayerInfos(GameData)
    self:RestoreOutPKs(GameData)
    self:RestoreHandPKs(GameData)
    self:RestoreOperat(GameData)
    self:RestoreOtherUI(GameData)
    self:RestoreGPS(GameData)
    --ChatManager.YayaChatSDKInit(self.ChatVoiceBtnGroup, GameData.RoomId);       --初始化语音聊天
end

--继续下一局游戏
function DouDiZhuMainView:GameContinue(GameData)
    self:InitUI()
    self.ReadyButt.gameObject:SetActive(true)
    if GameData.RoomRule.SettleType == 2 then
        self.bt_back.gameObject:SetActive(true)
        self.JuNumLabel.text = "局数: <color=#FDC241>"..GameData.IntoGameNum.."</color>/"..GameData.AllGameNum
    end
end

--结算界面直接返回主界面处理
function DouDiZhuMainView:BackMainView()
    local GameData = DouDiZhu.GetGameData()
    if GameData.IntoGameNum == GameData.AllGameNum or GameData.RoomResultData then       --房间结束了
        if GameData.IsClubRoom and GameData.RoomRule.SettleType == 2 and GameData.AllGameNum == 1 then
            self.bt_back.gameObject:SetActive(true)
            self.JieSuanButt.gameObject:SetActive(true)
            self.ComeAgainButt.gameObject:SetActive(false)
            self.ContinueButt.gameObject:SetActive(true)
        else
            self.bt_back.gameObject:SetActive(true)
            self.JieSuanButt.gameObject:SetActive(true)
            self.ReadyButt.gameObject:SetActive(false)
            self.ContinueButt.gameObject:SetActive(false)
        end
    else
        self.JieSuanButt.gameObject:SetActive(true)
        self.ContinueButt.gameObject:SetActive(true)
    end

end

--游戏再来一局初始化
function DouDiZhuMainView:GameComeAgain(GameData)
    self:InitUI()
end

function DouDiZhuMainView:StopAllCoroutine()
   
end


---------------------------------------------------游戏业务逻辑------------------------------------------------
--新玩家加入房间
function DouDiZhuMainView:PlayerIntoRoom(ChairId,GameData)
    self:ShowPlayer(ChairId,GameData)
    self:RestoreGPS(GameData)
    self.InvateButt.gameObject:SetActive(GameData.CurrPlayerNum < GameData.GamePlayerNum)
    if  GameData.IsClubRoom and GameData.RoomRule.SettleType == 2 and GameData.AllGameNum == 1 and not GameData.Table.Players[1].IsReady and GameData.AllGameNum > 1  and GameData.CurrPlayerNum == GameData.GamePlayerNum then
        self.PlayerOperatTips.gameObject:SetActive(true)
        self.PlayerOperatTipsLable.text = "90秒未准备将被踢出房间！"
    end
end

--玩家离开房间
function DouDiZhuMainView:PlayerLeave(ChairId,GameData)
    self.InvateButt.gameObject:SetActive(GameData.CurrPlayerNum < GameData.GamePlayerNum)
    self:HidePlayer(ChairId)
    self:RestoreGPS(GameData)
end

--玩家准备状态改变
function DouDiZhuMainView:PlayerReady(ChairId,GameData)
    local IsReady = GameData.Table.Players[ChairId].IsReady
    self.PlayerInfos[ChairId].ReadySigin.gameObject:SetActive(IsReady)
    if ChairId == 1 then
        if IsReady then
            self.PlayerOperatTips.gameObject:SetActive(false)
            self.ReadyButt.gameObject:SetActive(false)
        else
            self.ReadyButt.gameObject:SetActive(true)
        end
    end
end


--玩家货币改变
function DouDiZhuMainView:PlayerScoreChange(ChanageData,GameData)
    for i,v in ipairs(ChanageData) do  
        self.PlayerInfos[v.ChairId].Goldnum.text = tostring(numberToChineseString(GameData.Table.Players[v.ChairId].Score))
        self:UI_PlayerPlayScoreEffect(v.ChairId,v.ChanageValue)
    end
end

function DouDiZhuMainView:PlayerScoreNoAnimChange(GameData)
    for i,v in ipairs(GameData.Table.Players) do  
        self.PlayerInfos[i].Goldnum.text = tostring(numberToChineseString(GameData.Table.Players[i].Score))
    end
end

--玩家在线状态改变
function DouDiZhuMainView:PlayerIsOnline(ChairId,GameData)
    self:ShowPlayerOnline(ChairId,GameData)
    self.TrustFlagVire.gameObject:SetActive(GameData.Table.Players[1].IsTrustFlag)
end

--发牌
function DouDiZhuMainView:FaPai(GameData)
    self:InitGPS()
    self:HideReadySigin()
    self:HideCallScore()
    self:HideDaoJiShi()
    self:HideCallSoreEffect()
    self.bt_back.gameObject:SetActive(false)
    self.bt_breakup.gameObject:SetActive(GameData.AllGameNum > 1)
    self.JuNumLabel.text = "局数: <color=#FDC241>"..GameData.IntoGameNum.."</color>/"..GameData.AllGameNum
    self:InitHandPK()
    StartCoroutine(function()
        self.OnFaPaiAnim = true
        self.GameBeginEffect.gameObject:SetActive(true)
        self:PlaySound("mj_effect_start")
        WaitForSeconds(1)
        self.GameBeginEffect.gameObject:SetActive(false)
        for i=1,17 do
            for n=1,3 do
                self:HandFaPai(n,i,GameData.Table.Players[n].HandPKs[i])
            end
            self:PlaySound("fepai")
            WaitForSeconds(0.07)
        end
        WaitForSeconds(0.3)
        self:SortPlayerHandPks(GameData)
        self.OnFaPaiAnim = false
    end)
end

--玩家叫分
function DouDiZhuMainView:PlayerCallScore(ChairId,LastCallChairId,GameData)
    if LastCallChairId ~= 0 then    --前面有人已叫分
        self.BeiShu.text = "倍数: "..tostring(GameData.Table.BankerCallScore)
        self:PlaySound_CallScore(LastCallChairId,GameData.Table.CurCallScore,GameData)
        self:UI_PlayPlayerCallSoreEffect(LastCallChairId,GameData.Table.CurCallScore)
    end
    self:HideCallScore()
    self:HideDaoJiShi()
    if ChairId == 1 then
        self:ShowCallScore(GameData.Table.BankerCallScore,GameData.Table.OverCallNumTime)
    else
        self:ShowDaoJiShi(ChairId,GameData.Table.OverCallNumTime)
    end
end

--成功叫地主
function DouDiZhuMainView:SuccCallLandlord(ChairId,GameData)
    self:HideCallSoreEffect()
    self:HideCallScore()
    self:HideDaoJiShi()
    self:UI_PlayDiZhuEffect(ChairId)
    self:ShowAhandPks(GameData)
    self:SetHandPkLandlord(ChairId,GameData)
end

--显示玩家操作
function DouDiZhuMainView:ShowPlayerOperation(ChairId,GameData)
    print("显示玩家操作 1")
    self:HideOperatView()
    self:HideDaoJiShi()
    self:HideOutPKs(ChairId)
    if ChairId == 1 then
        self.RecommendList = nil
        self:ShowOperatView(GameData,GameData.Table.OperationTime)
    else
        self:ShowDaoJiShi(ChairId,GameData.Table.OperationTime)
    end
    print("显示玩家操作 10")
end

--玩家出牌
function DouDiZhuMainView:PlayerChuPai(ChairId,GameData)
    print("玩家出牌 1")
    self:PlaySound("shupai1")
    print("玩家出牌 2")
    self:HandPKChuPai(ChairId,GameData.Table.LastChuPaiPks,GameData)
    print("玩家出牌 3")
    self:PlayerOutPks(ChairId,GameData.Table.LastChuPaiPks,GameData,true)
    print("玩家出牌 4")
    local LeftPkNum =  #GameData.Table.Players[ChairId].HandPKs
    print("玩家出牌 5")
    if LeftPkNum > 0 and LeftPkNum<= 2 then
        print("玩家出牌 6")
        self:ShowAlarm(ChairId,LeftPkNum,GameData)
    end
    print("玩家出牌 10")
end

--玩家出牌过
function DouDiZhuMainView:PlayerChuPaiPass(ChairId,GameData)
    self:PlaySound_ChuPass(ChairId,GameData)
    self:UI_PlayPlayerCallSoreEffect(ChairId,4)
end

--出牌错误处理
function DouDiZhuMainView:PlayerOutError()
    ToastView.Show("出牌错误! 请重新出牌");
    self:ClearSelectPk()
end

--小结算
function DouDiZhuMainView:GameResult(GameData)
    self:HideOperatView()
    self:HideDaoJiShi()
    self:OutShowResult(GameData)
    --self:InitOutPK()
    self:HideAlarm()
    self:HideCallSoreEffect()
    self.OnJieSuanAnim = true
    --播放结算动画
    self.TrustFlagVire.gameObject:SetActive(false)
    self.JieSuanCoroutine = StartCoroutine(function()
        self:LiangPai()
        if GameData.Table.GameResultData and GameData.Table.GameResultData.SpringFlag then
            self.ChunTian.gameObject:SetActive(true) 
            self:PlaySound_ChunTian(GameData.Table.LastChuPaiChairId,GameData)
            WaitForSeconds(1)
        end
        WaitForSeconds(1)
        self.GameEndEffect.gameObject:SetActive(true)       --播放对局结束动画
        WaitForSeconds(1)
        self:HideGameEffect()
        if GameData.Table.GameResultData then 
            if GameData.Table.GameResultData.bAllResHasFlag then                --有大结算存在
                if GameData.RoomResultData then                                 --房间结算数据已经存在
                    CtrlManager.ReOpenCtrl(GameNames.DouDiZhu,CtrlNames.DouDiZhuRoomResult)
                end
            else
                CtrlManager.ReOpenCtrl(GameNames.DouDiZhu,CtrlNames.DouDiZhuGameResult)
            end
        end
        self.OnJieSuanAnim = false
    end)
end

--大结算界面
function DouDiZhuMainView:RoomResult(GameData)
    if not self.OnJieSuanAnim and GameData.RoomResultData then
        CtrlManager.ReOpenCtrl(GameNames.DouDiZhu,CtrlNames.DouDiZhuRoomResult)
    end
end


function DouDiZhuMainView:OnDestroy()
    DismissManager.ClearUserInfo();
end
