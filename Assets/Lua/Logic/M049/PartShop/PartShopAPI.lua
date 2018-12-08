require "System.Global"

class("PartShopAPI")

function PartShopAPI:Awake(this)
	-- body
	self.this = this
	self.controller = self.this.transforms[0]:GetComponent("NTGLuaScript")
	PartShopAPI.Instance = self
end

function PartShopAPI:Start()
	-- body
end

function PartShopAPI:UpdatePieceAndList()
	-- body
	self.controller.self:UpdatePieceAndList()
end

function PartShopAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	PartShopAPI.Instance = nil
end