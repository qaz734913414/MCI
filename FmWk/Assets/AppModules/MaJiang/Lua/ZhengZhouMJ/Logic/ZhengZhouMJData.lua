module("ZhengZhouMJ", package.seeall)
local GameData = nil;

function GameDataInit(RoomId,GameId)
    GameData = TableCopy(GameConfigData)
    GameData.GameId = GameId
    GameData.RoomId = RoomId
    DebugGameData("初始化房间信息");
end

--设置房间信息恢复 (重连)
function SetRoomDataRecovery(RoomData,PlayerData)
    GameData.CreateRoomTime = RoomData.Roomdetail.Baseroominfo.CreateRoomTime
    GameData.GamePlayerNum = RoomData.Roomdetail.Roomruleinfo.PersonType
    GameData.AllGameNum = RoomData.Roomdetail.Createinfo.AllGameNum
    GameData.IntoGameNum = RoomData.Roomdetail.Createinfo.IntoGameNum
    GameData.Table.GameStatus = RoomData.Roomdetail.Baseroominfo.MahStep
    GameData.Table.DaPiaoTime = RoomData.Roomdetail.Createinfo.DriftingSeconds 
    GameData.Table.OperationTime = RoomData.Roomdetail.Createinfo.OverTimeTrust
    GameData.Table.OperationLeftTime = RoomData.Roomdetail.Baseroominfo.StopSeconds - (Network.GetServerTime() - RoomData.Roomdetail.Baseroominfo.LastSetTime)
    SetRoomRule(RoomData.Roomdetail.Roomruleinfo,RoomData.Roomdetail.Roomrulebuff)
    for i,v in ipairs(PlayerData.Baseuser) do
        if v.UserID ~= 0 and v.UserID == _G["profile"].id then     --先把自己的信息找到 不然不好定座位
            SetRoomPlayerInfo(i-1,v,true)       --服务器id是从0开始的 所以-1
        end
    end
    for i,v in ipairs(PlayerData.Baseuser) do
        if v.UserID ~= 0 and v.UserID ~= _G["profile"].id then     --先把自己的信息找到 不然不好定座位
            SetRoomPlayerInfo(i-1,v,false)
        end
    end
    for i,v in ipairs(PlayerData.Useronlined) do
        local ChairId = SChairIdToChairId(i-1)
        if ChairId ~= 0 then
            GameData.Table.Players[ChairId].IsOnline =  v == 1 and true or false
        end
    end
    GameData.CreaterInfo.UserID = RoomData.Roomdetail.Createinfo.CreateUserID                      --创建者id
    GameData.CreaterInfo.UnionGroupID = RoomData.Roomdetail.Createinfo.UnionGroupID                --联盟id
    GameData.CreaterInfo.CreateUnionID = RoomData.Roomdetail.Createinfo.CreateUnionID              --创建者所在的战队ID
    GameData.CreaterInfo.CreateUnionName = RoomData.Roomdetail.Createinfo.CreateUnionName          --创建者战队名称
    GameData.CreaterChairId = UserIDToChairId(RoomData.Roomdetail.Createinfo.CreateUserID)          --房主
    GameData.IsClubRoom = RoomData.Roomdetail.Createinfo.CreateUnionID ~= 0 and true or false       --是否是俱乐部
    GameData.Table.BankerChairId = UserIDToChairId(RoomData.Roomdetail.Baseroominfo.BankerUserID)
    for i,v in ipairs(RoomData.Roomdetail.RoomUser) do
        local ChairId = SChairIdToChairId(i-1)
        if ChairId ~= 0 then
            GameData.Table.Players[ChairId].DaPiaoNum = v.DriftingNum == 255 and -1 or v.DriftingNum
            GameData.Table.Players[ChairId].IsTrustFlag = (v.TrustFlag == 1) and true or false
            GameData.Table.Players[ChairId].IsReady = (v.bReady == 1) and true or false
            GameData.Table.Players[ChairId].IsTing = (v.ListenFlag == 1) and true or false
            GameData.Table.HavePlayerTing = GameData.Table.Players[ChairId].IsTing and true or GameData.Table.HavePlayerTing
            GameData.Table.Players[ChairId].IsAdmitLostFlag = (v.AdmitLostFlag == 1) and true or false
            GameData.Table.Players[ChairId].Score = v.SettleItemNum
            GameData.Table.Players[ChairId].MapPoint.X = StringToNumber(v.Usermapinfo.Mappoint1)
            GameData.Table.Players[ChairId].MapPoint.Y = StringToNumber(v.Usermapinfo.Mappoint2)
            GameData.Table.Players[ChairId].MapPoint.IsOpenGPS = (GameData.Table.Players[ChairId].MapPoint.X ~= 0 and GameData.Table.Players[ChairId].MapPoint.Y ~= 0) and true or false
            for i1,v1 in ipairs(v.Mahjong) do
                if v1.MahjongStatus == 0 then
                    local MJ = SMJCardToCMJCard(v1.MahjongID)
                    if MJ ~= 0 then
                        table.insert(GameData.Table.Players[ChairId].HandMJ,MJ)
                    end
                end
            end
            SortHandMJ(ChairId)
            if ChairId == 1 then
                UpdataPlayerTingData(v)
            end
        end
    end
    for i,v in ipairs(RoomData.ExtenMajong) do
        local ChairId = SChairIdToChairId(i-1)
        if ChairId ~= 0 then
            for i1,v1 in ipairs(v.UserMajongEffect) do            --恢复打出牌数据
                if v1.MahjongID ~= 0 then
                    local MJ = SMJCardToCMJCard(v1.MahjongID)
                    local _SourceChairId = SChairIdToChairId(v1.ObjUserIndex)
                    if v1.MahjongStatus == MJHandleType.MAHJSTATOUCH then --碰
                        table.insert(GameData.Table.Players[ChairId].HandleMJ,{Type = MJHandleType.MAHJSTATOUCH,SourceChairId = _SourceChairId,MJs={MJ,MJ,MJ}})
                    elseif v1.MahjongStatus == MJHandleType.MAHJSTAABAR then --明杠
                        table.insert(GameData.Table.Players[ChairId].HandleMJ,{Type = MJHandleType.MAHJSTAABAR,SourceChairId = _SourceChairId,MJs={MJ,MJ,MJ,MJ}})
                    elseif v1.MahjongStatus == MJHandleType.MAHJSTAREPAIRBAR then --补杠
                        table.insert(GameData.Table.Players[ChairId].HandleMJ,{Type = MJHandleType.MAHJSTAREPAIRBAR,SourceChairId = _SourceChairId,MJs={MJ,MJ,MJ,MJ}})
                    elseif v1.MahjongStatus == MJHandleType.MAHJSTADARKBAR then --暗杠
                        table.insert(GameData.Table.Players[ChairId].HandleMJ,{Type = MJHandleType.MAHJSTADARKBAR,SourceChairId = _SourceChairId,MJs={MJ,MJ,MJ,MJ}})
                    end
                end
            end
            for i1,v1 in ipairs(v.HasOutMajongID) do            --恢复打出牌数据
                local MJ = SMJCardToCMJCard(v1)
                if MJ ~= 0 then
                    table.insert(GameData.Table.Players[ChairId].OutMJ,MJ)
                end
            end
        end
    end
    GameData.Table.CurRunChairId = UserIDToChairId(RoomData.Roomdetail.Baseroominfo.CurRunUserID)
    if RoomData.Roomdetail.Baseroominfo.CurUserMajongID ~= 0 then
        GameData.Table.Players[GameData.Table.CurRunChairId].MoPaiMJ = SMJCardToCMJCard(RoomData.Roomdetail.Baseroominfo.CurUserMajongID)
    end 
    if GameData.Table.GameStatus > GameState.STEPNULL then
        SetPlayerDeskPierNum()
    end
    GameData.Table.LastChuPaiChairId = UserIDToChairId(RoomData.Roomdetail.Baseroominfo.LastOutMahjongUserID)
    GameData.Table.LastChuPaiMJ = SMJCardToCMJCard(RoomData.Roomdetail.Baseroominfo.LastMahjongID)
    GameData.Table.DeskMJFaceIndx = RoomData.Roomdetail.Baseroominfo.AllMahjongNum - (RoomData.Roomdetail.Baseroominfo.AllFreeMahjongNum + RoomData.Roomdetail.Baseroominfo.BackOutMahjongNum)
    GameData.Table.DeskMJBackIndx = RoomData.Roomdetail.Baseroominfo.AllMahjongNum - RoomData.Roomdetail.Baseroominfo.BackOutMahjongNum
    GameData.Table.FirstDices[1] = RoomData.Roomdetail.Baseroominfo.FirstDiceID[1]
    GameData.Table.FirstDices[2] = RoomData.Roomdetail.Baseroominfo.FirstDiceID[2]
    GameData.Table.SecondDices[1] = RoomData.Roomdetail.Baseroominfo.SecondDiceID[1]
    GameData.Table.SecondDices[2] = RoomData.Roomdetail.Baseroominfo.SecondDiceID[2]
    GameData.Table.RemakeID = SMJCardToCMJCard(RoomData.Roomdetail.Baseroominfo.RemakeID)
    GameData.Table.LaiZis[1] =  SMJCardToCMJCard(RoomData.Roomdetail.Baseroominfo.RogueID[1])
    GameData.Table.LaiZis[2] =  SMJCardToCMJCard(RoomData.Roomdetail.Baseroominfo.RogueID[2])
    for i,v in ipairs(RoomData.Roomdetail.Userproshow) do
        local ChairId = SChairIdToChairId(i-1)
        if ChairId ~= 0 then
            SetPlayerOperationData(ChairId,v)
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
        GameData.Table.Players[ChairId].SChairId = Data.Index
        GameData.Table.Players[ChairId].PlayerInfo.UserID = Data.Baseuser.UserID
        GameData.Table.Players[ChairId].PlayerInfo.Imageurl = Data.Baseuser.Userdetail.Userrecordinfo.Imageurl
        GameData.Table.Players[ChairId].PlayerInfo.UserName = Data.Baseuser.Userdetail.Userbaseinfo.UserName
        GameData.Table.Players[ChairId].PlayerInfo.UserSex = Data.Baseuser.Userdetail.Userbaseinfo.UserSex
        GameData.Table.Players[ChairId].DaPiaoNum = Data.Roomuser.DriftingNum
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
        GameData.CurrPlayerNum = GameData.CurrPlayerNum + 1
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
        GameData.Table.Players[ChairId].PlayerInfo.UserID = 0 -- = {UserID=0,Imageurl="",UserName="",UserSex=0}
        GameData.Table.Players[ChairId].MapPoint = {X=0,Y=0}
        GameData.Table.Players[ChairId].DeskPierNum = 0
        GameData.Table.Players[ChairId].IsTing = false
        GameData.Table.Players[ChairId].SettleItemNum = 0                                             
        GameData.Table.Players[ChairId].IsReady = false                                               
        GameData.Table.Players[ChairId].IsTrustFlag = false                                           
        GameData.Table.Players[ChairId].IsAdmitLostFlag = false                                      
        GameData.Table.Players[ChairId].DaPiaoNum = 0
        GameData.Table.Players[ChairId].MoPaiMJ = nil
        GameData.Table.Players[ChairId].HandMJ = {}
        GameData.Table.Players[ChairId].OutMJ = {}
        GameData.Table.Players[ChairId].HandleMJ = {}
        GameData.Table.Players[ChairId].Operations = {}
    end
    return ChairId
