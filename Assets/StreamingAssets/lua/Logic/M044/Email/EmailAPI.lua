require "System.Global"

class("EmailAPI")

function EmailAPI:Awake(this)
	-- body
	self.this = this
	self.controller = self.this.transforms[0]:GetComponent("NTGLuaScript")
	EmailAPI.Instance = self
end

function EmailAPI:Start()
	-- body
end

function EmailAPI:GetOrderedList()
	-- body
	self.controller.self:GetOrderedList()
end

function EmailAPI:InitFriendList()
	-- body
	self.controller.self:InitFriendList()
end

function EmailAPI:InitSystemList()
	-- body
	self.controller.self:InitSystemList()
end

function EmailAPI:GetNextReward()
	-- body
	self.controller.self:GetNextReward()
end

function EmailAPI:UnReadMail()
	-- body
	self.controller.self:UnReadMail()
end

function EmailAPI:QuickDraw()
	-- body
	self.controller.self:QuickDrawMail(self.controller.self.drawType)
end

function EmailAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	EmailAPI.Instance = nil
end