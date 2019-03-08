require "Common/ChatManager"

ClassView(PanelNames.ZhengZhouMJMainView, GameNames.ZhengZhouMJ, UILayer.PanelHigh)

function ZhengZhouMJMainView:OnCreate()
    self.GameParamsValue = self.args[1][1];
    require("DouWan/ZhengZhouMJ/ZhengZhouMJUI_Player")
    require("DouWan/ZhengZhouMJ/ZhengZhouMJUI_Other")
    require("DouWan/ZhengZhouMJ/ZhengZhouMJUI_OperatGroup")
    require("DouWan/ZhengZhouMJ/ZhengZhouMJUI_GPS")
    require("DouWan/ZhengZhouMJ/ZhengZhouMJ_Sound")
    self:LoadPlayerInfos()
    self:LoadOtherUI()
    self:LoadOperatGroup()
    self:LoadGPSView()
    self:LoadSound()
    self:InitUI()
    self:PlayBgSound()
    self:LoadDesk(function()                --在房间初始化之前不接受任何消息事件
        ZhengZhouMJ.AddEventListener();         
        ZhengZhouMJ.JoinRoomRequest(nil)
    end)
end

function ZhengZhouMJMainView:PlayBgSound()
    local BgSounds= {"zhengzhoumjbg01","zhengzhoumjbg02"}
    local Index =  math.random(100)%#BgSounds + 1
    Sound.PlayBackMusic(GameNames.ZhengZhouMJ,BgSounds[Index], true, function (audio)
        self:StartTimer("PlayBgSound",audio.clip.length, function ()
            if audio then
                self:PlayBgSound()
            end
        end, 1)
    end)
    --soundMgr:SetBackMusicVolume(0.5)
end



function ZhengZhouMJMainView:InitUI()
    self:InitPlayerInfos()                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    self:InitOtherUI()
    self:InitOperatGroup()
    self:InitGPS()
    self.OnFaPaiAnim = false
    self.OnJieSuanAnim = false
    self.DingZhangCoroutine = nil
    self.DaPiaoCoroutine = nil
    self.FaPaiCoroutine = nil
    self.JieSuanCoroutine = nil
 end

 --唤醒游戏
function ZhengZhouMJMainView:AppAwakenGame(GameData)
    self:StopAllCoroutine()
    self:InitUI()
    self:InitDesk()
    -- self:RestoreGameUI(GameData)
    -- self:RestoreGameDesk(GameData)
end

--恢复游戏
function ZhengZhouMJMainView:RestoreGame(GameData,RoomJieSanData)
    --优先恢复解散场景
    DismissManager.SetApplyDismissUsers(RoomJieSanData.AdvAppSettleUser);
    self:RestoreGameUI(GameData)
    self:RestoreGameDesk(GameData)
    --ChatManager.YayaChatSDKInit(self.ChatVoiceBtnGroup, GameData.RoomId);       --初始化语音聊天
end

--继续下一局游戏
function ZhengZhouMJMainView:GameContinue(GameData)
    self:InitUI()
    self:InitDesk()
    self.ReadyButt.gameObject:SetActive(true)
    if GameData.RoomRule.SettleType == 2 then
        self.bt_back.gameObject:SetActive(true)
        self.JuNumLabel.text = "局数: <color=#FDC241>"..GameData.IntoGameNum.."</color>/"..GameData.AllGameNum
    end
end

--结算界面直接返回主界面处理
function ZhengZhouMJMainView:BackMainView()
    local GameData = ZhengZhouMJ.GetGameData()
    if GameData.IntoGameNum == GameData.AllGameNum or GameData.RoomResultData then       --房间结束了
        if GameData.IsClubRoom and GameData.RoomRule.SettleType == 2 and GameData.AllGameNum == 1 then
            self.bt_back.gameObject:SetActive(true)
            self.JieSuanButt.gameObject:SetActive(GameData.Table.GameResultData ~= nil)
            self.ComeAgainButt.gameObject:SetActive(false)
            self.ContinueButt.gameObject:SetActive(true)
        else
            self.bt_back.gameObject:SetActive(true)
            self.JieSuanButt.gameObject:SetActive(GameData.Table.GameResultData ~= nil)
            self.ReadyButt.gameObject:SetActive(false)
            self.ContinueButt.gameObject:SetActive(false)
        end
    else
        self.JieSuanButt.gameObject:SetActive(GameData.Table.GameResultData ~= nil)
        self.ContinueButt.gameObject:SetActive(not self.ReadyButt.gameObject.activeSelf)
    end

