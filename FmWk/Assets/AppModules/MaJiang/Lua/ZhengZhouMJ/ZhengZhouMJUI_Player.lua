--加载玩家UI对象
function ZhengZhouMJMainView:LoadPlayerInfos()
    self.PlayerInfos = {}
    for i= 1,4 do
        self.PlayerInfos[i] = {};
        self.PlayerInfos[i].PlayerObj = self:Find("PlayerInfo/Player_"..tostring(i))
        self.PlayerInfos[i].PlayerIcon = self.PlayerInfos[i].PlayerObj:Find("PlayerIcon")
        self.PlayerInfos[i].GoldIcon1 = self.PlayerInfos[i].PlayerObj:Find("GoldIcon1")
        self.PlayerInfos[i].GoldIcon2 = self.PlayerInfos[i].PlayerObj:Find("GoldIcon2")
        self.PlayerInfos[i].Goldnum = self.PlayerInfos[i].PlayerObj:Find("Goldbg/Goldnum"):GetComponent("Text")
        self.PlayerInfos[i].ZhuangSign = self.PlayerInfos[i].PlayerObj:Find("ZhuangSign")
        self.PlayerInfos[i].ChupaEffect =  self.PlayerInfos[i].PlayerObj:Find("ChupaEffect")
        self.PlayerInfos[i].ReadySigin = self.PlayerInfos[i].PlayerObj:Find("ReadySigin")
        self.PlayerInfos[i].OnlineShin = self.PlayerInfos[i].PlayerObj:Find("OnlineShin")
        self.PlayerInfos[i].TrustFlagShin = self.PlayerInfos[i].PlayerObj:Find("TrustFlagShin")
        self.PlayerInfos[i].DaPiao = self.PlayerInfos[i].PlayerObj:Find("DaPiao")
        self.PlayerInfos[i].DaPiaobg = self.PlayerInfos[i].DaPiao:Find("bg")
        self.PlayerInfos[i].DaPiaoP0bg = self.PlayerInfos[i].DaPiao:Find("P0bg")
        self.PlayerInfos[i].DaPiaoNum = self.PlayerInfos[i].DaPiao:Find("Text"):GetComponent("Text")
        self.PlayerInfos[i].ChatRoot = self.PlayerInfos[i].PlayerObj:Find("ChatRoot")
        self.PlayerInfos[i].ScoreEffect = self:Find("GameEffect/PlayerEffect/Player"..tostring(i).."/Score"):GetComponent("Animator")
        self.PlayerInfos[i].WinScoreEffect = self.PlayerInfos[i].ScoreEffect.transform:Find("Win"):GetComponent("Text")
        self.PlayerInfos[i].LoseScoreEffect = self.PlayerInfos[i].ScoreEffect.transform:Find("Lose"):GetComponent("Text")
        self.PlayerInfos[i].DaPiaoEffect = self:Find("GameEffect/PlayerEffect/Player"..tostring(i).."/DaPiaoEffect")
        self.PlayerInfos[i].DaPiaoEffectPos = self.PlayerInfos[i].DaPiaoEffect.position
        local OperateEffect =  self:Find("GameEffect/PlayerEffect/Player"..tostring(i).."/OperateEffect")
        self.PlayerInfos[i].OperateEffect = {}
        self.PlayerInfos[i].OperateEffect["Peng"] = OperateEffect:Find("Peng").gameObject
        self.PlayerInfos[i].OperateEffect["Gang"] = OperateEffect:Find("Gang").gameObject
        self.PlayerInfos[i].OperateEffect["Tang"] = OperateEffect:Find("Tang").gameObject
        self.PlayerInfos[i].OperateEffect["Hu"] = OperateEffect:Find("Hu").gameObject
        self.PlayerInfos[i].OperateEffect["ZiMo"] = OperateEffect:Find("ZiMo").gameObject


        self.PlayerInfos[i].PlayerIcon:SetOnClick(function(evt, go, args)
            self:PlayerHeadClick(i)
        end)
    end
end

function ZhengZhouMJMainView:RestorePlayerInfos()
    local GameData = ZhengZhouMJ.GetGameData()
    for i,v in ipairs(GameData.Table.Players) do
        if v.PlayerInfo.UserID ~= 0 then 
            self:ShowPlayer(i,GameData)
        else
            self:HidePlayer(i)
        end
    end
end

