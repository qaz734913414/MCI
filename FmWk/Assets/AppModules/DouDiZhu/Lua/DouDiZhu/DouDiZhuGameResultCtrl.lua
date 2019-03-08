ClassCtrl(CtrlNames.DouDiZhuGameResult)

function DouDiZhuGameResultCtrl:StartView()
    self.view = ViewManager.Start(self, GameNames.DouDiZhu, PanelNames.DouDiZhuGameResultView)
	self.view.ctrl = self
end