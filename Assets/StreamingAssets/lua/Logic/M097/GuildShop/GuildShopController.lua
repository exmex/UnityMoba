require "System.Global"

class("GuildShopController")

local Data = UTGData.Instance()
local Text = "Text"
local Image = "Image"
local Slider = "Slider"
local RectTrans = "RectTransform"

local json = require "cjson"

function  GuildShopController:Awake(this)
	-- body
	self.this = this

	self.leftTab = self.this.transforms[0]
	self.rightPanel = self.this.transforms[1]
	self.buyItemPanel = self.this.transforms[2]
	self.propPart = self.this.transforms[3]
	self.buyPart = self.this.transforms[4]

	self.itemDark = self.rightPanel:Find("GuildShopPanel/Top/Base/ItemDark")
	self.iconFrameDark = self.rightPanel:Find("GuildShopPanel/Top/Base/IconFrameDark")


	self.guildShopTab = self.leftTab:Find("GuildShop")
	self.guildShopPanel = self.rightPanel:Find("GuildShopPanel")
	self.guildShopItemPanel = self.guildShopPanel:Find("ItemShop")
	self.guildShopItemPanelRefreshButton = self.guildShopItemPanel:Find("Bottom/BottomFrame/Button")
	self.guildShopSubTabItem = self.rightPanel:Find("GuildShopPanel/Top/Base/Item")
	self.guildShopSubTabIconFrame = self.rightPanel:Find("GuildShopPanel/Top/Base/IconFrame")
	self.itemList = {}
	for i = 1,self.guildShopItemPanel:Find("Mid/Panel").childCount do
		table.insert(self.itemList,self.guildShopItemPanel:Find("Mid/Panel"):GetChild(i-1))
	end

	self.guildShopIconFramePanel = self.guildShopPanel:Find("IconFrameShop")
	self.guildShopIconFrameTemp = self.guildShopIconFramePanel:Find("Mid/ScrollRect/Panel/Image")
	self.buyButton = self.buyPart:Find("Button1")
	self.cancelButton = self.buyPart:Find("Button")

	self.refreshTime = 0

	self.selectedIndex = 0

	self.guildShopType = ""

	self.itemDone = false
	self.iconFrameDone = false
	self.refreshDone = true
	self.colorFlag = "Yellow"

	self.guildShopItemPanel.gameObject:SetActive(false)
	self.guildShopIconFramePanel.gameObject:SetActive(false)

	local listener
	listener = NTGEventTriggerProxy.Get(self.itemDark.gameObject)
	local callbackTab1 = function(self, e)
		self:SubTabControl(1)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackTab1, self)

	listener = NTGEventTriggerProxy.Get(self.iconFrameDark.gameObject)
	local callbackTab2 = function(self, e)
		self:SubTabControl(2)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackTab2, self)
end

function GuildShopController:Start()
	-- body
	self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
	local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
	UTGDataOperator.Instance:SetResourceList(topAPI)
	topAPI:GoToPosition("GuildShopPanel")
	topAPI:ShowControl(3)
	topAPI:InitTop(self,self.DestroySelf,nil,nil,"战队商店")
	topAPI:InitResource(2)
	topAPI:HideSom("Button")
	GameManager.CreatePanel("Waiting")
	self:InitLoadData()
	self:GetGuildShopItemList()
	self:GetGuildShopIconFrameList()
	--self:SubTabControl(1)


end

function GuildShopController:TabControl(tabNum)
	if tabNum == 1 then
		for i = 1,self.leftTab.childCount do
			self.leftTab:GetChild(i-1):Find("liang").gameObject:SetActive(false)
			self.rightPanel:GetChild(i-1).gameObject:SetActive(false)
		end
		self.guildShopTab:Find("liang"):SetActive(true)
		self.guildShopPanel.gameObject:SetActive(false)
	end
end