end

--游戏再来一局初始化
function ZhengZhouMJMainView:GameComeAgain(GameData)
    self:InitUI()
    self:InitDesk()
end

function ZhengZhouMJMainView:StopAllCoroutine()
    StopCoroutine(self.DingZhangCoroutine)  
    StopCoroutine(self.DaPiaoCoroutine)  
    StopCoroutine(self.FaPaiCoroutine) 
    StopCoroutine(self.JieSuanCoroutine) 
end

--------------------------------------------刷新UI---------------------------------------------------------
--刷新整體UI
function ZhengZhouMJMainView:RestoreGameUI(GameData)
    self:RestorePlayerInfos()
    self.JuNumLabel.text = "局数: <color=#FDC241>"..GameData.IntoGameNum.."</color>/"..GameData.AllGameNum
    if GameData.Table.GameStatus == ZhengZhouMJ.GameState.STEPNULL then             --牌局未开始
        self:RestoreGPS(GameData)
        self.InvateButt.gameObject:SetActive(GameData.CurrPlayerNum < GameData.GamePlayerNum)
        if GameData.IntoGameNum == 0 then
            self.bt_back.gameObject:SetActive(true)
            if GameData.CreaterChairId == 1 then                                    --在未开具之前只有房主有权解散房间
                self.bt_breakup.gameObject:SetActive(true)
            end
            if  GameData.IsClubRoom and GameData.RoomRule.SettleType == 2 and GameData.AllGameNum == 1 and not GameData.Table.Players[1].IsReady and GameData.AllGameNum > 1  and GameData.CurrPlayerNum == GameData.GamePlayerNum then
                self.PlayerOperatTips.gameObject:SetActive(true)
                self.PlayerOperatTipsLable.text = "90秒未准备将被踢出房间！"
            end
        else
            self.bt_breakup.gameObject:SetActive(GameData.AllGameNum > 1)
        end
        if GameData.RoomRule.SettleType == 2 then
            self.bt_back.gameObject:SetActive(true)
        end
        for i,v in ipairs(GameData.Table.Players) do
            self.PlayerInfos[i].ReadySigin.gameObject:SetActive(v.IsReady)
            self.PlayerInfos[i].DaPiao.gameObject:SetActive(false)
            self.PlayerInfos[i].ZhuangSign.gameObject:SetActive(false)
            if i == 1 and not v.IsReady then                                        --自己未准备
                self.ReadyButt.gameObject:SetActive(true)
                self.ContinueButt.gameObject:SetActive(false)
            end
        end
    else                                                                            --已开局
        self.bt_breakup.gameObject:SetActive(GameData.AllGameNum > 1)
        self.MJLeftObj.gameObject:SetActive(true)
        self.PlayerInfos[GameData.Table.BankerChairId].ZhuangSign.gameObject:SetActive(true)
        if GameData.Table.GameStatus == ZhengZhouMJ.GameState.STEPDRIFTING then     --大票中
            if GameData.Table.Players[1].DaPiaoNum == -1 then                       --自己未打票
                self.DaPiaoGroup.gameObject:SetActive(true)
            end
        else
            self.DaPiaoGroup.gameObject:SetActive(false)
            if GameData.Table.Players[1].IsTrustFlag then
                self.TrustFlagVire.gameObject:SetActive(true)
            end
            if GameData.Table.GameStatus == ZhengZhouMJ.GameState.STEPDICE then  --正常行牌中
                self:SetLaiZis(GameData)
            elseif GameData.Table.GameStatus >= ZhengZhouMJ.GameState.STEPNOMAROUT then  --正常行牌中
                self:SetLaiZis(GameData)
                self:UI_PlayerShwoChuPaiEffect(GameData.Table.CurRunChairId)
                if #GameData.Table.Players[1].Operations > 0 then                    --当前自己有操作
                    self:ShowOperation(GameData)
                else
                    for i,v in ipairs(GameData.Table.Players) do
                        if i ~= 1 and #GameData.Table.Players[i].Operations > 0 then
                            self.PlayerOperatTips.gameObject:SetActive(true)
                            self.PlayerOperatTipsLable.text = "等待其他玩家选择:碰,杠,胡"
                            break
                        end
                    end
                end
                if GameData.Table.Players[1].IsTing then
                    self.bt_dengpao.gameObject:SetActive(true)
                end
            end
        end
    end
