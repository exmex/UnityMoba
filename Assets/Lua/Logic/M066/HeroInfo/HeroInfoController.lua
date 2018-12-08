require "System.Global"
require "Logic.UTGData.UTGData"

class("HeroInfoController")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"

local json = require "cjson"

function HeroInfoController:Awake(this)
  self.this = this

  --UTGDataOperator.Instance:InitTop("HeroInfoPanel",self,HeroInfoController.DestroySelf,nil,nil,"姬神详情")


  self.leftInfoPanel = self.this.transforms[0]
  self.rightInfoPanel = self.this.transforms[1]
  self.propertyPanel = self.this.transforms[2]
  self.storyPanel = self.this.transforms[3]
  self.buyHeroPanel = self.this.transforms[4]
  --self.getNewPanel = self.this.transforms[5]
  self.buySkinPanel = self.this.transforms[5]
  self.giftSkinPanel = self.this.transforms[6]
  self.skinList = self.this.transforms[7]
  self.testButton = self.this.transforms[8]
  --self.topPanel = self.this.transforms[9]
  self.model = self.this.transforms[9]
  
  self.cubespeed = this.floats[0]
  
  self.model:Find("Plane/Plane").gameObject:SetActive(false)
  self:SaveDataFromLastPanel()
  
  
  --英雄职业图标
  self.heroClassIcon = self.leftInfoPanel:Find("HeroNamePanel/ClassTypeIconFrame/ClassTypeIcon")
  
  --英雄皮肤图标
  self.heroSkinName = self.leftInfoPanel:Find("HeroNamePanel/SkinName")
  
  --英雄名称
  self.heroName = self.leftInfoPanel:Find("HeroNamePanel/HeroName")
  
  --英雄获取途径
  self.needBuyPanel = self.leftInfoPanel:Find("NeedBuy")
  self.payBuy = self.leftInfoPanel:Find("NeedBuy/PayBuy")
  self.ticketBuy = self.leftInfoPanel:Find("NeedBuy/TicketBuy")
  self.sendGet = self.leftInfoPanel:Find("NeedBuy/SendGet")
  
  --英雄定位
  self.rightTop = self.rightInfoPanel:Find("Top")
  self.labelZone = self.rightTop:Find("Panel/LabelZone")
  self.typeName = self.labelZone:Find("Type")
  
  --英雄熟练度
  self.proficiencyIcon = self.labelZone:Find("Panel/ProficiencyIcon")
  self.proficiencyName = self.labelZone:Find("Panel/ProficiencyName")
  self.currentProficiency = self.labelZone:Find("Panel/CurrentProficiency")
  self.maxProficiency = self.labelZone:Find("Panel/MaxProficiency")
  self.proficiencyPanel = self.labelZone:Find("Panel")
  
  --英雄评级
  self.ratingZone = self.rightTop:Find("Panel/RatingZone")
  
  --皮肤特性
  self.feature = self.rightTop:Find("Feature")
  
  --英雄技能图标
  self.skillZone = self.rightInfoPanel:Find("Mid/SkillZone")
  
  --英雄技能Tips
  self.skillTips = {}
  for i = 1,4 do
    self.skillTips[i] = self.leftInfoPanel:Find("SkillTip" .. i)
  end
  
  --英雄基础属性
  self.heroPropertyButton = self.leftInfoPanel:Find("LeftButtonZone/PropertyButton")
  self.heroPropertyCancelButton = self.propertyPanel:Find("PropertyFrame/CancelButton")
  self.baseTextZone = self.propertyPanel:Find("PropertyFrame/PropertyTextZone/Left/BasePropertyText")
  self.atkTextZone = self.propertyPanel:Find("PropertyFrame/PropertyTextZone/Mid/AtkPropertyText")
  self.defTextZone = self.propertyPanel:Find("PropertyFrame/PropertyTextZone/Right/DefPropertyText")
  
  --英雄背景故事
  self.heroStoryButton = self.leftInfoPanel:Find("LeftButtonZone/StoryButton")
  self.heroStory = self.storyPanel:Find("StoryFrame/Panel/Content/Text")
  self.heroStoryCancelButton = self.storyPanel:Find("StoryFrame/CancelButton")
  
  --英雄装备
  self.equipButton = self.leftInfoPanel:Find("LeftButtonZone/EquipButton")

  --模型原画切换
  self.changeButton = self.leftInfoPanel:Find("LeftButtonZone/ChangeButton")
  self.rolePainting = self.leftInfoPanel:Find("RolePaintingBg/RolePainting")
  self.rolePaintingBg = self.leftInfoPanel:Find("RolePaintingBg")
  
  --英雄购买
  self.coinNum = self.buyHeroPanel:Find("BuyHeroFrame/BuyInfo/PayCoin/PayNum")
  self.payCoinPanel = self.buyHeroPanel:Find("BuyHeroFrame/BuyInfo/PayCoin")
  self.payOtherWayPanel = self.buyHeroPanel:Find("BuyHeroFrame/BuyInfo/PayOtherWay")
  self.payOtherWayType = self.payOtherWayPanel:Find("PayType")
  self.payOtherWayIcon = self.payOtherWayPanel:Find("PayTypeIcon")
  self.payOtherWayNum = self.payOtherWayPanel:Find("PayNum")
  self.payCoinButton = self.buyHeroPanel:Find("BuyHeroFrame/BuyInfo/PayCoinButton")
  self.payOtherWayButton = self.buyHeroPanel:Find("BuyHeroFrame/BuyInfo/PayOtherWayButton")
  self.payOtherWayButtonName = self.payOtherWayButton:Find("Text")
  self.payOtherWayCancelButton = self.buyHeroPanel:Find("BuyHeroFrame/CancelButton")
  
  --获得新英雄/皮肤
  --self.getNewTitle = self.getNewPanel:Find("GetNewTitle/Title")
  --self.getNewNameFrame = self.getNewPanel:Find("GetNewNameFrame")
  --self.getNewName = self.getNewNameFrame:Find("Text")
  --self.confirmButton = self.getNewPanel:Find("ConfirmButton")
  --self.getNewConfirmButton = self.getNewPanel:Find("ConfirmButton")
  
  --皮肤购买
  self.skinIcon = self.buySkinPanel:Find("BuyHeroFrame/BuyInfo/Mask/HeroIcon")
  self.payTicketNum = self.buySkinPanel:Find("BuyHeroFrame/BuyInfo/PayTicket/PayNum")
  self.giftButton = self.buySkinPanel:Find("BuyHeroFrame/BuyInfo/Button")
  self.payButton = self.buySkinPanel:Find("BuyHeroFrame/BuyInfo/Button2")
  self.skinPropertyPanel = self.buySkinPanel:Find("BuyHeroFrame/BuyInfo/SkinProperty")
  self.skinProperty = {}
  for i = 1,7 do
    table.insert(self.skinProperty ,self.skinPropertyPanel:Find("SkinProperty"):GetChild(i - 1))
  end
  self.buySkinCancelButton = self.buySkinPanel:Find("BuyHeroFrame/CancelButton")
  
  --皮肤赠送
  self.skinIcon1 = self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/Mask/HeroIcon")
  self.ticketNum = self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/PayTicket/PayNum")
  self.inputArea = self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/SearchFriend/inputFrame/InputField")
  self.searchButton = self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/SearchFriend/Button")
  self.friendList = self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/SearchFriend/FriendList")
  self.giftSkinCancelButton = self.giftSkinPanel:Find("BuyHeroFrame/CancelButton")
  
  --皮肤列表
  self.ll = self.rightInfoPanel:Find("Bottom/Panel/ll")
  self.rr = self.rightInfoPanel:Find("Bottom/Panel/rr")
  self.mm = self.rightInfoPanel:Find("Bottom/Panel/mm")
  self.scrollPanel = self.rightInfoPanel:Find("Bottom/Panel")
  
  --左右切换按钮
  self.toLeft = self.leftInfoPanel:Find("ToLeft")
  self.toRight = self.leftInfoPanel:Find("ToRight")

  --体验时间
  self.tryTime = self.leftInfoPanel:Find("ExprienceTime")

  --体验卡使用
  self.needCount = {}
  self.trans = {}


  self.roleModel = ""   --人物模型
  self.fxShow = ""
  self.fxPlay = ""


  self.getNewType = ""

  self.lastSelectedModel = ""

  self.isModelOrPainting = "Model"  
  
  
  
  
  --按钮事件绑定
  local listener
  listener = NTGEventTriggerProxy.Get(self.heroPropertyButton.gameObject)
  local callback = function(self, e)
    self:GetHeroProperty(self.HeroId,self.SkinId)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self) 

  listener = NTGEventTriggerProxy.Get(self.heroStoryButton.gameObject)
  local callback1 = function(self, e)
    self:GetHeroStory(self.HeroId)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)
  
  listener = NTGEventTriggerProxy.Get(self.testButton.gameObject)
  local callback2 = function(self, e)
    coroutine.start(HeroInfoController.Test,self)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback2, self)
  
  listener = NTGEventTriggerProxy.Get(self.heroPropertyCancelButton.gameObject)
  local callback4 = function(self, e)
    self:ClosePanel("Property")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback4, self)
  
  listener = NTGEventTriggerProxy.Get(self.scrollPanel.gameObject)
  local callback3 = function(self, e)
    --self:GoToCenter()
  end
  listener.onEndDrag = NTGEventTriggerProxy.PointerEventDelegateSelf(callback3, self)

  listener = NTGEventTriggerProxy.Get(self.heroStoryCancelButton.gameObject)
  local callback5 = function(self, e)
    self:ClosePanel("Story")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback5, self)
  
  listener = NTGEventTriggerProxy.Get(self.payOtherWayCancelButton.gameObject)
  local callback6 = function(self, e)
    self:ClosePanel("BuyHero")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback6, self)