end

--设置房间规则
function SetRoomRule(Data,buff)
    GameData.RoomRule.SettleType = Data.SettleType                  --结算方式
    GameData.RoomRule.DriftingType = Data.DriftingType              --漂类型，下跑
    GameData.RoomRule.GapType = Data.GapType                        --断门
    GameData.RoomRule.DrogueType = Data.DrogueType                  --带赖子数量，没赖子，1赖，2赖，混牌
    GameData.RoomRule.OneDrawType = Data.OneDrawType                --只能自摸标记，胡牌
    GameData.RoomRule.SutWindType = Data.SutWindType                --带风标记，风牌
    GameData.RoomRule.FankinDanker = Data.FankinDanker              --庄倍数 --庄加加底
    GameData.RoomRule.FankinSevenSub = Data.FankinSevenSub          --7队倍数 --7对
    GameData.RoomRule.FankinBloomBar = Data.FankinBloomBar          --杠上开花倍数，也包括杠上炮
    GameData.RoomRule.FankinBarRun = Data.FankinBarRun              --杠跑
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
--定庄
function SetBanker(Data)
    local ChairId = UserIDToChairId(Data.BankerUserID)
    GameData.Table.BankerChairId = ChairId
    GameData.Table.GameStatus = GameState.STEPVILLAGE
    GameData.IntoGameNum = GameData.IntoGameNum + 1
    SetPlayerDeskPierNum()
