require "DouWan/ZhengZhouMJ/Logic/ZhengZhouMJTools"
require "DouWan/ZhengZhouMJ/Logic/ZhengZhouMJDataConfig"
require "DouWan/ZhengZhouMJ/Logic/ZhengZhouMJData"
require "DouWan/ZhengZhouMJ/ZhengZhouMJProtocal"
require "Message/NetProtocolBase"

module("ZhengZhouMJ", package.seeall)

local RoomBaseuserMsg = nil                         --缓存房间内玩家信息 此消息必须要等待收到房间详情消息后才能处理 因为游戏人数的数据必须最先确定
local RoomdetailMsg = nil                           --两条重回数据必须都有才能恢复游戏数据
local IsStartCompleted = false                      --初始化完成
local RespondGameDataCallBack = nil                 --游戏详情数据请求到之后的回调 用于再来一局的自动准备处理
local CurrGameParams = nil                          --游戏启动参数
local IsOnHuanXing = false                          --是否在唤醒游戏中

function Initialize(gameParams)
    ModelLog("初始化逻辑控制脚本",TableToStr(gameParams));
    CurrGameParams = gameParams
    RoomBaseuserMsg = nil
    RoomdetailMsg = nil
    IsStartCompleted = false
    IsOnHuanXing = false
    GameDataInit(CurrGameParams.RoomID,CurrGameParams:GetGameID())
    GameAutoRequire("DouWan/ZhengZhouMJ/CardGame/Message/ZZMJMessage")
    GameAutoRequire("DouWan/ZhengZhouMJ/CardGame/Config/baseconfig")
    ListenerAppIsBack()                                                                        --监听游戏切后台事件
    RegisterErrorCodeHandler()
end

function UnInitialize()
    RoomBaseuserMsg = nil
    RoomdetailMsg = nil
    IsStartCompleted = false
    IsOnHuanXing = false
    GameDataInit(0,0)
    RemoveEventListener()
    Game.RemoveAppFocusEvent("ZhengZhouMJFocusEvent")                                           --移除后台事件
    RemoveErrorCodeHandler()
end

function AddEventListener()
    ModelLog("监听游戏消息事件");
    
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_QUERY_USER_ROOMID_RESULT, RespondIsKeepRomm)     --是否还在房间中
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLB_COMM_REPORT_USER_CUR_ROOMID, NoticeRoomInfo)
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_QUERY_ROOM_DETAIL_RESULT, RespondPlayerInfo)
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_QUERY_ROOM_EXTEN_RESULT, RespondRoomInfo)
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_USER_ADD, PlayerIntoRoom)
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_USER_LEAVE, PlayerLeaveRoom)
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_USER_STATUS, PlayerStateShange)
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_ITEM_CHANGE, PlayerScoreChange)      --玩家货币改变
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_USER_ITEM, PlayerRealScoreChange)     --玩家真实货币改变
    NetProtocolBase.RegistNetEvent(MessageType.FLG_HOUSE_REPORT_USER_ONLINE_FLAG, PlayerIsOnline)              --通告玩家在线状态
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_BASE, GameStateChange)
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_FRIFTING, PlayerDaPiao)              --玩家打票
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_DETAIL, FaPai)                       --发牌
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_MAHJONGID, MoPai)                    --摸牌
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_QUERY_CHANGE_MAHJONG_HUID_RESULT, QueryHu)       --查胡结果
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_QUERY_OUT_MAHJONG_HUPAI_RESULT, QueryDetailedHu)  --查胡详情结果
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_POP_PRODLG, ShowOperatGroup)         --玩家操作下发
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_ACTION, PlayAction)                  --玩家行为
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_LISTEN, PlayTing)                    --通告玩家听状态
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_FLOWING, GameFlowing)                --通告游戏流水
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_HOUSE_REPORT_FIGHT_RESULT, GameResult)                --游戏结算
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLG_HOUSE_REPORT_ALL_FIGHT_RESULT, RoomResult)             --房间结算
    NetProtocolBase.RegistNetEvent(ZhengZhouMJMsgType.FLB_COMM_OUT_FIGHT_RESULT, RespondExitRoom)               --推出房間成功
end


