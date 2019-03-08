function ZhengZhouMJMainView:LoadSound()
    self.Sounds = {}
    self.Sounds.BoySound={}
    self.Sounds.GirlSound={}
end

--播放出牌音效
function ZhengZhouMJMainView:PlaySound_ChuPai(ChairId,MJ,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("boy"..MJ)
    else
        self:PlaySound("girl"..MJ)
    end
end

function ZhengZhouMJMainView:PlaySound_Chi(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("boy_chi")
    else
        self:PlaySound("girl_chi")
    end
end


function ZhengZhouMJMainView:PlaySound_Peng(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("boy_peng")
    else
        self:PlaySound("girl_peng")
    end
end


function ZhengZhouMJMainView:PlaySound_Gang(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("boy_gang")
    else
        self:PlaySound("girl_gang")
    end
end

function ZhengZhouMJMainView:PlaySound_Ting(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("boy_ting")
    else
        self:PlaySound("girl_ting")
    end
end


function ZhengZhouMJMainView:PlaySound_Hu(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("boy_hu")
    else
        self:PlaySound("girl_hu")
    end
end

function ZhengZhouMJMainView:PlaySound_ZiMo(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("boy_zimo")
    else
        self:PlaySound("girl_zimo")
    end
end