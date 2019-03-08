module("ZhengZhouMJ", package.seeall)
GameState =
{
	STEPNULL				=0,					--//未开赛
	STEPVILLAGE				=1,					--//定庄
	STEPDRIFTING            =2,					--//打漂
	STEPDICE                =3,					--//掷骰子
	STEPNOMAROUT			=10,				--//正常出牌阶段
	STEPWAITFORTOP          =11,				--//等待充值状态
	STEPWAITEFOR			=20,				--//延迟等待，等待玩了继续下家
	STEPLISTEN              =21,				--//等待叫听
}
MJHandleType =
{
    Null                    =-1,                --无效操作
	MAHJSTANULL				=0,					--//出牌
	MAHJSTAABAR				=1,					--//明杠(刮风)
	MAHJSTAREPAIRBAR        =2,					--//补杠(刮风)
    MAHJSTADARKBAR          =3,					--//暗杠(下雨)
    Gang                    =4,					--杠(客户端专用  如果被服务占用着者改成一个没有占用的数值就可)
	MAHJSTATOUCH			=10,				--碰
	MAHJSTAOWNDRAW			=20,				--自摸
	MAHJSTATOUCHWIN         =21,				--点炮
	MAHJDRIFTIN             =22,				--下跑
	MAHJZHUANGADD           =23,				--庄家加底
	MAHJSTAWINDRAIN			=31,				--退换暗杠补杠钱，即下雨钱
	MAHJSTAWINMDRAIN        =32,				--退换明杠钱，即刮风钱
	MAHJSTARDEFEAT			=35,				--认输了
	MAHJSTARLISTEN			=40				    --听
}
HuType =
{
	HUPAIFLAT						=1,		--//平胡
	HUPAISEVENSUB					=4,		--//七对
	EXTENHUPAIGANGHU				=54,	--//杠上开花
	EXTENHUPAIGANGPAO               =55,	--//杠上炮
    HUPAIGANGPAO					=60,	--//杠跑
    MAHJZHUANGADD                   =61,	--//庄家加底
    HUANGZHUANGHGANG                =62,	--//荒庄荒杠
    RUNPAOFEN                       =63 	--//跑分
}
MJHandleStr =
{
    [MJHandleType.Null]     ="",                
    [MJHandleType.MAHJSTANULL]     ="出牌",               
    [MJHandleType.MAHJSTAABAR]     ="明杠",       
    [MJHandleType.MAHJSTAREPAIRBAR]     ="补杠",  
    [MJHandleType.MAHJSTADARKBAR]     ="暗杠",
    [MJHandleType.MAHJSTATOUCH]     ="碰",
    [MJHandleType.MAHJSTAOWNDRAW]     ="自摸",
    [MJHandleType.MAHJSTATOUCHWIN]     ="点炮",
	[MJHandleType.MAHJDRIFTIN]     ="下跑",
	[MJHandleType.MAHJZHUANGADD]     ="庄家加底",
	[MJHandleType.MAHJSTAWINDRAIN]     ="退税",
	[MJHandleType.MAHJSTAWINMDRAIN]     ="退税",
	[MJHandleType.MAHJSTARDEFEAT]     ="认输了",
	[MJHandleType.MAHJSTARLISTEN]     ="听"
}
HuTypeStr =
{
    [HuType.HUPAIFLAT]	="平胡",		
    [HuType.HUPAISEVENSUB]	="七对",		
    [HuType.EXTENHUPAIGANGHU]	="杠上开花",		
    [HuType.EXTENHUPAIGANGPAO]	="杠上炮",		
    [HuType.HUPAIGANGPAO]	="杠跑"	,
    [HuType.MAHJZHUANGADD]	="庄家加底"	,
    [HuType.HUANGZHUANGHGANG]	="荒庄荒杠"	,
    [HuType.RUNPAOFEN]	="跑分"	
}


