require "System.Global"

class("StoreRunePanelCtrl")
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local json = require "cjson"
local Image = "UnityEngine.UI.Image"
function StoreRunePanelCtrl:Awake(this)
	-- body
	self.this = this
	--camera
	self.camera=GameObject.Find("GameLogic"):GetComponent("Camera");
    self.y=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.y
    self.x=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.x
    self.wash= self.x /self.y;
	--coinBuyPart
	self.coinBuyPart=self.this.transforms[0]
	self.coinPartTitle=self.coinBuyPart:FindChild("Title"):GetComponent("UnityEngine.UI.Text")
	self.coinOneBtn=self.coinBuyPart:FindChild("BuyOneBtn")
	self.coinFiveBtn=self.coinBuyPart:FindChild("BuyFiveBtn")
	self.coinOnePrice=self.coinBuyPart:FindChild("OnePrice/Text"):GetComponent("UnityEngine.UI.Text")
	self.coinFivePrice=self.coinBuyPart:FindChild("FivePrice/Text"):GetComponent("UnityEngine.UI.Text")
	--daimondsBuyPart
	self.diamondsBuyPart=self.this.transforms[1]
	self.diamondsPartTitle=self.diamondsBuyPart:FindChild("Title"):GetComponent("UnityEngine.UI.Text")
	self.diamondsOneBtn=self.diamondsBuyPart:FindChild("BuyOneBtn")
	self.diamondsFiveBtn=self.diamondsBuyPart:FindChild("BuyFiveBtn")
	self.diamondsOnePrice=self.diamondsBuyPart:FindChild("OnePrice/Text"):GetComponent("UnityEngine.UI.Text")
	self.diamondsFivePrice=self.diamondsBuyPart:FindChild("FivePrice/Text"):GetComponent("UnityEngine.UI.Text")
	self.BuyTimeInfo=self.diamondsBuyPart:FindChild("BuyTimeInfo")
	self.BuyTimeText=self.BuyTimeInfo:FindChild("BuyTimeCount"):GetComponent("UnityEngine.UI.Text")
	--mask
	self.mask=self.this.transforms[2]
	--3D物体
	self.AnimObject=self.this.transforms[3]
	self.Eobj1=self.AnimObject:FindChild("R51140470")
	self.Eobj2=self.AnimObject:FindChild("R51140480")
	self.Eobj3=self.AnimObject:FindChild("R51140481")

	self.oneRune=self.this.transform:FindChild("Rune")
	self.runes={}
	for i=1,5 do
		self.runes[i]=self.this.transform:FindChild("Rune"..i)
	end

	--tips
	self.tip=self.this.transform:FindChild("Tips")
	--bottomUI
	self.bottomUI=self.this.transform:FindChild("BottomUI"):GetComponent("Animator")
	--listner
	local listener
	--coin
	listener = NTGEventTriggerProxy.Get(self.coinOneBtn.gameObject)
	listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnCoinOneBtn,self)

	listener = NTGEventTriggerProxy.Get(self.coinFiveBtn.gameObject)
	listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnCoinFiveBtn,self)
	--diamonds
	listener = NTGEventTriggerProxy.Get(self.diamondsOneBtn.gameObject)
	listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnDiamondsOneBtn,self)

	listener = NTGEventTriggerProxy.Get(self.diamondsFiveBtn.gameObject)
	listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnDiamondsFiveBtn,self)

	self.oneCoinPay = 200
	self.oneGemPay = 120
	self.fiveCoinPay = 800
	self.fiveGemPay = 568

	self:SetFxOk(self.AnimObject)

end
------tools function-------
function StoreRunePanelCtrl:SetFxOk(model)
  local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,btn.Length - 1 do
    model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
  end
end

function StoreRunePanelCtrl:SetFxPlay(fxTran)
	local fxShow = fxTran.transform
    local fx = fxShow:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
    local renderer = fxShow:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    for k = 0,renderer.Length - 1 do
      fxShow:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(renderer[k].material.shader.name)
    end
    for k = 0,fx.Length - 1 do
        fx[k]:Play()
    end
end
------------------------------------------

function StoreRunePanelCtrl:Start()

end

function StoreRunePanelCtrl:OnDiamondsOneBtn()
	self.oneRune.gameObject:SetActive(false) 
	for i=1,5 do
		self.runes[i].gameObject:SetActive(false)
	end
	self:ShowEffect(2,1,self.oneGemPay)
end
function StoreRunePanelCtrl:OnDiamondsFiveBtn()
	-- body
	--print("diamonds 5")
	self.oneRune.gameObject:SetActive(false) 
	for i=1,5 do
		self.runes[i].gameObject:SetActive(false)
	end
	self:ShowEffect(2,5,self.fiveGemPay)
