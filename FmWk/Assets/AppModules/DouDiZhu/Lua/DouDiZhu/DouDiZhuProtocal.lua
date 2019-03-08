-- 基础用户消息定义段
DouDiZhuMsgType =
{
	FLB_COMM_OUT_FIGHT						= 0x8112,		-- 退出游戏
	FLB_COMM_OUT_FIGHT_RESULT				= 0x8113,		--成功退出
	FLB_COMM_SET_FIGHT_READY            	= 0x8114,       -- 设置准备状态

	FLG_COMM_CALL_LANDBORD                  = 0x8120,       --叫地主，0表示不叫
	FLG_COMM_OUT_BRAND                      = 0x8122,       --出牌
	FLG_COMM_OUT_BRAND_PASS                 = 0x8124,       --放弃出牌
	FLG_COMM_ADM_DEFEAT						= 0x8140,		--认输
	FLG_COMM_ADM_DEFEAT_RESULT              = 0x8140,		--完成认输

	FLB_COMM_REPORT_USER_CUR_ROOMID			= 0x8200,		--服务器通告客户端当前的房间信息
	FLG_COMM_REPORT_ROOM_BASE               = 0x8201,		--服务器通告当前房间基本信息，开局时用
	FLG_COMM_REPORT_ROOM_USER               = 0x8202,		--服务器通告房间玩家和基本信息，玩家出牌时用
	FLG_COMM_REPORT_ROOM_DETAIL             = 0x8203,		--通告当前房间的所有信息，发牌玩家通告用
	FLG_COMM_REPORT_ROOM_USER_ADD           = 0x8204,		--通告房间新用户加入
	FLG_COMM_REPORT_ROOM_USER_STATUS        = 0x8205,		--通告用户状态
	FLG_COMM_REPORT_ROOM_USER_LEAVE         = 0x8206,		--通告房间内玩家离开
	FLG_COMM_REPORT_ROOM_USER_ITEM          = 0x8207,		--通告房间内的玩家基础货币
	FLG_COMM_REPORT_ROOM_FLOWING            = 0x8208,		--通告流水

	FLG_COMM_REPORT_USER_POP_PRODLG			= 0x8210,		--通告玩家弹出对话框，进行碰，杠，胡等操作，自摸也弹
	FLG_COMM_REPORT_USER_ITEM_CHANGE        = 0x8211,		--通告玩家货币更改
	FLG_COMM_REPORT_USER_ACTION             = 0x8212,		--通告用户动作
	FLG_COMM_REPORT_USER_MAHJONGID          = 0x8213,		--通告用户获得新麻将
	FLG_COMM_REPORT_USER_LISTEN				= 0x8214,		--通告用户听牌状态
	FLG_COMM_REPORT_USER_FRIFTING			= 0x8215,		--通告玩家大漂

    
	FLG_COMM_QUERY_USER_ROOMID				= 0x8220,		--请求玩家房间ID
	FLG_COMM_QUERY_USER_ROOMID_RESULT       = 0x8221,		--请求结果
	FLG_COMM_QUERY_ROOM_DETAIL              = 0x8222,		--请求房间用户信息
	FLG_COMM_QUERY_ROOM_DETAIL_RESULT       = 0x8223,		--请求结果
	FLG_COMM_QUERY_ROOM_EXTEN               = 0x8224,		--请求房间详细信息
	FLG_COMM_QUERY_ROOM_EXTEN_RESULT        = 0x8225,		--请求结果
	
	FLG_COMM_QUERY_FLOWING                  = 0x8226,		--查询流水
	FLG_COMM_QUERY_FLOWING_RESULT           = 0x8227,		--查询结果
	

	FLG_HOUSE_REPORT_FIGHT_RESULT			= 0x8300,		--服务器通告结算信息
	FLG_HOUSE_REPORT_ADV_APP_SETTLEUSER     = 0x8301,		--通告提前结算的玩家ID
	FLG_HOUSE_REPORT_CONTINUEROOM_ERROR     = 0x8302,		--通告新房间已满，请返回大厅
	FLG_HOUSE_REPORT_ALL_FIGHT_RESULT		= 0x8340,		--通告本房卡厂最终结果
	
	FLG_COMM_BRAND_TRUSTEESHIP= 0x8500,								-- 设置托管状态
	FLG_COMM_BRAND_TRUSTEESHIP_RESULT= 0x8501,						-- 托管结果
}

