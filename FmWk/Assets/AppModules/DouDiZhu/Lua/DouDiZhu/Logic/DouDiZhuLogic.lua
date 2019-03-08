require "DouWan/DouDiZhu/DouDiZhuProtocal"
require "DouWan/DouDiZhu/Logic/DouDiZhuTools"
print("导入新的牌型分析脚本 Logic 1")
require "DouWan/DouDiZhu/Logic/DouDiZhuDataConfig"
print("导入新的牌型分析脚本 Logic 2")
require "DouWan/DouDiZhu/Logic/DouDiZhuData"
print("导入新的牌型分析脚本 Logic 3")
require "Message/NetProtocolBase"
module("DouDiZhu", package.seeall)

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
    GameAutoRequire("DouWan/DouDiZhu/CardGame/Message/DDZMessage")
    GameAutoRequire("DouWan/DouDiZhu/CardGame/Config/baseconfig")
    --ListenerAppIsBack()                                                                        --监听游戏切后台事件
    RegisterErrorCodeHandler()
end

function UnInitialize()
    RoomBaseuserMsg = nil
    RoomdetailMsg = nil
    IsStartCompleted = false
    IsOnHuanXing = false
    GameDataInit(0,0)
    RemoveEventListener()
    Game.RemoveAppFocusEvent("DouDiZhuFocusEvent")                                           --移除后台事件
    RemoveErrorCodeHandler()
end

function AddEventListener()
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_COMM_QUERY_USER_ROOMID_RESULT, RespondIsKeepRomm)     --是否还在房间中
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLB_COMM_REPORT_USER_CUR_ROOMID, NoticeRoomInfo)
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_COMM_QUERY_ROOM_DETAIL_RESULT, RespondPlayerInfo)
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_USER_ADD, PlayerIntoRoom)
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_USER_LEAVE, PlayerLeaveRoom)
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_USER_STATUS, PlayerStateShange)
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_COMM_REPORT_USER_ITEM_CHANGE, PlayerScoreChange)       --玩家货币改变
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_USER_ITEM, PlayerRealScoreChange)     --玩家真实货币改变
    NetProtocolBase.RegistNetEvent(MessageType.FLG_HOUSE_REPORT_USER_ONLINE_FLAG, PlayerIsOnline)             --通告玩家在线状态
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_BASE, GameStateChange)               --状态改变中

    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_DETAIL, FaPai)                       --发牌
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_USER, PlayerDataChange)              --用户数据改变


    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_HOUSE_REPORT_FIGHT_RESULT, GameResult)                --游戏结算
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLG_HOUSE_REPORT_ALL_FIGHT_RESULT, RoomResult)            --房间结算
    NetProtocolBase.RegistNetEvent(DouDiZhuMsgType.FLB_COMM_OUT_FIGHT_RESULT, RespondExitRoom)               --推出房間成功
end


function RemoveEventListener()
    Event.RemoveListener(DouDiZhuMsgType.FLG_COMM_QUERY_USER_ROOMID_RESULT, RespondIsKeepRomm)     --是否还在房间中
    Event.RemoveListener(DouDiZhuMsgType.FLB_COMM_REPORT_USER_CUR_ROOMID, NoticeRoomInfo)
    Event.RemoveListener(DouDiZhuMsgType.FLG_COMM_QUERY_ROOM_DETAIL_RESULT, RespondPlayerInfo)
    Event.RemoveListener(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_USER_ADD, PlayerIntoRoom)
    Event.RemoveListener(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_USER_LEAVE, PlayerLeaveRoom)
    Event.RemoveListener(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_USER_STATUS, PlayerStateShange)
    Event.RemoveListener(DouDiZhuMsgType.FLG_COMM_REPORT_USER_ITEM_CHANGE, PlayerScoreChange)      --玩家货币改变
    Event.RemoveListener(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_USER_ITEM, PlayerRealScoreChange)    --玩家真实货币改变
    Event.RemoveListener(MessageType.FLG_HOUSE_REPORT_USER_ONLINE_FLAG, PlayerIsOnline)            --通告玩家在线状态
    Event.RemoveListener(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_BASE, GameStateChange)
    Event.RemoveListener(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_DETAIL,FaPai)                        --发牌
    Event.RemoveListener(DouDiZhuMsgType.FLG_COMM_REPORT_ROOM_USER, PlayerDataChange)              --用户数据改变

    Event.RemoveListener(DouDiZhuMsgType.FLG_HOUSE_REPORT_FIGHT_RESULT, GameResult)                  --游戏结算
    Event.RemoveListener(DouDiZhuMsgType.FLG_HOUSE_REPORT_ALL_FIGHT_RESULT, RoomResult)             --房间结算
    Event.RemoveListener(DouDiZhuMsgType.FLB_COMM_OUT_FIGHT_RESULT, RespondExitRoom)        --推出房間成功
