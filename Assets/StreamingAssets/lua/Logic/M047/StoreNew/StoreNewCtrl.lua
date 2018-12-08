require "System.Global"
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
local json = require "cjson"

class("StoreNewCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"
local Toggle = "UnityEngine.UI.Toggle"

local TypeShophero = 1
local TypeShopSkin = 2
local TypeShopRune = 3
local TypeShopBag = 4

local TypeTabNewHero = 1
local TypeTabNewSkin = 2

local TypeBuyCoin = 1
local TypeBuyRmb = 2
local TypeBuyChip = 3

local Data = UTGData.Instance()

----------------------------------------------------api--------------------------------------------------------------------------
--刷新面板全部信息
function StoreNewCtrl:ApiUpdateAll(args)
  local pageTmp = self.iTypeTab
  self:dataInit()
  self:newBuyBtnPartUpdate() --更新底部3个购买按钮
  self.iTypeTab = -1
  self:onClickTop(pageTmp)
  if (pageTmp == TypeTabNewHero) then
    self:modelDisplay(self.iNewHeroId,true)
  elseif (pageTmp == TypeTabNewSkin) then
    self:modelDisplay(self.iNewSkinId,false)
  end
end

--刷新拥有碎片数量
function StoreNewCtrl:ApiUpdatePartNum()
  self:labPartNumUpdate(self.iTypeTab)
end

--是否激活模型
function StoreNewCtrl:ApiModelActive(active)
  NTGApplicationController.SetShowQuality(true)
  self.model.gameObject:SetActive(active)
end

--每次激活调用
function StoreNewCtrl:ApiActive()
  NTGApplicationController.SetShowQuality(true)
  self:effectPlay()
end
-------------------------------------------------------api--------------------------------------------------------------------------

function StoreNewCtrl:Awake(this) 
  self.this = this 
  self.tTopBtnPart = this.transforms[0]
  self.tNewBuyPart = this.transforms[1] --新品购买左下
  self.tSkillBtnPart = this.transforms[2]
  self.tSkillTipsPart = this.transforms[3]
  self.tabSkillBtn = {}
  for i = 1,4 do
    self.tabSkillBtn[i] = self.tSkillBtnPart:Find("Skill" .. i)
  end

  self.skillTips = {}
  for i = 1,4 do
    self.skillTips[i] = self.tSkillTipsPart:Find("SkillTip" .. i)
  end

  self.tHeroClassIcon = this.transforms[4] --职业图标
  self.tHeroName = this.transforms[5]
  self.tSkinName = this.transforms[6]
  
  self.tBoxPart = this.transforms[7]--宝箱
  self.tabBox = {}
  for i = 1,4 do
    self.tabBox[i] = self.tBoxPart:Find(tostring(i))
  end

  self.tBtnBoxOpen = this.transforms[8] --商店开启
  self.model = this.transforms[9] --英雄模型
  self.labPartNum = this.transforms[10] --碎片数量
  self.btnPartShop = this.transforms[11] --开启碎片商店
  self.effectAlltime = this.transforms[12] --宝箱常驻特效
  self.effectOnce = this.transforms[13] --一开始只出现一次的特效
  self.sprPartIcon1 = this.transforms[14] --右下
  self.sprPartIcon2 = this.transforms[15] --左下
  self.leftPart = this.transforms[16]
  self.btnLeftNor = this.transforms[17]
  self.labLeftNor = this.transforms[18]
  self.labHave = this.transforms[19] --已拥有
  StoreNewCtrl.Instance = self

  local listener
  listener = NTGEventTriggerProxy.Get(self.btnPartShop.gameObject)
  local callback = function(self, e)
    self:DoOpenPartShop()
    self:ApiModelActive(false)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)  
  
end

function StoreNewCtrl:Start()
  NTGApplicationController.SetShowQuality(true)
  self:dataInit()
  self:btnInit()
  self:onNewHero()
  self:newBuyBtnPartUpdate()
  --显示模型 
  self:modelDisplay(self.iNewHeroId,true)
  self:EffectInit()
  self:effectPlay()
  self.cubespeed  = 0.6
  local listener = NTGEventTriggerProxy.Get(self.leftPart:Find("RawEvent").gameObject)
  listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(StoreNewCtrl.DragCube,self )

  listener = NTGEventTriggerProxy.Get(self.btnLeftNor.gameObject)
  listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf( StoreNewCtrl.onClickLeftNor,self)

end