function RemoveEventListener()
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_QUERY_USER_ROOMID_RESULT, RespondIsKeepRomm)     --是否还在房间中
    Event.RemoveListener(ZhengZhouMJMsgType.FLB_COMM_REPORT_USER_CUR_ROOMID, NoticeRoomInfo)
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_QUERY_ROOM_DETAIL_RESULT, RespondPlayerInfo)
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_QUERY_ROOM_EXTEN_RESULT, RespondRoomInfo)
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_USER_ADD, PlayerIntoRoom)
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_USER_LEAVE, PlayerLeaveRoom)
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_USER_STATUS, PlayerStateShange)
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_ITEM_CHANGE, PlayerScoreChange)      --玩家货币改变
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_USER_ITEM, PlayerRealScoreChange)    --玩家真实货币改变
    Event.RemoveListener(MessageType.FLG_HOUSE_REPORT_USER_ONLINE_FLAG, PlayerIsOnline)               --通告玩家在线状态
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_BASE, GameStateChange)
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_FRIFTING, PlayerDaPiao)
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_DETAIL, FaPai)
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_MAHJONGID, MoPai)                    --摸牌
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_QUERY_CHANGE_MAHJONG_HUID_RESULT, QueryHu)       --查胡结果
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_QUERY_OUT_MAHJONG_HUPAI_RESULT, QueryDetailedHu)       --查胡详情结果
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_POP_PRODLG, ShowOperatGroup)           --玩家操作下发
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_LISTEN, PlayTing)                    --通告玩家听状态
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_USER_ACTION, PlayAction) 
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_COMM_REPORT_ROOM_FLOWING, GameFlowing)                  --通告游戏流水
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_HOUSE_REPORT_FIGHT_RESULT, GameResult)                  --游戏结算
    Event.RemoveListener(ZhengZhouMJMsgType.FLG_HOUSE_REPORT_ALL_FIGHT_RESULT, RoomResult)             --房间结算
    Event.RemoveListener(ZhengZhouMJMsgType.FLB_COMM_OUT_FIGHT_RESULT, RespondExitRoom)        --推出房間成功
end

--错误码处理注册
function RegisterErrorCodeHandler()
	ErrorCodeHandler.RegisterCodeHandler(10091, function (cmd)
        TipsView.ShowOk("您的金币不足,请到大厅充值再继续游戏！", function ()
            CtrlManager.CloseGame(CtrlNames.ZhengZhouMJMain)
        end,true)
    end);
    ErrorCodeHandler.RegisterCodeHandler(10093, function (cmd)
        TipsView.ShowOk("您的金币不足,请到大厅充值再继续游戏！", function ()
            CtrlManager.CloseGame(CtrlNames.ZhengZhouMJMain)
        end,true)
    end);
    ErrorCodeHandler.RegisterCodeHandler(10092, function (cmd)
        TipsView.ShowOk("房间已满，请返回大厅重新选择！", function ()
            CtrlManager.CloseGame(CtrlNames.ZhengZhouMJMain)
        end,true)
	end);
end

--移除错误码事件
function RemoveErrorCodeHandler()
    ErrorCodeHandler.RemoveCodeHandler(10091)
    ErrorCodeHandler.RemoveCodeHandler(10093)
    ErrorCodeHandler.RemoveCodeHandler(10092)
end

--检测是否后台运行
function ListenerAppIsBack()
    Game.RegistAppFocusEvent("ZhengZhouMJFocusEvent", function (isFocus)
        if isFocus then     --从后台切回来
            ModelLog("唤醒游戏",nil);
            RoomBaseuserMsg = nil
            RoomdetailMsg = nil
            IsStartCompleted = false
            ZhengZhouMJ.AddEventListener()
            if not IsOnHuanXing then
                RequestIsKeepRoom()
            end
        else
            ModelLog("休眠游戏",nil);
            IsStartCompleted = false
            IsOnHuanXing = false
            RemoveEventListener()
        end
    end)
end

