require "System.Global"

class("StorePreferentialPanelAPI")

function StorePreferentialPanelAPI:Awake(this)
	-- body
	self.this = this
  	StorePreferentialPanelAPI.Instance = self
  	self.StorePreferentialPanelCtrl = this.transforms[0]:GetComponent("NTGLuaScript")
end

function StorePreferentialPanelAPI:Start()
	-- body
end
function StorePreferentialPanelAPI:UpdateUI()
	-- body
	self.StorePreferentialPanelCtrl.self:UpdateUI()
end
function StorePreferentialPanelAPI:OnDestroy()
	-- body
	StorePreferentialPanelAPI.Instance = nil
	self.this = nil
	self =nil
end