end

--开始打票 确定用户门前的牌墩数
function SetStartDaPiao(Data)
    GameData.Table.BankerChairId = UserIDToChairId(Data.BankerUserID)  
    GameData.Table.OperationLeftTime = Data.StopSeconds - (Network.GetServerTime() - Data.LastSetTime)
    for i=1,4 do
        GameData.Table.Players[i].DaPiaoNum = -1
    end
    GameData.Table.GameStatus = GameState.STEPDRIFTING
end

--玩家打票
function SetPlayerDaPiao(Data)
    local ChairId = UserIDToChairId(Data.UserID)
    GameData.Table.Players[ChairId].DaPiaoNum = Data.DriftingNum
    return ChairId
end

--发牌
function SetFaPai(Data)
    GameData.Table.GameStatus = Data.Baseroominfo.MahStep
    GameData.Table.FirstDices[1] = Data.Baseroominfo.FirstDiceID[1]
    GameData.Table.FirstDices[2] = Data.Baseroominfo.FirstDiceID[2]
    GameData.Table.SecondDices[1] = Data.Baseroominfo.SecondDiceID[1]
    GameData.Table.SecondDices[2] = Data.Baseroominfo.SecondDiceID[2]
    GameData.Table.RemakeID = SMJCardToCMJCard(Data.Baseroominfo.RemakeID)
    GameData.Table.LaiZis[1] =  SMJCardToCMJCard(Data.Baseroominfo.RogueID[1])
    GameData.Table.LaiZis[2] =  SMJCardToCMJCard(Data.Baseroominfo.RogueID[2])
    for i1,v1 in ipairs(Data.RoomUser) do
        local ChairId = SChairIdToChairId(i1-1)
        if ChairId ~= 0 then
            for i2,v2 in ipairs(v1.Mahjong) do
                local MJ = SMJCardToCMJCard(v2.MahjongID)
                table.insert(GameData.Table.Players[ChairId].HandMJ,MJ)
            end
        end
    end