function StoreNewCtrl:onClickLeftNor(args)
    if (self.iTypeTab == TypeTabNewSkin) then
      local heroId = Data.SkinsData[tostring(self.iNewSkinId)].RoleId
      local heroInfo = Data.RolesData[tostring(heroId)]
      local isOwnHero = StoreCtrl.Instance:isHeroOwn(heroId)
      local isOwnSkin = StoreCtrl.Instance:isSkinOwn(self.iNewSkinId)
      if (isOwnHero == false and isOwnSkin == false) then
        local tabRole = {}
        table.insert(tabRole,heroInfo)
        StoreCtrl.Instance:gotoHeroInfoPanel(heroId,tabRole)
      end
    end
end
function StoreNewCtrl:DragCube()
 coroutine.start(StoreNewCtrl.DragMov,self)
end

function StoreNewCtrl:DragMov()

  local startpos = Input.mousePosition
  ------print(startpos)
  local offet = {}
  local isClick = true
  while Input.GetMouseButton(0) do  
    coroutine.wait(0.02) 
    --coroutine.wait(WaitForSeconds.New(0.05))
    offet = (Input.mousePosition-startpos).x
    if math.abs(offet) > 0.1 then isClick = false end
    startpos = Input.mousePosition
    self.model:Find("desk").localEulerAngles = self.model:Find("desk").localEulerAngles + Vector3.New(0,-self.cubespeed*offet,0)
  end
  if isClick then
    self:SetModelPlayerAnimator()
  end
end

function StoreNewCtrl:SetModelPlayerAnimator()
  
  if self.fxShow ~= "" then
    self.fxShow.gameObject:SetActive(false)
  end
  
  self.modelAnimator:SetTrigger("play")
  

  if self.fxPlay ~= "" then
    local fx = self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
    local renderer = self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))

    for k = 0,renderer.Length - 1 do
      self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(renderer[k].material.shader.name)
    end

    for k = 0,fx.Length - 1 do
      fx[k]:Play()
    end
  end
end

function StoreNewCtrl:dataInit(args)
  self.iNewHeroId = 10000501 --新品英雄和皮肤可能不是同一个英雄
  self.iNewSkinId = 11000301
  self.iTypeTab = TypeTabNewHero
  self.bCanUpdateHero = true
  self.bCanUpdateSkin = true
  self:firstNotHaveNewIdGet()--得到展示新品id

  self.fxShow = ""
  self.fxPlay = ""
  self.midBuyType = 3
end

function StoreNewCtrl:effectPlay()
  self.effectAlltime.gameObject:SetActive(true)
--  local function waitFor()
--    coroutine.wait(WaitForSeconds.New(1.0))
--    self.effectAlltime.gameObject:SetActive(true)    
--  end
--  coroutine.start(NTGLuaCoroutine.New(self, waitFor))
end