--[[
  listener = NTGEventTriggerProxy.Get(self.getNewConfirmButton.gameObject)
  local callback7 = function(self, e)
    self:ClosePanel("GetNew")
  end
  listener.onPointerClick = listener.onPointerClick + DelegateFactory.NTGEventTriggerProxy_PointerEventDelegate_Self(self, callback7)
]]

  listener = NTGEventTriggerProxy.Get(self.buySkinCancelButton.gameObject)
  local callback8 = function(self, e)
    self:ClosePanel("BuySkin")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback8, self)
  
  listener = NTGEventTriggerProxy.Get(self.giftSkinCancelButton.gameObject)
  local callback9 = function(self, e)
    self:ClosePanel("GiftSkin")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback9, self)
  

  listener = NTGEventTriggerProxy.Get(self.equipButton.gameObject)
  local callback10 = function(self, e)
    self:GoToEquipPanel1()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback10, self)

  listener = NTGEventTriggerProxy.Get(self.toLeft.gameObject)
  local callback12 = function(self, e)
    self:ToLastHero()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback12, self)
  
  listener = NTGEventTriggerProxy.Get(self.toRight.gameObject)
  local callback13 = function(self, e)
    self:ToNextHero()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback13, self)

  listener = NTGEventTriggerProxy.Get(self.ticketBuy:Find("Button").gameObject)
  listener = NTGEventTriggerProxy.Get(self.payBuy:Find("Button").gameObject)
  local callback14 = function(self, e)
    self.buyHeroPanel.gameObject:SetActive(true)
    self:BuyHero(self.HeroId)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback14, self)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback14, self)

  listener = NTGEventTriggerProxy.Get(self.leftInfoPanel:Find("RawEvent").gameObject)
  listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(HeroInfoController.DragCube, self)

  listener = NTGEventTriggerProxy.Get(self.buySkinPanel:Find("BuyHeroFrame/BuyInfo/Button").gameObject)
  local callback13 = function(self, e)
    self:GiftSkin()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback13, self)

  listener = NTGEventTriggerProxy.Get(self.changeButton.gameObject)
  local callback14 = function(self, e)
    if self.isModelOrPainting == "Model" then
      self.isModelOrPainting = "Painting"
      self.model.gameObject:SetActive(false)

      self.rolePaintingBg.gameObject:SetActive(true)
      self.changeButton:Find("ButtonName1").gameObject:SetActive(true)
      self.changeButton:Find("ButtonName").gameObject:SetActive(false)
      self.changeButton:Find("Image").gameObject:SetActive(true)
      self.changeButton:Find("ButtonIcon1").gameObject:SetActive(true)
      self.changeButton:Find("ButtonIcon").gameObject:SetActive(false)
    elseif self.isModelOrPainting == "Painting" then
      self.isModelOrPainting = "Model"
      self.model.gameObject:SetActive(true)
      self.rolePaintingBg.gameObject:SetActive(false)
      self.changeButton:Find("ButtonName1").gameObject:SetActive(false)
      self.changeButton:Find("ButtonName").gameObject:SetActive(true)
      self.changeButton:Find("Image").gameObject:SetActive(false)
      self.changeButton:Find("ButtonIcon1").gameObject:SetActive(false)
      self.changeButton:Find("ButtonIcon").gameObject:SetActive(true)     
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback14, self)

  self.coroutines = {}

  self.heroInfoPanel = self.this.transform:Find("HeroInfoMainPanel")
  self.heroInfoPanel.gameObject:SetActive(false)
end

function HeroInfoController:Start()

  NTGApplicationController.SetShowQuality(true)
  --UnityEngine.QualitySettings.blendWeights = UnityEngine.BlendWeights.FourBones
  self.model:Find("desk").transform:GetComponent("Renderer").material.shader = UnityEngine.Shader.Find(self.model:Find("desk"):GetComponent("Renderer").material.shader.name)

end

function HeroInfoController:SaveDataFromLastPanel()
  --英雄是否拥有
  self.IsOwn = 0      --0：未拥有且未限免   1：拥有    2：限免但未拥有    3：限免且已拥有
  --英雄类型及改类型英雄的List
  self.HeroType = 0
  self.HeroListOfOneType = {}
  --选择英雄的ID
  self.HeroId = 0
  self.SkinId = 11000001
  self.buyType = ""
  self.scale = self.rightInfoPanel:Find("Bottom/Panel/Panel"):GetChild(0).localScale
end


function HeroInfoController:InitSelectHero(heroId,list)
  --记录当前时间
  --self.currentTime = os.time()



  --预置数据
  self.IsOwn = 0    --英雄是否拥有置为未拥有且未限免状态
  self.needBuyPanel.gameObject:SetActive(true)
  self.payBuy.gameObject:SetActive(false)   --获取途径面板置灰
  self.ticketBuy.gameObject:SetActive(false)  --获取途径面板置灰  
  self.sendGet.gameObject:SetActive(false)    --获取途径面板置灰
  for i = 1,self.ratingZone.childCount do
    for k = 1,self.ratingZone:GetChild(i - 1):Find("RatingLight-image").childCount do
      self.ratingZone:GetChild(i - 1):Find("RatingLight-image"):GetChild(k - 1).gameObject:SetActive(false)
    end
  end
  for i = 1,4 do
    self.skillTips[i]:Find("Panel/PIcon").gameObject:SetActive(false)
    self.skillTips[i]:Find("Panel/CIcon").gameObject:SetActive(false)
    self.skillTips[i]:Find("Panel/MIcon").gameObject:SetActive(false)
    self.skillTips[i]:Find("Panel/RIcon").gameObject:SetActive(false)
  end
  self.needCount = {}
  self.trans = {}
  
  self.HeroId = heroId
  
  self.HeroList = list
  self.leftInfoPanel:Find("MakeNotice").gameObject:SetActive(false)
  self.tryTime.gameObject:SetActive(false)
  self.isModelOrPainting = "Model"
  self.model.gameObject:SetActive(true)
  self.rolePaintingBg.gameObject:SetActive(false)
  self.changeButton:Find("ButtonName1").gameObject:SetActive(false)
  self.changeButton:Find("ButtonName").gameObject:SetActive(true)
  self.changeButton:Find("Image").gameObject:SetActive(false)
  self.changeButton:Find("ButtonIcon1").gameObject:SetActive(false)
  self.changeButton:Find("ButtonIcon").gameObject:SetActive(true)

  --英雄名称，皮肤名称，英雄类型图标
  local haveRole = false
  self.heroClassIcon:GetComponent(Image).sprite = UITools.GetSprite("classicon",  "ClassIcon" .. Data.RolesData[tostring(heroId)].Class)
  if Data.RolesDeck ~= nil then
    for k,v in pairs(Data.RolesDeck) do
      if heroId == Data.RolesDeck[k].RoleId then
        self.heroSkinName:GetComponent(Text).text = Data.SkinsData[tostring(Data.RolesDeck[k].Skin)].Name
        haveRole = true
      end
    end
    if haveRole == false then
      self.heroSkinName:GetComponent(Text).text = Data.SkinsData[tostring(Data.RolesData[tostring(heroId)].Skin)].Name
    end
  else
    self.heroSkinName:GetComponent(Text).text = Data.SkinsData[tostring(Data.RolesData[tostring(heroId)].Skin)].Name
  end
  self.heroName:GetComponent(Text).text = Data.RolesData[tostring(heroId)].Name

  --显示英雄获取类型
  for k,v in pairs(Data.RolesDeck) do
    if heroId == Data.RolesDeck[k].RoleId and v.IsOwn == true then
      self.IsOwn = 1
      break
    else
      self.IsOwn = 0
    end
  end
  
  for k,v in pairs(UTGDataTemporary.Instance().LimitedData) do
    if heroId == UTGDataTemporary.Instance().LimitedData[k] then
      if self.IsOwn == 1 then
        self.IsOwn = 3
      else
        self.IsOwn = 2
      end
    end
  end

  
  if self.IsOwn == 0 or self.IsOwn == 2 then
    if Data.RolesData[tostring(heroId)].ForSale == true then
      local coinCost = 0
      local jewelCost = 0
      local ticketCost = 0
      coinCost = Data.ShopsData[tostring(heroId)][1].CoinPrice
      jewelCost = Data.ShopsData[tostring(heroId)][1].GemPrice
      ticketCost = Data.ShopsData[tostring(heroId)][1].VoucherPrice
      
      
      if coinCost == -1 and jewelCost == -1 and ticketCost ~= -1 then
        self.ticketBuy.gameObject:SetActive(true)
        self.ticketBuy:Find("TicketNum"):GetComponent(Text).text = ticketCost
        self.buyType = "OnlyTicket"
        local listener
        listener = NTGEventTriggerProxy.Get(self.ticketBuy:Find("Button").gameObject)
        local callback = function(self, e)
          GameManager.CreatePanel("BuyHero")
          if BuyHeroAPI ~= nil and BuyHeroAPI.Instance ~= nil then
            BuyHeroAPI.Instance:BuyHero(heroId,1)
          end
        end
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self) 
      elseif coinCost ~= -1 and jewelCost ~= -1 and ticketCost == -1 then
        self.payBuy.gameObject:SetActive(true)
        self.payBuy:Find("CoinNum"):GetComponent(Text).text = coinCost
        self.payBuy:Find("SecondIcon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Gem")     --获取宝石资源图标
        self.payBuy:Find("SecondNum"):GetComponent(Text).text = jewelCost
        self.buyType = "CoinAndJewel"
        local listener
        listener = NTGEventTriggerProxy.Get(self.payBuy:Find("Button").gameObject)
        local callback = function(self, e)
          GameManager.CreatePanel("BuyHero")
          if BuyHeroAPI ~= nil and BuyHeroAPI.Instance ~= nil then
            BuyHeroAPI.Instance:BuyHero(heroId,2)
          end
        end
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self) 
      elseif coinCost ~= -1 and jewelCost == -1 and ticketCost ~= -1 then
        self.payBuy.gameObject:SetActive(true)
        self.payBuy:Find("CoinNum"):GetComponent(Text).text = coinCost
        self.payBuy:Find("SecondIcon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Voucher")     --获取点券资源图标
        --self.payBuy:Find("SecondNum"):GetComponent(Text).text = ticketCost
        self.buyType = "CoinAndTicket"
        local listener
        listener = NTGEventTriggerProxy.Get(self.payBuy:Find("Button").gameObject)
        local callback = function(self, e)
          GameManager.CreatePanel("BuyHero")
          if BuyHeroAPI ~= nil and BuyHeroAPI.Instance ~= nil then
            BuyHeroAPI.Instance:BuyHero(heroId,3)
          end
        end
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self) 
      end





    else
      self.sendGet.gameObject:SetActive(true)
      --print("AAAAAAAAAAAAAA " .. Data.SourcesData[tostring(Data.RolesData[tostring(heroId)].SourceId)].Desc .. " " .. Data.RolesData[tostring(heroId)].SourceId)
      self.sendGet:Find("Text"):GetComponent(Text).text = Data.SourcesData[tostring(Data.RolesData[tostring(heroId)].SourceId)].Desc
    end
  else 
    self.needBuyPanel.gameObject:SetActive(false)
  end
  
  --英雄定位
  self.typeName:GetComponent(Text).text = Data.RolesData[tostring(heroId)].Position
  
  --英雄熟练度
  if self.IsOwn == 0 or self.IsOwn == 2 then
    self.proficiencyPanel.gameObject:SetActive(false)
  else
    self.proficiencyPanel.gameObject:SetActive(true)
    for k,v in pairs(Data.RolesDeck) do
      if v.RoleId == heroId then
        self.proficiencyIcon:GetComponent(Image).sprite = UITools.GetSprite("icon", "Ishuliandu-" .. Data.RoleProficiencysData[tostring(v.ProficiencyId)].Quality)
      end
    end
    for k,v in pairs(Data.RolesDeck) do
      if heroId == Data.RolesDeck[k].RoleId then
        self.proficiencyName:GetComponent(Text).text = Data.RoleProficiencysData[tostring(Data.RolesDeck[k].ProficiencyId)].Name
        self.currentProficiency:GetComponent(Text).text = Data.RolesDeck[k].ProficiencyValue
        self.maxProficiency:GetComponent(Text).text = Data.RoleProficiencysData[tostring(Data.RolesDeck[k].ProficiencyId)].NextExp
        break
      else
        self.proficiencyName:GetComponent(Text).text = ""
        self.currentProficiency:GetComponent(Text).text = 0
        self.maxProficiency:GetComponent(Text).text = 0
      end
    end
  end
  
  --英雄评级
  local rating = {}
  rating[1] = math.floor(Data.RolesData[tostring(heroId)].SurviveDesc/100 * 16)
  rating[2] = math.floor(Data.RolesData[tostring(heroId)].DamageDesc/100 * 16)
  rating[3] = math.floor(Data.RolesData[tostring(heroId)].SkillEffectDesc/100 * 16)
  rating[4] = math.floor(Data.RolesData[tostring(heroId)].DifficultyDesc/100 * 16)

  
  for i = 1,4 do
    for j = 1,(16 - rating[i]) do
      self.ratingZone:GetChild(i - 1):Find("RatingLight-image"):GetChild(j - 1).gameObject:SetActive(true)
    end
  end
  
  --技能图标显示
  for i = 1,4 do
    self.skillZone:GetChild(i - 1):Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("skillicon-" .. heroId,Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].Icon)
    self.skillZone:GetChild(i - 1).name = tostring(Data.RolesData[tostring(heroId)].Skills[i+1])
  end
  
  --技能Tips
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
        print(Data.SkillBehavioursData[tostring(Data.SkillsData[tostring(Data.RolesData[tostring(heroId)].Skills[i+1])].DescParam[1][1])].PAtkAdd)
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

  self.heroInfoPanel.gameObject:SetActive(true)
  --英雄皮肤
  self:GetSkinList(heroId)
  table.insert(self.coroutines,coroutine.start(HeroInfoController.Test,self))

  
  --英雄模型
