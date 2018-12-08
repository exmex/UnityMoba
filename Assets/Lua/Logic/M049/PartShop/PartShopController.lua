require "System.Global"

class("PartShopController")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"

function  PartShopController:Awake(this)
	-- body
	self.this = this
	self.topTab = self.this.transforms[0]
	self.mainPanel = self.this.transforms[1]
	self.closeButton = self.this.transforms[2]


	self.heroTemp = self.mainPanel:Find("Hero/Panel/Image")
	self.skinTemp = self.mainPanel:Find("Skin/Panel/Image")

	self.heroTab = self.topTab:Find("Button1/NewHero")
	self.skinTab = self.topTab:Find("Button/NewSkin")

	self.heroList = {}
	self.skinList = {}

    local listener = NTGEventTriggerProxy.Get(self.heroTab.gameObject)
    local callbackHero = function(self, e)
    	UTGDataTemporary.Instance().PartShopType = "hero"
    	self:TabControl()
    end
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackHero, self)

    listener = NTGEventTriggerProxy.Get(self.skinTab.gameObject)
    local callbackSkin = function(self, e)
    	UTGDataTemporary.Instance().PartShopType = "skin"
    	self:TabControl()
    end
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackSkin, self)

    listener = NTGEventTriggerProxy.Get(self.closeButton.gameObject)
    local callbackSkin = function(self, e)
		if StoreNewCtrl ~= nil and StoreNewCtrl.Instance ~= nil then
			StoreNewCtrl.Instance.effectAlltime.gameObject:SetActive(true)
			StoreNewCtrl.Instance:ApiModelActive(true)
		end
    	GameObject.Destroy(self.this.transform.parent.gameObject)
    end
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackSkin, self)

end

function PartShopController:Start()
	-- body
	--UTGDataTemporary.Instance().PartShopType = "hero"
	if StoreNewCtrl ~= nil and StoreNewCtrl.Instance ~= nil then
		StoreNewCtrl.Instance.effectAlltime.gameObject:SetActive(false)
	end
	self:TabControl()
	self:InitAllList()
end

function PartShopController:TabControl()
	-- body
	if UTGDataTemporary.Instance().PartShopType == "hero" then
		self.topTab:Find("Button1/HighLight").gameObject:SetActive(true)
		self.topTab:Find("Button/HighLight").gameObject:SetActive(false)
		self.mainPanel:Find("PartPic/HeroPart").gameObject:SetActive(true)
		self.mainPanel:Find("PartPic/SkinPart").gameObject:SetActive(false)
		self.mainPanel:Find("Hero").gameObject:SetActive(true)
		self.mainPanel:Find("Skin").gameObject:SetActive(false)
		if Data.ItemsDeck[tostring(15010001)] ~= nil then
			self.mainPanel:Find("PartNum"):GetComponent(Text).text = Data.ItemsDeck[tostring(15010001)].Amount
		else
			self.mainPanel:Find("PartNum"):GetComponent(Text).text = 0
		end
	elseif UTGDataTemporary.Instance().PartShopType == "skin" then
		self.topTab:Find("Button1/HighLight").gameObject:SetActive(false)
		self.topTab:Find("Button/HighLight").gameObject:SetActive(true)
		self.mainPanel:Find("PartPic/HeroPart").gameObject:SetActive(false)
		self.mainPanel:Find("PartPic/SkinPart").gameObject:SetActive(true)
		self.mainPanel:Find("Hero").gameObject:SetActive(false)
		self.mainPanel:Find("Skin").gameObject:SetActive(true)
		if Data.ItemsDeck[tostring(15020001)] ~= nil then
			self.mainPanel:Find("PartNum"):GetComponent(Text).text = Data.ItemsDeck[tostring(15020001)].Amount
		else
			self.mainPanel:Find("PartNum"):GetComponent(Text).text = 0
		end	
	end
end

