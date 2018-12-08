require "System.Global"

class("PVPMallController")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"

function PVPMallController:Awake(this)
	self.this = this
	self.leftPanel = self.this.transforms[0]
	self.rightPanel = self.this.transforms[1]
	self.button  = self.this.transforms[2]

	self.getedEquipFrame = {}
	self.tabs = {}
	for i = 1,6 do
		self.tabs[i] = self.leftPanel:Find("LeftFrame/LeftBottom/Tab" .. i)
		self.getedEquipFrame[i] = self.this.transform:Find("BottomPanel/Block" .. i)
	end
	self.equipPropertyPanel = self.rightPanel:Find("Middle/Desc/Mid/Panel")
	self.equipProperty = self.rightPanel:Find("Middle/Desc/Mid/Panel/Text")
	self.equipName = self.rightPanel:Find("Middle/Desc/Name/Value")
	self.equipPrice = self.rightPanel:Find("Middle/Desc/Image")
	self.GetedEquip = {}
	self.Money = 0
	self.CurrentPage = ""
  	self.tempEquipList = {}
  	self.CloseButton = self.this.transform:Find("Image")
  	self.NeedBuy = 0
  	self.openPanel = true
  	self.finishBuy = false
  	self.finishSell = false
  	self.isSend = 2
  	self.isBuy = false
  	self.needBuyBackUp = {}
  	self.notHave = {}
  	self.price = {}
  	self.backUp1 = ""
  	self.backUp2 = ""
  	self.backUpPrice1 = 0
  	self.backUpPrice2 = 0
  	self.canSend1 = true
  	self.canSend2 = true
  	self.dontBuy = false
  	self.subEquipTemp = {}
  	self.subEquipList = {}
 	self.subEquip1 = {}
	self.subEquip2 = {}
	self.GetedEquipNum = 0
	self.closePanelDelegate = ""
	self.currentMoney = self.leftPanel:Find("LeftFrame/LeftTop/Text"):GetComponent(Text)





--[[
	self.equipScrowRectTransform=self.this.transform:FindChild("Right/Middle/Mask/ScrollRect"):GetComponent("RectTransform")

  	self.NameP=self.this.transform:FindChild("Right/Middle/Desc/Name/Value")
  	self.AttributesP=self.this.transform:FindChild("Right/Middle/Desc/ScrollRect/Content/Attributes")
 	self.PassiveSkillsP=self.this.transform:FindChild("Right/Middle/Desc/ScrollRect/Content/PassiveSkills")
]]


  local listener = NTGEventTriggerProxy.Get(self.tabs[1].gameObject)
  local callback1 = function(self, e)
    self:TabControl(1)
    self:InitList(self.recommend)
    self.CurrentPage = self.recommend
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)

  listener = NTGEventTriggerProxy.Get(self.tabs[2].gameObject)
  local callback2 = function(self, e)
    self:TabControl(2)
    self:InitList(self.Equips[1])
    self.CurrentPage = self.Equips[1]
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback2,self)

  listener = NTGEventTriggerProxy.Get(self.tabs[3].gameObject)
  local callback3 = function(self, e)
    self:TabControl(3)
    self:InitList(self.Equips[2])
    self.CurrentPage = self.Equips[2]
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback3, self)

   listener = NTGEventTriggerProxy.Get(self.tabs[4].gameObject)
  local callback4 = function(self, e)
    self:TabControl(4)
    self:InitList(self.Equips[3])
    self.CurrentPage = self.Equips[3]
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback4, self)

   listener = NTGEventTriggerProxy.Get(self.tabs[5].gameObject)
  local callback5 = function(self, e)
    self:TabControl(5)
    self:InitList(self.Equips[4])
    self.CurrentPage = self.Equips[4]
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback5, self)

   listener = NTGEventTriggerProxy.Get(self.tabs[6].gameObject)
  local callback6 = function(self, e)
    self:TabControl(6)
    self:InitList(self.Equips[5])
    self.CurrentPage = self.Equips[5]
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback6, self)

  listener = NTGEventTriggerProxy.Get(self.CloseButton.gameObject)
  local callback7 = function(self, e)
  	self.this.transform.parent.localPosition = Vector3.New(-1290,0,0)
  	self.openPanel = false
  	self.this.transform.parent.gameObject:SetActive(false)
  	--self:ClosePanel(self.closePanelDelegate)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback7, self)




end

function  PVPMallController:Start()
	-- body
	self.Content = UITools.GetLuaScript(self.this.transform:FindChild("Panel/Right/Middle/Mask") ,
                                       "Logic.UICommon.UIShopEquipGroup")
	--self.this:StartCoroutine(NTGLuaCoroutine.New(self, PVPMallController.MoneyIncrease))

	--self:GetMallData(10000001)
	--self:ShowGetedEquip()

  	self.this.transform.parent.localPosition = Vector3.New(-1290,0,0)
  	self.openPanel = false
end

function  PVPMallController:TabControl(num)
	for i = 1,6 do
		self.leftPanel:Find("LeftFrame/LeftBottom/Tab" .. i .. "/Image").gameObject:SetActive(false)
	end
	self.leftPanel:Find("LeftFrame/LeftBottom/Tab" .. num .. "/Image").gameObject:SetActive(true)
end

function  PVPMallController:GetMallData(roleId)
	-- 获取推荐装备
	local pPrice = {}
	self.price = {}
	local temp = {}
	local isOwn = false
	self.forUpdate = {}
	self.recommendEquip = {}
	for k,v in pairs(Data.RolesDeck) do
		if Data.RolesDeck[k].RoleId == roleId then
			if Data.RolesDeck[k].BattleEquips ~= nil then
				temp = Data.RolesDeck[k].BattleEquips
			else
				temp = Data.RolesData[tostring(roleId)].BattleEquips
			end
			isOwn = true
		end
	end


	if isOwn == false then
		temp = Data.RolesData[tostring(roleId)].BattleEquips
	end

	for i = #temp,1,-1 do
		if temp[i] == -1 then
			table.remove(temp,i)
		end
	end

	self.forUpdate = UITools.CopyTab(temp)
	self.forBuyOrder = UITools.CopyTab(temp)

	for k,v in pairs(temp) do
		--print("kv " .. k .. " " .. v)
		if #Data.PVPMallsData[tostring(v)].PreEquips ~= 0 then
			for i = 1,#Data.PVPMallsData[tostring(v)].PreEquips do
				if #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(v)].PreEquips[i])].PreEquips ~= 0 then
					for m = 1,#Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(v)].PreEquips[i])].PreEquips do
						table.insert(self.recommendEquip,Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(v)].PreEquips[i])].PreEquips[m])])
					end
				end

					table.insert(self.recommendEquip, Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(v)].PreEquips[i])])
			end
		end
		table.insert(self.recommendEquip,Data.PVPMallsData[tostring(temp[k])])
	end

	self.recommendEquipQuality1 = {}
	self.recommendEquipQuality2 = {}
	self.recommendEquipQuality3 = {}

	table.sort( self.recommendEquip, function(a,b) return a.Id < b.Id end )

	local same = ""


	self.HeroRecommendEquip = {}
	
	for i = 1,#temp do
		if Data.PVPMallsData[tostring(temp[i])].Quality == 3 then
			table.insert(self.recommendEquipQuality3,Data.PVPMallsData[tostring(temp[i])])
		end
	end




	for i = 1,#self.recommendEquip do
		table.insert(self.HeroRecommendEquip,self.recommendEquip[i].EquipId)
		--table.insert(pPrice , Data.PVPMallsData[tostring(self.recommendEquip[i].EquipId)].Price)
		if i == 1 then
			if self.recommendEquip[i].Quality == 1 then
				table.insert(self.recommendEquipQuality1,self.recommendEquip[i])
			elseif self.recommendEquip[i].Quality == 2 then
				table.insert(self.recommendEquipQuality2,self.recommendEquip[i])
			end
			same = self.recommendEquip[i]
		else
			if same ~= self.recommendEquip[i] then
				if self.recommendEquip[i].Quality == 1 then
					table.insert(self.recommendEquipQuality1,self.recommendEquip[i])
				elseif self.recommendEquip[i].Quality == 2 then
					table.insert(self.recommendEquipQuality2,self.recommendEquip[i])
					--[[
				elseif self.recommendEquip[i].Quality == 3 then
					for k = 1,#temp do
						if Data.PVPMallsData[tostring(temp[k])].Quality == 3 then
							table.insert(self.recommendEquipQuality3,Data.PVPMallsData[tostring(temp[k])])
						end
					end
					]]
				end
				same = self.recommendEquip[i]
			end
		end
	end

	self:ReorderBuy()

	table.sort( self.recommendEquipQuality1, function(a,b) return a.Id < b.Id end )
	table.sort( self.recommendEquipQuality2, function(a,b) return a.Id < b.Id end )	
	--table.sort( self.recommendEquipQuality3, function(a,b) return a.Id < b.Id end )


	self.recommend = {self.recommendEquipQuality1,self.recommendEquipQuality2,self.recommendEquipQuality3}



	local count = 0
	for k,v in pairs(Data.EquipsData) do
		if Data.EquipsData[k].Type > count then
			count = Data.EquipsData[k].Type
		end
	end

	self.Equips = {}

	for i = 1,count do
		self.Equips[i] = {}
		for k = 1,3 do
			self.Equips[i][k] = {}
		end
	end

	--获取不同Type装备,并区分品阶
	for k,v in pairs(Data.PVPMallsData) do
		table.insert(self.Equips[Data.PVPMallsData[k].Type][Data.PVPMallsData[k].Quality],Data.PVPMallsData[k])
	end

	for i = 1,count do
		for k = 1,#self.Equips[i] do
			table.sort(self.Equips[i][k],function(a,b) return a.Id < b.Id end)
		end
	end


end