--[[
  self.leftInfoPanel:Find("RawEvent").gameObject:SetActive(true)

  if lastSelectedModel ~= "" then
    NTGResourceController.Instance:UnloadAssetBundle(self.lastSelectedModel, true, false)
  end

  --tempo:Find("desk").transform.localRotation = Quaternion.identity
  for i=1,self.model:Find("desk/root").childCount do
    GameObject.Destroy(self.model:Find("desk/root"):GetChild(i-1).gameObject)
  end
  local assetbundle

  if Data.RolesDeckData[tostring(heroId)] ~= nil then
    assetbundle = NTGResourceController.Instance:LoadAsset("skin"..tostring(Data.SkinsData[tostring(Data.RolesDeckData[tostring(heroId)].Skin)].Resource),
                                                                        tostring(Data.SkinsData[tostring(Data.RolesDeckData[tostring(heroId)].Skin)].Resource) .. "-Show")
    self.lastSelectedModel = "skin"..tostring(Data.SkinsData[tostring(Data.RolesDeckData[tostring(heroId)].Skin)].Resource)
  else
    assetbundle = NTGResourceController.Instance:LoadAsset("skin"..tostring(Data.SkinsData[tostring(Data.RolesData[tostring(heroId)].Skin)].Resource),
                                                                        tostring(Data.SkinsData[tostring(Data.RolesData[tostring(heroId)].Skin)].Resource) .. "-Show")
    self.lastSelectedModel = "skin"..tostring(Data.SkinsData[tostring(Data.RolesData[tostring(heroId)].Skin)].Resource)
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
  ]]
  --temp

  --英雄体验倒计时
  for k,v in pairs(Data.RolesDeck) do
    if heroId == v.RoleId then
      if v.IsOwn == false then
          --print("该英雄在体验中")
          local leftTime = UTGData.Instance():GetLeftTime(v.ExperienceTime)
          if leftTime > 0 then 
            self.tryTime.gameObject:SetActive(true)
            self.heroTryTimeCoroutine = coroutine.start(self.GetPlayTime,self,leftTime)
          end
      end
    end
  end

  self.toLeft.gameObject:SetActive(true)
  self.toRight.gameObject:SetActive(true)
  --print("ssssssssssssss " .. #self.HeroList)
  for i = 1,#self.HeroList do
    --print("ddddddddddd " .. self.HeroList[i].Id)
    if self.HeroList[i].Id == heroId then
      if i == 1 then
        self.toLeft.gameObject:SetActive(false)
      elseif i == #self.HeroList then
        self.toRight.gameObject:SetActive(false)
      end
    end
  end

  if #self.HeroList == 1 or #self.HeroList == 0 then
    self.toLeft.gameObject:SetActive(false)
    self.toRight.gameObject:SetActive(false)
  end


  if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end

end

function HeroInfoController:CheckFxPlaying(duration,delay,fxTranform)
  -- body

end

function HeroInfoController:InitSkinList(heroId)
  local skinList = {}
  for k,v in pairs(Data.SkinsData) do
    if Data.SkinsData[k].RoleId == heroId then
      table.insert(skinList,Data.SkinsData[k])
    end
  end
  local temp = ""
  for i = 1,#skinList do
    for k = i+1,#skinList do
      if skinList[i].Id > skinList[k].Id then
        temp = skinList[i]
        skinList[i] = skinList[k]
        skinList[k] = temp
      end
    end
  end
  
  self.testList = skinList
  
  self.skinListPanel = self.rightInfoPanel:Find("Bottom/Panel/SkinList")
  self.skinListPanelSize = skinListPanel:GetComponent(RectTrans).sizeDelta
  self.skinListPanelCenter = skinListPanel:GetComponent(RectTrans).position
  local grid = self.rightInfoPanel:Find("Bottom/Panel/SkinList/Grid")
  local cPositionX = skinListPanel.localPosition.x / 2
  local element = self.rightInfoPanel:Find("Bottom/Panel/SkinList/Grid/Image")
  local elementSize = element:GetComponent(RectTrans).sizeDelta
  local elementSpace = 10
  grid:GetComponent(RectTrans).sizeDelta = Vector2.New(skinListPanelSize.x + (#skinList - 1) * elementSize.x + (#skinList - 1) * elementSpace,skinListPanelSize.y)
  

end


function HeroInfoController:GetHeroProperty(heroId,skinId)
  for i = 2,6 do
    self.this.transform:GetChild(i-1).gameObject:SetActive(false)
  end
  self.this.transform:GetChild(1).gameObject:SetActive(true)
  
  
  
  
  
  
  --基础属性  
  self.baseTextZone:Find("MaxHPTitle/MaxHP"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].HP + Data.SkinsData[tostring(skinId)].HP
  self.baseTextZone:Find("MaxMPTitle/MaxMP"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].MP + Data.SkinsData[tostring(skinId)].MP
  self.baseTextZone:Find("PAtkTitle/PAtk"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].PAtk + Data.SkinsData[tostring(skinId)].PAtk
  self.baseTextZone:Find("MAtkTitle/MAtk"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].MAtk + Data.SkinsData[tostring(skinId)].MAtk
  self.baseTextZone:Find("PDefTitle/PDef"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].PDef + Data.SkinsData[tostring(skinId)].PDef .. "|" .. self:GetDefRate(Data.RolesData[tostring(heroId)].PDef + Data.SkinsData[tostring(skinId)].PDef) .. "%"
  self.baseTextZone:Find("MDefTitle/MDef"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].MDef + Data.SkinsData[tostring(skinId)].MDef .. "|" .. self:GetDefRate(Data.RolesData[tostring(heroId)].MDef + Data.SkinsData[tostring(skinId)].MDef) .. "%"
  
  --攻击属性
  self.atkTextZone:Find("MoveSpeedTitle/MoveSpeed"):GetComponent(Text).text = math.floor((Data.RolesData[tostring(heroId)].MoveSpeed + Data.SkinsData[tostring(skinId)].MoveSpeed) * 121)
  self.atkTextZone:Find("PDefBreakTitle/PDefBreak"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].PpenetrateValue + Data.SkinsData[tostring(skinId)].PpenetrateValue .. "|" .. (Data.RolesData[tostring(heroId)].PpenetrateRate + Data.SkinsData[tostring(skinId)].PpenetrateRate)*100 .. "%"
  self.atkTextZone:Find("MDefBreakTitle/MDefBreak"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].MpenetrateValue + Data.SkinsData[tostring(skinId)].MpenetrateValue .. "|" .. (Data.RolesData[tostring(heroId)].MpenetrateRate + Data.SkinsData[tostring(skinId)].MpenetrateRate)*100 .. "%"
  self.atkTextZone:Find("ASpeedAddTitle/ASpeedAdd"):GetComponent(Text).text = math.floor((Data.RolesData[tostring(heroId)].AtkSpeed + Data.SkinsData[tostring(skinId)].AtkSpeed)*100) .. "%"
  self.atkTextZone:Find("CritPercentTitle/CritPercent"):GetComponent(Text).text = (Data.RolesData[tostring(heroId)].CritRate + Data.SkinsData[tostring(skinId)].CritRate)*100 .. "%"
  self.atkTextZone:Find("CritEffectTitle/CritEffect"):GetComponent(Text).text = (Data.RolesData[tostring(heroId)].CritEffect + Data.SkinsData[tostring(skinId)].CritEffect) * 100 .. "%"
  self.atkTextZone:Find("PStealLifeTitle/PStealLife"):GetComponent(Text).text = (Data.RolesData[tostring(heroId)].PHpSteal + Data.SkinsData[tostring(skinId)].PHpSteal) * 100 .. "%"
  self.atkTextZone:Find("MStealLifeTitle/MStealLife"):GetComponent(Text).text = (Data.RolesData[tostring(heroId)].MHpSteal + Data.SkinsData[tostring(skinId)].MHpSteal) * 100 .. "%"
  self.atkTextZone:Find("CDRTitle/CDR"):GetComponent(Text).text = (Data.RolesData[tostring(heroId)].CdReduce + Data.SkinsData[tostring(skinId)].CdReduce)*100 .. "%"
  if Data.RolesData[tostring(heroId)].AtkType == 1 then
    self.atkTextZone:Find("AtkRangeTitle/AtkRange"):GetComponent(Text).text = "近战"
  else
    self.atkTextZone:Find("AtkRangeTitle/AtkRange"):GetComponent(Text).text = "远程"
  end
  
  --防御属性
  self.defTextZone:Find("ToughTitle/Tough"):GetComponent(Text).text = (Data.RolesData[tostring(heroId)].Tough + Data.SkinsData[tostring(skinId)].Tough)*100 .. "%"
  self.defTextZone:Find("HpRecoverTitle/HpRecover"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].HpRecover5s + Data.SkinsData[tostring(skinId)].HpRecover5s
  self.defTextZone:Find("MpRecoverTitle/MpRecover"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].MpRecover5s + Data.SkinsData[tostring(skinId)].MpRecover5s
  
end

function HeroInfoController:GetHeroStory(heroId)
  for i = 2,6 do
    self.this.transform:GetChild(i-1).gameObject:SetActive(false)
  end
  self.this.transform:GetChild(2).gameObject:SetActive(true)
  self.heroStory:GetComponent(Text).text = Data.RolesData[tostring(heroId)].Story
end

function HeroInfoController:BuyHero(heroId)
  self.getNewType = "Hero"
  for i = 2,6 do
    self.this.transform:GetChild(i-1).gameObject:SetActive(false)
  end
  self.this.transform:GetChild(3).gameObject:SetActive(true)
  
  
  --初始化
  self.payCoinPanel.gameObject:SetActive(true)
  self.payCoinPanel.localPosition = Vector3.New(-8,87,0)
  self.payOtherWayPanel.localPosition = Vector3.New(-8,19,0)
  self.payCoinButton.gameObject:SetActive(true)
  self.payCoinButton.localPosition = Vector3.New(-2,-126,0)
  self.payOtherWayButton.localPosition = Vector3.New(285,-126,0)
  self.buyHeroPanel:Find("BuyHeroFrame/BuyInfo/Mask/HeroIcon"):GetComponent(Image).sprite = UITools.GetSprite("portrait", Data.SkinsData[tostring(Data.RolesData[tostring(heroId)].Skin)].Portrait) 
  self.buyHeroPanel:Find("BuyHeroFrame/BuyInfo/Mask/Image/Text"):GetComponent(Text).text = Data.RolesData[tostring(heroId)].Name
  if self.buyType == "OnlyTicket" then
    self.payCoinPanel.gameObject:SetActive(false)
    self.payOtherWayPanel.localPosition = Vector3.New(-8,77,0)
    self.payOtherWayIcon:GetComponent(Image).sprite = UITools.GetSprite("resourceicon", "Voucher")      --获取点卷Icon
    self.payOtherWayType:GetComponent(Text).text = "点券"
    self.payOtherWayNum:GetComponent(Text).text = Data.ShopsData[tostring(heroId)][1].VoucherPrice
    self.payCoinButton.gameObject:SetActive(false)
    self.payOtherWayButton.localPosition = Vector3.New(225,-57,0)
    self.payOtherWayButtonName:GetComponent(Text).text = "点券购买"
  elseif self.buyType == "CoinAndJewel" then
    self.coinNum:GetComponent(Text).text = Data.ShopsData[tostring(heroId)][1].CoinPrice
    self.payOtherWayIcon:GetComponent(Image).sprite = UITools.GetSprite("resourceicon", "Gem")     --获取宝石Icon
    self.payOtherWayType:GetComponent(Text).text = "宝石"
    self.payOtherWayNum:GetComponent(Text).text = Data.ShopsData[tostring(heroId)][1].GemPrice
    self.payOtherWayButtonName:GetComponent(Text).text = "宝石购买"
  elseif self.buyType == "CoinAndTicket" then
    self.coinNum:GetComponent(Text).text = Data.ShopsData[tostring(heroId)][1].CoinPrice
    self.payOtherWayIcon:GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Voucher")    --获取点券Icon
    self.payOtherWayType:GetComponent(Text).text = "点券"
    self.payOtherWayNum:GetComponent(Text).text = Data.ShopsData[tostring(heroId)][1].VoucherPrice
    self.payOtherWayButtonName:GetComponent(Text).text = "点券购买"
  end

  local listener = NTGEventTriggerProxy.Get(self.buyHeroPanel:Find("BuyHeroFrame/BuyInfo/PayCoinButton").gameObject)
  local callback13 = function(self, e)
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback13, self)

  listener = NTGEventTriggerProxy.Get(self.buyHeroPanel:Find("BuyHeroFrame/BuyInfo/PayOtherWayButton").gameObject)
  local callback13 = function(self, e)
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback13, self)


end
--[[
function HeroInfoController:GetNew(heroId,skinId)
  for i = 3,8 do
    self.this.transform:GetChild(i-1).gameObject:SetActive(false)
  end
  self.this.transform:GetChild(5).gameObject:SetActive(true)
  

  if self.getNewType == "Hero" then
    self.getNewTitle:GetComponent(Text).text = "恭喜你获得了新英雄"
    if heroId ~= nil then
      self.getNewName:GetComponent(Text).text = Data.RolesData[tostring(heroId)].Name
    end
  elseif self.getNewType == "Skin" then
    self.getNewTitle:GetComponent(Text).text = "恭喜你获得了新皮肤"
    if skinId ~= nil then
      self.getNewName:GetComponent(Text).text = Data.SkinsData[tostring(heroId)].Name
    end
  end
end
]]
function HeroInfoController:BuySkin(skinId)
  self.getNewType = "Skin"
  for i = 2,6 do
    self.this.transform:GetChild(i-1).gameObject:SetActive(false)
  end
  self.this.transform:GetChild(4).gameObject:SetActive(true)

  for i = 1,7 do 
    self.skinProperty[i].gameObject:SetActive(false)
  end
  self.skinIcon:GetComponent(Image).sprite = UITools.GetSprite("portrait", Data.SkinsData[tostring(skinId)].Portrait)   --获取皮肤头像
  self.payTicketNum:GetComponent(Text).text = Data.ShopsData[tostring(skinId)][1].VoucherPrice
  
  local skinsProperty = UTGDataOperator.Instance:GetSortedPropertiesByKey("Skin",skinId)
  for i = 1, #skinsProperty do
    self.skinProperty[i].gameObject:SetActive(true)
    self.skinProperty[i]:GetComponent(Text).text = skinsProperty[i].Des
    self.skinProperty[i]:Find("AddNum"):GetComponent(Text).text = "+ " .. skinsProperty[i].Attr
    self.skinAdd = skinsProperty[i]
  end
  
  if #skinsProperty == 0 then
    self.skinPropertyFrame.gameObject:SetActive(false)
  end

  local listener = NTGEventTriggerProxy.Get(self.buySkinPanel:Find("BuyHeroFrame/CancelButton").gameObject)
  local callback1 = function(self, e)
    self.buySkinPanel.gameObject:SetActive(false)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)

  listener = NTGEventTriggerProxy.Get(self.buySkinPanel:Find("BuyHeroFrame/BuyInfo/Button").gameObject)
  local callback13 = function(self, e)
    GameManager.CreatePanel("GiftSkin")
    GiftSkinAPI.Instance:InitGiftSkin(skinId)
    --[[
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    end
    ]]
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( callback13, self)

  listener = NTGEventTriggerProxy.Get(self.buySkinPanel:Find("BuyHeroFrame/BuyInfo/Button2").gameObject)
  local callback13 = function(self, e)
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback13, self)
end