--新品购买的三个按钮
function StoreNewCtrl:newBuyBtnPartUpdate()
  if (self.iTypeTab == TypeTabNewHero) then
    --先进行判断是否已经拥有改英雄
    local isOwn = StoreCtrl.Instance:isHeroOwn(self.iNewHeroId)
    if (isOwn == true) then
      self.tNewBuyPart.gameObject:SetActive(false)
      self.btnLeftNor.gameObject:SetActive(false)
      self.labHave.gameObject:SetActive(true)
      --self.labLeftNor:GetComponent(Text).text = "已拥有"
    elseif (isOwn == false) then
      self.tNewBuyPart.gameObject:SetActive(true)
      self.btnLeftNor.gameObject:SetActive(false)
      self.labHave.gameObject:SetActive(false)
      local coin = self.tNewBuyPart:GetChild(0)
      local labCoin = coin:FindChild("Text")
      labCoin:GetComponent("UnityEngine.UI.Text").text = tostring(UTGData.Instance().ShopsData[tostring(self.iNewHeroId)][1].CoinPrice)
      if (UTGData.Instance().ShopsData[tostring(self.iNewHeroId)][1].CoinPrice <= 0) then
        self.tNewBuyPart:GetChild(0).gameObject:SetActive(false)
      else 
        self.tNewBuyPart:GetChild(0).gameObject:SetActive(true)
      end

      local VoucherPrice = UTGData.Instance().ShopsData[tostring(self.iNewHeroId)][1].VoucherPrice
      local GemPrice = UTGData.Instance().ShopsData[tostring(self.iNewHeroId)][1].GemPrice 
      local showPrice = 0
      if (VoucherPrice > 0 ) then
        showPrice = VoucherPrice
        self.midBuyType =  3
      elseif (GemPrice > 0) then
        self.midBuyType =  2
        showPrice = GemPrice
      end

      local rmb = self.tNewBuyPart:GetChild(1)
      local labRmb = rmb:FindChild("Text")
      labRmb:GetComponent("UnityEngine.UI.Text").text = tostring(showPrice)
      if (showPrice == 0) then
        rmb.gameObject:SetActive(false)
      else 
        rmb.gameObject:SetActive(true)
        local labBtn = rmb:FindChild("Button/Text")
        local sprIcom = rmb:FindChild("Image")
        if (VoucherPrice > 0 ) then
          labBtn:GetComponent("UnityEngine.UI.Text").text = "点券购买"
          sprIcom:GetComponent(Image).sprite =  UITools.GetSprite("resourceicon","Voucher")
        elseif (GemPrice > 0) then
          labBtn:GetComponent("UnityEngine.UI.Text").text = "钻石购买"
          sprIcom:GetComponent(Image).sprite =  UITools.GetSprite("resourceicon","Gem")
        end
      end

      local part = self.tNewBuyPart:GetChild(2)
      local labPart = part:FindChild("Text")
      labPart:GetComponent("UnityEngine.UI.Text").text = tostring(UTGData.Instance().PartShopsData[tostring(self.iNewHeroId)].Price)
    end

    

  elseif (self.iTypeTab == TypeTabNewSkin) then
    local heroId = Data.SkinsData[tostring(self.iNewSkinId)].RoleId
    local isOwnHero = StoreCtrl.Instance:isHeroOwn(heroId)
    local isOwnSkin = StoreCtrl.Instance:isSkinOwn(self.iNewSkinId)
    if (isOwnHero == false and isOwnSkin == false) then
      self.tNewBuyPart.gameObject:SetActive(false)
      self.btnLeftNor.gameObject:SetActive(true)
      self.labHave.gameObject:SetActive(false)
      self.labLeftNor:GetComponent(Text).text = "需先获得该姬神"
    elseif (isOwnHero == true and isOwnSkin == false) then
      self.labHave.gameObject:SetActive(false)
      self.tNewBuyPart.gameObject:SetActive(true)
      self.btnLeftNor.gameObject:SetActive(false)

      self.tNewBuyPart:GetChild(0).gameObject:SetActive(false)

      local rmb = self.tNewBuyPart:GetChild(1)
      local labRmb = rmb:FindChild("Text")
      labRmb:GetComponent("UnityEngine.UI.Text").text = tostring(UTGData.Instance().ShopsData[tostring(self.iNewSkinId)][1].VoucherPrice)
      self.midBuyType =  3
      if (UTGData.Instance().ShopsData[tostring(self.iNewSkinId)][1].VoucherPrice <= 0) then
        rmb.gameObject:SetActive(false)
      else 
        rmb.gameObject:SetActive(true)
        local labBtn = rmb:FindChild("Button/Text")
        local sprIcom = rmb:FindChild("Image")
        labBtn:GetComponent("UnityEngine.UI.Text").text = "点券购买"
        sprIcom:GetComponent(Image).sprite =  UITools.GetSprite("resourceicon","Voucher")
      end

      local part = self.tNewBuyPart:GetChild(2)
      local labPart = part:FindChild("Text")
      labPart:GetComponent("UnityEngine.UI.Text").text = tostring(UTGData.Instance().PartShopsData[tostring(self.iNewSkinId)].Price)
    elseif (isOwnSkin == true) then
      self.tNewBuyPart.gameObject:SetActive(false)
      self.btnLeftNor.gameObject:SetActive(false)
      self.labHave.gameObject:SetActive(true)
      self.labLeftNor:GetComponent(Text).text = "已拥有"
    end
  end
end

function StoreNewCtrl:EffectInit()
 local tabRender = self.effectAlltime:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    for k = 0,tabRender.Length - 1 do
      self.effectAlltime:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(tabRender[k].material.shader.name)
    end

  local tabRender1 = self.effectOnce:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    for k = 0,tabRender1.Length - 1 do
      self.effectOnce:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(tabRender1[k].material.shader.name)
    end

end