function GuildShopController:SubTabControl(subTabNum)
		-- body
	if subTabNum == 1 then
		self.guildShopSubTabItem.gameObject:SetActive(true)
		self.guildShopSubTabIconFrame.gameObject:SetActive(false)
		self.guildShopItemPanel.gameObject:SetActive(true)
		self.guildShopIconFramePanel.gameObject:SetActive(false)
	elseif subTabNum == 2 then
		self.guildShopSubTabItem.gameObject:SetActive(false)
		self.guildShopSubTabIconFrame.gameObject:SetActive(true)
		self.guildShopItemPanel.gameObject:SetActive(false)
		self.guildShopIconFramePanel.gameObject:SetActive(true)		
	end
end

function GuildShopController:InitItemShop(map,leftTimes)
	-- body
	for k,v in pairs(map) do
		self.itemList[v.Index]:Find("Panel").gameObject:SetActive(true)
		self.itemList[v.Index]:Find("SoldOut").gameObject:SetActive(false)
		self.itemList[v.Index]:Find("Panel/Hero").gameObject:SetActive(false)
		self.itemList[v.Index]:Find("Panel/Skin").gameObject:SetActive(false)
		if v.CommodityType == 1 then
			local roleIcon = Data.SkinsData[tostring(Data.RolesData[tostring(v.CommodityId)].Skin)].Icon
			local roleName = Data.RolesData[tostring(v.CommodityId)].Name
			self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleIcon",roleIcon)
			self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(86.6,86)
			self.itemList[v.Index]:Find("Text"):GetComponent(Text).text = roleName
			self.itemList[v.Index]:Find("Panel/Frame"):GetComponent(Image).sprite = UITools.GetSprite("icon","1")
		elseif v.CommodityType == 2 then
			local skinIcon = Data.SkinsData[tostring(v.CommodityId)].Icon
			local skinName = Data.SkinsData[tostring(v.CommodityId)].Name
			self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleIcon",skinIcon)
			self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(86.6,86)
			self.itemList[v.Index]:Find("Text"):GetComponent(Text).text = skinName
			self.itemList[v.Index]:Find("Panel/Frame"):GetComponent(Image).sprite = UITools.GetSprite("icon","1")
		elseif v.CommodityType == 3 then
			local runeIcon = Data.RunesData[tostring(v.CommodityId)].Icon
			local runeName = Data.RunesData[tostring(v.CommodityId)].Name
			self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeIcon",runeIcon)
			self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(72.9,84.2)
			self.itemList[v.Index]:Find("Text"):GetComponent(Text).text = runeName
			self.itemList[v.Index]:Find("Panel/Frame"):GetComponent(Image).sprite = UITools.GetSprite("icon",Data.RunesData[tostring(v.CommodityId)].Level)
		elseif v.CommodityType == 4 then
			local itemData = Data.ItemsData[tostring(v.CommodityId)]
			local itemIcon = ""
			local itemName = itemData.Name
			if itemData.Type == 8 then
				self.itemList[v.Index]:Find("Panel/Hero").gameObject:SetActive(true)
				self.itemList[v.Index]:Find("Panel/Skin").gameObject:SetActive(false)
				--itemIcon = Data.SkinsData[tostring(Data.RolesData[tostring(itemData.Param[1][1])].Skin)].Icon
				itemIcon = itemData.Icon
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(86.6,86)
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleIcon",itemIcon)
			elseif itemData.Type == 7 then
				self.itemList[v.Index]:Find("Panel/Hero").gameObject:SetActive(false)
				self.itemList[v.Index]:Find("Panel/Skin").gameObject:SetActive(true)
				--itemIcon = Data.SkinsData[tostring(itemData.Param[1][1])].Icon
				itemIcon = itemData.Icon
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(86.6,86)
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleIcon",itemIcon)			
			elseif itemData.Type == 13 or itemData.Type == 14 or itemData.Type == 15 then
				itemIcon = itemData.Icon
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceIcon",itemIcon)
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(86.6,86)
			elseif itemData.Type == 17 then
				itemIcon = itemData.Icon
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemIcon",itemIcon)
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(86.6,86)
			elseif itemData.Type == 20 then
				itemIcon = itemData.Icon
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemIcon",itemIcon)
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(86.6,86)
			else
				itemIcon = itemData.Icon
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemIcon",itemIcon)
				self.itemList[v.Index]:Find("Panel/Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(87.6,92.6)				
			end
			self.itemList[v.Index]:Find("Panel/Frame"):GetComponent(Image).sprite = UITools.GetSprite("icon",itemData.Quality)
			self.itemList[v.Index]:Find("Text"):GetComponent(Text).text = itemName
		end
		self.itemList[v.Index]:Find("Price"):GetComponent(Text).text = v.Price
		if Data.PlayerData.GuildCoin >= v.Price	then	
			self.itemList[v.Index]:Find("Price"):GetComponent(Text).color = Color.New(255/255,199/255,3/255,1)
			self.colorFlag = "Yellow"
		else
			self.itemList[v.Index]:Find("Price"):GetComponent(Text).color = Color.New(255/255,107/255,105/255,1)
			self.colorFlag = "Red"
		end
		self.itemList[v.Index]:Find("Panel/Num"):GetComponent(Text).text = v.CommodityNum


		if v.IsSoldOut == false then
		  local listener
		  listener = NTGEventTriggerProxy.Get(self.itemList[v.Index].gameObject)
		  local callback = function(self, e)
		    --购买战队商品
		    self.guildShopType = "Item"
		    self.selectedIndex = v.Index
		    self:InitBuyItemFrame(v,1,v.Index)
		  end
		  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
		else
		  self.itemList[v.Index]:Find("Price"):GetComponent(Text).color = Color.New(128/255,128/255,128/255,1)
		  self.itemList[v.Index]:Find("Panel").gameObject:SetActive(false)
		  self.itemList[v.Index]:Find("SoldOut").gameObject:SetActive(true)
		  local listener
		  listener = NTGEventTriggerProxy.Get(self.itemList[v.Index].gameObject)
		  local callback = function(self, e)
		    --购买战队商品
		  end
		  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)		  
		end 
	end
	--self.guildShopItemPanel:Find("Bottom/BottomFrame/NextRefreshTime"):GetComponent(Text).text = Data.ConfigData["asdf"].String
	self.guildShopItemPanel:Find("Bottom/BottomFrame/LeftTimes"):GetComponent(Text).text = (10-leftTimes)
	  local listener
	  listener = NTGEventTriggerProxy.Get(self.guildShopItemPanelRefreshButton.gameObject)
	  local callbackRefresh = function(self, e)
	  		self.dialog = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
	    	if (10-leftTimes) > 0 then
	    	  local str = "显示一批新货物需要消耗" .. Data.GuildShopRefreshData[tostring(leftTimes+1)].GuildCoinPrice .. "战队币，是否继续（今日已刷新" .. leftTimes .. "次）？"
		      self.dialog:InitNoticeForNeedConfirmNotice("提示", str, false, "",2,false)
		      self.dialog:TwoButtonEvent("取消",self.dialog.DestroySelf, self.dialog,
		                              "确定",self.Refresh, self)
		      self.dialog:SetTextToCenter() 	    	
	    	else	  
		      self.dialog:InitNoticeForNeedConfirmNotice("提示", "已达到今日刷新次数上限", false, "" ,1 ,false)
		      self.dialog:OneButtonEvent("确定",self.dialog.DestroySelf, self.dialog)
		      self.dialog:SetTextToCenter()
	    	end
	  end
	  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackRefresh,self)
		self.itemDone = true
		if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil and self.refreshDone == false then
			self.refreshDone = true
			WaitingPanelAPI.Instance:DestroySelf()
		end		
