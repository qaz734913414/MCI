-------------------------------牌墩管理--------------------------------
function ZhengZhouMJMainView:LoadDeskCardPier()
    local deltaX= 0.3
    local deltaZ = -0.2
    local posX = 0
    local posZ = 0
    self.CardPier = {}
    self.CardPier.MJs = {}
    for i=1,4 do
        self.CardPier[i] = {}
        self.CardPier[i].Prent = self.Desk:Find("GameRoot/GameDeskMJ/Player" .. tostring(i).."/DeskMJs")
        self.CardPier[i].PierNum = 0
        self.CardPier[i].MJs = {}
        for j = 1,17 do
            for n = 1,2 do
                local obj = self:InstantionGameObject(self.MJPrefab, self.CardPier[i].Prent, tostring(j.."_"..n))
                local MJ = MJCard.new(0,obj);
                posZ = 0
                posX = deltaX*(j-1)
                if n == 1 then
                    posZ = deltaZ
                end
                obj:SetLocalPosition(posX, 0, posZ)
                obj:GetTransform().localEulerAngles = Vector3(0,0,0)
                MJ:SetLayer("3D")
                table.insert(self.CardPier[i].MJs,MJ)
            end
        end
    end
    local obj = self:InstantionGameObject(self.MJPrefab, self.Desk:Find("GameRoot/GameDeskMJ/LiziPos"), tostring("laiZi"))
    self.CardPier.LaiZiMJ = MJCard.new(0,obj);
    self.CardPier.LaiZiMJ:AddAnimator(self.MJAnimController)
    self.CardPier.LaiZiMJ:SetLayer("3D")
    self.GameDeskAnimtor = self.Desk:Find("GameRoot/GameDeskMJ"):GetComponent("Animator")
    self.FaceIndex = 0;
    self.BackIndex = 0;
end