--两个新品切换
function StoreNewCtrl:btnInit(args)
  self.tabTopBtnLabWhite = {}
  self.tabTopBtnImage = {}
  for i = 0, self.tTopBtnPart.childCount-1,1 do
    local btn = self.tTopBtnPart:GetChild(i)

    local labWhite = btn:FindChild("LabWhite")
    table.insert(self.tabTopBtnLabWhite,labWhite)

    local sprWhite = btn:FindChild("Image")
    table.insert(self.tabTopBtnImage,sprWhite)
    local listener = NTGEventTriggerProxy.Get(btn.gameObject)
    local callback = function(self, e)
      self:onClickTop(i+1)
	  end	
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
  end

  for i = 1, 3,1 do
    local part = self.tNewBuyPart:GetChild(i-1)
    local btn = part:FindChild("Button")
    local listener = NTGEventTriggerProxy.Get(btn.gameObject)
    local callback = function(self, e)
      self:onClickNewBuy(i)
	  end	
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)
  end

  local listener = NTGEventTriggerProxy.Get(self.tBtnBoxOpen.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(StoreNewCtrl.onClickBoxOpen,self )

end

--开启宝箱
function StoreNewCtrl:onClickBoxOpen(args)
  --Debugger.Log("onClickBoxOpen")
  local serverRequest = NetRequest.New()
  serverRequest.Content = JObject.New(JProperty.New("Type","RequestBuyNewCommodityChest"),
                                      JProperty.New("ChestType",self.iTypeTab))
  serverRequest.Handler = TGNetService.NetEventHanlderSelf(StoreNewCtrl.onServerBoxOpen,self)
  TGNetService.GetInstance():SendRequest(serverRequest)
end

--开启宝箱回调
function StoreNewCtrl:onServerBoxOpen(e)
  --Debugger.Log("onServerBoxOpen")
  if e.Type == "RequestBuyNewCommodityChest" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      --Debugger.Log("购买成功")
     
      --self:labPartNumUpdate(self.iTypeTab)
      local tabReward = json.decode(e.Content:get_Item("Reward"):ToString())
      if (tabReward.Type ~= 1 and tabReward.Type ~= 2) then
        --Debugger.Log("tabReward = "..tabReward.Id)
        local tabList = {}
        table.insert(tabList,tabReward)
        --调用获得奖励的界面todo
        local function CreatePanelAsync()
            local async = GameManager.CreatePanelAsync("GetRune")
            while async.Done == false do
              coroutine.wait(0.05)
            end
            if GetRuneAPI.Instance ~= nil then
              GetRuneAPI.Instance:ShowReward(tabList) --调用显示奖励api
            end
         end
         coroutine.start(CreatePanelAsync,self)
       end
    elseif result == 0 then
      --Debugger.Log("购买失败")
    elseif result == 2821 then
      --Debugger.Log("点券不足")
      local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("SelfHideNotice")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("点券不足") 

          end
       end
       coroutine.start(CreatePanelAsync,self)
    end
    return true
  end
  return false
end

--top按钮响应
function StoreNewCtrl:onClickTop(idx)
  if (self.iTypeTab == idx) then
    return
  end
  self:topBtnWhiteActive(idx)
  self.iTypeTab = idx
  if (self.iTypeTab == TypeTabNewHero) then
    self:onNewHero()
  elseif (self.iTypeTab == TypeTabNewSkin) then
    self:onNewSkin()
  end

  self:newBuyBtnPartUpdate()
  --Debugger.Log("onClickTop"..idx)
end

function StoreNewCtrl:topBtnWhiteActive(idx)
  if self.tabTopBtnLabWhite == nil then
    return
  end
  for i = 1,#self.tabTopBtnLabWhite,1 do
    if i == idx then
      self.tabTopBtnLabWhite[i].gameObject:SetActive(true)
      self.tabTopBtnImage[i].gameObject:SetActive(true)
    else
      self.tabTopBtnLabWhite[i].gameObject:SetActive(false)
      self.tabTopBtnImage[i].gameObject:SetActive(false)
    end
  end
end


function StoreNewCtrl:OnDestroy() 
  NTGApplicationController.SetShowQuality(false)
  GameObject.Destroy(self.model.gameObject)
  StoreNewCtrl.Instance = nil
  self.this = nil
  self = nil
end

function StoreNewCtrl:onNewHero()
  self:modelDisplay(self.iNewHeroId,true)
  self.tSkinName.gameObject:SetActive(false)
  self.tSkillBtnPart.gameObject:SetActive(true)

  local roleInfo = Data.RolesData[tostring(self.iNewHeroId)]
  self.tHeroClassIcon:GetComponent(Image).sprite = UITools.GetSprite("classicon",  "ClassIcon" .. roleInfo.Class)
  self.tHeroName:GetComponent(Text).text = roleInfo.Name
  self:onBoxHeroUpdate(self.iNewHeroId)
  self:labPartNumUpdate(TypeTabNewHero)

  --更新两个icon
  self.sprPartIcon1:GetComponent(Image).sprite = UITools.GetSprite("itemicon",UTGData.Instance().ItemsData[tostring(15010001)].Icon)
  self.sprPartIcon1:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector3.New(44,44,0)

  self.sprPartIcon2:GetComponent(Image).sprite = UITools.GetSprite("itemicon",UTGData.Instance().ItemsData[tostring(15010001)].Icon)
  self.sprPartIcon2:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector3.New(44,44,0)

  if self.bCanUpdateHero == true then
    self.bCanUpdateHero = false
    self:heroInfoInit()
  end
end

--更新符文碎片数量
function StoreNewCtrl:labPartNumUpdate(typePage)
  local num = 0
  if (typePage == TypeTabNewHero) then
    if (UTGData.Instance().ItemsDeck[tostring(15010001)]~= nil) then
      num = UTGData.Instance().ItemsDeck[tostring(15010001)].Amount 
    else
      num = 0
    end
  elseif (typePage == TypeTabNewSkin) then
    if (UTGData.Instance().ItemsDeck[tostring(15020001)] ~= nil) then
      num = UTGData.Instance().ItemsDeck[tostring(15020001)].Amount 
    else
      num = 0
    end
  end
  self.labPartNum:GetComponent("UnityEngine.UI.Text").text = num
end

function StoreNewCtrl:onNewSkin()
  self:modelDisplay(self.iNewSkinId,false)
  self.tSkillBtnPart.gameObject:SetActive(false)
  self.tSkinName.gameObject:SetActive(true)

  local skinInfo = UTGData.Instance().SkinsData[tostring(self.iNewSkinId)]
  self.tSkinName:GetComponent(Text).text = skinInfo.Name
  local skinHeroId = skinInfo.RoleId
  local roleInfo = Data.RolesData[tostring(skinHeroId)]
  self.tHeroName:GetComponent(Text).text = roleInfo.Name
  self.tHeroClassIcon:GetComponent(Image).sprite = UITools.GetSprite("classicon",  "ClassIcon" .. roleInfo.Class)
  self:onBoxSkinUpdate(self.iNewSkinId)
  self:labPartNumUpdate(TypeTabNewSkin)

    --更新两个icon
  self.sprPartIcon1:GetComponent(Image).sprite = UITools.GetSprite("itemicon",UTGData.Instance().ItemsData[tostring(15020001)].Icon)
  self.sprPartIcon1:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector3.New(44,44,0)

  self.sprPartIcon2:GetComponent(Image).sprite = UITools.GetSprite("itemicon",UTGData.Instance().ItemsData[tostring(15020001)].Icon)
  self.sprPartIcon2:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector3.New(44,44,0)

  if self.bCanUpdateSkin == true then
    self.bCanUpdateSkin = false
    self:skinInfoInit()
  end
end

function StoreNewCtrl:onClickNewBuy(idx)
  --Debugger.Log("onClickNewBuy"..idx)
  local buyType = -1
  if (idx == 1) then
    buyType = 1
  elseif idx == 2 then
    buyType = self.midBuyType
  end

  local shopId = -1
  if (self.iTypeTab == TypeTabNewHero) then
    shopId = self.iNewHeroId
  elseif (self.iTypeTab == TypeTabNewSkin) then
    shopId = self.iNewSkinId
  end
  if (idx == 1 or idx == 2) then
    local orderShopId = 0
    if (UTGData.Instance().ShopsData[tostring(shopId)][1] ~= nil) then
      orderShopId = UTGData.Instance().ShopsData[tostring(shopId)][1].Id
      --Debugger.Log("StoreNewCtrl:onClickNewBuy orderShopId = "..orderShopId)
      UTGDataOperator.Instance:ShopBuy(orderShopId,buyType,1)
    end
  else --碎片
    if (UTGData.Instance().PartShopsData[tostring(shopId)] ~= nil) then
      local partId = UTGData.Instance().PartShopsData[tostring(shopId)].Id
      UTGDataOperator.Instance:ExchangePartCommodity(partId)
    end
  end
end

function StoreNewCtrl:heroInfoInit(args)
  
  self:skillBtnUpdate(self.iNewHeroId)
  self:SkillTipsUpdate(self.iNewHeroId)
end

function StoreNewCtrl:skinInfoInit(args)
  --要通过皮肤id得到英雄id
  
end


function StoreNewCtrl:skillBtnUpdate(heroId)
--  for i = 1,4 do
--    self.tSkillBtnPart:GetChild(i - 1):Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("skillicon-" .. heroId,Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].Icon)
--    --self.skillZone:GetChild(i - 1).name = tostring(Data.RolesData[tostring(heroId)].Skills[i+1])
--  end
  self.tSkillBtnPart:GetChild(0):Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("skillicon-" .. heroId,Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[5])].Icon)
  self.tSkillBtnPart:GetChild(1):Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("skillicon-" .. heroId,Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[2])].Icon)
  self.tSkillBtnPart:GetChild(2):Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("skillicon-" .. heroId,Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[3])].Icon)
  self.tSkillBtnPart:GetChild(3):Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("skillicon-" .. heroId,Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[4])].Icon)