--微信邀请好友
function WXInvate()
    local Data = GetGameData()
    local title = "推倒胡," .. "房间号：" .. Data.RoomId .. "," .. Data.GamePlayerNum .."人"
    local content = Data.GameRuleInfoStrList[1] .. "、" .. Data.GameRuleInfoStrList[2] .. "、" .. Data.GameRuleInfoStrList[3]
    local params = {
        gameName = "推倒胡", 
        gameTitle = "房间号",
        ruleInfo = content,
        roomid = Data.RoomId
    }
    ShareHelper.ShareToFriend(params, title, content)
    -- local Data = GetGameData()
    -- -- 联盟数据判断
    -- local unionData = nil
    -- if Data.CreaterInfo.CreateUnionID ~= 0 then
    --     unionData = {
    --         unionID = Data.CreaterInfo.CreateUnionID,
    --         unionName = Data.CreaterInfo.CreateUnionName,
    --     }
    -- end
    -- -- 分享信息
    -- local shareInfo = Game.GenShareInfo(Data.GameId,
    --     Data.RoomId,
    --     CurrGameParams.FromType,
    --     Data.RoomRuleBuff,
    --     unionData)
    -- Game.InvestFriends(false, Data.RoomId, Data.GameId, CurrGameParams.ServerID, shareInfo)
end

----------------------------------------发包--------------------------------------------------------------
--请求退出房间
function SendExitRoom()
    Network.SendUserEmptyMsg(ZhengZhouMJMsgType.FLB_COMM_OUT_FIGHT, nil)
end

--客户端进入房间请求房间内数据
function JoinRoomRequest(callback)
    RespondGameDataCallBack = callback
    RequestRoominfo();
    RequestPlayerInfo();
end

--请求是否在房间中
function RequestIsKeepRoom()
    ModelLog("请求是否在房间中",nil);
    Network.SendUserEmptyMsg(ZhengZhouMJMsgType.FLG_COMM_QUERY_USER_ROOMID, nil)
    IsOnHuanXing = true
end

--请求房间内用户信息
function RequestPlayerInfo()
    ModelLog("请求房间内用户信息",nil);
    Network.SendUserEmptyMsg(ZhengZhouMJMsgType.FLG_COMM_QUERY_ROOM_DETAIL, nil)
end

function RequestRoominfo()
    ModelLog("请求房间内详细信息",nil);
    Network.SendUserEmptyMsg(ZhengZhouMJMsgType.FLG_COMM_QUERY_ROOM_EXTEN, nil)
end

--发送准备状态 1准备 0取消准备
function SendReadyState(state)
    ModelLog("请求玩家准备",state);
    Network.SendUCharMsg(ZhengZhouMJMsgType.FLB_COMM_SET_FIGHT_READY, tostring(state))
end

--发送玩家托管
function SendIsTrustFlag(state)
    ModelLog("请求玩家托管",state);
    Network.SendUCharMsg(ZhengZhouMJMsgType.FLG_COMM_BRAND_TRUSTEESHIP, tostring(state))
end

--请求能胡的牌
function SendCanHuQuery()
    ModelLog("请求听牌信息");
    Network.SendUserEmptyMsg(ZhengZhouMJMsgType.FLG_COMM_QUERY_CHANGE_MAHJONG_HUID, nil)
end

--请求详细胡牌信息
function SendCanHuDetailedQuery(SCardValue)
    ModelLog("请求胡牌信息");
    Network.SendUCharMsg(ZhengZhouMJMsgType.FLG_COMM_QUERY_OUT_MAHJONG_HUPAI, tostring(SCardValue))
end

--发送打票
function SendDaPiao(DaPiaoNum)
    ModelLog("请求玩家打票",DaPiaoNum);
    Network.SendUCharMsg(ZhengZhouMJMsgType.FLG_COMM_SET_DRIFTING, tostring(DaPiaoNum))
end

--出牌
function SendChuPai(SCardValue)
    ModelLog("请求玩家出牌",SCardValue);
    Network.SendUCharMsg(ZhengZhouMJMsgType.FLG_COMM_OUT_BRAND, tostring(SCardValue))
end

--发送玩家操作
function SendPlayerOperat(IsSelfOperat,OperatType,SCardValue)
    ModelLog("请求操作",{IsSelfOperat,OperatType,SCardValue});
    if IsSelfOperat then
        Network.SendUCharMsg(ZhengZhouMJMsgType.FLG_COMM_SELF_HAND_MAJHONG_PRO, ({OperatType,SCardValue}),nil,true)
    else
        Network.SendUCharMsg(ZhengZhouMJMsgType.FLG_COMM_OTHER_OUT_MAJHONG_PRO, (OperatType))
    end
end