end

--摸牌
function SetPlayerMoPai(Data)
    local ChairId = UserIDToChairId(Data.UserID)
    GameData.Table.Players[ChairId].MoPaiMJ = SMJCardToCMJCard(Data.NewMahjongID)
    GameData.Table.OperationLeftTime = GameData.Table.OperationTime             --设置倒计时
    local BackFlag = Data.BackFlag == 1 and true or false
    if not BackFlag then
        GameData.Table.DeskMJFaceIndx = GameData.Table.DeskMJFaceIndx+1
    else
        GameData.Table.DeskMJBackIndx = GameData.Table.DeskMJBackIndx-1
    end
    GameData.Table.CurRunChairId = ChairId
    GameData.Table.Players[1].CanHuData = {}
    return ChairId,BackFlag
end

--玩家出牌
function SetPlayerChuPai(Data)
    print("玩家出牌 1")
    local ChairId = UserIDToChairId(Data.UserID)
    local MJ = SMJCardToCMJCard(Data.MahjongID[1])
    if GameData.Table.Players[ChairId].MoPaiMJ then                 --先将摸牌移入数组
        table.insert(GameData.Table.Players[ChairId].HandMJ,GameData.Table.Players[ChairId].MoPaiMJ)
        GameData.Table.Players[ChairId].MoPaiMJ = nil
    end
    RemoveTableValue(GameData.Table.Players[ChairId].HandMJ,MJ)     --将打出牌移出手牌
    table.insert(GameData.Table.Players[ChairId].OutMJ,MJ)          --将出牌移入到打出牌列表中
    GameData.Table.LastChuPaiChairId = ChairId
    GameData.Table.LastChuPaiMJ = MJ
    SortHandMJ(ChairId)
    if ChairId == 1 then
        local IsTingMJ,HuData = IsOutCanHuMJ(MJ)
        if IsTingMJ then
            GameData.Table.Players[1].TingData = HuData and HuData or {}
        else
            if not GameData.Table.Players[1].IsTing then
                GameData.Table.Players[1].TingData = {}
            end
        end
    end
    return ChairId,MJ
end

--自己的操作对话框
function SetOperationData(Data)
    for i,v in ipairs(GameData.Table.Players) do
        v.Operations ={}
    end
    local ChairId = SChairIdToChairId(Data.UserIndex)
    SetPlayerOperationData(ChairId,Data.Userproshow)
end

--设置玩家的对话框
function SetPlayerOperationData(ChairId,Data)
    local Operations = {}                       --Operation={Type = MJHandleType.MAHJSTATOUCH ,Operats={Type,MJ}} MahjongStatus
    for i1,v1 in ipairs(Data.MahjongStatus) do
        if v1 ~= 0 then                          --过滤无效操作
            local IsKeep = false
            for i2,v2 in ipairs(Operations) do
                if v1 == v2.Type or (v2.Type == MJHandleType.Gang and (v1 == MJHandleType.MAHJSTAABAR or v1 == MJHandleType.MAHJSTAREPAIRBAR or v1 == MJHandleType.MAHJSTADARKBAR)) then
                    local Operat = {Type = v1,MJ = SMJCardToCMJCard(Data.MahjongID[i1])}
                    table.insert(v2.Operats,Operat)
                    IsKeep = true
                end
            end
            if not IsKeep and v1 ~= 0 then
                if (v1 == MJHandleType.MAHJSTAABAR or v1 == MJHandleType.MAHJSTAREPAIRBAR or v1 == MJHandleType.MAHJSTADARKBAR) then 
                    local Operation = {Type = MJHandleType.Gang ,Operats={{Type = v1,MJ = SMJCardToCMJCard(Data.MahjongID[i1])}}}
                    table.insert(Operations,Operation)
                else
                    local Operation = {Type = v1 ,Operats={{Type = v1,MJ = SMJCardToCMJCard(Data.MahjongID[i1])}}}
                    table.insert(Operations,Operation)
                end
            end
        end
    end
    GameData.Table.Players[ChairId].Operations = Operations