end

function StoreNewCtrl:SkillTipsUpdate(heroId)
  local tipsPosition = {}
  local newPosition = {{},{},{},{}}
  for i = 1,4 do
    tipsPosition[i] = self.skillTips[1]:Find("Panel"):GetChild(i-1).localPosition
  end

  for i = 1,4 do
    self.skillTips[i]:Find("Panel/SkillName"):GetComponent(Text).text = Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i + 1])].Name
    for k = 1,#Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i + 1])].Tags do
      if Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i + 1])].Tags[k] == "1" then
        self.skillTips[i]:Find("Panel/PIcon").gameObject:SetActive(true)
        table.insert(newPosition[i],self.skillTips[i]:Find("Panel/PIcon"))
      elseif Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i + 1])].Tags[k] == "2" then
        self.skillTips[i]:Find("Panel/MIcon").gameObject:SetActive(true)
        table.insert(newPosition[i],self.skillTips[i]:Find("Panel/MIcon"))
      elseif Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i + 1])].Tags[k] == "3" then
        self.skillTips[i]:Find("Panel/CIcon").gameObject:SetActive(true)
        table.insert(newPosition[i],self.skillTips[i]:Find("Panel/CIcon"))
      elseif Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i + 1])].Tags[k] == "4" then
        self.skillTips[i]:Find("Panel/RIcon").gameObject:SetActive(true)
        table.insert(newPosition[i],self.skillTips[i]:Find("Panel/RIcon"))
      end
    end
    self.skillTips[i]:Find("Panel2/CDTitle/CDNum"):GetComponent(Text).text = Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].Cd .. "秒"
    self.skillTips[i]:Find("Panel2/MCost/MCostNum"):GetComponent(Text).text = Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].MpCost


    if #Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam == 1 and Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[1][2] ~= 0 then
      if Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[1][2] == "1" then
        self.skillTips[i]:Find("Desc"):GetComponent(Text).text = string.format(Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].Desc,
                                  (Data.SkillBehavioursData[tostring(Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[1][1])].PAtkAdd * Data.RolesData[tostring(heroId)].PAtk))
      elseif Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[1][2] == "2" then
        self.skillTips[i]:Find("Desc"):GetComponent(Text).text = string.format(Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].Desc,
                                  (Data.SkillBehavioursData[tostring(Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[1][1])].MAtkAdd * Data.RolesData[tostring(heroId)].MAtk))        
      elseif Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[1][2] == "0" then
        self.skillTips[i]:Find("Desc"):GetComponent(Text).text = Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].Desc
      end
    elseif #Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam == 2 then
        local add1 = ""
        local add2 = ""
        if #Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[1][2] == "1" then
          add1 = Data.SkillBehavioursData[tostring(Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[1][1])].PAtkAdd * Data.RolesData[tostring(heroId)].PAtk
        else
          add1 = Data.SkillBehavioursData[tostring(Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[1][1])].MAtkAdd * Data.RolesData[tostring(heroId)].MAtk
        end
        if #Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[2][2] == "1" then
          add2 = Data.SkillBehavioursData[tostring(Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[2][1])].PAtkAdd * Data.RolesData[tostring(heroId)].PAtk
        else
          add2 = Data.SkillBehavioursData[tostring(Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[2][1])].MAtkAdd * Data.RolesData[tostring(heroId)].MAtk
        end
        self.skillTips[i]:Find("Desc"):GetComponent(Text).text = string.format(Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].Desc,add1,add2)        
    else
        self.skillTips[i]:Find("Desc"):GetComponent(Text).text = Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].Desc
    end
    self.skillTips[i].gameObject:SetActive(false)
    
  end
  
  for k = 1,4 do
    for i = 1,#newPosition[k] do
      newPosition[k][i].localPosition = tipsPosition[i]
    end
  end
