ClassCtrl(CtrlNames.ZhengZhouMJGameResult)

function ZhengZhouMJGameResultCtrl:StartView()
    print("打开大结算界面 1")
    self.view = ViewManager.Start(self, GameNames.ZhengZhouMJ, PanelNames.ZhengZhouMJGameResultView)
	self.view.ctrl = self
end