--玩家发送报听1报听，0不报听
function SendPlayerTing(data)
    ModelLog("请求报听",data);
    Network.SendUCharMsg(ZhengZhouMJMsgType.FLG_COMM_LISTEN_MAJHONG, tostring(data))
end

--再来一局请求
function SendGameComeAgain()
    ModelLog("请求再来一局",nil);
    Network.SendUserEmptyMsg(MessageType.FLG_COMM_CONTINUE_ROOM, nil,nil)
end

---------------------------------------收包----------------------------------------------------------------
--回应成功退出游戏
function RespondExitRoom(buffer)
    ModelLog("收到退出游戏成功",nil);
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):OnCallExitGame()
end

--回应是否在房间中
function RespondIsKeepRomm(buffer)
    local item = ZhengZhouMJ_UserRoomType:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到是否在房间中的回应",item);
    if item.UserRoomID == 0 then   --房间已经不存在了
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):GameComeAgain()
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):BackMainView()
    else    --房间还存在
        GameDataInit(item.UserRoomID,CurrGameParams:GetGameID())
        DebugGameData("房间信息初始化");
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):AppAwakenGame(GetGameData())
        ZhengZhouMJ.JoinRoomRequest()
    end
end

----服务器通告客户端当前的房间信息CommReportCurRoomBase
function  NoticeRoomInfo(buffer)
    local item = ZhengZhouMJ_CommReportCurRoomBase:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到房间信息改变",item);
    if item.Userroombase.UserRoomID == 0 then  --长时间不准备被系统提出房间
        if item.Reason == Report_reason_type.REASONTIMEOUTCLEAR then
            ToastView.Show("房间人员已满，30秒未准备将会被踢出房间", function ()             
            end, 3);
            CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):OnCallExitGame()
        elseif item.Reason == Report_reason_type.REASONUSERCLEAR and not GetGameData().Table.GameResultData then
            CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):OnCallExitGame()
        elseif item.Reason == Report_reason_type.REASONERRANDCLEAR then
            ToastView.Show("异常情况被踢出", function ()             
            end, 3);
            CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):OnCallExitGame()
        elseif item.Reason == Report_reason_type.REASONGOLDNULL then
            ToastView.Show("金币为空被清除房间", function ()             
            end, 3);
            CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):OnCallExitGame()
        elseif item.Reason == Report_reason_type.REASONCREATEDISS then
            ToastView.Show("房间被房主主动解散", function ()             
            end, 3);
            CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):OnCallExitGame()
        elseif item.Reason == Report_reason_type.REASONUNIONGRULEALTER then
            ToastView.Show("规则，战队或联盟信息发送变化", function ()             
            end, 3);
            CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):OnCallExitGame()
        end
    end

    if item.Userroombase.UserRoomID ~= 0 then   --房间信息改变 再来一局了
        RoomBaseuserMsg = nil
        RoomdetailMsg = nil
        GameDataInit(item.Userroombase.UserRoomID,CurrGameParams:GetGameID())
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):GameComeAgain(GetGameData())
         --请求房间信息
        ZhengZhouMJ.JoinRoomRequest(function()
            SendReadyState(1)   --自动准备
        end)          
    end
end

--返回房间内用户信息
function RespondPlayerInfo(buffer)
    if RoomBaseuserMsg then return end      --已经接收过了不在接收
    local item = ZhengZhouMJ_CommQueryDetailRes:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到房间内用户信息",item)
    RoomBaseuserMsg = item;
    --房间房间数据都已到达 可以写入游戏数据恢复场景了
    if RoomdetailMsg then
        SetRoomDataRecovery(RoomdetailMsg,RoomBaseuserMsg);
        DebugGameData("房间信息恢复");
        local GameDate = GetGameData()
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):RestoreGame(GameDate,RoomdetailMsg.Roomdetail.CurAppSettleInfo)
        if IsCanOutMJ() then
            SendCanHuQuery()
        else
            SendCanHuDetailedQuery(0)
        end
        if RespondGameDataCallBack then
            RespondGameDataCallBack()
            RespondGameDataCallBack = nil
        end
        IsStartCompleted = true
        IsOnHuanXing = false
        ModelLog("处理 房间内用户信息 完成",TableToStr(item))
    else
        ModelLog("等待房间用户信息数据到达...")
    end
end