end


--碰牌
function SetPlayerPenPai(Data)
    local ChairId = UserIDToChairId(Data.UserID)
    local MJ = SMJCardToCMJCard(Data.MahjongID[1])
    if GameData.Table.Players[ChairId].MoPaiMJ then                 --先将摸牌移入数组
        table.insert(GameData.Table.Players[ChairId].HandMJ,GameData.Table.Players[ChairId].MoPaiMJ)
        GameData.Table.Players[ChairId].MoPaiMJ = nil
    end
    table.remove(GameData.Table.Players[GameData.Table.LastChuPaiChairId].OutMJ)            --从最后出牌玩家的打出牌中移除最后一张牌
    table.insert(GameData.Table.Players[ChairId].HandMJ,GameData.Table.LastChuPaiMJ)        --将操作牌先放入手牌在统一移除
    RemoveTableNumValue(GameData.Table.Players[ChairId].HandMJ,MJ,3)     --将打出牌移出手牌
    table.insert(GameData.Table.Players[ChairId].HandleMJ,{Type = Data.MahjongStatus,SourceChairId = GameData.Table.LastChuPaiChairId,MJs={MJ,MJ,MJ}})
    SortHandMJ(ChairId)
    GameData.Table.CurRunChairId = ChairId
    return ChairId,MJ
end

--明杠
function SetPlayerMGang(Data)
    local ChairId = UserIDToChairId(Data.UserID)
    local MJ = SMJCardToCMJCard(Data.MahjongID[1])
    if GameData.Table.Players[ChairId].MoPaiMJ then                 --先将摸牌移入数组
        table.insert(GameData.Table.Players[ChairId].HandMJ,GameData.Table.Players[ChairId].MoPaiMJ)
        GameData.Table.Players[ChairId].MoPaiMJ = nil
    end
    table.remove(GameData.Table.Players[GameData.Table.LastChuPaiChairId].OutMJ)            --从最后出牌玩家的打出牌中移除最后一张牌
    table.insert(GameData.Table.Players[ChairId].HandMJ,GameData.Table.LastChuPaiMJ)        --将操作牌先放入手牌在统一移除
    RemoveTableNumValue(GameData.Table.Players[ChairId].HandMJ,MJ,4)     --将打出牌移出手牌
    table.insert(GameData.Table.Players[ChairId].HandleMJ,{Type = Data.MahjongStatus,SourceChairId = GameData.Table.LastChuPaiChairId,MJs={MJ,MJ,MJ,MJ}})
    SortHandMJ(ChairId)
    GameData.Table.CurRunChairId = ChairId
    return ChairId,MJ
end

--补杠
function SetPlayerBGang(Data)
    local ChairId = UserIDToChairId(Data.UserID)
    local MJ = SMJCardToCMJCard(Data.MahjongID[1])
    if GameData.Table.Players[ChairId].MoPaiMJ then                 --先将摸牌移入数组
        table.insert(GameData.Table.Players[ChairId].HandMJ,GameData.Table.Players[ChairId].MoPaiMJ)
        GameData.Table.Players[ChairId].MoPaiMJ = nil
    end
    RemoveTableNumValue(GameData.Table.Players[ChairId].HandMJ,MJ,1)                        --将打出牌移出手牌
    for i,v in ipairs(GameData.Table.Players[ChairId].HandleMJ) do
        if v.Type == MJHandleType.MAHJSTATOUCH and v.MJs[1] == MJ then                      --将碰的操作转成补杠
            v.Type = Data.MahjongStatus
            v.MJs = {MJ,MJ,MJ,MJ}
            break
        end
    end
    SortHandMJ(ChairId)
    GameData.Table.CurRunChairId = ChairId
    return ChairId,MJ
end

