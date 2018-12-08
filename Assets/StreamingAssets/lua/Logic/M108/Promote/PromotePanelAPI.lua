require "System.Global"

class("PromotePanelAPI")

function PromotePanelAPI:Awake(this)
	-- body
	self.this = this
  	PromotePanelAPI.Instance = self
  	self.PromotePanelCtrl = this.transforms[0]:GetComponent("NTGLuaScript")
end

function PromotePanelAPI:Start()
	-- body
	PromotePanelAPI.Instance:SetParam(6,"I20300080","召唤")
end

function PromotePanelAPI:SetParam(nowLevel,skillID,skillName)
	-- body
	self.PromotePanelCtrl.self:PromoteInfoInit(nowLevel,skillID,skillName)
end

function PromotePanelAPI:OnDestroy()
	-- body
	PromotePanelAPI.Instance = nil
	self.this = nil
	self =nil
end