end

---------------------------------------------------游戏业务逻辑------------------------------------------------
--新玩家加入房间
function ZhengZhouMJMainView:PlayerIntoRoom(ChairId,GameData)
    self:ShowPlayer(ChairId,GameData)
    self:RestoreGPS(GameData)
    self.InvateButt.gameObject:SetActive(GameData.CurrPlayerNum < GameData.GamePlayerNum)
    if  GameData.IsClubRoom and GameData.RoomRule.SettleType == 2 and GameData.AllGameNum == 1 and not GameData.Table.Players[1].IsReady and GameData.AllGameNum > 1  and GameData.CurrPlayerNum == GameData.GamePlayerNum then
        self.PlayerOperatTips.gameObject:SetActive(true)
        self.PlayerOperatTipsLable.text = "90秒未准备将被踢出房间！"
    end
end

--玩家离开房间
function ZhengZhouMJMainView:PlayerLeave(ChairId,GameData)
    self.InvateButt.gameObject:SetActive(GameData.CurrPlayerNum < GameData.GamePlayerNum)
    self:HidePlayer(ChairId)
    self:RestoreGPS(GameData)
end

--玩家准备状态改变
function ZhengZhouMJMainView:PlayerReady(ChairId,GameData)
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
function ZhengZhouMJMainView:PlayerScoreChange(ChanageData,GameData)
    for i,v in ipairs(ChanageData) do  
        self.PlayerInfos[v.ChairId].Goldnum.text = tostring(numberToChineseString(GameData.Table.Players[v.ChairId].Score))
        self:UI_PlayerPlayScoreEffect(v.ChairId,v.ChanageValue)
    end
end

function ZhengZhouMJMainView:PlayerScoreNoAnimChange(GameData)
    for i,v in ipairs(GameData.Table.Players) do  
        self.PlayerInfos[i].Goldnum.text = tostring(numberToChineseString(GameData.Table.Players[i].Score))
    end
end

--玩家在线状态改变
function ZhengZhouMJMainView:PlayerIsOnline(ChairId,GameData)
    self:ShowPlayerOnline(ChairId,GameData)
    self.TrustFlagVire.gameObject:SetActive(GameData.Table.Players[1].IsTrustFlag)
end

--定庄
function ZhengZhouMJMainView:DingZhang(GameData)
    self.bt_back.gameObject:SetActive(false)
    self.bt_breakup.gameObject:SetActive(GameData.AllGameNum > 1)
    self.JuNumLabel.text = "局数: <color=#FDC241>"..GameData.IntoGameNum.."</color>/"..GameData.AllGameNum
    self:XiPaiInit(GameData)
    self.DingZhangCoroutine = StartCoroutine(function()
        WaitForEndOfFrame()
        self:InitGPS()
        self:HideReadySigin()
        self.GameBeginEffect.gameObject:SetActive(true)
        self:PlaySound("mj_effect_start")
        WaitForSeconds(1)
        self.GameBeginEffect.gameObject:SetActive(false)
        self.PlayerInfos[GameData.Table.BankerChairId].ZhuangSign.gameObject:SetActive(true)
        Yield(self.XiPaiAnim(self)) 
        self.MJLeftObj.gameObject:SetActive(true)
        self:UpDataLeftMJNum(GameData)
    end)
end

--开始打票
function ZhengZhouMJMainView:StartDaPiao(GameData)
    self.DaPiaoCoroutine = StartCoroutine(function()
        WaitForSeconds(2)
        if GameData.Table.GameStatus == ZhengZhouMJ.GameState.STEPDRIFTING then
            self.PlayerOperatTips.gameObject:SetActive(true)
            self.PlayerOperatTipsLable.text = "请选择下跑分数"
            self:PlayDaoJiShi(GameData.Table.DaPiaoTime)
            for i,v in ipairs(self.PlayerInfos) do
                v.ReadySigin.gameObject:SetActive(false)
            end
            if GameData.Table.Players[1].DaPiaoNum == -1 then
                self.DaPiaoGroup.gameObject:SetActive(true)
            end
        end
    end)
