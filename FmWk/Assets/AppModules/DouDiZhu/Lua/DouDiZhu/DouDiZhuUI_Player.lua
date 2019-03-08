--加载玩家UI对象
function DouDiZhuMainView:LoadPlayerInfos()
    self.PlayerInfos = {}
    for i= 1,3 do
        self.PlayerInfos[i] = {};
        self.PlayerInfos[i].PlayerObj = self:Find("PlayerInfo/Player_"..tostring(i))
        self.PlayerInfos[i].PlayerIcon = self.PlayerInfos[i].PlayerObj:Find("PlayerIcon")
        self.PlayerInfos[i].Name = self.PlayerInfos[i].PlayerObj:Find("Name"):GetComponent("Text")
        self.PlayerInfos[i].LordIcon = self.PlayerInfos[i].PlayerObj:Find("LordIcon")
        self.PlayerInfos[i].ChupaEffect =  self.PlayerInfos[i].PlayerObj:Find("ChupaEffect")
        self.PlayerInfos[i].ReadySigin = self.PlayerInfos[i].PlayerObj:Find("ReadySigin")
        self.PlayerInfos[i].OnlineShin = self.PlayerInfos[i].PlayerObj:Find("OnlineShin")
        self.PlayerInfos[i].TrustFlagShin = self.PlayerInfos[i].PlayerObj:Find("TrustFlagShin")
        self.PlayerInfos[i].ChatRoot = self.PlayerInfos[i].PlayerObj:Find("ChatRoot")
        
        self.PlayerInfos[i].ScoreEffect = self:Find("GameEffect/PlayerEffect/Player"..tostring(i).."/Score"):GetComponent("Animator")
        self.PlayerInfos[i].WinScoreEffect = self.PlayerInfos[i].ScoreEffect.transform:Find("Win"):GetComponent("Text")
        self.PlayerInfos[i].LoseScoreEffect = self.PlayerInfos[i].ScoreEffect.transform:Find("Lose"):GetComponent("Text")
        self.PlayerInfos[i].CallScoreEffect = self:Find("GameEffect/PlayerEffect/Player"..tostring(i).."/CallScoreEffect")
        if i ~= 1 then
            self.PlayerInfos[i].GoldIcon1 = self.PlayerInfos[i].PlayerObj:Find("GoldIcon1")
            self.PlayerInfos[i].GoldIcon2 = self.PlayerInfos[i].PlayerObj:Find("GoldIcon2")
            self.PlayerInfos[i].Goldnum = self.PlayerInfos[i].PlayerObj:Find("Goldnum"):GetComponent("Text")
            self.PlayerInfos[i].DaoJiShi = self:Find("GameEffect/PlayerEffect/Player"..tostring(i).."/DaoJiShi")
            self.PlayerInfos[i].Alarm = self:Find("GameEffect/PlayerEffect/Player"..tostring(i).."/Alarm")
        else
            self.PlayerInfos[i].GoldIcon1 = self:Find("Bottom/SelfSocre/GoldIcon1")
            self.PlayerInfos[i].GoldIcon2 = self:Find("Bottom/SelfSocre/GoldIcon2")
            self.PlayerInfos[i].Goldnum = self:Find("Bottom/SelfSocre/Goldnum"):GetComponent("Text")
        end
        self.PlayerInfos[i].PlayerIcon:SetOnClick(function(evt, go, args)
            self:PlayerHeadClick(i)
        end)
    end
end

function DouDiZhuMainView:PlayerHeadClick(ChairId)	
    local GameData = DouDiZhu.GetGameData()
    if GameData.Table.Players[ChairId].PlayerInfo.UserID ~= 0 then
        CtrlManager.OpenCtrl(GameNames.Shared, CtrlNames.GameUserCommenDetail, GameData.Table.Players[ChairId].PlayerInfo.UserID);
    end
end

----------------------------------------------------------------业务接口------------------------------------------------------------
function DouDiZhuMainView:RestorePlayerInfos(GameData)
    for i,v in ipairs(GameData.Table.Players) do
        if v.PlayerInfo.UserID ~= 0 then 
            self:ShowPlayer(i,GameData)
        else
            self:HidePlayer(i)
        end
    end
    if GameData.Table.GameStatus == DouDiZhu.GameState.CallScore or GameData.Table.GameStatus == DouDiZhu.GameState.InGame  then
        if GameData.Table.CurrOperatChairId ~= 0 then
            if GameData.Table.CurrOperatChairId ~= 1 then
                self:ShowDaoJiShi(GameData.Table.CurrOperatChairId,GameData.Table.OperationLeftTime)
            end
        end
        if GameData.Table.GameStatus == DouDiZhu.GameState.InGame then
            self.PlayerInfos[GameData.Table.BankerChairId].LordIcon.gameObject:SetActive(true)
        end
    end
end

function DouDiZhuMainView:InitPlayerInfos()
    for i,v in ipairs(self.PlayerInfos) do
        v.LordIcon.gameObject:SetActive(false)
        v.ReadySigin.gameObject:SetActive(false)
        v.ChupaEffect.gameObject:SetActive(false)
        v.ScoreEffect.gameObject:SetActive(false)
        v.TrustFlagShin.gameObject:SetActive(false)
        v.CallScoreEffect.gameObject:SetActive(false)
        if i ~= 1 then
            v.DaoJiShi.gameObject:SetActive(false)
            v.Alarm.gameObject:SetActive(false)
        end
    end
end