function ZhengZhouMJMainView:RestoreGameCardPier(GameData)
    if GameData.Table.GameStatus == ZhengZhouMJ.GameState.STEPDRIFTING then     --大票中
        self:ShowDeskCardPier(GameData);
    elseif GameData.Table.GameStatus >= ZhengZhouMJ.GameState.STEPDICE then 
        self:ShowDeskCardPier(GameData);
        self:SetDeskCardPierStartPoint(GameData)
        if GameData.Table.DeskMJBackIndx < self.BackIndex then
            self:DeskCardPMoPai(#self.CardPier.MJs-GameData.Table.DeskMJBackIndx,true)
        end
        if GameData.Table.RemakeID ~= 0 then
            self:SetLaiPos()
            self.CardPier.LaiZiMJ:Show()
            self.CardPier.LaiZiMJ:SetValue(GameData.Table.RemakeID)
            self.CardPier.LaiZiMJ:PlayAnim("FanLaiZi")
        end
        if GameData.Table.DeskMJFaceIndx > 0 then
            self:DeskCardPMoPai(GameData.Table.DeskMJFaceIndx,false)
        end

    end
end


--初始化牌墩
function ZhengZhouMJMainView:InitDeskCardPier()
    self.CardPier.MJs = {}
    for i=4,1,-1 do
        for j,v in ipairs(self.CardPier[i].MJs) do
            v:Hide()
        end
    end
    self.CardPier.LaiZiMJ:Hide()
end


function ZhengZhouMJMainView:ShowDeskCardPier(GameData)
    self.CardPier.MJs = {}
    for i=4,1,-1 do
        self.CardPier[i].PierNum = GameData.Table.Players[i].DeskPierNum
        local mjnum = self.CardPier[i].PierNum*2
        for j,v in ipairs(self.CardPier[i].MJs) do
            if j <= mjnum then 
                v:Show()
                table.insert(self.CardPier.MJs,v)
            else
                v:Hide()
            end
        end
    end
    self.FaceIndex = 1;
    self.BackIndex = #self.CardPier.MJs
end

function ZhengZhouMJMainView:XiPaiInit(GameData)
    self.CardPier.MJs = {}
    for i=4,1,-1 do
        self.CardPier[i].PierNum = GameData.Table.Players[i].DeskPierNum
        local mjnum = self.CardPier[i].PierNum*2
        for j,v in ipairs(self.CardPier[i].MJs) do
            if j <= mjnum then 
                table.insert(self.CardPier.MJs,v)
            end
        end
    end
    self.FaceIndex = 1;
    self.BackIndex = #self.CardPier.MJs
end

function ZhengZhouMJMainView:XiPaiAnim()
    self.GameDeskAnimtor:Play("XiPai",-1,0)
    self.GameDeskAnimtor:Update(0)
    WaitForSeconds(0.1)
    for i,v in ipairs(self.CardPier.MJs) do
        v:Show();
    end
end



--确定牌起点
function ZhengZhouMJMainView:SetDeskCardPierStartPoint(GameData)
    local DeskMJSumNum = 0
    for i=4,1,-1 do
        DeskMJSumNum = DeskMJSumNum + self.CardPier[i].PierNum*2
    end
    local OffectChariId = (GameData.Table.FirstDices[1] + GameData.Table.FirstDices[2]) % GameData.GamePlayerNum
    if OffectChariId == 0 then OffectChariId = GameData.GamePlayerNum end
    local CharIds = {}
    for i=GameData.Table.BankerChairId,1,-1 do
        if GameData.Table.Players[i].PlayerInfo.UserID ~= 0 then
            table.insert(CharIds,i)
        end
    end
    if GameData.Table.BankerChairId < 4 then
        for i=4,GameData.Table.BankerChairId + 1,-1 do
            if GameData.Table.Players[i].PlayerInfo.UserID ~= 0 then
                table.insert(CharIds,i)
            end
        end
    end
    local ChariId = CharIds[OffectChariId]
    local Offect = GameData.Table.FirstDices[1] + GameData.Table.FirstDices[2] + GameData.Table.SecondDices[1] + GameData.Table.SecondDices[2]
    local FrontSum = 0
    local TargetChariId = ChariId-1
    if ChariId < 4 then
        for i=4,ChariId+1,-1 do
            FrontSum = FrontSum + self.CardPier[i].PierNum*2
        end
    end
    local Index = (FrontSum + Offect*2) % DeskMJSumNum + 1
    local NewMJs = {}
    for i=Index,#self.CardPier.MJs do
        table.insert(NewMJs, self.CardPier.MJs[i])
    end
    for i=1,Index-1 do
        table.insert(NewMJs, self.CardPier.MJs[i])
    end
    self.CardPier.MJs = NewMJs
    self.FaceIndex = 1;
    self.BackIndex = DeskMJSumNum;
end

function ZhengZhouMJMainView:FanLaiZi(GameData)
    local TargetMJ = nil
    if self.BackIndex % 2 == 0 then
        TargetMJ = self.CardPier.MJs[self.BackIndex-1]
    else
        TargetMJ = self.CardPier.MJs[self.BackIndex]
    end
    self.BackIndex = self.BackIndex - 1

    self.CardPier.LaiZiMJ:GetObj():GetTransform().position = TargetMJ:GetObj():GetTransform().position
    self.CardPier.LaiZiMJ:GetObj():GetTransform().rotation =TargetMJ:GetObj():GetTransform().rotation
    TargetMJ:Hide()
    self.CardPier.LaiZiMJ:Show()
    self.CardPier.LaiZiMJ:SetValue(GameData.Table.RemakeID)
    self.CardPier.LaiZiMJ:PlayAnim("FanLaiZi")
end

--设置赖子牌的位置
function ZhengZhouMJMainView:SetLaiPos()
    local TargetMJ = nil
    if self.BackIndex % 2 == 0 then
        TargetMJ = self.CardPier.MJs[self.BackIndex+2]
    else
        TargetMJ = self.CardPier.MJs[self.BackIndex]
    end
    self.CardPier.LaiZiMJ:GetObj():GetTransform().position = TargetMJ:GetObj():GetTransform().position
    self.CardPier.LaiZiMJ:GetObj():GetTransform().rotation =TargetMJ:GetObj():GetTransform().rotation
end


function ZhengZhouMJMainView:GetLeftMJNum()
    local leftmjnum = self.BackIndex - (self.FaceIndex - 1) 
    return leftmjnum > 0 and leftmjnum or 0
end

function ZhengZhouMJMainView:GetDeskLastMJ()
    local TargetMJ = nil
    if self.BackIndex % 2 == 0 then
        TargetMJ = self.CardPier.MJs[self.BackIndex-1]
    else
        TargetMJ = self.CardPier.MJs[self.BackIndex]
    end
    return TargetMJ
end

--摸牌 摸牌数量 是否是杠摸
function ZhengZhouMJMainView:DeskCardPMoPai(Num,IsGangMo)
    if not IsGangMo then
        for i=1,Num do
            self.CardPier.MJs[self.FaceIndex]:Hide()
            self.FaceIndex = self.FaceIndex + 1
            if self.FaceIndex == self.BackIndex and self.CardPier.LaiZiMJ:IsShow() then
                local Pos = self.CardPier.LaiZiMJ:GetObj():GetTransform().localPosition
                self.CardPier.LaiZiMJ:GetObj():GetTransform().localPosition = Vector3(Pos.x,Pos.y,0)
            end
        end
    else
        for i=1,Num do
            if self.BackIndex % 2 == 0 then
                self.CardPier.MJs[self.BackIndex-1]:Hide()
            else
                self.CardPier.MJs[self.BackIndex+1]:Hide()
            end
            self.BackIndex = self.BackIndex - 1
        end
    end
    print("self.FaceIndex == "..self.FaceIndex.."self.BackIndex =="..self.BackIndex)
end