end

--玩家打票
function ZhengZhouMJMainView:PlayerDaPiao(ChairId,GameData)
    if ChairId == 1 then
        self.DaPiaoGroup.gameObject:SetActive(false)
        self.PlayerOperatTips.gameObject:SetActive(false)
    end
    self:UI_PlayDaPiaoEffect(ChairId,GameData.Table.Players[ChairId].DaPiaoNum)
end

--发牌
function ZhengZhouMJMainView:FaPai(GameData)
    --发牌动画
    for i,v in ipairs(self.PlayerInfos) do
        v.ReadySigin.gameObject:SetActive(false)
    end
    self.FaPaiCoroutine = StartCoroutine(function()
        WaitForEndOfFrame()
        self.OnFaPaiAnim = true
        self:HideDaoJiShi()
        self:SetDeskCardPierStartPoint(GameData)        --根据筛子确定起牌点
        self:PlayShaiZiAnim(GameData.Table.FirstDices[1],GameData.Table.FirstDices[2])
        WaitForSeconds(2)
        self:PlayShaiZiAnim(GameData.Table.SecondDices[1],GameData.Table.SecondDices[2])
        WaitForSeconds(3)
        for j=1,3 do
            for i=1,4 do
                if GameData.Table.Players[i].PlayerInfo.UserID ~= 0  then               --玩家存在才发牌
                    self:DeskCardPMoPai(4,false)
                    for n=1,4 do
                        local Index = (j-1)*4+n
                        --print("发牌动画 j="..j.."i"..i.."n"..n.."Index"..Index.."MJ"..tostring(GameData.Table.Players[i].HandMJ[Index]))
                        self:HandFaPai(i,Index,GameData.Table.Players[i].HandMJ[Index])
                    end
                    self:UpDataLeftMJNum(GameData)
                    self:PlaySound("mj_effect_fapai")
                    WaitForSeconds(0.3)
                end
            end
        end
        for i=1,4 do
            if GameData.Table.Players[i].PlayerInfo.UserID ~= 0  then                   --玩家存在才发牌
                self:DeskCardPMoPai(1,false)
                self:HandFaPai(i,13,GameData.Table.Players[i].HandMJ[13])
                self:PlaySound("mj_effect_fapai")
                WaitForSeconds(0.3)
            end
        end
        self:HideShaiZi()
        if GameData.Table.RemakeID ~= 0 then
            WaitForSeconds(0.5)
            Yield(self:PlayCameraLaiZiAnim(GameData))
            -- self:FanLaiZi(GameData)
            WaitForSeconds(0.8)
            --self:SetLaiZis(GameData)
            Yield(self:PlayUIlaiZiEffect(GameData))
        end
        Yield(self.HandFaPaiStorAnim(self,GameData))
        self.OnFaPaiAnim = false
        self:ShowOperation(GameData)
    end)
end

--摸牌
function ZhengZhouMJMainView:MoPai(ChairId,BackFlag,GameData)
    self:InitOperatGroup()
    self:HideDaoJiShi()
    self:HideDeskDirectionAnim()
    self:DeskCardPMoPai(1,BackFlag)
    self:UpDataLeftMJNum(GameData)
    if BackFlag then self:SetLaiPos() end
    self:HandMoPai(ChairId,GameData.Table.Players[ChairId].MoPaiMJ)
    self:PlayDaoJiShi(GameData.Table.OperationTime)
    self:PlayDeskDirectionAnim(ChairId)
    self:UI_PlayerShwoChuPaiEffect(ChairId)
end


function ZhengZhouMJMainView:ShowCanTingMJ(GameData)
    self:ShowCanTingHandMJ(GameData)
end

function ZhengZhouMJMainView:ShowQueryHuView(GameData)
    if self.SelectMJ then
        for i,v in ipairs(GameData.Table.Players[1].CanHuData) do
            if v.OutMJ == self.SelectMJ:GetValue() then
                self:ShowPlayerTingDataView(v.HuMJs,false)
                return
            end
        end
    end
    if #GameData.Table.Players[1].TingData > 0 and not ZhengZhouMJ.IsCanOutMJ() then    --非自己出牌的时候才使用
        self.bt_dengpao.gameObject:SetActive(true)
    else
        if not GameData.Table.Players[1].IsTing then
            self.bt_dengpao.gameObject:SetActive(false)
        end
    end