end
function StoreRunePanelCtrl:OnCoinOneBtn()
	-- body
	--print("coin 1")
	self.oneRune.gameObject:SetActive(false) 
	for i=1,5 do
		self.runes[i].gameObject:SetActive(false)
	end
	self:ShowEffect(1,1,self.oneCoinPay)
end
function StoreRunePanelCtrl:OnCoinFiveBtn()
	-- body
	--print("coin 5")
	self.oneRune.gameObject:SetActive(false) 
	for i=1,5 do
		self.runes[i].gameObject:SetActive(false)
	end
	self:ShowEffect(1,5,self.fiveGemPay)
end
function StoreRunePanelCtrl:ShowEffect(paytype,num,payNum)
	if paytype == 2 then 
		if num == 1 and self.Onefree then 
			self:sendBuy(paytype,num)
		else
			local boo = UTGDataOperator.Instance:VoucherToGemNotice(payNum,2,self.sendBuy,self,{PayType = paytype,Num =num})
			if boo == false then self:sendBuy(paytype,num) end
		end
	else
		self:sendBuy(paytype,num)
	end
end
function StoreRunePanelCtrl:sendBuy(type,num)
	-- body
	self.sendType=type
	self:setMask(true)
	local buyInfoRequest = NetRequest.New()
	buyInfoRequest.Content=JObject.New(JProperty.New("Type","RequestRollRune"),JProperty.New("RollType",type),JProperty.New("Count",num))
	buyInfoRequest.Handler=TGNetService.NetEventHanlderSelf(StoreRunePanelCtrl.sendBuyHandler,self)
	TGNetService.GetInstance():SendRequest(buyInfoRequest)
end
function StoreRunePanelCtrl:setMask(tempBool)
	-- body
	if StoreCtrl~=nil and StoreCtrl.Instance ~=nil then 
		StoreCtrl.Instance:apiSetMask(tempBool)
	end
end
function StoreRunePanelCtrl:setRedPoint(tempBool)
	-- body
	if StoreCtrl~=nil and StoreCtrl.Instance ~=nil then 
		StoreCtrl.Instance:apiRuneRedPointActive(tempBool)
	end
	self.diamondsOneBtn:FindChild("RedPoint").gameObject:SetActive(tempBool)