function  PVPMallController:InitList(tableWithTwo)
	self.rightPanel:Find("Middle/Scrollbar"):GetComponent("UnityEngine.UI.Scrollbar").value = 1
	self.rightPanel:Find("Middle/Desc").gameObject:SetActive(false)

	local forCompare = 0
    self.tempEquipList = {}
    self.selectedList = tableWithTwo

	self.Content:InitDrags(#tableWithTwo[1],#tableWithTwo[2],#tableWithTwo[3])
	for k,v in pairs(tableWithTwo) do
		for m,n in pairs(tableWithTwo[k]) do
			local price = 0
			local price2 = 0
			self.Content.drags[k][m].transform.name = n.EquipId
			self.Content.drags[k][m].transform:Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(n.EquipId)].Icon)
			self.Content.drags[k][m].transform:Find("Name"):GetComponent(Text).text = Data.EquipsData[tostring(n.EquipId)].Name
			self.Content.drags[k][m].transform:Find("Price"):GetComponent(Text).text = n.Price
			forCompare = n.Price
			self.subEquipList[tostring(n.EquipId)] = {}
			--[[
			if n.PreEquips[1] ~= nil then				
				for k = 1,#self.GetedEquip do
					if self.GetedEquip ~= nil then
						for i = 1,#n.PreEquips do
							if n.PreEquips[i] == self.GetedEquip[k] then
								price = price + Data.PVPMallsData[tostring(self.GetedEquip[k])].Price
								table.insert(self.subEquipList[tostring(n.EquipId)],tostring(self.GetedEquip[k]))
								--print("self.Content.drags[k][m] " .. self.Content.drags[k][m].transform.name)
								--self.Content.drags[k][m].transform:Find("Price"):GetComponent(Text).text = (n.Price - price)
								--self.Content.drags[k][m].transform:Find("Price"):GetComponent(Text).text = n.Price
								forCompare = n.Price - price
								break
							end
						end
					end
				end
			end
]]