function DouDiZhuMainView:ShowPlayer(ChairId,GameData)
    local PlayerInfo = GameData.Table.Players[ChairId].PlayerInfo
    self.PlayerInfos[ChairId].PlayerObj.gameObject:SetActive(true)
    self.PlayerInfos[ChairId].PlayerIcon.gameObject:SetActive(true)
    self.PlayerInfos[ChairId].Name.text = PlayerInfo.UserName
    self.PlayerInfos[ChairId].GoldIcon1.gameObject:SetActive(GameData.RoomRule.SettleType == 1)
    self.PlayerInfos[ChairId].GoldIcon2.gameObject:SetActive(GameData.RoomRule.SettleType == 2)
    self:GetWebIconImage(PlayerInfo.UserSex,PlayerInfo.Imageurl, self.PlayerInfos[ChairId].PlayerIcon)
    self.PlayerInfos[ChairId].Goldnum.text = tostring(numberToChineseString(GameData.Table.Players[ChairId].Score))
    local isRight = (ChairId == 1 or ChairId == 3) and true or false
    ChatManager.RegisterChatPlayItem(PlayerInfo.UserID, self.PlayerInfos[ChairId].ChatRoot, PlayerInfo.UserSex, isRight, GameNames.ZhengZhouMJ)
    if GameData.Table.GameStatus == DouDiZhu.GameState.STEPNULL then
        self.PlayerInfos[ChairId].ReadySigin.gameObject:SetActive(GameData.Table.Players[ChairId].IsReady)
    end
    self:ShowPlayerOnline(ChairId,GameData)
end

function DouDiZhuMainView:HidePlayer(ChairId)
    self.PlayerInfos[ChairId].PlayerObj.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].PlayerIcon.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].LordIcon.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].ChupaEffect.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].ReadySigin.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].TrustFlagShin.gameObject:SetActive(false)
    self.PlayerInfos[ChairId].ScoreEffect.gameObject:SetActive(false)
end

function DouDiZhuMainView:HideReadySigin()
    for i,v in ipairs(self.PlayerInfos) do
        v.ReadySigin.gameObject:SetActive(false)
    end
end

function DouDiZhuMainView:ShowPlayerOnline(ChairId,GameData)
    local IsOnline = not GameData.Table.Players[ChairId].IsOnline
    self.PlayerInfos[ChairId].OnlineShin.gameObject:SetActive(IsOnline)
    if IsOnline then
        self.PlayerInfos[ChairId].TrustFlagShin.gameObject:SetActive(false)
    else
        self.PlayerInfos[ChairId].TrustFlagShin.gameObject:SetActive(GameData.Table.Players[ChairId].IsTrustFlag)
    end
end

-- function DouDiZhuMainView:ShowLordIcon(ChairId)
--     self.PlayerInfos[ChairId].LordIcon.gameObject:SetActive(true)
-- end

--影藏玩家操作倒计时
function DouDiZhuMainView:HideDaoJiShi()
    for i,v in ipairs(self.PlayerInfos) do
        if i ~= 1 then
            self.PlayerInfos[i].DaoJiShi.gameObject:SetActive(false)
        end
        v.ChupaEffect.gameObject:SetActive(false)
    end
    StopCoroutine(self.DaoJiShiCoroutine)
end

--显示操作倒计时
function DouDiZhuMainView:ShowDaoJiShi(ChairId,Time)
    for i,v in ipairs(self.PlayerInfos) do
        v.ChupaEffect.gameObject:SetActive(false)
        if v.DaoJiShi then
            v.DaoJiShi.gameObject:SetActive(false)
        end
    end
    self.PlayerInfos[ChairId].ChupaEffect.gameObject:SetActive(true)
    self.PlayerInfos[ChairId].DaoJiShi.gameObject:SetActive(true)
    self:ShowTimer(self.PlayerInfos[ChairId].DaoJiShi,Time)
end

--显示报警特效
function DouDiZhuMainView:ShowAlarm(ChairId,LeftPkNum,GameData)
    self:PlaySound_Alarm(ChairId,LeftPkNum,GameData)
    if ChairId ~= 1 then
        self.PlayerInfos[ChairId].Alarm.gameObject:SetActive(true)
    end
end

function DouDiZhuMainView:HideAlarm()
    self.PlayerInfos[2].Alarm.gameObject:SetActive(false)
    self.PlayerInfos[3].Alarm.gameObject:SetActive(false)
end

--播放叫分特效
function DouDiZhuMainView:UI_PlayPlayerCallSoreEffect(ChairId,CallSore)
    self.PlayerInfos[ChairId].CallScoreEffect.gameObject:SetActive(true)
    for i=0,4 do
        if i == CallSore then
            self.PlayerInfos[ChairId].CallScoreEffect:Find("Score"..i).gameObject:SetActive(true)
        else
            self.PlayerInfos[ChairId].CallScoreEffect:Find("Score"..i).gameObject:SetActive(false)
        end
    end
end

--影藏叫分特效
function DouDiZhuMainView:HideCallSoreEffect()
    for i,v in ipairs(self.PlayerInfos) do
        v.CallScoreEffect.gameObject:SetActive(false)
    end
end

--播放玩家的分数特效
function DouDiZhuMainView:UI_PlayerPlayScoreEffect(ChairId,Score)
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

--播放地主特效
function DouDiZhuMainView:UI_PlayDiZhuEffect(ChairId)
    StartCoroutine(function()
        local position = self.DiZhuEffect.position
        self.DiZhuEffect.gameObject:SetActive(true)
        WaitForSeconds(0.5)
        self.DiZhuEffect:DOMove(self.PlayerInfos[ChairId].LordIcon.position, 0.3)
        WaitForSeconds(0.3)
        self.PlayerInfos[ChairId].LordIcon.gameObject:SetActive(true)
        self.DiZhuEffect.gameObject:SetActive(false)
        self.DiZhuEffect.position = position
    end)
end