require "System.Global"

class("RankPanelAPI")

function RankPanelAPI:Awake(this)
	-- body
	self.this = this
  	RankPanelAPI.Instance = self
  	self.RankPanelCtrl = this.transforms[0]:GetComponent("NTGLuaScript")
  	self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end

function RankPanelAPI:Start()
	-- body
	local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
	topAPI:GoToPosition("RankPanel/RankCtrl")
	topAPI:ShowControl(1)
	topAPI:ShowSom("Button")
	topAPI:InitTop(self.RankPanelCtrl.self,RankPanelCtrl.OnBackBtnClick,self.RankPanelCtrl.self,RankPanelCtrl.OnRuleBtnClick,"排位赛")
	--UTGDataOperator.Instance:SetResourceList(topAPI)
end
function RankPanelAPI:OnDestroy()
	-- body
	RankPanelAPI.Instance = nil
	self.this = nil
	self =nil
end