end

function ZhengZhouMJMainView:PlayerShowOperation(GameData)
    self:HideDaoJiShi()
    self:PlayDaoJiShi(GameData.Table.OperationTime)
    self:ShowOperation(GameData)
    if self.IsShowTingDataView then
        self:ShowPlayerTingDataView(nil,false)
    end
end

--玩家行为
function ZhengZhouMJMainView:PlayAction(ChairId,Type,MJ,GameData)
    self:InitOperatGroup()
    self:UpDatePlayerTingDataView()
    if Type == ZhengZhouMJ.MJHandleType.MAHJSTANULL then                --出牌
        self:ChuPai(ChairId,MJ,GameData)
    elseif Type == ZhengZhouMJ.MJHandleType.MAHJSTATOUCH then           --碰牌
        self:PenPai(ChairId,MJ,GameData)
    elseif Type == ZhengZhouMJ.MJHandleType.MAHJSTAABAR then           --明杠
        self:MGang(ChairId,MJ,GameData)
    elseif Type == ZhengZhouMJ.MJHandleType.MAHJSTAREPAIRBAR then      --补杠
        self:BGang(ChairId,MJ,GameData)  
    elseif Type == ZhengZhouMJ.MJHandleType.MAHJSTADARKBAR then        --暗杠
        self:AGang(ChairId,MJ,GameData)
    elseif Type == ZhengZhouMJ.MJHandleType.MAHJSTARLISTEN then         --听
        self:Ting(ChairId,GameData)
    elseif Type == ZhengZhouMJ.MJHandleType.MAHJSTAOWNDRAW then         --自摸
        self:ZiMo(ChairId,GameData)
    elseif Type == ZhengZhouMJ.MJHandleType.MAHJSTATOUCHWIN then        --点炮
        self:DianPao(ChairId,GameData)
    end
end

--出牌
function ZhengZhouMJMainView:ChuPai(ChairId,MJ,GameData)
    self:HandMJChuPai(ChairId,MJ,GameData)
    self:OutMJChuPai(ChairId,GameData)
    self:PlaySound("effect_tuidao")
    if ChairId == 1 then
        if #GameData.Table.Players[1].TingData > 0 then
            self.bt_dengpao.gameObject:SetActive(true)
        else
            self.bt_dengpao.gameObject:SetActive(false)
        end
    end
end

--碰牌
function ZhengZhouMJMainView:PenPai(ChairId,MJ,GameData)
    self:HideDaoJiShi()
    self:HideDeskDirectionAnim()
    self:LastOutMJToChair(ChairId,GameData)
    self:HandMJPengPai(ChairId,MJ,GameData)
    self:HandleMJ_PenPai(ChairId,GameData)
    self:PlayDaoJiShi(GameData.Table.OperationTime)
    self:PlayDeskDirectionAnim(ChairId)
    self:UI_PlayerShwoChuPaiEffect(ChairId)
    self:UI_PlayerPlayOperateEffect(ChairId,ZhengZhouMJ.MJHandleType.MAHJSTATOUCH)
    self:PlaySound("mj_effect_peng")
    self:PlaySound_Peng(ChairId,GameData)
end

--明杠
function ZhengZhouMJMainView:MGang(ChairId,MJ,GameData)
    self:HideDaoJiShi()
    self:HideDeskDirectionAnim()
    self:LastOutMJToChair(ChairId,GameData)
    self:HandMJMGang(ChairId,MJ,GameData)
    self:HandleMJ_MGang(ChairId,GameData)
    self:UI_PlayerPlayOperateEffect(ChairId,ZhengZhouMJ.MJHandleType.Gang)
    self:PlaySound_Gang(ChairId,GameData)
end

--补杠
function ZhengZhouMJMainView:BGang(ChairId,MJ,GameData)
    self:HideDaoJiShi()
    self:HideDeskDirectionAnim()
    self:HandMJBGang(ChairId,MJ,GameData)
    self:HandleMJ_BGang(ChairId,MJ,GameData)
    self:UI_PlayerPlayOperateEffect(ChairId,ZhengZhouMJ.MJHandleType.Gang)
    self:PlaySound("mj_effect_peng")
    self:PlaySound_Gang(ChairId,GameData)
