-- 基础用户消息定义段
ZhengZhouMJMsgType =
{
    --自己的通讯包，写在0x8100 到0xFFFF之间
	--UCHAR(牌ID)
	FLB_COMM_OUT_FIGHT						= 0x8112,		-- 退出游戏
	FLB_COMM_OUT_FIGHT_RESULT				= 0x8113,		--成功退出
	FLB_COMM_SET_FIGHT_READY            	= 0x8114,       -- 设置准备状态
	FLG_COMM_OUT_BRAND						= 0x8120,		--出牌
	FLG_COMM_OUT_BRAND_RESULT               = 0x8121,		--//出完牌了

	FLG_COMM_SELF_HAND_MAJHONG_PRO          = 0x8122,		--针对自己手上抓的牌进行操作

	FLG_COMM_SELF_HAND_MAJHONG_PRO_RES      = 0x8123,		--操作完成
	FLG_COMM_OTHER_OUT_MAJHONG_PRO          = 0x8124,		--针对其他玩家打下来的牌进行操作
	FLG_COMM_OTHER_OUT_MAJHONG_PRO_RESULT   = 0x8125,		--操作完成
	
	FLG_COMM_LISTEN_MAJHONG					= 0x8130,		--听牌
	FLG_COMM_LISTEN_MAJHONG_RESULT          = 0x8131,		--完成听牌
	FLG_COMM_SET_DRIFTING					= 0x8132,		--打漂
	FLG_COMM_SET_DRIFTING_RESULT			= 0x8133,		--//打漂通报
	FLG_COMM_ADM_DEFEAT						= 0x8140,		--认输
	FLG_COMM_ADM_DEFEAT_RESULT              = 0x8140,		--完成认输

	FLB_COMM_REPORT_USER_CUR_ROOMID			= 0x8200,		--服务器通告客户端当前的房间信息
	FLG_COMM_REPORT_ROOM_BASE               = 0x8201,		--服务器通告当前房间基本信息，开局时用
	FLG_COMM_REPORT_ROOM_USER               = 0x8202,		--服务器通告房间玩家和基本信息，玩家出牌时用
	FLG_COMM_REPORT_ROOM_DETAIL             = 0x8203,		--通告当前房间的所有信息，开启时玩家通告用
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
	
	FLG_COMM_QUERY_CHANGE_MAHJONG_HUID			= 0x8230,				--//查询换那些牌有胡牌
	FLG_COMM_QUERY_CHANGE_MAHJONG_HUID_RESULT	= 0x8231,				--//查询结果
	FLG_COMM_QUERY_OUT_MAHJONG_HUPAI			= 0x8232,				--//查询出一张麻将后的胡牌
	FLG_COMM_QUERY_OUT_MAHJONG_HUPAI_RESULT		= 0x8233,				--//查询结果
    
	FLG_HOUSE_REPORT_FIGHT_RESULT			= 0x8300,		--服务器通告麻将结算信息
	FLG_HOUSE_REPORT_ADV_APP_SETTLEUSER     = 0x8301,		--通告提前结算的玩家ID
	FLG_HOUSE_REPORT_CONTINUEROOM_ERROR     = 0x8302,		--通告新房间已满，请返回大厅
	FLG_HOUSE_REPORT_ALL_FIGHT_RESULT		= 0x8340,		--通告本房卡厂最终结果
	
	FLG_COMM_BRAND_TRUSTEESHIP= 0x8500,								-- 设置托管状态
	FLG_COMM_BRAND_TRUSTEESHIP_RESULT= 0x8501,						-- 托管结果
}

Report_reason_type =
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

	REASONPOKEOVER			=1000,			--出子结束，处理结算
	REASONOUTVERTIME		=1001,						--出子超时，处理结算
	REASONWAITETOPUP		=1002,						--等待充值
	REASONRESUMEGAME		=1003,						--等待充值结束，恢复比赛
	REASONCURNORMAL			=1004,						--当前用户ID变化
	REASONGETNEWMAHJONG		=1005,					--加入新麻将

	REASONBASESETP			=1106,			--房间的状态发生了变化，用户数据无变化，参考Baseroominfo.MahStep

	REASONUSEROUTPOKE		=2001,			--玩家出子并等待其他玩家吃胡或者杠等
	REASONUSEROUTCONTINUE	=2002,					--玩家出子后，继续下家并抓牌
	REASONUSERPENG			=2003,							--玩家碰了
	REASONUSERGANG			=2004,							--玩家吃杠了
	REASONUSERWAITFOR		=2005,						--系统等待时间被更改

	REASONBREADYLISCENS		=3000,			--房间的状态发生了变化，参考Baseroominfo.MahStep

	REASONUSERAPPSETTLE		=4000,			--玩家主动申请退出
	REASONUSERREPLYSETTLE	=4001,					--有玩家回复申请结果
	REASONCLEARREPLYSETTLE	=4002,					--清除申请结果
	REASONREPLYREFUSERENEW	=4003,					--申请被拒绝
	REASONOVERAPPSETTLE		=4004,					--申请通过，本局完了就结束
}