function HeroInfoController:GiftSkin(skinId)

  --初始化界面
  local temp = self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/SearchFriend/FriendList/Grid")
  for i = 2,temp.childCount  do
    GameObject.Destroy(temp:GetChild(i-1).gameObject)
  end
  self.inputArea:GetComponent("UnityEngine.UI.InputField").text = ""

  self.buySkinPanel.gameObject:SetActive(false)
  self.giftSkinPanel.gameObject:SetActive(true)
  for i = 2,6 do
    if i ~= 6 then
      self.this.transform:GetChild(i-1).gameObject:SetActive(false)
    end
  end
  self.this.transform:GetChild(5).gameObject:SetActive(true)

  self.skinIcon1:GetComponent(Image).sprite = UITools.GetSprite("portrait",Data.SkinsData[tostring(skinId)].Portrait)   --获取皮肤头像
  if self.skinAdd ~= nil then
    self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/AttrTitle").gameObject:SetActive(true)
    self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/AttrAddNum").gameObject:SetActive(true)
    self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/AttrTitle"):GetComponent(Text).text = self.skinAdd.Des
    self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/AttrAddNum"):GetComponent(Text).text = "+ " .. self.skinAdd.Attr
    self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/AttrAddNum"):GetComponent(Text).color = Color.New(0,1,0,1)
  else
    self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/AttrTitle").gameObject:SetActive(false)
    self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/AttrAddNum").gameObject:SetActive(false)
  end
  self.ticketNum:GetComponent(Text).text = Data.ShopsData[tostring(skinId)][1].VoucherPrice

  local listener = NTGEventTriggerProxy.Get(self.giftSkinPanel:Find("BuyHeroFrame/CancelButton").gameObject)
  local callback13 = function(self, e)
    self.giftSkinPanel.gameObject:SetActive(false)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback13, self)

  listener = NTGEventTriggerProxy.Get(self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/SearchFriend/Button").gameObject)
  local callback1 = function(self, e)
    self:SearchFriend()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)

