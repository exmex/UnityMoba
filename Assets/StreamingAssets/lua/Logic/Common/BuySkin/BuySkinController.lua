require "System.Global"

class("BuySkinController")

local Data = UTGData.Instance()
local Text = "Text"
local Image = "Image"
local Slider = "Slider"
local RectTrans = "RectTransform"

function BuySkinController:Awake(this)
	-- body
	self.this = this
	self.buyInfo = self.this.transforms[0]
	self.cancelButton = self.this.transforms[1]

	self.skinPropertyFrame = self.buyInfo:Find("SkinProperty/SkinProperty")
	self.buySkinButton = self.buyInfo:Find("BuySkinButton")
	self.firstGetHeroButton = self.buyInfo:Find("FirstGetHeroButton")
	self.skinIcon = self.buyInfo:Find("Mask/HeroIcon")

	self.pay = self.buyInfo:Find("Pay")
	self.payType = self.pay:Find("PayType")
	self.payIcon = self.pay:Find("PayTypeIcon")
	self.payNum = self.pay:Find("PayNum")
	self.prePrice = self.pay:Find("PrePrice")
	self.prePriceTitle = self.pay:Find("PrePriceTitle")

	self.skinProperty = {}

	for i = 1,self.skinPropertyFrame.childCount do
		table.insert(self.skinProperty,self.skinPropertyFrame:GetChild(i-1))
	end

	self.closeButton = self.this.transform:Find("CancelButton")

   	local listener = NTGEventTriggerProxy.Get(self.closeButton.gameObject)
  	local callback = function(self, e)
    	self:DestroySelf()
  	end
  	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback ,self)

  	self.skinIcon.gameObject:SetActive(false)	



end

function BuySkinController:Start()
	-- body
end

function BuySkinController:Init(skinId)
	-- body
	UTGDataTemporary.Instance().GetNewType = "Skin"
	for i = 1,7 do
		self.skinProperty[i].gameObject:SetActive(false)
	end
	self.skinIcon:GetComponent(Image).sprite = UITools.GetSprite("portrait",Data.SkinsData[tostring(skinId)].Portrait)
	--print("abcabcabc " .. Data.ShopsData[tostring(skinId)].VoucherPrice)	--没有VoucherPrice的数据
	--self.payNum:GetComponent(Text).text = Data.ShopsData[tostring(skinId)].VoucherPrice
	self.skinIcon.gameObject:SetActive(true)
	self:ShowPrice(skinId)
	local skinsProperty = UTGDataOperator.Instance:GetSortedPropertiesByKey("Skin",skinId)
	for i = 1,#skinsProperty do
		self.skinProperty[i].gameObject:SetActive(true)
		print("skinsProperty[i].Des " .. skinsProperty[i].Des)
		self.skinProperty[i]:GetComponent(Text).text = skinsProperty[i].Des
		print("skinsProperty[i].Attr " .. skinsProperty[i].Attr)
		self.skinProperty[i]:Find("AddNum"):GetComponent(Text).text = "+ " .. skinsProperty[i].Attr
		self.skinAdd = skinsProperty[i]
	end

	self.heroId = Data.SkinsData[tostring(skinId)].RoleId

	self.shopId = 0
	if Data.ShopsData[tostring(skinId)] ~= nil then
		self.shopId = Data.ShopsData[tostring(skinId)][1].Id
	end

	if #skinsProperty == 0 then
		self.skinPropertyFrame.gameObject:SetActive(false)
	end

  	local listener = NTGEventTriggerProxy.Get(self.cancelButton.gameObject)
  	local callback1 = function(self, e)
    	self:DestroySelf()
  	end
  	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)

  	listener = NTGEventTriggerProxy.Get(self.buyInfo:Find("Button").gameObject)
  	local callback13 = function(self, e)
    	--self:GiftSkin(skinId)
    	--self:DoGoToGiftSkinPanel()
    	GameManager.CreatePanel("GiftSkin")
  		GiftSkinAPI.Instance:InitGiftSkin(skinId)
  		self:DestroySelf()
    	--[[
	    GameManager.CreatePanel("SelfHideNotice")
	    if SelfHideNoticeAPI ~= nil then
	      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
	    end  
	    ]]  	
  	end
  	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback13 ,self)

  	listener = NTGEventTriggerProxy.Get(self.buyInfo:Find("BuySkinButton").gameObject)
  	local callbackBuySkin = function(self, e)
    	UTGDataOperator.Instance:ShopBuy(self.shopId,self.buySkinType,1)
    	self:DestroySelf()
  	end
  	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackBuySkin, self)

   	listener = NTGEventTriggerProxy.Get(self.buyInfo:Find("FirstGetHeroButton").gameObject)
  	local callbackGetHero = function(self, e)
    	self:DoGoToHeroInfoPanel()
    	self:DestroySelf()
  	end
  	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackGetHero, self)