end

--暗杠
function ZhengZhouMJMainView:AGang(ChairId,MJ,GameData)
    self:HideDaoJiShi()
    self:HideDeskDirectionAnim()
    self:HandMJAGang(ChairId,MJ,GameData)
    self:HandleMJ_AGang(ChairId,GameData)
    self:UI_PlayerPlayOperateEffect(ChairId,ZhengZhouMJ.MJHandleType.Gang)
    self:PlaySound("mj_effect_peng")
    self:PlaySound_Gang(ChairId,GameData)
end

--听牌
function ZhengZhouMJMainView:Ting(ChairId,GameData)
    self:HandMJTing(ChairId,GameData)
    self:UI_PlayerPlayOperateEffect(ChairId,ZhengZhouMJ.MJHandleType.MAHJSTARLISTEN)
    self:PlaySound("mj_effect_peng")
    self:PlaySound_Ting(ChairId,GameData)
    self:RestoreGameHandleMJ(GameData)
end

--自摸
function ZhengZhouMJMainView:ZiMo(ChairId,GameData)
    self:HideDaoJiShi()
    self:HideDeskDirectionAnim()
    self:HideAllOperateEffect()
    self:UI_PlayerPlayOperateEffect(ChairId,ZhengZhouMJ.MJHandleType.MAHJSTAOWNDRAW)
    self:PlaySound_ZiMo(ChairId,GameData)
    self:LoadObject("MJ_Effect_3d_hu",self.Desk, "ZiMoEffect", function(obj)
        obj:GetTransform().position = self:GetChairIdMoPai(ChairId).position
        obj:GetTransform().rotation = Quaternion.Euler(-90,0,0);
    end)
end

--点炮
function ZhengZhouMJMainView:DianPao(ChairId,GameData)
    self:HideDaoJiShi()
    self:HideDeskDirectionAnim()
    self:HideAllOperateEffect()
    self:PlaySound_Hu(ChairId,GameData)
    self:UI_PlayerPlayOperateEffect(ChairId,ZhengZhouMJ.MJHandleType.MAHJSTATOUCHWIN)
    self:PlaySound("mj_effect_peng")
    self:LoadObject("MJ_Effect_3d_hu_out",self.Desk, "DianPaoEffect", function(obj)
        obj:GetTransform().position = self:GetLastOutMJTran(GameData).position
        obj:GetTransform().rotation = Quaternion.Euler(-90,0,0);
    end)
    StartCoroutine(function()
        WaitForSeconds(1)
        local LastIndex = #GameData.Table.Players[GameData.Table.LastChuPaiChairId].OutMJ
        self.OutMJ[GameData.Table.LastChuPaiChairId].MJs[LastIndex]:Hide()
        self.LastMJTips.gameObject:SetActive(false);
        self:HandMJDianPao(ChairId,self.OutMJ[GameData.Table.LastChuPaiChairId].MJs[LastIndex]:GetValue(),GameData)
    end)
end

--小结算
function ZhengZhouMJMainView:GameResult(GameData)
    self:HidePlayerTingDataView()
    self.TrustFlagVire.gameObject:SetActive(false)
    self.OnJieSuanAnim = true
    --播放结算动画
    self.JieSuanCoroutine = StartCoroutine(function()
        WaitForSeconds(1)
        self:HandMJDaoPai()    --到牌
        self:PlaySound("effect_tuidao")
        WaitForSeconds(2)
        if GameData.Table.GameResultData.FlowBureauFlag then --刘局
            self.GameLiuJuEffect.gameObject:SetActive(true)     --播放刘局动画
        else
            self.GameEndEffect.gameObject:SetActive(true)       --播放对局结束动画
        end
        WaitForSeconds(2)
        self:HideGameEffect()
        if GameData.Table.GameResultData then 
            if GameData.Table.GameResultData.bAllResHasFlag then                  --有大结算存在
                if GameData.RoomResultData then                    --房间结算数据已经存在
                    CtrlManager.ReOpenCtrl(GameNames.ZhengZhouMJ,CtrlNames.ZhengZhouMJRoomResult)
                end
            else
                CtrlManager.ReOpenCtrl(GameNames.ZhengZhouMJ,CtrlNames.ZhengZhouMJGameResult)
            end
        end
        self.OnJieSuanAnim = false
    end)
