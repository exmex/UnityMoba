require "System.Global"

class("PropDetailsAPI")

function PropDetailsAPI:Awake(this)
	-- body
	self.this = this
	self.controller = self.this.transforms[0]:GetComponent("NTGLuaScript")
	PropDetailsAPI.Instance = self

end

function PropDetailsAPI:Start()
	-- body
end

function PropDetailsAPI:DataInit(itemId,isLock,maxNum,buyType,singlePrice,itemType,funcDelegate,funcDelegateSelf)	--id，是否有限购，可购买的最大数量，购买类型（1金币2宝石3点券），单价
	-- body
	self.controller.self:DataInit(itemId,isLock,maxNum,buyType,singlePrice,itemType,funcDelegate,funcDelegateSelf)
end

function PropDetailsAPI:DestroySelf()
	-- body
	self.controller.self:DestroySelf()
end

function PropDetailsAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	PropDetailsAPI.Instance = nil
end