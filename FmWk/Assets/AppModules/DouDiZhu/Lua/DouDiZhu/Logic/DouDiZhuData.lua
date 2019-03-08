module("DouDiZhu", package.seeall)
local GameData = nil;

function GameDataInit(RoomId,GameId)
    GameData = TableCopy(GameConfigData)
    GameData.GameId = GameId
    GameData.RoomId = RoomId
    DebugGameData("初始化房间信息");
end

--设置房间信息恢复 (重连)
function SetRoomDataRecovery(RoomData)
    GameData.Table.GameStatus = GameState.STEPNULL
    GameData.CreateRoomTime = RoomData.Roomdetail.Baseroominfo.CreateRoomTime
    GameData.AllGameNum = RoomData.Roomdetail.Createinfo.AllGameNum
    GameData.IntoGameNum = RoomData.Roomdetail.Createinfo.IntoGameNum
    SetRoomRule(RoomData.Roomdetail.Roomruleinfo,RoomData.Roomdetail.Roomrulebuff)
    for i,v in ipairs(RoomData.Baseuser) do
        if v.UserID ~= 0 and v.UserID == _G["profile"].id then     --先把自己的信息找到 不然不好定座位
            SetRoomPlayerInfo(i-1,v,true)       --服务器id是从0开始的 所以-1
        end
    end
    for i,v in ipairs(RoomData.Baseuser) do
        if v.UserID ~= 0 and v.UserID ~= _G["profile"].id then     --先把自己的信息找到 不然不好定座位
            SetRoomPlayerInfo(i-1,v,false)
        end
    end
    GameData.CreaterInfo.UserID = RoomData.Roomdetail.Createinfo.CreateUserID                      --创建者id
    GameData.CreaterInfo.UnionGroupID = RoomData.Roomdetail.Createinfo.UnionGroupID                --联盟id
    GameData.CreaterInfo.CreateUnionID = RoomData.Roomdetail.Createinfo.CreateUnionID              --创建者所在的战队ID
    GameData.CreaterInfo.CreateUnionName = RoomData.Roomdetail.Createinfo.CreateUnionName          --创建者战队名称
    GameData.CreaterChairId = UserIDToChairId(RoomData.Roomdetail.Createinfo.CreateUserID)          --房主
    GameData.IsClubRoom = RoomData.Roomdetail.Createinfo.CreateUnionID ~= 0 and true or false       --是否是俱乐部
    GameData.Table.BankerChairId = UserIDToChairId(RoomData.Roomdetail.Baseroominfo.LandlordUserID)     --地主
    if GameData.Table.BankerChairId ~= 0 then
        GameData.Table.GameStatus = GameState.InGame
    end
    GameData.Table.BankerCallScore = RoomData.Roomdetail.Baseroominfo.CurCallPoint                      --倍數
    GameData.Table.MultipleNum = RoomData.Roomdetail.Baseroominfo.MultipleNum                           --炸弹倍数  
    print("砸蛋倍数 = "..RoomData.Roomdetail.Baseroominfo.MultipleNum)
    GameData.Table.CurrOperatChairId = UserIDToChairId(RoomData.Roomdetail.Baseroominfo.CurRunUserID)   --当前操作玩家
    GameData.Table.OperationTime = RoomData.Roomdetail.Createinfo.OverTimeTrust                         --用户操作时间
    GameData.Table.OverCallNumTime = RoomData.Roomdetail.Createinfo.OverCallNumTime                     --叫分操作时间
    GameData.Table.OverNotRiseTime = RoomData.Roomdetail.Createinfo.OverNotRiseTime                     --要不起操作时间

    GameData.Table.OperationLeftTime = RoomData.Roomdetail.Baseroominfo.StopSeconds - (Network.GetServerTime() - RoomData.Roomdetail.Baseroominfo.LastSetTime) 
    GameData.Table.LastChuPaiChairId = UserIDToChairId(RoomData.Roomdetail.Baseroominfo.LastMesaUserID) --最后出牌玩家
    GameData.Table.LastPokeType = RoomData.Roomdetail.Baseroominfo.LastPokeType                         --最后出牌类型
    for i,v in ipairs(RoomData.Roomdetail.Baseroominfo.LastMesaBrandID) do                              --最后打出牌
        if v ~= 0 then
            table.insert(GameData.Table.LastChuPaiPks,v)
        end
    end
    for i,v in ipairs(RoomData.Roomdetail.AhandBandID) do
        GameData.Table.AhandPks[i] = v
    end
    for i,v in ipairs(RoomData.Roomdetail.RoomUser) do
        local ChairId = SChairIdToChairId(i-1)
        if ChairId ~= 0 then
            GameData.Table.Players[ChairId].IsTrustFlag = (v.TrustFlag == 1) and true or false
            GameData.Table.Players[ChairId].IsReady = (v.bReady == 1) and true or false
            GameData.Table.Players[ChairId].IsAdmitLostFlag = (v.AdmitLostFlag == 1) and true or false
            GameData.Table.Players[ChairId].Score = v.SettleItemNum
            GameData.Table.Players[ChairId].MapPoint.X = StringToNumber(v.Usermapinfo.Mappoint1)
            GameData.Table.Players[ChairId].MapPoint.Y = StringToNumber(v.Usermapinfo.Mappoint2)
            GameData.Table.Players[ChairId].MapPoint.IsOpenGPS = (GameData.Table.Players[ChairId].MapPoint.X ~= 0 and GameData.Table.Players[ChairId].MapPoint.Y ~= 0) and true or false
            for i2,v2 in ipairs(v.BrandID) do
                if v2 ~= 0 then
                    table.insert(GameData.Table.Players[ChairId].HandPKs,v2)
                end
            end
            SortHandPks(ChairId)
            if #GameData.Table.Players[ChairId].HandPKs > 0 then
                GameData.Table.GameStatus = GameData.Table.GameStatus == GameState.STEPNULL and GameState.CallScore or GameData.Table.GameStatus
            end
        end
    end
