require "System.Global"

class("StoreLotteryPanelCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local json = require "cjson"
	
function StoreLotteryPanelCtrl:Awake(this)
	-- body
	self.this = this

	--camera
	self.camera=GameObject.Find("GameLogic"):GetComponent("Camera");
    self.y=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.y
    self.x=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.x
    self.wash= self.x /self.y;
	--mask
	self.mask =self.this.transforms[5]
	--tips
	self.tip=self.this.transforms[6]:GetComponent("RectTransform")
	--self.tips=self.this.transforms[6]:GetComponent("RectTransform")
	--self.tipsText=self.tips:FindChild("Text"):GetComponent("UnityEngine.UI.Text")
	--self.tipsTextTrans=self.tips:FindChild("Text"):GetComponent("RectTransform")
	--top
	self.top = self.this.transforms[0]
	self.topBtn1 =self.top:FindChild("Table1")
	self.btn1Bg= self.topBtn1:FindChild("BG")
	self.btn1Text=self.topBtn1:FindChild("Text"):GetComponent(Text)
	self.Text1OutLine=self.btn1Text.gameObject:GetComponent("UnityEngine.UI.Outline")
	self.topBtn2 =self.top:FindChild("Table2")
	self.btn2Bg= self.topBtn2:FindChild("BG")
	self.btn2Text=self.topBtn2:FindChild("Text"):GetComponent(Text)
	self.Text2OutLine=self.btn2Text.gameObject:GetComponent("UnityEngine.UI.Outline")
	self.timeShowText=self.top:FindChild("TimeShow/Text"):GetComponent(Text)
	--center
	self.center=self.this.transforms[2]
	--effect
	self.animFX_1  = self.this.transforms[7]
	self.animFX_2  = self.this.transforms[8]
	self.animFX_3  = self.this.transforms[9]
	self.animFX_4  = self.this.transforms[10]
	self.animFX_5  = self.this.transforms[11]
	self.animFX_6  = self.this.transforms[13]

	self.effectObj = self.this.transforms[12]


	self.PromoteAnimFx = {}
	table.insert(self.PromoteAnimFx,self.animFX_1)
	table.insert(self.PromoteAnimFx,self.animFX_2)
	table.insert(self.PromoteAnimFx,self.animFX_3)
	table.insert(self.PromoteAnimFx,self.animFX_4)
	table.insert(self.PromoteAnimFx,self.animFX_5)
	table.insert(self.PromoteAnimFx,self.animFX_6)

	--buyInfo
	self.buyInfo=self.center:FindChild("BuyInfo")
	self.buyOneBtn=self.buyInfo:FindChild("BuyButton1")
	self.buyOnePrice=self.buyOneBtn:FindChild("ButtonLayout/Text"):GetComponent(Text)
	self.OneBtnGem=self.buyOneBtn:FindChild("ButtonLayout/Image1")
	self.OneBtnVoucher=self.buyOneBtn:FindChild("ButtonLayout/Image2")
	self.buyFiveBtn=self.buyInfo:FindChild("BuyButton2")
	self.buyFivePrice=self.buyOneBtn:FindChild("ButtonLayout/Text"):GetComponent(Text)
	self.FiveBtnGem=self.buyFiveBtn:FindChild("ButtonLayout/Image1")
	self.FiveBtnVoucher=self.buyFiveBtn:FindChild("ButtonLayout/Image2")
	self.ruleBtn=self.buyInfo:FindChild("RuleButton")
	self.luckNum=self.buyInfo:FindChild("luckNum"):GetComponent(Text)
	--self.luckImage=self.buyInfo:FindChild("mask/Image")
	self.luckImage=self.buyInfo:FindChild("mask/RawImage")
	--rewardInfo
	self.reWardInfo=self.center:FindChild("RewardInfo")
	self.centerCell={}
	for i=1,5 do
		self.centerCell[i]=self.reWardInfo:FindChild("Group/Cell"..i)
	end
	--centent
	self.centent=self.this.transforms[1]
	self.slot=self.this.transforms[4]
	self.cellTable={}

	for i=1,14 do
		local newCell=self.centent:FindChild("Image"..i)
		self.cellTable[i]=newCell
		--------print(self.cellTable[i].gameObject.name)
	end
	--right
	self.right=self.this.transforms[3]
	self.weekNum=self.right:FindChild("Top/Group/Num")
	self.rewads={}
	self.rewadTexts={}
	self.rewadImages={}
	self.rightBtn={}
	for i=1,5 do
		local tempReward =self.right:FindChild("Middle/Cell"..i)
		local tempText = self.right:FindChild("Middle/Cell"..i.."/Text")
		local tempImage =self.right:FindChild("Middle/Cell"..i.."/Image")
		local tempBtn =self.right:FindChild("Middle/Cell"..i.."/BG")
		self.rewads[i]=tempReward
		self.rewadTexts[i]=tempText
		self.rewadImages[i]= tempImage
		self.rightBtn[i]=tempBtn
	end	
	local listener
	listener = NTGEventTriggerProxy.Get(self.topBtn1.gameObject)
	listener.onPointerClick =NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnTopBtn1Click,self)
	listener = NTGEventTriggerProxy.Get(self.topBtn2.gameObject)
	listener.onPointerClick =NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnTopBtn2Click,self)
	listener = NTGEventTriggerProxy.Get(self.ruleBtn.gameObject)
	listener.onPointerClick =NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnRuleBtnClick,self)
	self.txttitle = "夺宝规则"
	self.txtcontent="<size=26><color=#BCBDCF>1、花费60点券或60钻石，可购买36金币，花费270点券或270钻石，可购买180金币。同时赠送一次或者五次夺宝机会，有机会获得稀有物品。\n2、累计夺宝此时达到指定数量时，还可领取额外奖励，累计次数会在每周一中午12点重置。\n3、每夺宝一次，均会增加一定数量的幸运值（1点幸运值），幸运值越高，获得稀有物品的机会就越大，当幸运值满时（满值为200），必能获得一个稀有物品。\n4、点券夺宝中，获得稀有道具时，幸运值将重置为0，且不再累计。\n5、钻石夺宝中，获得稀有道具时，幸运值将重置为0，且不再累计。\n6、幸运值只会对带有“稀有”标签的物品进行概率加成。\n7、已经拥有的姬神或皮肤，在夺宝中不会重复获得。</color></size>"

	self.OneVoucherPay = 60
	self.FiveVoucherPay = 270
	self.OneGemPay = 60
	self.FiveGemPay = 270
end
function StoreLotteryPanelCtrl:OnRuleBtnClick()
	coroutine.start(StoreLotteryPanelCtrl.CreateRulePanelMov,self)
