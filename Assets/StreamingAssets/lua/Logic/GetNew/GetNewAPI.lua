require "System.Global"
class("GetNewAPI")

function GetNewAPI:Awake(this)
	-- body
	self.this = this
end

function GetNewAPI:OnDestroy()
	-- body
	self.this = nil 
	self = nil
end