end

--设置房间内用户信息(重连)
function SetRoomPlayerInfo(SChairID,PlayerInfo,IsSelf)
    if IsSelf then
        GameData.Table.Players[1].SChairId = SChairID
        GameData.Table.Players[1].PlayerInfo.UserID = PlayerInfo.UserID
        GameData.Table.Players[1].PlayerInfo.Imageurl = PlayerInfo.Userdetail.Userrecordinfo.Imageurl
        GameData.Table.Players[1].PlayerInfo.UserName = PlayerInfo.Userdetail.Userbaseinfo.UserName
        GameData.Table.Players[1].PlayerInfo.UserSex = PlayerInfo.Userdetail.Userbaseinfo.UserSex
    else
        local ChairId = SChairIdToChairId(SChairID)
        GameData.Table.Players[ChairId].SChairId = SChairID
        GameData.Table.Players[ChairId].PlayerInfo.UserID = PlayerInfo.UserID
        GameData.Table.Players[ChairId].PlayerInfo.Imageurl = PlayerInfo.Userdetail.Userrecordinfo.Imageurl
        GameData.Table.Players[ChairId].PlayerInfo.UserName = PlayerInfo.Userdetail.Userbaseinfo.UserName
        GameData.Table.Players[ChairId].PlayerInfo.UserSex = PlayerInfo.Userdetail.Userbaseinfo.UserSex
    end
    --添加解散通用界面的玩家信息
    DismissManager.AddUserInfo(PlayerInfo.UserID, PlayerInfo.Userdetail.Userbaseinfo.UserName, 
    PlayerInfo.Userdetail.Userbaseinfo.UserSex, PlayerInfo.Userdetail.Userrecordinfo.Imageurl)
    GameData.CurrPlayerNum = GameData.CurrPlayerNum + 1
end