end
function StoreLotteryPanelCtrl:CreateRulePanelMov()
	-- body
	local result = GameManager.CreatePanelAsync("PageText")
  	while result.Done~= true do
    ----------print("deng")
    	coroutine.wait(0.05)
  	end
  	PageTextAPI.instance:Init(self.txttitle,self.txtcontent)
end
function StoreLotteryPanelCtrl:setMask(tempBool)
	-- body
	if StoreCtrl~=nil and StoreCtrl.Instance ~=nil then 
		StoreCtrl.Instance:apiSetMask(tempBool)
	end
end
function StoreLotteryPanelCtrl:OnTopBtn1Click()
	-- body
	self:ShowVoucherContent()
	self:ShowVoucherChest()
	self:UpdateVoucherCenter()
	self.btn1Bg.gameObject:SetActive(true)
	self.btn2Text.color=Color.New(204/225,204/225,204/225,1)
	self.btn1Text.color=Color.New(1,1,1,1)
	self.Text1OutLine.effectColor=Color.New(5/255,137/255,192/255,128/255)
	self.Text2OutLine.effectColor=Color.New(0,0,0,1)

	self.btn2Bg.gameObject:SetActive(false)
	if(self.PanelActive) then 
		self:updateTime(1)
	end
	self.panelstate=1
	self.OneBtnVoucher.gameObject:SetActive(false)

	self.OneBtnGem.gameObject:SetActive(true)
	self.FiveBtnVoucher.gameObject:SetActive(false)
	self.FiveBtnGem.gameObject:SetActive(true)
end
function StoreLotteryPanelCtrl:OnTopBtn2Click()
	-- body
	self:ShowGemContent()
	self:ShowGemChest()
	self:UpdateGemCenter()
	self.btn1Bg.gameObject:SetActive(false)
	self.btn2Text.color=Color.New(1,1,1,1)
	self.btn1Text.color=Color.New(204/225,204/225,204/225,1)
	self.Text1OutLine.effectColor=Color.New(0,0,0,1)
	self.Text2OutLine.effectColor=Color.New(5/255,137/255,192/255,128/255)
	self.btn2Bg.gameObject:SetActive(true)
	if(self.PanelActive) then 
		self:updateTime(2)
	end
	self.panelstate=2
	self.OneBtnVoucher.gameObject:SetActive(true)
	self.OneBtnGem.gameObject:SetActive(false)
	self.FiveBtnVoucher.gameObject:SetActive(true)
	self.FiveBtnGem.gameObject:SetActive(false)
	
end
function StoreLotteryPanelCtrl:updateTime(type)
	-- body
	local leftTimeSeconds=nil
	if(self.timeMove~=nil) then
		coroutine.stop(self.timeMove)
	end
	--self.this:StopAllCoroutines()
	if(type==1) then 
		------print("1Buytime"..self.playerShopsDeck.NextVoucherTreasureRefreshTime)
		leftTimeSeconds = UTGData.Instance():GetLeftTime(self.playerShopsDeck.NextVoucherTreasureRefreshTime)
		if(leftTimeSeconds)>0 then

		self.timeMove = coroutine.start(self.TimeDown,self,leftTimeSeconds) 
		end
	elseif(type==2) then
		------print("2Buytime"..self.playerShopsDeck.NextGemTreasureRefreshTime)
		leftTimeSeconds = UTGData.Instance():GetLeftTime(self.playerShopsDeck.NextGemTreasureRefreshTime)
		if(leftTimeSeconds)>0 then

		self.timeMove = coroutine.start(self.TimeDown,self,leftTimeSeconds) 
		end
	end	
	
end
function StoreLotteryPanelCtrl:TimeDown(count)
	-- body
	local day = 0
	local hour = 0
  	local min = 0
  	local sec = 0
    while count>0 do
    	day = math.floor(count/86400)
    	hour = math.floor((count-day*86400)/3600)
    	min = math.floor((count-day*86400-hour*3600)/60)
    	sec = count - min * 60 - hour * 3600 -day * 86400
    	self.timeShowText.text=string.format("%d天%02d:%02d:%02d",day,hour,min,sec).."后累计个数重置"
    	coroutine.wait(1)
    	count=count-1
    	--------print("shijian"..count)
	end
	UTGData.Instance():UTGDataUpdatePlayerShopDeck()
	coroutine.wait(2)
	if(self.PanelActive) then
		self:UpdateUI()
	end
end
function StoreLotteryPanelCtrl:Start()
	-- body
	for i,v in ipairs(self.PromoteAnimFx) do
    	local btn = self.PromoteAnimFx[i]:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    	for k = 0,btn.Length - 1 do
      		self.PromoteAnimFx[i]:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
    	end
  	end
end
function StoreLotteryPanelCtrl:OnEnable()
	-- body
	self:GetData()
	self:GetDeckData()
	local function sort(a,b)
    return a.Id<b.Id
    end
	table.sort(self.voucherTreasurs,sort)
    table.sort(self.gemTreasurs,sort)
    table.sort(self.voucherTreasursChest,sort)
    table.sort(self.gemTreasursChest,sort)
    self.PanelActive=true
	self:OnTopBtn1Click()
end
function StoreLotteryPanelCtrl:OnDisable()
	-- body
	self.PanelActive=false
end
function StoreLotteryPanelCtrl:GetData()
	-- body
	self.ConfigData =UTGData.Instance().ConfigData
	self.voucherTreasurs={}
	self.gemTreasurs={}
	self.voucherTreasursChest={}
	self.gemTreasursChest={}
	if(UTGData.Instance().ShopTreasuresData==nil) then
	end
	for k,v in pairs(UTGData.Instance().ShopTreasuresData) do
		if(v.Type==1) then
			table.insert(self.voucherTreasurs,v)
		end
		if(v.Type==2) then 
			table.insert(self.gemTreasurs,v)
		end
	end
	for k1,v1 in pairs(UTGData.Instance().ShopTreasureChestsData) do
			if(v1.Type==1) then
			table.insert(self.voucherTreasursChest,v1)
		end
		if(v1.Type==2) then 
			table.insert(self.gemTreasursChest,v1)
		end
	end
end
function StoreLotteryPanelCtrl:GetDeckData()
	self.playerShopsDeck=nil
	local shopsDeck = UTGData.Instance().PlayerShopsDeck
	self.playerShopsDeck=shopsDeck