--[[
			local getedTemp = UITools.CopyTab(self.GetedEquip)
			if #n.PreEquips ~= 0 then
				local tempLayer1 = UITools.CopyTab(n.PreEquips)
				for m = #tempLayer1,1,-1 do
					if #Data.PVPMallsData[tostring(tempLayer1[m])].PreEquips ~= 0 then
						local tempLayer2 = UITools.CopyTab(Data.PVPMallsData[tostring(tempLayer1[m])].PreEquips)
						for p = #tempLayer2,1,-1 do
							for j = #getedTemp,1,-1 do
								if tempLayer2[p] == getedTemp[j] then
									price = price + Data.PVPMallsData[tostring(getedTemp[j])].Price
									table.insert(self.subEquipList[tostring(n.EquipId)],tostring(getedTemp[j]))
									table.remove(getedTemp,j)
									forCompare = n.Price - price
									break				
								end
							end
							table.remove(tempLayer2,p)
						end

						for j = #getedTemp,1,-1 do
							if tempLayer1[m] == getedTemp[j] then
								price2 = price2 + Data.PVPMallsData[tostring(getedTemp[j])].Price
								if Data.PVPMallsData[tostring(tempLayer1[m])].Quality == 1 then
									table.insert(self.subEquipList[tostring(n.EquipId)],tostring(getedTemp[j]))
									forCompare = forCompare - price2
								else
									self.subEquipList[tostring(n.EquipId)] = {}
									table.insert(self.subEquipList[tostring(n.EquipId)],tostring(getedTemp[j]))
									forCompare = n.Price - price2
								end
							end			
						end

						if tempLayer1[m] == getedTemp[j] then
							price2 = price2 + Data.PVPMallsData[tostring(getedTemp[j])].Price
						end

					else
						for j = #getedTemp,1,-1 do
							if tempLayer1[m] == getedTemp[j] then
								price = price + Data.PVPMallsData[tostring(getedTemp[j])].Price
								table.insert(self.subEquipList[tostring(n.EquipId)],tostring(getedTemp[j]))
								table.remove(getedTemp,j)
								forCompare = n.Price - price
								break	
							end
						end
					end
					table.remove(tempLayer1,m)
				end
			end

]]

			local haveLayer1 = {}
			local haveLayer2 = {}
			local buy = {}
			local buiesSubLayer1 = {}
			local buiesSubLayer2 = {}
			local buiesSubLayer3 = {}
			local needDelete = {}
			local buiesSelf = ""

			if #Data.PVPMallsData[tostring(n.EquipId)].PreEquips ~= 0 then
				for i = #Data.PVPMallsData[tostring(n.EquipId)].PreEquips,1,-1 do
					if Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(n.EquipId)].PreEquips[i])].Quality == 1 then
						table.insert(buiesSubLayer1,Data.PVPMallsData[tostring(n.EquipId)].PreEquips[i])
					elseif Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(n.EquipId)].PreEquips[i])].Quality == 2 then
						table.insert(buiesSubLayer2,Data.PVPMallsData[tostring(n.EquipId)].PreEquips[i])
					end

					if #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(n.EquipId)].PreEquips[i])].PreEquips ~= 0 then
						for l = #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(n.EquipId)].PreEquips[i])].PreEquips,1,-1 do
							table.insert(buiesSubLayer1, Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(n.EquipId)].PreEquips[i])].PreEquips[l])
						end
					end
				end


				--if Data.PVPMallsData[tostring(equipId)].Quality == 2 then
					--buiesSelf = equipId
				--elseif Data.PVPMallsData[tostring(equipId)].Quality == 3 then
					--buiesSelf = equipId
				--end
			end

			--如果装备质量大于1，则判断是否存在配件




			--如果存在配件，则遍历已获得物品	
			for i = #self.GetedEquip,1,-1 do
				if Data.PVPMallsData[tostring(self.GetedEquip[i])].Quality == 1 then
					table.insert(haveLayer1,self.GetedEquip[i])
				elseif Data.PVPMallsData[tostring(self.GetedEquip[i])].Quality == 2 then
					table.insert(haveLayer2,self.GetedEquip[i])
				end
			end

			for i = #buiesSubLayer2,1,-1 do
				for l = #haveLayer2,1,-1 do
					if buiesSubLayer2[i] == haveLayer2[l] then
						for p = #Data.PVPMallsData[tostring(haveLayer2[l])].PreEquips,1,-1 do
							for o = #buiesSubLayer1,1,-1 do
								if buiesSubLayer1[o] == Data.PVPMallsData[tostring(haveLayer2[l])].PreEquips[p] then
									table.remove(buiesSubLayer1,o)
									break
								end
							end 
						end
						table.insert(needDelete,buiesSubLayer2[i])
						table.insert(self.subEquipList[tostring(n.EquipId)],tostring(haveLayer2[l]))
						price = price + Data.PVPMallsData[tostring(haveLayer2[l])].Price
						table.remove(haveLayer2,l)
						table.remove(buiesSubLayer2,i)
						break
					end
				end
			end

			if #buiesSubLayer2 == 0 and #buiesSubLayer1 ~= 0 then
				for i = #buiesSubLayer1,1,-1 do
					for l = #haveLayer1,1,-1 do
						if buiesSubLayer1[i] == haveLayer1[l] then
							table.insert(needDelete,buiesSubLayer1[i])
							table.insert(self.subEquipList[tostring(n.EquipId)],tostring(haveLayer1[l]))
							price = price + Data.PVPMallsData[tostring(haveLayer1[l])].Price
							table.remove(haveLayer1,l)
							table.remove(buiesSubLayer1,i)
							break
						end
					end
				end
			end 

			local tempHaveLayer1 = {}	--避免在一个层级中重复计算已有1级装备，对haveLayer1做一个拷贝
			if #buiesSubLayer2 ~= 0 then	--假如2级装备不全，则对没有的2级装备进行处理
				for i = #buiesSubLayer2,1,-1 do
					tempHaveLayer1 = {}
					tempHaveLayer1 = UITools.CopyTab(haveLayer1)
					if #Data.PVPMallsData[tostring(buiesSubLayer2[i])].PreEquips ~= 0 then
						--print("dfdfd " .. #Data.PVPMallsData[tostring(buiesSubLayer2[i])].PreEquips .. " " .. buiesSubLayer2[i])
						for l = #Data.PVPMallsData[tostring(buiesSubLayer2[i])].PreEquips,1,-1 do
							--print("abdc " .. Data.PVPMallsData[tostring(buiesSubLayer2[i])].PreEquips[k] .. #tempHaveLayer1)
							for u = #tempHaveLayer1,1,-1 do
								if Data.PVPMallsData[tostring(buiesSubLayer2[i])].PreEquips[l] == tempHaveLayer1[u] then
									table.insert(needDelete,tempHaveLayer1[u])
									--print("AAAAAAA AAAAAAAAA " .. tempHaveLayer1[m])
									for p = #buiesSubLayer1,1,-1 do
										if buiesSubLayer1[p] == tempHaveLayer1[u] then
											table.remove(buiesSubLayer1,p)
											break
										end
									end
									table.insert(self.subEquipList[tostring(n.EquipId)],tostring(haveLayer1[u]))
									price = price + Data.PVPMallsData[tostring(haveLayer1[u])].Price
									table.remove(haveLayer1,u)
									table.remove(tempHaveLayer1,u)

									break
								end
							end
						end
					end
				end

				--if #buiesSubLayer3 ~= 0 then
					for i = #buiesSubLayer1,1,-1 do
						for l = #haveLayer1,1,-1 do
							if buiesSubLayer1[i] == haveLayer1[l] then
								table.insert(needDelete,haveLayer1[l])
								table.insert(self.subEquipList[tostring(n.EquipId)],tostring(haveLayer1[l]))
								price = price + Data.PVPMallsData[tostring(haveLayer1[l])].Price
								table.remove(haveLayer1,l)
								table.remove(buiesSubLayer1,i)
								break					
							end
						end
					end
				--end
			end

			forCompare = Data.PVPMallsData[tostring(n.EquipId)].Price - price



			self.Content.drags[k][m].transform:Find("Price"):GetComponent(Text).text = forCompare



			if forCompare > self.Money then
				self.Content.drags[k][m].transform:Find("Icon"):GetComponent(Image).color = Color.New(94/255,94/255,94/255,1)
			end

			if self.GetedEquip ~= nil then
				for i = 1,#self.GetedEquip do
					if self.GetedEquip[i] == n.EquipId then
						self.Content.drags[k][m].transform:Find("Own").gameObject:SetActive(true)
						self.Content.drags[k][m].transform:Find("Icon"):GetComponent(Image).color = Color.New(1,1,1,1)
					end
				end
			end
			self.forCompare = forCompare

			local data = UITools.GetLuaScript(self.Content.drags[k][m].gameObject,"Logic.UICommon.UIShopEquipData")
			data.selfId = n.EquipId
			if n.PreEquips ~= nil then
				data.lIds = n.PreEquips
			end

			local temp = UTGDataOperator.Instance:FindNode(n)

			if temp ~= nil then
				data.rIds = temp
			end

			data.dataTable = n

			self.selectedEquip = ""
			self.Content.drags[k][m].transform:Find("Selected").gameObject:SetActive(false) 
		    local callback = function()
		      self.selectedEquipId=n.EquipId
		      self.buyPrice = tonumber(self.Content.drags[k][m].transform:Find("Price"):GetComponent(Text).text)
		      self.selectedEquip = self.Content.drags[k][m].transform
		      self:GetEquipInfo(self.selectedEquipId)
		      self:ShowPriceForBuy(n.EquipId)

				for k,v in pairs(tableWithTwo) do
					for m,n in pairs(tableWithTwo[k]) do
						self.Content.drags[k][m].transform:Find("Selected").gameObject:SetActive(false)
					end
				end
				self.Content.drags[k][m].transform:Find("Selected").gameObject:SetActive(true) 
				self.rightPanel:Find("Middle/Desc/ButtonInside").gameObject:SetActive(true)
				self.rightPanel:Find("Middle/Desc/ButtonSell").gameObject:SetActive(false)

				for i = 1,#self.getedEquipFrame do
					self.getedEquipFrame[i]:Find("Selected").gameObject:SetActive(false)
				end

		    end
		    local uiClick=UITools.GetLuaScript(self.Content.drags[k][m].gameObject,"Logic.UICommon.UIClick")  
		    uiClick:RegisterClickDelegate(self,callback)			

      	table.insert(self.tempEquipList,self.Content.drags[k][m].transform)
		end
	end
end

--用于每秒更新列表中可以购买的装备的图标的灰度
function  PVPMallController:InitListForUpdate()
  for i = 1,#self.tempEquipList do
  	self.tempEquipList[i].transform:Find("Own").gameObject:SetActive(false)

    if tonumber(self.tempEquipList[i]:Find("Price"):GetComponent(Text).text) < self.Money then
      self.tempEquipList[i]:Find("Icon"):GetComponent(Image).color = Color.New(1,1,1,1)
  	elseif  tonumber(self.tempEquipList[i]:Find("Price"):GetComponent(Text).text) > self.Money then
  	  self.tempEquipList[i]:Find("Icon"):GetComponent(Image).color = Color.New(0.4,0.4,0.4,1)
      --[[
		if self.GetedEquip ~= nil then
			for k = 1,#self.GetedEquip do
				if Data.EquipsData[tostring(self.GetedEquip[k])].Name == self.tempEquipList[i]:Find("Name"):GetComponent(Text).text then
					self.tempEquipList[i].transform:Find("Own").gameObject:SetActive(true)
				end
			end
		end
		]]
    end
   	for k = 1,#self.GetedEquip do
  		if self.GetedEquip[k] == tonumber(self.tempEquipList[i].name) then
  			self.tempEquipList[i]:Find("Icon"):GetComponent(Image).color = Color.New(1,1,1,1)
  			self.tempEquipList[i]:Find("Own").gameObject:SetActive(true)
  		end
  	end
  end
end

function PVPMallController:GetEquipInfo(equipId)
  --清除上一次生成的属性列表
  local length = self.equipPropertyPanel.childCount
  if length > 1 then
    for i = 2,length do
      Object.Destroy(self.equipPropertyPanel:GetChild(i-1).gameObject)
    end
  end

  self.rightPanel:Find("Middle/Desc").gameObject:SetActive(true)
  
  local properties = UTGDataOperator.Instance:GetSortedPropertiesByKey("Equip",equipId)
  local skill = Data.EquipsData[tostring(equipId)].PassiveSkills
  local skillDesc = {}
  local desc = ""
  if skill ~= nil then
    for i = 1,#skill do
      --table.insert(skillDesc,Data.SkillsData[tostring(skill[i])].Desc)
      desc = desc .. "\n" .. Data.SkillsData[tostring(skill[i])].Desc
    end
  end
  
  
  for i = 1,#properties + 1 do
  	if i == (#properties + 1) then
     	local go = GameObject.Instantiate(self.equipProperty.gameObject)
    	go:SetActive(true)
    	go.transform:SetParent(self.equipPropertyPanel)
    	go.transform.localScale = Vector3.one
    	go.transform.localPosition = Vector3.zero
    	go.transform:GetComponent(Text).text = desc
   	else
   		local go = GameObject.Instantiate(self.equipProperty.gameObject)
    	go:SetActive(true)
    	go.transform:SetParent(self.equipPropertyPanel)
    	go.transform.localScale = Vector3.one
    	go.transform.localPosition = Vector3.zero
    	go.transform:GetComponent(Text).text = "+" .. properties[i].Attr .. "  " .. properties[i].Des
  	end


  end

  local weight = 0
  weight = (#properties) * 40 + self.equipPropertyPanel:GetChild(#properties):GetComponent(RectTrans).sizeDelta.y

  --设置equipinfo面板长度
  self.equipPropertyPanel:GetComponent(RectTrans).sizeDelta = Vector2.New(self.equipPropertyPanel:GetComponent(RectTrans).sizeDelta.x,
  																				weight + 40)


  self.equipName:GetComponent(Text).text = Data.EquipsData[tostring(equipId)].Name
  --设置被动技能框位置

  --local py = self.equipPropertyPanel.localPosition.y - (25 * (#properties + 1)) - self.equipSkill:GetComponent(RectTrans).sizeDelta.y / 2
  --self.equipSkill.localPosition = Vector3.New(self.equipSkill.localPosition.x,py,0 )
  --self.equipSkill:GetComponent(Text).text = desc
  --self.equipPrice:GetComponent(Text).text = Data.PVPMallsData[tostring(equipId)].Price
end

function  PVPMallController:ShowGetedEquip()
	if self.GetedEquip ~= nil then
		for i = 1,#self.GetedEquip do
			self.getedEquipFrame[i]:Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(self.GetedEquip[i])].Icon)
			self.getedEquipFrame[i]:Find("Icon").gameObject:SetActive(true)
	      local listener = NTGEventTriggerProxy.Get(self.getedEquipFrame[i]:Find("Icon").gameObject)
	      local callback = function(self, e)
	      	for k = 1,#self.getedEquipFrame do
	      		self.getedEquipFrame[k]:Find("Selected").gameObject:SetActive(false)
	      	end
	      	self.rightPanel:Find("Middle/Scrollbar"):GetComponent("UnityEngine.UI.Scrollbar").value = 1

	      	self.selectGetedEquip = self.GetedEquip[i]
	        self:GetLineByGetedEquip(self.GetedEquip[i])
	        self:ShowSellInfo(self.GetedEquip[i])
	      	self.getedEquipFrame[i]:Find("Selected").gameObject:SetActive(true)
	      end
	      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)
		end
	end

	if #self.GetedEquip < 6 then
		for i = 1,6 do
			if i > #self.GetedEquip then
				self.getedEquipFrame[i]:Find("Icon").gameObject:SetActive(false)
			end
		end
	end
end

function PVPMallController:GetLineByGetedEquip(equipId)
  self:InitList(self.Equips[Data.EquipsData[tostring(equipId)].Type])
  self:TabControl(Data.EquipsData[tostring(equipId)].Type + 1)
  for i = 1,#self.tempEquipList do
    if self.tempEquipList[i]:Find("Name"):GetComponent(Text).text == Data.EquipsData[tostring(equipId)].Name then
      local uiClick=UITools.GetLuaScript(self.tempEquipList[i].gameObject,"Logic.UICommon.UIClick");  
      uiClick:ExecuteClickDelegate()
      self.selectedEquip:Find("Selected").gameObject:SetActive(false)
      break
    end
  end
  self:GetEquipInfo(equipId)
  
end

function  PVPMallController:ShowPriceForBuy(equipId)
	-- body
	for i = 1,#self.tempEquipList do
		if self.tempEquipList[i]:Find("Name"):GetComponent(Text).text == Data.EquipsData[tostring(equipId)].Name then
			self.rightPanel:Find("Middle/Desc/Image/Text"):GetComponent(Text).text = self.tempEquipList[i]:Find("Price"):GetComponent(Text).text
			self.rightPanel:Find("Middle/Desc/ButtonInside").gameObject:SetActive(true)
			if self.Money < tonumber(self.tempEquipList[i]:Find("Price"):GetComponent(Text).text) then
				self.rightPanel:Find("Middle/Desc/ButtonInside"):GetComponent(Image).color = Color.New(94/255,94/255,94/255,1)
				self.rightPanel:Find("Middle/Desc/ButtonMask").gameObject:SetActive(true)
				self.rightPanel:Find("Middle/Desc/ButtonInside/Text"):GetComponent(Text).color = Color.New(94/255,94/255,94/255,1)
			else
				self.rightPanel:Find("Middle/Desc/ButtonInside"):GetComponent(Image).color = Color.New(1,1,1,1)
				self.rightPanel:Find("Middle/Desc/ButtonInside/Text"):GetComponent(Text).color = Color.New(1,1,1,1)
				self.rightPanel:Find("Middle/Desc/ButtonMask").gameObject:SetActive(false)				
			end
		end
	end
end

function  PVPMallController:ShowSellInfo(equipId)
	-- body
	self.rightPanel:Find("Middle/Desc/ButtonInside").gameObject:SetActive(false)
	self.rightPanel:Find("Middle/Desc/ButtonSell").gameObject:SetActive(true)
	self.sellPrice = Data.PVPMallsData[tostring(equipId)].Price * 0.6
	self.rightPanel:Find("Middle/Desc/Image/Text"):GetComponent(Text).text = self.sellPrice

end

function  PVPMallController:BuyEquip(delegate)
	--将购买到的物品ID添加到self.GetedEquip，并进行排列
  	--如果成功更新一遍当前的装备列表
  self.buyDelegate = delegate
  local listener = NTGEventTriggerProxy.Get(self.rightPanel:Find("Middle/Desc/ButtonInside").gameObject);
  listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()

        for i = #self.subEquipList[tostring(self.selectedEquipId)],1,-1 do
          self.this:InvokeDelegate(self.sellDelegate,self.subEquipList[tostring(self.selectedEquipId)][i],0)
        end
      	if delegate ~= nil then
      		self.finishBuy = false
          self.finishBuy = self.this:InvokeDelegate(delegate,tostring(self.selectedEquipId),self.buyPrice)


          if self.finishBuy == true then
          	--print("购买成功")
          	self:UpdateGetedEquip(self.selectedEquipId,"Buy")
          else
          	--print("购买失败")
          end
      	end
      end  
    , self)
end

function  PVPMallController:BuyEquipOutside(equipId,buyCount,price)
	-- body
	self.BuiedEquipId = equipId
	if buyCount == 1 then
		if self.subEquip1[tostring(equipId)] ~= nil then
			for i = #self.subEquip1[tostring(equipId)],1,-1 do
				--print("11111111 " .. self.subEquip1[tostring(equipId)][i])
				self.this:InvokeDelegate(self.sellDelegate,self.subEquip1[tostring(equipId)][i],0)
			end
		end
	else
		if self.subEquip2[tostring(equipId)] ~= nil then
			for i = #self.subEquip2[tostring(equipId)],1,-1 do
				self.this:InvokeDelegate(self.sellDelegate,self.subEquip2[tostring(equipId)][i],0)
			end
		end
	end
	self.finishBuy = false
	self.finishBuy = self.this:InvokeDelegate(self.buyDelegate,tostring(equipId),price)
	if self.finishBuy == true then
		--print("购买成功")
		self:UpdateGetedEquip(equipId,"Buy")
	else
		--print("购买失败")
	end
end

function  PVPMallController:UpdateGetedEquip(equipId,actType)
	-- body
	self.isBuy = true
	if actType == "Buy" then
		self:GetHighDeleteLow(equipId)
		if #self.GetedEquip < 6 then
			table.insert(self.GetedEquip,equipId)
		end
	elseif actType == "Sell" then
		--self:SellControl(equipId)
		for i = 1,#self.GetedEquip do
			if self.GetedEquip[i] == equipId then
				table.remove(self.GetedEquip,i)
				break
			end
		end

		for i = 1,#self.getedEquipFrame do
			self.getedEquipFrame[i]:Find("Selected").gameObject:SetActive(false)
		end

	end

	self:ReorderBuy()
	if self.openPanel == true then
		self:InitList(self.selectedList)
	end
	self:ShowGetedEquip()
	self:UpdateBuyPrice(equipId)
	
end

function PVPMallController:SellEquip(delegate)
	-- body 
	--讲出售的物品ID从self.GetedEquip中去除，重新排列，并重新执行一次self:ShowGetedEquip()
	--如果成功更新一遍当前的装备列表
	self.sellDelegate = delegate
  local listener = NTGEventTriggerProxy.Get(self.rightPanel:Find("Middle/Desc/ButtonSell").gameObject)
  listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
      	if delegate ~= nil then
      	  self.finishSell = false
          self.finishSell = self.this:InvokeDelegate(delegate,tostring(self.selectGetedEquip),self.sellPrice)
          if self.finishSell == true then
          	--print("出售成功")
          	self:UpdateGetedEquip(self.selectGetedEquip,"Sell")
          else
          	--print("出售失败")
          end
      	end
      end  
    , self)

end

function PVPMallController:ClosePanel(delegate)
	-- body
	self.this.transform.parent.gameObject:SetActive(false)
	self.openPanel = false
	local listener = NTGEventTriggerProxy.Get(self.CloseButton.gameObject)
  	listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
      	  self.this.transform.parent.localPosition = Vector3.New(-1290,0,0)
      	  if delegate ~= nil then
          	self.this:InvokeDelegate(delegate)
          end
      end  
    , self)		

