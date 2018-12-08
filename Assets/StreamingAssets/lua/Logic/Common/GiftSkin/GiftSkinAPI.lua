require "System.Global"

class("GiftSkinAPI")

function GiftSkinAPI:Awake(this)
	-- body
	self.this = this
	self.controller = self.this.transforms[0]:GetComponent("NTGLuaScript")
	GiftSkinAPI.Instance = self
end

function GiftSkinAPI:Start()
	-- body
end

function GiftSkinAPI:InitGiftSkin(skinId)
	-- body
	self.controller.self:InitGiftSkin(skinId)
end

function GiftSkinAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	GiftSkinAPI.Intance = nil
end
