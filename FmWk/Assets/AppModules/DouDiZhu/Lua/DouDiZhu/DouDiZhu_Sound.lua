function DouDiZhuMainView:LoadSound()
    self.Sounds = {}
    self.Sounds.BoySound={}
    self.Sounds.GirlSound={}
end

function DouDiZhuMainView:PlaySound_CallScore(ChairId,Score,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("fen_"..Score.."_1")
    else
        self:PlaySound("fen_"..Score.."_2")
    end
end


--播放出牌过
function DouDiZhuMainView:PlaySound_ChuPass(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        local BgSounds= {"Pass_1_1","Pass_2_1","Pass_3_1"}
        local Index =  math.random(100)%#BgSounds + 1
        self:PlaySound(BgSounds[Index])
    else
        local BgSounds= {"Pass_1_2","Pass_2_2","Pass_3_2"}
        local Index =  math.random(100)%#BgSounds + 1
        self:PlaySound(BgSounds[Index])
    end
end

--播放单牌音效
function DouDiZhuMainView:PlaySound_ChuDanPai(ChairId,Pk,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("dan_"..Pk.."_1")
    else
        self:PlaySound("dan_"..Pk.."_2")
    end
end

--播放对子音效
function DouDiZhuMainView:PlaySound_ChuDuiZi(ChairId,Pk,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("shuang_"..Pk.."_1")
    else
        self:PlaySound("shuang_"..Pk.."_2")
    end
end

--出牌火箭
function DouDiZhuMainView:PlaySound_ChuHuoJian(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("pokerhuojian_1")
    else
        self:PlaySound("pokerhuojian_2")
    end
    self:PlaySound("huojian")
end

--出牌炸弹
function DouDiZhuMainView:PlaySound_ChuZhaDan(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("pokerzhadan_1")
    else
        self:PlaySound("pokerzhadan_2")
    end
    self:PlaySound("zhadan1")
end

--出牌飞机
function DouDiZhuMainView:PlaySound_ChuFeiJi(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("pokerfeiji_1")
    else
        self:PlaySound("pokerfeiji_2")
    end
    self:PlaySound("feji")
end

--出牌连对
function DouDiZhuMainView:PlaySound_ChuLianDui(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("pokerliandui_1")
    else
        self:PlaySound("pokerliandui_2")
    end
    self:PlaySound("liandui")
end

--出牌顺子
function DouDiZhuMainView:PlaySound_ChuSunZi(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("pokershunzi_1")
    else
        self:PlaySound("pokershunzi_2")
    end
    self:PlaySound("shunzi")
end

--三张
function DouDiZhuMainView:PlaySound_ChuSanZhang(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("san_1")
    else
        self:PlaySound("san_2")
    end
end

--三代一
function DouDiZhuMainView:PlaySound_ChuSanDaiYi(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("san_1_1")
    else
        self:PlaySound("san_1_2")
    end
end

--三代一对
function DouDiZhuMainView:PlaySound_ChuSanDaiYiDui(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("san_11_1")
    else
        self:PlaySound("san_11_2")
    end
end

--四代二
function DouDiZhuMainView:PlaySound_ChuSiDaire(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("si_11_1")
    else
        self:PlaySound("si_11_2")
    end
end

--四代两对
function DouDiZhuMainView:PlaySound_ChuSiDailiangdui(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("si_1122_1")
    else
        self:PlaySound("si_1122_2")
    end
end

--春天
function DouDiZhuMainView:PlaySound_ChunTian(ChairId,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        self:PlaySound("Audio_Spring_1")
    else
        self:PlaySound("Audio_Spring_2")
    end
end

--播放警告
function DouDiZhuMainView:PlaySound_Alarm(ChairId,LeftPkNum,GameData)
    local IsBoy = GameData.Table.Players[ChairId].PlayerInfo.UserSex
    if IsBoy == 2 then
        if LeftPkNum == 2 then
            self:PlaySound("wj2zpl_1")
        else
            self:PlaySound("wj1zpl_1")
        end
    else
        if LeftPkNum == 2 then
            self:PlaySound("wj2zpl_2")
        else
            self:PlaySound("wj1zpl_2")
        end
    end
    self:PlaySound("shi1")
end