end

function StoreNewCtrl:onBoxHeroUpdate(heroId)
  --local itemInfo = UTGData.Instance().ItemsData[tostring(heroId)]
  local roleInfo = UTGData.Instance().RolesData[tostring(heroId)]
  local skinInfo = UTGData.Instance().SkinsData[tostring(roleInfo.Skin)]
  for i = 1, 4,1 do
    local labName = self.tabBox[i]:FindChild("LabName") 
   
    if (i == 1 or i == 2) then
      local sprIcon = self.tabBox[i]:FindChild("Image/Image/SprIcon")
      sprIcon:GetComponent(Image).sprite = UITools.GetSprite("roleicon",skinInfo.Icon)
      if (i == 2) then
        local sprHeroTry = self.tabBox[i]:FindChild("HeroTry")
        local sprSkinTry = self.tabBox[i]:FindChild("SkinTry")
        sprHeroTry.gameObject:SetActive(true)
        sprSkinTry.gameObject:SetActive(false)
      end
      labName:GetComponent(Text).text = roleInfo.Name
    elseif i == 3 or i== 4 then
      local sprIcon = self.tabBox[i]:FindChild("Image/Image/SprIcon")
      sprIcon:GetComponent(Image).sprite = UITools.GetSprite("itemicon",UTGData.Instance().ItemsData[tostring(15010001)].Icon)
      labName:GetComponent(Text).text = UTGData.Instance().ItemsData[tostring(15010001)].Name
    end
  end