function PartShopController:InitAllList()
	-- body
	self.heroList = {}
	self.skinList = {}

	for i = 1,#Data.PartShopsDataForOrder do
		print("Data.PartShopsDataForOrder[i].Category " .. Data.PartShopsDataForOrder[i].CommodityType)
		if Data.PartShopsDataForOrder[i].CommodityType == 1 then
			table.insert(self.heroList,Data.PartShopsDataForOrder[i].CommodityId)
		elseif Data.PartShopsDataForOrder[i].CommodityType == 2 then
			table.insert(self.skinList,Data.PartShopsDataForOrder[i].CommodityId)
		end
	end

	for i = 2,self.mainPanel:Find("Hero/Panel").childCount do
		GameObject.Destroy(self.mainPanel:Find("Hero/Panel"):GetChild(i-1).gameObject)
	end

	for i = 2,self.mainPanel:Find("Skin/Panel").childCount do
		GameObject.Destroy(self.mainPanel:Find("Skin/Panel"):GetChild(i-1).gameObject)
	end

	local heroListSkin = {}
	for i = 1,#self.skinList do
		table.insert(heroListSkin,Data.RolesData[tostring(Data.SkinsData[tostring(self.skinList[i])].RoleId)])
	end

	local heroListHero = {}
	for i = 1,#self.heroList do
		table.insert(heroListHero,Data.RolesData[tostring(self.heroList[i])])
	end

	local go = ""
	local portrait = ""
	local role = ""
	for i = 1,#self.heroList do
		go = GameObject.Instantiate(self.heroTemp.gameObject)
		go:SetActive(true)
		go.transform:SetParent(self.mainPanel:Find("Hero/Panel"))
		go.transform.localScale = Vector3.one
		go.transform.localPosition = Vector3.zero

		portrait = Data.SkinsData[tostring(Data.RolesData[tostring(self.heroList[i])].Skin)].Portrait
		go.transform:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("portrait",portrait)
		go.transform.name = Data.PartShopsData[tostring(self.heroList[i])].Id
		if Data.RolesDeckData[tostring(self.heroList[i])] ~= nil and Data.RolesDeckData[tostring(self.heroList[i])].IsOwn == true then
			go.transform:Find("Panel/Info2").gameObject:SetActive(false)
			go.transform:Find("Panel/Info1/Text"):GetComponent(Text).text = Data.RolesData[tostring(self.heroList[i])].Name
			go.transform:Find("Button/Text"):GetComponent(Text).text = "已拥有"
		else
			go.transform:Find("Panel/Info1/Text"):GetComponent(Text).text = Data.RolesData[tostring(self.heroList[i])].Name
			go.transform:Find("Panel/Info2/Text"):GetComponent(Text).text = Data.PartShopsData[tostring(self.heroList[i])].Price
			go.transform:Find("Button/Text"):GetComponent(Text).text = "碎片兑换"
			local name = Data.PartShopsData[tostring(self.heroList[i])].Id


		    local callback2 = function()
		    	print("go.name " .. name .. " " .. type(tonumber(name)))
		    	UTGDataOperator.Instance:ExchangePartCommodity(tonumber(name))
		    end
		    local uiClick=UITools.GetLuaScript(go.transform:Find("Button"),"Logic.UICommon.UIClick")  
		    uiClick:RegisterClickDelegate(self,callback2)
		end
		local callback2 = function()
	    	self:DoGoToHeroInfoPanel(self.heroList[i],heroListHero)
	    end
	    local uiClick2=UITools.GetLuaScript(go.transform:Find("Image"),"Logic.UICommon.UIClick")  
	    uiClick2:RegisterClickDelegate(self,callback2) 
	end

	for i = 1,#self.skinList do
		go = GameObject.Instantiate(self.skinTemp.gameObject)
		go:SetActive(true)
		go.transform:SetParent(self.mainPanel:Find("Skin/Panel"))
		go.transform.localScale = Vector3.one
		go.transform.localPosition = Vector3.zero
		portrait = Data.SkinsData[tostring(self.skinList[i])].Portrait
		go.transform:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("portrait",portrait)
		go.transform.name = Data.PartShopsData[tostring(self.skinList[i])].Id
		--go.transform:Find("Tag"):GetComponent(Image).sprite = UITools.GetSprite("skintag",Data.SkinsData[tostring(self.skinList[i])].Tag) 
		role = Data.SkinsData[tostring(self.skinList[i])].RoleId
		if Data.SkinsDeckData[tostring(self.skinList[i])] ~= nil then
			if Data.SkinsDeckData[tostring(self.skinList[i])].IsOwn == true then
				go.transform:Find("Panel/Info2").gameObject:SetActive(false)
				print("self.skinList[i] " .. Data.SkinsData[tostring(self.skinList[i])].Name)
				go.transform:Find("Panel/Info1/HeroName"):GetComponent(Text).text = Data.RolesData[tostring(Data.SkinsData[tostring(self.skinList[i])].RoleId)].Name
				go.transform:Find("Panel/Info1/SkinName"):GetComponent(Text).text = Data.SkinsData[tostring(self.skinList[i])].Name
				go.transform:Find("Button/Text"):GetComponent(Text).text = "已拥有"
			else
				go.transform:Find("Panel/Info2").gameObject:SetActive(true)
				go.transform:Find("Panel/Info1/HeroName"):GetComponent(Text).text = Data.RolesData[tostring(Data.SkinsData[tostring(self.skinList[i])].RoleId)].Name
				go.transform:Find("Panel/Info1/SkinName"):GetComponent(Text).text = Data.SkinsData[tostring(self.skinList[i])].Name
				if Data.RolesDeckData[tostring(role)] ~= nil then
					go.transform:Find("Panel/Info2/Text"):GetComponent(Text).text = Data.PartShopsData[tostring(self.skinList[i])].Price
					go.transform:Find("Button/Text"):GetComponent(Text).text = "碎片兑换"
					local name = Data.PartShopsData[tostring(self.skinList[i])].Id

				    local callback1 = function()
				    	--print("go.name " .. go.name .. " " .. type(tonumber(go.name)))
				    	UTGDataOperator.Instance:ExchangePartCommodity(tonumber(name))
				    end
				    local uiClick=UITools.GetLuaScript(go.transform:Find("Button"),"Logic.UICommon.UIClick")  
				    uiClick:RegisterClickDelegate(self,callback1) 
				else	
					go.transform:Find("Button/Text"):GetComponent(Text).text = "需要先获得姬神"
					go.transform:Find("Button/Text"):GetComponent(Image).color = Color.New(252/255,216/255,92/255,1)

				    local callback3 = function()
				    	self:DoGoToHeroInfoPanel(Data.SkinsData[go.name].RoleId,heroListSkin,self.skinList[i],self.skinList)
				    end
				    local uiClick=UITools.GetLuaScript(go.transform:Find("Button"),"Logic.UICommon.UIClick")  
				    uiClick:RegisterClickDelegate(self,callback3) 
				end
				go.transform:Find("Panel/Info2/Text"):GetComponent(Text).text = Data.PartShopsData[tostring(self.skinList[i])].Price
			end
		else
			go.transform:Find("Panel/Info2").gameObject:SetActive(true)
			go.transform:Find("Panel/Info1/HeroName"):GetComponent(Text).text = Data.RolesData[tostring(Data.SkinsData[tostring(self.skinList[i])].RoleId)].Name
			go.transform:Find("Panel/Info1/SkinName"):GetComponent(Text).text = Data.SkinsData[tostring(self.skinList[i])].Name
			if Data.RolesDeckData[tostring(role)] ~= nil then
				go.transform:Find("Panel/Info2/Text"):GetComponent(Text).text = Data.PartShopsData[tostring(self.skinList[i])].Price
				go.transform:Find("Button/Text"):GetComponent(Text).text = "碎片兑换"
				local name = Data.PartShopsData[tostring(self.skinList[i])].Id

			    local callback5 = function()
			    	--print("go.name " .. go.name .. " " .. type(tonumber(go.name)))
			    	UTGDataOperator.Instance:ExchangePartCommodity(tonumber(name))
			    end
			    local uiClick=UITools.GetLuaScript(go.transform:Find("Button"),"Logic.UICommon.UIClick")  
			    uiClick:RegisterClickDelegate(self,callback5) 
			else	
				go.transform:Find("Button/Text"):GetComponent(Text).text = "需要先获得姬神"
				go.transform:Find("Button/Text"):GetComponent(Image).color = Color.New(252/255,216/255,92/255,1)

			    local callback6 = function()
			    	self:DoGoToHeroInfoPanel(Data.SkinsData[go.name].RoleId,heroListSkin,self.skinList[i],self.skinList)
			    end
			    local uiClick=UITools.GetLuaScript(go.transform:Find("Button"),"Logic.UICommon.UIClick")  
			    uiClick:RegisterClickDelegate(self,callback6) 
			end
			go.transform:Find("Panel/Info2/Text"):GetComponent(Text).text = Data.PartShopsData[tostring(self.skinList[i])].Price
						
		end
		local callback7 = function()
	    	self:DoGoToHeroInfoPanel(Data.SkinsData[tostring(self.skinList[i])].RoleId,heroListSkin,self.skinList[i],self.skinList)
	    end
	    local uiClick2=UITools.GetLuaScript(go.transform:Find("Image"),"Logic.UICommon.UIClick")  
	    uiClick2:RegisterClickDelegate(self,callback7) 
	end
