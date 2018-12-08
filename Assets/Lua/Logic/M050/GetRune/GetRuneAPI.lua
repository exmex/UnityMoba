require "System.Global"

class("GetRuneAPI")

function GetRuneAPI:Awake(this)
	-- body
	self.this = this
	self.controller = self.this.transforms[0]:GetComponent("NTGLuaScript")
	GetRuneAPI.Instance = self
end

function GetRuneAPI:Start()
	-- body
end

function GetRuneAPI:ChangeTitle(text)
	-- body
	self.controller.self:ChangeTitle(text)
end

function GetRuneAPI:ShowReward(list)			--list为一个双层table，内层table需要包含id，type，amount
	-- body
	self.controller.self:UseSuccessfullyControl(list)
end

function GetRuneAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	GetRuneAPI.Instance = nil
end