function ZhengZhouMJMainView:InitPlayerInfos()
    for i,v in ipairs(self.PlayerInfos) do
        v.ZhuangSign.gameObject:SetActive(false)
        v.ReadySigin.gameObject:SetActive(false)
        v.DaPiao.gameObject:SetActive(false)
        v.ChupaEffect.gameObject:SetActive(false)
        v.ScoreEffect.gameObject:SetActive(false)
        v.DaPiaoEffect.gameObject:SetActive(false)
        v.TrustFlagShin.gameObject:SetActive(false)
        for k1,v1 in pairs(v.OperateEffect) do
            v1:SetActive(false)
        end
    end
end


function ZhengZhouMJMainView:HidePlayer(ChairId)
    self.PlayerInfos[ChairId].PlayerObj.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].PlayerIcon.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].ZhuangSign.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].ChupaEffect.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].ReadySigin.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].TrustFlagShin.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].DaPiao.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].ScoreEffect.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].DaPiaoEffect.gameObject:SetActive(false)
end


function ZhengZhouMJMainView:ShowPlayer(ChairId,GameData)
    local PlayerInfo = GameData.Table.Players[ChairId].PlayerInfo
    self.PlayerInfos[ChairId].PlayerObj.gameObject:SetActive(true)
    self.PlayerInfos[ChairId].PlayerIcon.gameObject:SetActive(true)
    self.PlayerInfos[ChairId].GoldIcon1.gameObject:SetActive(GameData.RoomRule.SettleType == 1)
    self.PlayerInfos[ChairId].GoldIcon2.gameObject:SetActive(GameData.RoomRule.SettleType == 2)
    self:GetWebIconImage(PlayerInfo.UserSex,PlayerInfo.Imageurl, self.PlayerInfos[ChairId].PlayerIcon)
    self.PlayerInfos[ChairId].Goldnum.text = tostring(numberToChineseString(GameData.Table.Players[ChairId].Score))
    --聊天系统
    local isRight = (ChairId == 1 or ChairId == 4) and true or false
    ChatManager.RegisterChatPlayItem(PlayerInfo.UserID, self.PlayerInfos[ChairId].ChatRoot, PlayerInfo.UserSex, isRight, GameNames.ZhengZhouMJ);   

    if GameData.Table.GameStatus == ZhengZhouMJ.GameState.STEPNULL then             --牌局未开始
    else
        if GameData.Table.Players[ChairId].DaPiaoNum ~= -1 then
            self.PlayerInfos[ChairId].DaPiao.gameObject:SetActive(true)
            self.PlayerInfos[ChairId].DaPiaoNum.text = "+"..tostring(GameData.Table.Players[ChairId].DaPiaoNum)
            if GameData.Table.Players[ChairId].DaPiaoNum > 0 then
                self.PlayerInfos[ChairId].DaPiaobg.gameObject:SetActive(true)
                self.PlayerInfos[ChairId].DaPiaoP0bg.gameObject:SetActive(false)
            else
                self.PlayerInfos[ChairId].DaPiaobg.gameObject:SetActive(false)
                self.PlayerInfos[ChairId].DaPiaoP0bg.gameObject:SetActive(true)
            end
        else
            self.PlayerInfos[ChairId].DaPiao.gameObject:SetActive(false)
        end
        if GameData.Table.Players[ChairId].IsTing then
            self:UI_PlayerPlayOperateEffect(ChairId,ZhengZhouMJ.MJHandleType.MAHJSTARLISTEN)
        end
    end
end

function ZhengZhouMJMainView:PlayerHeadClick(ChairId)	
    local GameData = ZhengZhouMJ.GetGameData()
    if GameData.Table.Players[ChairId].PlayerInfo.UserID ~= 0 then
        CtrlManager.OpenCtrl(GameNames.Shared, CtrlNames.GameUserCommenDetail, GameData.Table.Players[ChairId].PlayerInfo.UserID);
    end
end

---------------------------------------------------------------------------------------------------------
function ZhengZhouMJMainView:HideReadySigin()
    for i,v in ipairs(self.PlayerInfos) do
        v.ReadySigin.gameObject:SetActive(false)
    end
end

function ZhengZhouMJMainView:ShowPlayerOnline(ChairId,GameData)
    local IsOnline = not GameData.Table.Players[ChairId].IsOnline
    self.PlayerInfos[ChairId].OnlineShin.gameObject:SetActive(IsOnline)
    if IsOnline then
        self.PlayerInfos[ChairId].TrustFlagShin.gameObject:SetActive(false)
    else
        self.PlayerInfos[ChairId].TrustFlagShin.gameObject:SetActive(GameData.Table.Players[ChairId].IsTrustFlag)
    end
end

--显示玩家头像上的出牌特效
function ZhengZhouMJMainView:UI_PlayerShwoChuPaiEffect(ChairId)
    for i,v in ipairs(self.PlayerInfos) do
        v.ChupaEffect.gameObject:SetActive(false)
    end
    self.PlayerInfos[ChairId].ChupaEffect.gameObject:SetActive(true)