end

function PVPMallController:OpenPanel(delegate)
	self.this.transform.parent.gameObject:SetActive(true)
	self.openPanel = true
	self.rightPanel:Find("Middle/Scrollbar"):GetComponent("UnityEngine.UI.Scrollbar").value = 1
	self:InitList(self.selectedList)
	for i = 1,#self.getedEquipFrame do
		self.getedEquipFrame[i]:Find("Selected").gameObject:SetActive(false)
	end
    self.this.transform.parent.localPosition = Vector3.New(0,0,0)
    local line = self.rightPanel:Find("Middle/Mask/ScrollRect/Content/Lines")
    if line.childCount > 0 then
	    for i = 1,line.childCount do
	    	if line:GetChild(i-1).childCount > 0 then
		    	for k = 1,line:GetChild(i-1).childCount do
		    		line:GetChild(i-1):GetChild(k-1).gameObject:SetActive(false)
		    	end
		    end
	    end
	end
	if self.selectedEquip ~= "" then
		self.selectedEquip:Find("Selected").gameObject:SetActive(false)
	end

    if delegate ~= nil then
    	self.this:InvokeDelegate(delegate)
    end
end

--获取服务器发来的钱数变化
function PVPMallController:GetPlayerMoney(num)
	-- body

	self.Money = math.floor(num)
	self.currentMoney.text = self.Money

	if self.openPanel == true then
		self:InitListForUpdate()
	end 

	if self.openPanel == false then
		local a = self:OutSideCanBuy()
		if self.canSend1 == true or self.canSend2 == true then
			if self.buyDelegate ~= nil then
				if #self.GetedEquip < 7 then
					UIBattleAPI.Instance:RefreshRecoEquip(a)
				end
			end
		end
	end
end

function  PVPMallController:OutSideCanBuy()
	-- body
		local needBuy1 = ""
		local needBuy2 = ""
		local needBuy = {}
		local count = 0
		local price1 = 0
		local price2 = 0
		local money = self.Money
		local temp = 0
		local isBuyNextEquip = true
		local count = #self.notHave1
		local from = 0

		for i = count,1,-1 do
			if money >= self.priceSingle1[i] then
				needBuy1 = self.notHave1[i]
				price1 = self.priceSingle1[i]
				if i ~= 1 and i ~= count then
					if self.notHave1[i-1] ~= self.notHave1[i] and money >= self.priceSingle1[i-1] then
						needBuy2 = self.notHave1[i-1]
						price2 = self.priceSingle1[i-1]
						from = 1
						isBuyNextEquip = false
					end
				end
				break	
			end	
		end

		if isBuyNextEquip == true then
			for i = #self.notHave2,1,-1 do
				if money >= self.priceSingle2[i] then
					needBuy2 = self.notHave2[i]
					price2 = self.priceSingle2[i]
					from = 2
					break	
				end	
			end
		end

		if needBuy1 ~= "" then 
			if needBuy1 == needBuy2 then
				needBuy2 = ""
			end
		end


		if needBuy1 ~= self.backUp1 or self.backUpPrice1 ~= price1 then
			self.backUp1 = needBuy1
			self.backUpPrice1 = price1
			self.canSend1 = true
		else
			self.canSend1 = false
		end


		if needBuy2 ~= self.backUp2 or self.backUpPrice2 ~= price2 then
			self.backUp2 = needBuy2
			self.backUpPrice2 = price2
			self.canSend2 = true
		else
			self.canSend2 = false
		end


		if self.backUp1 ~= "" then
			table.insert(needBuy, self.price1[tostring(self.backUp1)])
		end
		if self.backUp2 ~= "" then
			if from == 1 then
				table.insert(needBuy, self.price1[tostring(self.backUp2)])
			elseif from == 2 then
				table.insert(needBuy, self.price2[tostring(self.backUp2)])
			end 
		end




		return needBuy
end

function PVPMallController:GetSelectedEquipInfo()
	-- body
	local data = {}
	local equipId = self.selectedEquipId
	local price = self.buyPrice
	local attr = {}
	local name = {}
	local value = {}
	local skill = {}
	local temp = Data.EquipsData[tostring(equipId)]
	for k,v in pairs(temp) do
		if k == "HP" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "MP" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "PAtk" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "MAtk" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "PDef" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "MDef" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "MoveSpeed" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "PpenetrateValue" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "PpenetrateRate" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "MpenetrateValue" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "MpenetrateRate" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "AtkSpeed" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "CritRate" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "CritEffect" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "PHpSteal" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)	
		elseif k == "MHpSteal" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)	
		elseif k == "CdReduce" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)	
		elseif k == "Tough" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)	
		elseif k == "HpRecover5s" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)	
		elseif k == "MpRecover5s" and v ~= 0 then
			table.insert(name,k)
			table.insert(value,v)
		elseif k == "PassiveSkills" then
			skill = v				
		end
	end

	for i = 1,#name do
		attr[name[i]] = value[i]
	end

	data = {EquipId = equipId,Price = price,Attr = attr,PassiveSkills = skill}

	return data
end

