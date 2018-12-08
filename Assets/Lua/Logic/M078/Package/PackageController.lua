require "System.Global"
class("PackageController")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"

local json = require "cjson"

function  PackageController:Awake(this)
	-- body
	self.this = this
	self.leftTabs = self.this.transforms[0]
	self.mainLeft = self.this.transforms[1]
	self.mainRight = self.this.transforms[2]
	self.subPanel = self.this.transforms[3]
	self.nonePanel = self.this.transforms[4]

	self.tip = self.subPanel:Find("UseSuccessfully/ItemTip")
	self.lastSave = ""
	self.lastSelected = ""
	self.map = {}
	self.camera = GameObject.Find("GameLogic"):GetComponent("Camera")

	local listener = NTGEventTriggerProxy.Get(self.leftTabs:Find("Tab1/Text").gameObject)
	local callback = function(self, e)
		self:TabControl(1)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)	

	listener = NTGEventTriggerProxy.Get(self.leftTabs:Find("Tab2/Text").gameObject)
	local callback1 = function(self, e)
		self:TabControl(2)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)

	listener = NTGEventTriggerProxy.Get(self.leftTabs:Find("Tab3/Text").gameObject)
	local callback2 = function(self, e)
		self:TabControl(3)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback2, self)

	listener = NTGEventTriggerProxy.Get(self.leftTabs:Find("Tab4/Text").gameObject)
	local callback3 = function(self, e)
		self:TabControl(4)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback3, self)


end

function  PackageController:Start()
	-- body


	if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
		WaitingPanelAPI.Instance:DestroySelf()
	end
--[[
	self.notifyPlayerReward = DelegateFactory.TGNetService_NetEventHanlder_Self(self, PackageController.NotifyPlayerReward)
	TGNetService.GetInstance():AddEventHandler("NotifyRewards", self.notifyPlayerReward , 1)
	self.notifyShowTips = DelegateFactory.TGNetService_NetEventHanlder_Self(self, PackageController.NotifyShowTips)
	TGNetService.GetInstance():AddEventHandler("NotifyTips", self.notifyShowTips , 1)
	]]
end

function PackageController:TabControl(num)
	-- body
	if num == 1 then
		self.leftTabs:Find("Tab" .. num .. "/Click").gameObject:SetActive(true)
		self.leftTabs:Find("Tab" .. (num + 1) .. "/Click").gameObject:SetActive(false)
		self.leftTabs:Find("Tab" .. (num + 2) .. "/Click").gameObject:SetActive(false)
		self.leftTabs:Find("Tab" .. (num + 3) .. "/Click").gameObject:SetActive(false)
	elseif num == 2 then
		self.leftTabs:Find("Tab" .. num .. "/Click").gameObject:SetActive(true)
		self.leftTabs:Find("Tab" .. (num + 1) .. "/Click").gameObject:SetActive(false)
		self.leftTabs:Find("Tab" .. (num + 2) .. "/Click").gameObject:SetActive(false)
		self.leftTabs:Find("Tab" .. (num - 1) .. "/Click").gameObject:SetActive(false)
	elseif num == 3 then
		self.leftTabs:Find("Tab" .. num .. "/Click").gameObject:SetActive(true)
		self.leftTabs:Find("Tab" .. (num + 1) .. "/Click").gameObject:SetActive(false)
		self.leftTabs:Find("Tab" .. (num - 1) .. "/Click").gameObject:SetActive(false)
		self.leftTabs:Find("Tab" .. (num - 2) .. "/Click").gameObject:SetActive(false)
	elseif num == 4 then
		self.leftTabs:Find("Tab" .. num .. "/Click").gameObject:SetActive(true)
		self.leftTabs:Find("Tab" .. (num - 1) .. "/Click").gameObject:SetActive(false)
		self.leftTabs:Find("Tab" .. (num - 2) .. "/Click").gameObject:SetActive(false)
		self.leftTabs:Find("Tab" .. (num - 3) .. "/Click").gameObject:SetActive(false)
	end
	self.num = num
	self:TypeControl(self.num)

end

function PackageController:TypeControl(num)
	-- body
	self.value = {}
	if Data.ItemsDeck ~= nil then
		if num == 1 then
			self:GetListData(Data.ItemsDeck)
		else 
			for k,v in pairs(Data.ItemsDeck) do
				if Data.ItemsData[tostring(v.ItemId)].BagCategory == (num - 1) then
					table.insert(self.value,v)
				end
			end
			self:GetListData(self.value)
		end
	end
end

function PackageController:GetListData(map)
	-- body

	self.itemList = {}
	self.mapBackUp = UITools.CopyTab(map)
	self.map = UITools.CopyTab(map)

		for k,v in pairs(self.map) do

			if Data.ItemsData[tostring(self.map[k].ItemId)].BagCatefory ~= 4 then
				if self.map[k].Amount > Data.ItemsData[tostring(map[k].ItemId)].MaxStack then
			       local temp = ""
				   local amount = self.map[k].Amount
				   local x = math.floor(self.map[k].Amount / Data.ItemsData[tostring(self.map[k].ItemId)].MaxStack)
				   for i = 1,x do
				   		self.map[k].Amount = Data.ItemsData[tostring(self.map[k].ItemId)].MaxStack
				   		temp = UITools.CopyTab(self.map[k])
				   		table.insert(self.itemList,temp)
				   end
				   self.map[k].Amount = (amount - (Data.ItemsData[tostring(self.map[k].ItemId)].MaxStack) * x)
				   table.insert(self.itemList,self.map[k])
				else
					table.insert(self.itemList,self.map[k])
				end
			end
			
		end
	table.sort(self.itemList,function(a,b)
		-- body
		return a.ItemId < b.ItemId
	end)



	self:InitList()