end
function StoreRunePanelCtrl:sendBuyHandler(e)
	self.getRunes={}
	if e.Type == "RequestRollRune" then
		self.Eobj2.gameObject:SetActive(false)
		local result = tonumber(e.Content:get_Item("Result"):ToString())
	 	if result == 1 then
	 		local runeIds = json.decode(e.Content:get_Item("RuneIds"):ToString())
	 		if(runeIds==nil) then
	 		 	--print("竟然是空的") 
	 		end
	 		if(table.getn(runeIds)>0) then
	 			self.getRunes=runeIds
	 			local mainTable = {}
	 			for k,v in pairs(self.getRunes) do
	 				local subTable = {}
	 				subTable["Id"]=v
	 				subTable["Type"]=3
	 				subTable["Amount"]=1
	 				table.insert(mainTable,subTable)
	 			end
	 			local listener
	 			local callback
	 			local callback1=function(self, e)
    				self:UpTips()
    			end
	 			if(table.getn(runeIds)==1) then
	 				listener = NTGEventTriggerProxy.Get(self.oneRune.gameObject)
	 				callback = function(self, e)
    				self:ShowTipsControl(runeIds[1],3)
  					end
  					listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
					listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1,self)
	 				self.oneRune:GetComponent(Image).sprite=UITools.GetSprite("runeicon",UTGData.Instance().RunesData[tostring(runeIds[1])].Icon)
	 				if(self.sendType~=nil) then
	 					if(self.sendType==1 and UTGData.Instance().RunesData[tostring(runeIds[1])].Level==UTGData.Instance().ConfigData["shop_coin_roll_rune_rare_level"].Int) then
	 						--print("稀有符文啊")
	 						self.oneRune:FindChild("R51140490").gameObject:SetActive(true)
	 					elseif(self.sendType==2 and UTGData.Instance().RunesData[tostring(runeIds[1])].Level==UTGData.Instance().ConfigData["shop_gem_roll_rune_rare_level"].Int) then 
	 						--print("稀有符文啊")
	 						self.oneRune:FindChild("R51140490").gameObject:SetActive(true)
	 					else
	 						self.oneRune:FindChild("R51140490").gameObject:SetActive(false)
	 					end
	 					self:SetFxOk(self.oneRune:FindChild("R51140490"))
	 				end
	 			else
	 				for k,v in pairs(self.getRunes) do
	 					--print("第"..k.."个符文等级"..UTGData.Instance().RunesData[tostring(v)].Level)
	 					local listener = NTGEventTriggerProxy.Get(self.runes[k].gameObject)
	 					callback = function(self, e)
    					self:ShowTipsControl(v,3)
    					end
    					listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
						listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1,self)
	 					self.runes[k]:GetComponent(Image).sprite=UITools.GetSprite("runeicon",UTGData.Instance().RunesData[tostring(v)].Icon)
	 					if(self.sendType~=nil) then
	 					--print(UTGData.Instance().ConfigData["shop_coin_roll_rune_rare_level"].Int)
	 						if(self.sendType==1 and UTGData.Instance().RunesData[tostring(v)].Level==UTGData.Instance().ConfigData["shop_coin_roll_rune_rare_level"].Int) then
	 							--print("稀有符文啊")
	 							self.runes[k]:FindChild("R51140490").gameObject:SetActive(true)
	 						elseif(self.sendType==2 and UTGData.Instance().RunesData[tostring(v)].Level==UTGData.Instance().ConfigData["shop_gem_roll_rune_rare_level"].Int) then 
	 							--print("稀有符文啊")
	 							self.runes[k]:FindChild("R51140490").gameObject:SetActive(true)
	 						else
	 							self.runes[k]:FindChild("R51140490").gameObject:SetActive(false)
	 						end
	 						self:SetFxOk(self.runes[k]:FindChild("R51140490"))
	 					end
	 				end
	 			end
	 			coroutine.start(StoreRunePanelCtrl.ShowRunesMov,self, mainTable)
	 		end
			return true
	 	elseif result == 2819 then
    		local dialog = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
	      	dialog:InitNoticeForNeedConfirmNotice("提示", "您的金币不足", false,"", 1,false)
	      	dialog:OneButtonEvent("确定",dialog.DestroySelf,dialog)
	      	dialog:SetTextToCenter()
	      	dialog:HideCloseButton(false)
	      	self:setMask(false)
	      	self.bottomUI:SetBool("isShow",true)
	      	return true
		elseif result == 2820 then
		    local dialog = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
		    dialog:InitNoticeForNeedConfirmNotice("提示", "您的钻石不足", false,"", 1,false)
		    dialog:OneButtonEvent("确定",dialog.DestroySelf,dialog)
		    dialog:SetTextToCenter()
		   	dialog:HideCloseButton(false)
		   	self:setMask(false)
		   	self.bottomUI:SetBool("isShow",true)
		    return true
	  	elseif result == 2821 then
		    local dialog = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
		    dialog:InitNoticeForNeedConfirmNotice("提示", "点券不足", false,"", 2,false)
		    dialog:TwoButtonEvent("确定",dialog.DestroySelf,dialog,"购买点券",dialog.DestroySelf,dialog)
		    dialog:SetTextToCenter()
		    dialog:HideCloseButton(false)
		    self:setMask(false)
		    self.bottomUI:SetBool("isShow",true)
		    return true     
		end
	end
	return false
end
function StoreRunePanelCtrl:ShowRunesMov(myTable)
	self.mask.gameObject:SetActive(false)
	self.Eobj2.gameObject:SetActive(true)
	self:SetFxOk(self.Eobj2)
	self.bottomUI:SetBool("isShow",false)
	coroutine.wait(2) 
	self.mask.gameObject:SetActive(true)
	if(table.getn(myTable)==1) then
		local fx = self.oneRune:FindChild("Fx")
		fx.gameObject:SetActive(true)
		self:SetFxOk(fx)
		--coroutine.wait(0.3)
		self.oneRune.gameObject:SetActive(true) 
	elseif(table.getn(myTable)==5) then 
		for i=1,5 do
			local fx = self.runes[i]:FindChild("Fx")
			fx.gameObject:SetActive(true)
			self:SetFxOk(fx)
			--coroutine.wait(0.3)
			self.runes[i].gameObject:SetActive(true) 
		end
	end
	coroutine.wait(1)
	for i=1,5 do
		self.runes[i]:FindChild("Fx").gameObject:SetActive(false) 
	end
	self.oneRune:FindChild("Fx").gameObject:SetActive(false) 
	coroutine.start(StoreRunePanelCtrl.CreateMainPanelMov,self,myTable)
end
function StoreRunePanelCtrl:CreateMainPanelMov(myTable)
	-- body
	local result = GameManager.CreatePanelAsync("GetRune")
  	while result.Done~= true do
    ------print("deng")
    coroutine.wait(0.05)
  	end
  	self:setMask(false)
  	GetRuneAPI.Instance:ChangeTitle("获得奖励")
  	GetRuneAPI.Instance:ShowReward(myTable)
  	self.bottomUI:SetBool("isShow",true)
end
function StoreRunePanelCtrl:UpdateUI()
	-- body
	if(self.PanelActive) then 
		--print("调用了一次")
		self:GetData()
		self:UpdateCoinTitle()
		self:UpdateDiamondsTitle()
		self:updateTime()
	end
