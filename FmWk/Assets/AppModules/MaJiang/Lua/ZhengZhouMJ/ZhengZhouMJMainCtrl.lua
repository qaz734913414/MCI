require "DouWan/ZhengZhouMJ/Logic/ZhengZhouMJLogic"
print("导入郑州麻将 完成 Ok 1")
require "DouWan/ZhengZhouMJ/MJCard"
print("导入郑州麻将 完成 Ok 2")
ClassCtrl(CtrlNames.ZhengZhouMJMain)

print("导入郑州麻将 完成 Ok")
function ZhengZhouMJMainCtrl:StartView()
    print("进入了郑州麻将")
    self.CurGameParams = unpack(self.args) -- 传输过来的游戏参数
    ZhengZhouMJ.Initialize(self.CurGameParams)
    self.view = ViewManager.Start(self, GameNames.ZhengZhouMJ, PanelNames.ZhengZhouMJMainView, self.args)
	self.view.ctrl = self
end

function ZhengZhouMJMainCtrl:CallExitGame()
    TipsView.Show("确定退出推倒胡？", function ()
        ZhengZhouMJ.SendExitRoom()
    end, nil, true)
end

function ZhengZhouMJMainCtrl:OnCallExitGame()
    CtrlManager.CloseGame(CtrlNames.ZhengZhouMJMain)
end

function ZhengZhouMJMainCtrl:OnDestroy()
    ZhengZhouMJ.UnInitialize()
end

--App重新切回游戏
function ZhengZhouMJMainCtrl:AppAwakenGame(GameData)
    self.view:AppAwakenGame(GameData)
end

--回復游戲 解散场景也需要恢复
function ZhengZhouMJMainCtrl:RestoreGame(GameData,RoomJieSanData)
    self.view:RestoreGame(GameData,RoomJieSanData)
end

function ZhengZhouMJMainCtrl:UpdataPlayerInfo(ChairId,GameData)
    self.view:ShowPlayer(ChairId,GameData)
end

--玩家离开房间
function ZhengZhouMJMainCtrl:PlayerLeave(ChairId,GameData)
    self.view:PlayerLeave(ChairId,GameData)
end

function ZhengZhouMJMainCtrl:PlayerScoreChange(ChanageData,GameData)
    self.view:PlayerScoreChange(ChanageData,GameData)
end

function ZhengZhouMJMainCtrl:PlayerScoreNoAnimChange(GameData)
    self.view:PlayerScoreNoAnimChange(GameData)
end


function ZhengZhouMJMainCtrl:PlayerIsOnline(ChairId,GameData)
    self.view:PlayerIsOnline(ChairId,GameData)
end


--返回主界面
function ZhengZhouMJMainCtrl:BackMainView()
    self.view:BackMainView()
end

--停止全部携程
 function ZhengZhouMJMainCtrl:StopAllCoroutine()
    self.view:StopAllCoroutine()
 end

----------------------------------------游戏业务逻辑-----------------------------------
function ZhengZhouMJMainCtrl:PlayerIntoRoom(ChairId,GameData)
    self.view:PlayerIntoRoom(ChairId,GameData)
end

function ZhengZhouMJMainCtrl:PlayerReady(ChairId,GameData)
    self.view:PlayerReady(ChairId,GameData)
end

function ZhengZhouMJMainCtrl:DingZhang(GameData)
    self.view:DingZhang(GameData)
end

function ZhengZhouMJMainCtrl:StartDaPiao(GameData)
    self.view:StartDaPiao(GameData)
end

function ZhengZhouMJMainCtrl:PlayerDaPiao(ChairId,GameData)
    self.view:PlayerDaPiao(ChairId,GameData)
end

function ZhengZhouMJMainCtrl:FaPai(GameData)
    self.view:FaPai(GameData)
end

function ZhengZhouMJMainCtrl:MoPai(ChairId,BackFlag,GameData)
    self.view:MoPai(ChairId,BackFlag,GameData)
end

function ZhengZhouMJMainCtrl:ShowCanTingMJ(GameData)
    self.view:ShowCanTingMJ(GameData)
end

function ZhengZhouMJMainCtrl:ShowQueryHuView(GameData)
    self.view:ShowQueryHuView(GameData)
end

function ZhengZhouMJMainCtrl:ShowOperation(GameData)
    self.view:PlayerShowOperation(GameData)
end

--玩家欣行为 出牌 吃碰杠胡
function ZhengZhouMJMainCtrl:PlayAction(ChairId,AcyionType,MJ,GameData)
    self.view:PlayAction(ChairId,AcyionType,MJ,GameData)
end

--游戏结算
function ZhengZhouMJMainCtrl:GameResult(GameData)
    self.view:GameResult(GameData)
end

--继续游戏
function ZhengZhouMJMainCtrl:GameContinue(GameData)
    self.view:GameContinue(GameData)
end

--房间结算
function ZhengZhouMJMainCtrl:RoomResult(GameData)
    self.view:RoomResult(GameData)
end

function ZhengZhouMJMainCtrl:GameComeAgain(GameData)
    self.view:GameComeAgain(GameData)
end
    