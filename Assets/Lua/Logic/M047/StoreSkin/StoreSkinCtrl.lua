require "System.Global"
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
local json = require "cjson"

class("StoreSkinCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"
local Toggle = "UnityEngine.UI.Toggle"

local TypeTopAll = 1
local TypeTopTank = 2
local TypeTopWarrior = 3
local TypeTopAssassin = 4
local TypeTopMage = 5
local TypeTopShooter = 6
local TypeTopAssist = 7

--排序
local typeSortDefault = 0
local typeSortName = 1
local typeSortRmb = 2
local typeSortGold = 3
local typeSortTime = 4

--排序反转
local typeSortDefaultTurn = -0
local typeSortNameTurn = -1
local typeSortRmbTurn = -2
local typeSortGoldTurn = -3
local typeSortTimeTurn = -4


local TypeShophero = 1
local TypeShopSkin = 2
local TypeShopRune = 3
local TypeShopBag = 4

-----------------------------------------------------外部调用api------------------------------------------------------------------------------
--对卡片进行排序 
function StoreSkinCtrl:apiCardSort(typeSort)
  if self.typeSort == typeSort then --进行反转排序
    self:tabTurnSet(self.typeSort) --其他排序置为默认
    --Debugger.Log("self.typeSort * (self.tabTurn[tostring(typeSort)])"..self.typeSort * (self.tabTurn[tostring(typeSort)]))
    self.tabTurn[tostring(typeSort)]  = self.tabTurn[tostring(typeSort)] * (-1)

    local tabTmp = self.tabSort[tostring(self.typeSort * (self.tabTurn[tostring(typeSort)]))][self.typeTop]
    if tabTmp ~= nil then
      --Debugger.Log("self.typeSort == typeSort----------------------------------------------------------------")
      self:itemInit(tabTmp)
      if (typeSort == 4) then
        --Debugger.Log("---------------------------------------4444444444444444444")
      end
    end
    
  else 
    self.typeSort = typeSort --当前排序类型
    --self.tabTurn[tostring(typeSort)]  = self.tabTurn[tostring(typeSort)] * (-1)
    self:tabTurnSet(self.typeSort) --其他排序置为默认
    local tabTmp = self.tabSort[tostring(self.typeSort)][self.typeTop] --一定是显示默认的排序
    if tabTmp ~= nil then
      self:itemInit(tabTmp)
      if (typeSort == 4) then
        --Debugger.Log("++++++++++++++++++++++++++++++++++4444444444444444444")
      end
    end
    self.tabTurn[tostring(typeSort)]  = 1--self.tabTurn[tostring(typeSort)] * (-1)
  end

end

function StoreSkinCtrl:ApiUpdateHeroList(args)
  self:dataInit()
  self.topBtnPart:GetChild(0):GetComponent(Toggle).isOn = true
  self.typeTop = -1 
  self:onClickTop(1)
  --todo 排序面板，top

end


----------------------------------------------------------------------------------------------------------------------------------------------

function StoreSkinCtrl:tabTurnSet(idx)
  for i,v in pairs(self.tabTurn) do
    if tostring(idx) ~= i then
      v = -1
    end
  end
end

function StoreSkinCtrl:Awake(this) 
  self.this = this 
  self.topBtnPart = this.transforms[0] 
  self.itemPart = this.transforms[1]
  self.itemTmp = this.transforms[2]
  self.noneTip = this.transforms[3]
  StoreSkinCtrl.Instance = self
end

function StoreSkinCtrl:Start()
  self:dataInit()
  self:topBtnInit()
  --self:itemInit(self.tabHero) --初始化一开始的全部item
  self:itemInit(self.tabSort[tostring(self.typeSort)][self.typeTop])
end

function StoreSkinCtrl:dataInit(args)
  self.tabTurn = {}
  self.tabTurn[tostring(typeSortDefault)]  = -1
  self.tabTurn[tostring(typeSortName)]  = -1
  self.tabTurn[tostring(typeSortRmb)]  = -1
  self.tabTurn[tostring(typeSortGold)]  = -1
  self.tabTurn[tostring(typeSortTime)]  = -1

  self.typeSort = typeSortDefault
  self.typeTop = TypeTopAll
  self.tabSort = {}
  self.tabHero = {}
  self.tabHero = UITools.CopyTab(UTGData.Instance().ShopsSkinData) --这个是显示全部英雄数据

  --英雄进行id排序
  local function idSort(a,b)
    if a.Id  < b.Id   then
      return true
    end
    return false
  end 
  table.sort(self.tabHero,idSort)

  self.tabHeroClass0 = {}
  self.tabHeroClass1 = {}
  self.tabHeroClass2 = {}
  self.tabHeroClass3 = {}
  self.tabHeroClass4 = {}
  self.tabHeroClass5 = {}

  --self.tabCardTrans = {} --保存当前存在列表trans项

  for i,v in pairs(self.tabHero) do
    local skinInfo = UTGData.Instance().SkinsData[tostring(v.CommodityId)]
    local roleInfo = UTGData.Instance().RolesData[tostring(skinInfo.RoleId)] --heroID
    if roleInfo.Class == 0 then 
      table.insert(self.tabHeroClass0,v);
    elseif roleInfo.Class == 1 then 
      table.insert(self.tabHeroClass1,v);
    elseif roleInfo.Class == 2 then 
      table.insert(self.tabHeroClass2,v);
    elseif roleInfo.Class == 3 then 
      table.insert(self.tabHeroClass3,v);
    elseif roleInfo.Class == 4 then 
      table.insert(self.tabHeroClass4,v);
    elseif roleInfo.Class == 5 then 
      table.insert(self.tabHeroClass5,v);
    end
  end

  
--  local str1 = {1}
--  local str2 = str1 --浅拷贝
--  str2[1] = 23
--  --Debugger.Log("str1[1].num = "..str1[1])

  --默认排序
  self.tabCardTab = {self.tabHero,self.tabHeroClass0,self.tabHeroClass1,self.tabHeroClass2,self.tabHeroClass3,self.tabHeroClass4,self.tabHeroClass5}
--  self.tabSort[tostring(typeSortDefault)] = self.tabCardTab
--  self.tabSort[tostring(typeSortDefaultTurn)] = self.tabCardTab


  --按照拥有排序
  local tabOwn = {}
  local function ownSort(a,b)
    local isAOwn = StoreCtrl.Instance:isSkinOwn(a.CommodityId)
    local isBOwn = StoreCtrl.Instance:isSkinOwn(b.CommodityId)
    if (isAOwn == false and isBOwn == true) then
      return true
    end
    return false
  end 
  for i = 1,#self.tabCardTab,1 do
    local tabOne = UITools.CopyTab(self.tabCardTab[i])
    table.sort(tabOne,ownSort)
    table.insert(tabOwn,tabOne)
  end

  
  self.tabSort[tostring(typeSortDefault)] = tabOwn
  self.tabSort[tostring(typeSortDefaultTurn)] = tabOwn

  --点劵价格排序
  local function rmbSort(a,b)
    if a.VoucherPrice < b.VoucherPrice then
      return true
    end
    return false
  end 

  self.tabCardTabRmb = {}
  for i = 1,#self.tabCardTab,1 do
    local tabOneRmb = UITools.CopyTab(self.tabCardTab[i])
    table.sort(tabOneRmb,rmbSort)
    table.insert(self.tabCardTabRmb,tabOneRmb)
  end

  self.tabSort[tostring(typeSortRmb)] = self.tabCardTabRmb

 --点劵价格排序----------------------------------------
  local function rmbSort(a,b)
    if a.VoucherPrice < b.VoucherPrice then
      return true
    end
    return false
  end 

  self.tabCardTabRmb = {}
  for i = 1,#self.tabCardTab,1 do
    local tabOneRmb = UITools.CopyTab(self.tabCardTab[i])
    table.sort(tabOneRmb,rmbSort)
    table.insert(self.tabCardTabRmb,tabOneRmb)
  end

  self.tabSort[tostring(typeSortRmb)] = self.tabCardTabRmb


  local function rmbSortTurn(a,b)
    if a.VoucherPrice > b.VoucherPrice then
      return true
    end
    return false
  end 

  self.tabCardTabRmbTurn = {}
  for i = 1,#self.tabCardTab,1 do
    local tabOneRmb = UITools.CopyTab(self.tabCardTab[i])
    table.sort(tabOneRmb,rmbSortTurn)
    table.insert(self.tabCardTabRmbTurn,tabOneRmb)
  end

  self.tabSort[tostring(typeSortRmbTurn)] = self.tabCardTabRmbTurn


  --金币排序------------------------------------------------------------------------------------
  local function coinSort(a,b)
    if a.CoinPrice < b.CoinPrice then
      return true
    end
    return false
  end 

  self.tabCardTabCoin = {}
  for i = 1,#self.tabCardTab,1 do
    local tabOne = UITools.CopyTab(self.tabCardTab[i])
    table.sort(tabOne,coinSort)
    table.insert(self.tabCardTabCoin,tabOne)
  end

  self.tabSort[tostring(typeSortGold)] = self.tabCardTabCoin


  local function coinSortTurn(a,b)
    if a.CoinPrice > b.CoinPrice then
      return true
    end
    return false
  end 

  self.tabCardTabCoinTurn = {}
  for i = 1,#self.tabCardTab,1 do
    local tabOne = UITools.CopyTab(self.tabCardTab[i])
    table.sort(tabOne,coinSortTurn)
    table.insert(self.tabCardTabCoinTurn,tabOne)
  end

  self.tabSort[tostring(typeSortGoldTurn)] = self.tabCardTabCoinTurn


  --------------------------------------------------------------------------------------------------------
  --名称排序todo !!!!!
  local function nameSort(a,b)
    local roleInfoA = UTGData.Instance().SkinsData[tostring(a.CommodityId)] --从商品id转为英雄id
    local roleInfoB = UTGData.Instance().SkinsData[tostring(b.CommodityId)] --从商品id转为英雄id
    if (roleInfoA.NameOrder < roleInfoB.NameOrder) then
      return true
    end
    return false
  end

  self.tabCardTabName = {}
  for i = 1,#self.tabCardTab,1 do
    local tabOne = UITools.CopyTab(self.tabCardTab[i])
    table.sort(tabOne,nameSort)
    table.insert(self.tabCardTabName,tabOne)
  end

  self.tabSort[tostring(typeSortName)] = self.tabCardTabName

  local function nameSortTurn(a,b)
    local roleInfoA = UTGData.Instance().SkinsData[tostring(a.CommodityId)] --从商品id转为英雄id
    local roleInfoB = UTGData.Instance().SkinsData[tostring(b.CommodityId)] --从商品id转为英雄id
    if (roleInfoA.NameOrder > roleInfoB.NameOrder) then
      return true
    end
    return false
  end

  self.tabCardTabNameTurn = {}
  for i = 1,#self.tabCardTab,1 do
    local tabOne = UITools.CopyTab(self.tabCardTab[i])
    table.sort(tabOne,nameSortTurn)
    table.insert(self.tabCardTabNameTurn,tabOne)
  end

  self.tabSort[tostring(typeSortNameTurn)] = self.tabCardTabNameTurn
  ---------------------------------------------------------------------------------------------------------
  --上架时间排序
  local function timeSort(a,b)
    local aTime = UTGData.Instance():GetLeftTime(a.StartTime)
    local bTime = UTGData.Instance():GetLeftTime(b.StartTime)
    if aTime  < bTime   then
      return true
    end
    return false
  end 

  self.tabCardTabStartTime = {}
  for i = 1,#self.tabCardTab,1 do
    local tabOne = UITools.CopyTab(self.tabCardTab[i])
    table.sort(tabOne,timeSort)
    table.insert(self.tabCardTabStartTime,tabOne)
  end
  
  self.tabSort[tostring(typeSortTime)] = self.tabCardTabStartTime

  local function timeSortTurn(a,b)
    local aTime = UTGData.Instance():GetLeftTime(a.StartTime)
    local bTime = UTGData.Instance():GetLeftTime(b.StartTime)
    if aTime  > bTime   then
      return true
    end
    return false
  end 

  self.tabCardTabStartTimeTurn = {}
  for i = 1,#self.tabCardTab,1 do
    local tabOne = UITools.CopyTab(self.tabCardTab[i])
    table.sort(tabOne,timeSortTurn)
    table.insert(self.tabCardTabStartTimeTurn,tabOne)
  end
  
  self.tabSort[tostring(typeSortTimeTurn)] = self.tabCardTabStartTimeTurn
end

function StoreSkinCtrl:topBtnInit(args)
  self.tabTopBtnLabWhite = {}
  for i = 0, self.topBtnPart.childCount-1,1 do
    local btn = self.topBtnPart:GetChild(i)
    local labWhite = btn:FindChild("LabNameWhite")
    table.insert(self.tabTopBtnLabWhite,labWhite)
    local listener = NTGEventTriggerProxy.Get(btn.gameObject)
    local callback = function(self, e)
      self:onClickTop(i+1)
	  end	
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self )
  end
