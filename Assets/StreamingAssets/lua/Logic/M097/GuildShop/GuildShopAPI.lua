require "System.Global"

class("GuildShopAPI")

function GuildShopAPI:Awake(this)
	-- body
	self.this = this
	self.controller = self.this.transforms[0]:GetComponent("NTGLuaScript")
	GuildShopAPI.Instance = self
end

function GuildShopAPI:Start()
	-- body
end

function GuildShopAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	GuildShopAPI.Instance = nil
end