end

function HeroInfoController:SearchFriend()
  local keyWord = self.inputArea:GetComponent("UnityEngine.UI.InputField").text
  local resultList = {}
  for k,v in pairs(Data.FriendList) do
    if string.find(Data.FriendList[k].Name,keyWord) ~= nil then
      table.insert(resultList,Data.FriendList[k])
    end
  end
  if #resultList == 0 then
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("未能找到符合条件的好友")
    end
  end

  self:ShowSearchFriendResult(resultList)

end

function HeroInfoController:ShowSearchFriendResult(resultList)
  -- body
  local temp = self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/SearchFriend/FriendList/Grid/Friend1")
  for i = 1,#resultList do
    local go = GameObject.Instantiate(temp.gameObject)
      go:SetActive(true)
      go.transform.parent = self.giftSkinPanel:Find("BuyHeroFrame/BuyInfo/SearchFriend/FriendList/Grid")
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.zero
      go.transform:Find("Image"):GetComponent(Image).sprite = resultList[i].Avatar
      go.transform:Find("PlayerName"):GetComponent(Text).text = resultList[i].Name
      local listener = NTGEventTriggerProxy.Get(go.transform:Find("GiftButton").gameObject)
      local callback13 = function(self, e)
        --print("赠送成功")
      end
      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback13, self)
  end

end

function HeroInfoController:ToNextHero()

  GameManager.CreatePanel("Waiting")

  local nextHeroId = 0
  local nextSkinId = 0
  for i = 1,#self.HeroList do
    if self.HeroList[i].Id == self.HeroId then
      if i < #self.HeroList then
        nextHeroId = self.HeroList[i+1].Id
        if self.SkinList ~= nil then
          if self.SkinList[i+1] ~= nil then
            nextSkinId = self.SkinList[i+1].Id
          else
            nextSkinId = Data.RolesData[tostring(nextHeroId)].Skin
          end
        end
      end
    end
  end

  if self.fxPlay ~= "" then
    self.fxPlay.gameObject:SetActive(false)
    self.fxPlay = ""
  end

  if self.fxShow ~= "" then
    self.fxShow.gameObject:SetActive(false)
    self.fxShow = ""
  end
  
  for i = 1,#self.coroutines do
    coroutine.stop(self.coroutines[i])
  end
  coroutine.stop(self.heroTryTimeCoroutine)
  coroutine.stop(self.skinTryTimeCoroutine)
  self.coroutines = {}
  self:InitSelectHero(nextHeroId,self.HeroList)
  if self.SkinList ~= nil then
    --print("222222222222")
    self:DoInitCenterBySkinId(nextSkinId,self.SkinList)
  end

end

function HeroInfoController:ToLastHero()

  GameManager.CreatePanel("Waiting")

  local lastHeroId = 0
  local lastSkinId = 0
  for i = 1,#self.HeroList do
    if self.HeroList[i].Id == self.HeroId then
      if i > 1 then
        lastHeroId = self.HeroList[i-1].Id
        if self.SkinList ~= nil then
          if self.SkinList[i-1] ~= nil then
            lastSkinId = self.SkinList[i-1].Id
          else
            lastSkinId = Data.RolesData[tostring(lastSkinId)].Skin
          end
        end
      end
    end
  end
  if self.fxPlay ~= "" then
    self.fxPlay.gameObject:SetActive(false)
    self.fxPlay = ""
  end

  if self.fxShow ~= "" then
    self.fxShow.gameObject:SetActive(false)
    self.fxShow = ""
  end
  for i = 1,#self.coroutines do
    coroutine.stop(self.coroutines[i])
  end
  coroutine.stop(self.heroTryTimeCoroutine)
  coroutine.stop(self.skinTryTimeCoroutine)
  self.coroutines = {}
  self:InitSelectHero(lastHeroId,self.HeroList)
  if self.SkinList ~= nil then
    --print("3333333333333")
    self:DoInitCenterBySkinId(lastSkinId,self.SkinList)
  end
end