--暗杠
function SetPlayerAGang(Data)
    local ChairId = UserIDToChairId(Data.UserID)
    local MJ = SMJCardToCMJCard(Data.MahjongID[1])
    if GameData.Table.Players[ChairId].MoPaiMJ then                 --先将摸牌移入数组
        table.insert(GameData.Table.Players[ChairId].HandMJ,GameData.Table.Players[ChairId].MoPaiMJ)
        GameData.Table.Players[ChairId].MoPaiMJ = nil
    end
    RemoveTableNumValue(GameData.Table.Players[ChairId].HandMJ,MJ,4)                        --将打出牌移出手牌
    table.insert(GameData.Table.Players[ChairId].HandleMJ,{Type = Data.MahjongStatus,SourceChairId = ChairId,MJs={MJ,MJ,MJ,MJ}})
    SortHandMJ(ChairId)
    GameData.Table.CurRunChairId = ChairId
    return ChairId,MJ
end

--听
function SetPlayerTing(Data)
    local ChairId = UserIDToChairId(Data.UserID)
    GameData.Table.Players[ChairId].IsTing = Data.ListenFlag == 1 and true or false
    GameData.Table.HavePlayerTing = true
    return ChairId
end

--更新玩家可胡牌信息
function UpdataPlayerCanHuMJData(Data)
    GameData.Table.Players[1].CanHuData = {}
    for i,v in ipairs(Data) do
        local HuData = {}
        HuData.OutMJ = SMJCardToCMJCard(v)
        table.insert(GameData.Table.Players[1].CanHuData,HuData)
    end
end

function UpdataPlayerCanHuMJDetailedData(Data)
    --if GameData.Table.Players[1].IsTing or GameData.Table.CurRunChairId ~= 1  then
        GameData.Table.Players[1].TingData = {}
        for i1,v1 in ipairs(Data.EnableHupai) do
            if v1.EnableHupaiID ~= 0 then
                local HuData = {}
                HuData.MJ = SMJCardToCMJCard(v1.EnableHupaiID)
                HuData.Multiple = v1.HupaiMultNum
                HuData.LeftNum = GetLeftMJNum(HuData.MJ)
                table.insert(GameData.Table.Players[1].TingData,HuData)
            end
        end 
   -- else
        local OutMJ = SMJCardToCMJCard(Data.OutMahjongID)
        for i,v in ipairs(GameData.Table.Players[1].CanHuData) do
            if v.OutMJ == OutMJ then
                v.HuMJs = {}
                for i1,v1 in ipairs(Data.EnableHupai) do
                    if v1.EnableHupaiID ~= 0 then
                        local HuData = {}
                        HuData.MJ = SMJCardToCMJCard(v1.EnableHupaiID)
                        HuData.Multiple = v1.HupaiMultNum
                        HuData.LeftNum = GetLeftMJNum(HuData.MJ)
                        table.insert(v.HuMJs,HuData)
                    end
                end 
            end
        end
   -- end
end

--更新听胡数据
function UpdataPlayerTingData(Data)
    local ChairId = UserIDToChairId(Data.RoomUserID)
    if ChairId == 1 then
        GameData.Table.Players[1].TingData = {}
        for i,v in ipairs(Data.EnableHupai) do
            if v.EnableHupaiID ~= 0 then
                TingData = {}
                TingData.MJ = SMJCardToCMJCard(v.EnableHupaiID)
                TingData.LeftNum = GetLeftMJNum(TingData.MJ)
                TingData.Multiple = v.HupaiMultNum
                table.insert(GameData.Table.Players[1].TingData,TingData)
            end
        end
    end
end

--写入自己的流水
function SetFlowingData(Data)
    local FlowingTitle = function(Integral,MahjongStatus,ActionIDs)
        local Str = ""
        if MJHandleStr[MahjongStatus] then
            if Integral < 0 and (MahjongStatus == MJHandleType.MAHJSTAOWNDRAW or MahjongStatus == MJHandleType.MAHJSTATOUCHWIN) then
                Str = Str.."被"..MJHandleStr[MahjongStatus]
            else
                Str = Str..MJHandleStr[MahjongStatus]
            end
        end
        local Str = Str.."("
        local IsStr = false
        for i,v in ipairs(ActionIDs) do
            if HuTypeStr[v] then
                Str = Str..HuTypeStr[v]..","
                IsStr = true
            end
        end
        Str = string.sub(Str,1,string.len(Str)-1)
        if IsStr then
            Str = Str..")"
        end
        return Str
    end

    local TargetPlayer = function(ObjUserID)
        local Str = ""
        if ObjUserID == 0 then  --所有玩家
            if GameData.Table.Players[4].PlayerInfo.UserID ~= 0 then Str = Str.."上家," end
            if GameData.Table.Players[3].PlayerInfo.UserID ~= 0 then Str = Str.."对家," end
            if GameData.Table.Players[2].PlayerInfo.UserID ~= 0 then Str = Str.."下家," end
            Str = string.sub(Str,1,string.len(Str)-1)
        else
            local TChairId = UserIDToChairId(ObjUserID)
            if TChairId == 4 then
                Str = Str .. "上家"
            elseif TChairId == 3 then
                Str = Str .. "对家"
            elseif TChairId == 2 then
                Str = Str .. "下家"
            end
        end
        return Str
    end
    for i,v in ipairs(Data) do
        local Flowing = {}
        local title= FlowingTitle(v.AddDeleteItemNum,v.MahjongStatus,v.ActionID)
        Flowing.Title = title
        Flowing.Multiple = v.MahjongMultiple
        Flowing.Integral = v.AddDeleteItemNum
        Flowing.ProdPlayer = TargetPlayer(v.ObjUserID)
        table.insert(GameData.Table.Players[1].FlowingData,Flowing)
    end
