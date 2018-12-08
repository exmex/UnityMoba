require "System.Global"

class("StoreLotteryPanelAPI")

function StoreLotteryPanelAPI:Awake(this)
	-- body
	self.this = this
  	StoreLotteryPanelAPI.Instance = self
  	self.StoreLotteryPanelCtrl = this.transforms[0]:GetComponent("NTGLuaScript")
end

function StoreLotteryPanelAPI:Start()
	-- body
end
function StoreLotteryPanelAPI:UpdateUI()
	-- body
	self.StoreLotteryPanelCtrl.self:UpdateUI()
end
function StoreLotteryPanelAPI:OnDestroy()
	-- body
	StoreLotteryPanelAPI.Instance = nil
	self.this = nil
	self =nil
end