DouDiZhuMsgReason =
{
	--//针对 FLB_COMM_REPORT_USER_CUR_ROOMID
	REASONSEARCHROOM		=1,				--//正在寻找房间
	REASONUSERCLEAR			=2,				--//玩家被清除房间
	REASONHASINTOROOM		=3,				--//已经进入房间
	REASONERRANDCLEAR		=4,				--//因为错误的数据而清除房间数据
	REASONUSEROUTROOM		=5,				--//主动退出房间

	REASONTIMEOUTCLEAR		=20,			--//90秒不准备被清除房间，20以上直接退出大厅并提示原因
	REASONGOLDNULL			=21,			--//金币为空被清除房间
	REASONCREATEDISS		=22,			--//房间被房主主动解散
	REASONUNIONGRULEALTER	=23,			--//规则，战队或联盟信息发送变化

    --针对 FLG_1_REPORT_ROOM_BASE
    REASONPOKEOVER          = 1000,                   --出牌结束，处理结算
    REASONPOKEGUONEXT       = 1001,                   --不出牌直接过
    REASONCALLLANDNEXT      = 1002,                   --通告有人叫了地主并继续下家    
    REASONNOCALLNEXT        = 1003,                   --通告当前玩家不叫地主继续下家
	REASONBASESETP			= 1100,					  --//房间的状态发生了变化，用户数据无变化，参考Baseroominfo.MahStep
    --针对 FLG_1_REPORT_ROOM_USER
    REASONSETLANDBORD       = 2000,                   --成功设置为地主
	REASONUSEROUTPOKE       = 2001,					  --//玩家出牌可要的起
	REASONUSEROUTNOTRISE    = 2002,					  --//玩家出牌要不起

    --针对 FLG_1_REPORT_ROOM_DETAIL
    REASONBREADYLISCENS     = 3000,                   --都准备好了，开始发牌了

    --针对 FLG_20000_REPORT_ADV_APP_SETTLEUSER
    REASONUSERAPPSETTLE     = 4000,                   --玩家主动申请退出
    REASONUSERREPLYSETTLE   = 4001,                   --有玩家回复申请结果
    REASONCLEARREPLYSETTLE  = 4002,                   --清除申请结果，可以重来
    REASONREPLYREFUSERENEW  = 4003,                   --申请最终未通过，其他玩家可以重新申请
}

--斗地主动态资源列表 restype 1 GameObject 2 Sprite
DouDiZhuPKResConf =
{
	{name = "PK",restype = 1},
	{name = "pk_16",restype = 2},
	{name = "pk_17",restype = 2},
	{name = "pkvalue_16",restype = 2},
	{name = "pkvalue_17",restype = 2},
	{name = "pic_dizhu",restype = 2},
	{name = "bigtag_0",restype = 2},
	{name = "bigtag_1",restype = 2},
	{name = "bigtag_2",restype = 2},
	{name = "bigtag_3",restype = 2},
	{name = "puke_01",restype = 2},
	{name = "puke_02",restype = 2},
	{name = "puke_03",restype = 2},
	{name = "puke_04",restype = 2},
	{name = "black_3",restype = 2},
	{name = "black_4",restype = 2},
	{name = "black_5",restype = 2},
	{name = "black_6",restype = 2},
	{name = "black_7",restype = 2},
	{name = "black_8",restype = 2},
	{name = "black_9",restype = 2},
	{name = "black_10",restype = 2},
	{name = "black_11",restype = 2},
	{name = "black_12",restype = 2},
	{name = "black_13",restype = 2},
	{name = "black_14",restype = 2},
	{name = "black_15",restype = 2},
	{name = "red_3",restype = 2},
	{name = "red_4",restype = 2},
	{name = "red_5",restype = 2},
	{name = "red_6",restype = 2},
	{name = "red_7",restype = 2},
	{name = "red_8",restype = 2},
	{name = "red_9",restype = 2},
	{name = "red_10",restype = 2},
	{name = "red_11",restype = 2},
	{name = "red_12",restype = 2},
	{name = "red_13",restype = 2},
	{name = "red_14",restype = 2},
	{name = "red_15",restype = 2},
}