end
--游戏结算
function SetGameResult(Data)
    GameData.Table.GameStatus = GameState.STEPNULL
    local GameResultData = {}
    GameResultData.FlowBureauFlag = Data.FlowBureauFlag == 1 and true or false
    GameResultData.bAllResHasFlag = Data.bAllResHasFlag == 1 and true or false
    GameResultData.PlayerData = {}
    for i,v in ipairs(Data.Houseloadres) do
        local ChairId = UserIDToChairId(v.UserID)
        if ChairId ~= 0 then
            GameResultData.PlayerData[ChairId] = {}
            GameResultData.PlayerData[ChairId].Integral = v.SettleItemNum
            GameResultData.PlayerData[ChairId].PointPanFlag = v.PointPanFlag == 1 and true or false
        end
    end
    GameData.Table.GameResultData = GameResultData
end

--初始化下一局游戏数据
function SetGameDataContinue()
    GameData.Table.GameStatus = GameState.STEPNULL
    GameData.Table.BankerChairId = 0
    GameData.Table.CurRunChairId = 0
    GameData.Table.FirstDices = {0,0}
    GameData.Table.SecondDices = {0,0}
    GameData.Table.RemakeID = 0
    GameData.Table.LaiZis = {0,0}
    GameData.Table.OperationLeftTime = 0
    GameData.Table.DeskMJFaceIndx = 0
    GameData.Table.DeskMJBackIndx = 0
    GameData.Table.LastChuPaiChairId = 0
    GameData.Table.LastChuPaiMJ = 0
    GameData.Table.HavePlayerTing = false
    if GameData.RoomRule.SettleType == 2 then
        GameData.IntoGameNum = 0
    end 
    for i=1,4 do
        GameData.Table.Players[i].DeskPierNum = 0 
        GameData.Table.Players[i].IsReady = false
        GameData.Table.Players[i].IsTrustFlag = false
        GameData.Table.Players[i].IsTing = false
        GameData.Table.Players[i].IsAdmitLostFlag = false
        GameData.Table.Players[i].DaPiaoNum = -1
        GameData.Table.Players[i].MoPaiMJ = nil
        GameData.Table.Players[i].HandMJ = {}
        GameData.Table.Players[i].OutMJ = {}
        GameData.Table.Players[i].HandleMJ = {}
        GameData.Table.Players[i].Operations = {}
        if i==1 then
            GameData.Table.Players[i].FlowingData = {}
            GameData.Table.Players[i].CanHuData = {}
            GameData.Table.Players[i].TingData = {}
        end
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
            RoomResultData[ChairId].AllHuNum = v.Userroomrecord.AllHuNum
        end
    end
    GameData.RoomResultData = RoomResultData
end

-----------------------------------------------数据读取接口-------------------------------------------
function GetGameData()
    return GameData
end

--自己是否可以出牌
function IsCanOutMJ()
    local mjnum = #GameData.Table.Players[1].HandMJ
    mjnum = GameData.Table.Players[1].MoPaiMJ and mjnum+1 or mjnum
    if mjnum%3 == 2 then
        return true
    else
        return false
    end
end

function IsOutCanHuMJ(MJValue)
    if GameData.Table.Players[1].CanHuData then
        for i,v in ipairs(GameData.Table.Players[1].CanHuData) do
            if v.OutMJ == MJValue then
                return true,v.HuMJs
            end
        end
    end
    return false,nil
end