GameConfigData = 
{
    GameId = 0,                         --游戏Id
    RoomId = 0,                         --房间Id
    CreaterInfo = {UserID = 0,UnionGroupID = 0,CreateUnionID = 0,CreateUnionName =""},        --创建者信息
    IsClubRoom = false,                 --是否是俱乐部房间
    CreaterChairId  = 0,                --创建者椅子号
    CreateRoomTime = 0,                 --创建房间的时间
    GamePlayerNum = 4,                  --玩家人数
    CurrPlayerNum=0,                    --当前玩家人数
    GameData = 0,                       --游戏总局数
    IntoGameNum = 0,                    --当前局数
    RoomRule = {DriftingType=0,DrogueType=0,OneDrawType=0,SutWindType=0,FankinDanker=0,FankinSevenSub=0,FankinBloomBar=0,FankinBarRun=0},
    RoomRuleBuff = nil,                 --用户分享使用
    GameRuleInfoStrList,                --游戏规则字符串
    RoomResultData = nil,                           --房间结算
    Table = 
    {
        BankerChairId = 0,                          --庄家椅子号
        CurRunChairId = 0,                          --当前轮流的玩家ID
        FirstDices={0,0},                           --第一次色子
        SecondDices={0,0},                          --第二次色子
        RemakeID = 0,                               --翻赖子的牌
        LaiZis = {0,0},                             --赖子(最多两个)
        GameStatus = GameState.STEPNULL,            --游戏状态
        DaPiaoTime = 0,                             --打票总用时
        OperationTime = 0,                          --操作总用时
        OperationLeftTime = 0,                      --操作剩余倒计时 (重回用)
        DeskMJFaceIndx = 0,                         --桌子上剩余麻将的前面下标
        DeskMJBackIndx = 0,                         --桌子上剩余麻将的后面下标
        LastChuPaiChairId = 0,                      --最后出牌玩家Id
        LastChuPaiMJ = 0,                           --最后出牌麻将
        HavePlayerTing = false,                     --已经有用户听了
        GameResultData=nil,                         --当前对局结算数据
        Players = 
        { 
            {
                SChairId = -1,
                PlayerInfo = {UserID=0,Imageurl="",UserName="",UserSex=0},
                MapPoint = {IsOpenGPS = false ,X=0,Y=0},                                           --GPS定位
                Score = 0,                                                      --玩家分值 当前模式值，当前金币或者积分值
                DeskPierNum = 0,                                                --自己面前的牌墩数
                IsReady = false,                                                --是否准备
                IsOnline = true,                                                --是否在线
                IsTrustFlag = false,                                            --是否托管
                IsTing = false,                                                 --听牌标记
                IsAdmitLostFlag = false,                                        --是否认输
                DaPiaoNum = -1,                                                 --打票值
                MoPaiMJ  = nil,                                                 --手上摸得麻將                              
                HandMJ = {},
                OutMJ = {},
                HandleMJ = {},          --{{Type=MJHandleType.Null,SourceChairId = 0,MJs={}}}           操作牌信息
                Operations = {},        --{(Type = MJHandleType.MAHJSTATOUCH ,Operats={{Type,MJ}}}      自己的操作選項數據
                FlowingData = {},       --{{ProdChairId,Type,Multiple,Integral,HuType}}                自己的流水数据
                CanHuData   =  {},      --{{MJ,HuMJs={MJ,LeftNum,Multiple}}} 
                TingData={},            --{{MJ,LeftNum,Multiple}}                                       用户听牌数据
            },
            {
                SChairId = -1,
                PlayerInfo = {UserID=0,Imageurl="",UserName="",UserSex=0},
                MapPoint = {IsOpenGPS = false ,X=0,Y=0},                                           --GPS定位
                Score = 0,
                DeskPierNum = 0,                                                --自己面前的牌墩数
                IsReady = false,
                IsOnline = true,                                                --是否在线
                IsTrustFlag = false,
                IsTing = false,                                                 --听牌标记
                IsAdmitLostFlag = false,            
                DaPiaoNum = -1,
                MoPaiMJ  = nil,                                                 --手上摸得麻將         
                HandMJ = {},
                OutMJ = {},
                HandleMJ = {},
                Operations = {}        --{(Type = MJHandleType.MAHJSTATOUCH ,Operats={{Type,MJ}}}      自己的操作選項數據
            },
            {
                SChairId = -1,
                PlayerInfo = {UserID=0,Imageurl="",UserName="",UserSex=0},
                MapPoint = {IsOpenGPS = false ,X=0,Y=0},                                           --GPS定位
                Score = 0,
                DeskPierNum = 0,                                                --自己面前的牌墩数
                IsReady = false,
                IsOnline = true,                                                --是否在线
                IsTrustFlag = false,
                IsTing = false,                                                 --听牌标记
                IsAdmitLostFlag = false,
                DaPiaoNum = -1,
                MoPaiMJ  = nil,                                                 --手上摸得麻將         
                HandMJ = {},
                OutMJ = {},
                HandleMJ = {},
                Operations = {}        --{(Type = MJHandleType.MAHJSTATOUCH ,Operats={{Type,MJ}}}      自己的操作選項數據
            },
            {
                SChairId = -1,
                PlayerInfo = {UserID=0,Imageurl="",UserName="",UserSex=0},
                MapPoint = {IsOpenGPS = false ,X=0,Y=0},                                           --GPS定位
                Score = 0,
                DeskPierNum = 0,                                                --自己面前的牌墩数
                IsReady = false,
                IsOnline = true,                                                --是否在线
                IsTrustFlag = false,
                IsTing = false,                                                 --听牌标记
                IsAdmitLostFlag = false,
                DaPiaoNum = -1,
                MoPaiMJ  = nil,                                                 --手上摸得麻將         
                HandMJ = {},
                OutMJ = {},
                HandleMJ = {},
                Operations = {}        --{(Type = MJHandleType.MAHJSTATOUCH ,Operats={{Type,MJ}}}      自己的操作選項數據
            }
        }
    },
}


function GameDataStr(Data)
    local Str = "GameData = \n{RoomId="..tostring(Data.RoomId).."|CreateRoomTime="..tostring(Data.CreateRoomTime).."|GamePlayerNum="..tostring(Data.GamePlayerNum).."\n";
        --Table输出
        Str = Str..string.rep(" ",2).."Table = {\n"
            Str = Str..string.rep(" ",4).."GameStatus="..Data.Table.GameStatus.."|BankerChairId="..Data.Table.BankerChairId.."|DaPiaoTime="..Data.Table.DaPiaoTime.."|OperationTime="..Data.Table.OperationTime.."|DeskMJFaceIndx="..Data.Table.DeskMJFaceIndx.."|DeskMJBackIndx="..Data.Table.DeskMJBackIndx.."|LastChuPaiChairId="..Data.Table.LastChuPaiChairId.."\n"
            Str = Str..string.rep(" ",4).."FirstDices={"..Data.Table.FirstDices[1]..","..Data.Table.FirstDices[2].."}|".."SecondDices={"..Data.Table.SecondDices[1]..","..Data.Table.SecondDices[2].."}\n"
            Str = Str..string.rep(" ",4).."RemakeID={"..MJCardValueToStr(Data.Table.RemakeID).."|LaiZis={"..MJCardValueToStr(Data.Table.LaiZis[1])..","..MJCardValueToStr(Data.Table.LaiZis[2]).."}\n"
            --Players输出
            Str = Str..string.rep(" ",4).."Players = {\n"
                --玩家信息输出
                for i,v in ipairs(Data.Table.Players) do
                    Str = Str..string.rep(" ",6).." {\n"
                    Str = Str..string.rep(" ",8).."Playerinfo={SChairId="..v.SChairId.."|UserID="..v.PlayerInfo.UserID.."|IsReady="..tostring(v.IsReady).."|IsOnline="..tostring(v.IsOnline).."|IsTrustFlag="..tostring(v.IsTrustFlag).."|IsTing="..tostring(v.IsTing).."|GPS="..tostring(v.MapPoint.IsOpenGPS).."|DaPiaoNum="..tostring(v.DaPiaoNum).."|DeskPierNum="..tostring(v.DeskPierNum).."|Score="..tostring(v.Score).."}\n"   
                    
                    Str = Str..string.rep(" ",8).."Url = "..tostring(v.PlayerInfo.Imageurl).."\n"
                    --玩家摸得牌
                    Str = Str..string.rep(" ",8).."MoPaiMJ = "..MJCardValueToStr(v.MoPaiMJ).."\n"

                    --玩家手牌
                    Str = Str..string.rep(" ",8).."HandMJ={"
                    for i1,v1 in ipairs(v.HandMJ) do
                        Str = Str..MJCardValueToStr(v1)..","
                    end
                    Str = Str.."}\n"
                    --玩家打出牌
                    Str = Str..string.rep(" ",8).."OutMJ={"
                    for i1,v1 in ipairs(v.OutMJ) do
                        Str = Str..MJCardValueToStr(v1)..","
                    end
                    Str = Str.."}\n"
                    --玩家操作牌
                    Str = Str..string.rep(" ",8).."HandleMJ={"
                    for i1,v1 in ipairs(v.HandleMJ) do
                        Str = Str.."{ Type = "..tostring(v1.Type).."|SourceChairId = "..tostring(v1.SourceChairId).."|MJs = {"
                        for i2,v2 in ipairs(v1.MJs) do
                            Str = Str..MJCardValueToStr(v2)..","
                        end
                        Str = Str.."}}"
                    end
                    Str = Str.."}\n"
                    Str = Str..string.rep(" ",8).."Operations={"
                    for i1,v1 in ipairs(v.Operations) do
                        Str = Str.."{Type = ".. tostring(v1.Type).."|Operats={"
                        for i2,v2 in ipairs(v1.Operats) do
                            Str = Str.."{Type = ".. tostring(v2.Type).."|MJ=".. MJCardValueToStr(v2.MJ).."},"
                        end
                        Str = Str.."}}"
                    end
                    Str = Str..string.rep(" ",8).."}\n"
                    if i == 1 then
                        Str = Str..string.rep(" ",8).."FlowingData = "..tostring(#v.FlowingData).."|CanHuData = "..tostring(#v.CanHuData).."|TingData = "..tostring(#v.TingData).."\n" 
                        Str = Str..string.rep(" ",8).."CanHuData={"
                        for i1,v1 in ipairs(v.CanHuData) do
                            Str = Str.."{OutMJ = ".. MJCardValueToStr(v1.OutMJ).."|HuMJs={"
                            if v1.HuMJs then
                                for i2,v2 in ipairs(v1.HuMJs) do
                                    Str = Str.."{MJ = ".. MJCardValueToStr(v2.MJ).."|Multiple="..tostring(v2.Multiple).."|LeftNum="..tostring(v2.LeftNum).."},"
                                end
                            end
                            Str = Str.."},"
                        end
                        Str = Str.."}\n"
                        Str = Str..string.rep(" ",8).."TingData={"
                        for i2,v2 in ipairs(v.TingData) do
                            Str = Str.."{MJ = ".. MJCardValueToStr(v2.MJ).."|Multiple="..tostring(v2.Multiple).."|LeftNum="..tostring(v2.LeftNum).."},"
                        end
                        Str = Str.."}\n"
                    end
                end
            Str = Str..string.rep(" ",4).."}\n"
        Str = Str..string.rep(" ",2).."}\n"
    Str = Str.."}"
    return Str
end

function MJCardValueToStr(CardValue)
    if CardValue then
        return string.format( "0x%02x", tonumber(CardValue))
    else
        return tostring(CardValue)
    end
end