end

function StoreNewCtrl:onBoxSkinUpdate(skinId)
  local skinInfo = UTGData.Instance().SkinsData[tostring(skinId)]

  for i = 1, 4,1 do
    local labName = self.tabBox[i]:FindChild("LabName") 
   
    if (i == 1 or i == 2) then
      local sprIcon = self.tabBox[i]:FindChild("Image/Image/SprIcon")
      sprIcon:GetComponent(Image).sprite = UITools.GetSprite("roleicon",skinInfo.Icon)
      if (i == 2) then
        local sprHeroTry = self.tabBox[i]:FindChild("HeroTry")
        local sprSkinTry = self.tabBox[i]:FindChild("SkinTry")
        sprHeroTry.gameObject:SetActive(false)
        sprSkinTry.gameObject:SetActive(true)
      end
      labName:GetComponent(Text).text = skinInfo.Name
    elseif i == 3 or i== 4 then
      local sprIcon = self.tabBox[i]:FindChild("Image/Image/SprIcon")
      sprIcon:GetComponent(Image).sprite = UITools.GetSprite("itemicon",UTGData.Instance().ItemsData[tostring(15020001)].Icon)
      labName:GetComponent(Text).text = UTGData.Instance().ItemsData[tostring(15020001)].Name
    end
  end
end

function StoreNewCtrl:firstNotHaveNewIdGet(args)
  self.iNewHeroId = 0
  self.iNewSkinId = 0
  local tabTmp = UITools.CopyTab(UTGData.Instance().PartShopsDataForOrder)
  local tabHero = {}
  local tabSkin = {}
  for i,v in ipairs(tabTmp) do
    if (v.CommodityType == 1) then-- 英雄
      table.insert(tabHero,v)
    elseif (v.CommodityType == 2) then
      table.insert(tabSkin,v)
    end
  end

  for i,v in ipairs(UTGData.Instance().PartShopsDataForOrder) do
    if (v.CommodityType == 1) then-- 英雄
      if (UTGData.Instance().RolesDeckData[tostring(v.CommodityId)] == nil) then
        self.iNewHeroId = v.CommodityId
        break
      end
      if (UTGData.Instance().RolesDeckData[tostring(v.CommodityId)].IsOwn == false) then
        self.iNewHeroId = v.CommodityId
        break
      end
    end
  end

  for i,v in ipairs(UTGData.Instance().PartShopsDataForOrder) do
    if (v.CommodityType == 2) then-- 皮肤
      if (UTGData.Instance().SkinsDeckData[tostring(v.CommodityId)] == nil) then
        self.iNewSkinId = v.CommodityId
        break
      end
      if (UTGData.Instance().SkinsDeckData[tostring(v.CommodityId)].IsOwn == false) then
        self.iNewSkinId = v.CommodityId
        break
      end
    end
  end

  --Debugger.Log("self.iNewHeroId = "..self.iNewHeroId)
  --Debugger.Log("self.iNewSkinId = "..self.iNewSkinId)

  if (self.iNewHeroId == 0) then
    local len = #tabHero
    self.iNewHeroId = tabHero[len].CommodityId
  end

  if (self.iNewSkinId == 0) then
    local len = #tabSkin
    self.iNewSkinId = tabSkin[len].CommodityId
  end
end

function StoreNewCtrl:modelDisplay(heroId,isHero)

--英雄模型

  --self.leftInfoPanel:Find("RawEvent").gameObject:SetActive(true)

  --tempo:Find("desk").transform.localRotation = Quaternion.identity
  for i=1,self.model:Find("desk/root").childCount do
    GameObject.Destroy(self.model:Find("desk/root"):GetChild(i-1).gameObject)
  end
  local assetbundle

