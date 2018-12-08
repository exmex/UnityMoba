require "System.Global"

class("StorePreferentialPanelCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"

function StorePreferentialPanelCtrl:Awake(this)
	-- body
	self.this = this
	self.tempCell = self.this.transforms[0]
	self.cellGroup = self.this.transforms[1]
end

function StorePreferentialPanelCtrl:Start()
	-- body
	self:GetData()
	self:UpdateCell(self.cellData)
end
function StorePreferentialPanelCtrl:OnEnable()
	-- body
	self.panelState=true
end
function StorePreferentialPanelCtrl:OnDisable()
	-- body
	self.panelState=false
end
function StorePreferentialPanelCtrl:UpdateUI()
	-- body
	if(self.panelState) then
		self:UpdateText()
	end

end
function StorePreferentialPanelCtrl:GetData()
	-- body
	local shopData=UTGData.Instance().ShopsSaleData
	self.cellData={}
	if(shopData~=nil) then
		self.cellData=shopData
	end
	local function sort(a,b)
    return a.Order<b.Order
    end
	table.sort(self.cellData,sort)
	self.playerShopsDeck = UTGData.Instance().PlayerShopsDeck

end
function StorePreferentialPanelCtrl:OnClick(Id,IdType,Limited,BuyNum,priceType,finalPrice,myTable)
	-- body
	local tempTable = {}
	table.insert(tempTable,Id)
	----print("ID"..Id)
	
	table.insert(tempTable,Limited)
	----print("Limited"..tostring(Limited))
	table.insert(tempTable,BuyNum)
	----print("BuyNum"..BuyNum)
	table.insert(tempTable,priceType)
	----print("priceType"..priceType)
	table.insert(tempTable,finalPrice)
	----print("finalPrice"..finalPrice)
	if(table.getn(myTable)>0) then
		table.insert(tempTable,myTable)	
		coroutine.start(StorePreferentialPanelCtrl.CreateGiftPanelMov,self, tempTable)
	else
		table.insert(tempTable,IdType)
		----print("IdType"..IdType)
		coroutine.start(StorePreferentialPanelCtrl.CreatePropPanelMov,self, tempTable)
	end
	----print("OnClick"..Id)

end
function StorePreferentialPanelCtrl:CreateGiftPanelMov(tempTable)
	-- body
	local result = GameManager.CreatePanelAsync("GiftDetails")
  	while result.Done~= true do
    --------print("deng")
    coroutine.wait(0.05)
  	end
  	GiftDetailsAPI.Instance:DataInit(tempTable[1],tempTable[2],tempTable[3],tempTable[4],tempTable[5],tempTable[6])
end
function StorePreferentialPanelCtrl:UpdateText()
	-- body
	for k,v in pairs(UTGData.Instance().PlayerShopsDeck.PurchasedLimitCommodities) do
		if self.cells[tostring(UTGData.Instance().ShopsDataById[tostring(v.ShopId)].CommodityId)]~=nil then
			self.cells[tostring(UTGData.Instance().ShopsDataById[tostring(v.ShopId)].CommodityId)]:FindChild("LimitBuy/Text1"):GetComponent(Text).text=v.Amount.."/"..UTGData.Instance().ShopsDataById[tostring(v.ShopId)].LimitAmount
		end
	end
end

function StorePreferentialPanelCtrl:CreatePropPanelMov(tempTable)
	-- body
	local result = GameManager.CreatePanelAsync("PropDetails")
  	while result.Done~= true do
    --------print("deng")
    coroutine.wait(0.05)
  	end
  	PropDetailsAPI.Instance:DataInit(tempTable[1],tempTable[2],tempTable[3],tempTable[4],tempTable[5],tempTable[6])
end
function StorePreferentialPanelCtrl:UpdateCell(date)
	-- body
	self.cells={}
	for k,v in pairs(date) do
		local newCell = GameObject.Instantiate(self.tempCell.gameObject).transform
		newCell.gameObject:SetActive(true)
		newCell.gameObject.name=v.CommodityId
		newCell.transform:SetParent(self.cellGroup)
		newCell.transform.localScale = Vector3.one
		newCell.transform.localPosition = Vector3.zero
		self.cells[tostring(v.CommodityId)]=newCell
		
		local buyNum = 0
		--middle
		if(v.CommodityType==1) then
			newCell:FindChild("Middle/Icon").gameObject:SetActive(true)
			newCell:FindChild("Middle/Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().ItemsData[tostring(v.CommodityId)].Icon)
			newCell:FindChild("Text"):GetComponent(Text).text=UTGData.Instance().ItemsData[tostring(v.CommodityId)].Name
		elseif(v.CommodityType==2) then
			newCell:FindChild("Middle/Icon").gameObject:SetActive(true)
			newCell:FindChild("Middle/Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("skinicon",UTGData.Instance().ItemsData[tostring(v.CommodityId)].Icon)
			newCell:FindChild("Text"):GetComponent(Text).text=UTGData.Instance().ItemsData[tostring(v.CommodityId)].Name
		elseif(v.CommodityType==3) then
			newCell:FindChild("Middle/Rune").gameObject:SetActive(true)
			newCell:FindChild("Middle/Rune"):GetComponent(Image).sprite=UITools.GetSprite("runeicon",UTGData.Instance().RunesData[tostring(v.CommodityId)].Icon)
			newCell:FindChild("Text"):GetComponent(Text).text=UTGData.Instance().RunesData[tostring(v.CommodityId)].Name
			buyNum=UTGData.Instance().RunesData[tostring(v.CommodityId)].MaxStack
		elseif(v.CommodityType==4) then
			newCell:FindChild("Middle/Item").gameObject:SetActive(true)
			newCell:FindChild("Middle/Item"):GetComponent(Image).sprite=UITools.GetSprite("itemicon",UTGData.Instance().ItemsData[tostring(v.CommodityId)].Icon)
			newCell:FindChild("Text"):GetComponent(Text).text=UTGData.Instance().ItemsData[tostring(v.CommodityId)].Name
			buyNum=UTGData.Instance().ItemsData[tostring(v.CommodityId)].MaxStack
		end
		--state
		if(v.TagType==1) then
			newCell:FindChild("State/State1").gameObject:SetActive(true)
			newCell:FindChild("State/State1/Text"):GetComponent(Text).text=v.TagDesc
			----print("打折的具体"..v.TagDesc)
		elseif(v.TagType==2) then
			newCell:FindChild("State/State2").gameObject:SetActive(true)
			newCell:FindChild("State/State2/Text"):GetComponent(Text).text=v.TagDesc
		elseif(v.TagType==3) then
			newCell:FindChild("State/State3").gameObject:SetActive(true)
			newCell:FindChild("State/State3/Text"):GetComponent(Text).text=v.TagDesc
		end

		local haveBuy = 0
		--limit
		if(v.Limited) then
			newCell:FindChild("LimitBuy").gameObject:SetActive(true)
			if(v.LimitType==1) then
				newCell:FindChild("LimitBuy/Text"):GetComponent(Text).text="永久限购"
			elseif(v.LimitType==2) then
				newCell:FindChild("LimitBuy/Text"):GetComponent(Text).text="今日限购"
			end
			buyNum=v.LimitAmount
			------print(self.playerShopsDeck.PurchasedLimitCommodities)
			for k1,v1 in pairs(self.playerShopsDeck.PurchasedLimitCommodities) do
				if(v1.ShopId==v.Id) then
					haveBuy=v1.Amount
					buyNum=buyNum-haveBuy
				end
			end
			newCell:FindChild("LimitBuy/Text1"):GetComponent(Text).text=haveBuy.."/"..v.LimitAmount			
		end
		--TimeStateGroup
		if(v.LimitDuration>0) then
			----print("进来了"..v.LimitDuration)
			newCell:FindChild("TimeState").gameObject:SetActive(true)
			newCell:FindChild("TimeState/Text"):GetComponent(Text).text=v.LimitDuration.."天"
		end
		local priceType = 0
		local finalPrice = 0
		--price
		if(v.CoinPrice>0) then
			priceType=1
			newCell:FindChild("PriceGroup/Image3").gameObject:SetActive(true)
			newCell:FindChild("PriceGroup/PriceNum2"):GetComponent(Text).text=v.CoinPrice
			finalPrice=v.CoinPrice
			if(v.Discountable) then
				newCell:FindChild("PriceGroup/PriceNum1").gameObject:SetActive(true)
				newCell:FindChild("PriceGroup/PriceNum1"):GetComponent(Text).text=v.RawCoinPrice
			end

		end
		if(v.GemPrice>0) then
			priceType=2
			newCell:FindChild("PriceGroup/Image2").gameObject:SetActive(true)
			newCell:FindChild("PriceGroup/PriceNum2"):GetComponent(Text).text=v.GemPrice
			finalPrice=v.GemPrice
			if(v.Discountable) then
				newCell:FindChild("PriceGroup/PriceNum1").gameObject:SetActive(true)
				newCell:FindChild("PriceGroup/PriceNum1"):GetComponent(Text).text=v.RawGemPrice
			end	
		end
		if(v.VoucherPrice>0) then
			priceType=3
			newCell:FindChild("PriceGroup/Image1").gameObject:SetActive(true)
			newCell:FindChild("PriceGroup/PriceNum2"):GetComponent(Text).text=v.VoucherPrice
			finalPrice=v.VoucherPrice
			if(v.Discountable) then
				newCell:FindChild("PriceGroup/PriceNum1").gameObject:SetActive(true)
				newCell:FindChild("PriceGroup/PriceNum1"):GetComponent(Text).text=v.RawVoucherPrice
			end	
		end


		--礼包
		local myTable = {}

		if(v.CommodityType==4) then
			if(UTGData.Instance().ItemsData[tostring(v.CommodityId)].Type==16) then
				for k1,v1 in pairs(UTGData.Instance().ItemsData[tostring(v.CommodityId)].Param) do
					local subTable = {}
					subTable["Id"]=v1[1]
					subTable["Type"]=v1[2]
					subTable["Amount"]=v1[3]
					subTable["IsOwn"]=false
					table.insert( myTable,subTable)
					if(subTable.Type==1) then 
						for k2,v2 in pairs(UTGData.Instance().ShopDepreciationsData) do
							if(v.Id==v2.ShopId) then
								if(subTable.Id==v2.TargetId) then
									for k3,v3 in pairs(UTGData.Instance().RolesDeck) do
										if(v3.IsOwn) then
											if(v3.RoleId==subTable.Id) then
												subTable["IsOwn"]=true
												finalPrice=finalPrice-v2.ReducePrice
											end
										end
									end
								end
							end
						end
					end
					if(subTable.Type==2) then 
						for k2,v2 in pairs(UTGData.Instance().ShopDepreciationsData) do
							if(v.Id==v2.ShopId) then
								if(subTable.Id==v2.TargetId) then
									if(UTGData.Instance():IsOwnSkinBySkinId(subTable.Id)) then
										subTable["IsOwn"]=true
										finalPrice=finalPrice-v2.ReducePrice
									end
								end
							end
						end
					end

				end

			end
		end
		----print("看看价格:"..finalPrice)
		--local listener
		--listener = NTGEventTriggerProxy.Get(newCell.gameObject)
		local callback = function(self, e)
    	self:OnClick(v.CommodityId,v.CommodityType,v.Limited,buyNum,priceType,finalPrice,myTable)
  		end
  		UITools.GetLuaScript(newCell,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)
    end
end
function StorePreferentialPanelCtrl:OnDestroy()
	-- body
	self.this = nil
	self =nil
end