POKEHuaSe = 
{   
    CLUBS               =1,                 --梅花
    DIAMONDS            =2,                 --方块
    HEARTS              =3,                 --红星
	SPADES              =4,                 --黑桃
	King				=5,					--王
};


POKEVALUE =
{
    VALUE_LW            =1,                 --小王
    VALUE_BW            =2,                 --大王
    VALUE_3             =3,                 --3
    VALUE_4             =4,                 --4
    VALUE_5             =5,                 --5
    VALUE_6             =6,                 --6
    VALUE_7             =7,                 --7
    VALUE_8             =8,                 --8
    VALUE_9             =9,                 --9
    VALUE_10            =10,                --10
    VALUE_J             =11,                --J
    VALUE_Q             =12,                --Q
    VALUE_K             =13,                --K
    VALUE_A             =14,                --A
    VALUE_2             =15,                --2
};

POKETYPE =
{
	POKE_INVALID       	=0,                        --不合法的牌组
	POKE_ROCKET			=1,					--//火箭,大小王,大小王先后不管
	POKE_BOMB           =2,					--//炸弹,四张同数值牌（如四个 7 ）
	POKE_SINGLECARD     =3,					--//单牌,单个牌（如红桃 5 ）
	POKE_SUB            =4,					--//对子,数值相同的两张牌（如梅花 4+ 方块 4 ）
	POKE_THREECARDS     =5,					--//三张牌,数值相同的三张牌（如三个 J ）
	POKE_THREEBELTONE   =6,					--//三带一，先三个再一个,数值相同的三张牌 + 一张单牌或一对牌。例如： 333+6
	POKE_THREEBELTSUB   =7,					--//三带一对，先三个再一对,数值相同的三张牌 + 一张单牌或一对牌。例如： 444+99 
	POKE_SHUNZI         =8,					--//顺子，最少5个，从小到大,五张或更多的连续单牌（如： 45678 或 78910JQK ）。不包括 2 点和双王。
	POKE_SUBSHUNZI      =9,					--//双顺，最少3个，从小到大,三对或更多的连续对牌（如： 334455 、 7788991010JJ ）。不包括 2 点和双王。 
	POKE_THREESHUNZI    =10,				--//三顺，最少2个，从小到大,二个或更多的连续三张牌（如： 333444 、 555666777888 ）。不包括 2 点和双王。 
	POKE_PLANEADDSIN    =11,				--//N飞机带翅膀+N个单牌,三顺＋同数量的单牌，三顺从小到大，单牌不管（如444555+79,444555666+789,444555666777+89JQ）
	POKE_PLANEADDSUM    =12,				--//N飞机带翅膀+N个对牌,三顺＋同数量的对牌，三顺从小到大，对子不管（如444555+66+77,如444555666+77+88+99,444555666777+88+99+JJ+QQ）
	POKE_BOMBADDSIN     =13,				--//4带2张单牌,一个炸弹+2个单牌，（如4444+89），但不是炸弹
	POKE_BOMBADDSUM     =14,				--//4带2个对牌,一个炸弹+2个对牌，（如4444+8899），但不是炸弹
}