end

function GuildShopController:InitIconFrame(list)
	-- body
	for i = 1,self.guildShopIconFramePanel:Find("Mid/ScrollRect/Panel").childCount-1 do
		GameObject.Destroy(self.guildShopIconFramePanel:Find("Mid/ScrollRect/Panel"):GetChild(i).gameObject)
	end

	for i = 1,#list do
		go = GameObject.Instantiate(self.guildShopIconFrameTemp.gameObject)
		go:SetActive(true)
		go.transform:SetParent(self.guildShopIconFramePanel:Find("Mid/ScrollRect/Panel"))
		go.transform.localScale = Vector3.one
		go.transform.localPosition = Vector3.zero

		go.transform:Find("SoldOut").gameObject:SetActive(false)
		go.transform:Find("IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("frameicon",Data.AvatarFramesData[tostring(list[i].CommodityId)].Icon)
		go.transform:Find("Text"):GetComponent(Text).text = Data.AvatarFramesData[tostring(list[i].CommodityId)].Name
		go.transform:Find("Price"):GetComponent(Text).text = list[i].Price
		if list[i].Price > Data.PlayerData.GuildCoin then
			go.transform:Find("Price"):GetComponent(Text).color = Color.New(255/255,107/255,105/255,1)
			self.colorFlag = "Yellow"
		else
			go.transform:Find("Price"):GetComponent(Text).color = Color.New(255/255,199/255,3/255,1)
			self.colorFlag = "Red"
		end

		local isOwnIconFrame = false
		if Data.PlayerAvatarFramesDeck[tostring(list[i].CommodityId)] ~= nil and Data.AvatarFramesData[tostring(list[i].CommodityId)].IsForever == true then
			isOwnIconFrame = true
		else
			isOwnIconFrame = false
		end

		if isOwnIconFrame == false then
		  local callback = function(self, e)
		    --购买战队商品
		    
		    self.guildShopType = "IconFrame"
		    self.selectedIndex = i
		    self:InitBuyItemFrame(list[i],2,i)
		  end
		  local uiClick = UITools.GetLuaScript(go.transform,"Logic.UICommon.UIClick")
		  uiClick:RegisterClickDelegate(self,callback)
		else
		  go.transform:Find("Price"):GetComponent(Text).color = Color.New(128/255,128/255,128/255,1)
		  go.transform:Find("IconFrame").gameObject:SetActive(false)
		  go.transform:Find("SoldOut").gameObject:SetActive(true)
		  local callback = function(self, e)
		    --购买战队商品
		  end
		  local uiClick = UITools.GetLuaScript(go.transform,"Logic.UICommon.UIClick")
		  uiClick:RegisterClickDelegate(self,callback)		  
		end			
	end

	self.iconFrameDone = true
	--self.guildShopIconFramePanel:Find("Bottom/BottomFrame/NextRefreshTime"):GetComponent(Text).text = Data.ConfigData["asdf"].String
end




function GuildShopController:InitBuyItemFrame(list,category,index)
	-- body
	local id = list.CommodityId
	local itemType = list.CommodityType
	self.buyItemPanel.gameObject:SetActive(true)
	self.propPart:Find("IconFrame/Image").gameObject:SetActive(true)
	self.propPart:Find("Skin").gameObject:SetActive(false)
	self.propPart:Find("Hero").gameObject:SetActive(false)
	if itemType == 4 then
		local itemData = Data.ItemsData[tostring(id)]
		self.propPart:Find("IconFrame/Image/Icon"):GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector2.New(100,100)
		self.propPart:Find("IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("icon",itemData.Quality)
		if itemData.Type == 8 then
			--local icon = Data.SkinsData[tostring(Data.RolesData[tostring(itemData.Param[1][1])].Skin)].Icon
			local icon = itemData.Icon
			self.propPart:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",icon)
			self.propPart:Find("Skin").gameObject:SetActive(false)
			self.propPart:Find("Hero").gameObject:SetActive(true)
		elseif itemData.Type == 7 then
			--local icon = Data.SkinsData[tostring(itemData.Param[1][1])].Icon
			local icon = itemData.Icon
			self.propPart:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",icon)
			self.propPart:Find("Skin").gameObject:SetActive(true)
			self.propPart:Find("Hero").gameObject:SetActive(false)
		else
			self.propPart:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",itemData.Icon)			
		end
		self.propPart:Find("LabName"):GetComponent(Text).text = itemData.Name
		if Data.ItemsDeck[tostring(id)] ~= nil then
			self.propPart:Find("LabOwn"):GetComponent(Text).text = Data.ItemsDeck[tostring(id)].Amount
		else
			self.propPart:Find("LabOwn"):GetComponent(Text).text = 0
		end
		self.propPart:Find("LabDes"):GetComponent(Text).text = itemData.Desc
	elseif itemType == 3 then
		local itemData = Data.RunesData[tostring(id)]
		self.propPart:Find("IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("icon",itemData.Level)
		self.propPart:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",itemData.Icon)
		self.propPart:Find("IconFrame/Image/Icon"):GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector2.New(73,84.4)
		self.propPart:Find("LabName"):GetComponent(Text).text = itemData.Name
		if Data.RunesDeck[tostring(id)] ~= nil then
			self.propPart:Find("LabOwn"):GetComponent(Text).text = Data.RunesDeck[tostring(id)].Amount
		else
			self.propPart:Find("LabOwn"):GetComponent(Text).text = 0
		end
		local attrs = UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",id)
		local str = ""
		for i = 1,#attrs do
			str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr .. "\n"
		end
		self.propPart:Find("LabDes"):GetComponent(Text).text = str
	elseif itemType == 6 then
		local iconFrameData = Data.AvatarFramesData[tostring(id)]
		self.propPart:Find("IconFrame/Image/Icon"):GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector2.New(100,100)
		self.propPart:Find("IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("frameicon",iconFrameData.Icon)
		self.propPart:Find("IconFrame/Image").gameObject:SetActive(false)
		self.propPart:Find("LabName"):GetComponent(Text).text = iconFrameData.Name
		if Data.PlayerAvatarFramesDeck[tostring(id)] ~= nil then
			self.propPart:Find("LabOwn"):GetComponent(Text).text = 1
		else
			self.propPart:Find("LabOwn"):GetComponent(Text).text = 0
		end
		self.propPart:Find("LabDes"):GetComponent(Text).text = ""
		self.propPart:Find("LabDes"):GetComponent(Text).text = iconFrameData.Desc
	end
	self.propPart:Find("Price"):GetComponent(Text).text = list.Price


	if list.Price > Data.PlayerData.GuildCoin then
		self.propPart:Find("Price"):GetComponent(Text).color = Color.New(255/255,107/255,105/255,1)
	elseif list.Price <= Data.PlayerData.GuildCoin then
		self.propPart:Find("Price"):GetComponent(Text).color = Color.New(255/255,199/255,3/255,1)
	end



	local listener
	listener = NTGEventTriggerProxy.Get(self.buyButton.gameObject)
	local callbackBuy = function(self, e)
	--购买
		self:GuildShopBuy(category,index)
		self.buyItemPanel.gameObject:SetActive(false)
	end 
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackBuy, self)

	listener = NTGEventTriggerProxy.Get(self.cancelButton.gameObject)
	local callbackClose = function(self, e)
	--购买
		self.buyItemPanel.gameObject:SetActive(false)
	end 
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackClose, self)

end

function GuildShopController:Refresh()
	-- body
	GameManager.CreatePanel("Waiting")
	self.refreshDone = false
	local refreshRequest = NetRequest.New()
	refreshRequest.Content = JObject.New(JProperty.New("Type","RequestRefreshGuildShop"))
	refreshRequest.Handler = TGNetService.NetEventHanlderSelf(GuildShopController.RefreshHandler,self)
	TGNetService.GetInstance():SendRequest(refreshRequest) 	
end
function GuildShopController:RefreshHandler(e)
	-- body
	if e.Type == "RequestRefreshGuildShop" then
		self.dialog:DestroySelf()
		local result = tonumber(e.Content:get_Item("Result"):ToString())
		if result == 1 then			
			self:GetGuildShopItemList()		
		else
			if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil and self.refreshDone == false then
				self.refreshDone = true
				WaitingPanelAPI.Instance:DestroySelf()
			end	
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("刷新失败")
		    end
		end
		return true
	end
	return false
end

function GuildShopController:GetGuildShopItemList()
	-- body
	local guildShopListRequest = NetRequest.New()
	guildShopListRequest.Content = JObject.New(JProperty.New("Type","RequestGuildCommodityList"),
										JProperty.New("Category",1))
	guildShopListRequest.Handler = TGNetService.NetEventHanlderSelf(GuildShopController.GetGuildShopItemListHandler,self)
	TGNetService.GetInstance():SendRequest(guildShopListRequest) 	
end
function GuildShopController:GetGuildShopItemListHandler(e)
	-- body
	if e.Type == "RequestGuildCommodityList" then
		local result = tonumber(e.Content:get_Item("Result"):ToString())
		if result == 1 then
			local commodities =	json.decode(e.Content:get_Item("Commodities"):ToString())
			local leftTimes = tonumber(e.Content:get_Item("ShopRefreshCount"):ToString())
			self:InitItemShop(commodities,leftTimes)
			
		elseif result == 3848 then
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
		    end				
		end
		return true
	end
	return false
end

function GuildShopController:GetGuildShopIconFrameList()
	-- body
	local guildShopListRequest = NetRequest.New()
	guildShopListRequest.Content = JObject.New(JProperty.New("Type","RequestGuildCommodityList"),
										JProperty.New("Category",2))
	guildShopListRequest.Handler = TGNetService.NetEventHanlderSelf(GuildShopController.GetGuildShopIconFrameListHandler,self)
	TGNetService.GetInstance():SendRequest(guildShopListRequest) 	
end
function GuildShopController:GetGuildShopIconFrameListHandler(e)
	-- body
	if e.Type == "RequestGuildCommodityList" then
		local result = tonumber(e.Content:get_Item("Result"):ToString())
		if result == 1 then
			local commodities =	json.decode(e.Content:get_Item("Commodities"):ToString())
			local leftTimes = tonumber(e.Content:get_Item("ShopRefreshCount"):ToString())
			self:InitIconFrame(commodities)
		elseif result == 3848 then
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
		    end				
		end
		return true
	end
	return false
end

function GuildShopController:GuildShopBuy(category,index)
	-- body
	local guildShopBuyRequest = NetRequest.New()
	guildShopBuyRequest.Content = JObject.New(JProperty.New("Type","RequestBuyGuildCommodity"),
										JProperty.New("Category",category),
										JProperty.New("Index",index))
	guildShopBuyRequest.Handler = TGNetService.NetEventHanlderSelf(GuildShopController.GetGuildShopBuyHandler,self)
	TGNetService.GetInstance():SendRequest(guildShopBuyRequest)	
end
function GuildShopController:GetGuildShopBuyHandler(e)
	-- body
	if e.Type == "RequestBuyGuildCommodity" then
		local result = tonumber(e.Content:get_Item("Result"):ToString())
		if result == 1 then
			if self.guildShopType == "Item" then
				self:GetGuildShopItemList()
			else
				self:GetGuildShopIconFrameList()
			end
		elseif result == 3859 then
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该商品已售完")
		    end
		elseif result == 3857 then
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队币不足")
		    end				
		end
		return true
	end
	return false
end

function GuildShopController:InitLoadData()
	-- body
	coroutine.start(GuildShopController.DoInitLoadData,self)
end
function GuildShopController:DoInitLoadData()
	-- body
	--GameManager.CreatePanel("Waiting")
	while (self.itemDone == false or self.iconFrameDone == false) do
		coroutine.step()
	end
	self:SubTabControl(1)
	
	if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
		WaitingPanelAPI.Instance:DestroySelf()
	end
end


function GuildShopController:DestroySelf()
	-- body
	GameObject.Destroy(self.this.transform.parent.gameObject)
end

function GuildShopController:OnDestroy()
	-- body
	self.this = nil
	self = nil
end