end
function StoreLotteryPanelCtrl:UpdateVoucherCenter()
	-- body
	self.luckNum.text=self.playerShopsDeck.VoucherTreasureLuckyPoint
	--self.luckImage.sizeDelta = Vector2.New(self.luckImage.sizeDelta.x,220*self.playerShopsDeck.VoucherTreasureLuckyPoint/self.ConfigData["shop_treasure_max_lucky_point"].Int)
	self.luckImage.transform.localPosition =Vector3.New(self.luckImage.transform.localPosition.x,109*self.playerShopsDeck.VoucherTreasureLuckyPoint/self.ConfigData["shop_treasure_max_lucky_point"].Int-120,self.luckImage.transform.localPosition.z)
	self.buyOnePrice=self.ConfigData["shop_voucher_treasure_once_price"].Int
	self.buyFivePrice=self.ConfigData["shop_voucher_treasure_five_times_price"].Int
	local listener
	listener = NTGEventTriggerProxy.Get(self.buyOneBtn.gameObject)
	local callback = function(self, e)
    self:OnBuyButton(1,1)
  	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
	
	listener = NTGEventTriggerProxy.Get(self.buyFiveBtn.gameObject)
	callback = function(self, e)
    self:OnBuyButton(1,5)
  	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
	

end
function StoreLotteryPanelCtrl:UpdateGemCenter()
	-- body
	self.luckNum.text=self.playerShopsDeck.GemTreasureLuckyPoint
	--self.luckImage.sizeDelta = Vector2.New(self.luckImage.sizeDelta.x,220*self.playerShopsDeck.GemTreasureLuckyPoint/self.ConfigData["shop_treasure_max_lucky_point"].Int)
	self.luckImage.transform.localPosition =Vector3.New(self.luckImage.transform.localPosition.x,109*self.playerShopsDeck.GemTreasureLuckyPoint/self.ConfigData["shop_treasure_max_lucky_point"].Int-120,self.luckImage.transform.localPosition.z)
	self.buyOnePrice=self.ConfigData["shop_gem_treasure_once_price"].Int
	self.buyFivePrice=self.ConfigData["shop_gem_treasure_five_times_price"].Int

	local listener
	listener = NTGEventTriggerProxy.Get(self.buyOneBtn.gameObject)
	local callback = function(self, e)
    self:OnBuyButton(2,1)
  	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
	listener = NTGEventTriggerProxy.Get(self.buyFiveBtn.gameObject)
	callback = function(self, e)
    self:OnBuyButton(2,5)
  	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
end
function StoreLotteryPanelCtrl:OnBuyButton(paytype,num)
	if paytype == 2 then 
		local payNum = 0
		if num ==1 then payNum = self.OneGemPay else payNum = self.FiveGemPay end
		local boo = UTGDataOperator.Instance:VoucherToGemNotice(payNum,3,self.sendBuy,self,{PayType = paytype,Num =num})
		if boo == false then self:sendBuy(paytype,num) end
	else
		self:sendBuy(paytype,num)
	end
