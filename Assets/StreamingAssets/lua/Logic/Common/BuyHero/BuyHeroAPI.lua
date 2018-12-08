require "System.Global"

class("BuyHeroAPI")

function BuyHeroAPI:Awake(this)
	-- body
	self.this = this
	self.controller = self.this.transforms[0]:GetComponent("NTGLuaScript")
	BuyHeroAPI.Instance = self
end

function BuyHeroAPI:Start()
	-- body
end

function BuyHeroAPI:BuyHero(heroId,buyType)
	-- body
	--print(heroId .. " " .. buyType)
	self.controller.self:BuyHero(heroId,buyType)
end

function BuyHeroAPI:DestroySelf()
	-- body
	self.controller.self:DestroySelf()
end

function BuyHeroAPI:OnDestroy()
	-- body
	self.this = nil 
	self = nil 
	BuyHeroAPI.Instance = nil
end
