require "System.Global"
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
local json = require "cjson"

class("StoreCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"
local Toggle = "UnityEngine.UI.Toggle"

--左边页签
local typePageRecommend = 0
local typePageNew = 1
local typePageHero = 2
local typePageSkin = 3
local typePageRune = 4
local typePageSpecialSale = 5
local typePageSnatch = 6

local typeSortDefault = 0
local typeSortName = 1
local typeSortRmb = 2
local typeSortGold = 3
local typeSortTime = 4

local TypeShophero = 1
local TypeShopSkin = 2
local TypeShopRune = 3
local TypeShopBag = 4

function StoreCtrl:Awake(this) 
  self.this = this
  self.btnSortPart = this.transforms[0] --排序按钮部分
  self.normalResParent = this.transforms[1] --通用资源的父节点
  self.btnRecommendPage = this.transforms[2] --推荐
  self.btnNewPage = this.transforms[3] --新品
  self.btnHeroPage = this.transforms[4] --英雄
  self.btnSkinPage = this.transforms[5] --皮肤
  self.btnRunePage = this.transforms[6] --芯片
  self.btnSpecialSalePage = this.transforms[7] --特惠
  self.btnSnatchPage = this.transforms[8] --夺宝
  self.btnSort = this.transforms[9] --排序按钮
  self.sortPagePart = this.transforms[10] --排序下拉列表
  self.sortGold = this.transforms[11]--金币价格排序，皮肤页需要隐藏
  self.labSort = this.transforms[12] --当前排序种类的标签
  self.contentPart = this.transforms[13] -- 内容部分
  self.leftPageBtnPart = this.transforms[14] --左边页签
  
  self.runeRedPoint = this.transforms[15] --符文上的小红点
  self.btnGiftCenter = this.transforms[16] --礼包中心入口
  self.effectGiftCenter = this.transforms[17] --按钮特效
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")--上方资源条
  StoreCtrl.Instance = self


  --白鹏添加
  self.BPMask= self.this.transform:FindChild("Mask")

  self:dataInit()
  self:btnPageInit()

  local num = 0 *(-1)
  --Debugger.Log("num = "..num)



end

----------------------------------------------------外部调用Api------------------------------------------------------------------
--跳转UI,点击海报
function StoreCtrl:postGoToUI(gotoInfo)
  --再读取source表
  --Debugger.Log("goToUI")
  local souData = UTGData.Instance().SourcesData[tostring(gotoInfo.SourceId)] --
  if (souData.UIName == "Store") then
    self:GoToUI(souData.UIParam[1])
  end
end

--礼物中心特效
function StoreCtrl:effectActive(active)
  self.effectGiftCenter.gameObject:SetActive(active)
end

--跳转UI
function StoreCtrl:GoToUI(idx)
  --再读取source表
  --Debugger.Log("goToUI")

  --对应的page页
  local pageID = idx - 1 
  self.tabLeftPageBtn[tostring(pageID)]:GetComponent(Toggle).isOn = true
  self:onBtnPartPage(pageID)

end


--符文页签上是否显示小红点
--active : false true
function StoreCtrl:apiRuneRedPointActive(active)
  self.runeRedPoint.gameObject:SetActive(active)
end
--白鹏添加
--检测是否免费
function StoreCtrl:CheckFree()
  -- body
  local leftTimeSeconds = UTGData.Instance():GetLeftTime(UTGData.Instance().PlayerShopsDeck.NextFreeRollRuneOnceByGemTime)
  ----print("haisheng"..leftTimeSeconds)
  if(leftTimeSeconds>0) then
    self:apiRuneRedPointActive(false)
  else
    self:apiRuneRedPointActive(true)
  end
end
--全屏透明遮罩
function StoreCtrl:apiSetMask(isShow)
  -- body
  if(isShow) then 
    self.BPMask.gameObject:SetActive(true)
  else
    self.BPMask.gameObject:SetActive(false)
  end
end
--------------------------------------------------------------------------------------------------------------------------------------
function  StoreCtrl:Start()
  --if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
    --WaitingPanelAPI.Instance:DestroySelf()
  --end
  

  
  self:ResetPanel()
 
  self.btnSortPart.gameObject:SetActive(false)
  
  self:sortBtnInit()

  local listener = NTGEventTriggerProxy.Get(self.btnGiftCenter.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(StoreCtrl.onClickGiftCenter,self)


  self:EffectInit(self.effectGiftCenter)
  --白鹏添加
  self:CheckFree()

  --self:partActive(0)

end

function StoreCtrl:EffectInit(trans)
 local tabRender = trans:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,tabRender.Length - 1 do
    trans:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(tabRender[k].material.shader.name)
  end
end


function StoreCtrl:onClickGiftCenter(args)
  local function CreatePanelAsync()
    local async = GameManager.CreatePanelAsync("GiftCenter")
    while async.Done == false do
      coroutine.wait(0.05)
    end
  end
  coroutine.start(CreatePanelAsync,self)
end

function StoreCtrl:dataInit()
  self.isSortPageOpen = false
  self.typePage = -1 --当前所在页
  UTGDataTemporary.Instance().shopPageID = 1 
  self.typeSort = typeSortDefault
  self.tabPart = {}
  for  i = 0 , self.contentPart.childCount-1,1  do
    self.tabPart[tostring(i)] = self.contentPart:GetChild(i)
  end
--  self.tabPart[tostring(typePageRecommend)] = self.recommendPart
--  self.tabPart[tostring(typePageNew)] = self.newPart
--  self.tabPart[tostring(typePageHero)] = self.heroPart
--  self.tabPart[tostring(typePageSkin)] = self.skinPart

  self.tabLeftPageBtn = {}
end

function StoreCtrl:ResetPanel()
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("StorePanel/NormalResParent")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,self.OnReturnButtonClick,nil,nil,"商城")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  topAPI:HideSom("Text")
  UTGDataOperator.Instance:SetResourceList(topAPI)
end

function StoreCtrl:OnReturnButtonClick()
  UTGDataOperator.Instance:SetPreUIRight(self.this.transform)
  GameObject.Destroy(self.this.gameObject)
  NTGResourceController.Instance:UnloadAssetBundle("storerecommend", true, false)
  NTGResourceController.Instance:UnloadAssetBundle("storenew", true, false)
  NTGResourceController.Instance:UnloadAssetBundle("storehero", true, false)
  NTGResourceController.Instance:UnloadAssetBundle("storeskin", true, false)
  NTGResourceController.Instance:UnloadAssetBundle("storerune", true, false)
  NTGResourceController.Instance:UnloadAssetBundle("storeperferential", true, false)
  NTGResourceController.Instance:UnloadAssetBundle("storelottery", true, false)
  --UnityEngine.Resources.UnloadUnusedAssets()
end

function StoreCtrl:OnDestroy() 
  self.this = nil
  StoreCtrl.Instance = nil
  UTGDataTemporary.Instance().shopPageID = - 1 
  self = nil
end

--页签按钮响应绑定
function StoreCtrl:btnPageInit(args)
  self.tabLeftLabWhite = {}
  for i = 0, self.leftPageBtnPart.childCount-1,1 do
    local trans = self.leftPageBtnPart:GetChild(i)
    self.tabLeftPageBtn[tostring(i)] = trans
    local labWhite = trans:FindChild("LabWhite")
    table.insert(self.tabLeftLabWhite,labWhite)
    local listener = NTGEventTriggerProxy.Get(trans.gameObject)
    local callback = function()
      self:onBtnPartPage(i)
    end
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
  end

    local listener = NTGEventTriggerProxy.Get(self.btnSort.gameObject)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(StoreCtrl.onBtnSort,self)
end

function StoreCtrl:onBtnPartPage(idx)
  if self.typePage == idx then
    return
  end 
  self:sortTypeInit()
  if  idx == typePageHero or idx == typePageSkin then
    self.btnSortPart.gameObject:SetActive(true)
  else
    self.btnSortPart.gameObject:SetActive(false)
  end
  self.typePage = idx
  UTGDataTemporary.Instance().shopPageID = self.typePage + 1
  self:onLeftLabWhite(idx)
  self:sortPageClose()
  self:partActive(self.typePage)


  if idx == typePageRecommend then
    if (StoreRecommendCtrl~= nil and StoreRecommendCtrl.Instance~=nil) then
      StoreRecommendCtrl.Instance:displayInitApi()
      StoreRecommendCtrl.Instance:ApiUpdateNew()---
    end
    --显示礼包中心按钮
    self.btnGiftCenter.gameObject:SetActive(true)
  else
    self.btnGiftCenter.gameObject:SetActive(false)
  end


  if idx == typePageNew then
    if (StoreNewCtrl~= nil and StoreNewCtrl.Instance~=nil) then
      StoreNewCtrl.Instance:ApiModelActive(true)
      StoreNewCtrl.Instance:ApiUpdateAll()
      StoreNewCtrl.Instance:ApiActive()
    end
  else
    if (StoreNewCtrl~= nil and StoreNewCtrl.Instance~=nil) then
      StoreNewCtrl.Instance:ApiModelActive(false)
    end
  end

  if (idx == typePageHero) then
    if (StoreHeroCtrl~= nil and StoreHeroCtrl.Instance~=nil) then
      StoreHeroCtrl.Instance:ApiUpdateHeroList()
    end
  end

  if (idx == typePageSkin) then
    if (StoreSkinCtrl~= nil and StoreSkinCtrl.Instance~=nil) then
      StoreSkinCtrl.Instance:ApiUpdateHeroList()
    end
  end

end

function StoreCtrl:onLeftLabWhite(idx)
  local trueIdx = idx +1 
  for i = 1,#self.tabLeftLabWhite,1 do
    if ( i== trueIdx) then
      self.tabLeftLabWhite[i].gameObject:SetActive(true)
    else
      self.tabLeftLabWhite[i].gameObject:SetActive(false)
    end
  end
end
--排序的父类按钮负责打开排序下拉列表
function StoreCtrl:onBtnSort(args)
  if self.isSortPageOpen == false then --排序页关闭状态
    if (self.typePage == typePageHero) then
      self.sortGold.gameObject:SetActive(true)
    elseif self.typePage == typePageSkin then
      self.sortGold.gameObject:SetActive(false)
    end
    self.sortPagePart.gameObject:SetActive(true)
    self.isSortPageOpen = true
  else 
    self.sortPagePart.gameObject:SetActive(false)
    self.isSortPageOpen = false
  end
end

function StoreCtrl:sortPageClose(args)
  self.sortPagePart.gameObject:SetActive(false)
  self.isSortPageOpen = false
end

function StoreCtrl:sortBtnInit()
  self.sortPagePart.gameObject:SetActive(true)
  local sortRoot = self.sortPagePart:FindChild("Root")
  for i = 0,sortRoot.childCount-1,1 do
    local sort = sortRoot:GetChild(i)
    local callback = function()
      --Debugger.Log("sort.name"..sort.name)
      self:onBtnSortType(sort.name)
      --self:AddPointerClickEvent(sort.gameObject, StoreCtrl.onBtnSortType)
    end
    --UITools.GetLuaScript(sort.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)
    local script = UITools.GetLuaScript(sort.gameObject,"Logic.UICommon.UIClick")
    if (script == nil) then
      --Debugger.Log("script == nil")
    end

    script:RegisterClickDelegate(self,callback)
  end
  self.sortPagePart.gameObject:SetActive(false)
end

function StoreCtrl:AddPointerClickEvent(go, func)
  local listener = NTGEventTriggerProxy.Get(go)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(func,self)
end

--排序函数，调用英雄或皮肤界面的api
function StoreCtrl:onBtnSortType(idx)
--  if UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject == nil then return end
--  local name = tostring(UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject.name)
--  local obj = UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject
 
  self:sortPageClose()


  local sortTypeTmp = tonumber(idx)
--  if self.typeSort == sortTypeTmp then
--    return
--  end
  
  self.typeSort = sortTypeTmp 
  local objRoot = self.sortPagePart:FindChild("Root")  --obj.transform:FindChild("PageName")
  local objItem = objRoot:FindChild(idx)
  local sTypeName = objItem:GetComponent(NTGLuaScript.GetType("UnityEngine.UI.Text")).text
  self.labSort:GetComponent(NTGLuaScript.GetType("UnityEngine.UI.Text")).text = sTypeName

  --当前页为皮肤或英雄时，执行排序
  if self.typePage == typePageHero then
    StoreHeroCtrl.Instance:apiCardSort(self.typeSort)
  elseif self.typePage ==  typePageSkin then
    StoreSkinCtrl.Instance:apiCardSort(self.typeSort)
  end
end

function StoreCtrl:sortTypeInit(args)
  self.labSort:GetComponent(NTGLuaScript.GetType("UnityEngine.UI.Text")).text = "默认排序"
  self.typeSort = typeSortDefault
end

function StoreCtrl:partActive(idx)
  --Debugger.Log(idx)
  idx = idx + 1
  --[[
  for k,v in pairs(self.tabPart) do
    if k == tostring(idx) then
    --Debugger.Log(idx)
      v.gameObject:SetActive(true)
    else 
      v.gameObject:SetActive(false)
    end
  end
  ]]

  for i = 1,self.contentPart.childCount do
    self.contentPart:GetChild(i-1).gameObject:SetActive(false)
  end

  for i = 1,self.contentPart.childCount do
    if idx == 1 then
      if self.contentPart:GetChild(i-1).name == "StoreRecommendPanel" then
        self.contentPart:GetChild(i-1).gameObject:SetActive(true)
        return
      end
    elseif idx == 2 then
      if self.contentPart:GetChild(i-1).name == "StoreNewPanel" then
        self.contentPart:GetChild(i-1).gameObject:SetActive(true)
        return
      end
    elseif idx == 3 then
      if self.contentPart:GetChild(i-1).name == "StoreHeroPanel" then
        self.contentPart:GetChild(i-1).gameObject:SetActive(true)
        return
      end
    elseif idx == 4 then
      if self.contentPart:GetChild(i-1).name == "StoreSkinPanel" then
        self.contentPart:GetChild(i-1).gameObject:SetActive(true)
        return
      end
    elseif idx == 5 then
      if self.contentPart:GetChild(i-1).name == "StoreRunePanel" then
        self.contentPart:GetChild(i-1).gameObject:SetActive(true)
        return
      end
    elseif idx == 6 then
      if self.contentPart:GetChild(i-1).name == "StorePreferentialPanel" then
        self.contentPart:GetChild(i-1).gameObject:SetActive(true)
        return
      end
    elseif idx == 7 then
      if self.contentPart:GetChild(i-1).name == "StoreLotteryPanel" then
        self.contentPart:GetChild(i-1).gameObject:SetActive(true)
        return
      end
    end
  end

  if idx == 1 then
    GameManager.CreatePanel("Waiting")    
    self:LoadSubPanel("StoreRecommend")
    
  elseif idx == 2 then
    GameManager.CreatePanel("Waiting")    
    self:LoadSubPanel("StoreNew")

  elseif idx == 3 then
    GameManager.CreatePanel("Waiting")    
    self:LoadSubPanel("StoreHero")
   
  elseif idx == 4 then
    GameManager.CreatePanel("Waiting")    
    self:LoadSubPanel("StoreSkin")

  elseif idx == 5 then
    GameManager.CreatePanel("Waiting")    
    self:LoadSubPanel("StoreRune")

  elseif idx == 6 then
    GameManager.CreatePanel("Waiting")    
    self:LoadSubPanel("StorePreferential")

  elseif idx == 7 then
    GameManager.CreatePanel("Waiting")    
    self:LoadSubPanel("StoreLottery")

  end

end

--产生购买英雄面板
--info 商品信息
function StoreCtrl:gotoHeroBuyPanel(info)
  local role = UTGData.Instance().RolesData[tostring(info.CommodityId)]
  --Debugger.Log(role.Name)
  local CoinPrice = info.CoinPrice       
  local GemPrice = info.GemPrice
  local VoucherPrice  = info.VoucherPrice    
  local buyType = 0
  if (CoinPrice == -1 and VoucherPrice ~= -1 and GemPrice == -1) then
    buyType = 1
  elseif (CoinPrice ~= -1 and VoucherPrice == -1 and GemPrice ~= -1) then
    buyType = 2
  elseif (CoinPrice ~= -1 and VoucherPrice ~= -1 and GemPrice == -1) then
    buyType = 3
  end

  local function CreatePanelAsync()
    --Debugger.Log("CreatePanelAsync")
    local async = GameManager.CreatePanelAsync("BuyHero")
    while async.Done == false do
      coroutine.wait(0.05)
    end
    --Debugger.Log("CreatePanelAsync end")
    if BuyHeroAPI ~= nil and BuyHeroAPI.Instance ~= nil then
      BuyHeroAPI.Instance:BuyHero(info.CommodityId,buyType)
    end
  end
  coroutine.start(CreatePanelAsync,self)
end

--产生皮肤购买面板
function StoreCtrl:gotoSkinBuyPanel(info)
  local skinInfo = UTGData.Instance().SkinsData[tostring(info.CommodityId)]
  --Debugger.Log(skinInfo.Name)
    
  --弹出购买皮肤面板
  local function CreatePanelAsync()
    local async = GameManager.CreatePanelAsync("BuySkin")
    while async.Done == false do
      coroutine.step()
    end
    --Debugger.Log("CreatePanelAsync end")
    if BuySkinAPI ~= nil and BuySkinAPI.Instance ~= nil then
      BuySkinAPI.Instance:Init(info.CommodityId)
      local isOwnHero = self:isHeroOwn(skinInfo.RoleId)
      local buyType = -1
      if (isOwnHero == true ) then
        buyType = 0
      elseif (isOwnHero == false) then
        buyType = 1
      end
      BuySkinAPI.Instance:ConfirmButtonChose(buyType)
    end
  end
  coroutine.start(CreatePanelAsync,self)
end

function StoreCtrl:gotoHeroInfoPanel(id,selectedTable)
  local function CreatePanelAsync()
    local async = GameManager.CreatePanelAsync("HeroInfo")
    while async.Done == false do
      coroutine.wait(0.05)
    end
    if  (HeroInfoAPI.Instance ~= nil) then
      local tabSkin = {}
      local role = UTGData.Instance().RolesData[tostring(id)]
      local skinId = role.Skin

      for i,val in ipairs(selectedTable) do
        local skinInfoTmp = UTGData.Instance().SkinsData[tostring(val.Skin)]
        table.insert(tabSkin,skinInfoTmp)
      end
      HeroInfoAPI.Instance:Init(id,selectedTable)
      HeroInfoAPI.Instance:InitCenterBySkinId(skinId,tabSkin)
    end
  end
  coroutine.start(CreatePanelAsync,self)
end

function StoreCtrl:gotoSkinInfoPanel(id,selectedTable,heroId,tabHero)
  local function CreatePanelAsync()
    local async = GameManager.CreatePanelAsync("HeroInfo")
    while async.Done == false do
      coroutine.wait(0.05)
    end
    if  (HeroInfoAPI.Instance ~= nil) then
      HeroInfoAPI.Instance:Init(heroId,tabHero)
      HeroInfoAPI.Instance:InitCenterBySkinId(id,selectedTable)
    end
  end
  coroutine.start(CreatePanelAsync,self)
end


--判断英雄是否已经拥有
function StoreCtrl:isHeroOwn(heroId)
  if (UTGData.Instance().RolesDeckData[tostring(heroId)] == nil) then
    return false
  end
  if (UTGData.Instance().RolesDeckData[tostring(heroId)].IsOwn == true) then
    return true
  end
  return false
end


--判断皮肤是否已经拥有
function StoreCtrl:isSkinOwn(skinId)
  if (UTGData.Instance().SkinsDeckData[tostring(skinId)] == nil) then
    return false
  end
  if (UTGData.Instance().SkinsDeckData[tostring(skinId)].IsOwn == true) then
    return true
  end
  return false
end

--英雄卡片的信息设置
--trans：
--v:商品信息
function StoreCtrl:heroCradInfoSet(trans,info,isNew)
  --Debugger.Log("StoreHeroCtrl:heroCardSetInfo"..trans.name)
  local spr = trans:FindChild("iconPart/Image/SprTrue"):GetComponent("UnityEngine.UI.Image")   
  --Debugger.Log("info.CommodityId = "..info.CommodityId)
  local pricePart = trans:FindChild("iconPart/PricePart")
  --英雄
  if  (info.CommodityType == TypeShophero) then
    local part1 = trans:FindChild("iconPart/NamePart1")
    
    part1.gameObject:SetActive(true)
    local labHero = part1:FindChild("LabName")

    local role = UTGData.Instance().RolesData[tostring(info.CommodityId)] --heroID
    local skinID = role.Skin
    local skinName = UTGData.Instance().SkinsData[tostring(skinID)].Portrait            
    spr.sprite = UITools.GetSprite("portrait",skinName);
    spr:SetNativeSize()
    --Debugger.Log("LabName = "..role.Name)
    labHero:GetComponent("UnityEngine.UI.Text").text = role.Name

    --英雄不可购买，更改UI显示
    if ( role.ForSale == false) then
        
      --英雄的名字下移
      local pos = labHero.transform.parent.localPosition
      --Debugger.Log("pos.y = "..pos.y)
      if (isNew == false) then
        pos.y = -90
      elseif (isNew == true) then
        pos.y = -55
      end
      labHero.transform.parent.localPosition = pos

      --更换按钮显示换成蓝色
      --todo
      
      --获取跳转表信息
      local souData = UTGData.Instance().SourcesData[tostring(role.SourceId)]
      local tLab = trans:FindChild("LabBuy")
      tLab:GetComponent("UnityEngine.UI.Text").text = souData.Desc
    end

    --是否已经拥有英雄
    local isOwn = self:isHeroOwn(info.CommodityId)
    if (isOwn == true) then
      local tLab = trans:FindChild("LabBuy")
      tLab:GetComponent("UnityEngine.UI.Text").text = "已拥有"

      local pos = labHero.transform.parent.localPosition
      --Debugger.Log("pos.y = "..pos.y)
      if (isNew == false) then
        pos.y = -90
      elseif (isNew == true) then
        pos.y = -55
      end
      labHero.transform.parent.localPosition = pos

      --隐藏价格
      pricePart.gameObject:SetActive(false)
    end

    
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

    --是否拥有该英雄
    local isOwnHero = self:isHeroOwn(skinInfo.RoleId)
    if (isOwnHero == false ) then --需要先获得该英雄
      --Debugger.Log("需要先获得该英雄")
      local tLab = trans:FindChild("LabBuy")
      tLab:GetComponent("UnityEngine.UI.Text").text = "需要先获得该英雄"
    end

    --是否拥有改皮肤
    local isOwn = self:isSkinOwn(skinId)
    if (isOwn == true) then
      local tLab = trans:FindChild("LabBuy")
      tLab:GetComponent("UnityEngine.UI.Text").text = "已拥有"

      local pos = labHero.transform.parent.localPosition
      --Debugger.Log("pos.y = "..pos.y)
      if (isNew == false) then
        pos.y = -90
      elseif (isNew == true) then
        pos.y = -55
      end
      labHero.transform.parent.localPosition = pos

      --隐藏价格
      pricePart.gameObject:SetActive(false)
    end


  end

  --显示左上角
  if (info.TagType ~= 0) then 
    local mark = trans:FindChild("iconPart/"..tostring(info.TagType))
    mark.gameObject:SetActive(true)
    local markDes = mark:FindChild("Text")
    markDes:GetComponent("UnityEngine.UI.Text").text = info.TagDesc   
  end

  --显示价格
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

  --打折
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
    local sOri = labOldCoin:GetComponent("UnityEngine.UI.Text").text
    if (orCnt >= 2) then
      if (info.RawCoinPrice ~= -1) then
        oldCoin.gameObject:SetActive(true)
        labOldCoin:GetComponent("UnityEngine.UI.Text").text = tostring(iRawPrice)
      end

      if (info.RawVoucherPrice ~= -1 ) then
        oldRmb.gameObject:SetActive(true)
        labOldRmb:GetComponent("UnityEngine.UI.Text").text =tostring(iRawPrice)
      end
    elseif (orCnt == 1) then
       local midText = oldPart:FindChild("Mid")
       midText.gameObject:SetActive(true)
       local lab  = midText:FindChild("Text")
       
       lab:GetComponent("UnityEngine.UI.Text").text =tostring(iRawPrice)
    end
  end
end


--点击购买
--info 为shops商品信息
function StoreCtrl:onClickHeroCardBuy(info)
  if  (info.CommodityType == TypeShophero) then
    local role = UTGData.Instance().RolesData[tostring(info.CommodityId)]
    local isOwn = self:isHeroOwn(info.CommodityId)
    local isCanBuy = role.ForSale
    if (isCanBuy == true and isOwn == false) then --可以购买
      StoreCtrl.Instance:gotoHeroBuyPanel(info)
    elseif (isCanBuy == false and isOwn == false ) then --特殊途径获得跳转界面
      local souData = UTGData.Instance().SourcesData[tostring(role.SourceId)]
      if souData.UIName == "Store" then
        StoreCtrl.Instance:GoToUI(souData.UIParam[1])
      end
    end
    
  elseif info.CommodityType == TypeShopSkin then 
    local skinInfo = UTGData.Instance().SkinsData[tostring(info.CommodityId)]
    local isOwn = self:isSkinOwn(info.CommodityId)
    local isCanBuy = skinInfo.ForSale

    if (isCanBuy == true and isOwn == false) then --可以购买
      StoreCtrl.Instance:gotoSkinBuyPanel(info)
    elseif (isCanBuy == false and isOwn == false ) then --特殊途径获得跳转界面
      local souData = UTGData.Instance().SourcesData[tostring(role.SourceId)]
      if souData.UIName == "Store" then
        StoreCtrl.Instance:GoToUI(souData.UIParam[1])
      end
    end
  end
end

function StoreCtrl:LoadSubPanel(name)
  -- body
  coroutine.start(StoreCtrl.LoadSubPanelCoroutine,self,name)
end

function StoreCtrl:LoadSubPanelCoroutine(name)
  -- body
  local result = GameManager.CreatePanelAsync(name)
  while result.Done == false do
    coroutine.wait(0.05)
  end

  result.Panel:SetParent(self.contentPart)
  if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end
end


