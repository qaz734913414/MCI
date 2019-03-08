module("DouDiZhu", package.seeall)
GameState =
{
    STEPNULL				=0,					--//未开赛
    FaPai                   =1,					--//发牌中
	CallScore               =2,					--//叫分中
	InGame			        =10,				--//正常游戏中
}




GameConfigData = 
{
    GameId = 0,                         --游戏Id
    RoomId = 0,                         --房间Id
    CreaterInfo = {UserID = 0,UnionGroupID = 0,CreateUnionID = 0,CreateUnionName =""},        --创建者信息
    IsClubRoom = false,                 --是否是俱乐部房间
    CreaterChairId  = 0,                --创建者椅子号
    CreateRoomTime = 0,                 --创建房间的时间
    GamePlayerNum = 3,                  --玩家人数
    CurrPlayerNum=0,                    --当前玩家人数
    GameData = 0,                       --游戏总局数
    IntoGameNum = 0,                    --当前局数
    RoomRule = {DriftingType=0,DrogueType=0,OneDrawType=0,SutWindType=0,FankinDanker=0,FankinSevenSub=0,FankinBloomBar=0,FankinBarRun=0},
    RoomRuleBuff = nil,                 --用户分享使用
    GameRuleInfoStrList,                --游戏规则字符串
    RoomResultData = nil,                           --房间结算
    Table = 
    {
        BankerChairId = 0,                          --地主椅子号
        GameStatus = GameState.STEPNULL,            --游戏状态
        AhandPks = {0,0,0},                         --三张底牌
        CurrOperatChairId = 0,                      --当前操作玩家Id
        CurCallScore = 0,                           --当前所叫分
        BankerCallScore = 0,                        --地主所叫分
        MultipleNum = 0,                            --炸弹倍数
        OperationTime = 0,                          --操作总用时
        OverCallNumTime = 0,                        --叫分倒计时
        OverNotRiseTime = 0,                        --要不起倒计时
        OperationLeftTime = 0,                      --操作剩余倒计时 (重回用)
        LastChuPaiChairId = 0,                      --最后出牌玩家Id
        LastPokeType = POKETYPE.POKE_INVALID,       --最后打出牌类型
        LastChuPaiPks = {},                         --最后出牌
        GameResultData=nil,                         --当前对局结算数据
        Players = 
        { 
            {
                SChairId = -1,
                PlayerInfo = {UserID=0,Imageurl="",UserName="",UserSex=0},
                MapPoint = {IsOpenGPS = false ,X=0,Y=0},                        --GPS定位
                Score = 0,                                                      --玩家分值 当前模式值，当前金币或者积分值
                IsReady = false,                                                --是否准备
                IsOnline = true,                                                --是否在线
                IsTrustFlag = false,                                            --是否托管
                IsAdmitLostFlag = false,                                        --是否认输
                HandPKs = {},                                                   --手牌
            },
            {
                SChairId = -1,
                PlayerInfo = {UserID=0,Imageurl="",UserName="",UserSex=0},
                MapPoint = {IsOpenGPS = false ,X=0,Y=0},                        --GPS定位
                Score = 0,
                IsReady = false,
                IsOnline = true,                                                --是否在线
                IsTrustFlag = false,
                HandPKs = {},                                                   --手牌
            },
            {
                SChairId = -1,
                PlayerInfo = {UserID=0,Imageurl="",UserName="",UserSex=0},
                MapPoint = {IsOpenGPS = false ,X=0,Y=0},                        --GPS定位
                Score = 0,
                IsReady = false,
                IsOnline = true,                                                --是否在线
                IsTrustFlag = false,
                HandPKs = {},                                                   --手牌
            }
        }
    },
}


function GameDataStr(Data)
    local Str = "GameData = \n{RoomId="..tostring(Data.RoomId).."|CreateRoomTime="..tostring(Data.CreateRoomTime).."|CreaterChairId="..tostring(Data.CreaterChairId).."|GamePlayerNum="..tostring(Data.GamePlayerNum).."|CurrPlayerNum="..tostring(Data.CurrPlayerNum).."\n";
        --Table输出
        Str = Str..string.rep(" ",2).."Table = {\n"
        Str = Str..string.rep(" ",4).."GameStatus="..tostring(Data.Table.GameStatus).."|BankerChairId="..tostring(Data.Table.BankerChairId).."|BankerCallScore="..tostring(Data.Table.BankerCallScore).."|MultipleNum="..tostring(Data.Table.MultipleNum).."|OperationTime="..tostring(Data.Table.OperationTime).."|OperationLeftTime="..tostring(Data.Table.OperationLeftTime).."|CurrOperatChairId="..tostring(Data.Table.CurrOperatChairId).."\n"
        Str = Str..string.rep(" ",4).."AhandPks={"..CardValueToStr(Data.Table.AhandPks[1])..","..CardValueToStr(Data.Table.AhandPks[2])..","..CardValueToStr(Data.Table.AhandPks[3]).."}\n"
        Str = Str..string.rep(" ",4).."LastChuPaiChairId = "..Data.Table.LastChuPaiChairId.."|LastPoke="..Data.Table.LastPokeType.."|LastChuPaiPks={"
        for i1,v1 in ipairs(Data.Table.LastChuPaiPks) do
            Str = Str..CardValueToStr(v1)..","
        end
        Str = Str.."}\n"
        --Players输出
        Str = Str..string.rep(" ",4).."Players={\n"
            --玩家信息输出
            for i,v in ipairs(Data.Table.Players) do
                Str = Str..string.rep(" ",6).."{\n"
                Str = Str..string.rep(" ",8).."Playerinfo={SChairId="..v.SChairId.."|UserID="..v.PlayerInfo.UserID.."|IsReady="..tostring(v.IsReady).."|IsOnline="..tostring(v.IsOnline).."|IsTrustFlag="..tostring(v.IsTrustFlag).."|GPS="..tostring(v.MapPoint.IsOpenGPS).."|Score="..tostring(v.Score).."}\n"   
                Str = Str..string.rep(" ",8).."Url = "..tostring(v.PlayerInfo.Imageurl).."\n"
                Str = Str..string.rep(" ",8).."HandPKs={"
                for i1,v1 in ipairs(v.HandPKs) do
                    Str = Str..CardValueToStr(v1)..","
                end
                Str = Str.."}\n"
            end
        Str = Str..string.rep(" ",4).."}\n"
        Str = Str..string.rep(" ",2).."}\n"
        Str = Str.."}"
    return Str
end

function CardValueToStr(CardValue)
    if CardValue then
        local t1,v1 = math.modf(CardValue/16)
        v1 = v1*16
        if v1 < 3 then v1 = v1 + 15 end
        return tostring(v1)
       --return string.format("0x%02x", tonumber(CardValue))
    else
        return tostring(CardValue)
    end
end