end

--错误码处理注册
function RegisterErrorCodeHandler()
    ErrorCodeHandler.RegisterCodeHandler(8007, function (cmd)
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):PlayerOutError(8007,GetGameData())
    end);
	ErrorCodeHandler.RegisterCodeHandler(10091, function (cmd)
        TipsView.ShowOk("您的金币不足,请到大厅充值再继续游戏！", function ()
            CtrlManager.CloseGame(CtrlNames.DouDiZhuMain)
        end,true)
    end);
    ErrorCodeHandler.RegisterCodeHandler(10093, function (cmd)
        TipsView.ShowOk("您的金币不足,请到大厅充值再继续游戏！", function ()
            CtrlManager.CloseGame(CtrlNames.DouDiZhuMain)
        end,true)
    end);
    ErrorCodeHandler.RegisterCodeHandler(10092, function (cmd)
        TipsView.ShowOk("房间已满，请返回大厅重新选择！", function ()
            CtrlManager.CloseGame(CtrlNames.DouDiZhuMain)
        end,true)
	end);
end

--移除错误码事件
function RemoveErrorCodeHandler()
    ErrorCodeHandler.RemoveCodeHandler(8007)
    ErrorCodeHandler.RemoveCodeHandler(10091)
    ErrorCodeHandler.RemoveCodeHandler(10092)
    ErrorCodeHandler.RemoveCodeHandler(10093)
end

--检测是否后台运行
function ListenerAppIsBack()
    Game.RegistAppFocusEvent("DouDiZhuFocusEvent", function (isFocus)
        if isFocus then     --从后台切回来
            ModelLog("唤醒游戏",nil);
            RoomBaseuserMsg = nil
            RoomdetailMsg = nil
            IsStartCompleted = false
            DouDiZhu.AddEventListener()
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
    local title = "斗地主," .. "房间号：" .. Data.RoomId .. ",3人"
    local content = Data.GameRuleInfoStrList[1] .. "、" .. Data.GameRuleInfoStrList[2] .. "、" .. Data.GameRuleInfoStrList[3]
    local params = {
        gameName = "斗地主", 
        gameTitle = "房间号",
        ruleInfo = content,
        roomid = Data.RoomId
    }
    ShareHelper.ShareToFriend(params, title, content)
end

----------------------------------------发包--------------------------------------------------------------
--请求退出房间
function SendExitRoom()
    Network.SendUserEmptyMsg(DouDiZhuMsgType.FLB_COMM_OUT_FIGHT, nil)
end

--客户端进入房间请求房间内数据
function JoinRoomRequest(callback)
    RespondGameDataCallBack = callback
    --RequestRoominfo();
    RequestPlayerInfo();
end

--请求是否在房间中
function RequestIsKeepRoom()
    ModelLog("请求是否在房间中",nil);
    Network.SendUserEmptyMsg(DouDiZhuMsgType.FLG_COMM_QUERY_USER_ROOMID, nil)
    IsOnHuanXing = true
end

--请求房间内用户信息
function RequestPlayerInfo()
    ModelLog("请求房间内用户信息",nil);
    Network.SendUserEmptyMsg(DouDiZhuMsgType.FLG_COMM_QUERY_ROOM_DETAIL, nil)
end

function RequestRoominfo()
    ModelLog("请求房间内详细信息",nil);
    Network.SendUserEmptyMsg(DouDiZhuMsgType.FLG_COMM_QUERY_ROOM_EXTEN, nil)
end

--发送准备状态 1准备 0取消准备
function SendReadyState(state)
    ModelLog("请求玩家准备",state);
    Network.SendUCharMsg(DouDiZhuMsgType.FLB_COMM_SET_FIGHT_READY, tostring(state))
end

--发送玩家托管
function SendIsTrustFlag(state)
    ModelLog("请求玩家托管",state);
    Network.SendUCharMsg(DouDiZhuMsgType.FLG_COMM_BRAND_TRUSTEESHIP, tostring(state))
end

--请求叫地主
function RequestLandlord(CallScore)
    Network.SendUCharMsg(DouDiZhuMsgType.FLG_COMM_CALL_LANDBORD,  tostring(CallScore))
end

--请求出牌
function RequestChuPai(PkType,Pks)
    local req = DouDiZhu_CommOutBrand:New(tonumber(DouDiZhuMsgType.FLG_COMM_OUT_BRAND), PkType, Pks)
    req:WriteToBuffer()
    networkMgr:SendMessage()
end

--放弃出牌
function RequestChuPaiPass()
    Network.SendUserEmptyMsg(DouDiZhuMsgType.FLG_COMM_OUT_BRAND_PASS, nil)
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
    CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):OnCallExitGame()