function HeroInfoController:GetSkinList(roleId)
  local skinList = {}
  self.haveButton = {}
  local count = 0
  for k,v in pairs(Data.SkinsData) do
    if Data.SkinsData[k].RoleId == roleId then
      count = count + 1
      table.insert(skinList,Data.SkinsData[k])
    end
  end
  self.orderCount = count
  table.sort(skinList,function(a,b) return a.Id < b.Id end)
  self.orderSkinList = skinList
  
  local list = self.skinList:GetComponent("NTGLuaScript")
  list.self:ResetItemsSimple(count)
  self.orderList = list
  for i = 1,count do
    list.self.itemList[i].transform.name = skinList[i].Id
    list.self.itemList[i].transform:Find("IconMask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("portrait",skinList[i].Portrait)     --获取人物皮肤Icon
    list.self.itemList[i].transform:Find("SkinName"):GetComponent(Text).text = Data.RolesData[tostring(roleId)].Name
    list.self.itemList[i].transform:Find("SkinName/Text"):GetComponent(Text).text = skinList[i].Name
    --判断皮肤等级
    if skinList[i].tag ~= nil then
      --list.self.itemList[i].transform:Find("SkinTag"):GetComponent(Image).sprite = UITools.GetSprite("Icon",XXX)   --以后填写
    else
      list.self.itemList[i].transform:Find("SkinTag").gameObject:SetActive(false)
    end
    if self.IsOwn == 0 or self.IsOwn == 2 then    --未获取英雄
      --print("未获取英雄未获取英雄未获取英雄未获取英雄")
      if skinList[i].Id == Data.RolesData[tostring(roleId)].Skin or Data.SkinsDeckData[tostring(skinList[i].Id)] ~= nil then   --拥有皮肤
        --print("未获取英雄 拥有皮肤")
        if skinList[i].Id == Data.RolesData[tostring(roleId)].Skin then
          list.self.itemList[i].transform:Find("Button").gameObject:SetActive(false)
          list.self.itemList[i].transform:Find("SkinName").localPosition = Vector3.New(-33.2,-57.84,0)
          --list.self.itemList[i].transform:Find("SkinName"):GetComponent(Text).text = Data.RolesData[tostring(roleId)].Name .. " " .. skinList[i].Name
          list.self.itemList[i].transform:Find("Text"):GetComponent(Text).text = "已穿戴"
          list.self.itemList[i].transform:Find("BlackFrame/NeedBuy").gameObject:SetActive(false)
          list.self.itemList[i].transform:Find("BlackFrame/CanTry").gameObject:SetActive(false)
          list.self.itemList[i].transform:Find("TopFrame").gameObject:SetActive(false)
        else
          list.self.itemList[i].transform:Find("Button/Text"):GetComponent(Text).text = "穿戴"
          list.self.itemList[i].transform:Find("SkinName").localPosition = Vector3.New(-33.2,-57.84,0)
          table.insert(self.haveButton,list.self.itemList[i].transform)
          local callback1 = function()
            self:ChangeSkin(Data.SkinsData[tostring(skinList[i].Id)].RoleId,skinList[i].Id)
          end
          local uiClick=UITools.GetLuaScript(list.self.itemList[i].transform:Find("Button").gameObject,"Logic.UICommon.UIClick")  
          uiClick:RegisterClickDelegate(self,callback1)
          --list.self.itemList[i].transform:Find("SkinName"):GetComponent(Text).text = Data.RolesData[tostring(roleId)].Name .. " " .. skinList[i].Name
          if self.isCenter == list.self.itemList[i].transform then     --在中心
            --print("拥有皮肤拥有皮肤拥有皮肤 在中心")
            list.self.itemList[i].transform:Find("Button").gameObject:SetActive(true)
            list.self.itemList[i].transform:Find("Text").gameObject:SetActive(false)
            list.self.itemList[i].transform:Find("Button/Text"):GetComponent(Text).text = "穿戴"   
          else
            --print("拥有皮肤拥有皮肤拥有皮肤 不在中心")
            list.self.itemList[i].transform:Find("Button").gameObject:SetActive(false)
            list.self.itemList[i].transform:Find("Text").gameObject:SetActive(true)
            list.self.itemList[i].transform:Find("Text"):GetComponent(Text).text = "已拥有"              
          end  
        end        
      else      --未拥有皮肤
        --print("未获取英雄 未拥有皮肤")
        if skinList[i].ForSale == true then     --可购买皮肤
          --print("未获取英雄  可购买皮肤")
          list.self.itemList[i].transform:Find("Button").gameObject:SetActive(false)
          list.self.itemList[i].transform:Find("SkinName").localPosition = Vector3.New(-33.2,-32.7,0)
          list.self.itemList[i].transform:Find("BlackFrame/NeedBuy").gameObject:SetActive(true)
          list.self.itemList[i].transform:Find("BlackFrame/CanTry").gameObject:SetActive(false)
          if Data.ShopsData[tostring(skinList[i].Id)][1].Discountable == false then     --无打折
            --print("未获取英雄  可购买皮肤  无打折")
            list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel").localPosition = Vector3.New(0,list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel").localPosition.y,0)
            list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/PrePrice").gameObject:SetActive(false)
            list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel/Num"):GetComponent(Text).text = Data.ShopsData[tostring(skinList[i].Id)][1].VoucherPrice
          else      --有打折
            --print("未获取英雄  可购买皮肤  有打折")
            list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel").localPosition = Vector3.New(-26.3,list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel").localPosition.y,0)
            list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/PrePrice").gameObject:SetActive(true)
            list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel/Num"):GetComponent(Text).text = Data.ShopsData[tostring(skinList[i].Id)][1].VoucherPrice
            list.self.itemList[i].transform:Find("BlackFrame/PrePrice/Num"):GetComponent(Text).text = Data.ShopsData[tostring(skinList[i].Id)][1].RawVoucherPrice
          end
        else
            list.self.itemList[i].transform:Find("SkinName").localPosition = Vector3.New(-33.2,-57.84,0)
            list.self.itemList[i].transform:Find("Text").gameObject:SetActive(true)
            list.self.itemList[i].transform:Find("Text"):GetComponent(Text).text = Data.SourcesData[tostring(skinList[i].SourceId)].Desc
            list.self.itemList[i].transform:Find("BlackFrame/NeedBuy").gameObject:SetActive(false)
            list.self.itemList[i].transform:Find("Button").gameObject:SetActive(false)           
        end
        list.self.itemList[i].transform:Find("SkinName").localPosition = Vector3.New(-33.2,-57.84,0)
        list.self.itemList[i].transform:Find("BlackFrame/NeedBuy").gameObject:SetActive(false)
        list.self.itemList[i].transform:Find("BlackFrame/CanTry").gameObject:SetActive(false)
        list.self.itemList[i].transform:Find("Text"):GetComponent(Text).text = "需先获取英雄"
        list.self.itemList[i].transform:Find("Button").gameObject:SetActive(false)
      end
    else    --拥有英雄
      --print("有英雄有英雄有英雄")

        if Data.RolesDeckData[tostring(roleId)].Skin == skinList[i].Id or Data.SkinsDeckData[tostring(skinList[i].Id)] ~= nil then     --该皮肤当前穿戴
          --print("拥有皮肤 该皮肤当前穿戴")
          if Data.RolesDeckData[tostring(roleId)].Skin == skinList[i].Id then
            list.self.itemList[i].transform:Find("Button").gameObject:SetActive(false)
            list.self.itemList[i].transform:Find("SkinName").localPosition = Vector3.New(-33.2,-57.84,0)
            --list.self.itemList[i].transform:Find("SkinName"):GetComponent(Text).text = Data.RolesData[tostring(roleId)].Name .. " " .. skinList[i].Name
            list.self.itemList[i].transform:Find("Text"):GetComponent(Text).text = "已穿戴"
            list.self.itemList[i].transform:Find("BlackFrame/NeedBuy").gameObject:SetActive(false)
            list.self.itemList[i].transform:Find("BlackFrame/CanTry").gameObject:SetActive(false)
            list.self.itemList[i].transform:Find("TopFrame").gameObject:SetActive(false)
          else
            list.self.itemList[i].transform:Find("Button/Text"):GetComponent(Text).text = "穿戴"
            list.self.itemList[i].transform:Find("SkinName").localPosition = Vector3.New(-33.2,-57.84,0)
            list.self.itemList[i].transform:Find("BlackFrame/NeedBuy").gameObject:SetActive(false)
            table.insert(self.haveButton,list.self.itemList[i].transform)
            local callback1 = function()
              self:ChangeSkin(Data.SkinsData[tostring(skinList[i].Id)].RoleId,skinList[i].Id)
            end
            local uiClick=UITools.GetLuaScript(list.self.itemList[i].transform:Find("Button").gameObject,"Logic.UICommon.UIClick")  
            uiClick:RegisterClickDelegate(self,callback1)
            --list.self.itemList[i].transform:Find("SkinName"):GetComponent(Text).text = Data.RolesData[tostring(roleId)].Name .. " " .. skinList[i].Name
            if self.isCenter == list.self.itemList[i].transform then     --在中心
              --print("拥有皮肤拥有皮肤拥有皮肤 在中心")
              list.self.itemList[i].transform:Find("Button").gameObject:SetActive(true)
              list.self.itemList[i].transform:Find("Text").gameObject:SetActive(false)
              list.self.itemList[i].transform:Find("Button/Text"):GetComponent(Text).text = "穿戴"   
            else
              --print("拥有皮肤拥有皮肤拥有皮肤 不在中心")
              list.self.itemList[i].transform:Find("Button").gameObject:SetActive(false)
              list.self.itemList[i].transform:Find("Text").gameObject:SetActive(true)
              list.self.itemList[i].transform:Find("Text"):GetComponent(Text).text = "已拥有"              
            end
           
          end
        else    --该皮肤跟穿戴皮肤不同
          --print("该皮肤跟穿戴皮肤不同")
            if Data.SkinsDeckData[tostring(skinList[i])] ~= nil or skinList[i].Id == Data.RolesData[tostring(skinList[i].RoleId)].Skin then     --拥有皮肤
              --print("拥有皮肤拥有皮肤拥有皮肤")
              list.self.itemList[i].transform:Find("BlackFrame/NeedBuy").gameObject:SetActive(false)
              local callback1 = function()
                self:ChangeSkin(Data.SkinsData[tostring(skinList[i].Id)].RoleId,skinList[i].Id)
              end
              local uiClick=UITools.GetLuaScript(list.self.itemList[i].transform:Find("Button").gameObject,"Logic.UICommon.UIClick")  
              uiClick:RegisterClickDelegate(self,callback1)
              if self.isCenter == list.self.itemList[i].transform then     --在中心
                --print("拥有皮肤拥有皮肤拥有皮肤 在中心")
                list.self.itemList[i].transform:Find("Button").gameObject:SetActive(true)
                list.self.itemList[i].transform:Find("Text").gameObject:SetActive(false)
                list.self.itemList[i].transform:Find("Button/Text"):GetComponent(Text).text = "穿戴"           
              else
                --print("拥有皮肤拥有皮肤拥有皮肤 不在中心")
                list.self.itemList[i].transform:Find("Button").gameObject:SetActive(false)
                list.self.itemList[i].transform:Find("Text").gameObject:SetActive(true)
                list.self.itemList[i].transform:Find("Text"):GetComponent(Text).text = "已拥有"              
              end
 

              table.insert(self.haveButton,list.self.itemList[i].transform)
              list.self.itemList[i].transform:Find("SkinName").localPosition = Vector3.New(-33.2,-57.84,0)
              --list.self.itemList[i].transform:Find("SkinName").GetComponent(Text).text = string.format("%s %s",Data.RolesData[tostring(roleId)].Name,Data,skinList[i].Name)
            else
              --print("未拥有皮肤")
              if self.isCenter == list.self.itemList[i].transform then
                --print("未拥有皮肤 在中心")
                list.self.itemList[i].transform:Find("Button").gameObject:SetActive(true)
                list.self.itemList[i].transform:Find("Text").gameObject:SetActive(false)
                list.self.itemList[i].transform:Find("Button/Text"):GetComponent(Text).text = "穿戴"      --临时
              else
                list.self.itemList[i].transform:Find("Button").gameObject:SetActive(false)
                list.self.itemList[i].transform:Find("Text").gameObject:SetActive(false)             
              end
              if skinList[i].ForSale == true then   --是否可购买
                --print("未拥有皮肤 可购买")
                table.insert(self.haveButton,list.self.itemList[i].transform)
                list.self.itemList[i].transform:Find("Button").gameObject:SetActive(false)
                list.self.itemList[i].transform:Find("Button/Text"):GetComponent(Text).text = "购买"
                list.self.itemList[i].transform:Find("Text").gameObject:SetActive(true)
                list.self.itemList[i].transform:Find("Text"):GetComponent(Text).text = "可购买"
                list.self.itemList[i].transform:Find("SkinName").localPosition = Vector3.New(-33.2,-32.7,0)
                if Data.ShopsData[tostring(skinList[i].Id)][1].Discountable == false then     --无打折
                  --print("未拥有皮肤 可购买 无打折")
                  list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel").localPosition = Vector3.New(0,list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel").localPosition.y,0)
                  list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/PrePrice").gameObject:SetActive(false)
                  list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel/Num"):GetComponent(Text).text = Data.ShopsData[tostring(skinList[i].Id)][1].VoucherPrice
                  list.self.itemList[i].transform:Find("BlackFrame/NeedBuy").gameObject:SetActive(true)
                else      --有打折
                  --print("未拥有皮肤 可购买 有打折")
                  list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel").localPosition = Vector3.New(-23,list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel").localPosition.y,0)
                  list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/PrePrice").gameObject:SetActive(true)
                  list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/Panel/Num"):GetComponent(Text).text = Data.ShopsData[tostring(skinList[i].Id)][1].VoucherPrice
                  list.self.itemList[i].transform:Find("BlackFrame/NeedBuy/PrePrice/Num"):GetComponent(Text).text = Data.ShopsData[tostring(skinList[i].Id)][1].RawVoucherPrice
                  list.self.itemList[i].transform:Find("BlackFrame/NeedBuy").gameObject:SetActive(true)
                end

                local listener = NTGEventTriggerProxy.Get(list.self.itemList[i].transform:Find("Button").gameObject)
                local callback13 = function(self, e)
                  --self:BuySkin(skinList[i].Id)
                  GameManager.CreatePanel("BuySkin")
                  if BuySkinAPI ~= nil and BuySkinAPI.Instance ~= nil then
                    BuySkinAPI.Instance:Init(skinList[i].Id)
                    BuySkinAPI.Instance:ConfirmButtonChose(0)
                  end
                end
                listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback13, self)               
              else      --活动赠送
                --print("未拥有皮肤 不可购买 赠送")
                list.self.itemList[i].transform:Find("SkinName").localPosition = Vector3.New(-33.2,-57.84,0)
                list.self.itemList[i].transform:Find("Text").gameObject:SetActive(true)
                list.self.itemList[i].transform:Find("Text"):GetComponent(Text).text = Data.SourcesData[tostring(skinList[i].SourceId)].Desc
                list.self.itemList[i].transform:Find("BlackFrame/NeedBuy").gameObject:SetActive(false)
                list.self.itemList[i].transform:Find("Button").gameObject:SetActive(false)
              end
            end
        end
    end
    if self.isCenter == list.self.itemList[i].transform then
      if skinList[i].Feature ~= nil then
        self.rightTop:Find("Panel").gameObject:SetActive(false)
        self.feature.gameObject:SetActive(true)
      else
        self.rightTop:Find("Panel").gameObject:SetActive(true)
        self.feature.gameObject:SetActive(false)        
      end
    end

    local callback1 = function()
      self:ClickGoToCenter(list.self.itemList[i].transform)
      --self:GoToCenter()
      --self:SelectSkinGetModel(skinList[i].Id)
      --print("UIClickUIClickUIClickUIClick")
    end
    --print("list.self.itemList[i].transform:Find" .. list.self.itemList[i].transform:Find("IconFrame").name)
    local uiClick=UITools.GetLuaScript(list.self.itemList[i].transform:Find("IconFrame").gameObject,"Logic.UICommon.UIClick")  
    uiClick:RegisterClickDelegate(self,callback1)    


    local listener = NTGEventTriggerProxy.Get(list.self.itemList[i].transform:Find("IconFrame").gameObject)
    local callbackClick = function(self, e)
      --print("onPointUponPointUponPointUponPointUp")
      self:GoToCenter()

      --self:SelectSkinGetModel(skinList[i].Id)
    end
    listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackClick, self)    



  end


  if self.cor ~= nil then
    coroutine.stop(self.cor)
  end

  self.cor = nil

  self.cor = coroutine.start(HeroInfoController.WaitForList,self,list.self.itemList,roleId)
  table.insert(self.coroutines,self.cor)
