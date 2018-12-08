require "System.Global"
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
local json = require "cjson"

class("GiftDetailsCtrl")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"

function GiftDetailsCtrl:Awake(this) 
  self.this = this
  self.btnClose = this.transforms[0] --关闭按钮
  self.giftItemPart = this.transforms[1] --礼包item的父类
  self.tip = this.transforms[2] --礼包提示
  self.buyPart = this.transforms[3]

  self.camera = GameObject.Find("GameLogic"):GetComponent("Camera")

  self.currentNum = self.buyPart:Find("Count/Count/Current")
  self.reduceButton = self.buyPart:Find("Count/ReduceImage")
  self.addButton = self.buyPart:Find("Count/AddImage")
  self.maxButton = self.buyPart:Find("Count/MaxButton")

  self.buyButton = self.buyPart:Find("Button")

  self.subItem = {}
  for i = 1,self.giftItemPart.childCount do
    table.insert(self.subItem,self.giftItemPart:GetChild(i-1))
    self.giftItemPart:GetChild(i-1).gameObject:SetActive(false)
  end

  self.giftDes = self.giftItemPart.parent:Find("LabDes")
  self.payType = self.buyButton:Find("Image")
  self.payNum = self.buyButton:Find("LabCost")

  self.num = 1


  local listener = NTGEventTriggerProxy.Get(self.btnClose.gameObject)
  local callbackClose = function(self, e)
    self:DestroySelf()
  end 
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( callbackClose,self)

end

function  GiftDetailsCtrl:Start()
  --self:GiftItemBindInit()
end