end

--回应是否在房间中
function RespondIsKeepRomm(buffer)
    local item = DouDiZhu_UserRoomType:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到是否在房间中的回应",item);
    if item.UserRoomID == 0 then   --房间已经不存在了
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):GameComeAgain()
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):BackMainView()
    else    --房间还存在
        GameDataInit(item.UserRoomID,CurrGameParams:GetGameID())
        DebugGameData("房间信息初始化");
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):AppAwakenGame(GetGameData())
        DouDiZhu.JoinRoomRequest()
    end
end

----服务器通告客户端当前的房间信息CommReportCurRoomBase
function  NoticeRoomInfo(buffer)
    local item = DouDiZhu_CommReportCurRoomBase:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到房间信息改变",item);
    if item.Userroombase.UserRoomID == 0 then  --长时间不准备被系统提出房间
        if item.Reason == DouDiZhuMsgReason.REASONTIMEOUTCLEAR then
            ToastView.Show("房间人员已满，30秒未准备将会被踢出房间", function ()             
            end, 3);
            CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):OnCallExitGame()
        elseif item.Reason == DouDiZhuMsgReason.REASONUSERCLEAR and not GetGameData().Table.GameResultData then
            CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):OnCallExitGame()
        elseif item.Reason == DouDiZhuMsgReason.REASONERRANDCLEAR then
            ToastView.Show("异常情况被踢出", function ()             
            end, 3);
            CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):OnCallExitGame()
        elseif item.Reason == DouDiZhuMsgReason.REASONGOLDNULL then
            ToastView.Show("金币为空被清除房间", function ()             
            end, 3);
            CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):OnCallExitGame()
        elseif item.Reason == DouDiZhuMsgReason.REASONCREATEDISS then
            ToastView.Show("房间被房主主动解散", function ()             
            end, 3);
            CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):OnCallExitGame()
        elseif item.Reason == DouDiZhuMsgReason.REASONUNIONGRULEALTER then
            ToastView.Show("规则，战队或联盟信息发送变化", function ()             
            end, 3);
            CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):OnCallExitGame()
        end
    end

    if item.Userroombase.UserRoomID ~= 0 then   --房间信息改变 再来一局了
        RoomBaseuserMsg = nil
        RoomdetailMsg = nil
        GameDataInit(item.Userroombase.UserRoomID,CurrGameParams:GetGameID())
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):GameComeAgain(GetGameData())
         --请求房间信息
        DouDiZhu.JoinRoomRequest(function()
            SendReadyState(1)   --自动准备
        end)          
    end