end

function BuySkinController:ConfirmButtonChose(buttonType)		--0:购买并穿戴		1:前往获取姬神
	-- body
	if buttonType == 0 then
		self.buySkinButton.gameObject:SetActive(true)
		self.firstGetHeroButton.gameObject:SetActive(false)
	elseif buttonType == 1 then
		self.buySkinButton.gameObject:SetActive(false)
		self.firstGetHeroButton.gameObject:SetActive(true)
	end
end

function BuySkinController:ShowPrice(skinId)
	-- body
	self.skinId = skinId
	local payCoin = Data.ShopsData[tostring(skinId)][1].CoinPrice
	local payGem = Data.ShopsData[tostring(skinId)][1].GemPrice
	local payVoucher = Data.ShopsData[tostring(skinId)][1].VoucherPrice
	local payType = {}
	local priceCount = 0	--0：原价与现价一致		1：原价与现价不一致

	self.price = payVoucher

	if payCoin ~= -1 then
		table.insert(payType,1)			--1：金币	2：宝石    3：点券
		self.payNum:GetComponent(Text).text = payCoin
		if Data.ShopsData[tostring(skinId)][1].RawCoinPrice ~= payCoin then
			priceCount = 1
		else
			priceCount = 0
		end
	end
	if payGem ~= -1 then
		table.insert(payType,2)
		self.payNum:GetComponent(Text).text = payGem
		if Data.ShopsData[tostring(skinId)][1].RawGemPrice ~= payGem then
			priceCount = 1
		else
			priceCount = 0
		end
	end
	if payVoucher ~= -1 then
		table.insert(payType,3)
		self.payNum:GetComponent(Text).text = payVoucher
		if Data.ShopsData[tostring(skinId)][1].RawVoucherPrice ~= payVoucher then
			priceCount = 1
		else
			priceCount = 0
		end
	end

	if priceCount == 1 then
		self.prePrice.gameObject:SetActive(false)
		self.prePriceTitle.gameObject:SetActive(false)
		self.payNum.localPosition = Vector3.New(self.payNum.localPosition.x,-3.2,0)
	else
		self.prePrice.gameObject:SetActive(true)
		self.prePriceTitle.gameObject:SetActive(true)
		self.payNum.localPosition = Vector3.New(self.payNum.localPosition.x,-11.82,0)		
	end

	self.buySkinType = 0
	print("#payType " .. #payType)
	if #payType == 1 then
		if payType[1] == 1 then
			self.payType:GetComponent(Text).text = "金币"
			self.payIcon:GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Coin")
		elseif payType[1] == 2 then
			self.payType:GetComponent(Text).text = "钻石"
			self.payIcon:GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Gem")
		elseif payType[1] == 3 then
			self.payType:GetComponent(Text).text = "点券"
			self.payIcon:GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Voucher")			
		end
		self.buySkinType = payType[1]
	end
end

function BuySkinController:DoGoToHeroInfoPanel()
	-- body
	coroutine.start(BuySkinController.GoToHeroInfoPanel, self)
end

function BuySkinController:GoToHeroInfoPanel()
	-- body
	local trans = GameManager.CreatePanelAsync("HeroInfo")
	while trans.Done == false do
		coroutine.wait(0.05)
	end
	if HeroInfoAPI ~= nil and HeroInfoAPI.Instance ~= nil then
		HeroInfoAPI.Instance:Init(self.heroId,{})
		HeroInfoAPI.Instance:InitCenterBySkinId(self.skinId)
	end
end

function BuySkinController:DoGoToGiftSkinPanel()
	-- body
	coroutine.start(self,BuySkinController.GoToGiftSkinPanel)
end

function BuySkinController:GoToGiftSkinPanel()
	-- body
	local trans = GameManager.CreatePanelAsync("GiftSkin")
	while trans.Done == false do
		coroutine.wait(0.05)
	end
	if GiftSkinAPI ~= nil and GiftSkinAPI.Instance ~= nil then
		GiftSkinAPI.Instance:InitGiftSkin(self.skinId,self.price)
	end
end

function BuySkinController:DestroySelf()
	-- body
	GameObject.Destroy(self.this.transform.parent.gameObject)
end

function BuySkinController:OnDestroy()
	-- body
	self.this = nil
	self = nil
end