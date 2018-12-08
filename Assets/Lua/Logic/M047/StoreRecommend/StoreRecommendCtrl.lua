require "System.Global"
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
local json = require "cjson"

class("StoreRecommendCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"

local TypeShophero = 1
local TypeShopSkin = 2
local TypeShopRune = 3
local TypeShopBag = 4

--更新推荐界面的新品
function StoreRecommendCtrl:ApiUpdateNew(args)
  self.tabNewData = {}
  self.tabNewData = UITools.CopyTab(UTGData.Instance().ShopNewsData)

  --形成新的顺序表
  self.tabNewDataOrder = {}
  for k,v in pairs(self.tabNewData) do
    table.insert(self.tabNewDataOrder,v)
  end

  --按照id排序
   local function idSort(a,b)
    if a.Id  < b.Id   then
      return true
    end
    return false
  end 
  table.sort(self.tabNewDataOrder,idSort)

  self:newItemInit()
end

function StoreRecommendCtrl:Awake(this) 
  self.this = this
  self.displayPart = this.transforms[0] -- 展示部分
  self.newTmp = this.transforms[1] --新品
  self.hotTmp = this.transforms[2] -- 热卖
  self.newPart = this.transforms[3] --新品滚动层
  self.idxTmp = this.transforms[4] 
  self.idxPart = this.transforms[5]
  self.hotPart = this.transforms[6]
  self.postTmp = this.transforms[7]-- 海报tmp
  StoreRecommendCtrl.Instance = self
  self:allInit()
end

function  StoreRecommendCtrl:Start()
  --self:allInit()
end

function StoreRecommendCtrl:allInit(args)
  self:dataInit()
  self:displayItemInit()

  if (self.moveAuto ~= nil) then
    coroutine.stop(self.moveAuto)  
  end
  --self.moveAuto  =NTGLuaCoroutine.New(self, self.yieldDisplayAuto)
  self.moveAuto = coroutine.start(  self.yieldDisplayAuto,self )  
  self:idxInit()

  self:idxSet(1)
  self:newItemInit()
  self:hotItemInit()

  self.displayPart.localPosition = self.tabDisplayPos["1"]

end

--外部调用，初始化海报的展示
function StoreRecommendCtrl:displayInitApi(args)
  self:idxSet(1)
  self.displayIdx = 1 --当前展示idx,1,2,3
  self.displayPart.localPosition = self.tabDisplayPos["1"]
  if (self.moveAuto ~= nil) then
    coroutine.stop(self.moveAuto)  
  end
  --self.moveAuto  =NTGLuaCoroutine.New(self, self.yieldDisplayAuto)
  self.moveAuto = coroutine.start(  self.yieldDisplayAuto,self  )  
end

function StoreRecommendCtrl:dataInit()
  self.playerShopsDeck = UTGData.Instance().PlayerShopsDeck
  self.displayIdx = 1 --当前展示idx,1,2,3
  self.isDisplayMoving = false --是否正在自动滚动中
  self.isDisplayRight = true --默认第一张向右滚动
  
  self.moveLen = 696--一次滚动总长度
  --self.moveTime = 0.64--移动一次总时间
  --self.moveOnceTime = 0.01--每段移动时间

  self.moveTime = 0.64--移动一次总时间
  self.moveOnceTime = 0.02--每段移动时间

  self.moveOnceLen = self.moveLen/(self.moveTime/self.moveOnceTime)--每段移动长度
  --Debugger.Log(self.moveOnceLen )
  self.displayTime = 2.0 -- 暂停展示时间

  self.posDragBegin = Vector3.New(0,0,0)--保存拖动开始坐标
  self.isClickDisplayItem = true --当前允许海报点击

  self:postDataInit()
  self:newDataInit()
  self:hotDataInit()
end

function StoreRecommendCtrl:postDataInit(args)
   --海报数据相关
  self.tabPostData = {} 

  local num = 0
  for k,v in pairs(UTGData.Instance().ShopPostsData) do
    num = num +1
  end
  --Debugger.Log("ShopPostsDataNum = "..num)

  --得到海报信息,从UTGData
  self.tabPostData = UITools.CopyTab(UTGData.Instance().ShopPostsData)

   --形成新的顺序表
  self.tabPostDataOrder = {}
  for k,v in pairs(self.tabPostData) do
    table.insert(self.tabPostDataOrder,v)
  end

  --按照id排序
   local function idSort(a,b)
    if a.Id  < b.Id   then
      return true
    end
    return false
  end 
  table.sort(self.tabPostDataOrder,idSort)


  --测试用自己生成数据
--  local postData = {}
--  postData.Id = 1
--  postData.Image = "111"
--  postData.SourceId = 1
--  postData.Param = {1,2}
--  self.tabPostData["1"] = postData

--  local postData = {}
--  postData.Id = 2
--  postData.Image = "222"
--  postData.SourceId = 1
--  postData.Param = {1,2}
--  self.tabPostData["2"] = postData

  self.displayMax = 0
  for k,v in pairs(self.tabPostData) do
    --Debugger.Log("self.tabPostData[k].Image"..self.tabPostData[k].Image)
    self.displayMax = self.displayMax +1
  end

  --Debugger.Log("self.displayMax = "..self.displayMax)
  self.tabIdx = {} --保存所有idx的trans，统一管理
  self.tabDisplayPos = {}

  for i = 1, self.displayMax,1 do
    self.tabDisplayPos[tostring(i)] = self.displayPart.localPosition - Vector3.New(self.moveLen*(i-1),0,0)
  end
end

--新品数据初始化
function StoreRecommendCtrl:newDataInit(args)
  self.tabNewData = {}

--  local num = 0
--  for k,v in pairs(UTGData.Instance().ShopNewsData) do
--    num = num +1
--  end
--  --Debugger.Log("ShopNewsDataNum = "..num)


  self.tabNewData = UITools.CopyTab(UTGData.Instance().ShopNewsData)

   --测试用自己生成数据
--  local newData = {}
--  newData.Id = 1
--  newData.ShopId = 212
--  self.tabNewData[tostring(newData.Id)] = newData

--  local newData = {}
--  newData.Id = 2
--  newData.ShopId = 333
--  self.tabNewData[tostring(newData.Id)] = newData

  self.newMax = 0
  for k,v in pairs(self.tabNewData) do
    --Debugger.Log(k)
    self.newMax = self.newMax +1
  end

  --形成新的顺序表
  self.tabNewDataOrder = {}
  for k,v in pairs(self.tabNewData) do
    table.insert(self.tabNewDataOrder,v)
  end

  --按照id排序
   local function idSort(a,b)
    if a.Id  < b.Id   then
      return true
    end
    return false
  end 
  table.sort(self.tabNewDataOrder,idSort)

  --Debugger.Log("ShopNewsDataNum = "..self.newMax)
end

function StoreRecommendCtrl:hotDataInit(args)
  self.tabHotData = {}

  self.tabHotData = UITools.CopyTab(UTGData.Instance().ShopHotsData)


   --测试用自己生成数据
--  local newData = {}
--  newData.Id = 1
--  newData.ShopId = 212
--  self.tabHotData[tostring(newData.Id)] = newData

--  local newData = {}
--  newData.Id = 2
--  newData.ShopId = 333
--  self.tabHotData[tostring(newData.Id)] = newData

  self.tabHotOrder = {}
  self.hotMax = 0
  for k,v in pairs(self.tabHotData) do
    self.hotMax = self.hotMax +1
    table.insert(self.tabHotOrder,v)
  end

   --按照id排序
   local function idSort(a,b)
    if a.Id  < b.Id   then
      return true
    end
    return false
  end 
  table.sort(self.tabHotOrder,idSort)


  --Debugger.Log("hotMax = "..self.hotMax)
end

function StoreRecommendCtrl:OnDestroy() 
  StoreRecommendCtrl.Instance = nil
  coroutine.stop(  self.moveAuto  )  
  self.this = nil
  self = nil
end

function StoreRecommendCtrl:displayItemInit(args)
  for i = 1,self.displayMax,1 do
    local newTmp = GameObject.Instantiate(self.postTmp)
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(i)
    newTmp.transform:SetParent(self.displayPart)
    newTmp.transform.localPosition = Vector3.zero
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one

    
    --todo 根据名字更改海报的图片
--    --Debugger.Log("self.tabPostData[i] = "..self.tabPostData[tostring(i)].Image)
--    local info = self.tabPostData[tostring(i)]
--    newTmp.transform:GetComponent(Image).sprite=UITools.GetSprite("shoppost",info.Image);

    ----Debugger.Log("self.tabPostData[i] = "..self.tabPostData[tostring(i)].Image)
    local info = self.tabPostDataOrder[i]
    newTmp.transform:GetComponent(Image).sprite=UITools.GetSprite("shoppost",info.Image);


    local item = newTmp.transform
    local callback = function(self, e)
      --Debugger.Log("callbackClick")
		  self:onClickDisplayItem(i)
	  end	
    local listener = NTGEventTriggerProxy.Get(newTmp.gameObject)
    local callbackBeginDrag = function(self, e)
      self.isClickDisplayItem = false
		  self.posDragBegin = Input.mousePosition
      coroutine.stop(self.moveAuto) 
	  end	
    local callbackDrag = function(self, e)
		  self:onDragDisplayItem(i,item)
	  end	
    listener.onBeginDrag = listener.onBeginDrag + NTGEventTriggerProxy.PointerEventDelegateSelf(callbackBeginDrag,self );
    listener.onEndDrag = listener.onEndDrag + NTGEventTriggerProxy.PointerEventDelegateSelf(callbackDrag,self );
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
  end
end

--点击海报
function StoreRecommendCtrl:onClickDisplayItem(idx)
   if self.isClickDisplayItem == true then
      --Debugger.Log("onClickDisplayItem"..idx)
      --这里进行海报跳转
      --local info  = self.tabPostData[tostring(idx)]
      local info  = self.tabPostDataOrder[idx]
      StoreCtrl.Instance:postGoToUI(info)
   else 
      self.isClickDisplayItem = true
   end
end

function StoreRecommendCtrl:idxSet(i)
  for k,v in pairs(self.tabIdx) do 
    if k == tostring(i) then 
      v.gameObject:SetActive(true)
    else
      v.gameObject:SetActive(false)
    end
  end
end

function StoreRecommendCtrl:onDragDisplayItem(idx,item)
  if Input.mousePosition.x < self.posDragBegin.x-10 then
    --Debugger.Log("right")
    coroutine.stop(  self.moveAuto  )  
    if (self.handMove~=nil) then
      coroutine.stop(  self.handMove  )  
    end
    --self.handMove  =NTGLuaCoroutine.New(self, self.yieldDisplayHand,true)
    self.handMove  = coroutine.start(  self.yieldDisplayHand  ,self,true)  
  elseif Input.mousePosition.x > self.posDragBegin.x + 10 then
    --Debugger.Log("left")
    coroutine.stop(  self.moveAuto  )  
    if (self.handMove~=nil) then
      coroutine.stop(  self.handMove  )  
    end
    --self.handMove  =NTGLuaCoroutine.New(self, self.yieldDisplayHand,false)
    self.handMove  =coroutine.start(  self.yieldDisplayHand,self,false )  
  elseif  Input.mousePosition.x > self.posDragBegin.x - 10 and Input.mousePosition.x < self.posDragBegin.x + 10 then 
     --Debugger.Log("click")
  end

  self.isClickDisplayItem = true
end

--手动滚动一张
function StoreRecommendCtrl:yieldDisplayHand(isRight)
  if self.displayMax <= 1 then
    --Debugger.Log("yieldDisplayHand")
    return
  end
  self.isDisplayMoving = true
  local cnt = 0
  if isRight == true then 
    cnt = self.displayIdx + 1
  elseif isRight == false then
    cnt = self.displayIdx  -1 
  end

  if cnt < 1 then
    cnt = 1
  elseif cnt > self.displayMax then
    cnt = self.displayMax
  end
  self:idxSet(cnt)
  local newPos = self.tabDisplayPos[tostring(cnt)]
  --Debugger.Log("newPos = "..newPos.x)
  local oldPos = self.displayPart.localPosition
    
  local totalTime = math.abs(newPos.x - oldPos.x) / self.moveLen * self.moveTime
  --Debugger.Log("totalTime = "..totalTime)
  local lerpTime = 0
  if (totalTime ~= 0) then
    while (lerpTime <= totalTime + self.moveOnceTime) do
      --Debugger.Log("lerpTime = "..lerpTime)
      --Debugger.Log("lerpTime/totalTime = "..lerpTime/totalTime)
      self.displayPart.localPosition = Vector3.Lerp(oldPos,newPos,lerpTime/totalTime)
      lerpTime = lerpTime + self.moveOnceTime
      coroutine.wait(self.moveOnceTime)
    end
  end
  --移动完成
  self.displayIdx = cnt
  self.isDisplayMoving = false

  --self.moveAuto  =NTGLuaCoroutine.New(self, self.yieldDisplayAuto)
  self.moveAuto  = coroutine.start(  self.yieldDisplayAuto,self  )  
end

function  StoreRecommendCtrl:idxInit(args)
  --print("self.displayMax " .. self.displayMax)
  for  i = 1,self.displayMax,1 do
    local idxTmp = GameObject.Instantiate(self.idxTmp)
    idxTmp.gameObject:SetActive(true)
    idxTmp.name = tostring(self.displayMax - i +1)
    idxTmp.transform:SetParent(self.idxPart)
    idxTmp.transform.localPosition = Vector3.zero
    idxTmp.transform.localRotation = Quaternion.identity
    idxTmp.transform.localScale = Vector3.one
    local idx = idxTmp.transform:FindChild("idxActive")
    self.tabIdx[tostring(self.displayMax - i +1)] = idx
  end
end


--自动滚动展示
function StoreRecommendCtrl:yieldDisplayAuto(args)
  if self.displayMax <= 1 then
    return
  end
  while true do
    coroutine.wait(self.displayTime) --等待开始滚动
    self.isDisplayMoving = true
    if self.displayIdx == 1 then --当前是第一页向右滚动
      self:idxSet(2)
      self.isDisplayRight = true
      local newPosX = self.displayPart.localPosition.x - self.moveLen
      while (newPosX < self.displayPart.localPosition.x) do
        local oldPos =  self.displayPart.localPosition
        oldPos.x = oldPos.x - self.moveOnceLen
        self.displayPart.localPosition = oldPos  
        coroutine.wait(self.moveOnceTime)
      end
      --第一张移动完成
      self.displayIdx = 2
      self.isDisplayMoving = false
    elseif self.displayIdx == self.displayMax then --当前最后一页
      self:idxSet(self.displayMax-1)
      self.isDisplayRight = false
      local newPosX = self.displayPart.localPosition.x + self.moveLen
      while (newPosX > self.displayPart.localPosition.x) do
        local oldPos =  self.displayPart.localPosition
        oldPos.x = oldPos.x + self.moveOnceLen
        self.displayPart.localPosition = oldPos
        coroutine.wait(self.moveOnceTime)
      end
      --第二张向左移动完成    
      self.displayIdx = self.displayMax-1
      self.isDisplayMoving = fals
    else --当前中间页
      if ( self.isDisplayRight == true) then --向右滚动
        self:idxSet(self.displayIdx+1)
        local newPosX = self.displayPart.localPosition.x - self.moveLen
        while (newPosX < self.displayPart.localPosition.x) do
          local oldPos =  self.displayPart.localPosition
          oldPos.x = oldPos.x - self.moveOnceLen
          self.displayPart.localPosition = oldPos
          coroutine.wait(self.moveOnceTime)
        end
        self.displayIdx = self.displayIdx+1
        self.isDisplayMoving = false
      elseif self.isDisplayRight == false then--向左滚动
        self:idxSet(self.displayIdx-1)
        local newPosX = self.displayPart.localPosition.x + self.moveLen
        while (newPosX > self.displayPart.localPosition.x) do
          local oldPos =  self.displayPart.localPosition
          oldPos.x = oldPos.x + self.moveOnceLen
          self.displayPart.localPosition = oldPos
          coroutine.wait(self.moveOnceTime)
        end
        self.displayIdx = self.displayIdx-1
        self.isDisplayMoving = false
      end
    end
  end
end

function StoreRecommendCtrl:newItemInit(args)
  for i = 0,self.newPart.childCount-1,1 do
    local obj = self.newPart:GetChild(i).gameObject
    Object.Destroy(obj)
  end

  for i,v in ipairs(self.tabNewDataOrder) do
    local newTmp = GameObject.Instantiate(self.newTmp)
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(i)
    newTmp.transform:SetParent(self.newPart)
    newTmp.transform.localPosition = Vector3.zero
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one
    
    --设置新品UI
    --self:newSetInfo(newTmp.transform,v)
    local shopId = v.ShopId
    local info = UTGData.Instance().ShopsDataById[tostring(shopId)] --得到商品的结构体
    StoreCtrl.Instance:heroCradInfoSet(newTmp.transform,info,true)


    --新品点击响应
    local bg = newTmp.transform:FindChild("iconPart/ClickBg")
    local callback = function(self, e)
      self:onClickNewGoto(v)
	  end	
    UITools.GetLuaScript(bg,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)

    local btn = newTmp.transform:FindChild("Button")
    callback = function(self, e)
      --self:onClickNewBuy(v)
      local info = UTGData.Instance().ShopsDataById[tostring(v.ShopId)] --得到商品的结构体
      StoreCtrl.Instance:onClickHeroCardBuy(info)
	  end	
    UITools.GetLuaScript(btn,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)
  end
end

--热卖初始化
function StoreRecommendCtrl:hotItemInit(args)
  --for i = 1,self.hotMax,1 do
  for i,k in ipairs(self.tabHotOrder) do
    local hotItem = GameObject.Instantiate(self.hotTmp)
    hotItem.gameObject:SetActive(true)
    hotItem.name = tostring(i)
    hotItem.transform:SetParent(self.hotPart)
    hotItem.transform.localPosition = Vector3.zero
    hotItem.transform.localRotation = Quaternion.identity
    hotItem.transform.localScale = Vector3.one

    --设置新品显示信息
    self:hotSetInfo(hotItem.transform,k)

    local callBack = function(self,e)
      self:onClickHotBuy(k)
    end
    UITools.GetLuaScript(hotItem.transform,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callBack)
  end
end

--点击新品跳转3d展示界面
function StoreRecommendCtrl:onClickNewGoto(info)
  local shopId = info.ShopId 
  local shopInfo = UTGData.Instance().ShopsDataById[tostring(shopId)] 

  --Debugger.Log("StoreRecommendCtrl:onClickNewGoto")

  if  (shopInfo.CommodityType == TypeShophero) then
    --Debugger.Log("StoreRecommendCtrl:onClickNewGoto hero")
    local roleInfo = UTGData.Instance().RolesData[tostring(shopInfo.CommodityId)]
    --Debugger.Log(roleInfo.Name)
    local tabRole = {}
    table.insert(tabRole,roleInfo)
    StoreCtrl.Instance:gotoHeroInfoPanel(roleInfo.Id,tabRole)
  elseif shopInfo.CommodityType == TypeShopSkin then 

    
    local skinInfo = UTGData.Instance().SkinsData[tostring(shopInfo.CommodityId)] --得到皮肤信息
    --Debugger.Log(skinInfo.Name)
    local tabSkin = {}
    table.insert(tabSkin,skinInfo)

    local roleInfo = UTGData.Instance().SkinsData[tostring(skinInfo.RoleId)]
    local tabHero = {}
    table.insert(tabHero,roleInfo)
    StoreCtrl.Instance:gotoSkinInfoPanel(shopInfo.CommodityId,tabSkin,skinInfo.RoleId,tabHero)

  end
end

--点击新品购买
function StoreRecommendCtrl:onClickNewBuy(info)
  local shopId = info.ShopId 
  local shopInfo = UTGData.Instance().ShopsDataById[tostring(shopId)] 
  if (shopInfo.CommodityType == 1) then
    
    local isOwn = self:isHeroOwn(shopInfo.CommodityId)
    if (isOwn == true) then --是否已经拥有改英雄
      return
    end

    StoreCtrl.Instance:gotoHeroBuyPanel(shopInfo)
  elseif (shopInfo.CommodityType == 2) then
    local skinInfo = UTGData.Instance().SkinsData[tostring(shopInfo.CommodityId)]
    local isOwnHero = self:isHeroOwn(skinInfo.RoleId)
    if (isOwnHero == false ) then --需要先获得该英雄
      return
    end
    StoreCtrl.Instance:gotoSkinBuyPanel(shopInfo)
  end
end

function StoreRecommendCtrl:onClickHotBuy(info)
  local shopId = info.ShopId 
  local shopInfo = UTGData.Instance().ShopsDataById[tostring(shopId)] 

  local buyNum = 0
	if(shopInfo.CommodityType==3) then
		buyNum=UTGData.Instance().RunesData[tostring(shopInfo.CommodityId)].MaxStack
	elseif(shopInfo.CommodityType==4) then
		buyNum=UTGData.Instance().ItemsData[tostring(shopInfo.CommodityId)].MaxStack
	end

  local haveBuy = 0
		--limit
		if(shopInfo.Limited) then	
			buyNum=shopInfo.LimitAmount	
			for k1,v1 in pairs(self.playerShopsDeck.PurchasedLimitCommodities) do
				if(v1.ShopId==shopInfo.Id) then
					haveBuy=v1.Amount
					buyNum=buyNum-haveBuy
				end
			end
		end
		
		local priceType = 0
		local finalPrice = 0
		--price
		if(shopInfo.CoinPrice>0) then
			priceType=1		
			finalPrice=shopInfo.CoinPrice
		
		end
		if(shopInfo.GemPrice>0) then
			priceType=2
			finalPrice=shopInfo.GemPrice

		end
		if(shopInfo.VoucherPrice>0) then
			priceType=3
			finalPrice=shopInfo.VoucherPrice
		end

  local myTable = {}
  if(shopInfo.CommodityType==4) then
			if(UTGData.Instance().ItemsData[tostring(shopInfo.CommodityId)].Type==16) then
				for k1,v1 in pairs(UTGData.Instance().ItemsData[tostring(shopInfo.CommodityId)].Param) do
					local subTable = {}
					subTable["Id"]=v1[1]
					subTable["Type"]=v1[2]
					subTable["Amount"]=v1[3]
					subTable["IsOwn"]=false
					table.insert( myTable,subTable)
					if(subTable.Type==4) then 
						for k2,v2 in pairs(UTGData.Instance().ShopDepreciationsData) do
							if(shopInfo.Id==v2.ShopId) then
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
					if(subTable.Type==5) then 
						for k2,v2 in pairs(UTGData.Instance().ShopDepreciationsData) do
							if(shopInfo.Id==v2.ShopId) then
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
    
    self:OnHotItemClick(shopInfo.CommodityId,shopInfo.CommodityType,shopInfo.Limited,buyNum,priceType,finalPrice,myTable)
end

function StoreRecommendCtrl:OnHotItemClick(Id,IdType,Limited,BuyNum,priceType,finalPrice,myTable)
	-- body
  --Debugger.Log("finalPrice = "..finalPrice)
	local tempTable = {}
	table.insert(tempTable,Id)
	table.insert(tempTable,Limited)
	table.insert(tempTable,BuyNum)
	table.insert(tempTable,priceType)
	table.insert(tempTable,finalPrice)
	if(table.getn(myTable)>0) then
		table.insert(tempTable,myTable)	
		coroutine.start(StoreRecommendCtrl.CreateGiftPanelMov,self,tempTable) 
	else
		table.insert(tempTable,IdType)
		coroutine.start(StoreRecommendCtrl.CreatePropPanelMov,self,tempTable) 
	end

end
function StoreRecommendCtrl:CreateGiftPanelMov(tempTable)
	local result = GameManager.CreatePanelAsync("GiftDetails")
  	while result.Done~= true do
    --------print("deng")
    coroutine.wait(0.05)
  	end
  	GiftDetailsAPI.Instance:DataInit(tempTable[1],tempTable[2],tempTable[3],tempTable[4],tempTable[5],tempTable[6])
end

function StoreRecommendCtrl:CreatePropPanelMov(tempTable)
	local result = GameManager.CreatePanelAsync("PropDetails")
  	while result.Done~= true do
    --------print("deng")
    coroutine.wait(0.05)
  	end
  	PropDetailsAPI.Instance:DataInit(tempTable[1],tempTable[2],tempTable[3],tempTable[4],tempTable[5],tempTable[6])
end


function StoreRecommendCtrl:newSetInfo(trans,v) 

  local shopId = v.ShopId
  --Debugger.Log("newSetInfo shopId"..shopId)
  local info = UTGData.Instance().ShopsDataById[tostring(shopId)] --得到商品的结构体
  

  local spr = trans:FindChild("iconPart/Image/SprTrue"):GetComponent("UnityEngine.UI.Image")   
  --Debugger.Log("info.CommodityId = "..info.CommodityId)
  --英雄
  if  (info.CommodityType == TypeShophero) then
    local part1 = trans:FindChild("iconPart/NamePart1")
    part1.gameObject:SetActive(true)
    local labHero = part1:FindChild("LabName")

    local role = UTGData.Instance().RolesData[tostring(info.CommodityId)] --heroID
    local skinID = role.Skin --默认皮肤
    local skinName = UTGData.Instance().SkinsData[tostring(skinID)].Portrait            
    spr.sprite = UITools.GetSprite("portrait",skinName);
    spr:SetNativeSize()
    --Debugger.Log("LabName = "..role.Name)
    labHero:GetComponent("UnityEngine.UI.Text").text = role.Name

    local isOwn = self:isHeroOwn(info.CommodityId)
    if (isOwn == true) then --是否已经拥有改英雄
      local tLab = trans:FindChild("LabBuy")
      tLab:GetComponent("UnityEngine.UI.Text").text = "已拥有"

      local pos = labHero.transform.parent.localPosition
      --Debugger.Log("pos.y = "..pos.y)
      pos.y = -55
      labHero.transform.parent.localPosition = pos


    end
  --皮肤 
  elseif info.CommodityType == TypeShopSkin then 
    local part2 = trans:FindChild("iconPart/NamePart2")
    part2.gameObject:SetActive(true)
    local labSkin = part2:FindChild("LabSkin")
    local labHero = part2:FindChild("LabName")
    local skinId = info.CommodityId
    --Debugger.Log("skinId = "..skinId)
    local skinInfo = UTGData.Instance().SkinsData[tostring(skinId)]
    local skinName = skinInfo.Portrait  
    spr.sprite = UITools.GetSprite("portrait",skinName); 
    spr:SetNativeSize()
    local roleInfo = UTGData.Instance().RolesData[tostring( skinInfo.RoleId)] --heroID    
    labHero:GetComponent("UnityEngine.UI.Text").text = roleInfo.Name  
    labSkin:GetComponent("UnityEngine.UI.Text").text = skinInfo.Name  

    --Debugger.Log("需要先获得该英雄1111111111111111111111")
    local isOwnHero = self:isHeroOwn(skinInfo.RoleId)
    if (isOwnHero == false ) then --需要先获得该英雄
      --Debugger.Log("需要先获得该英雄")
      local tLab = trans:FindChild("LabBuy")
      tLab:GetComponent("UnityEngine.UI.Text").text = "需要先获得该英雄"
    end

    local isOwn = StoreCtrl.Instance:isSkinOwn(skinId)
    if (isOwn == true) then
      local tLab = trans:FindChild("LabBuy")
      tLab:GetComponent("UnityEngine.UI.Text").text = "已拥有"

      local pos = labHero.transform.parent.localPosition
      --Debugger.Log("pos.y = "..pos.y)
      pos.y = -90
      labHero.transform.parent.localPosition = pos

      --隐藏价格
      pricePart.gameObject:SetActive(false)
    end
  end

  --左上角
  if (info.TagType ~= 0) then 
    local mark = trans:FindChild("iconPart/"..tostring(info.TagType))
    mark.gameObject:SetActive(true)
    local markDes = mark:FindChild("Text")
    markDes:GetComponent("UnityEngine.UI.Text").text = info.TagDesc   
  end

  --打折信息
  local oldPart = trans:FindChild("iconPart/PricePart/Old")

  local orCnt = 0 --是否两种定价
  if ( info.CoinPrice ~= -1 ) then
    orCnt = orCnt + 1
  end
  if  (info.GemPrice ~= -1) then
    orCnt = orCnt + 1
  end
  if  (info.VoucherPrice ~= -1) then
    orCnt = orCnt + 1
  end

  local tNewOne =  trans:FindChild("iconPart/PricePart/NewOne")
  local tNewTwo = trans:FindChild("iconPart/PricePart/NewTwo")
  if (orCnt == 1) then --一种定价
     tNewOne.gameObject:SetActive(true)
     local name = ""
     local num = 0
     if ( info.CoinPrice ~= -1 ) then
        name = "Coin"
        num = info.CoinPrice
     elseif (info.GemPrice ~= -1) then
        name = "Gem"
        num = info.GemPrice
     elseif (info.VoucherPrice ~= -1) then
        name = "Voucher"
        num = info.VoucherPrice
     end
     local spr = tNewOne:FindChild("SprCoin")
     spr:GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("resourceicon",name);
     spr:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector3.New(25,25,0)
     local labCoin = tNewOne:FindChild("LabCoin")
     labCoin:GetComponent("UnityEngine.UI.Text").text = num

  elseif orCnt == 2 then --两种定价
    tNewTwo.gameObject:SetActive(true)
    if (info.CoinPrice ~= -1) then
      local spr = tNewTwo:FindChild("SprCoin")
      spr:GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("resourceicon","Coin");
      spr:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector3.New(25,25,0)
      local labCoin = tNewTwo:FindChild("LabCoin")
      labCoin:GetComponent("UnityEngine.UI.Text").text = info.CoinPrice
    end

    if (info.GemPrice ~= -1) then
      local spr = tNewTwo:FindChild("SprRmb")
      spr:GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("resourceicon","Gem");
      spr:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector3.New(25,25,0)
      local labCoin = tNewTwo:FindChild("LabRmb")
      labCoin:GetComponent("UnityEngine.UI.Text").text = info.GemPrice
    elseif (info.VoucherPrice ~= -1) then
      local spr = tNewTwo:FindChild("SprRmb")
      spr:GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("resourceicon","Voucher");
      spr:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector3.New(25,25,0)
      local labCoin = tNewTwo:FindChild("LabRmb")
      labCoin:GetComponent("UnityEngine.UI.Text").text = info.VoucherPrice
    end
  end

  --是否有打折消息
  if info.Discountable == true then
    oldPart.gameObject:SetActive(true)
    local oldCoin = oldPart:FindChild("Coin")
    local oldRmb =  oldPart:FindChild("Rmb")
    local labOldCoin = oldCoin:FindChild("Text")
    local labOldRmb = oldRmb:FindChild("Text")

    local iRawPrice = 0
    if (info.RawCoinPrice ~= -1) then
      iRawPrice = info.RawCoinPrice
    elseif (info.RawVoucherPrice ~= -1 ) then
      iRawPrice = info.RawVoucherPrice
    end

    if (orCnt >= 2) then
      if (info.RawCoinPrice ~= -1) then
        oldCoin.gameObject:SetActive(true)
        labOldCoin:GetComponent("UnityEngine.UI.Text").text = iRawPrice
      end

      if (info.RawVoucherPrice ~= -1 ) then
        oldRmb.gameObject:SetActive(true)
        labOldRmb:GetComponent("UnityEngine.UI.Text").text =iRawPrice
      end
    elseif (orCnt == 1) then
       local midText = oldPart:FindChild("Mid")
       midText.gameObject:SetActive(true)
       local lab  = midText:FindChild("Text")
       lab:GetComponent("UnityEngine.UI.Text").text =iRawPrice
    end
  end
end

function StoreRecommendCtrl:hotSetInfo(trans,v) 
  local shopId = v.ShopId
  local info = UTGData.Instance().ShopsDataById[tostring(shopId)] --得到商品的结构体
  
  --读item表得到信息
  local itemInfo = UTGData.Instance().ItemsData[tostring(info.CommodityId)]
  --名字
  trans:FindChild("LabName"):GetComponent(Text).text = itemInfo.Name 
  --背景与icon
  trans:FindChild("Image"):GetComponent(Image).sprite = UITools.GetSprite("icon",itemInfo.Quality)--选择某种颜色的边框
  local sprTure = trans:FindChild("Image/SprIcon")
  if itemInfo.Type == 7 then
    sprTure:GetComponent(Image).sprite = UITools.GetSprite("icon",itemInfo.Icon)
		--sprTure:GetComponent(RectTrans).sizeDelta = Vector2.New(85.1,89.9)
	elseif  itemInfo.Type == 8 then
    sprTure:GetComponent(Image).sprite = UITools.GetSprite("roleicon",itemInfo.Icon)
	elseif 	itemInfo.Type == 12 then
    sprTure:GetComponent(Image).sprite = UITools.GetSprite("runeicon",itemInfo.Icon)
		--self.subPanel:Find("UseItemPanel/IconFrame/Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(72.6,83.9)
	else	
    sprTure:GetComponent(Image).sprite = UITools.GetSprite("itemicon",itemInfo.Icon)
	end
  

  --显示现在的价格
  local newPart = trans:FindChild("PricePart/New")
  local labNew = newPart:FindChild("Text")
  local sprNew = newPart:FindChild("Image")

  if ( info.CoinPrice ~= -1 ) then
    labNew:GetComponent("UnityEngine.UI.Text").text = info.CoinPrice  
    sprNew:GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("resourceicon","Coin");
  elseif  (info.VoucherPrice ~= -1) then
    labNew:GetComponent("UnityEngine.UI.Text").text = info.VoucherPrice 
    sprNew:GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("resourceicon","Voucher");
  elseif  (info.GemPrice ~= -1) then
    sprNew:GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("resourceicon","Gem");
    labNew:GetComponent("UnityEngine.UI.Text").text = info.GemPrice 
  end
  --打折信息
  if  (info.Discountable == true ) then
    local oldPart = trans:FindChild("PricePart/Old")
    oldPart.gameObject:SetActive(true)
    local labOld = oldPart:FindChild("Text")
    local oldPrice = 0
    if info.RawCoinPrice ~= -1 then
      oldPrice = info.RawCoinPrice
    elseif info.RawGemPrice ~= -1 then
      oldPrice = info.RawGemPrice
    elseif info.RawVoucherPrice ~= -1 then
      oldPrice = info.RawVoucherPrice
    end
    labOld:GetComponent("UnityEngine.UI.Text").text = oldPrice 
  end
end

--判断英雄是否已经拥有
function StoreRecommendCtrl:isHeroOwn(heroId)
  if (UTGData.Instance().RolesDeckData[tostring(heroId)] == nil) then
    return false
  end
  if (UTGData.Instance().RolesDeckData[tostring(heroId)].IsOwn == true) then
    return true
  end
  return false
end