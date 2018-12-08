require "System.Global"

class("GetRuneController")

local Data = UTGData.Instance()
local Text = "Text"
local Image = "Image"
local Slider = "Slider"
local RectTrans = "RectTransform"

function GetRuneController:Awake(this)
	-- body
	self.this = this

	self.subPanel = self.this.transform
	self.tip = self.subPanel:Find("UseSuccessfully/ItemTip")
	self.title = self.subPanel:Find("Title/Text")
	self.camera = GameObject.Find("GameLogic"):GetComponent("Camera")

	for i = 1,self.subPanel:Find("UseSuccessfully/Panel").childCount do
		self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1).gameObject:SetActive(false)
	end
end

function GetRuneController:Start()
	-- body
    local btn = self.subPanel:Find("UseSuccessfully/R51140310"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    local fx = self.subPanel:Find("UseSuccessfully/R51140310"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
    for k = 0,btn.Length - 1 do
      self.subPanel:Find("UseSuccessfully/R51140310"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
    end
	  for k = 0,fx.Length - 1 do
	    fx[k]:Play()
	  end
    
end

function GetRuneController:ChangeTitle(text)
	-- body
	self.title:GetComponent(Text).text = text
end

function GetRuneController:UseSuccessfullyControl(rewardslist)
	--print("进入")
	local quality = 0
	local icon = ""
	for i = 1,self.subPanel:Find("UseSuccessfully/Panel").childCount do
		local itemName = ""
		local itemNum = 0
		local itemDesc = ""
		self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1).gameObject:SetActive(false)
		self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Skin").gameObject:SetActive(false)
		self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Hero").gameObject:SetActive(false)
		if i < ((#rewardslist)+1) then
			self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1).gameObject:SetActive(true)
			if rewardslist[i].IsRare ~= nil then
				if rewardslist[i].IsRare == true then
				    local btn = self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("R51140550"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
				    for k = 0,btn.Length - 1 do
				      self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("R51140550"):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
				    end				
				else
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("R51140550").gameObject:SetActive(false)
				end
			else
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("R51140550").gameObject:SetActive(false)
			end
			if rewardslist[i].Type == 4 then
				quality = Data.ItemsData[tostring(rewardslist[i].Id)].Quality
			elseif rewardslist[i].Type == 1 or rewardslist[i].Type == 2 then
				quality = 4
			elseif rewardslist[i].Type == 3 then
				quality = Data.RunesData[tostring(rewardslist[i].Id)].Level
			elseif rewardslist[i].Type == 6 then
				quality = 1
			end
			self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):GetComponent(Image).sprite = UITools.GetSprite("icon",quality)

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
			if  rewardslist[i].Type == 1 then
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Name"):GetComponent(Text).text = Data.RolesData[tostring(rewardslist[i].Id)].Name
				itemName = Data.RolesData[tostring(rewardslist[i].Id)].Name
				itemNum = 1
				itemDesc = Data.RolesData[tostring(rewardslist[i].Id)].Desc
				icon = Data.SkinsData[tostring(Data.RolesData[tostring(rewardslist[i].Id)].Skin)].Icon
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon").gameObject:SetActive(false)	--显示通用道具icon
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",icon)
				--self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Hero").gameObject:SetActive(true)
			elseif 	rewardslist[i].Type == 2 then
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Name"):GetComponent(Text).text = Data.SkinsData[tostring(rewardslist[i].Id)].Name
				itemName = Data.SkinsData[tostring(rewardslist[i].Id)].Name
				itemDesc = Data.SkinsData[tostring(rewardslist[i].Id)].Desc
				ItemNum = 1
				icon = Data.SkinsData[tostring(rewardslist[i].Id)].Icon
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon").gameObject:SetActive(false)	--显示通用道具icon
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",icon)

			elseif	rewardslist[i].Type == 3 then
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Name"):GetComponent(Text).text = Data.RunesData[tostring(rewardslist[i].Id)].Name
				itemName = Data.RunesData[tostring(rewardslist[i].Id)].Name
		        if Data.RunesDeck[tostring(rewardslist[i].Id)] ~= nil then
		          itemNum = Data.RunesDeck[tostring(rewardslist[i].Id)].Amount
		        else
		          itemNum = 0
		        end
				local attrs = UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",rewardslist[i].Id)
				local str = ""
				for i = 1,#attrs do
			        if i == #attrs then
			          str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr
			        else
			          str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr .. "\n"
			        end
				end
				itemDesc = str				
				icon = Data.RunesData[tostring(rewardslist[i].Id)].Icon
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon").gameObject:SetActive(false)
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",icon)
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(73,84.4)
			elseif rewardslist[i].Type == 6 then
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Name"):GetComponent(Text).text = Data.AvatarFramesData[tostring(rewardslist[i].Id)].Name
				itemName = Data.AvatarFramesData[tostring(rewardslist[i].Id)].Name
				itemNum = 1
				itemDesc = Data.AvatarFramesData[tostring(rewardslist[i].Id)].Desc
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("frameicon",Data.AvatarFramesData[tostring(rewardslist[i].Id)].Icon)
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image").gameObject:SetActive(false)
			else
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon").gameObject:SetActive(false)
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Name"):GetComponent(Text).text = Data.ItemsData[tostring(rewardslist[i].Id)].Name
				itemName = Data.ItemsData[tostring(rewardslist[i].Id)].Name
				local itemData = Data.ItemsData[tostring(rewardslist[i].Id)]
				if itemData.Type == 8 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Hero").gameObject:SetActive(true)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",
																												Data.SkinsData[tostring(Data.RolesData[tostring(itemData.Param[1][1])].Skin)].Icon)
					itemDesc = Data.RolesData[tostring(itemData.Param[1][1])].Desc
					itemNum = Data.ItemsDeck[tostring(rewardslist[i].Id)].Amount
				elseif itemData.Type == 7 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Skin").gameObject:SetActive(true)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",
																												Data.SkinsData[tostring(itemData.Param[1][1])].Icon)
					itemDesc = Data.SkinsData[tostring(itemData.Param[1][1])].Desc
					itemNum = Data.ItemsDeck[tostring(rewardslist[i].Id)].Amount
				elseif itemData.Type == 13 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(79.4,79.4)
					itemDesc = itemData.Desc
					itemNum = Data.PlayerData.Coin .. "个"
				elseif itemData.Type == 14 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(79.4,79.4)
					itemDesc = itemData.Desc
					itemNum = Data.PlayerData.Gem .. "个"
				elseif itemData.Type == 15 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(79.4,79.4)
					itemDesc = itemData.Desc
					itemNum = Data.PlayerData.Exp
				elseif itemData.Type == 23 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(79.4,79.4)
					itemDesc = itemData.Desc
					itemNum = Data.PlayerData.Voucher .. "个"					
				elseif itemData.Type == 17 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(79.4,79.4)
					itemNum = Data.PlayerData.RunePiece .. "个"
					itemDesc = itemData.Desc
				elseif itemData.Type == 20 then
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					itemNum = Data.PlayerData.DailyActivePoint
					itemDesc = itemData.Desc		
        elseif itemData.Type == 23 then --点券
          self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(info.Id)].Icon)
			    itemNum = Data.PlayerData.Voucher
			    itemDesc = itemData.Desc				
          self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(79.4,79.4)	
				else
					self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(rewardslist[i].Id)].Icon)
					itemDesc = itemData.Desc
					itemNum = Data.ItemsDeck[tostring(rewardslist[i].Id)].Amount
				end




				--icon = Data.ItemsData[tostring(rewardslist[i].Id)].Icon
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Icon").gameObject:SetActive(false)	--显示通用道具icon
				self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
			end

			--local itemName = Data.ItemsData[tostring(rewardslist[i].ItemId)].Name

			--[[
			local itemNum
			if rewardslist[i].Type == 13 then
				itemNum = Data.PlayerData.Coin .. "个"
			elseif rewardslist[i].Type == 14 then
				itemNum = Data.PlayerData.Gem .. "个"
			elseif rewardslist[i].Type == 15 then 
				itemNum = Data.PlayerData.Exp
			else
				itemNum = Data.ItemsDeck[tostring(rewardslist[i].ItemId)].Amount .. "个"
			end
			local itemDesc = Data.ItemsData[tostring(rewardslist[i].ItemId)].Desc
]]
			local listener = NTGEventTriggerProxy.Get(self.subPanel:Find("UseSuccessfully/Panel"):GetChild(i-1):Find("Image/Icon").gameObject)
			local callback = function(self,e)
				self:ShowTipsControl(itemName,itemNum,itemDesc)
			end
			listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)

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
    local function anonyFunc(args)
      self:DestroySelf()
    end
		
    UTGDataOperator.Instance:NewAchievePanelOpen(anonyFunc)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback3, self)

	self.subPanel:Find("UseSuccessfully/Panel").gameObject:SetActive(true)
end

function GetRuneController:ShowTipsControl(itemName,ownNum,desc)
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

function GetRuneController:DestroySelf()
	-- body
	GameObject.Destroy(self.this.transform.parent.gameObject)
	if EmailAPI ~= nil and EmailAPI.Instance ~= nil then
		if EmailAPI.Instance.controller.self.isQuickDraw == true then
			EmailAPI.Instance:QuickDraw()
		end
	end
end

function GetRuneController:OnDestroy()
	-- body
	self.this = nil
	self = nil
end