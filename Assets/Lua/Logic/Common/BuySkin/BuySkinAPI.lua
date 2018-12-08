require "System.Global"

class("BuySkinAPI")

function BuySkinAPI:Awake(this)
	-- body
	self.this = this
	self.controller = self.this.transforms[0]:GetComponent("NTGLuaScript")
	BuySkinAPI.Instance = self
end

function BuySkinAPI:Start()
	-- body
end

function BuySkinAPI:Init(skinId)
	-- body
	self.controller.self:Init(skinId)
	--self.controller.self:ShowPrice(skinId)
end

function BuySkinAPI:ConfirmButtonChose(buttonType)
	-- body
	self.controller.self:ConfirmButtonChose(buttonType)
end

function BuySkinAPI:DestroySelf()
	-- body
	self.controller.self:DestroySelf()
end

function BuySkinAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	BuySkinAPI.Instance = nil
end