end

function PackageController:InitList()
	-- body
  self.lastSelected = ""
  local length = self.mainLeft:Find("SC/Panel").childCount

  if length > 1 then
    for i = 2,length do
      Object.Destroy(self.mainLeft:Find("SC/Panel"):GetChild(i-1).gameObject)
    end
  end

  --print("bbb " .. self.mainLeft:Find("SC/Panel").childCount)

	for i = 1,#self.itemList do

		local go = GameObject.Instantiate(self.mainLeft:Find("SC/Panel/Image").gameObject)
		go:SetActive(true)
		go.transform:SetParent(self.mainLeft:Find("SC/Panel"))
		go.transform.localScale = Vector3.one
		go.transform.localPosition = Vector3.zero
		
		if Data.ItemsData[tostring(self.itemList[i].ItemId)].Type == 7 then
			go.transform:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleIcon",Data.ItemsData[tostring(self.itemList[i].ItemId)].Icon)
			go.transform:Find("IconFrame/Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(85.1,89.9)
			go.transform:Find("IconFrame/Icon").gameObject:SetActive(false)
			go.transform:Find("IconFrame/Image/Icon").gameObject:SetActive(true)
			go.transform:Find("Skin").gameObject:SetActive(true)
		elseif  Data.ItemsData[tostring(self.itemList[i].ItemId)].Type == 8 then
			go.transform:Find("IconFrame/Icon").gameObject:SetActive(false)
			go.transform:Find("IconFrame/Image/Icon").gameObject:SetActive(true)
			go.transform:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(self.itemList[i].ItemId)].Icon)
			go.transform:Find("Hero").gameObject:SetActive(true)
		elseif 	Data.ItemsData[tostring(self.itemList[i].ItemId)].Type == 12 then
			go.transform:Find("IconFrame/Icon").gameObject:SetActive(false)
			go.transform:Find("IconFrame/Image/Icon").gameObject:SetActive(true)
			go.transform:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",Data.ItemsData[tostring(self.itemList[i].ItemId)].Icon)
			go.transform:Find("IconFrame/Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(72.6,83.9)
		else
			go.transform:Find("IconFrame/Icon").gameObject:SetActive(true)
			go.transform:Find("IconFrame/Image/Icon").gameObject:SetActive(false)
			go.transform:Find("IconFrame/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(self.itemList[i].ItemId)].Icon)
		end
		go.transform.name = self.itemList[i].ItemId
		go.transform:Find("IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("icon",tostring(Data.ItemsData[tostring(self.itemList[i].ItemId)].Quality))
		go.transform:Find("Text"):GetComponent(Text).text = self.itemList[i].Amount
		go.transform:Find("Selected").gameObject:SetActive(false)
		--[[ 
		if i == 1 then
			print("111111111111111111")
			print(go.transform.name)
			go.transform:Find("Selected").gameObject:SetActive(true)
			self.lastSelected = go.transform
		end

		if i == 2 then
			print("222222222222")
			go.transform:Find("Selected").gameObject:SetActive(false)
		end

		if i == 3 then
			print("333333333333")
			go.transform:Find("Selected").gameObject:SetActive(false)
		end

		if i == 4 then
			print("444444444444")
			go.transform:Find("Selected").gameObject:SetActive(false)
		end
]]

		listener = NTGEventTriggerProxy.Get(go)
		local callback = function(self, e)
		    if self.lastSelected == "" then
		    	self.lastSelected = go.transform
		    	go.transform:Find("Selected").gameObject:SetActive(true)
		    else
		    	self.lastSelected:Find("Selected").gameObject:SetActive(false)
		    	self.lastSelected = go.transform
		    	go.transform:Find("Selected").gameObject:SetActive(true)
		    end
		    self.lastSave = self.itemList[i].ItemId
		    self.nextSave = nil
		    if (i+1) <= #self.itemList then
		    	self.nextSave = self.itemList[i+1].ItemId
		    end
		    self:PutItemInfo(self.itemList[i].ItemId)
		end
		listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)
	end

	self:DoChoseLastSelect()

end

function PackageController:DoChoseLastSelect()
	-- body
	coroutine.start(self.ChoseLastSelect,self)
end
function PackageController:ChoseLastSelect()
	-- body
	coroutine.step()
	if #self.itemList ~= 0 then
		self.mainRight.gameObject:SetActive(true)
		self.nonePanel.gameObject:SetActive(false)
		--print("self.lastSabve " .. self.lastSave .. " " .. self.mainLeft:Find("SC/Panel").childCount)
		if self.lastSave ~= "" then
			local flag = false
			for i = 1,self.mainLeft:Find("SC/Panel").childCount do
				--print("self.lastSabve " .. self.lastSave .. " " .. self.mainLeft:Find("SC/Panel"):GetChild(i-1).name)
				if self.mainLeft:Find("SC/Panel"):GetChild(i-1).name == tostring(self.lastSave) then
					self.mainLeft:Find("SC/Panel"):GetChild(i-1):Find("Selected").gameObject:SetActive(true)
					self.lastSelected = self.mainLeft:Find("SC/Panel"):GetChild(i-1)
					self:PutItemInfo(self.lastSave)
					flag = true
				end
			end

			if flag == false then
				if self.nextSave ~= nil then
					for i = 1,self.mainLeft:Find("SC/Panel").childCount do
						if self.mainLeft:Find("SC/Panel"):GetChild(i-1).name == tostring(self.nextSave) then
							self.mainLeft:Find("SC/Panel"):GetChild(i-1):Find("Selected").gameObject:SetActive(true)
							self.lastSelected = self.mainLeft:Find("SC/Panel"):GetChild(i-1)
							self:PutItemInfo(self.nextSave)
							flag = true
						end
					end
				end				
			end

			if flag == false then
				--print("aaa " .. self.itemList[1].ItemId .. " " .. #self.itemList .. " " .. self.mainLeft:Find("SC/Panel"):GetChild(self.mainLeft:Find("SC/Panel").childCount - #self.itemList).name)
				self:PutItemInfo(self.itemList[1].ItemId)
				self.mainLeft:Find("SC/Panel"):GetChild(self.mainLeft:Find("SC/Panel").childCount - #self.itemList):Find("Selected").gameObject:SetActive(true)
				self.lastSelected = self.mainLeft:Find("SC/Panel"):GetChild(self.mainLeft:Find("SC/Panel").childCount - #self.itemList)				
			end
		else
			self:PutItemInfo(self.itemList[1].ItemId)
			self.mainLeft:Find("SC/Panel"):GetChild(self.mainLeft:Find("SC/Panel").childCount - #self.itemList):Find("Selected").gameObject:SetActive(true)
			self.lastSelected = self.mainLeft:Find("SC/Panel"):GetChild(self.mainLeft:Find("SC/Panel").childCount - #self.itemList)
		end
	else
		self.mainRight.gameObject:SetActive(false)
		self.nonePanel.gameObject:SetActive(true)
	end	
end

function  PackageController:PutItemInfo(itemId)
	-- body
	
	--print("roleID " .. Data.ItemsData[tostring(itemId)].Type .. " " .. Data.ItemsData[tostring(itemId)].Icon)
	local info = self.mainRight:Find("InfoBase")
	local listener = nil
	local num = 0
	local amount = 0
	local listener = ""
	info:Find("TopFrame/Frame/Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(100,100)
	info:Find("TopFrame/Skin").gameObject:SetActive(false)
	info:Find("TopFrame/Hero").gameObject:SetActive(false)
	--item名称
	info:Find("TopFrame/Frame"):GetComponent(Image).sprite = UITools.GetSprite("icon",Data.ItemsData[tostring(itemId)].Quality)
	--info:Find("TopFrame/Frame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(itemId)].Icon)
	if Data.ItemsData[tostring(itemId)].Type == 7 then
		info:Find("TopFrame/Frame/Image/Icon"):GetComponent(Image).sprite= UITools.GetSprite("roleIcon",Data.ItemsData[tostring(itemId)].Icon)
		info:Find("TopFrame/Frame/Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(85.1,89.9)
		info:Find("TopFrame/Frame/Icon").gameObject:SetActive(false)		--隐藏道具用icon
		info:Find("TopFrame/Frame/Image/Icon").gameObject:SetActive(true)			--显示特殊道具用icon
		info:Find("TopFrame/Skin").gameObject:SetActive(true)
	elseif  Data.ItemsData[tostring(itemId)].Type == 8 then
		info:Find("TopFrame/Frame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(itemId)].Icon)
		info:Find("TopFrame/Frame/Icon").gameObject:SetActive(false)		--隐藏道具用icon
		info:Find("TopFrame/Frame/Image/Icon").gameObject:SetActive(true)			--显示特殊道具用icon
		info:Find("TopFrame/Hero").gameObject:SetActive(true)
	elseif 	Data.ItemsData[tostring(itemId)].Type == 12 then
		info:Find("TopFrame/Frame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",Data.ItemsData[tostring(itemId)].Icon)
		info:Find("TopFrame/Frame/Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(72.6,83.9)
		info:Find("TopFrame/Frame/Image/Icon").gameObject:SetActive(true)			--显示特殊道具用icon
		info:Find("TopFrame/Frame/Icon").gameObject:SetActive(false)		--隐藏道具用icon	
	else
		info:Find("TopFrame/Frame/Icon").gameObject:SetActive(true)		--显示道具用icon
		info:Find("TopFrame/Frame/Image/Icon").gameObject:SetActive(false)			--隐藏特殊道具用icon
		info:Find("TopFrame/Frame/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(itemId)].Icon)
	end
	info:Find("TopFrame/ItemName"):GetComponent(Text).text = Data.ItemsData[tostring(itemId)].Name
	for k,v in pairs(self.mapBackUp) do
		if v.ItemId == itemId then
			amount = v.Amount
		end
	end
	info:Find("TopFrame/Num"):GetComponent(Text).text = amount
	if Data.ItemsData[tostring(itemId)].Type == 12 then	--判断是否为芯片
		local runeId = Data.ItemsData[tostring(itemId)].Param[1][1]
		local attr = UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",runeId)
		local attrText = ""
		for i = 1,#attr do
			if attrText == "" then
				attrText = "+" .. attr[i].Attr .. " " .. attr[i].Des
			else
				attrText = attrText .. "\n" .. "+" .. attr[i].Attr .. " " .. attr[i].Des
			end
		end
		info:Find("MidFrame/Text"):GetComponent(Text).text = attrText
	else
		info:Find("MidFrame/Text"):GetComponent(Text).text = Data.ItemsData[tostring(itemId)].Desc
	end
	info:Find("PriceInfoBar/Panel/Num"):GetComponent(Text).text = Data.ItemsData[tostring(itemId)].SalePrice
	if Data.ItemsData[tostring(itemId)].SalePrice > 0 then
		info:Find("PriceInfoBar/Panel").gameObject:SetActive(true)
		info:Find("PriceInfoBar/Panel/Num"):GetComponent(Text).text = Data.ItemsData[tostring(itemId)].SalePrice
		info:Find("SellButton").gameObject:SetActive(true)
		info:Find("UseButton").localPosition = Vector3.New(93.3,info:Find("UseButton").localPosition.y,0)
		listener = NTGEventTriggerProxy.Get(info:Find("SellButton").gameObject)
		local callback = function(self, e)
			self.subPanel.parent.gameObject:SetActive(true)
			self:SubPanelControl("Sell",itemId)
		end
		listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)
	else
		info:Find("PriceInfoBar/Panel").gameObject:SetActive(false)
		info:Find("SellButton").gameObject:SetActive(false)
		info:Find("UseButton").localPosition = Vector3.New(0,info:Find("UseButton").localPosition.y,0)		
	end	
	listener = NTGEventTriggerProxy.Get(info:Find("UseButton").gameObject)
	local callback1 = function(self, e)
		if Data.ItemsData[tostring(itemId)].BatchUseFlag == true then
			self.subPanel.parent.gameObject:SetActive(true)
			self:SubPanelControl("Use",itemId)
		else
			local itemType = Data.ItemsData[tostring(itemId)].Type
			local isSend = true
			if itemType == 9 then
			    GameManager.CreatePanel("ChatHorn")
			    if ChatHornAPI ~= nil and ChatHornAPI.Instance ~= nil then
			      ChatHornAPI.Instance:Init("Big",itemId)
			    end
			    isSend = false
			elseif itemType == 10 then
			    GameManager.CreatePanel("ChatHorn")
			    if ChatHornAPI ~= nil and ChatHornAPI.Instance ~= nil then
			      ChatHornAPI.Instance:Init("Small",itemId)
			    end
			    isSend = false
			elseif itemType == 12 then
				UTGDataOperator.Instance.RunePanelEntrance = "PackagePanel"
				self:DoGoToRunePanel()
				isSend = false
			elseif itemType == 1 then
				self:DoGoToStorePanel()
				UTGDataTemporary.Instance().PartShopType = "hero"
				isSend = false
			elseif itemType == 2 then
				self:DoGoToStorePanel()
				UTGDataTemporary.Instance().PartShopType = "skin"
				isSend = false				
			end
			if isSend == true then
				UTGDataOperator.Instance:UseItem(itemId,1)
			end
		end
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)
	





end

function  PackageController:SubPanelControl(typeName,itemId)
	-- body

	if typeName == "Sell" then
		self.subPanel:Find("SellItemPanel").gameObject:SetActive(true)
		self.subPanel:Find("UseItemPanel").gameObject:SetActive(false)
		self.subPanel:Find("UseSuccessfully").gameObject:SetActive(false)
		self.subPanel:Find("Title/Text"):GetComponent(Text).text = "出售道具"
		self:SellControl(itemId)

	elseif typeName == "Use" then
		self.subPanel:Find("SellItemPanel").gameObject:SetActive(false)
		self.subPanel:Find("UseItemPanel").gameObject:SetActive(true)
		self.subPanel:Find("UseSuccessfully").gameObject:SetActive(false)
		self.subPanel:Find("Title/Text"):GetComponent(Text).text = "使用道具"
		self:UseControl(itemId)
	elseif typeName == "UseSuccessfully" then
		self.subPanel:Find("SellItemPanel").gameObject:SetActive(false)
		self.subPanel:Find("UseItemPanel").gameObject:SetActive(false)
		self.subPanel:Find("UseSuccessfully").gameObject:SetActive(true)
		self.subPanel:Find("Title/Text"):GetComponent(Text).text = "使用成功"
		--self:UseSuccessfullyControl(itemId)		
	end
end

function  PackageController:SellControl(itemId)
	-- body
	self.subPanel:Find("SellItemPanel/IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("icon",tostring(Data.ItemsData[tostring(itemId)].Quality))
	--self.subPanel:Find("SellItemPanel/IconFrame/Icon"):GetComponent(Image).sprite = UITools.GetSprite("icon",Data.ItemsData[tostring(itemId)].Icon)
	if Data.ItemsData[tostring(itemId)].Type == 7 then
		go.transform:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(itemId)].Icon)
		go.transform:Find("IconFrame/Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(85.1,89.9)
	elseif  Data.ItemsData[tostring(itemId)].Type == 8 then
		self.subPanel:Find("SellItemPanel/IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(itemId)].Icon)
	elseif 	Data.ItemsData[tostring(itemId)].Type == 12 then
		self.subPanel:Find("SellItemPanel/IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",Data.ItemsData[tostring(itemId)].Icon)
		self.subPanel:Find("SellItemPanel/IconFrame/Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(72.6,83.9)
	else	
		self.subPanel:Find("SellItemPanel/IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(itemId)].Icon)
	end
	self.subPanel:Find("SellItemPanel/ItemName"):GetComponent(Text).text = Data.ItemsData[tostring(itemId)].Name
	self.subPanel:Find("SellItemPanel/OwnNum/Text"):GetComponent(Text).text = Data.ItemsDeck[tostring(itemId)].Amount
	self.subPanel:Find("SellItemPanel/SellTitle/SellPrice"):GetComponent(Text).text = Data.ItemsData[tostring(itemId)].SalePrice
	self.subPanel:Find("SellItemPanel/Count/Count/Current"):GetComponent(Text).text = "1"
	local num = 1
	self.subPanel:Find("SellItemPanel/Count/Count/Max"):GetComponent(Text).text = Data.ItemsDeck[tostring(itemId)].Amount
	self.subPanel:Find("SellItemPanel/GetMoney/SellPrice"):GetComponent(Text).text = Data.ItemsData[tostring(itemId)].SalePrice
	local listener = NTGEventTriggerProxy.Get(self.subPanel:Find("SellItemPanel/Count/ReduceImage").gameObject)
	local callback = function(self, e)
		if num > 1 then
			num = num - 1
			self.subPanel:Find("SellItemPanel/Count/Count/Current"):GetComponent(Text).text = num
			self.subPanel:Find("SellItemPanel/GetMoney/SellPrice"):GetComponent(Text).text = num * Data.ItemsData[tostring(itemId)].SalePrice
		end
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)

	listener = NTGEventTriggerProxy.Get(self.subPanel:Find("SellItemPanel/Count/AddImage").gameObject)
	local callback1 = function(self, e)
		if num < Data.ItemsDeck[tostring(itemId)].Amount then
			num = num + 1
			self.subPanel:Find("SellItemPanel/Count/Count/Current"):GetComponent(Text).text = num
			self.subPanel:Find("SellItemPanel/GetMoney/SellPrice"):GetComponent(Text).text = num * Data.ItemsData[tostring(itemId)].SalePrice
		end
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)

	listener = NTGEventTriggerProxy.Get(self.subPanel:Find("SellItemPanel/Count/MaxButton").gameObject)
	local callback2 = function(self, e)
		self.subPanel:Find("SellItemPanel/Count/Count/Current"):GetComponent(Text).text = Data.ItemsDeck[tostring(itemId)].Amount
		self.subPanel:Find("SellItemPanel/GetMoney/SellPrice"):GetComponent(Text).text = Data.ItemsDeck[tostring(itemId)].Amount * Data.ItemsData[tostring(itemId)].SalePrice
		num = Data.ItemsDeck[tostring(itemId)].Amount
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback2, self)

	listener = NTGEventTriggerProxy.Get(self.subPanel:Find("SellItemPanel/CancelButton").gameObject)
	local callback3 = function(self, e)
		self.subPanel.parent.gameObject:SetActive(false)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback3, self)

	listener = NTGEventTriggerProxy.Get(self.subPanel:Find("SellItemPanel/ConfirmButton").gameObject)
	local callback4 = function(self, e)
		--出售道具
		self:SellItem(itemId,num)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback4, self)
end

function PackageController:UseControl(itemId)
	-- body
	self.subPanel:Find("UseItemPanel/IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("icon",tostring(Data.ItemsData[tostring(itemId)].Quality))
	--self.subPanel:Find("UseItemPanel/IconFrame/Icon"):GetComponent(Image).sprite = UITools.GetSprite("icon",Data.ItemsData[tostring(itemId)].Icon)
	if Data.ItemsData[tostring(itemId)].Type == 7 then
		self.subPanel:Find("UseItemPanel/IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(itemId)].Icon)
		self.subPanel:Find("UseItemPanel/IconFrame/Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(85.1,89.9)
	elseif  Data.ItemsData[tostring(itemId)].Type == 8 then
		self.subPanel:Find("UseItemPanel/IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(itemId)].Icon)
	elseif 	Data.ItemsData[tostring(itemId)].Type == 12 then
		self.subPanel:Find("UseItemPanel/IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",Data.ItemsData[tostring(itemId)].Icon)
		self.subPanel:Find("UseItemPanel/IconFrame/Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(72.6,83.9)
	else	
		self.subPanel:Find("UseItemPanel/IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(itemId)].Icon)
	end
	self.subPanel:Find("UseItemPanel/ItemName"):GetComponent(Text).text = Data.ItemsData[tostring(itemId)].Name
	self.subPanel:Find("UseItemPanel/OwnNum/Text"):GetComponent(Text).text = Data.ItemsDeck[tostring(itemId)].Amount
	self.subPanel:Find("UseItemPanel/Count/Count/Current"):GetComponent(Text).text = "1"
	local num = 1
	self.subPanel:Find("UseItemPanel/Count/Count/Max"):GetComponent(Text).text = Data.ItemsDeck[tostring(itemId)].Amount
	local listener = NTGEventTriggerProxy.Get(self.subPanel:Find("UseItemPanel/Count/ReduceImage").gameObject)
	local callback = function(self, e)
		if num > 1 then
			num = num - 1
			self.subPanel:Find("UseItemPanel/Count/Count/Current"):GetComponent(Text).text = num
		end
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)

	listener = NTGEventTriggerProxy.Get(self.subPanel:Find("UseItemPanel/Count/AddImage").gameObject)
	local callback1 = function(self, e)
		if num < Data.ItemsDeck[tostring(itemId)].Amount then
			num = num + 1
			self.subPanel:Find("UseItemPanel/Count/Count/Current"):GetComponent(Text).text = num
		end
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)

	listener = NTGEventTriggerProxy.Get(self.subPanel:Find("UseItemPanel/Count/MaxButton").gameObject)
	local callback2 = function(self, e)
		self.subPanel:Find("UseItemPanel/Count/Count/Current"):GetComponent(Text).text = Data.ItemsDeck[tostring(itemId)].Amount
		num = Data.ItemsDeck[tostring(itemId)].Amount
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback2, self)

	listener = NTGEventTriggerProxy.Get(self.subPanel:Find("UseItemPanel/ConfirmButton").gameObject)
	local callback3 = function(self, e)
		--使用道具
		UTGDataOperator.Instance.itemDataUpdate = false
		self.subPanel.parent.gameObject:SetActive(false)
		local isSend = true
		self.itemType = Data.ItemsData[tostring(itemId)].Type
		--print("self.itemType " .. self.itemType)
		if self.itemType == 1 then
		    --打开商场界面
		    return 0
		  elseif self.itemType == 2 then
		    --打开商城界面
		    return 0
		  elseif self.itemType == 3 then
		    if amount == Data.ItemsData[tostring(itemId)].Param[1] or (amount > Data.ItemsData[tostring(itemId)].Param[1]) then
		      --print("abc")
		    else
		      return 0
		    end
		  elseif self.itemType == 4 then
		    if amount == Data.ItemsData[tostring(itemId)].Param[1] or (amount > Data.ItemsData[tostring(itemId)].Param[1]) then
		      --print("abc")
		    else
		      return 0
		    end
		  elseif self.itemType == 5 then
		  elseif self.itemType == 6 then
		  elseif self.itemType == 7 then
		  elseif self.itemType == 8 then
		  elseif self.itemType == 9 then --大喇叭
		    GameManager.CreatePanel("ChatHorn")
		    if ChatHornAPI ~= nil and ChatHornAPI.Instance ~= nil then
		      ChatHornAPI.Instance:Init("Big",itemId)
		    end
		    isSend = false
		  elseif self.itemType == 10 then--小喇叭
		    GameManager.CreatePanel("ChatHorn")
		    if ChatHornAPI ~= nil and ChatHornAPI.Instance ~= nil then
		      ChatHornAPI.Instance:Init("Small",itemId)
		    end
		    isSend = false
		  elseif self.itemType == 11 then
		  elseif self.itemType == 12 then
		  end
		  if isSend == true then		
			UTGDataOperator.Instance:UseItem(itemId,num)
		  end
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback3, self)

	listener = NTGEventTriggerProxy.Get(self.subPanel:Find("UseItemPanel/CancelButton").gameObject)
	local callback4 = function(self, e)
		self.subPanel.parent.gameObject:SetActive(false)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback4, self)

end

function PackageController:UseSuccessfullyControl(rewardslist)
	local fx = self.subPanel:Find("UseSuccessfully/R51140310"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
	for i = 1,fx.Length-1 do
		fx[i]:Play()
	end

    local btn = self.subPanel:Find("UseSuccessfully/R51140310"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    for k = 0,btn.Length - 1 do
      self.subPanel:Find("UseSuccessfully/R51140310"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
    end

	for i = 1,self.subPanel:Find("UseSuccessfully/Panel").childCount do
		self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1).gameObject:SetActive(false)
		self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Skin").gameObject:SetActive(false)
		self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Hero").gameObject:SetActive(false)
		if i < ((#rewardslist)+1) then
			self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1).gameObject:SetActive(true)
			self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):GetComponent(Image).sprite = UITools.GetSprite("icon",Data.ItemsData[tostring(rewardslist[i].Id)].Quality)
			local num = 0
			--print("aaaaaaaaaaa " .. rewardslist[i].Amount)
			if rewardslist[i].Amount > 1000 and rewardslist[i].Amount < 1000000 then
				--print("11111")
				num = string.format("%.1f",(rewardslist[i].Amount/1000)) .. "K"
			elseif rewardslist[i].Amount > 1000000 then
				--print("22222")
				num = string.format("%.1f",(rewardslist[i].Amount/1000000)) .. "M"
			else
				--print("33333")
				num = rewardslist[i].Amount
			end

			self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Text"):GetComponent(Text).text = num
			--self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("icon",rewardslist[i].Icon)
			if rewardslist[i].Type == 4 then
				if Data.ItemsData[tostring(rewardslist[i].Id)].Type == 7 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(85.1,89.9)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon").gameObject:SetActive(false)	--显示通用道具icon
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Skin").gameObject:SetActive(true)
				elseif  Data.ItemsData[tostring(rewardslist[i].Id)].Type == 8 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon").gameObject:SetActive(false)	--显示通用道具icon
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
					--print("8 " .. rewardslist[i].Id)
					--print(Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Hero").gameObject:SetActive(true)
				elseif 	Data.ItemsData[tostring(rewardslist[i].Id)].Type == 12 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon").gameObject:SetActive(false)	--显示通用道具icon
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
					--print("12 " .. rewardslist[i].Id)
					--print(Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(72.6,83.9)
				elseif	Data.ItemsData[tostring(rewardslist[i].Id)].Type == 13 or Data.ItemsData[tostring(rewardslist[i].Id)].Type == 14 or Data.ItemsData[tostring(rewardslist[i].Id)].Type == 15 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon").gameObject:SetActive(false)	--显示通用道具icon
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
					--print("131415 " .. rewardslist[i].Id)
					--print(Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
				else
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon").gameObject:SetActive(true)	--显示通用道具icon
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject:SetActive(false)		--隐藏特殊道具icon
					--print("else " .. rewardslist[i].Id)
					--print(Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
				end
			end

			local itemName = Data.ItemsData[tostring(rewardslist[i].Id)].Name
			local itemNum
			if Data.ItemsData[tostring(rewardslist[i].Id)].Type == 13 then
				itemNum = Data.PlayerData.Coin .. "个"
			elseif Data.ItemsData[tostring(rewardslist[i].Id)].Type == 14 then
				itemNum = Data.PlayerData.Gem .. "个"
			elseif Data.ItemsData[tostring(rewardslist[i].Id)].Type == 15 then 
				itemNum = Data.PlayerData.Exp
			else
				itemNum = Data.ItemsDeck[tostring(rewardslist[i].Id)].Amount .. "个"
			end
			local itemDesc = Data.ItemsData[tostring(rewardslist[i].Id)].Desc

			local listener = NTGEventTriggerProxy.Get(self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject)
			local callback = function(self,e)
				self:ShowTipsControl(itemName,itemNum,itemDesc)
			end
			listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)

			listener = NTGEventTriggerProxy.Get(self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject)
			local callback1 = function(self,e)
				self.tip.gameObject:SetActive(false)
			end
			listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)
		end
	end

	--self.subPanel:Find("UseSuccessfully/ConfirmButton"):
	local listener = NTGEventTriggerProxy.Get(self.subPanel:Find("UseSuccessfully/ConfirmButton").gameObject)
	local callback3 = function(self, e)
		--使用道具
		self.subPanel.parent.gameObject:SetActive(false)
		self:TypeControl(self.num)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback3, self)
end

function PackageController:ShowTipsControl(itemName,ownNum,desc)
	-- body
	self.tip.gameObject:SetActive(true)
	local pos = self.camera:ScreenToWorldPoint(Input.mousePosition)
	--local pos = Input.mousePosition
	self.tip.position = Vector3.New(pos.x,pos.y,0)
	self.tip.localPosition = Vector3.New(self.tip.localPosition.x,self.tip.localPosition.y,0)
	self.tip:Find("Panel/ItemName"):GetComponent(Text).text = itemName
	self.tip:Find("Panel2/Own/OwnNum"):GetComponent(Text).text = ownNum
	self.tip:Find("Desc"):GetComponent(Text).text = desc
end


function PackageController:SellItem(itemId,amount,networkDelegate,networkDelegateSelf)
	-- body
	self.sellDelegate = networkDelegate
	self.sellDelegateSelf = networkDelegateSelf
	local SellItemRequest = NetRequest.New()
	SellItemRequest.Content = JObject.New(JProperty.New("Type", "RequestSaleItem"),
											JProperty.New("ItemId",itemId),
											JProperty.New("Amount",amount))
	SellItemRequest.Handler = TGNetService.NetEventHanlderSelf(PackageController.SellItemHandler, self)
	TGNetService.GetInstance():SendRequest(SellItemRequest)	
end
function  PackageController:SellItemHandler(e)
	-- body
	if e.Type == "RequestSaleItem" then
		local result = tonumber(e.Content:get_Item("Result"):ToString())
		if result == 1 then
			self.subPanel.parent.gameObject:SetActive(false)
			
			--GameManager.CreatePanel("SelfHideNotice")
			--if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
				--SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("出售成功")
			--end

			if self.sellDelegate ~= nil and self.sellDelegateSelf ~= nil then
				self.sellDelegate(self.sellDelegateSelf)
			end
		end
		return true
	end
	return false 
end

--[[

function PackageController:UseItem(itemId,amount,networkDelegateDelegate,networkDelegateSelf)
	-- body
	self.itemType = Data.ItemsData[tostring(itemId)].Type
	self.itemId = itemId
	print("id " .. Data.ItemsData[tostring(self.ItemId)].Param[1][1])
	print("self.itemType " .. self.itemType .. " " .. self.num)
	if self.itemType == 1 then
		--打开商场界面
		return 0
	elseif self.itemType == 2 then
		--打开商城界面
		return 0
	elseif self.itemType == 3 then
		if amount == Data.ItemsData[tostring(itemId)].Param[1] or (amount > Data.ItemsData[tostring(itemId)].Param[1]) then
			print("abc")
		else
			return 0
		end
	elseif self.itemType == 4 then
		if amount == Data.ItemsData[tostring(itemId)].Param[1] or (amount > Data.ItemsData[tostring(itemId)].Param[1]) then
			print("abc")
		else
			return 0
		end
	elseif self.itemType == 5 then
	elseif self.itemType == 6 then
	elseif self.itemType == 7 then
	elseif self.itemType == 8 then
	elseif self.itemType == 9 then
	elseif self.itemType == 10 then
	elseif self.itemType == 11 then
		print("CCCCCCCCCCCCCCCCCCCCCC")
	elseif self.itemType == 12 then
		--打开芯片装配界面
	end

	self.useItemDelegate = networkDelegate
	self.useItemDelegateSelf = networkDelegateSelf
	local UseItemRequest = NetRequest.New()
	print("itemId " .. itemId .. " " .. amount)

	UseItemRequest.Content = JObject.New(JProperty.New("Type", "RequestUseItem"),
											JProperty.New("ItemId",itemId),
											JProperty.New("Amount",amount))
	UseItemRequest.Handler = DelegateFactory.TGNetService_NetEventHanlder_Self(self,PackageController.UseItemHandler)
	TGNetService.GetInstance():SendRequest(UseItemRequest)
	
end
function PackageController:UseItemHandler(e)
	-- body
	if e.Type == "RequestUseItem" then
		print("AAAAAAAAAAAA")
		local result = e.Content:Value("System.Int32","Result")
		if result == 1 then
			if self.itemType == 5 then    --次数倍卡
				if Data.ItemsData[tostring(itemId)].Param[1] == 1 then   --经验	
					UTGDataOperator.Instance.TimesLimitDoubleMoney_Time = UTGDataOperator.Instance.TimesLimitDoubleMoney_Time + Data.ItemsData[tostring(itemId)].Param[2]
					UTGDataOperator.Instance.TimesLimitDoubleMoney_Rate = Data.ItemsData[tostring(itemId)].Param[3]
				elseif Data.ItemsData[tostring(itemId)].Param[1] == 2 then    --金币
					UTGDataOperator.Instance.TimesLimitDoubleEXP_Time = UTGDataOperator.Instance.TimesLimitDoubleEXP_Time + Data.ItemsData[tostring(itemId)].Param[2]
					UTGDataOperator.Instance.TimesLimitDoubleEXP_Rate = Data.ItemsData[tostring(itemId)].Param[3]			
				end
				GameManager.CreatePanel("SelfHideNotice")
				if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
					SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("使用成功")
				end
			elseif self.itemType == 6 then    		--限时倍卡
				if Data.ItemsData[tostring(itemId)].Param[1] == 2 then     --金币
					UTGDataOperator.Instance.HoursLimitDoubleMoney_Hour = Data.ItemsData[tostring(itemId)].Param[2]
					UTGDataOperator.Instance.HoursLimitDoubleMoney_Rate = Data.ItemsData[tostring(itemId)].Param[3]
				elseif Data.ItemsData[tostring(itemId)].Param[1] == 1 then     --经验
					UTGDataOperator.Instance.HoursLimitDoubleEXP_Hour = Data.ItemsData[tostring(itemId)].Param[2]
					UTGDataOperator.Instance.HoursLimitDoubleEXP_Rate = Data.ItemsData[tostring(itemId)].Param[3]			
				end
				GameManager.CreatePanel("SelfHideNotice")
				if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
					SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("使用成功")
				end
			elseif self.itemType == 7 then    --皮肤体验卡
				local isFirstSkin = true
				for k,v in pairs(Data.SkinsDeck) do
					if Data.ItemsData[tostring(self.itemId)].Param[1][1] == v.SkinId then
						isFirstSkin = false
					end
				end
				if isFirstSkin == true then
					print("打开获得新皮肤界面")
					self:TypeControl(self.num)
				end
			elseif self.itemType == 8 then     --英雄体验卡
				local isFirstRole = true
				for k,v in pairs(Data.SkinsDeck) do
					if Data.ItemsData[tostring(self.itemId)].Param[1][1] == v.RoleId then
						isFirstRole = false
					end
				end
				if isFirstRole == true then
					print("打开获得新英雄界面")
					self:TypeControl(self.num)
				end
			elseif self.itemType == 9 then    --大喇叭
			elseif self.itemType == 10 then    --小喇叭
			elseif self.itemType == 11 then     --宝箱
				print(self.itemType)
				PackageController.Test1(self,self.num)
			end

			if self.useItemDelegate ~= nil and self.useItemDelegateSelf ~= nil then
				self.useItemDelegate(self.useItemDelegateSelf)
			end



		end
		return true
	end
	return false
end

]]

--[[
function  PackageController:NotifyPlayerReward(e)
	-- body
	if e.Type == "NotifyRewards" then
		print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1")
		self.rewards = json.decode(e.Content:get_Item("Rewards"):ToString())
		if UTGDataOperator.Instance.itemType == 11 then
			self:SubPanelControl("UseSuccessfully",UTGDataOperator.Instance.itemId)
			self:UseSuccessfullyControl(self.rewards)
		elseif UTGDataOperator.Instance.itemType == 7 then
			self:SubPanelControl("UseSuccessfully",UTGDataOperator.Instance.itemId)
			self:UseSuccessfullyControl(self.rewards)
		elseif UTGDataOperator.Instance.itemType == 8 then
			self:SubPanelControl("UseSuccessfully",UTGDataOperator.Instance.itemId)
			self:UseSuccessfullyControl(self.rewards)			
		end
		return true
	end
	return false
end

function PackageController:NotifyShowTips(e)
	-- body
	if e.Type == "NotifyTips" then
		local str = tostring(e.Content:get_Item("Tips"):ToString())
		GameManager.CreatePanel("SelfHideNotice")
		if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
			SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice(str)
		end
		return true
	end
	return false
end
]]

function PackageController:DoGoToRunePanel()
  -- body
  coroutine.start(PackageController.GoToRunePanel, self) 
end

function PackageController:GoToRunePanel()
  -- body
  local async = GameManager.CreatePanelAsync("Rune")
  while async.Done == false do
    coroutine.wait(0.05)
  end
end

function PackageController:DoGoToStorePanel()
  -- body
  coroutine.start(PackageController.GoToStorePanel, self) 
end

function PackageController:GoToStorePanel()
  -- body
  local async = GameManager.CreatePanelAsync("Store")
  while async.Done == false do
    coroutine.wait(0.05)
  end
  if StoreCtrl ~= nil and StoreCtrl.Instance ~= nil then
  	StoreCtrl.Instance:GoToUI(2)
  	--GameManager.CreatePanel("PartShop")
  	--coroutine.yield(WaitForSeconds.New(0.05))
  	--StoreNewCtrl.Instance:ApiModelActive(false)
  end
end


function PackageController:DestroySelf()
	if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
		UTGMainPanelAPI.Instance:ShowSelf()
		--UTGMainPanelAPI.Instance:OpenMainPanelFX()
	end
	Object.Destroy(self.this.transform.parent.gameObject)
end

function PackageController:CloseSubPanel()
	-- body
	self.subPanel.parent.gameObject:SetActive(false)
end

function  PackageController:Test1(num)
	-- body
	--print("self.num" .. num)
end

function PackageController:BackInit()
	-- body
	self:TabControl(self.Num)
end

function PackageController:OnDestroy()
	-- body
	self.this = nil
	self = nil
end