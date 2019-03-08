ClassView(PanelNames.ZhengZhouMJRoomResultView, GameNames.ZhengZhouMJ, UILayer.PanelHigh)

function ZhengZhouMJRoomResultView:OnCreate()
    self.GanmeName = self:Find("GanmeName"):GetComponent("Text")
    self.GanmeInfo = self:Find("GanmeInfo"):GetComponent("Text")
    self.ExitButt = self:Find("ExitButt")
	self.ShaerButt = self:Find("ShaerButt")
	self.Details = self:Find("Details")
	self.ShaerButt:SetOnClick(function(evt, go, args)
        self:ShareToCircle()
    end)
	self.ExitButt:SetOnClick(function(evt, go, args)
        self:ExitButtClick()
	end)
	self.Details:SetOnClick(function(evt, go, args)
        self:DetailsClick()
    end)
    self.Player={}
    for i=1,4 do
        self.Player[i] = {}
		self.Player[i].PlayerObj = self:Find("Players/Player"..i)
		self.Player[i].PlayerIcon = self.Player[i].PlayerObj:Find("PlayerIcon")
		self.Player[i].PlayerName = self.Player[i].PlayerObj:Find("Name"):GetComponent("Text")
		self.Player[i].WinIntegral = self.Player[i].PlayerObj:Find("WinIntegral"):GetComponent("Text")
		self.Player[i].LoseIntegral = self.Player[i].PlayerObj:Find("LoseIntegral"):GetComponent("Text")
		self.Player[i].HuNum = self.Player[i].PlayerObj:Find("HuNum"):GetComponent("Text")
		self.Player[i].WinNum = self.Player[i].PlayerObj:Find("WinNum"):GetComponent("Text")
		self.Player[i].HightNum = self.Player[i].PlayerObj:Find("HightNum"):GetComponent("Text")
		self.Player[i].MaxWinSgin = self.Player[i].PlayerObj:Find("MaxWinSgin")
		self.Player[i].WinSgin = self.Player[i].PlayerObj:Find("WinSgin")
		self.Player[i].LoseSgin = self.Player[i].PlayerObj:Find("LoseSgin")
		self.Player[i].AccomSgin = self.Player[i].PlayerObj:Find("AccomSgin")
	end
	self:UpDataView()
end

function ZhengZhouMJRoomResultView:UpDataView()
	local GameData = ZhengZhouMJ.GetGameData()
	local MaxWinIntegral = 0
	self.GanmeInfo.text = "局数:"..GameData.IntoGameNum.."  房间ID:"..GameData.RoomId
	for i= 1,4 do
		if GameData.RoomResultData[i] then
			self:GetWebIconImage(GameData.Table.Players[i].PlayerInfo.UserSex,GameData.Table.Players[i].PlayerInfo.Imageurl, self.Player[i].PlayerIcon)
			self.Player[i].PlayerName.text = tostring(GameData.Table.Players[i].PlayerInfo.UserName) 
			self.Player[i].HuNum.text ="累计共胡 : "..tostring(GameData.RoomResultData[i].AllHuNum).." 次"
			self.Player[i].WinNum.text ="胜负局数 : 胜"..tostring(GameData.RoomResultData[i].WinNum).." 负 "..tostring(GameData.RoomResultData[i].FailNum)
			self.Player[i].HightNum.text ="单局最高分 : "..tostring(GameData.RoomResultData[i].SingleMaxIntegral)
			MaxWinIntegral = GameData.RoomResultData[i].Integral > MaxWinIntegral and GameData.RoomResultData[i].Integral or MaxWinIntegral
			if GameData.RoomResultData[i].Integral > 0 then
				self.Player[i].WinIntegral.gameObject:SetActive(true)
				self.Player[i].WinIntegral.text = "+"..tostring(GameData.RoomResultData[i].Integral)
				self.Player[i].WinSgin.gameObject:SetActive(true)
			elseif GameData.RoomResultData[i].Integral < 0 then
				self.Player[i].LoseIntegral.gameObject:SetActive(true)
				self.Player[i].LoseIntegral.text = tostring(GameData.RoomResultData[i].Integral)
				self.Player[i].LoseSgin.gameObject:SetActive(true)
			else
				self.Player[i].WinIntegral.gameObject:SetActive(true)
				self.Player[i].WinIntegral.text = "+"..tostring(GameData.RoomResultData[i].Integral)
				self.Player[i].AccomSgin.gameObject:SetActive(true)
			end
			if i == 1 then
				if GameData.RoomResultData[i].Integral > 0 then
					self:PlaySound("mj_effect_shengli")
				else
					self:PlaySound("mj_effect_shibai")
				end
			end
		else
			self.Player[i].PlayerObj.gameObject:SetActive(false)
		end
	end
	for i=1,4 do
		if GameData.RoomResultData[i] and GameData.RoomResultData[i].Integral == MaxWinIntegral then
			self.Player[i].MaxWinSgin.gameObject:SetActive(true)
		end
	end
end

function ZhengZhouMJRoomResultView:ExitButtClick()
	CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):OnCallExitGame()
    CtrlManager.CloseCtrl(CtrlNames.ZhengZhouMJRoomResult)
end

function ZhengZhouMJRoomResultView:DetailsClick()
	CtrlManager.ReOpenCtrl(GameNames.ZhengZhouMJ,CtrlNames.ZhengZhouMJGameResult)
	CtrlManager.CloseCtrl(CtrlNames.ZhengZhouMJRoomResult)
end

function ZhengZhouMJRoomResultView:ShareToCircle()
	Game.CallCaptureScreenShare(false)
	-- self:StartTimer("ShareToCircle", 1, function ()
	-- end, 1)
end