end

--返回房间内用户信息
function RespondPlayerInfo(buffer)
    if RoomBaseuserMsg then return end      --已经接收过了不在接收
    local item = DouDiZhu_CommQueryDetailRes:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到房间内用户信息",item)
    RoomBaseuserMsg = item;
    --房间房间数据都已到达 可以写入游戏数据恢复场景了
    -- if RoomdetailMsg then
    SetRoomDataRecovery(RoomBaseuserMsg);
    DebugGameData("房间信息恢复");
    local GameDate = GetGameData()
    CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):RestoreGame(GameDate,RoomBaseuserMsg.Roomdetail.CurAppSettleInfo)
    if RespondGameDataCallBack then
        RespondGameDataCallBack()
        RespondGameDataCallBack = nil
    end
    IsStartCompleted = true
    IsOnHuanXing = false
    ModelLog("处理 房间内用户信息 完成",TableToStr(item))
    -- else
    --     ModelLog("等待房间详细信息到达...")
    -- end
end

--通告房间内玩家离开
function PlayerLeaveRoom(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local uid = buffer:ReadUInt32()
    local ChairId = SetPlayerLeaveRoom(uid)
    DebugGameData("收到 玩家离开房间 ChairId = "..ChairId)
    if ChairId ~= 0 then
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):PlayerLeave(ChairId,GetGameData())
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
        local infoItem = DouDiZhu_CommUserItemChange:Create()
        subBuffer = Util.GetSubBuffer(bytes, offset, infoItem.size)
        infoItem:ReadFromBuffer(subBuffer)
        offset = offset + infoItem.size
        itemList[i]=infoItem
    end
    ModelLog("收到玩家货币改变",itemList)
    local ChanageData = SetPlayerScore(itemList)
    DebugGameData("玩家货币改变")
    CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):PlayerScoreChange(ChanageData,GetGameData())
    ModelLog("处理 玩家货币改变 完成")
end

function PlayerRealScoreChange(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = DouDiZhu_CommReportRoomUserItem:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到玩家真实货币改变",item)
    SetPlayerRealScore(item)
    DebugGameData("玩家真实货币改变")
    CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):PlayerScoreNoAnimChange(GetGameData())
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
    CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):PlayerIsOnline(ChairId,GetGameData())
    ModelLog("处理 玩家离线状态改变 完成")
end

--------------------------------------------游戏流程逻辑--------------------------------------------------
--通告房间新用户加入 此函数要做异常处理 有可能玩家还未请求到房间信息之前 收到此消息 这个时候房间数据结构不能确定 
function PlayerIntoRoom(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = DouDiZhu_CommRoomNewUser:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("收到 新玩家加入",item)
    local ChairId = SetPlayerIntoRoom(item)
    if ChairId ~= 0 then
        DebugGameData("新用户加入 ChairId ="..ChairId);
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):PlayerIntoRoom(ChairId,GetGameData())
    else
        ModelLog("无效玩家加入",item)
    end
    ModelLog("处理 新玩家加入 完成")
end
--准备
function PlayerStateShange(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = DouDiZhu_CommRoomUserStatus:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("玩家状态改变",item)
    local ChairId = SetPlayerIsReady(item);
    DebugGameData("玩家状态改变 ChairId ="..ChairId);
    CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):PlayerReady(ChairId,GetGameData())
    ModelLog("处理 玩家状态改变 完成")
end

