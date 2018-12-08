require "System.Global"

class("PropDetailsController")
local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"

function PropDetailsController:Awake(this)
	-- body
	self.this = this
	self.staticPart = self.this.transforms[0]
	self.buyPart = self.this.transforms[1]
	self.propPart = self.this.transforms[2]

	self.closeButton = self.staticPart:Find("BtnClose")

	self.reduceButton = self.buyPart:Find("Count/ReduceImage")
	self.addButton = self.buyPart:Find("Count/AddImage")
	self.maxButton = self.buyPart:Find("Count/MaxButton")

	self.buyButton = self.buyPart:Find("Button")
	self.imageOnButton = self.buyPart:Find("Button/Image")
	self.numOnButton = self.buyPart:Find("Button/LabCost")

	self.currentNum = self.buyPart:Find("Count/Count/Current")

	self.num = 1

	  local listener = NTGEventTriggerProxy.Get(self.closeButton.gameObject)
	  local callbackBuy = function(self, e)
	    self:DestroySelf()
	  end 
	  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackBuy, self)

end

function PropDetailsController:Start()
	-- body
end

function PropDetailsController:DataInit(id,isLocked,canBuyNum,buyType,singlePrice,itemType,funcDelegate,funcDelegateSelf)
	-- body

	--print("isLocked " .. itemType)
	if itemType == 4 then
		local itemData = Data.ItemsData[tostring(id)]
		self.propPart:Find("IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("icon",itemData.Quality)
		self.propPart:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",itemData.Icon)
		self.propPart:Find("LabName"):GetComponent(Text).text = itemData.Name
		self.propPart:Find("LabCost"):GetComponent(Text).text = singlePrice
		self.propPart:Find("LabDes"):GetComponent(Text).text = itemData.Desc
	elseif itemType == 3 then
		local itemData = Data.RunesData[tostring(id)]
		self.propPart:Find("IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("icon",itemData.Level)
		self.propPart:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",itemData.Icon)
		self.propPart:Find("IconFrame/Image/Icon"):GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector2.New(73,84.4)
		self.propPart:Find("LabName"):GetComponent(Text).text = itemData.Name
		self.propPart:Find("LabCost"):GetComponent(Text).text = singlePrice
		local attrs = UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",id)
		local str = ""
		for i = 1,#attrs do
			str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr .. "\n"
		end
		self.propPart:Find("LabDes"):GetComponent(Text).text = str		
	end
	self.propPart:Find("IconFrame").gameObject:SetActive(true)
	  if buyType == 1 then
	    self.imageOnButton:GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Coin")
	  elseif buyType == 2 then
	    self.imageOnButton:GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Gem")
	  elseif buyType == 3 then
	    self.imageOnButton:GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Voucher")
	  end
	  self.imageOnButton.gameObject:SetActive(true)
	  self.numOnButton:GetComponent(Text).text = singlePrice
	  --print("sdfsdfsdf")

	  local maxNum = 0

	  if isLocked == true then
	    maxNum = canBuyNum
	  else
	  	local itemNum = 0
	  	if Data.ItemsDeck[tostring(id)] ~= nil then
	    	itemNum = Data.ItemsDeck[tostring(id)].Amount
	    else
	    	itemNum = 0
	    end
	    maxNum = Data.ItemsData[tostring(id)].MaxStack - itemNum
	  end



	self.currentNum:GetComponent(Text).text = self.num
	--print("zxcvzxcvzxc")
	self.shopId = 0
	if Data.ShopsData[tostring(id)] ~= nil then
		self.shopId = Data.ShopsData[tostring(id)][1].Id
	end

	
    local listener = NTGEventTriggerProxy.Get(self.reduceButton.gameObject)
    --print("asdf")
    local callbackReduce = function(self, e)
	    if self.num > 1 then
	      self.num = self.num - 1
	      self.currentNum:GetComponent(Text).text = self.num
	      self.numOnButton:GetComponent(Text).text = singlePrice * self.num
	    end
    end 
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackReduce, self)
  

    listener = NTGEventTriggerProxy.Get(self.addButton.gameObject)
    local callbackAdd = function(self, e)
    	--print("self.num " .. self.num .. " " .. maxNum)
	    if self.num < maxNum then
	      self.num = self.num + 1
	      self.currentNum:GetComponent(Text).text = self.num
	      self.numOnButton:GetComponent(Text).text = singlePrice * self.num
	    end
    end 
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackAdd, self)
  

  
    listener = NTGEventTriggerProxy.Get(self.maxButton.gameObject)
    local callbackMax = function(self, e)
	    if self.num < maxNum then
	      self.num = maxNum
	      self.currentNum:GetComponent(Text).text = self.num
	      self.numOnButton:GetComponent(Text).text = singlePrice * self.num
	    end
    end 
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackMax, self)
  

	  listener = NTGEventTriggerProxy.Get(self.buyButton.gameObject)
	  local callbackBuy = function(self, e)
	    --购买
	    UTGDataOperator.Instance:ShopBuy(self.shopId,buyType,self.num,funcDelegate,funcDelegateSelf)
	  end 
	  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackBuy, self)
end

function PropDetailsController:DestroySelf()
	-- body
	GameObject.DestroyImmediate(self.this.transform.parent.gameObject)
end

function PropDetailsController:Test()
	-- body
	print("asdfasdfasdfasdf")
end

function PropDetailsController:OnDestroy()
	-- body
	self.this = nil 
	self = nil
end