--计算玩家门前牌墩数
function SetPlayerDeskPierNum()
    local TableMJAllNum  = 0 
    if GameData.GamePlayerNum == 4 then
        for i,v in ipairs(GameData.Table.Players) do
            if GameData.RoomRule.SutWindType == 1 then      --带字牌
                v.DeskPierNum = 17
                TableMJAllNum = TableMJAllNum + v.DeskPierNum*2
            else
                if i == GameData.Table.BankerChairId or math.abs(i-GameData.Table.BankerChairId) == 2 then
                    v.DeskPierNum = 14
                    TableMJAllNum = TableMJAllNum + v.DeskPierNum*2
                else
                    v.DeskPierNum = 13
                    TableMJAllNum = TableMJAllNum + v.DeskPierNum*2
                end
            end
        end
    elseif GameData.GamePlayerNum == 3 then
        for i,v in ipairs(GameData.Table.Players) do
            if v.PlayerInfo.UserID ~= 0 then
                if i == GameData.Table.BankerChairId then
                    v.DeskPierNum = 16
                    TableMJAllNum = TableMJAllNum + v.DeskPierNum*2
                else
                    v.DeskPierNum = 17
                    TableMJAllNum = TableMJAllNum + v.DeskPierNum*2
                end
            else
                v.DeskPierNum = 0
            end
        end
    elseif GameData.GamePlayerNum == 2 then
        GameData.Table.Players[1].DeskPierNum = 16
        GameData.Table.Players[3].DeskPierNum = 16
        TableMJAllNum = 16*2*2
    end
    GameData.Table.DeskMJFaceIndx = 1
    GameData.Table.DeskMJBackIndx = TableMJAllNum
end

function ClearPlayerOperations()
    for i,v in ipairs(GameData.Table.Players) do
        v.Operations = {}
    end
end

function IsLaiZi(Value)
    if Value == 0 then return false end
    for i,v in ipairs(GameData.Table.LaiZis) do
        if Value == v then
            return true
        end
    end
    return false
end

--获取剩余麻将数量
function GetLeftMJNum(Value)
    local num = 0
    for i1,v1 in ipairs(GameData.Table.Players) do
        if i1 == 1 then
            for i2,v2 in ipairs(v1.HandMJ) do
                if Value == v2 then
                    num = num + 1
                end
            end
        end
        for i2,v2 in ipairs(v1.OutMJ) do
            if Value == v2 then
                num = num + 1
            end
        end
        for i2,v2 in ipairs(v1.HandleMJ) do
            for i3,v3 in ipairs(v2.MJs) do
                if v2.Type ~= MJHandleType.MAHJSTADARKBAR then
                    if Value == v3 then
                        num = num + 1
                    end
                else
                    if i1 == 1 or GameData.Table.HavePlayerTing then
                        if Value == v3 then
                            num = num + 1
                        end
                    end
                end
            end
        end
    end
    return 4 - num
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
-----------------------------------------------游戲工具函數-------------------------------------------
function SortHandMJ(ChairId)
    table.sort(GameData.Table.Players[ChairId].HandMJ,function(a,b)
        return a>b
    end)
end

function RemoveTableNumValue(DataTable,Value,Num)
    for i=1,Num do
        RemoveTableValue(DataTable,Value)
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


function SChairIdToChairId(SChairId)
    if GameData.GamePlayerNum == 4 then
        if GameData.Table.Players[1].SChairId ~= -1 then
            return (SChairId - GameData.Table.Players[1].SChairId + 4 )%4 +1;
        else
            ModelLog("自己的座位都还不知道！ 无效玩家")
            return 0 
        end
    elseif GameData.GamePlayerNum == 3 then
        if GameData.Table.Players[1].SChairId ~= -1 then
            if SChairId ~= 3 then
                local TemChair = (SChairId - GameData.Table.Players[1].SChairId + 4 )%4 +1;
                if TemChair == 3 then
                    if SChairId > GameData.Table.Players[1].SChairId then
                        return 4
                    else
                        return 2
                    end
                end
                return TemChair
            else
                return 0
            end
        else
            ModelLog("自己的座位都还不知道！ 无效玩家")
            return 0 
        end
    elseif GameData.GamePlayerNum == 2 then
        if GameData.Table.Players[1].SChairId ~= -1 then
            if SChairId == 0 or SChairId == 1 then
                return SChairId == GameData.Table.Players[1].SChairId and 1 or 3
            else
                return 0
            end
        else
            ModelLog("自己的座位都还不知道！ 无效玩家")
            return 0 
        end
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

--將服務器麻將
function SMJCardToCMJCard(SMJCard)
    return SMJCard
    --return string.format( "0x%02x", tonumber(SMJCard))
end

function DebugGameData(Title)
    ModelLog(Title,GameDataStr(GameData))
end