--返回房间内详细信息 (重回)
function RespondRoomInfo(buffer)
    if RoomdetailMsg then return end      --已经接收过了不在接收
    local item = ZhengZhouMJ_CommMajhongTaimianRes:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到房间详细信息",item)
    RoomdetailMsg = item
    --用户和房间数据都已到达 可以写入游戏数据恢复场景了
    if RoomBaseuserMsg then
        SetRoomDataRecovery(RoomdetailMsg,RoomBaseuserMsg);
        DebugGameData("房间信息恢复");
        local GameDate = GetGameData()
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):RestoreGame(GameDate,RoomdetailMsg.Roomdetail.CurAppSettleInfo)
        if IsCanOutMJ() then
            SendCanHuQuery()
        else
            SendCanHuDetailedQuery(0)
        end
        if RespondGameDataCallBack then
            RespondGameDataCallBack()
            RespondGameDataCallBack = nil
        end
        IsStartCompleted = true
        IsOnHuanXing = false
        ModelLog("处理 房间详细信息 完成")
    else
        ModelLog("等待房间用户信息数据到达...")
    end
end

--通告房间内玩家离开
function PlayerLeaveRoom(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local uid = buffer:ReadUInt32()
    local ChairId = SetPlayerLeaveRoom(uid)
    DebugGameData("收到 玩家离开房间 ChairId = "..ChairId)
    if ChairId ~= 0 then
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayerLeave(ChairId,GetGameData())
    end
    ModelLog("处理 玩家离开房间 完成")
end

--玩家货币改变
function PlayerScoreChange(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local bytes = buffer:ReadAllBytes()
    local offset = 0
    local subBuffer = Util.GetSubBuffer(bytes, 0, 2)
    local num = subBuffer:ReadShort()
    offset = offset + 2
    local itemList={}
    for i=1,num do
        local infoItem = ZhengZhouMJ_CommUserItemChange:Create()
        subBuffer = Util.GetSubBuffer(bytes, offset, infoItem.size)
        infoItem:ReadFromBuffer(subBuffer)
        offset = offset + infoItem.size
        itemList[i]=infoItem
    end
    ModelLog("收到玩家货币改变",itemList)
    local ChanageData = SetPlayerScore(itemList)
    DebugGameData("玩家货币改变")
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayerScoreChange(ChanageData,GetGameData())
    ModelLog("处理 玩家货币改变 完成")
end

function PlayerRealScoreChange(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_CommReportRoomUserItem:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到玩家真实货币改变",item)
    SetPlayerRealScore(item)
    DebugGameData("玩家真实货币改变")
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayerScoreNoAnimChange(GetGameData())
    ModelLog("处理 玩家真实货币改变 完成")
end

--玩家在线状态
function PlayerIsOnline(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = CommHouseUserOnline:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到 玩家离线状态改变",item)
    local ChairId =  SetPlayerIsOnline(item)
    DebugGameData("玩家离线状态改变 ChairId = "..ChairId)
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayerIsOnline(ChairId,GetGameData())
    ModelLog("处理 玩家离线状态改变 完成")
end

--------------------------------------------游戏流程逻辑--------------------------------------------------
--通告房间新用户加入 此函数要做异常处理 有可能玩家还未请求到房间信息之前 收到此消息 这个时候房间数据结构不能确定 
function PlayerIntoRoom(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_CommRoomNewUser:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到 新玩家加入",item)
    local ChairId = SetPlayerIntoRoom(item)
    if ChairId ~= 0 then
        DebugGameData("新用户加入 ChairId ="..ChairId);
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayerIntoRoom(ChairId,GetGameData())
    else
        ModelLog("无效玩家加入",item)
    end
    ModelLog("处理 新玩家加入 完成")
end
--准备
function PlayerStateShange(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_CommRoomUserStatus:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("玩家状态改变",item)
    local ChairId = SetPlayerIsReady(item);
    DebugGameData("玩家状态改变 ChairId ="..ChairId);
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayerReady(ChairId,GetGameData())
    ModelLog("处理 玩家状态改变 完成")
end

--游戏状态改变
function GameStateChange(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_CommReportRoomBase:Create()
    item:ReadFromBuffer(buffer)
    if item.Baseroominfo.MahStep == GameState.STEPVILLAGE then  --开始定庄
        SetBanker(item.Baseroominfo)
        DebugGameData("确定庄家")
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):DingZhang(GetGameData());
        ModelLog("处理 确定庄家 完成")
    elseif item.Baseroominfo.MahStep == GameState.STEPDRIFTING then --开始打票
        SetStartDaPiao(item.Baseroominfo)
        DebugGameData("开始打票")
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):StartDaPiao(GetGameData())
        ModelLog("处理 开始打票 完成")
    elseif item.Baseroominfo.MahStep == GameState.STEPNOMAROUT then --开始行牌
        
    end
end

--玩家打票
function PlayerDaPiao(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_CommUserDrifting:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("通告玩家大票",TableToStr(item))
    local ChairId = SetPlayerDaPiao(item)
    DebugGameData("玩家打票 ChairId = "..ChairId)
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayerDaPiao(ChairId,GetGameData())
    ModelLog("处理 玩家打票 完成")
end

--发牌
function FaPai(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_CommReportRoomDetail:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("通告发牌",item)
    SetFaPai(item.Roomdetail)
    DebugGameData("发牌")
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):FaPai(GetGameData())
    ModelLog("处理 发牌 完成")
end

--摸牌
function MoPai(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_CommNewUserMahjongID:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("通告玩家摸牌",item)
    local ChairId,BackFlag = SetPlayerMoPai(item)
    DebugGameData("摸牌 ChairId = "..ChairId)
    local GameData = GetGameData()
    if ChairId == 1 then
        if GameData.Table.Players[1].IsTing then
            SendCanHuDetailedQuery(GameData.Table.Players[1].MoPaiMJ)
        else
            SendCanHuQuery()    --查询胡牌信息
        end
    end
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):MoPai(ChairId,BackFlag,GameData)
    ModelLog("处理 摸牌 完成")
end

function QueryHu(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local CanOutHu = {}
    local bytes = buffer:ReadAllBytes()
    for i=1,14 do
        local subBuffer = Util.GetSubBuffer(bytes, i-1, 1)
        local mj = subBuffer:ReadByte()
        if mj ~= 0 then
            table.insert(CanOutHu, mj)
        end
    end
    ModelLog("查询可胡牌信息",CanOutHu)
    UpdataPlayerCanHuMJData(CanOutHu)
    DebugGameData("查询可听牌结果")
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):ShowCanTingMJ(GetGameData())
end

function QueryDetailedHu(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_CommQueryOutHupaiRes:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("查询可胡详情",item)
    UpdataPlayerCanHuMJDetailedData(item)
    DebugGameData("查询胡牌详情结果")
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):ShowQueryHuView(GetGameData())
end

--显示玩家操作按钮
function ShowOperatGroup(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_UserShowProType:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("下发玩家操作按钮",item)
    SetOperationData(item)
    DebugGameData("显示操作按钮")
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):ShowOperation(GetGameData())
    ModelLog("处理 显示操作按钮 完成")
end

--玩家行为 出牌 吃牌 碰牌 杠牌 
function PlayAction(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_CommUserAction:Create()
    item:ReadFromBuffer(buffer)
    ClearPlayerOperations()                                                        --清除玩家遗留的对话框数据
    ModelLog("通告玩家行为",item)
    if item.MahjongStatus == MJHandleType.MAHJSTANULL then                          --出牌
        local ChairId,MJ = SetPlayerChuPai(item)
        local GameData = GetGameData()
        DebugGameData("出牌 ChairId = "..ChairId)
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayAction(ChairId,item.MahjongStatus,MJ,GameData)
        if ChairId == 1  then
            local IsTingMJ,HuData = IsOutCanHuMJ(MJ)
            if IsTingMJ and not HuData then
                SendCanHuDetailedQuery(0)
            end
        end
    elseif item.MahjongStatus == MJHandleType.MAHJSTATOUCH then                     --碰牌
        local ChairId,MJ = SetPlayerPenPai(item)
        DebugGameData("碰牌 ChairId ="..ChairId)
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayAction(ChairId,item.MahjongStatus,MJ,GetGameData())
        if ChairId == 1 then
            SendCanHuQuery()    --查询胡牌信息
        end
    elseif item.MahjongStatus == MJHandleType.MAHJSTAABAR then                      --明杠
        local ChairId,MJ = SetPlayerMGang(item)
        DebugGameData("明杠 ChairId = "..ChairId)
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayAction(ChairId,item.MahjongStatus,MJ,GetGameData())
    elseif item.MahjongStatus == MJHandleType.MAHJSTAREPAIRBAR then                  --补杠
        local ChairId,MJ = SetPlayerBGang(item)
        DebugGameData("补杠 ChairId = "..ChairId)
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayAction(ChairId,item.MahjongStatus,MJ,GetGameData())
    elseif item.MahjongStatus == MJHandleType.MAHJSTADARKBAR then                    --暗杠
        local ChairId,MJ = SetPlayerAGang(item)
        DebugGameData("暗杠 ChairId = "..ChairId)
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayAction(ChairId,item.MahjongStatus,MJ,GetGameData())
    elseif item.MahjongStatus == MJHandleType.MAHJSTAOWNDRAW then                    --自摸
        local ChairId = UserIDToChairId(item.UserID)
        DebugGameData("自摸 ChairId = "..ChairId)
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayAction(ChairId,item.MahjongStatus,nil,GetGameData())
    elseif item.MahjongStatus == MJHandleType.MAHJSTATOUCHWIN then                    --点炮
        local ChairId = UserIDToChairId(item.UserID)
        DebugGameData("点炮 ChairId = "..ChairId)
        CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayAction(ChairId,item.MahjongStatus,nil,GetGameData())
    end  
    ModelLog("处理 玩家动作完成 End")
end

--通告玩家听状态
function PlayTing(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_CommReportUserListen:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到 玩家听 ",item)
    local ChairId = SetPlayerTing(item)
    DebugGameData("听 ChairId = "..ChairId)
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):PlayAction(ChairId,MJHandleType.MAHJSTARLISTEN,nil,GetGameData())
    ModelLog("处理 听 End")
end

--更新玩家可胡牌信息
function UpDataPlayTingData(buffer)
    -- local item = ZhengZhouMJ_CommReportRoomUser:Create()
    -- item:ReadFromBuffer(buffer)
    -- ModelLog("更新玩家可胡牌数据",item)
    -- UpdataPlayerTingData(item.Roomuserdetail)
    -- ModelLog("处理 更新玩家可胡牌数据 End")
end

--游戏流水
function GameFlowing(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local bytes = buffer:ReadAllBytes()
    local offset = 0
    local subBuffer = Util.GetSubBuffer(bytes, 0, 2)
    local num = subBuffer:ReadShort()
    offset = offset + 2
    local itemList={}
    for i=1,num do
        local infoItem = ZhengZhouMJ_FlowingLogType:Create()
        subBuffer = Util.GetSubBuffer(bytes, offset, infoItem.size)
        infoItem:ReadFromBuffer(subBuffer)
        offset = offset + infoItem.size
        itemList[i]=infoItem
    end
    ModelLog("通告自己的流水 size = "..num,TableToStr(itemList))
    SetFlowingData(itemList)
    DebugGameData("添加玩家流水")
end

--游戏结算
function GameResult(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = ZhengZhouMJ_CommReportFightRes:Create()
    item:ReadFromBuffer(buffer)
    SetGameResult(item)
    ModelLog("通告游戏结算",item)
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):GameResult(GetGameData())
    ModelLog("处理 游戏结算 完成")
end

--继续游戏
function GameContinue()
    SetGameDataContinue()
    DebugGameData("继续游戏")
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):GameContinue(GetGameData())
    ModelLog("处理 继续游戏 完成")
end

--房间结算
function RoomResult(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local itemList = {}
    local bytes = buffer:ReadAllBytes()
    local offset = 0
    for i = 1, 4 do
        local item = ZhengZhouMJ_HouseLoadFinalResult:Create()
        local subBuffer = Util.GetSubBuffer(bytes, offset, item.size)
        item:ReadFromBuffer(subBuffer)
        itemList[#itemList+1]=item
        offset = offset + item.size
    end
    ModelLog("收到房间结算",itemList)
    SetRoomResult(itemList)
    CtrlManager.GetCtrl(CtrlNames.ZhengZhouMJMain):RoomResult(GetGameData())
    ModelLog("处理 房间结算 完成")
end

--再来一局
function GameComeAgain()
    SendGameComeAgain()
end