--  if Data.RolesDeckData[tostring(heroId)] ~= nil then
--    assetbundle = NTGResourceController.Instance:LoadAsset("skin"..tostring(Data.SkinsData[tostring(Data.RolesDeckData[tostring(heroId)].Skin)].Resource),
--                                                                        tostring(Data.SkinsData[tostring(Data.RolesDeckData[tostring(heroId)].Skin)].Resource) .. "-Show")
--  else
--    assetbundle = NTGResourceController.Instance:LoadAsset("skin"..tostring(Data.SkinsData[tostring(Data.RolesData[tostring(heroId)].Skin)].Resource),
--                                                                        tostring(Data.SkinsData[tostring(Data.RolesData[tostring(heroId)].Skin)].Resource) .. "-Show")
--  end
  if (isHero == true) then
    assetbundle = NTGResourceController.Instance:LoadAsset("skin"..tostring(Data.SkinsData[tostring(Data.RolesData[tostring(heroId)].Skin)].Resource),tostring(Data.SkinsData[tostring(Data.RolesData[tostring(heroId)].Skin)].Resource) .. "-Show")
  elseif (isHero == false) then
    assetbundle = NTGResourceController.Instance:LoadAsset("skin"..tostring(Data.SkinsData[tostring(heroId)].Resource),tostring(Data.SkinsData[tostring(heroId)].Resource) .. "-Show")
  end

  if assetbundle == nil then
    self.leftInfoPanel:Find("MakeNotice").gameObject:SetActive(true)
      self.model:Find("Plane"):GetComponent(NTGLuaScript.GetType("UnityEngine.Renderer")).material.shader = UnityEngine.Shader.Find(self.model:Find("Plane"):GetComponent(NTGLuaScript.GetType("UnityEngine.Renderer")).material.shader.name)
  self.model:Find("Plane/Plane"):GetComponent(NTGLuaScript.GetType("UnityEngine.Renderer")).material.shader = UnityEngine.Shader.Find(self.model:Find("Plane/Plane"):GetComponent(NTGLuaScript.GetType("UnityEngine.Renderer")).material.shader.name)
  end


  local model
  if assetbundle ~= nil then
    model = GameObject.Instantiate(assetbundle)
    model.gameObject:SetActive(true)


  local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,btn.Length - 1 do
    if k ~= btn.Length-1 and btn[k].transform.name ~= btn[k+1].transform.name then
      for i = 0,btn[k].materials.Length-1 do
        model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].materials[i].shader = UnityEngine.Shader.Find(btn[k].materials[i].shader.name)
      end
    end
  end

  self.model:Find("Plane"):GetComponent(NTGLuaScript.GetType("UnityEngine.Renderer")).material.shader = UnityEngine.Shader.Find(self.model:Find("Plane"):GetComponent(NTGLuaScript.GetType("UnityEngine.Renderer")).material.shader.name)
  self.model:Find("Plane/Plane"):GetComponent(NTGLuaScript.GetType("UnityEngine.Renderer")).material.shader = UnityEngine.Shader.Find(self.model:Find("Plane/Plane"):GetComponent(NTGLuaScript.GetType("UnityEngine.Renderer")).material.shader.name)
  self.model:Find("desk"):GetComponent(NTGLuaScript.GetType("UnityEngine.Renderer")).material.shader = UnityEngine.Shader.Find(self.model:Find("desk"):GetComponent(NTGLuaScript.GetType("UnityEngine.Renderer")).material.shader.name)

  model.transform.parent = self.model:FindChild("desk/root")
  model.transform.localPosition = Vector3.zero
  model.transform.localRotation = Quaternion.identity
  model.transform.localScale = Vector3.one
  self.model:FindChild("desk").localRotation = Quaternion.Euler(270,0,0)
  self.modelAnimator = model:GetComponent("Animator")
  self.modelAnimator:SetTrigger("show")
  for i = model.transform.childCount,1,-1 do
    if model.transform:GetChild(i-1).name == "FX-Show" then
      self.fxShow = model.transform:GetChild(i-1)
      local fx = model.transform:GetChild(i-1):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
      local renderer = model.transform:GetChild(i-1):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))

      for k = 0,renderer.Length - 1 do
        ----print(model.transform.name)
        model.transform:GetChild(i-1):GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(renderer[k].material.shader.name)
      end

      for k = 0,fx.Length - 1 do
        fx[k]:Play()
      end
    end

    if model.transform:GetChild(i-1).name == "FX-Play" then
      self.fxPlay = model.transform:GetChild(i-1)
    end
  end

  self.model:SetParent(nil)
  self.model.position = Vector3.New(0,0,0)
  self.roleModel = model.transform
  end
end

function StoreNewCtrl:DoOpenPartShop()
  -- body
  coroutine.start(StoreNewCtrl.OpenPartShop,self) 
end

function StoreNewCtrl:OpenPartShop()
  -- body
  local async = GameManager.CreatePanelAsync("PartShop")
  while async.Done == false do
    coroutine.wait(0.05)
  end
end