ClassCtrl(CtrlNames.ZhengZhouMJRoomResult)

function ZhengZhouMJRoomResultCtrl:StartView()
    self.view = ViewManager.Start(self, GameNames.ZhengZhouMJ, PanelNames.ZhengZhouMJRoomResultView,  self.args)
	self.view.ctrl = self
end