end
function StoreRunePanelCtrl:UpTips()
	-- body
	self.tip.gameObject:SetActive(false)
end
function StoreRunePanelCtrl:ShowTipsControl(RIid,RItype)
	-- body
	local Data = UTGData.Instance()
	local itemName = ""
	local ownNum = 0
	local desc = ""
	if(RItype==3) then 
		itemName = Data.RunesData[tostring(RIid)].Name
		ownNum = Data.RunesDeck[tostring(RIid)].Amount
		local attrs = UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",RIid)
		local str = ""
		for i = 1,#attrs do
			str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr 
			--str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr .. "\n"
			if(i<table.getn(attrs)) then
				str = str.."\n"
			end
		end
		--print("attrs " .. str)
		desc = str
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
function StoreRunePanelCtrl:OnEnable()
	--body
	--print("Rune  OnEnable")
	self:GetData()
	self:UpdateCoinTitle()
	self.PanelActive=true
	self:UpdateDiamondsTitle()
	self:updateTime()
end
function StoreRunePanelCtrl:OnDisable()
	-- body
	self.Eobj2.gameObject:SetActive(false)
	self.oneRune.gameObject:SetActive(false) 
	for i=1,5 do
		self.runes[i].gameObject:SetActive(false)
	end
	self.PanelActive=false
	if(self.timeMove~=nil) then 
		coroutine.stop(self.timeMove)
	end
	self.mask.gameObject:SetActive(false)
	self.timeMove=nil
end

function StoreRunePanelCtrl:GetData()
	-- body
	self.playerShopsDeck=nil
	local shopsDeck = UTGData.Instance().PlayerShopsDeck
	self.playerShopsDeck=shopsDeck
	self.ConfigData =UTGData.Instance().ConfigData
end
function StoreRunePanelCtrl:UpdateCoinTitle()
	-- body
	local x = self.ConfigData["shop_coin_roll_rune_special_cycle"].Int
	self.coinPartTitle.text="再买"..x-(self.playerShopsDeck.RollRuneByCoinAmount -math.floor(self.playerShopsDeck.RollRuneByCoinAmount/x)*x).."次"..self.ConfigData["shop_show_coin_roll_rune_desc"].String
	self.coinFivePrice.text=self.ConfigData["shop_coin_roll_rune_five_times_price"].Int
end
function StoreRunePanelCtrl:UpdateDiamondsTitle()
	-- body
	local x = self.ConfigData["shop_gem_roll_rune_special_cycle"].Int
	self.diamondsPartTitle.text="再买"..x-(self.playerShopsDeck.RollRuneByGemAmount -math.floor(self.playerShopsDeck.RollRuneByGemAmount/x)*x).."次"..self.ConfigData["shop_show_gem_roll_rune_desc"].String
	self.diamondsOnePrice.text=self.ConfigData["shop_gem_roll_rune_once_price"].Int
	self.diamondsFivePrice.text=self.ConfigData["shop_gem_roll_rune_five_times_price"].Int

end
function StoreRunePanelCtrl:updateTime()
	local leftTimeSeconds = UTGData.Instance():GetLeftTime(self.playerShopsDeck.NextFreeRollRuneOnceByGemTime)
	if(leftTimeSeconds>0) then
		self:TimeShow(leftTimeSeconds)
	else
		self:FreeShow()
	end
end
function StoreRunePanelCtrl:FreeShow()
	self.Onefree = true
	self:setRedPoint(true)
	self.diamondsOnePrice.text="免费"
	self.BuyTimeInfo.gameObject:SetActive(false)
end
function StoreRunePanelCtrl:TimeShow(count)
	self.Onefree = false
	self:setRedPoint(false)
	if(self.timeMove~=nil) then
	--print("关了协程") 
		coroutine.stop(self.timeMove)
	end
	self.BuyTimeInfo.gameObject:SetActive(true)
	self.diamondsOnePrice.text=self.ConfigData["shop_gem_roll_rune_once_price"].Int

    self.timeMove = coroutine.start(self.TimeDown,self ,count)  
end
function StoreRunePanelCtrl:TimeDown(count)
	-- body
	--print("timeDown调用一次")
	local hour = 0
  	local min = 0
  	local sec = 0
    while count>0 do
    	hour = math.floor(count/3600)
    	min = math.floor((count - hour*3600)/60)
    	sec = count - min * 60 - hour * 3600
    	self.BuyTimeText.text=string.format("%02d:%02d:%02d",hour,min,sec)
    	coroutine.wait(1)
    	count=count-1
    	--print("shijian"..count)
	end
	self:updateTime()
end
function StoreRunePanelCtrl:OnDestroy()
	-- body
	self.this = nil
	self =nil
end