end

function PartShopController:DoGoToHeroInfoPanel(heroId,heroList,skinId,skinList)
  -- body
  
	if skinId == nil and skinList == nil then
		coroutine.start(PartShopController.GoToHeroInfoPanel,self,heroId,heroList)
	else
		coroutine.start(PartShopController.GoToHeroInfoPanel,self,heroId,heroList,skinId,skinList)
	end 
end

function PartShopController:GoToHeroInfoPanel(heroId,heroList,skinId,skinList)
  -- body
  local async = GameManager.CreatePanelAsync("HeroInfo")
  while async.Done == false do
    coroutine.wait(0.05)
  end
  
  if HeroInfoAPI ~= nil and HeroInfoAPI.Instance ~= nil then
  	HeroInfoAPI.Instance:Init(heroId,heroList)
  	if skinId ~= nil and skinList ~= nil then
  		HeroInfoAPI.Instance:InitCenterBySkinId(skinId,skinList)
  	end
  end 
end

function PartShopController:UpdatePieceAndList()
	-- body
	if UTGDataTemporary.Instance().PartShopType == "hero" then
		self.mainPanel:Find("PartNum"):GetComponent(Text).text = Data.ItemsDeck[tostring(15010001)].Amount
	else
		self.mainPanel:Find("PartNum"):GetComponent(Text).text = Data.ItemsDeck[tostring(15020001)].Amount
	end
	self:InitAllList()
end

function PartShopController:OnDestroy()
	-- body
	self.this = nil
	self = nil
end