end

--选择当前实现哪个职业
function StoreSkinCtrl:onClickTop(idx)
  --Debugger.Log(idx)
  if (self.typeTop == idx) then
    return
  end
  self:topBtnWhiteActive(idx)
  self.typeTop = idx
  --local tabTmp = self.tabCardTab[idx]

  local tabTmp = self.tabSort[tostring(self.typeSort)][idx]

  self:itemInit(tabTmp)

  if (#tabTmp == 0) then
    self.noneTip.gameObject:SetActive(true)
  else
    self.noneTip.gameObject:SetActive(false)
  end
end

function StoreSkinCtrl:topBtnWhiteActive(idx)
  if self.tabTopBtnLabWhite == nil then
    return
  end
  for i = 1,#self.tabTopBtnLabWhite,1 do
    if i == idx then
      self.tabTopBtnLabWhite[i].gameObject:SetActive(true)
    else
      self.tabTopBtnLabWhite[i].gameObject:SetActive(false)
    end
  end
end


function StoreSkinCtrl:OnDestroy() 
  self.this = nil
  self = nil
  StoreSkinCtrl.Instance = nil
end

function StoreSkinCtrl:itemInit(tabTmp)
 for i = 0 ,self.itemPart.childCount-1 ,1 do
   local obj = self.itemPart:GetChild(i)
   Object.Destroy(obj.gameObject)
 end
 --self.tabCardTrans = {}

 for i,v in ipairs(tabTmp) do
    --Debugger.Log("StoreSkinCtrl:itemInit"..i)
    local newTmp = GameObject.Instantiate(self.itemTmp)
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(i)
    newTmp.transform:SetParent(self.itemPart)
    newTmp.transform.localPosition = Vector3.zero
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one
    --table.insert(self.tabCardTrans,newTmp.transform)
    --self:heroCardSetInfo(newTmp.transform,v)
    StoreCtrl.Instance:heroCradInfoSet(newTmp.transform,v,false)

    local bg = newTmp.transform:FindChild("iconPart/ClickBg")
    local listener = NTGEventTriggerProxy.Get(bg.gameObject)
    local callback = function(self, e)
      self:onClickGoto(v)
	  end	
    UITools.GetLuaScript(bg,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)

    local btn = newTmp.transform:FindChild("Button")
    listener = NTGEventTriggerProxy.Get(btn.gameObject)
    callback = function(self, e)
      --self:onClickBuy(v)
      StoreCtrl.Instance:onClickHeroCardBuy(v)
	  end	
    UITools.GetLuaScript(btn,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)
  end
  ----Debugger.Log("after #self.tabCardTrans = "..#self.tabCardTrans)
end

function StoreSkinCtrl:onClickGoto(info)
  if  (info.CommodityType == TypeShophero) then
    local role = UTGData.Instance().RolesData[tostring(info.CommodityId)]
    --Debugger.Log(role.Name)
    local tabShop = self.tabSort[tostring(self.typeSort * (self.tabTurn[tostring(self.typeSort)]))][self.typeTop]
    local tabHero = self:tabShopToTabHero(tabShop)
    StoreCtrl.Instance:gotoHeroInfoPanel(role.Id,tabHero)
  elseif info.CommodityType == TypeShopSkin then 
    local skinInfo = UTGData.Instance().SkinsData[tostring(info.CommodityId)]
    --Debugger.Log(skinInfo.Name)
    local tabShop = self.tabSort[tostring(self.typeSort * (self.tabTurn[tostring(self.typeSort)]))][self.typeTop]--皮肤
    local tabSkin = self:tabShopToTabSkin(tabShop)

    local roleInfo =  UTGData.Instance().RolesData[tostring(skinInfo.RoleId)]
    local tabHero = self:tabShopSkinToTabHero(tabShop)
    StoreCtrl.Instance:gotoSkinInfoPanel(info.CommodityId,tabSkin,skinInfo.RoleId,tabHero)
  end
end

--将商品表转为英雄表
function StoreSkinCtrl:tabShopToTabHero(tabShop)
  local tabHero = {}
  for i,v in ipairs(tabShop) do
    local roleInfo = UTGData.Instance().RolesData[tostring(v.CommodityId)]
    table.insert(tabHero,roleInfo)
  end
  return tabHero
end

--将商品表转为皮肤表
function StoreSkinCtrl:tabShopToTabSkin(tabShop)
  local tabHero = {}
  for i,v in ipairs(tabShop) do
    --print("sdfsdf " .. v.CommodityId)
    local skinInfo = UTGData.Instance().SkinsData[tostring(v.CommodityId)]
    --local roleInfo = UTGData.Instance().RolesData[tostring(skinInfo.RoleId)]
    table.insert(tabHero,skinInfo)
  end
  return tabHero
end

--将商品皮肤表转为英雄表
function StoreSkinCtrl:tabShopSkinToTabHero(tabShop)
  local tabHero = {}
  for i,v in ipairs(tabShop) do
    --print("sdfsdf " .. v.CommodityId)
    local skinInfo = UTGData.Instance().SkinsData[tostring(v.CommodityId)]
    local roleInfo = UTGData.Instance().RolesData[tostring(skinInfo.RoleId)]
    table.insert(tabHero,roleInfo)
  end
  return tabHero
end


--点击购买英雄
--info 为商品信息
function StoreSkinCtrl:onClickBuy(info)
  if  (info.CommodityType == TypeShophero) then
    --如果没有拥有
    local isOwn = StoreCtrl.Instance:isHeroOwn(info.CommodityId)
    if (isOwn == false) then
      StoreCtrl.Instance:gotoHeroBuyPanel(info)
    end

  elseif info.CommodityType == TypeShopSkin then 
    local skinInfo = UTGData.Instance().SkinsData[tostring(info.CommodityId)]
    --Debugger.Log(skinInfo.Name)
    local isOwn = StoreCtrl.Instance:isSkinOwn(info.CommodityId)
    if  (isOwn == false) then
      StoreCtrl.Instance:gotoSkinBuyPanel(info)
    end
  end
end