--新用户加入房间
function SetPlayerIntoRoom(Data)
    local ChairId = SChairIdToChairId(Data.Index);
    if ChairId ~= 0 then
        GameData.CurrPlayerNum = GameData.CurrPlayerNum + 1
        GameData.Table.Players[ChairId].SChairId = Data.Index
        GameData.Table.Players[ChairId].PlayerInfo.UserID = Data.Baseuser.UserID
        GameData.Table.Players[ChairId].PlayerInfo.Imageurl = Data.Baseuser.Userdetail.Userrecordinfo.Imageurl
        GameData.Table.Players[ChairId].PlayerInfo.UserName = Data.Baseuser.Userdetail.Userbaseinfo.UserName
        GameData.Table.Players[ChairId].PlayerInfo.UserSex = Data.Baseuser.Userdetail.Userbaseinfo.UserSex
        GameData.Table.Players[ChairId].IsTrustFlag = (Data.Roomuser.TrustFlag == 1) and true or false
        GameData.Table.Players[ChairId].IsReady = (Data.Roomuser.bReady == 1) and true or false
        GameData.Table.Players[ChairId].IsAdmitLostFlag = (Data.Roomuser.AdmitLostFlag == 1) and true or false
        GameData.Table.Players[ChairId].Score = Data.Roomuser.SettleItemNum
        GameData.Table.Players[ChairId].MapPoint.X = StringToNumber(Data.Roomuser.Usermapinfo.Mappoint1)
        GameData.Table.Players[ChairId].MapPoint.Y = StringToNumber(Data.Roomuser.Usermapinfo.Mappoint2)
        GameData.Table.Players[ChairId].MapPoint.IsOpenGPS = (GameData.Table.Players[ChairId].MapPoint.X ~= 0 and GameData.Table.Players[ChairId].MapPoint.Y ~= 0) and true or false
        --添加解散通用界面的玩家信息
        DismissManager.AddUserInfo(Data.Baseuser.UserID, Data.Baseuser.Userdetail.Userbaseinfo.UserName, 
        Data.Baseuser.Userdetail.Userbaseinfo.UserSex, Data.Baseuser.Userdetail.Userrecordinfo.Imageurl)
    end
    return ChairId
end

--設置玩家離開房間
function SetPlayerLeaveRoom(Data)
    local ChairId = UserIDToChairId(Data);
    if ChairId ~= 0 then
        GameData.CurrPlayerNum = GameData.CurrPlayerNum - 1
        DismissManager.RemoveUserInfo(GameData.Table.Players[ChairId].PlayerInfo.UserID)            --玩家离开房间
        GameData.Table.Players[ChairId].SChairId = -1
        GameData.Table.Players[ChairId].PlayerInfo.UserID = 0 --= {UserID=0,Imageurl="",UserName="",UserSex=0}
        GameData.Table.Players[ChairId].MapPoint = {X=0,Y=0}
        GameData.Table.Players[ChairId].SettleItemNum = 0                                             
        GameData.Table.Players[ChairId].IsReady = false                                               
        GameData.Table.Players[ChairId].IsTrustFlag = false                                           
        GameData.Table.Players[ChairId].IsAdmitLostFlag = false                                      
    end
    return ChairId
end

--设置房间规则
function SetRoomRule(Data,buff)
    GameData.RoomRule.SettleType = Data.SettleType                  --结算方式
    GameData.RoomRule.EndPointType = Data.EndPointType              --底分
    GameData.RoomRuleBuff = buff                                    --缓存规则数据
    local agr1,agr2,agr3 = GameRuleHelper.ParseRuleDisplay(GameData.GameId,buff)
    GameData.GameRuleInfoStrList = {agr1,agr2,agr3}
end

--设置玩家的准备状态
function SetPlayerIsReady(Data)
    local ChairId = UserIDToChairId(Data.UserID)
    GameData.Table.Players[ChairId].IsReady = (Data.bReady == 1) and true or false
    return ChairId
end

--设置玩家货币改变
function SetPlayerScore(Data)
    local PlayerScoreChanage = {}
    for i,v in ipairs(Data) do
        local _ChairId = UserIDToChairId(v.UserID)
        GameData.Table.Players[_ChairId].Score = v.SettleItemNum
        table.insert(PlayerScoreChanage,{ChairId=_ChairId,ChanageType = v.GetItemType,ChanageValue = v.UserItemNum})
    end
    return PlayerScoreChanage
end

function SetPlayerRealScore(Data)
    for i,v in ipairs(Data.RoomUserItem) do
        local ChairId = UserIDToChairId(v.ReportUserID)
        if ChairId ~= 0 then
            GameData.Table.Players[ChairId].Score = v.ReportItemNum
        end
    end
end


function SetPlayerIsTrustFlag(Data)
    GameData.Table.Players[1].IsTrustFlag = Data == 1 and true or false
end

--设置玩家是否在线
function SetPlayerIsOnline(Data)
    local ChairId = UserIDToChairId(Data.UserID)
    if ChairId ~= 0 then
        GameData.Table.Players[ChairId].IsOnline = Data.Useronlined == 1 and true or false
        GameData.Table.Players[ChairId].IsTrustFlag = Data.TrustFlag == 1 and true or false
    end
    return ChairId
end

--------------------------------------------游戏逻辑------------------------------------