--游戏状态改变
function GameStateChange(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = DouDiZhu_CommReportRoomBase:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("游戏状态改变 Reason = "..item.Reason)
    print("监控日志 1")
    ModelLog("游戏状态改变 Reason = ",item)
    print("监控日志 2")
    if item.Reason == DouDiZhuMsgReason.REASONBASESETP or item.Reason == DouDiZhuMsgReason.REASONCALLLANDNEXT or item.Reason == DouDiZhuMsgReason.REASONNOCALLNEXT then  --开始叫分
        ModelLog("游戏状态改变 Reason = ",item)
        local ChairId,LastCallChairId = SetCurrCallScorePlayer(item.Baseroominfo)
        DebugGameData("通告玩家叫地主 ChairId = "..ChairId.."|LastCallChairId = "..LastCallChairId)
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):PlayerCallScore(ChairId,LastCallChairId,GetGameData())
    elseif item.Reason == DouDiZhuMsgReason.REASONPOKEGUONEXT then           --出牌过
        local PassChairId,CurrRunChairId = SetPlayerChuPaiPass(item.Baseroominfo)
        DebugGameData("通告玩家出牌 过 CurrRunChairId = "..CurrRunChairId)
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):PlayerChuPaiPass(PassChairId,GetGameData())
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):ShowPlayerOperation(CurrRunChairId,GetGameData())
    end
    ModelLog("游戏状态改变 处理完成")
end

--玩家数据改变
function PlayerDataChange(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = DouDiZhu_CommReportRoomUser:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("用户数据改变 Reason = "..item.Reason)
    print("监控日志 1")
    ModelLog("用户数据改变 Reason = ",item)
    print("监控日志 2")
    if item.Reason == DouDiZhuMsgReason.REASONSETLANDBORD then --成功设置地主
        local ChairId = SetCallLandlord(item.Roomuserdetail)
        DebugGameData("通告叫地主成功 ChairId = "..ChairId)
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):SuccCallLandlord(ChairId,GetGameData())
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):ShowPlayerOperation(ChairId,GetGameData())
    elseif item.Reason == DouDiZhuMsgReason.REASONUSEROUTPOKE or item.Reason == DouDiZhuMsgReason.REASONUSEROUTNOTRISE then            --玩家出牌
        local OutChairId,CurrRunChairId = SetPlayerChuPai(item.Baseroominfo)
        DebugGameData("通告玩家出牌 OutChairId = "..OutChairId.."|CurrRunChairId = "..CurrRunChairId)
        CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):PlayerChuPai(OutChairId,GetGameData())
        if CurrRunChairId ~= OutChairId then
            CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):ShowPlayerOperation(CurrRunChairId,GetGameData())
        end
    end
    ModelLog("用户数据改变 处理完成")
end

--发牌
function FaPai(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = DouDiZhu_CommReportRoomDetail:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("通告发牌",item)
    SetFaPai(item.Roomdetail)
    DebugGameData("发牌")
    CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):FaPai(GetGameData())
    ModelLog("处理 发牌 完成")
end

--游戏结算
function GameResult(buffer)
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local item = DouDiZhu_CommReportFightRes:Create()
    item:ReadFromBuffer(buffer)
    ModelLog("通告游戏结算",item)
    SetGameResult(item)
    CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):GameResult(GetGameData())
    ModelLog("处理 游戏结算 完成")
end

--继续游戏
function GameContinue()
    SetGameDataContinue()
    DebugGameData("继续游戏")
    CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):GameContinue(GetGameData())
    ModelLog("处理 继续游戏 完成")
end

--房间结算
function RoomResult(buffer)
    print("收到房间结算消息")
    if not IsStartCompleted then return end             --房间没有初始化成功不处理游戏业务消息
    local itemList = {}
    local bytes = buffer:ReadAllBytes()
    local offset = 0
    for i = 1, 3 do
        local item = DouDiZhu_HouseLoadFinalResult:Create()
        local subBuffer = Util.GetSubBuffer(bytes, offset, item.size)
        item:ReadFromBuffer(subBuffer)
        itemList[#itemList+1]=item
        offset = offset + item.size
    end
    ModelLog("收到房间结算",itemList)
    SetRoomResult(itemList)
    CtrlManager.GetCtrl(CtrlNames.DouDiZhuMain):RoomResult(GetGameData())
    ModelLog("处理 房间结算 完成")
end

--再来一局
function GameComeAgain()
    SendGameComeAgain()
end

