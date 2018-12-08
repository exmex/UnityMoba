require "System.Global"

class("GiftDetailsAPI")

function GiftDetailsAPI:Awake(this)
	-- body
	self.this = this
	self.controller = self.this.transforms[0]:GetComponent("NTGLuaScript")
	GiftDetailsAPI.Instance = self

end

function GiftDetailsAPI:Start()
	-- body
end

function GiftDetailsAPI:DataInit(id,isLock,canBuyNum,buyType,singlePrice,list)		--id，是否有限购，可购买的最大数量，购买类型（1金币2宝石3点券），单价
	-- body
	self.controller.self:DataInit(id,isLock,canBuyNum,buyType,singlePrice,list)
end

function GiftDetailsAPI:DestroySelf()
	-- body
	self.controller.self:DestroySelf()
end

function GiftDetailsAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	GiftDetailsAPI.Instance = nil
end