--发牌
function SetFaPai(Data)
    GameData.Table.GameStatus = DouDiZhu.FaPai
    GameData.Table.CurrOperatChairId = 0
    GameData.IntoGameNum = Data.Createinfo.IntoGameNum
    for i1,v1 in ipairs(Data.RoomUser) do
        local ChairId = SChairIdToChairId(i1-1)
        if ChairId ~= 0 then
            GameData.Table.Players[ChairId].HandPKs = {}
            for i2,v2 in ipairs(v1.BrandID) do
                if v2 ~= 0 then
                    table.insert(GameData.Table.Players[ChairId].HandPKs,v2)
                end
            end
            if ChairId ~= 1 then
                SortHandPks(ChairId)
            end
        end
    end
end

--设置当前叫分玩家
function SetCurrCallScorePlayer(Data)
    local LastCallChairId =  GameData.Table.CurrOperatChairId
    local ChairId = UserIDToChairId(Data.CurRunUserID)
    if ChairId ~= 0 then
        GameData.Table.GameStatus = DouDiZhu.CallScore
        GameData.Table.CurrOperatChairId = ChairId
        GameData.Table.BankerCallScore = Data.CurCallPoint > GameData.Table.BankerCallScore and Data.CurCallPoint or GameData.Table.BankerCallScore
        if GameData.Table.CurCallScore == Data.CurCallPoint then
            GameData.Table.CurCallScore = 0
        else
            GameData.Table.CurCallScore = Data.CurCallPoint
        end
    end
    return ChairId,LastCallChairId
end

--设置地主
function SetCallLandlord(Data)
    local ChairId = UserIDToChairId(Data.RoomUserID)
    if ChairId ~= 0 then
        GameData.Table.GameStatus = DouDiZhu.InGame
        GameData.Table.BankerChairId = ChairId
        GameData.Table.CurrOperatChairId = ChairId
        local Index = 1
        for i1,v1 in ipairs(Data.BrandID) do
            if v1 ~= 0 then
                local IsKeep = false
                for i2,v2 in ipairs(GameData.Table.Players[ChairId].HandPKs) do
                    if v1 == v2 then
                        IsKeep = true
                        break
                    end
                end
                if not IsKeep then
                    GameData.Table.AhandPks[Index] = v1
                    Index = Index + 1
                end
            end
        end
        for i,v in ipairs(GameData.Table.AhandPks) do
            table.insert(GameData.Table.Players[ChairId].HandPKs,v)
        end
        SortHandPks(ChairId)
    end
    return ChairId
end

--玩家出牌
function SetPlayerChuPai(Data)
    local OutChairId = UserIDToChairId(Data.LastMesaUserID)                     --出牌玩家
    local CuuRunChairId = UserIDToChairId(Data.CurRunUserID)                    --当前操作玩家
    GameData.Table.MultipleNum = Data.MultipleNum
    print("砸蛋倍数 = "..Data.MultipleNum)
    if OutChairId ~= 0 then
        GameData.Table.LastPokeType = Data.LastPokeType                         --最后出牌类型
        GameData.Table.LastChuPaiPks = {}
        for i,v in ipairs(Data.LastMesaBrandID) do                              --最后打出牌
            if v ~= 0 then
                table.insert(GameData.Table.LastChuPaiPks,v)
                RemoveTableValue(GameData.Table.Players[OutChairId].HandPKs,v)  --移除玩家手牌
            end
        end
    end
    GameData.Table.LastChuPaiChairId = OutChairId
    GameData.Table.CurrOperatChairId = CuuRunChairId
    return OutChairId,CuuRunChairId
end

--玩家出牌过
function SetPlayerChuPaiPass(Data)
    local PassChairId = GameData.Table.CurrOperatChairId                        --Pass玩家
    local CuuRunChairId = UserIDToChairId(Data.CurRunUserID)                    --当前操作玩家
    GameData.Table.CurrOperatChairId = CuuRunChairId
    return PassChairId,CuuRunChairId
end