end

--播放打票特效
function ZhengZhouMJMainView:UI_PlayDaPiaoEffect(ChairId,DaPiao)
    StartCoroutine(function()
        self.PlayerInfos[ChairId].DaPiaoEffect.position = self.PlayerInfos[ChairId].DaPiaoEffectPos 
        self.PlayerInfos[ChairId].DaPiaoEffect.localScale =  Vector3.one
        self.PlayerInfos[ChairId].DaPiaoEffect.gameObject:SetActive(true)
        self.PlayerInfos[ChairId].DaPiaoEffect:Find(tostring(DaPiao)).gameObject:SetActive(true)
        WaitForSeconds(0.7)
        self.PlayerInfos[ChairId].DaPiaoEffect:DOMove(self.PlayerInfos[ChairId].DaPiao.position, 0.3)
        self.PlayerInfos[ChairId].DaPiaoEffect:DOScale(0.3, 0.3)
        WaitForSeconds(0.3)
        self.PlayerInfos[ChairId].DaPiaoEffect:Find(tostring(DaPiao)).gameObject:SetActive(false)
        self.PlayerInfos[ChairId].DaPiaoEffect.gameObject:SetActive(false)
        self.PlayerInfos[ChairId].DaPiao.gameObject:SetActive(true)
        self.PlayerInfos[ChairId].DaPiaoNum.text = "+"..tostring(DaPiao)
        if DaPiao > 0 then
            self.PlayerInfos[ChairId].DaPiaobg.gameObject:SetActive(true)
            self.PlayerInfos[ChairId].DaPiaoP0bg.gameObject:SetActive(false)
        else
            self.PlayerInfos[ChairId].DaPiaobg.gameObject:SetActive(false)
            self.PlayerInfos[ChairId].DaPiaoP0bg.gameObject:SetActive(true)
        end
    end)
end

--播放玩家的分数特效
function ZhengZhouMJMainView:UI_PlayerPlayScoreEffect(ChairId,Score)
    if Score >= 0 then
        self.PlayerInfos[ChairId].WinScoreEffect.text = "+"..Score
        self.PlayerInfos[ChairId].LoseScoreEffect.text = ""
    else
        self.PlayerInfos[ChairId].LoseScoreEffect.text = tostring(Score)
        self.PlayerInfos[ChairId].WinScoreEffect.text = ""
    end
    self.PlayerInfos[ChairId].ScoreEffect.gameObject:SetActive(true)
    self.PlayerInfos[ChairId].ScoreEffect:Play("PlayerScore",-1,0)
    self.PlayerInfos[ChairId].ScoreEffect:Update(0)
end

function ZhengZhouMJMainView:HideAllOperateEffect()
    for i,v in ipairs(self.PlayerInfos) do
        for k1,v1 in pairs(v.OperateEffect) do
            v1:SetActive(false)
        end
    end
end

--播放玩家的操作特效
function ZhengZhouMJMainView:UI_PlayerPlayOperateEffect(ChairId,ActionType)
    if ActionType == ZhengZhouMJ.MJHandleType.MAHJSTATOUCH then --碰
        self.PlayerInfos[ChairId].OperateEffect["Peng"]:SetActive(false)
        self.PlayerInfos[ChairId].OperateEffect["Peng"]:SetActive(true)
    elseif ActionType == ZhengZhouMJ.MJHandleType.Gang  then--碰
        self.PlayerInfos[ChairId].OperateEffect["Gang"]:SetActive(false)
        self.PlayerInfos[ChairId].OperateEffect["Gang"]:SetActive(true)
    elseif ActionType == ZhengZhouMJ.MJHandleType.MAHJSTARLISTEN then   
        self.PlayerInfos[ChairId].OperateEffect["Tang"]:SetActive(false)
        self.PlayerInfos[ChairId].OperateEffect["Tang"]:SetActive(true)
    elseif ActionType == ZhengZhouMJ.MJHandleType.MAHJSTATOUCHWIN then
        self.PlayerInfos[ChairId].OperateEffect["Tang"]:SetActive(false)
        self.PlayerInfos[ChairId].OperateEffect["Hu"]:SetActive(false)
        self.PlayerInfos[ChairId].OperateEffect["Hu"]:SetActive(true)
    elseif ActionType == ZhengZhouMJ.MJHandleType.MAHJSTAOWNDRAW then
        self.PlayerInfos[ChairId].OperateEffect["ZiMo"]:SetActive(false)
        self.PlayerInfos[ChairId].OperateEffect["ZiMo"]:SetActive(true)
    end
end