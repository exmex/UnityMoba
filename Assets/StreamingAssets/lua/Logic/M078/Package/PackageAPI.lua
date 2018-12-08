require "System.Global"

class("PackageAPI")

function  PackageAPI:Awake(this)
	-- body
	self.this = this	
	self.packageControl = self.this.transforms[0]:GetComponent("NTGLuaScript")
	PackageAPI.Instance = self
	--上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end

function  PackageAPI:Start()
	-- body
	self:ResetPanel()
	--self.packageControl.self:TabControl(1)
end

function  PackageAPI:TypeControl()
	-- body
	self.packageControl.self:TypeControl(self.packageControl.self.num)
end

function PackageAPI:CloseSubPanel()
	-- body
	self.packageControl.self:CloseSubPanel()
end

function PackageAPI:ResetPanel()
	local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
	topAPI:GoToPosition("PackagePanel")
	topAPI:ShowControl(3)
	topAPI:InitTop(self.packageControl.self,PackageController.DestroySelf,nil,nil,"背包")
	topAPI:InitResource(0)
	topAPI:HideSom("Button")
	UTGDataOperator.Instance:SetResourceList(topAPI)
	self.packageControl.self:TabControl(1)
end

function PackageAPI:BackInit()
	-- body
	self.PackageControl.self:BackInit()
end

function PackageAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	PackageAPI.Instance = nil
end