--游戏结算
function SetGameResult(Data)
    GameData.Table.GameStatus = GameState.STEPNULL
    local GameResultData = {}
    GameResultData.bAllResHasFlag = Data.bAllResHasFlag == 1 and true or false
    GameResultData.PlayerData = {}
    for i,v in ipairs(Data.Houseloadres) do
        local ChairId = UserIDToChairId(v.UserID)
        if ChairId ~= 0 then
            GameResultData.PlayerData[ChairId] = {}
            GameResultData.PlayerData[ChairId].WinFlag = v.WinFlag == 1 and true or false           --胜利
            GameResultData.PlayerData[ChairId].Multiple = v.Multiple                                --倍数
            GameResultData.PlayerData[ChairId].SettleType = v.SettleType                            --结算类型
            GameResultData.PlayerData[ChairId].Integral = v.SettleItemNum                           --结算的数值
            GameResultData.PlayerData[ChairId].SpringFlag = v.SpringFlag == 1 and true or false     --春天
            GameResultData.SpringFlag = GameResultData.PlayerData[ChairId].SpringFlag               
            GameResultData.PlayerData[ChairId].OverFlag = v.OverFlag == 1 and true or false         --封顶
        end
    end
    GameData.Table.GameResultData = GameResultData
end

--初始化下一局游戏数据
function SetGameDataContinue()
    GameData.Table.GameStatus = GameState.STEPNULL
    GameData.Table.CurrOperatChairId = 0
    GameData.Table.CurCallScore = 0
    GameData.Table.BankerChairId =  0
    GameData.Table.BankerCallScore = 0
    GameData.Table.LastChuPaiChairId = 0
    GameData.Table.MultipleNum = 0
    GameData.Table.LastPokeType = POKETYPE.POKE_INVALID
    GameData.Table.LastChuPaiPks = {}
    GameData.Table.AhandPks = {0,0,0}
    if GameData.RoomRule.SettleType == 2 then
        GameData.IntoGameNum = 0
    end 
    for i=1,3 do
        GameData.Table.Players[i].IsReady = false
        GameData.Table.Players[i].IsTrustFlag = false
        GameData.Table.Players[i].IsAdmitLostFlag = false
        GameData.Table.Players[i].HandPKs = {}
    end
end

--房间结算
function SetRoomResult(Data)
    GameData.Table.GameStatus = GameState.STEPNULL
    local RoomResultData = {}
    for i,v in ipairs(Data) do
        local ChairId = UserIDToChairId(v.UserID)
        if ChairId ~= 0 then
            RoomResultData[ChairId] = {}
            RoomResultData[ChairId].Integral = v.Userroomrecord.SettleItemNum
            RoomResultData[ChairId].WinNum = v.Userroomrecord.WinNum
            RoomResultData[ChairId].FailNum = v.Userroomrecord.FailNum
            RoomResultData[ChairId].SingleMaxIntegral = v.Userroomrecord.SingleMaxIntegral
        end
    end
    GameData.RoomResultData = RoomResultData
end

-----------------------------------------------数据读取接口-------------------------------------------
function GetGameData()
    return GameData
end

function SortHandPks(ChairId)
    table.sort(GameData.Table.Players[ChairId].HandPKs, function(a,b)
        local t1,v1 = math.modf(a/16)
        v1 = v1*16
        if v1 < 3 then v1 = v1 + 15 end

        local t2,v2 = math.modf(b/16)
        v2 = v2*16
        if v2 < 3 then v2 = v2 + 15 end

        return v1 > v2 
        -- if v1 < v2 then
        --     return false
        -- elseif v1 > v2 then
        --     return true
        -- else
        --     if t1 < t2 then
        --         return false
        --     else
        --         return true
        --     end
        -- end
    end)
end

-- 是否可以直接解散 1 可以直接界面 2当前玩家无权解散房间 3申请解散
function CanDisbandNow()
	if GameData.Table.GameStatus == GameState.STEPNULL and  GameData.IntoGameNum == 0 then --未开局之前之后房主有权解散房间
        if GameData.CreaterChairId == 1 then
            return 1
        else
            return 2
        end
	else
        return 3
	end
end

function RemoveTableValue(DataTable,Value)
    for i,v in ipairs(DataTable) do
        if v == Value then
            table.remove(DataTable,i)
            return
        end
    end
end

-----------------------------------------------游戲工具函數-------------------------------------------

function SChairIdToChairId(SChairId)
    if GameData.Table.Players[1].SChairId ~= -1 then
        return (SChairId - GameData.Table.Players[1].SChairId + 3 )%3 +1;
    else
        ModelLog("自己的座位都还不知道！ 无效玩家")
        return 0 
    end
end

function UserIDToChairId(UserID)
    if UserID == 0 then return 0 end
    for i,v in ipairs(GameData.Table.Players) do
        if v.PlayerInfo.UserID == UserID then
            return i
        end
    end
    return 0
end

function DebugGameData(Title)
    ModelLog(Title,GameDataStr(GameData))
end