end

function HeroInfoController:SelectSkinGetModel()
  -- body
  --print("self.isCenter.name " .. self.isCenter.name)
  local skinId = tonumber(self.isCenter.name)
  self.selectedSkinId = skinId
  --print("trycountDown " .. self.isCenter.name .. " " .. self.isCenter:Find("TopFrame/TryCountDown").name)

  for k,v in pairs(Data.SkinsDeck) do
    if v.SkinId == skinId then
      if v.IsOwn == false then
        local leftTime = Data:GetLeftTime(v.ExperienceTime)
        if leftTime > 0 then
          self.isCenter:Find("TopFrame").gameObject:SetActive(true)
          if self.skinTryTimeCoroutine ~= nil then
            coroutine.stop(self.skinTryTimeCoroutine)
            self.skinTryTimeCoroutine = coroutine.start(self.GetSkinPlayTime,self,leftTime,self.isCenter:Find("TopFrame/TryCountDown"))
          else
            self.skinTryTimeCoroutine = coroutine.start(self.GetSkinPlayTime,self,leftTime,self.isCenter:Find("TopFrame/TryCountDown"))
          end                      
        end
      end
    end
  end
     



  self.isModelOrPainting = "Model"

  --更改皮肤名称
  self.heroSkinName:GetComponent(Text).text = Data.SkinsData[tostring(skinId)].Name



  self.leftInfoPanel:Find("RawEvent").gameObject:SetActive(true)

  if self.lastSelectedModel ~= "" then
    NTGResourceController.Instance:UnloadAssetBundle(self.lastSelectedModel, true, false)
  end

  --tempo:Find("desk").transform.localRotation = Quaternion.identity
  for i=1,self.model:Find("desk/root").childCount do
    GameObject.Destroy(self.model:Find("desk/root"):GetChild(i-1).gameObject)
  end
  local assetbundle

  assetbundle = NTGResourceController.Instance:LoadAsset("skin"..tostring(Data.SkinsData[tostring(skinId)].Resource),
                                                                        tostring(Data.SkinsData[tostring(skinId)].Resource) .. "-Show")
  self.lastSelectedModel = "skin"..tostring(Data.SkinsData[tostring(skinId)].Resource)

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
  self.rolePainting:GetComponent(Image).sprite = UITools.GetSprite("rolepainting-"..self.HeroId,"post"..skinId)



end

function HeroInfoController:Test()
  local childList = self.rightInfoPanel:Find("Bottom/Panel/Panel")
  while (true) do
    for i = 1,childList.childCount do
      if childList:GetChild(i-1).position.x > self.ll.position.x and childList:GetChild(i-1).position.x < self.rr.position.x then
        local per = (1 - math.abs(childList:GetChild(i-1).position.x - self.mm.position.x) / math.abs(self.ll.position.x - self.mm.position.x)) * 0.47
        childList:GetChild(i-1).localScale = Vector3.New((1+per) * self.scale.x,(1+per) * self.scale.y,1)
        --childList:GetChild(i-1):Find("Text"):GetComponent(RectTrans).localScale = Vector3.New(1,1,1)
        --childList:GetChild(i-1):Find("Text"):GetComponent(Text).fontSize = 20 * (1+per)
      else
        childList:GetChild(i-1).localScale = Vector3.New(self.scale.x,self.scale.y,1)
      end
    end
    coroutine.wait(0.05)
  end
end

function HeroInfoController:GoToCenter()
  local childList = self.rightInfoPanel:Find("Bottom/Panel/Panel")
  local toCenter = ""
  local temp = math.abs(self.ll.position.x - self.mm.position.x)
  self.isCenter = ""
  for i = 2,childList.childCount do
    if i == 2 then
      temp = math.abs(childList:GetChild(i-1).position.x - self.mm.position.x)
      toCenter = childList:GetChild(i-1)
    end
    
    if math.abs(childList:GetChild(i-1).position.x - self.mm.position.x) < temp then
      toCenter = childList:GetChild(i-1)
      temp = math.abs(childList:GetChild(i-1).position.x - self.mm.position.x)
    end
  end
  self.isCenter = toCenter
  if (toCenter.position.x - self.mm.position.x) < 0 then
    childList.position = Vector3.New(childList.position.x + (math.abs(toCenter.position.x - self.mm.position.x)),childList.position.y,childList.position.z)
  else
    childList.position = Vector3.New(childList.position.x - (math.abs(toCenter.position.x - self.mm.position.x)),childList.position.y,childList.position.z)
  end

  for i = 1,#self.haveButton do
    if self.haveButton[i] == toCenter then
      self.haveButton[i]:Find("Button").gameObject:SetActive(true)
      self.haveButton[i]:Find("Text").gameObject:SetActive(false)
    else
      self.haveButton[i]:Find("Button").gameObject:SetActive(false)
      self.haveButton[i]:Find("Text").gameObject:SetActive(true)
    end
  end


  self:SelectSkinGetModel()

end

function HeroInfoController:ClickGoToCenter(trans)
  local childList = self.rightInfoPanel:Find("Bottom/Panel/Panel")
  local toCenter = ""
  local temp = math.abs(self.ll.position.x - self.mm.position.x)
  self.isCenter = ""
  toCenter = trans
  self.isCenter = toCenter
  if (toCenter.position.x - self.mm.position.x) < 0 then
    tarPos = Vector3.New(childList.position.x + (math.abs(toCenter.position.x - self.mm.position.x)),childList.position.y,childList.position.z)
    coroutine.start(HeroInfoController.MoveAnimation,self,childList,tarPos,true)
  else
    tarPos = Vector3.New(childList.position.x - (math.abs(toCenter.position.x - self.mm.position.x)),childList.position.y,childList.position.z)
    coroutine.start(HeroInfoController.MoveAnimation,self,childList,tarPos,false)
  end
  for i = 1,#self.haveButton do
    if self.haveButton[i] == toCenter then
      self.haveButton[i]:Find("Button").gameObject:SetActive(true)
      self.haveButton[i]:Find("Text").gameObject:SetActive(false)
    else
      self.haveButton[i]:Find("Button").gameObject:SetActive(false)
      self.haveButton[i]:Find("Text").gameObject:SetActive(true)
    end
  end

  self:SelectSkinGetModel()

end

function HeroInfoController:MoveAnimation(trans,targetPos,toLeft)
  -- body
  local dis = math.abs(trans.position.x - targetPos.x) / 10
  local count = 0

  while count < 10 do
    if toLeft == true then
      trans.position = Vector3.New(trans.position.x + dis,trans.position.y,trans.position.z)
    else
      trans.position = Vector3.New(trans.position.x - dis,trans.position.y,trans.position.z)
    end
    count = count + 1
    coroutine.wait(0.01)
  end 
end

function HeroInfoController:InitCenter(roleId)
  --print("asdfasdfasd " .. roleId)
  local childList = self.rightInfoPanel:Find("Bottom/Panel/Panel")
  for i = 1,childList.childCount do
    if self.IsOwn == 0 or self.IsOwn == 2 then
        if tostring(Data.RolesData[tostring(roleId)].Skin) == childList:GetChild(i - 1).name then
          if (childList:GetChild(i - 1).position.x - self.mm.position.x) < 0 then
            childList.position = Vector3.New(childList.position.x + (math.abs(childList:GetChild(i - 1).position.x - self.mm.position.x)),childList.position.y,childList.position.z)
          else
            childList.position = Vector3.New(childList.position.x - (math.abs(childList:GetChild(i - 1).position.x - self.mm.position.x)),childList.position.y,childList.position.z)
          end
        end
    else
      for k,v in pairs(Data.RolesDeckData) do
        if tostring(v.Skin) == childList:GetChild(i - 1).name then
          if (childList:GetChild(i - 1).position.x - self.mm.position.x) < 0 then
            childList.position = Vector3.New(childList.position.x + (math.abs(childList:GetChild(i - 1).position.x - self.mm.position.x)),childList.position.y,childList.position.z)
          else
            childList.position = Vector3.New(childList.position.x - (math.abs(childList:GetChild(i - 1).position.x - self.mm.position.x)),childList.position.y,childList.position.z)
          end      
        end
      end     
    end
  end
end

function HeroInfoController:DoInitCenterBySkinId(skinId,skinList)
  -- body
  if self.coroutineInitSkin == nil then
    self.coroutineInitSkin = coroutine.start(self.InitCenterBySkinId,self,skinId,skinList)
  else
    coroutine.stop(self.coroutineInitSkin)
    self.coroutineInitSkin = coroutine.start(self.InitCenterBySkinId,self,skinId,skinList)
  end
end