end

--大结算界面
function ZhengZhouMJMainView:RoomResult(GameData)
    if not self.OnJieSuanAnim and GameData.RoomResultData then
        CtrlManager.ReOpenCtrl(GameNames.ZhengZhouMJ,CtrlNames.ZhengZhouMJRoomResult)
    end
end


---------------------------------------------------加载桌子对象管理-------------------------------------------------
function ZhengZhouMJMainView:LoadDesk(backCall)
    self:LoadObject("ZhnegZhouMJDesk", nil, "ZhnegZhouMJDesk", function(obj)
        obj:SetLocalPosition(1000, 0, 100)
        self.Desk = obj:GetTransform()
        self:LoadBundleObj(GameNames.ZhengZhouMJ,"ZhengZhouMJCard",function(prefab)
            self.MJPrefab = prefab
            self:LoadBundleObj(GameNames.ZhengZhouMJ,"MJCardAnimController",function(prefab1)
                self.MJAnimController = prefab1
                self:LoadBundleObj(GameNames.ZhengZhouMJ,"ZhengZhouOperatMJ",function(prefab2)
                    print("加载完 麻将资源了"..tostring(prefab2))
                    self.OperatMJ = prefab2
                    self:LoadDeskMJ()
                    self:InitDesk()
                    if backCall then
                        backCall()
                    end
                end)
            end)
        end)
    end)
end

function ZhengZhouMJMainView:LoadDeskMJ()
    require("DouWan/ZhengZhouMJ/ZhengZhouMJTable_DeskObj")
    require("DouWan/ZhengZhouMJ/ZhengZhouMJTable_CardPier")
    require("DouWan/ZhengZhouMJ/ZhengZhouMJTable_OutMJ")
    require("DouWan/ZhengZhouMJ/ZhengZhouMJTable_HandMJ")
    require("DouWan/ZhengZhouMJ/ZhengZhouMJTable_HandleMJ")
    self:LoadDeskObjs()
    self:LoadDeskCardPier()
    self:LoadOutMJ()
    self:LoadHandMJ()
    self:LoadHandleMJ()
end

--------------------------------------------初始化----------------------------------------
function ZhengZhouMJMainView:InitDesk()
    self:InitDeskObjs()
    self:InitDeskCardPier()
    self:InitOutMJ()
    self:InitHandMJ()
    self:InitHandleMJ()
end

--恢复桌子
function ZhengZhouMJMainView:RestoreGameDesk(GameData)
    self:RestoreGameDeskObj(GameData)
    if GameData.Table.GameStatus == ZhengZhouMJ.GameState.STEPNULL then             --牌局未开始
       
    else
        if GameData.Table.GameStatus == ZhengZhouMJ.GameState.STEPDRIFTING then     --大票中
            self:RestoreGameCardPier(GameData)
        else
            if GameData.Table.GameStatus == ZhengZhouMJ.GameState.STEPDICE then      --发牌动画中
                self:RestoreGameCardPier(GameData)
                self:RestoreGameHandMJ(GameData)
            else
                if GameData.Table.GameStatus >= ZhengZhouMJ.GameState.STEPNOMAROUT then  --正常行牌中
                    self:RestoreGameCardPier(GameData)
                    self:RestoreGameHandMJ(GameData)
                    self:RestoreGameOutMJ(GameData)
                    self:RestoreGameHandleMJ(GameData)
                end
            end
        end
        self:UpDataLeftMJNum(GameData)
    end
end

function ZhengZhouMJMainView:FindRelationMJ(Value)
    self:FindOutRelationMJ(Value)
    self:FindHandleMJRelationMJ(Value)
end

function ZhengZhouMJMainView:ClearRelationMJ()
    self:ClearOutRelationMJ()
    self:ClearHandleMJRelationMJ()
end

function ZhengZhouMJMainView:OnDestroy()
    DismissManager.ClearUserInfo();
    if self.Desk  then
        GameObject.Destroy(self.Desk.gameObject)
    end
end