function GiftDetailsCtrl:DataInit(id,isLock,canBuyNum,buyType,singlePrice,list)
  print("asdddddddddddddd " .. singlePrice)
  for i = 1,#self.subItem do
    self.subItem[i].gameObject:SetActive(false)
  end
  local itemData = Data.ItemsData[tostring(id)]
  self.giftDes:GetComponent(Text).text = itemData.Desc

  if itemData.Type == 16 then
    for i = 1,#list do
      local itemName = ""
      local itemNum = 0
      local itemDesc = ""
      self.subItem[i].gameObject:SetActive(true)
      if list[i].Type == 4 then
        if Data.ItemsData[tostring(list[i].Id)].Type == 7 then
          self.subItem[i]:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(list[i].Id)].Icon)
          itemName = Data.ItemsData[tostring(list[i].Id)].Name
          if Data.ItemsDeck[tostring(list[i].Id)] ~= nil then
            itemNum = Data.ItemsDeck[tostring(list[i].Id)].Amount
          else
            itemNum = 0
          end
          itemDesc = Data.ItemsData[tostring(list[i].Id)].Desc
          self.subItem[i]:Find("Hero").gameObject:SetActive(true)
        elseif Data.ItemsData[tostring(list[i].Id)].Type == 8 then
          self.subItem[i]:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(list[i].Id)].Icon)
          itemName = Data.ItemsData[tostring(list[i].Id)].Name
          if Data.ItemsDeck[tostring(list[i].Id)] ~= nil then
            itemNum = Data.ItemsDeck[tostring(list[i].Id)].Amount
          else
            itemNum = 0
          end
          itemDesc = Data.ItemsData[tostring(list[i].Id)].Desc
          self.subItem[i]:Find("Skin").gameObject:SetActive(true)
        elseif Data.ItemsData[tostring(list[i].Id)].Type == 13 then
          self.subItem[i]:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(list[i].Id)].Icon)
          itemName = Data.ItemsData[tostring(list[i].Id)].Name
          itemNum = Data.PlayerData.Coin
          itemDesc = Data.ItemsData[tostring(list[i].Id)].Desc
        elseif Data.ItemsData[tostring(list[i].Id)].Type == 14 then
          self.subItem[i]:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(list[i].Id)].Icon)
          itemName = Data.ItemsData[tostring(list[i].Id)].Name
          itemNum = Data.PlayerData.Gem
          itemDesc = Data.ItemsData[tostring(list[i].Id)].Desc
        elseif Data.ItemsData[tostring(list[i].Id)].Type == 15 then
          self.subItem[i]:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(list[i].Id)].Icon)
          itemName = Data.ItemsData[tostring(list[i].Id)].Name
          itemNum = Data.PlayerData.Voucher
          itemDesc = Data.ItemsData[tostring(list[i].Id)].Desc
        elseif Data.ItemsData[tostring(list[i].Id)].Type == 17 then
          self.subItem[i]:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(list[i].Id)].Icon)          
          itemName = Data.ItemsData[tostring(list[i].Id)].Name
          itemNum = Data.PlayerData.RunePiece
          itemDesc = Data.ItemsData[tostring(list[i].Id)].Desc        
        else
          self.subItem[i]:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(list[i].Id)].Icon)   
          itemName = Data.ItemsData[tostring(list[i].Id)].Name
          if Data.ItemsDeck[tostring(list[i].Id)] ~= nil then
            itemNum = Data.ItemsDeck[tostring(list[i].Id)].Amount
          else
            itemNum = 0
          end
          itemDesc = Data.ItemsData[tostring(list[i].Id)].Desc
        end
        self.subItem[i]:Find("IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("icon",Data.ItemsData[tostring(list[i].Id)].Quality)
        self.subItem[i]:Find("LabName"):GetComponent(Text).text = Data.ItemsData[tostring(list[i].Id)].Name
      elseif list[i].Type == 3 then
        self.subItem[i]:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",Data.RunesData[tostring(list[i].Id)].Icon)
        self.subItem[i]:Find("IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("icon",Data.RunesData[tostring(list[i].Id)].Level)
        self.subItem[i]:Find("LabName"):GetComponent(Text).text = Data.RunesData[tostring(list[i].Id)].Name
        self.subItem[i]:Find("IconFrame/Image/Icon"):GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector2.New(73,84.4)
        itemName = Data.RunesData[tostring(list[i].Id)].Name
        if Data.RunesDeck[tostring(list[i].Id)] ~= nil then
          itemNum = Data.RunesDeck[tostring(list[i].Id)].Amount
        else
          itemNum = 0
        end
        local attrs = UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",list[i].Id)
        local str = ""
        for i = 1,#attrs do
              if i == #attrs then
                str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr
              else
                str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr .. "\n"
              end
        end
        itemDesc = str  
      elseif list[i].Type == 1 then
        self.subItem[i]:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",
                                                        Data.SkinsData[tostring(Data.RolesData[tostring(list[i].Id)].Skin)].Icon)
        self.subItem[i]:Find("IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("icon",4)
        self.subItem[i]:Find("LabName"):GetComponent(Text).text = Data.RolesData[tostring(list[i].Id)].Name
        itemName = Data.RolesData[tostring(list[i].Id)].Name
        itemNum = 1
        itemDesc = Data.RolesData[tostring(list[i].Id)].Desc
        if Data.RolesDeckData[tostring(list[i].Id)] ~= nil then
          self.subItem[i]:Find("Own").gameObject:SetActive(true)
        end
      elseif list[i].Type == 2 then
        self.subItem[i]:Find("IconFrame/Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.SkinsData[tostring(list[i].Id)].Icon)
        self.subItem[i]:Find("IconFrame"):GetComponent(Image).sprite = UITools.GetSprite("icon",4)
        self.subItem[i]:Find("LabName"):GetComponent(Text).text = Data.SkinsData[tostring(list[i].Id)].Name
        itemName = Data.SkinsData[tostring(list[i].Id)].Name
        itemNum = 1
        itemDesc = Data.SkinsData[tostring(list[i].Id)].Desc        
      end
      self.subItem[i]:Find("Text"):GetComponent(Text).text = list[i].Amount

      local listener = NTGEventTriggerProxy.Get(self.subItem[i]:Find("IconFrame/Image/Icon").gameObject)
      local callback = function(self,e)
        self:ShowTipsControl(itemName,itemNum,itemDesc)
      end
      listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)

      listener = NTGEventTriggerProxy.Get(self.subItem[i]:Find("IconFrame/Image/Icon").gameObject)
      local callback1 = function(self,e)
        self.tip.gameObject:SetActive(false)
      end
      listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1,self)           
    end
  end





  local maxNum = 0

  if isLock == true then
    maxNum = canBuyNum
  else
    local itemNum = 0
    if Data.ItemsDeck[tostring(id)] ~= nil then
      itemNum = Data.ItemsDeck[tostring(id)].Amount
    else
      itemNum = 0
    end
    maxNum = itemData.MaxStack - itemNum
  end

  --设置货币图标及价格
  if buyType == 1 then
    self.payType:GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Coin")
  elseif buyType == 2 then
    self.payType:GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Gem")
  elseif buyType == 3 then
    self.payType:GetComponent(Image).sprite = UITools.GetSprite("resourceicon","Voucher")
  end

  self.payNum:GetComponent(Text).text = singlePrice

  self.currentNum:GetComponent(Text).text = self.num

  self.shopId = 0
  if Data.ShopsData[tostring(id)] ~= nil then
    self.shopId = Data.ShopsData[tostring(id)][1].Id
  end
  
  local listener = NTGEventTriggerProxy.Get(self.reduceButton.gameObject)
  local callbackReduce = function(self, e)
    if self.num > 1 then
      self.num = self.num - 1
      self.currentNum:GetComponent(Text).text = self.num
      self.payNum:GetComponent(Text).text = singlePrice * self.num
    end
  end 
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackReduce,self)

  local listener = NTGEventTriggerProxy.Get(self.addButton.gameObject)
  local callbackAdd = function(self, e)
    if self.num < maxNum then
      self.num = self.num + 1
      self.currentNum:GetComponent(Text).text = self.num
      self.payNum:GetComponent(Text).text = singlePrice * self.num
    end
  end 
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackAdd,self)

  local listener = NTGEventTriggerProxy.Get(self.maxButton.gameObject)
  local callbackMax = function(self, e)
    if self.num < maxNum then
      self.num = maxNum
      self.currentNum:GetComponent(Text).text = self.num
      self.payNum:GetComponent(Text).text = singlePrice * self.num
    end
  end 
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackMax,self)

  local listener = NTGEventTriggerProxy.Get(self.buyButton.gameObject)
  local callbackBuy = function(self, e)
    --购买
    UTGDataOperator.Instance:ShopBuy(self.shopId,buyType,self.num)
  end 
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackBuy,self)  



end



function GiftDetailsCtrl:OnDestroy() 
  self.this = nil
  self = nil
end

--页签按钮响应绑定
function GiftDetailsCtrl:BtnPageInit(args)
  local listener = NTGEventTriggerProxy.Get(self.btnClose.gameObject)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.onBtnClose,self)
end

function GiftDetailsCtrl:OnBtnClose(args)
  --GameObject.Destroy(self.this.gameObject)
 self.this.gameObject:SetActive(false)
end

function GiftDetailsCtrl:ShowTipsControl(itemName,ownNum,desc)
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


function GiftDetailsCtrl:DestroySelf()
  -- body
  GameObject.DestroyImmediate(self.this.transform.parent.gameObject)
end


