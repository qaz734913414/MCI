print("导入新的牌型分析脚本 1")
require "DouWan/DouDiZhu/Logic/DouDiZhuLogic"
print("导入新的牌型分析脚本 2")
require "DouWan/DouDiZhu/PokeCardComb"
print("导入新的牌型分析脚本 3")
require "DouWan/DouDiZhu/PkAnalysis"
print("导入新的牌型分析脚本 10")
ClassCtrl(CtrlNames.DouDiZhuMain)


function DouDiZhuMainCtrl:StartView()
    self.CurGameParams = unpack(self.args) -- 传输过来的游戏参数
    DouDiZhu.Initialize(self.CurGameParams)
    self.view = ViewManager.Start(self, GameNames.DouDiZhu, PanelNames.DouDiZhuMainView, self.args)
	self.view.ctrl = self
end

function DouDiZhuMainCtrl:CallExitGame()
    TipsView.Show("确定退出斗地主？", function ()
        DouDiZhu.SendExitRoom()
    end, nil, true)
end

function DouDiZhuMainCtrl:OnCallExitGame()
    CtrlManager.CloseGame(CtrlNames.DouDiZhuMain)
end

function DouDiZhuMainCtrl:OnDestroy()
    DouDiZhu.UnInitialize()
end

--App重新切回游戏
function DouDiZhuMainCtrl:AppAwakenGame(GameData)
    self.view:AppAwakenGame(GameData)
end

--回復游戲 解散场景也需要恢复
function DouDiZhuMainCtrl:RestoreGame(GameData,RoomJieSanData)
    self.view:RestoreGame(GameData,RoomJieSanData)
end

function DouDiZhuMainCtrl:UpdataPlayerInfo(ChairId,GameData)
    self.view:ShowPlayer(ChairId,GameData)
end

--玩家离开房间
function DouDiZhuMainCtrl:PlayerLeave(ChairId,GameData)
    self.view:PlayerLeave(ChairId,GameData)
end

function DouDiZhuMainCtrl:PlayerScoreChange(ChanageData,GameData)
    self.view:PlayerScoreChange(ChanageData,GameData)
end

function DouDiZhuMainCtrl:PlayerScoreNoAnimChange(GameData)
    self.view:PlayerScoreNoAnimChange(GameData)
end


function DouDiZhuMainCtrl:PlayerIsOnline(ChairId,GameData)
    self.view:PlayerIsOnline(ChairId,GameData)
end


--返回主界面
function DouDiZhuMainCtrl:BackMainView()
    self.view:BackMainView()
end

--停止全部携程
 function DouDiZhuMainCtrl:StopAllCoroutine()
    self.view:StopAllCoroutine()
 end

----------------------------------------游戏业务逻辑-----------------------------------
function DouDiZhuMainCtrl:PlayerIntoRoom(ChairId,GameData)
    self.view:PlayerIntoRoom(ChairId,GameData)
end

function DouDiZhuMainCtrl:PlayerReady(ChairId,GameData)
    self.view:PlayerReady(ChairId,GameData)
end

function DouDiZhuMainCtrl:FaPai(GameData)
    self.view:FaPai(GameData)
end

--玩家叫分
function DouDiZhuMainCtrl:PlayerCallScore(ChairId,LastCallChairId,GameData)
    self.view:PlayerCallScore(ChairId,LastCallChairId,GameData)
end

--成功叫地主
function DouDiZhuMainCtrl:SuccCallLandlord(ChairId,GameData)
    self.view:SuccCallLandlord(ChairId,GameData)
end


--显示玩家出牌操作按钮
function DouDiZhuMainCtrl:ShowPlayerOperation(ChairId,GameData)
    self.view:ShowPlayerOperation(ChairId,GameData)
end

--玩家出牌
function DouDiZhuMainCtrl:PlayerChuPai(ChairId,GameData)
    self.view:PlayerChuPai(ChairId,GameData)
end


--玩家出牌过
function DouDiZhuMainCtrl:PlayerChuPaiPass(ChairId,GameData)
    self.view:PlayerChuPaiPass(ChairId,GameData)
end

function DouDiZhuMainCtrl:PlayerOutError(Code,GameData)
    self.view:PlayerOutError(Code,GameData)
end

--游戏结算
function DouDiZhuMainCtrl:GameResult(GameData)
    self.view:GameResult(GameData)
end

--继续游戏
function DouDiZhuMainCtrl:GameContinue(GameData)
    self.view:GameContinue(GameData)
end

--房间结算
function DouDiZhuMainCtrl:RoomResult(GameData)
    self.view:RoomResult(GameData)
end

function DouDiZhuMainCtrl:GameComeAgain(GameData)
    self.view:GameComeAgain(GameData)
end
    