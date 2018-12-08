require "System.Global"

class("StoreRunePanelAPI")

function StoreRunePanelAPI:Awake(this)
	-- body
	self.this = this
  	StoreRunePanelAPI.Instance = self
  	self.StoreRunePanelCtrl = this.transforms[0]:GetComponent("NTGLuaScript")
end

function StoreRunePanelAPI:Start()
	-- body
end
function StoreRunePanelAPI:UpdateUI()
	-- body
	self.StoreRunePanelCtrl.self:UpdateUI()
end
function StoreRunePanelAPI:OnDestroy()
	-- body
	StoreRunePanelAPI.Instance = nil
	self.this = nil
	self =nil
end