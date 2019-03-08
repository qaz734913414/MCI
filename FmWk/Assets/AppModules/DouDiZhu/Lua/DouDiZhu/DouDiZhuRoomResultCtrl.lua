ClassCtrl(CtrlNames.DouDiZhuRoomResult)

function DouDiZhuRoomResultCtrl:StartView()
    self.view = ViewManager.Start(self, GameNames.DouDiZhu, PanelNames.DouDiZhuRoomResultView,  self.args)
	self.view.ctrl = self
end