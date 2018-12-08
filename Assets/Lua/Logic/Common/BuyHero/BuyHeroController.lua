require "System.Global"

class("BuyHeroController")

local Data = UTGData.Instance()
local Text = "Text"
local Image = "Image"
local Slider = "Slider"
local RectTrans = "RectTransform"

function BuyHeroController:Awake(this)
	-- body
	self.this = this
	self.buyInfoPanel = self.this.transforms[0]

	self.payCoinPanel = self.buyInfoPanel:Find("PricePanel/PayCoin")
	self.payOtherWayPanel = self.buyInfoPanel:Find("PricePanel/PayOtherWay")
	self.payCoinButton = self.buyInfoPanel:Find("Panel/PayCoinButton")
	self.payOtherWayButton = self.buyInfoPanel:Find("Panel/PayOtherWayButton")
	self.coinNum = self.payCoinPanel:Find("PayNum")
	self.payOtherWayNum = self.payOtherWayPanel:Find("PayNum")
	self.payOtherWayIcon = self.payOtherWayPanel:Find("PayTypeIcon")
	self.payOtherWayType = self.payOtherWayPanel:Find("PayType")
	self.payOtherWayButtonName = self.payOtherWayButton:Find("Text")

	self.closeButton = self.this.transform:Find("CancelButton")

  self.buyInfoPanel:Find("Mask/HeroIcon").gameObject:SetActive(false)





   	local listener = NTGEventTriggerProxy.Get(self.closeButton.gameObject)
  	local callback = function(self, e)
    	self:DestroySelf()
  	end
  	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)
end

function BuyHeroController:Start()
	-- body
end

function BuyHeroController:BuyHero(heroId,buyType)

	if buyType == 1 then
		self.buyType = "OnlyTicket"
	elseif buyType == 2 then
		self.buyType = "CoinAndJewel"
	elseif buyType == 3 then
		self.buyType = "CoinAndTicket"
  elseif buyType == 0 then
    self.buyType = "Free"
	end

  self.getNewType = "Hero"
  --初始化
  self.payCoinPanel.gameObject:SetActive(true)
  self.payCoinButton.gameObject:SetActive(true)
  self.buyInfoPanel:Find("Mask/HeroIcon"):GetComponent(Image).sprite = UITools.GetSprite("portrait", Data.SkinsData[tostring(Data.RolesData[tostring(heroId)].Skin)].Portrait) 
  self.buyInfoPanel:Find("Mask/Image/Text"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].Name
  self.buyInfoPanel:Find("Mask/HeroIcon").gameObject:SetActive(true)
  self.shopId = 0
  if Data.ShopsData[tostring(heroId)] ~= nil then
    self.shopId = Data.ShopsData[tostring(heroId)][1].Id
  end
  --print("self.buyType " .. self.buyType)
  if self.buyType == "OnlyTicket" then
    self.payCoinPanel.gameObject:SetActive(false)
    self.payOtherWayIcon:GetComponent(Image).sprite = UITools.GetSprite("resourceicon", "Voucher")      --获取点卷Icon
    self.payOtherWayType:GetComponent(Text).text = "点券"
    self.payOtherWayNum:GetComponent(Text).text = Data.ShopsData[tostring(heroId)][1].VoucherPrice
    self.payCoinButton.gameObject:SetActive(false)
    self.payOtherWayButtonName:GetComponent(Text).text = "点券购买"
  elseif self.buyType == "CoinAndJewel" then
    self.coinNum:GetComponent(Text).text = Data.ShopsData[tostring(heroId)][1].CoinPrice
    self.payOtherWayIcon:GetComponent(Image).sprite = UITools.GetSprite("resourceicon", "Gem")     --获取宝石Icon
    self.payOtherWayType:GetComponent(Text).text = "宝石"
    self.payOtherWayNum:GetComponent(Text).text = Data.ShopsData[tostring(heroId)][1].GemPrice
    self.payOtherWayButtonName:GetComponent(Text).text = "宝石购买"
  elseif self.buyType == "CoinAndTicket" then
    self.coinNum:GetComponent(Text).text = Data.ShopsData[tostring(heroId)][1].CoinPrice
    self.payOtherWayIcon:GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Voucher")   --获取点券Icon
    self.payOtherWayType:GetComponent(Text).text = "点券"
    self.payOtherWayNum:GetComponent(Text).text = Data.ShopsData[tostring(heroId)][1].VoucherPrice
    self.payOtherWayButtonName:GetComponent(Text).text = "点券购买"
  elseif self.buyType == "Free" then
    self.payCoinPanel.gameObject:SetActive(false)
    self.payCoinButton.gameObject:SetActive(false)
    self.payOtherWayType:GetComponent(Text).text = "点券"
    self.payOtherWayNum:GetComponent(Text).text = 0  
  end
  --print("self.buyType end " .. self.buyType)

  local listener
  if buyType == 1 then
  	self.payCoinButton.gameObject:SetActive(true)
  	self.payOtherWayButton.gameObject:SetActive(false)
   	listener = NTGEventTriggerProxy.Get(self.payCoinButton.gameObject)
  	local callbackPayCoin = function(self, e)
    	UTGDataOperator.Instance:ShopBuy(self.shopId,buyType,1)
  	end
  	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackPayCoin,self)
  elseif buyType == 2 then
  	self.payCoinButton.gameObject:SetActive(true)
  	self.payOtherWayButton.gameObject:SetActive(true)
    listener = NTGEventTriggerProxy.Get(self.payCoinButton.gameObject)
  	local callbackPayCoin = function(self, e)
    	--print("宝石购买")
      UTGDataOperator.Instance:ShopBuy(self.shopId,1,1)
  	end
  	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackPayCoin,self)
  	
   	listener = NTGEventTriggerProxy.Get(self.payOtherWayButton.gameObject)
  	local callbackPayGem = function(self, e)
    	UTGDataOperator.Instance:ShopBuy(self.shopId,2,1)
  	end
  	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackPayGem,self)
  elseif buyType == 3 then
  	self.payCoinButton.gameObject:SetActive(true)
  	self.payOtherWayButton.gameObject:SetActive(true)
    listener = NTGEventTriggerProxy.Get(self.payCoinButton.gameObject)
  	local callbackPayCoin = function(self, e)
    	--print("金币购买")
      UTGDataOperator.Instance:ShopBuy(self.shopId,1,1)
  	end
  	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackPayCoin,self)
  	
   	listener = NTGEventTriggerProxy.Get(self.payOtherWayButton.gameObject)
  	local callbackPayTicket = function(self, e)
    	--print("点券购买")
      UTGDataOperator.Instance:ShopBuy(self.shopId,buyType,1)
  	end
  	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackPayTicket,self)  	
  end
end

function BuyHeroController:DestroySelf()
	-- body
	GameObject.Destroy(self.this.transform.parent.gameObject)
end

function BuyHeroController:OnDestroy()
	-- body
	self.this = nil
	self = nil
end