function HeroInfoController:InitCenterBySkinId(skinId,skinList)

  coroutine.wait(0.1)

  self.SkinList = skinList
  self.CurrentSkinId = skinId
  self.selectedSkinId = skinId

  local trans = ""
  local childList = self.rightInfoPanel:Find("Bottom/Panel/Panel")
  for i = 1,childList.childCount do
    if tostring(skinId) == childList:GetChild(i - 1).name then
      trans = childList:GetChild(i - 1):Find("TopFrame/TryCountDown")
      if (childList:GetChild(i - 1).position.x - self.mm.position.x) < 0 then
        childList.position = Vector3.New(childList.position.x + (math.abs(childList:GetChild(i - 1).position.x - self.mm.position.x)),childList.position.y,childList.position.z)
      else
        childList.position = Vector3.New(childList.position.x - (math.abs(childList:GetChild(i - 1).position.x - self.mm.position.x)),childList.position.y,childList.position.z)
      end      
    end
  end

  for k,v in pairs(Data.SkinsDeck) do
    if v.SkinId == skinId then
      if v.IsOwn == false then
        local leftTime = Data:GetLeftTime(v.ExperienceTime)
        if leftTime > 0 then
          if self.skinTryTimeCoroutine ~= nil then
            trans.parent.gameObject:SetActive(true)
            coroutine.stop(self.skinTryTimeCoroutine)
            self.skinTryTimeCoroutine = coroutine.start(self.GetSkinPlayTime,self,leftTime,trans)
          else
            self.skinTryTimeCoroutine = coroutine.start(self.GetSkinPlayTime,self,leftTime,trans)
          end                      
        end
      end
    end
  end

  self.leftInfoPanel:Find("RawEvent").gameObject:SetActive(true)

  if self.lastSelectedModel ~= "" then
    NTGResourceController.Instance:UnloadAssetBundle(self.lastSelectedModel, true, false)
  end

  --tempo:Find("desk").transform.localRotation = Quaternion.identity
  for i=1,self.model:Find("desk/root").childCount do
    GameObject.Destroy(self.model:Find("desk/root"):GetChild(i-1).gameObject)
  end
  local assetbundle

  assetbundle = NTGResourceController.Instance:LoadAsset("skin"..tostring(Data.SkinsData[tostring(skinId)].Resource),
                                                                        tostring(Data.SkinsData[tostring(skinId)].Resource) .. "-Show")
  self.lastSelectedModel = "skin"..tostring(Data.SkinsData[tostring(skinId)].Resource)

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
  self.model:Find("Plane/Plane").gameObject:SetActive(true)
  end

  self.rolePainting:GetComponent(Image).sprite = UITools.GetSprite("rolepainting-"..self.HeroId,"post"..skinId)

--[[
  if self.isModelOrPainting == "Model" then
    self.model.gameObject:SetActive(true)
    self.changeButton:Find("Text"):GetComponent(Text).text = "切换原画"
    self.rolePainting.gameObject:SetActive(false)
  end 
]]
end

function HeroInfoController:WaitForList(list,roleId)
  while (true) do
    for i = 1,#list do
      if (list[i].transform.position.x - self.mm.position.x) ~= 0 then
        self:InitCenter(roleId)
        return
      end
    end
    coroutine.wait(0.05)
  end
end



function HeroInfoController:ClosePanel(winNum)
  if winNum == "Property" then
    self.propertyPanel.gameObject:SetActive(false)
  elseif winNum == "Story" then
    self.storyPanel.gameObject:SetActive(false)
  elseif winNum == "BuyHero" then
    self.buyHeroPanel.gameObject:SetActive(false)
  elseif winNum == "GetNew" then
    self.getNewPanel.gameObject:SetActive(false)
  elseif winNum == "BuySkin" then
    self.buySkinPanel.gameObject:SetActive(false)
  elseif winNum == "giftSkin" then
    self.giftSkinPanel.gameObject:SetActive(false)
  end
end

function HeroInfoController:GoToEquipPanel(name,fun,funself)
  coroutine.start(HeroInfoController.GoToCor,self,name,fun,funself) 
end

function HeroInfoController:GoToCor(name,fun,funself)
  local result = GameManager.CreatePanelAsync(name)
  while result.Done ~= true do
    coroutine.wait(0.05)
  end

  if fun ~= nil and funself ~= nil then
    fun(funself)
  end

end

function  HeroInfoController:InitTop()
  -- body
  if NormalResourceAPI ~= nil then
    if NormalResourceAPI.Instance ~= nil then
      NormalResourceAPI.Instance:GoToPosition("HeroInfoPanel")
      NormalResourceAPI.Instance:ShowControl(3)
      NormalResourceAPI.Instance:InitTop(self,HeroInfoController.DestroySelf,nil,nil,"姬神详情")
      NormalResourceAPI.Instance:InitResource()
    end
  end
end

function HeroInfoController:DoInitTop()
    --加载顶部条
  self:GoToEquipPanel("NormalResource",HeroInfoController.InitTop,self)
end

function HeroInfoController:DragCube()
 coroutine.start(HeroInfoController.DragMov,self)
end

function HeroInfoController:DragMov()

  local startpos = Input.mousePosition
  --print(startpos)
  local offet = {}
  local isClick = true
  while Input.GetMouseButton(0) do  
    coroutine.step() 
    --coroutine.yield(WaitForSeconds.New(0.05))
    offet = (Input.mousePosition-startpos).x
    if math.abs(offet) > 0.1 then isClick = false end
    startpos = Input.mousePosition
    self.model:Find("desk").localEulerAngles = self.model:Find("desk").localEulerAngles + Vector3.New(0,-self.cubespeed*offet,0)
  end
  if isClick then
    self:SetModelPlayerAnimator()
  end
end

function HeroInfoController:SetModelPlayerAnimator()
  
  if self.fxShow ~= "" then
    self.fxShow.gameObject:SetActive(false)
  end
  --self.modelAnimator:Stop()
  --self.modelAnimator:Play()
  self.modelAnimator:SetTrigger("play")
  

  if self.fxPlay ~= "" then
    local fx = self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
    local renderer = self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))

    for k = 0,renderer.Length - 1 do
      self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(renderer[k].material.shader.name)
    end

    for k = 0,fx.Length - 1 do
      --fx[k]:Stop()
      fx[k]:Play()
    end
  end
end









--****************test
function HeroInfoController:GoToEquipPanel1()
  coroutine.start(HeroInfoController.GoToCor1,self) 
end

function HeroInfoController:GoToCor1()
  local result = GameManager.CreatePanelAsync("PreviewEquip")
  while result.Done ~= true do
    coroutine.wait(0.05)
  end

  if PreviewEquipAPI ~= nil and PreviewEquipAPI.Instance ~= nil then
    PreviewEquipAPI.Instance:Initialize(self.HeroId)
  end
end




function HeroInfoController:GetPlayTime(time)
  -- body
  while time > 0 do
    local str = ""
    if time/3600 >24 then math.floor((time%(3600*24))/3600)
      str = string.format("<color=#FFED00FF>%d</color>天<color=#FFED00FF>%d</color>时",math.floor(time/(3600*24)),math.floor((time%(3600*24))/3600))
      self.tryTime:Find("TryCountDown"):GetComponent("UnityEngine.UI.Text").text = str
    else
      local hour = 0
      local min =0
      local sec = 0
      hour = math.floor(time/3600)
      min = math.floor((time%3600)/60)
      sec = math.floor((time%3600)%60)
      str = string.format("<color=#FFED00FF>%02d:%02d:%02d</color>",hour,min,sec)
      self.tryTime:Find("TryCountDown"):GetComponent("UnityEngine.UI.Text").text = str
    end
    coroutine.wait(1)
    time = time-1    
  end
  self.tryTime.gameObject:SetActive(false)
end

function HeroInfoController:GetSkinPlayTime(time,countTime)
  -- body
  while time > 0 do
    local str = ""
    if time/3600 >24 then math.floor((time%(3600*24))/3600)
      str = string.format("<color=#FFED00FF>%d</color>天<color=#FFED00FF>%d</color>时",math.floor(time/(3600*24)),math.floor((time%(3600*24))/3600))
      countTime:GetComponent("UnityEngine.UI.Text").text = str
    else
      local hour = 0
      local min =0
      local sec = 0
      hour = math.floor(time/3600)
      min = math.floor((time%3600)/60)
      sec = math.floor((time%3600)%60)
      str = string.format("<color=#FFED00FF>%02d:%02d:%02d</color>",hour,min,sec)
      countTime:GetComponent("UnityEngine.UI.Text").text = str
    end
    coroutine.wait(1)
    time = time-1    
  end
  countTime.parent.gameObject:SetActive(false)  
end

function HeroInfoController:DestroySelf()
  if PreviewHeroAPI ~= nil and PreviewHeroAPI.Instance~= nil then
    PreviewHeroAPI.Instance:Start();
  end

  if PartShopAPI ~= nil and PartShopAPI.Instance ~= nil then
    StoreNewCtrl.Instance:ApiModelActive(true)
    StoreNewCtrl.Instance:ApiModelActive(false)
  end
  Object.Destroy(self.this.gameObject)
end


--防御力换算
function  HeroInfoController:GetDefRate(def)
  -- body
  local defRate = 0
  defRate = 1 - (1/(def/600 + 1))

  return tostring(math.floor(defRate * 100))
end

function HeroInfoController:ChangeSkin(roleId,skinId,networkDelegate,networkDelegateSelf)
  -- body
  self.changeSkinDelegate = networkDelegate
  self.changeSkinDelegateSelf = networkDelegateSelf
  local changeSkinRequest = NetRequest.New()
  changeSkinRequest.Content = JObject.New(JProperty.New("Type", "RequestWearSkin"),
                    JProperty.New("RoleId",roleId),
                    JProperty.New("SkinId",skinId))
  changeSkinRequest.Handler = TGNetService.NetEventHanlderSelf(HeroInfoController.ChangeSkinHandler, self)
  TGNetService.GetInstance():SendRequest(changeSkinRequest)   
end

function HeroInfoController:ChangeSkinHandler(e)
  -- body
  if e.Type == "RequestWearSkin" then
    local result = json.decode(e.Content:get_Item("Result"):ToString())
    if result == 1 then

      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("更换成功")

      --self:GetSkinList(self.HeroId)
      for i = 1,#self.SkinList do
        if self.SkinList[i].Id == self.CurrentSkinId then
          self.SkinList[i] = Data.SkinsData[tostring(self.selectedSkinId)]
        end
      end


      --self:InitSelectHero(self.HeroId,self,HeroList)
      self:DoInitCenterBySkinId(self.selectedSkinId,self.SkinList)


    elseif result == 278 then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("请先获得该姬神")
    elseif result == 279 then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("请先获得该皮肤")
    end
    return true
  end
  return false
end

function HeroInfoController:DoWaitSP()
  coroutine.start(HeroInfoController.WaitSP,self)
end

function HeroInfoController:WaitSP()
  coroutine.wait(1)
  self:GetSkinList(self.HeroId)
end



function HeroInfoController:OnDestroy()
  for i = 1,#self.coroutines do
    coroutine.stop(self.coroutines[i])
  end
  coroutine.stop(self.heroTryTimeCoroutine)
  coroutine.stop(self.skinTryTimeCoroutine)
  NTGApplicationController.SetShowQuality(false)
  GameObject.Destroy(self.model.gameObject)
  NTGResourceController.Instance:UnloadAssetBundle(self.lastSelectedModel, true, false)
  self.this = nil
  self = nil

  
end