function PVPMallController:GetHighDeleteLow(equipId)
	-- body
	local temp = Data.PVPMallsData[tostring(equipId)]
	local haveLayer1 = {}
	local haveLayer2 = {}
	local buy = {}
	local buiesSubLayer1 = {}
	local buiesSubLayer2 = {}
	local buiesSubLayer3 = {}
	local needDelete = {}
	local buiesSelf = ""

	if #Data.PVPMallsData[tostring(equipId)].PreEquips ~= 0 then
		for i = #Data.PVPMallsData[tostring(equipId)].PreEquips,1,-1 do
			if Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(equipId)].PreEquips[i])].Quality == 1 then
				table.insert(buiesSubLayer1,Data.PVPMallsData[tostring(equipId)].PreEquips[i])
			elseif Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(equipId)].PreEquips[i])].Quality == 2 then
				table.insert(buiesSubLayer2,Data.PVPMallsData[tostring(equipId)].PreEquips[i])
			end

			if #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(equipId)].PreEquips[i])].PreEquips ~= 0 then
				for k = #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(equipId)].PreEquips[i])].PreEquips,1,-1 do
					table.insert(buiesSubLayer1, Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(equipId)].PreEquips[i])].PreEquips[k])
				end
			end
		end


		--if Data.PVPMallsData[tostring(equipId)].Quality == 2 then
			--buiesSelf = equipId
		--elseif Data.PVPMallsData[tostring(equipId)].Quality == 3 then
			--buiesSelf = equipId
		--end
	end

	--如果装备质量大于1，则判断是否存在配件




	--如果存在配件，则遍历已获得物品	
	for i = #self.GetedEquip,1,-1 do
		if Data.PVPMallsData[tostring(self.GetedEquip[i])].Quality == 1 then
			table.insert(haveLayer1,self.GetedEquip[i])
		elseif Data.PVPMallsData[tostring(self.GetedEquip[i])].Quality == 2 then
			table.insert(haveLayer2,self.GetedEquip[i])
		end
	end

	for i = #buiesSubLayer2,1,-1 do
		for k = #haveLayer2,1,-1 do
			if buiesSubLayer2[i] == haveLayer2[k] then
				for n = #Data.PVPMallsData[tostring(haveLayer2[k])].PreEquips,1,-1 do
					for m = #buiesSubLayer1,1,-1 do
						if buiesSubLayer1[m] == Data.PVPMallsData[tostring(haveLayer2[k])].PreEquips[n] then
							table.remove(buiesSubLayer1,m)
							break
						end
					end 
				end
				table.insert(needDelete,buiesSubLayer2[i])
				table.remove(haveLayer2,k)
				table.remove(buiesSubLayer2,i)
				break
			end
		end
	end

	if #buiesSubLayer2 == 0 and #buiesSubLayer1 ~= 0 then
		for i = #buiesSubLayer1,1,-1 do
			for k = #haveLayer1,1,-1 do
				if buiesSubLayer1[i] == haveLayer1[k] then
					table.insert(needDelete,buiesSubLayer1[i])
					table.remove(haveLayer1,k)
					table.remove(buiesSubLayer1,i)
					break
				end
			end
		end
	end 

	local tempHaveLayer1 = {}	--避免在一个层级中重复计算已有1级装备，对haveLayer1做一个拷贝
	if #buiesSubLayer2 ~= 0 then	--假如2级装备不全，则对没有的2级装备进行处理
		for i = #buiesSubLayer2,1,-1 do
			tempHaveLayer1 = {}
			tempHaveLayer1 = UITools.CopyTab(haveLayer1)
			if #Data.PVPMallsData[tostring(buiesSubLayer2[i])].PreEquips ~= 0 then
				--print("dfdfd " .. #Data.PVPMallsData[tostring(buiesSubLayer2[i])].PreEquips .. " " .. buiesSubLayer2[i])
				for k = #Data.PVPMallsData[tostring(buiesSubLayer2[i])].PreEquips,1,-1 do
					--print("abdc " .. Data.PVPMallsData[tostring(buiesSubLayer2[i])].PreEquips[k] .. #tempHaveLayer1)
					for m = #tempHaveLayer1,1,-1 do
						if Data.PVPMallsData[tostring(buiesSubLayer2[i])].PreEquips[k] == tempHaveLayer1[m] then
							table.insert(needDelete,tempHaveLayer1[m])
							--print("AAAAAAA AAAAAAAAA " .. tempHaveLayer1[m])
							for p = #buiesSubLayer1,1,-1 do
								if buiesSubLayer1[p] == tempHaveLayer1[m] then
									table.remove(buiesSubLayer1,p)
									break
								end
							end
							table.remove(haveLayer1,m)
							table.remove(tempHaveLayer1,m)

							break
						end
					end
				end
			end
		end

		--if #buiesSubLayer3 ~= 0 then
			for i = #buiesSubLayer1,1,-1 do
				for k = #haveLayer1,1,-1 do
					if buiesSubLayer1[i] == haveLayer1[k] then
						table.insert(needDelete,haveLayer1[k])
						table.remove(haveLayer1,k)
						table.remove(buiesSubLayer1,i)
						break					
					end
				end
			end
		--end
	end


	for i = #self.GetedEquip,1,-1 do
		for k = #needDelete,1,-1 do
			if self.GetedEquip[i] == needDelete[k] then
				table.remove(self.GetedEquip,i)
				table.remove(needDelete,k)
			end
		end
	end

end

function PVPMallController:UpdateBuyPrice()			--更新列表的钱数
	-- body

	self.subEquip1 = {}
	self.subEquip2 = {}
	self.priceSingle1 = {}
	self.priceSingle2 = {}

	local notHave1Layer1 = {}
	local notHave1Layer2 = {}
	local notHave1Layer3 = {}
	local haveLayer1 = {}
	local haveLayer2 = {}
	local notHave2Layer1 = {}
	local notHave2Layer2 = {}
	local notHave2Layer3 = {}
	local have2Layer1 = {}
	local have2Layer2 = {}
	local price = 0

	for i = #self.Ttemp1,1,-1 do
		if Data.PVPMallsData[tostring(self.Ttemp1[i])].Quality == 1 then
			table.insert(notHave1Layer1,self.Ttemp1[i])
		elseif Data.PVPMallsData[tostring(self.Ttemp1[i])].Quality == 2 then
			table.insert(notHave1Layer2,self.Ttemp1[i])
			self.subEquip1[tostring(self.Ttemp1[i])] = {}
		elseif Data.PVPMallsData[tostring(self.Ttemp1[i])].Quality == 3 then
			table.insert(notHave1Layer3,self.Ttemp1[i])
			self.subEquip1[tostring(self.Ttemp1[i])] = {}
		end
	end

	--print("11111 " .. #notHave1Layer1)
	--print("11112 " .. #notHave1Layer2)
	--print("11113 " .. #notHave1Layer3)

	for i = #self.GetedEquip,1,-1 do
		if Data.PVPMallsData[tostring(self.GetedEquip[i])].Quality == 1 then
			table.insert(haveLayer1,self.GetedEquip[i])
		elseif Data.PVPMallsData[tostring(self.GetedEquip[i])].Quality == 2 then
			table.insert(haveLayer2,self.GetedEquip[i])
		end
	end

	tempHaveLayer2 = {}
	tempHaveLayer2 = UITools.CopyTab(haveLayer2)

	for i = #notHave1Layer2,1,-1 do
		for k = #haveLayer2,1,-1 do
			if notHave1Layer2[i] == haveLayer2[k] then
				for n = #Data.PVPMallsData[tostring(haveLayer2[k])].PreEquips,1,-1 do
					for m = #notHave1Layer1,1,-1 do
						if notHave1Layer1[m] == Data.PVPMallsData[tostring(haveLayer2[k])].PreEquips[n] then
							table.remove(notHave1Layer1,m)
							break
						end
					end 
				end
				price = Data.PVPMallsData[tostring(haveLayer2[k])].Price
				if #notHave1Layer3 ~= 0 then
					self.price1[tostring(notHave1Layer3[1])][2] = self.price1[tostring(notHave1Layer3[1])][2] - price
					table.insert(self.subEquip1[tostring(notHave1Layer3[1])],tostring(haveLayer2[k]))
				end
				table.remove(haveLayer2,k)
				table.remove(notHave1Layer2,i)
				break
			end
		end
	end


	--print("11111 " .. #notHave1Layer1)
	--print("11112 " .. #notHave1Layer2)
	--print("11113 " .. #notHave1Layer3)

	if #notHave1Layer2 == 0 and #notHave1Layer1 ~= 0 then
		for i = #notHave1Layer1,1,-1 do
			for k = #haveLayer1,1,-1 do
				if notHave1Layer1[i] == haveLayer1[k] then
					price = Data.PVPMallsData[tostring(haveLayer1[k])].Price
					if #notHave1Layer3 ~= 0 then
						self.price1[tostring(notHave1Layer3[1])][2] = self.price1[tostring(notHave1Layer3[1])][2] - price
						table.insert(self.subEquip1[tostring(notHave1Layer3[1])],tostring(haveLayer1[k]))
					end
					table.remove(haveLayer1,k)
					table.remove(notHave1Layer1,i)
					break
				end
			end
		end
	end

	--print("11111 " .. #notHave1Layer1)
	--print("11112 " .. #notHave1Layer2)
	--print("11113 " .. #notHave1Layer3)

	local tempHaveLayer1 = {}	--避免在一个层级中重复计算已有1级装备，对haveLayer1做一个拷贝
	if #notHave1Layer2 ~= 0 then	--假如2级装备不全，则对没有的2级装备进行处理
		for i = #notHave1Layer2,1,-1 do
			tempHaveLayer1 = {}
			tempHaveLayer1 = UITools.CopyTab(haveLayer1)
			if #Data.PVPMallsData[tostring(notHave1Layer2[i])].PreEquips ~= 0 then
				for k = #Data.PVPMallsData[tostring(notHave1Layer2[i])].PreEquips,1,-1 do
					for m = #tempHaveLayer1,1,-1 do
						if Data.PVPMallsData[tostring(notHave1Layer2[i])].PreEquips[k] == tempHaveLayer1[m] then
							price = Data.PVPMallsData[tostring(tempHaveLayer1[m])].Price
							self.price1[tostring(notHave1Layer2[i])][2] = self.price1[tostring(notHave1Layer2[i])][2] - price
							table.insert(self.subEquip1[tostring(notHave1Layer2[i])],tostring(tempHaveLayer1[m]))
							table.remove(tempHaveLayer1,m)
							break
						end
					end
				end
			end

			if #Data.PVPMallsData[tostring(notHave1Layer2[i])].PreEquips ~= 0 then
				for k = #Data.PVPMallsData[tostring(notHave1Layer2[i])].PreEquips,1,-1 do
					for m = #tempHaveLayer2,1,-1 do
						--print(Data.PVPMallsData[tostring(notHave1Layer2[i])].PreEquips[k] .. " " .. tempHaveLayer2[m])
						if Data.PVPMallsData[tostring(notHave1Layer2[i])].PreEquips[k] == tempHaveLayer2[m] then
							price = Data.PVPMallsData[tostring(tempHaveLayer2[m])].Price
							self.price1[tostring(notHave1Layer2[i])][2] = self.price1[tostring(notHave1Layer2[i])][2] - price
							table.insert(self.subEquip1[tostring(notHave1Layer2[i])],tostring(tempHaveLayer2[m]))
							table.remove(tempHaveLayer2,m)
							break
						end
					end
				end
			end




		end

	--print("11111 " .. #notHave1Layer1)
	--print("11112 " .. #notHave1Layer2)
	--print("11113 " .. #notHave1Layer3)


		if  #notHave1Layer3 ~= 0 then
			for i = #notHave1Layer1,1,-1 do
				for k = #haveLayer1,1,-1 do
					if notHave1Layer1[i] == haveLayer1[k] then
						price = Data.PVPMallsData[tostring(haveLayer1[k])].Price
						self.price1[tostring(notHave1Layer3[1])][2] = self.price1[tostring(notHave1Layer3[1])][2] - price
						table.insert(self.subEquip1[tostring(notHave1Layer3[1])],tostring(haveLayer1[k]))
						table.remove(haveLayer1,k)
						table.remove(notHave1Layer1,i)
						break					
					end
				end
			end
		end
	end


	--print("11111 " .. #notHave2Layer1)
	--print("11112 " .. #notHave2Layer2)
	--print("11113 " .. #notHave2Layer3)


	for i = #self.Ttemp2,1,-1 do
		if Data.PVPMallsData[tostring(self.Ttemp2[i])].Quality == 1 then
			table.insert(notHave2Layer1,self.Ttemp2[i])
		elseif Data.PVPMallsData[tostring(self.Ttemp2[i])].Quality == 2 then
			table.insert(notHave2Layer2,self.Ttemp2[i])
			self.subEquip2[tostring(self.Ttemp2[i])] = {}
		elseif Data.PVPMallsData[tostring(self.Ttemp2[i])].Quality == 3 then
			table.insert(notHave2Layer3,self.Ttemp2[i])
			self.subEquip2[tostring(self.Ttemp2[i])] = {}
		end
	end

	for i = #self.GetedEquip,1,-1 do
		if Data.PVPMallsData[tostring(self.GetedEquip[i])].Quality == 1 then
			table.insert(have2Layer1,self.GetedEquip[i])
		elseif Data.PVPMallsData[tostring(self.GetedEquip[i])].Quality == 2 then
			table.insert(have2Layer2,self.GetedEquip[i])
		end
	end

	--print("11111 " .. #notHave2Layer1)
	--print("11112 " .. #notHave2Layer2)
	--print("11113 " .. #notHave2Layer3)

	tempHave2Layer2 = {}
	tempHave2Layer2 = UITools.CopyTab(have2Layer2)

	for i = #notHave2Layer2,1,-1 do
		for k = #have2Layer2,1,-1 do
			if notHave2Layer2[i] == have2Layer2[k] then
				for n = #Data.PVPMallsData[tostring(have2Layer2[k])].PreEquips,1,-1 do
					for m = #notHave2Layer1,1,-1 do
						if notHave2Layer1[m] == Data.PVPMallsData[tostring(have2Layer2[k])].PreEquips[n] then
							table.remove(notHave2Layer1,m)
							break
						end
					end 
				end
				price = Data.PVPMallsData[tostring(have2Layer2[k])].Price
				if #notHave2Layer3 ~= 0 then
					self.price2[tostring(notHave2Layer3[1])][2] = self.price2[tostring(notHave2Layer3[1])][2] - price
					table.insert(self.subEquip2[tostring(notHave2Layer3[1])],tostring(have2Layer2[k]))
				end
				table.remove(have2Layer2,k)
				table.remove(notHave2Layer2,i)
				break
			end
		end
	end 

	if #notHave2Layer2 == 0 and #notHave2Layer1 ~= 0 then
		for i = #notHave2Layer1,1,-1 do
			for k = #have2Layer1,1,-1 do
				if notHave2Layer1[i] == have2Layer1[k] then
					price = Data.PVPMallsData[tostring(have2Layer1[k])].Price
					if #notHave2Layer3 ~= 0 then
						self.price2[tostring(notHave2Layer3[1])][2] = self.price2[tostring(notHave2Layer3[1])][2] - price
						table.insert(self.subEquip2[tostring(notHave2Layer3[1])],tostring(have2Layer1[k]))
					end
					table.remove(have2Layer1,k)
					table.remove(notHave2Layer1,i)
					break
				end
			end
		end
	end

	local tempHave2Layer1 = {}	--避免在一个层级中重复计算已有1级装备，对haveLayer1做一个拷贝
	if #notHave2Layer2 ~= 0 then	--假如2级装备不全，则对没有的2级装备进行处理
		for i = #notHave2Layer2,1,-1 do
			if #notHave2Layer2~=1 then
				if i < #notHave2Layer2 then
					if notHave2Layer2[i] == notHave2Layer2[i+1] then
						break
					end
				end
			end
			tempHave2Layer1 = {}
			tempHave2Layer1 = UITools.CopyTab(have2Layer1)
			if #Data.PVPMallsData[tostring(notHave2Layer2[i])].PreEquips ~= 0 then
				for k = #Data.PVPMallsData[tostring(notHave2Layer2[i])].PreEquips,1,-1 do
					--print("ddddd " .. #Data.PVPMallsData[tostring(notHave2Layer2[i])].PreEquips .. " " .. #tempHave2Layer1 .. " " .. Data.PVPMallsData[tostring(notHave2Layer2[i])].PreEquips[k])
					for m = #tempHave2Layer1,1,-1 do
						if Data.PVPMallsData[tostring(notHave2Layer2[i])].PreEquips[k] == tempHave2Layer1[m] then
							--print("fffffff " .. tempHave2Layer1[m])
							price = Data.PVPMallsData[tostring(tempHave2Layer1[m])].Price
							self.price2[tostring(notHave2Layer2[i])][2] = self.price2[tostring(notHave2Layer2[i])][2] - price
							table.insert(self.subEquip2[tostring(notHave2Layer2[i])],tostring(tempHave2Layer1[m]))
							table.remove(tempHave2Layer1,m)
							break
						end
					end
				end
			end

			if #Data.PVPMallsData[tostring(notHave2Layer2[i])].PreEquips ~= 0 then
				for k = #Data.PVPMallsData[tostring(notHave2Layer2[i])].PreEquips,1,-1 do
					--print("ddddd " .. #Data.PVPMallsData[tostring(notHave2Layer2[i])].PreEquips .. " " .. #tempHave2Layer1 .. " " .. Data.PVPMallsData[tostring(notHave2Layer2[i])].PreEquips[k])
					for m = #tempHave2Layer2,1,-1 do
						if Data.PVPMallsData[tostring(notHave2Layer2[i])].PreEquips[k] == tempHave2Layer2[m] then
							--print("fffffff " .. tempHave2Layer1[m])
							price = Data.PVPMallsData[tostring(tempHave2Layer2[m])].Price
							self.price2[tostring(notHave2Layer2[i])][2] = self.price2[tostring(notHave2Layer2[i])][2] - price
							table.insert(self.subEquip2[tostring(notHave2Layer2[i])],tostring(tempHave2Layer2[m]))
							table.remove(tempHave2Layer2,m)
							break
						end
					end
				end
			end



		end
		if #notHave2Layer3 ~= 0 then
			for i = #notHave2Layer1,1,-1 do
				for k = #have2Layer1,1,-1 do
					if notHave2Layer1[i] == have2Layer1[k] then
						price = Data.PVPMallsData[tostring(have2Layer1[k])].Price
						self.price2[tostring(notHave2Layer3[1])][2] = self.price2[tostring(notHave2Layer3[1])][2] - price
						table.insert(self.subEquip2[tostring(notHave2Layer3[1])],tostring(have2Layer1[k]))
						table.remove(have2Layer1,k)
						table.remove(notHave2Layer1,i)
						break					
					end
				end
			end
		end
	end

--[[
	local temp = UITools.CopyTab(self.GetedEquip)
	for i = #temp,1,-1 do
		for k = #self.forUpdate ,1,-1 do
			if temp[i] == self.forUpdate[k] then
				table.remove(temp,i)
			end
		end
	end




	local price = 0

	local notHave1Temp = UITools.CopyTab(self.notHave1)

	--print("GGGGGGG " .. #notHave1Temp)
	--for i = 1,#notHave1Temp do
		--print("GGGGGGG " .. notHave1Temp[i] .. " " .. i)
	--end


	for i = 1,#notHave1Temp do
		self.subEquip1[tostring(notHave1Temp[i])] = {}
	end

	self.layer3 = {}
	self.layer2 = {}

	if temp ~= nil then
		for k = #notHave1Temp,1,-1 do

			for i = #temp,1,-1 do
				local isUsed = false
				if #Data.PVPMallsData[tostring(notHave1Temp[k])].PreEquips ~= 0 then
					local preEquips1 = UITools.CopyTab(Data.PVPMallsData[tostring(notHave1Temp[k])].PreEquips)
					for m = #preEquips1,1,-1 do
						if Data.PVPMallsData[tostring(temp[i])].Quality == 2 then
							if preEquips1[m] == temp[i] and isUsed == false then
								isUsed = true
								local price = Data.PVPMallsData[tostring(temp[i])].Price
								self.price1[tostring(notHave1Temp[k])][2] = self.price1[tostring(notHave1Temp[k])][2] - price
								table.insert(self.subEquip1[tostring(notHave1Temp[k])],tostring(temp[i]))
							end
						else
							if #Data.PVPMallsData[tostring(preEquips1[m])].PreEquips ~= 0 then
								local preEquips2 = Data.PVPMallsData[tostring(preEquips1[m])].PreEquips
								for n = #preEquips2,1,-1 do
									if preEquips2[n] == temp[i] and isUsed == false then
										isUsed = true
										local price = Data.PVPMallsData[tostring(temp[i])].Price
										self.price1[tostring(notHave1Temp[k])][2] = self.price1[tostring(notHave1Temp[k])][2] - price
										table.insert(self.subEquip1[tostring(notHave1Temp[k])],tostring(temp[i]))
										--table.remove(preEquips2,n)
										--table.remove(notHave1Temp,k)
									end
								end
							else
								if preEquips1[m] == temp[i] and isUsed == false then
									isUsed = true
									local price = Data.PVPMallsData[tostring(temp[i])].Price
									self.price1[tostring(notHave1Temp[k])][2] = self.price1[tostring(notHave1Temp[k])][2] - price
									table.insert(self.subEquip1[tostring(notHave1Temp[k])],tostring(temp[i]))
									--table.remove(preEquips1,m)	
								end
							end
						end
					end
				end
				--table.remove(notHave1Temp,k)
			end
		end
	else
		for k,v in pairs(self.price1) do
			v[2] = Data.PVPMallsData[tostring(k)].Price
		end
	end

	local notHave2Temp = UITools.CopyTab(self.notHave2)
	for i = 1,#notHave2Temp do
		self.subEquip2[tostring(notHave2Temp[i])] = {}
	end

	local notHave2Temp = UITools.CopyTab(self.notHave2)
	if temp ~= nil then
		for i = #temp,1,-1 do
			for k = #notHave2Temp,1,-1 do
				local isUsed = false
				if #Data.PVPMallsData[tostring(notHave2Temp[k])].PreEquips ~= 0 then
					local preEquips1 = UITools.CopyTab(Data.PVPMallsData[tostring(notHave2Temp[k])].PreEquips)
					for m = #preEquips1,1,-1 do
						if Data.PVPMallsData[tostring(temp[i])].Quality == 2 then
							if preEquips1[m] == temp[i] and isUsed == false then
								isUsed = true
								local price = Data.PVPMallsData[tostring(temp[i])].Price
								self.price2[tostring(notHave2Temp[k])][2] = self.price2[tostring(notHave2Temp[k])][2] - price
								table.insert(self.subEquip2[tostring(notHave2Temp[k])],tostring(temp[i]))
							end
						else
							if #Data.PVPMallsData[tostring(preEquips1[m])].PreEquips ~= 0 then
								local preEquips2 = Data.PVPMallsData[tostring(preEquips1[m])].PreEquips
								for n = #preEquips2,1,-1 do
									if preEquips2[n] == temp[i] and isUsed == false then
										isUsed = true
										local price = Data.PVPMallsData[tostring(temp[i])].Price
										self.price2[tostring(notHave2Temp[k])][2] = self.price2[tostring(notHave2Temp[k])][2] - price
										table.insert(self.subEquip2[tostring(notHave2Temp[k])],tostring(temp[i]))
										--table.remove(preEquips2,n)
										--table.remove(notHave1Temp,k)
									end
								end
							else
								if preEquips1[m] == temp[i] and isUsed == false then
									isUsed = true
									local price = Data.PVPMallsData[tostring(temp[i])].Price
									self.price2[tostring(notHave2Temp[k])][2] = self.price2[tostring(notHave2Temp[k])][2] - price
									table.insert(self.subEquip2[tostring(notHave2Temp[k])],tostring(temp[i]))
									--table.remove(preEquips1,m)	
								end
							end
						end
					end
				end
				--table.remove(notHave1Temp,k)
			end
		end
	else
		for k,v in pairs(self.price2) do
			v[2] = Data.PVPMallsData[tostring(k)].Price
		end
	end
]]
	for i = 1,#self.notHave1 do
		table.insert(self.priceSingle1,self.price1[tostring(self.notHave1[i])][2])
	end
	for i = 1,#self.notHave2 do
		table.insert(self.priceSingle2,self.price2[tostring(self.notHave2[i])][2])
   	end

	--[[
	for k,v in pairs(self.subEquip1) do
		if #v ~= 0 then
			for i = 1,#v do
				print("HHHHHHH " .. k .. " " .. v[i])
			end
		end
	end

	for i = 1,#self.notHave1 do
		print("GGGGGGGG1 " .. #self.notHave1 .. " " ..self.notHave1[i] .. " " ..self.price1[tostring(self.notHave1[i])][1].. " "..self.price1[tostring(self.notHave1[i])][2])
	end

	for i = 1,#self.notHave2 do
		print("GGGGGGGG2 " .. #self.notHave2 .. " " ..self.notHave2[i] .. " " ..self.price2[tostring(self.notHave2[i])][1].. " "..self.price2[tostring(self.notHave2[i])][2])
	end

	for i = 1,#self.priceSingle1 do
		print("GGGGGGGprice1 " .. i .. " " .. self.priceSingle1[i])
	end

	for i = 1,#self.priceSingle2 do
		print("GGGGGGGprice2 " .. i .. " " .. self.priceSingle2[i])
	end

	for k,v in pairs(self.subEquip1) do
		print("配件列表 " .. k .. #v)
	end

	for k,v in pairs(self.subEquip2) do
		print("配件列表2 " .. k .. #v)
	end
]]

end

function PVPMallController:SellControl(equipId)
	-- body
	if Data.PVPMallsData[tostring(equipId)].Quality ~= 3 then
		local needDel = false
		for i = 1,#self.HeroRecommendEquip do
			if self.HeroRecommendEquip[i] == equipId then
				needDel = true
				break
			end
		end

		if needDel == true then

			table.insert(self.notHave,equipId)
		end

		table.sort(self.notHave,function(a,b) return Data.PVPMallsData[tostring(a)].Price < Data.PVPMallsData[tostring(b)].Price end)
	end

end

function PVPMallController:ReorderBuy()
	-- body

	self.notHave1 = {}
	self.notHave2 = {}
	self.needBuyBackUp1 = {}
	self.needBuyBackUp2 = {}
	self.price1 = {}
	self.price2 = {}
	self.priceSingle1 = {}
	self.priceSingle2 = {}
	self.GetedEquipNum = #self.GetedEquip

	local forBuyOrderTemp = UITools.CopyTab(self.forBuyOrder)

	local tempGeted = UITools.CopyTab(self.GetedEquip)
	for i = #tempGeted,1,-1 do
		for k = 1,#forBuyOrderTemp do
			if tempGeted[i] == forBuyOrderTemp[k] then
				table.remove(forBuyOrderTemp,k)
				table.remove(tempGeted,i)
				break
			end
		end
	end

	for i = 1,#forBuyOrderTemp do
		--print("ssss " .. forBuyOrderTemp[i])
	end



	local allEquipIsLayer3 = true
	for i = 1,#self.GetedEquip do
		if Data.PVPMallsData[tostring(self.GetedEquip[i])].Quality ~= 3 then
			if #forBuyOrderTemp > 0 then		
				for k = #Data.PVPMallsData[tostring(forBuyOrderTemp[1])].PreEquips,1,-1 do
					if self.GetedEquip[i] == Data.PVPMallsData[tostring(forBuyOrderTemp[1])].PreEquips[k] then
						allEquipIsLayer3 = false
					end

					for m = #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(forBuyOrderTemp[1])].PreEquips[k])].PreEquips,1,-1 do
						if self.GetedEquip[i] == Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(forBuyOrderTemp[1])].PreEquips[k])].PreEquips[m] then
							allEquipIsLayer3 = false
						end
					end
				end
			end

			if #forBuyOrderTemp > 1 then
				for k = #Data.PVPMallsData[tostring(forBuyOrderTemp[2])].PreEquips,1,-1 do
					if self.GetedEquip[i] == Data.PVPMallsData[tostring(forBuyOrderTemp[2])].PreEquips[k] then
						allEquipIsLayer3 = false
					end

					for m = #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(forBuyOrderTemp[2])].PreEquips[k])].PreEquips,1,-1 do
						if self.GetedEquip[i] == Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(forBuyOrderTemp[2])].PreEquips[k])].PreEquips[m] then
							allEquipIsLayer3 = false
						end
					end
				end				
			end

		end
	end

	if #forBuyOrderTemp > 1 then
		table.insert(self.needBuyBackUp1,forBuyOrderTemp[1])
		table.insert(self.needBuyBackUp2,forBuyOrderTemp[2])
		--self.count = 2
	elseif	#forBuyOrderTemp == 1 then
		table.insert(self.needBuyBackUp1,forBuyOrderTemp[1])
		--self.count = 1
	else
		--print("无需要购买的装备")
		self.needBuyBackUp1 = nil
		self.needBuyBackUp2 = nil
	end

	if #self.GetedEquip > 5 then
		if allEquipIsLayer3 == true then
			--print("无需要购买的装备")
			self.needBuyBackUp1 = nil
			self.needBuyBackUp2 = nil		
		end
	end
--[[
	if #self.needBuyBackUp1 ~= 0 then
		print("1st " .. self.needBuyBackUp1[1])
	end

	if #self.needBuyBackUp2 ~= 0 then
		print("2nd " .. self.needBuyBackUp2[1])
	end
]]
	--解压
	if self.needBuyBackUp1 ~= nil then
		for i = 1,#self.needBuyBackUp1 do
			if #Data.PVPMallsData[tostring(self.needBuyBackUp1[i])].PreEquips ~= 0 then
				for k = 1,#Data.PVPMallsData[tostring(self.needBuyBackUp1[i])].PreEquips do
					if #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.needBuyBackUp1[i])].PreEquips[k])].PreEquips ~= 0 then
						for m = 1,#Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.needBuyBackUp1[i])].PreEquips[k])].PreEquips do
							table.insert(self.notHave1,Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.needBuyBackUp1[i])].PreEquips[k])].PreEquips[m])
						end
					end
					table.insert(self.notHave1,Data.PVPMallsData[tostring(self.needBuyBackUp1[i])].PreEquips[k])
				end
			end
			table.insert(self.notHave1,self.needBuyBackUp1[i])
		end
	end


	if self.needBuyBackUp2 ~= nil then
		for i = 1,#self.needBuyBackUp2 do
			if #Data.PVPMallsData[tostring(self.needBuyBackUp2[i])].PreEquips ~= 0 then
				for k = 1,#Data.PVPMallsData[tostring(self.needBuyBackUp2[i])].PreEquips do
					if #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.needBuyBackUp2[i])].PreEquips[k])].PreEquips ~= 0 then
						for m = 1,#Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.needBuyBackUp2[i])].PreEquips[k])].PreEquips do
							table.insert(self.notHave2,Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.needBuyBackUp2[i])].PreEquips[k])].PreEquips[m])
						end
					end
					table.insert(self.notHave2,Data.PVPMallsData[tostring(self.needBuyBackUp2[i])].PreEquips[k])
				end
			end
			table.insert(self.notHave2,self.needBuyBackUp2[i])
		end
	end

	--for i = 1,#self.notHave1 do
		--for k = 1,#Data.PVPMallsData[tostring(self.notHave1[i])].PreEquips do
			--print("SubEquips " .. self.notHave1[i] .. " " .. #Data.PVPMallsData[tostring(self.notHave1[i])].PreEquips .. " " .. Data.PVPMallsData[tostring(self.notHave1[i])].PreEquips[k])
		--end
	--end

	self.Ttemp1 = UITools.CopyTab(self.notHave1)
	self.Ttemp2 = UITools.CopyTab(self.notHave2)

	local layer2Equip1 = {}
	local layer2Equip2 = {}
	local temp1 = UITools.CopyTab(self.GetedEquip)
	for i = #temp1,1,-1 do
		for k = #self.notHave1,1,-1 do
			if temp1[i] == self.notHave1[k] then
				--table.remove(temp1,i)
				if Data.PVPMallsData[tostring(temp1[i])].Quality == 2 then
					table.insert(layer2Equip1,temp1[i])
				end

				if Data.PVPMallsData[tostring(temp1[i])].Quality ~= 3 then
					table.remove(self.notHave1,k)
					break
				end
			end
		end
	end

	for i = 1,#layer2Equip1 do
		for k = #Data.PVPMallsData[tostring(layer2Equip1[i])].PreEquips,1,-1 do
			for m = #self.notHave1,1,-1 do
				if self.notHave1[m] == Data.PVPMallsData[tostring(layer2Equip1[i])].PreEquips[k] then
					table.remove(self.notHave1,m)
					break
				end
			end
		end
	end

	--for  i = #self.notHave1,1,-1 do
		--print("self.notHave1 " .. self.notHave1[i] .. " " .. #self.notHave1)
	--end

	local notHave1Temp = self.notHave1[#self.notHave1]
--[[
	for i = #temp1,1,-1 do
		if #Data.PVPMallsData[tostring(notHave1Temp)].PreEquips ~= 0 then
			for k = 1,#Data.PVPMallsData[tostring(notHave1Temp)].PreEquips do
				if #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(notHave1Temp)].PreEquips[k])].PreEquips ~= 0 then
					for m = 1,#Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(notHave1Temp)].PreEquips[k])].PreEquips do
						if temp1[i] ==  Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(notHave1Temp)].PreEquips[k])].PreEquips[m] then
							table.insert(self.notHave1,temp1[i])
						end
					end
				elseif temp1[i] == Data.PVPMallsData[tostring(notHave1Temp)].PreEquips[k] then
					table.insert(self.notHave1,temp1[i])
				end
			end
		end
	end
]]
	local temp2 = UITools.CopyTab(self.GetedEquip)
	for i = #temp2,1,-1 do
		for k = #self.notHave2,1,-1 do
			if temp2[i] == self.notHave2[k] then
				--table.remove(temp2,i)
				if Data.PVPMallsData[tostring(temp2[i])].Quality == 2 then
					table.insert(layer2Equip2,temp2[i])
				end

				if Data.PVPMallsData[tostring(temp2[i])].Quality ~= 3 then
					table.remove(self.notHave2,k)
					break
				end
				break
			end
		end
	end

	for i = 1,#layer2Equip2 do
		for k = #Data.PVPMallsData[tostring(layer2Equip2[i])].PreEquips,1,-1 do
			for m = #self.notHave2,1,-1 do
				if self.notHave2[m] == Data.PVPMallsData[tostring(layer2Equip2[i])].PreEquips[k] then
					table.remove(self.notHave2,m)
					break
				end
			end
		end
	end

	local notHave2Temp = self.notHave2[#self.notHave2]
--[[
	for i = #temp2,1,-1 do
		if #Data.PVPMallsData[tostring(notHave2Temp)].PreEquips ~= 0 then
			for k = 1,#Data.PVPMallsData[tostring(notHave2Temp)].PreEquips do
				if #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(notHave2Temp)].PreEquips[k])].PreEquips ~= 0 then
					for m = 1,#Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(notHave2Temp)].PreEquips[k])].PreEquips do
						if temp2[i] ==  Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(notHave2Temp)].PreEquips[k])].PreEquips[m] then
							table.insert(self.notHave2,temp2[i])
						end
					end
				elseif temp2[i] == Data.PVPMallsData[tostring(notHave2Temp)].PreEquips[k] then
					table.insert(self.notHave2,temp2[i])
				end
			end
		end
	end
]]

	table.sort(self.notHave1,function(a,b) return Data.PVPMallsData[tostring(a)].Price < Data.PVPMallsData[tostring(b)].Price end)
	table.sort(self.notHave2,function(a,b) return Data.PVPMallsData[tostring(a)].Price < Data.PVPMallsData[tostring(b)].Price end)

	for i = 1,#self.notHave1 do
		self.price1[tostring(self.notHave1[i])] = {self.notHave1[i],Data.PVPMallsData[tostring(self.notHave1[i])].Price,1}
		table.insert(self.priceSingle1,Data.PVPMallsData[tostring(self.notHave1[i])].Price)
	end

	for i = 1,#self.notHave2 do
		self.price2[tostring(self.notHave2[i])] = {self.notHave2[i],Data.PVPMallsData[tostring(self.notHave2[i])].Price,2}
		table.insert(self.priceSingle2,Data.PVPMallsData[tostring(self.notHave2[i])].Price)
	end


	if #forBuyOrderTemp == 0 then
		self.dontBuy1 = true
		self.dontBuy2 = true
	end

	if #temp1 ~= 0 then
		for i = 1,#self.notHave1 do
			for n = 1,#temp1 do
			if #Data.PVPMallsData[tostring(self.notHave1[i])].PreEquips ~= 0 then
				for k = 1,#Data.PVPMallsData[tostring(self.notHave1[i])].PreEquips do
					if #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.notHave1[i])].PreEquips[k])].PreEquips ~= 0 then
						for m = 1,#Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.notHave1[i])].PreEquips[k])].PreEquips do
							if Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.notHave1[i])].PreEquips[k])].PreEquips[m] == temp1[n] then
								self.dontBuy1 = false
								break
							end		
						end
					end
					if Data.PVPMallsData[tostring(self.notHave1[i])].PreEquips[k]== temp1[n] then
						self.dontBuy1 = false
						break
					end	
				end
			end
			end
		end
	end

	if self.dontBuy1 == true then
		--print("第一推荐装备为空")
		self.notHave1 = {}
		self.priceSingle1 = {}
	else
		if self.GetedEquipNum == 6 then
			for i = #self.notHave1,1,-1 do
				if Data.PVPMallsData[tostring(self.notHave1[i])].Quality == 1 then
					table.remove(self.notHave1,i)
				elseif Data.PVPMallsData[tostring(self.notHave1[i])].Quality == 2 then
					local isNeed = false
					for k = #Data.PVPMallsData[tostring(self.notHave1[i])].PreEquips,1,-1 do
						for m = #self.GetedEquip,1,-1 do
							if Data.PVPMallsData[tostring(self.notHave1[i])].PreEquips[k] == self.GetedEquip[m] then
								isNeed = true
							end
						end
					end
					if isNeed == false then
						table.remove(self.notHave1,i)
					end
				end
			end
		end
	end

	if #temp2 ~= 0 then
		for i = 1,#self.notHave2 do
			for n = 1,#temp2 do
			if #Data.PVPMallsData[tostring(self.notHave2[i])].PreEquips ~= 0 then
				for k = 1,#Data.PVPMallsData[tostring(self.notHave2[i])].PreEquips do
					if #Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.notHave2[i])].PreEquips[k])].PreEquips ~= 0 then
						for m = 1,#Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.notHave2[i])].PreEquips[k])].PreEquips do
							if Data.PVPMallsData[tostring(Data.PVPMallsData[tostring(self.notHave2[i])].PreEquips[k])].PreEquips[m] == temp2[n] then
								self.dontBuy2 = false
								break
							end		
						end
					end
					if Data.PVPMallsData[tostring(self.notHave2[i])].PreEquips[k]== temp2[n] then
						self.dontBuy2 = false
						break
					end	
				end
			end
			end
		end
	end

	if self.dontBuy2 == true then
		--print("第二推荐装备为空")
		self.notHave2 = {}
		self.priceSingle2 = {}
	else
		if self.GetedEquipNum == 6 then
			for i = #self.notHave2,1,-1 do
				if Data.PVPMallsData[tostring(self.notHave2[i])].Quality == 1 then
					table.remove(self.notHave2,i)
				elseif Data.PVPMallsData[tostring(self.notHave2[i])].Quality == 2 then
					local isNeed = false
					for k = #Data.PVPMallsData[tostring(self.notHave2[i])].PreEquips,1,-1 do
						for m = #self.GetedEquip,1,-1 do
							if Data.PVPMallsData[tostring(self.notHave2[i])].PreEquips[k] == self.GetedEquip[m] then
								isNeed = true
							end
						end
					end
					if isNeed == false then
						table.remove(self.notHave2,i)
					end
				end
			end
		end
	end
end

function PVPMallController:GetCurrentPageEquipId(equipId)
	-- body

	for i = 1, #self.tempEquipList do
		if equipId == tonumber(self.tempEquipList[i].name) then
			self.tempEquipList[i]:Find()
		end
	end

end

function  PVPMallController:OnDestroy()
	-- body
	self.this = nil
	self = nil
end