end
function StoreLotteryPanelCtrl:ShowreWardInfoInfo(tempTable)
	-- body
	self.getTable={}
	local mytable ={}
	local mianTable = {}
	for k2,v2 in pairs(self.centerCell) do
		v2.gameObject:SetActive(false)
	end
	for k1,v1 in pairs(tempTable) do
		------print("小框里的id"..v1)
		table.insert(mytable,UTGData.Instance().ShopTreasuresData[tostring(v1)])
	end
	for k,v in pairs(mytable) do

		self.centerCell[k].gameObject:SetActive(false)
		self.centerCell[k]:FindChild("Icon/Mask").gameObject:SetActive(false)
		self.centerCell[k]:FindChild("Icon/Rune").gameObject:SetActive(false)
		self.centerCell[k]:FindChild("Icon/Item").gameObject:SetActive(false)
		self.centerCell[k]:FindChild("Num").gameObject:SetActive(false)
		self.centerCell[k]:FindChild("Icon/TY1").gameObject:SetActive(false)
		self.centerCell[k]:FindChild("Icon/TY2").gameObject:SetActive(false)

		if(v.TreasureType==1) then
			self.centerCell[k]:FindChild("Icon/Mask").gameObject:SetActive(true)
			self.centerCell[k]:FindChild("Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().SkinsData[tostring(UTGData.Instance().RolesData[tostring(v.TreasureId)].Skin)].Icon)
			self.centerCell[k]:FindChild("Icon"):GetComponent(Image).sprite=UITools.GetSprite("icon",4)
		elseif(v.TreasureType==2) then
			self.centerCell[k]:FindChild("Icon/Mask").gameObject:SetActive(true)
			self.centerCell[k]:FindChild("Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().SkinsData[tostring(v.TreasureId)].Icon)
			self.centerCell[k]:FindChild("Icon"):GetComponent(Image).sprite=UITools.GetSprite("icon",4)
		elseif(v.TreasureType==3) then
			self.centerCell[k]:FindChild("Icon/Rune").gameObject:SetActive(true)
			self.centerCell[k]:FindChild("Icon/Rune"):GetComponent(Image).sprite=UITools.GetSprite("runeicon",UTGData.Instance().RunesData[tostring(v.TreasureId)].Icon)
			self.centerCell[k]:FindChild("Icon"):GetComponent(Image).sprite=UITools.GetSprite("icon",UTGData.Instance().RunesData[tostring(v.TreasureId)].Level)
		elseif(v.TreasureType==4) then
			if(UTGData.Instance().ItemsData[tostring(v.TreasureId)].Type==7) then 
				self.centerCell[k]:FindChild("Icon/Mask").gameObject:SetActive(true)
				self.centerCell[k]:FindChild("Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().ItemsData[tostring(v.TreasureId)].Icon)
				self.centerCell[k]:FindChild("Icon"):GetComponent(Image).sprite=UITools.GetSprite("icon",4)
				self.centerCell[k]:FindChild("Icon/TY2").gameObject:SetActive(true)
			elseif(UTGData.Instance().ItemsData[tostring(v.TreasureId)].Type==8) then
				self.centerCell[k]:FindChild("Icon/Mask").gameObject:SetActive(true)
				self.centerCell[k]:FindChild("Icon/TY1").gameObject:SetActive(true)
				self.centerCell[k]:FindChild("Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().ItemsData[tostring(v.TreasureId)].Icon)
				self.centerCell[k]:FindChild("Icon"):GetComponent(Image).sprite=UITools.GetSprite("icon",4)
			else
				self.centerCell[k]:FindChild("Icon/Item"):GetComponent(Image).sprite=UITools.GetSprite("itemicon",UTGData.Instance().ItemsData[tostring(v.TreasureId)].Icon)
				self.centerCell[k]:FindChild("Icon/Item").gameObject:SetActive(true)
				self.centerCell[k]:FindChild("Icon/Item"):GetComponent(Image).sprite=UITools.GetSprite("itemicon",UTGData.Instance().ItemsData[tostring(v.TreasureId)].Icon)
				self.centerCell[k]:FindChild("Icon"):GetComponent(Image).sprite=UITools.GetSprite("icon",UTGData.Instance().ItemsData[tostring(v.TreasureId)].Quality)
			end
			
		end
		if(v.TreasureNum>1) then 
			self.centerCell[k]:FindChild("Num").gameObject:SetActive(true)
			self.centerCell[k]:FindChild("Num"):GetComponent(Text).text=v.TreasureNum
		else
			self.centerCell[k]:FindChild("Num").gameObject:SetActive(false)
		end
		local subTable = {}
		subTable["Id"]=v.TreasureId
		subTable["Type"]=v.TreasureType
		subTable["Amount"]=v.TreasureNum
		subTable["IsRare"]=v.IsRare
		----print("IsRare"..tostring(subTable["IsRare"]))
		table.insert(mianTable,subTable)
	end
	self.getTable=mianTable
end
function StoreLotteryPanelCtrl:sendOpen(Id)
	-- body
	self:setMask(true)
	local openInfoRequest = NetRequest.New()
	openInfoRequest.Content=JObject.New(JProperty.New("Type","RequestOpenTreasureChest"),JProperty.New("ChestId",Id))
	openInfoRequest.Handler=TGNetService.NetEventHanlderSelf(StoreLotteryPanelCtrl.sendOpenHandler,self)
	TGNetService.GetInstance():SendRequest(openInfoRequest)
end
function StoreLotteryPanelCtrl:sendOpenHandler(e)
	-- body
	if e.Type == "RequestOpenTreasureChest" then
		local result = tonumber(e.Content:get_Item("Result"):ToString())
		if result == 1 then
			------print("开启宝箱成功了")
			self:setMask(false)
			return true
		end
	end
	return false
end
function StoreLotteryPanelCtrl:sendBuy(type,num)
	-- body
	self:setMask(true)
	local buyInfoRequest = NetRequest.New()
	buyInfoRequest.Content=JObject.New(JProperty.New("Type","RequestRollTreasure"),JProperty.New("TreasureType",type),JProperty.New("Count",num))
	buyInfoRequest.Handler=TGNetService.NetEventHanlderSelf(StoreLotteryPanelCtrl.sendBuyHandler,self)
	TGNetService.GetInstance():SendRequest(buyInfoRequest)
	--self.mask.gameObject:SetActive(true)
	self.effectObj.gameObject:SetActive(true)
end
function StoreLotteryPanelCtrl:UpdateUI()
		if(self.panelstate==1) then 
			self:GetDeckData()
			------print("看看变了没"..UTGData.Instance().PlayerShopsDeck.VoucherTreasureLuckyPoint)
			self:OnTopBtn1Click()
	 	else
	 		self:GetDeckData()
	 		self:OnTopBtn2Click()
	 	end
end
function StoreLotteryPanelCtrl:sendBuyHandler(e)
	self.getTreasureIds={}
	if e.Type == "RequestRollTreasure" then
		local result = tonumber(e.Content:get_Item("Result"):ToString())
		------print(result)
	 	if result == 1 then
	 		local TreasureIds = json.decode(e.Content:get_Item("TreasureIds"):ToString())
	 		if(TreasureIds==nil) then 
	 			----print("竟然是空的") 
	 		end
	 		local x = table.getn(TreasureIds)
	 		local mytable={}
	 		if(x>0) then
	 			self.getTreasureIds=TreasureIds
	 			if(self.panelstate==1) then 
	 				for k,v in pairs(self.getTreasureIds) do
	 					------print("k"..k)
	 					------print("得到的ID"..v)
	 					for k1,v1 in pairs(self.voucherTreasurs) do
	 						if(v==v1.Id) then 
	 							table.insert(mytable,k1)
	 							------print("查到的Index"..k1)
	 						end
	 					end
	 				end
	 			end
	 			if(self.panelstate==2) then
	 				for k,v in pairs(self.getTreasureIds) do
	 					for k1,v1 in pairs(self.gemTreasurs) do
	 						if(v==v1.Id) then 
	 							table.insert(mytable,k1)
	 						end
	 					end
	 				end
	 			end
	 			self:ShowreWardInfoInfo(self.getTreasureIds)
	 			self:UpdateSlot(mytable)
	 		end
			return true
	 	elseif result == 2819 then
    		local dialog = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
	      	dialog:InitNoticeForNeedConfirmNotice("提示", "您的金币不足", false,"", 1,false)
	      	dialog:OneButtonEvent("确定",dialog.DestroySelf,dialog)
	      	dialog:SetTextToCenter()
	      	dialog:HideCloseButton(false)
	      	self.effectObj.gameObject:SetActive(false)
	      	self:setMask(false)
	      	return true
		elseif result == 2820 then
		    local dialog = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
		    dialog:InitNoticeForNeedConfirmNotice("提示", "您的钻石不足", false,"", 1,false)
		    dialog:OneButtonEvent("确定",dialog.DestroySelf,dialog)
		    dialog:SetTextToCenter()
		   	dialog:HideCloseButton(false)
		   	self.effectObj.gameObject:SetActive(false)
		   	self:setMask(false)
		    return true
	  	elseif result == 2821 then
		    UTGDataOperator.Instance:VoucherNotEnoughNotice()
		    self.effectObj.gameObject:SetActive(false)
		    self:setMask(false)
		    return true     
		end

	end
	return false
end
function StoreLotteryPanelCtrl:ShowVoucherChest()
	-- body
	local n = 1
	for k,v in pairs(self.voucherTreasursChest) do
		local get = false
		self.rewadTexts[n]:GetComponent(Text).color=Color.New(72/255,1,252/255,1)
		self.rewadImages[n]:GetComponent(Image).color=Color.New(1,1,1,1)
		self.rewadTexts[n]:GetComponent(Text).text=v.Count.."个"
		if(self.playerShopsDeck.VoucherTreasureCount<v.Count) then
			self.rewadTexts[n]:GetComponent(Text).color=Color.New(0.4,0.4,0.4,1)
			self.rewadImages[n]:GetComponent(Image).color=Color.New(0.4,0.4,0.4,1)
		else
			for k1,v1 in pairs(self.playerShopsDeck.TreasureOpenedChests) do
				------print("caice")
				if(v.Id==v1) then
					------print("youai"..v.Id)
					self.rewadTexts[n]:GetComponent(Text).text="已领取"
					self.rewadTexts[n]:GetComponent(Text).color=Color.New(0.4,0.4,0.4,1)
					self.rewadImages[n]:GetComponent(Image).color=Color.New(0.4,0.4,0.4,1)
					get=true
				end
			end
		end
		local myTable = {}
		for k1,v1 in pairs(UTGData.Instance().ItemsData[tostring(v.RewardId)].Param) do
			local subTable = {}
			subTable["Id"]=v1[1]
			subTable["Type"]=v1[2]
			subTable["Amount"]=v1[3]
			table.insert(myTable,subTable)
		end
		local listener
		listener = NTGEventTriggerProxy.Get(self.rightBtn[n].gameObject)
		local callback = function(self, e)
    	self:OnChestClick(v.Id,v.RewardId,3,self.ConfigData["shop_voucher_treasure_once_price"].Int,v.Count,self.playerShopsDeck.VoucherTreasureCount,get,myTable)
  		end
		listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
		n=n+1
	end
	self.weekNum:GetComponent(Text).text=self.playerShopsDeck.VoucherTreasureCount
end
function StoreLotteryPanelCtrl:ShowGemChest()
	-- body
	local n = 1
	for k,v in pairs(self.gemTreasursChest) do
		local get = false
		self.rewadTexts[n]:GetComponent(Text).color=Color.New(72/255,1,252/255,1)
		self.rewadImages[n]:GetComponent(Image).color=Color.New(1,1,1,1)
		self.rewadTexts[n]:GetComponent(Text).text=v.Count.."个"
		if(self.playerShopsDeck.GemTreasureCount<v.Count) then
			self.rewadTexts[n]:GetComponent(Text).color=Color.New(0.4,0.4,0.4,1)
			self.rewadImages[n]:GetComponent(Image).color=Color.New(0.4,0.4,0.4,1)
		else
			for k1,v1 in pairs(self.playerShopsDeck.TreasureOpenedChests) do
				if(v.Id==v1) then
					self.rewadTexts[n]:GetComponent(Text).text="已领取"
					self.rewadTexts[n]:GetComponent(Text).color=Color.New(0.4,0.4,0.4,1)
					self.rewadImages[n]:GetComponent(Image).color=Color.New(0.4,0.4,0.4,1)
					get=true
				end
			end
		end
		local myTable = {}
		for k1,v1 in pairs(UTGData.Instance().ItemsData[tostring(v.RewardId)].Param) do
			local subTable = {}
			subTable["Id"]=v1[1]
			subTable["Type"]=v1[2] 
			subTable["Amount"]=v1[3]
			table.insert(myTable,subTable)
		end
		local listener
		listener = NTGEventTriggerProxy.Get(self.rightBtn[n].gameObject)
		local callback = function(self, e)
    	self:OnChestClick(v.Id,v.RewardId,2,self.ConfigData["shop_gem_treasure_once_price"].Int,v.Count,self.playerShopsDeck.GemTreasureCount,get,myTable)
  		end
		listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
		n=n+1
	end
	self.weekNum:GetComponent(Text).text=self.playerShopsDeck.GemTreasureCount
end
function StoreLotteryPanelCtrl:OnChestClick(chestId,rewardId,type,price,count,have,get,aTable)
	-- body
	local text =""
	local title =""
	local buyType=0
	if(type==2) then 
		title="钻石夺宝奖励"
		buyType=2

	else
		title="点券夺宝奖励"
		buyType=1
	end
	local dialog =UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
	if(have<count) then 
		dialog:InitNoticeForNeedConfirmNotice(title,"<size=26><color=#BCBDCF>您已累计购买<color=#C7D61C>"..have.."</color>个</color></size>",true,"<size=26><color=#BCBDCF>再购买<color=#C7D61C>"..count-have.."</color>个即可获取以下奖励</color></size>",4,true)
		local callback = function(self, e)
		 self:OnBuyButton(buyType,1)
		 dialog:DestroySelf()
		end
		dialog:ButtonEventType4(type,price,"再买一个",callback,self,"去完成",dialog.DestroySelf,dialog)
		dialog:HideCloseButton(false)
		dialog:FxControl(false)
	else
		if(get) then
			------print("竟然领取了么")
			local callback = function(self, e)
		 	self:OnBuyButton(buyType,1)
		 	dialog:DestroySelf()
			end
			dialog:InitNoticeForNeedConfirmNotice(title,"<size=26><color=#BCBDCF>您已累计购买<color=#C7D61C>"..count.."</color>个</color></size>",false,"",4,true)
			dialog:ButtonEventType4(type,price,"再买一个",callback,self,"已领取",dialog.DestroySelf,dialog)
			dialog:HideCloseButton(false)
			dialog:FxControl(false)
		else
			------print("有一个还没领取哒")
			local callback = function(self, e)
		 	self:OnBuyButton(buyType,1)
		 	dialog:DestroySelf()
			end
			local callback1 = function(self, e)
		 	self:sendOpen(chestId)
		 	dialog:DestroySelf()
			end
			dialog:InitNoticeForNeedConfirmNotice(title,"<size=26><color=#BCBDCF>您已累计购买<color=#C7D61C>"..count.."</color>个</color></size>",false,"",4,true)
			dialog:ButtonEventType4(type,price,"再买一个",callback,self,"领取",callback1,self)
			dialog:HideCloseButton(false)
			dialog:FxControl(false)
		end
	end
	dialog:ImagePanelControl(aTable)
	------print("chestId"..chestId.."rewardId"..rewardId)
end

function StoreLotteryPanelCtrl:ShowVoucherContent()
	-- body
	local n = 1
	for k,v in pairs(self.voucherTreasurs) do
		self.cellTable[n]:FindChild("State/Left/State1").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Middle/Icon").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Left/State3").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Left/State3").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Middle/Rune").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Middle/Item").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/right").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Middle/Icon/TY2").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Middle/Icon/TY1").gameObject:SetActive(false)
		if(v.IsUltra) then
			self.cellTable[n]:FindChild("State/Left/State1").gameObject:SetActive(true)
		end
		if(v.TreasureType==1) then
			self.cellTable[n]:FindChild("State/buttom/Text"):GetComponent(Text).text=UTGData.Instance().RolesData[tostring(v.TreasureId)].Name
			self.cellTable[n]:FindChild("State/Middle/Icon").gameObject:SetActive(true)
			--------print("TreasureId"..UTGData.Instance().RolesData[tostring(v.TreasureId)].Skin)
			self.cellTable[n]:FindChild("State/Middle/Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().SkinsData[tostring(UTGData.Instance().RolesData[tostring(v.TreasureId)].Skin)].Icon)
			for k1,v1 in pairs(UTGData.Instance().RolesDeck) do
				if(v1.IsOwn) then
					if(v1.RoleId==v.TreasureId) then
						self.cellTable[n]:FindChild("State/Left/State3").gameObject:SetActive(true)
					end
				end
			end
		elseif(v.TreasureType==2) then
			self.cellTable[n]:FindChild("State/buttom/Text"):GetComponent(Text).text=UTGData.Instance().SkinsData[tostring(v.TreasureId)].Name
			self.cellTable[n]:FindChild("State/Middle/Icon").gameObject:SetActive(true)
			self.cellTable[n]:FindChild("State/Middle/Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().SkinsData[tostring(v.TreasureId)].Icon)
			for k1,v1 in pairs(UTGData.Instance().SkinsDeck) do
				if(v1.IsOwn) then
					if(v1.SkinId==v.TreasureId) then
						self.cellTable[n]:FindChild("State/Left/State3").gameObject:SetActive(true)
					end
				end
			end
		elseif(v.TreasureType==3) then 
			self.cellTable[n]:FindChild("State/buttom/Text"):GetComponent(Text).text=UTGData.Instance().RunesData[tostring(v.TreasureId)].Name
			self.cellTable[n]:FindChild("State/Middle/Rune").gameObject:SetActive(true)
			self.cellTable[n]:FindChild("State/Middle/Rune"):GetComponent(Image).sprite=UITools.GetSprite("runeicon",UTGData.Instance().RunesData[tostring(v.TreasureId)].Icon)
		elseif(v.TreasureType==4) then
			if(UTGData.Instance().ItemsData[tostring(v.TreasureId)].Type==7) then 
				self.cellTable[n]:FindChild("State/Middle/Icon").gameObject:SetActive(true)
				self.cellTable[n]:FindChild("State/Middle/Icon/TY2").gameObject:SetActive(true)
				self.cellTable[n]:FindChild("State/Middle/Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().ItemsData[tostring(v.TreasureId)].Icon)
			elseif(UTGData.Instance().ItemsData[tostring(v.TreasureId)].Type==8) then
				self.cellTable[n]:FindChild("State/Middle/Icon/TY1").gameObject:SetActive(true)
				self.cellTable[n]:FindChild("State/Middle/Icon").gameObject:SetActive(true)
				self.cellTable[n]:FindChild("State/Middle/Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().ItemsData[tostring(v.TreasureId)].Icon)
			else
				self.cellTable[n]:FindChild("State/Middle/Item").gameObject:SetActive(true)
				self.cellTable[n]:FindChild("State/Middle/Item"):GetComponent(Image).sprite=UITools.GetSprite("itemicon",UTGData.Instance().ItemsData[tostring(v.TreasureId)].Icon)
			end
			self.cellTable[n]:FindChild("State/buttom/Text"):GetComponent(Text).text=UTGData.Instance().ItemsData[tostring(v.TreasureId)].Name
		end 
		if(v.TreasureNum>1) then
			self.cellTable[n]:FindChild("State/right").gameObject:SetActive(true)
			self.cellTable[n]:FindChild("State/right/Text"):GetComponent(Text).text=v.TreasureNum
		end
		if(v.TreasureType==1)  then
			local listener
			listener = NTGEventTriggerProxy.Get(self.cellTable[n]:FindChild("BG").gameObject)
			local callback = function(self, e)
    		self:OnJumpPanel(v.TreasureId,-1)
  			end
			listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
			callback = function(self, e)
  			end
			listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
			listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
		elseif(v.TreasureType==2) then
			local listener
			listener = NTGEventTriggerProxy.Get(self.cellTable[n]:FindChild("BG").gameObject)
			local callback = function(self, e)
    		self:OnJumpPanel(UTGData.Instance().SkinsData[tostring(v.TreasureId)].RoleId,v.TreasureId)
  			end
			listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
			callback = function(self, e)
  			end
			listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
			listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
		else
			local listener
			listener = NTGEventTriggerProxy.Get(self.cellTable[n]:FindChild("BG").gameObject)
			local callback = function(self, e)
    		self:ShowTipsControl(v.TreasureId,v.TreasureType)
  			end
			listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
			local callback1 = function(self, e)
			self:UpTips()
			end
			listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1,self)
			callback = function(self, e)
  			end
			listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)

		end
		n=n+1
	end
end
function StoreLotteryPanelCtrl:OnTips(treasureId,myType)
	-- body
	------print("OnTips"..treasureId)
	if (myType ==3) then 
		local artTabel=UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",treasureId)
		local tipContenet =""
		local x = 1
		for k,v in pairs(artTabel) do
			tipContenet=v.Des.."+"..v.Attr
			if(table.getn(artTabel)>x) then
				tipContenet=v.Des.."+"..v.Attr.."\n"
			end
			self.tipsText.text=self.tipsText.text..tipContenet
			x=x+1
		end
	elseif (myType == 4) then
		self.tipsText.text=UTGData.Instance().ItemsData[tostring(treasureId)].Desc
	end
	self.tips.localPosition=self:MouseToUIposition(Input.mousePosition)
	--self.tips.sizeDelta = self.tipsTextTrans.sizeDelta
	self.tips.gameObject:SetActive(true)
end
function StoreLotteryPanelCtrl:UpTips()
	-- body
	self.tip.gameObject:SetActive(false)
end
function StoreLotteryPanelCtrl:ShowTipsControl(RIid,RItype)
	-- body
	local Data = UTGData.Instance()
	local itemName = ""
	local ownNum = 0
	local desc = ""
	if(RItype==3) then 
		itemName = Data.RunesData[tostring(RIid)].Name
		if( Data.RunesDeck[tostring(RIid)]~=nil) then 
			ownNum = Data.RunesDeck[tostring(RIid)].Amount
		end
		local attrs = UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",RIid)
		local str = ""
		for i = 1,#attrs do
			str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr 
			--str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr .. "\n"
			if(i<table.getn(attrs)) then
				str = str.."\n"
			end
		end
		----print("attrs " .. str)
		desc = str	
	elseif(RItype==4) then 
		itemName = Data.ItemsData[tostring(RIid)].Name
		local itemData = Data.ItemsData[tostring(RIid)]

		if itemData.Type == 13 then
			--desc = itemData.Desc
			ownNum = Data.PlayerData.Coin .. "个"
		elseif itemData.Type == 14 then		
			--desc = itemData.Desc
			ownNum = Data.PlayerData.Coin .. "个"
		elseif itemData.Type == 15 then				
			--desc = itemData.Desc
			ownNum = Data.PlayerData.Exp
		elseif itemData.Type == 17 then	
			--desc = itemData.Desc
			ownNum = Data.PlayerData.RunePiece.."个"
		else
			--desc = itemData.Desc
			if(Data.ItemsDeck[tostring(RIid)]~=nil) then 
				ownNum = Data.ItemsDeck[tostring(RIid)].Amount
			end
		end
		desc = itemData.Desc
	end
	self.tip.gameObject:SetActive(true)
	local pos = self.camera:ScreenToWorldPoint(Input.mousePosition)
	--local pos = Input.mousePosition
	self.tip.position = Vector3.New(pos.x,pos.y,0)
	self.tip.localPosition = Vector3.New(self.tip.localPosition.x,self.tip.localPosition.y,0)
	self.tip:Find("Panel/ItemName"):GetComponent(Text).text = itemName
	self.tip:Find("Panel2/Own/OwnNum"):GetComponent(Text).text = ownNum
	self.tip:Find("Desc"):GetComponent(Text).text = desc
end
function StoreLotteryPanelCtrl:MouseToUIposition(mousePosition) --Input.mousePosition
    
    --local y=self.y;--720要改的吧从canvas获取
    --local wash= Screen.width / Screen.height;
    --local screenPos = self.UICamera:ScreenToViewportPoint(mousePosition);
    --return Vector3.New((screenPos.x - 0.5) * y * wash-self.tips.sizeDelta.x/2, (screenPos.y - 0.5) * y, 0);

    local screenPos = self.camera:ScreenToViewportPoint(mousePosition);
    return Vector3.New((screenPos.x - 0.5) * self.y * self.wash+self.tips.sizeDelta.x/2, (screenPos.y - 0.5) * self.y, 0);

end
function StoreLotteryPanelCtrl:OnJumpPanel(roleId,skinId)
	-- body
	--------print("OnJumpPanel"..roleId)
	------print("skinId"..skinId)
	coroutine.start(StoreLotteryPanelCtrl.CreateHeroInfoPanelMov,self,roleId,skinId)
end
function StoreLotteryPanelCtrl:CreateHeroInfoPanelMov(roleId,skinId)
	--Debugger.LogError(roleId.." "..skinId)
	if skinId == -1 then 
		skinId = UTGData.Instance().RolesData[tostring(roleId)].Skin
	end
	local myTable = {}
	local result = GameManager.CreatePanelAsync("HeroInfo")
  	while result.Done~= true do
    	coroutine.step()
	end
    HeroInfoAPI.Instance:Init(roleId,myTable)
    HeroInfoAPI.Instance:InitCenterBySkinId(skinId,{[1] = skinId})

end
function StoreLotteryPanelCtrl:ShowGemContent()
	-- body
	local n = 1
	for k,v in pairs(self.gemTreasurs) do
		self.cellTable[n]:FindChild("State/Left/State1").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Middle/Icon").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Left/State3").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Left/State3").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Middle/Rune").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Middle/Item").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/right").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Middle/Icon/TY2").gameObject:SetActive(false)
		self.cellTable[n]:FindChild("State/Middle/Icon/TY1").gameObject:SetActive(false)
		if(v.IsUltra) then
			self.cellTable[n]:FindChild("State/Left/State1").gameObject:SetActive(true)
		end

		if(v.TreasureType==1) then
			self.cellTable[n]:FindChild("State/buttom/Text"):GetComponent(Text).text=UTGData.Instance().RolesData[tostring(v.TreasureId)].Name
			self.cellTable[n]:FindChild("State/Middle/Icon").gameObject:SetActive(true)
			self.cellTable[n]:FindChild("State/Middle/Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().SkinsData[tostring(UTGData.Instance().RolesData[tostring(v.TreasureId)].Skin)].Icon)
			for k1,v1 in pairs(UTGData.Instance().RolesDeck) do
				if(v1.IsOwn) then
					if(v1.RoleId==v.TreasureId) then
						self.cellTable[n]:FindChild("State/Left/State3").gameObject:SetActive(true)
					end
				end
			end
		elseif(v.TreasureType==2) then
			self.cellTable[n]:FindChild("State/buttom/Text"):GetComponent(Text).text=UTGData.Instance().SkinsData[tostring(v.TreasureId)].Name
			self.cellTable[n]:FindChild("State/Middle/Icon").gameObject:SetActive(true)
			self.cellTable[n]:FindChild("State/Middle/Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().SkinsData[tostring(v.TreasureId)].Icon)
			for k1,v1 in pairs(UTGData.Instance().SkinsDeck) do
				if(v1.IsOwn) then
					if(v1.SkinId==v.TreasureId) then
						self.cellTable[n]:FindChild("State/Left/State3").gameObject:SetActive(true)
					end
				end
			end
		elseif(v.TreasureType==3) then 
			self.cellTable[n]:FindChild("State/buttom/Text"):GetComponent(Text).text=UTGData.Instance().RunesData[tostring(v.TreasureId)].Name
			self.cellTable[n]:FindChild("State/Middle/Rune").gameObject:SetActive(true)
			self.cellTable[n]:FindChild("State/Middle/Rune"):GetComponent(Image).sprite=UITools.GetSprite("runeicon",UTGData.Instance().RunesData[tostring(v.TreasureId)].Icon)
		elseif(v.TreasureType==4) then
			if(UTGData.Instance().ItemsData[tostring(v.TreasureId)].Type==7) then 
				self.cellTable[n]:FindChild("State/Middle/Icon").gameObject:SetActive(true)
				self.cellTable[n]:FindChild("State/Middle/Icon/TY2").gameObject:SetActive(true)
				self.cellTable[n]:FindChild("State/Middle/Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().ItemsData[tostring(v.TreasureId)].Icon)
			elseif(UTGData.Instance().ItemsData[tostring(v.TreasureId)].Type==8) then
				self.cellTable[n]:FindChild("State/Middle/Icon/TY1").gameObject:SetActive(true)
				self.cellTable[n]:FindChild("State/Middle/Icon").gameObject:SetActive(true)
				self.cellTable[n]:FindChild("State/Middle/Icon/Mask/Image"):GetComponent(Image).sprite=UITools.GetSprite("roleicon",UTGData.Instance().ItemsData[tostring(v.TreasureId)].Icon)
			else
				self.cellTable[n]:FindChild("State/Middle/Item").gameObject:SetActive(true)
				self.cellTable[n]:FindChild("State/Middle/Item"):GetComponent(Image).sprite=UITools.GetSprite("itemicon",UTGData.Instance().ItemsData[tostring(v.TreasureId)].Icon)
			end
			self.cellTable[n]:FindChild("State/buttom/Text"):GetComponent(Text).text=UTGData.Instance().ItemsData[tostring(v.TreasureId)].Name
			
		end 
		if(v.TreasureNum>1) then
			self.cellTable[n]:FindChild("State/right").gameObject:SetActive(true)
			self.cellTable[n]:FindChild("State/right/Text"):GetComponent(Text).text=v.TreasureNum
		end
		if(v.TreasureType==1)  then
			local listener
			listener = NTGEventTriggerProxy.Get(self.cellTable[n]:FindChild("BG").gameObject)
			local callback = function(self, e)
    		self:OnJumpPanel(v.TreasureId,-1)
  			end
			listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
			callback = function(self, e)
  			end
			listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
			listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
		elseif(v.TreasureType==2) then
			local listener
			listener = NTGEventTriggerProxy.Get(self.cellTable[n]:FindChild("BG").gameObject)
			local callback = function(self, e)
    		self:OnJumpPanel(UTGData.Instance().SkinsData[tostring(v.TreasureId)].RoleId,v.TreasureId)
  			end
			listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
			callback = function(self, e)
  			end
			listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
			listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
		else
			local listener
			listener = NTGEventTriggerProxy.Get(self.cellTable[n]:FindChild("BG").gameObject)
			local callback = function(self, e)
    		self:ShowTipsControl(v.TreasureId,v.TreasureType)
  			end
			listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
			local callback1 = function(self, e)
			self:UpTips()
			end
			listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1,self)
			callback = function(self, e)
  			end
			listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
		end
		n=n+1
	end
end
function StoreLotteryPanelCtrl:UpdateSlot(tempSlots)
	-- body
	if(table.getn(tempSlots)==1) then
    self.slotMove =coroutine.start( self.moveNextSlot,self,tempSlots[1] )  

	elseif(table.getn(tempSlots)>1) then
    self.slotMove =coroutine.start(self.moveNextSlot, self,tempSlots[1],tempSlots )  
	end
    
	
end
function StoreLotteryPanelCtrl:moveNextSlot(fistSlot,otherSlots)
	local y = 1
	for i=1,3 do
		self.slot.gameObject:SetActive(true)
		self.slot.transform:SetParent(self.cellTable[y])
		self.slot.transform.localPosition = Vector3.zero
		y=y+1
		while y~=1 do
			coroutine.wait(0.05)
			if(y==14) then
				y=1
			else
				y=y+1
			end
			self.slot.transform:SetParent(self.cellTable[y])
			self.slot.transform.localPosition = Vector3.zero
		end
	end
	self.effectObj.gameObject:SetActive(false)
	local x = 1
	while x~=fistSlot do
		coroutine.wait(0.05)
		if(x==14) then
			x=1
		else
			x=x+1
		end
		self.slot.transform:SetParent(self.cellTable[x])
		self.slot.transform.localPosition = Vector3.zero
	end
	self.buyInfo.gameObject:SetActive(false)
	self.reWardInfo.gameObject:SetActive(true)
	self.centerCell[1].gameObject:SetActive(true)
	coroutine.wait(0.05)
	self.slot.gameObject:SetActive(false)
	coroutine.wait(0.05)
	self.slot.gameObject:SetActive(true)
	coroutine.wait(0.05)
	self.slot.gameObject:SetActive(false)
	coroutine.wait(0.05)
	self.slot.gameObject:SetActive(true)
	coroutine.wait(0.05)

	if(otherSlots~=nil) then
		if(otherSlots[2]==fistSlot) then 
			x=x+1
		end
		while x~=otherSlots[2] do
			coroutine.wait(0.05)
			if(x==14) then
				x=1
			else
				x=x+1
			end
			self.slot.transform:SetParent(self.cellTable[x])
			self.slot.transform.localPosition = Vector3.zero
		
		end
		self.centerCell[2].gameObject:SetActive(true)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(false)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(true)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(false)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(true)
		coroutine.wait(0.05)
		
		if(otherSlots[3]==otherSlots[2]) then 
			x=x+1
		end
		while x~=otherSlots[3] do
			coroutine.wait(0.05)
			
			if(x==14) then
				x=1
			else
				x=x+1
			end
			self.slot.transform:SetParent(self.cellTable[x])
			self.slot.transform.localPosition = Vector3.zero
		end
		self.centerCell[3].gameObject:SetActive(true)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(false)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(true)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(false)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(true)
		coroutine.wait(0.05)
		
		if(otherSlots[4]==otherSlots[3]) then 
			x=x+1
		end
		while x~=otherSlots[4] do
			coroutine.wait(0.05)
			if(x==14) then
				x=1
			else
				x=x+1
			end
			self.slot.transform:SetParent(self.cellTable[x])
			self.slot.transform.localPosition = Vector3.zero
		end
		self.centerCell[4].gameObject:SetActive(true)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(false)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(true)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(false)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(true)
		coroutine.wait(0.05)
		
		if(otherSlots[5]==otherSlots[4]) then 
			x=x+1
		end
		while x~=otherSlots[5] do
			coroutine.wait(0.05)
			if(x==14) then
				x=1
			else
				x=x+1
			end
			self.slot.transform:SetParent(self.cellTable[x])
			self.slot.transform.localPosition = Vector3.zero
		end
		self.centerCell[5].gameObject:SetActive(true)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(false)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(true)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(false)
		coroutine.wait(0.05)
		self.slot.gameObject:SetActive(true)
		coroutine.wait(0.05)
	end
	self.slot.gameObject:SetActive(false)
	coroutine.wait(0.5)
	local dialog =UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
	local title=" "
	local buyType =1
	local buyNum =1
	local btnName =" "
	local priceTpye=3
	local price = 0
	if(otherSlots~=nil) then
		btnName="再买五个"
		buyNum =5

	else
		btnName="再买一个"
		buyNum =1
	end
	if(self.panelstate==1) then 
		title="获得奖励"
		buyType=1
		priceTpye=3
		price=self.ConfigData["shop_voucher_treasure_once_price"].Int
		if(buyNum==5) then 
			price=self.ConfigData["shop_voucher_treasure_five_times_price"].Int
		end
	else
		title="获得奖励"
		buyType=2
		priceTpye=2
		price=self.ConfigData["shop_gem_treasure_once_price"].Int
		if(buyNum==5) then 
			price=self.ConfigData["shop_gem_treasure_five_times_price"].Int
		end
	end
	dialog:InitNoticeForNeedConfirmNotice(title,"",false,"",4,true)
	local callback = function(self, e)
		self.reWardInfo.gameObject:SetActive(false)
		self.buyInfo.gameObject:SetActive(true)
		self:OnBuyButton(buyType,buyNum)
		dialog:DestroySelf()
	end 
	local callback1 = function(self, e)
		
		dialog:DestroySelf()
		self.reWardInfo.gameObject:SetActive(false)
		self.buyInfo.gameObject:SetActive(true)
	end 
	dialog:ButtonEventType4(priceTpye,price,btnName,callback,self,"确定",callback1,self)
	dialog:ImagePanelControl(self.getTable)
	dialog:FxControl(true)
	dialog:DoShowByStep(buyNum)
	--self.mask.gameObject:SetActive(false)
		self:setMask(false)
end
function StoreLotteryPanelCtrl:OnDestroy()
	-- body
  coroutine.stop(self.timeMove)
	self.this = nil
	self =nil
end