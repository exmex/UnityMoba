--author zx
require "System.Global"
require "Logic.UICommon.Static.UITools"
class("GiftCenterCtrl")

local json = require "cjson"

--排序方法 正序 参数：shop

local function SortByName(a,b) --名称
  local roleInfoA = UTGData.Instance().SkinsData[tostring(a.CommodityId)] 
  local roleInfoB = UTGData.Instance().SkinsData[tostring(b.CommodityId)] 
  return roleInfoA.NameOrder < roleInfoB.NameOrder
end

local function SortByPrice(a,b) --点劵价格
  return a.VoucherPrice < b.VoucherPrice
end

local function SortByOnSaleTime(a,b) --上架时间
  local aTime = UTGData.Instance():GetLeftTime(a.StartTime)
  local bTime = UTGData.Instance():GetLeftTime(b.StartTime)
  return aTime < bTime 
end

local function SortById(a,b) --id（默认）
  return a.CommodityId<b.CommodityId
end


function GiftCenterCtrl:Awake(this)
  self.this = this

  self.top = this.transforms[0]
  self.middle = this.transforms[1]

  self.gridClassButton = self.middle:FindChild("TopBtnPart/BtnPart")
  self.wuList = self.middle:FindChild("Wu")
  self.wuList.gameObject:SetActive(false)

  self.gridList = self.middle:FindChild("Scroll/Viewport/Content")
  self.tempSkin = self.middle:FindChild("NewTmp")

  self.sortNow = self.top:FindChild("BtnSortPart")
  self.sortList = self.top:FindChild("PageList")


  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")

end

function GiftCenterCtrl:Start()

  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("GiftCenterPanel/Main/Top/ResourcePanel")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,self.ClickClosePanel,nil,nil,"赠礼中心")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(topAPI)

  self:Init()
end
function GiftCenterCtrl:ClickClosePanel()
  Object.Destroy(self.this.transform.parent.gameObject)
end


function GiftCenterCtrl:Init()
  self.allShopSkinData = {} --全部皮肤数据
  for k,v in pairs(UTGData.Instance().ShopsSkinData) do
    table.insert(self.allShopSkinData,v)
  end

  table.sort(self.allShopSkinData,SortById)

  self.allSkinTran = {}
  self.sortCtrl = {}
  self:InitClassButton()
  self:InitList(self.allShopSkinData)
  self:InitSortList()

end

function GiftCenterCtrl:InitClassButton()
  for i=1,self.gridClassButton.childCount do
    local temp = self.gridClassButton:GetChild(i-1)
    UITools.GetLuaScript(temp.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickClassButton,temp.name)
  end
end
--点击职业按钮
function GiftCenterCtrl:ClickClassButton(name)
  name = tostring(name)
  if self.gridClassButton:FindChild(name.."/Liang").gameObject.activeSelf then 
    return
  end
  for i=1,self.gridClassButton.childCount do
    local temp = self.gridClassButton:GetChild(i-1)
    temp:FindChild("Liang").gameObject:SetActive(false)
  end
  self.gridClassButton:FindChild(name.."/Liang").gameObject:SetActive(true)

  self:UpdateListByClassType(tonumber(name))
end
--初始化列表
function GiftCenterCtrl:InitList(data)
  for i,v in ipairs(data) do
    local temp = GameObject.Instantiate(self.tempSkin)
    temp.gameObject:SetActive(true)
    temp.name = tostring(i)
    temp.transform:SetParent(self.gridList)
    temp.transform.localPosition = Vector3.zero
    temp.transform.localRotation = Quaternion.identity
    temp.transform.localScale = Vector3.one
    StoreCtrl.Instance:heroCradInfoSet(temp.transform,v,false)
    local tLab = temp:FindChild("LabBuy")
    tLab:GetComponent("UnityEngine.UI.Text").text = "赠送"
    UITools.GetLuaScript(temp:FindChild("iconPart/ClickBg").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickOpenSkinPanel,v) --查看皮肤信息
    UITools.GetLuaScript(temp:FindChild("Button").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickSendGift,v) --赠送
  
    self.allSkinTran[tostring(v.CommodityId)] = temp
  end
end
--更新 列表 by 职业
function GiftCenterCtrl:UpdateListByClassType(classType)
  classType = tonumber(classType)
  if classType<0 then
    for k,v in pairs(self.allSkinTran) do
      v.gameObject:SetActive(true)
    end
  else
    for i,v in ipairs(self.allShopSkinData) do
      local skinId = v.CommodityId
      if UTGData.Instance().RolesData[tostring(UTGData.Instance().SkinsData[tostring(skinId)].RoleId)].Class == classType then 
        self.allSkinTran[tostring(skinId)].gameObject:SetActive(true)
      else
        self.allSkinTran[tostring(skinId)].gameObject:SetActive(false)
      end 
    end
  end

  self.wuList.gameObject:SetActive(true)
  for k,v in pairs(self.allSkinTran) do
    if v.gameObject.activeSelf then
      self.wuList.gameObject:SetActive(false)
      break
    end
  end
end
--更新 列表 by 排序
function GiftCenterCtrl:UpdateListBySort(data,inverse)
  inverse = inverse or false
  local grid = self.gridList
  local index = 0
  for i=0,#data-1 do
    if inverse then 
      index = #data - i
    else
      index = i+1
    end
    local temp = self.allSkinTran[tostring(data[index].CommodityId)].transform
    temp:SetParent(grid.parent)
    temp:SetParent(grid)
  end
end

function GiftCenterCtrl:ClickOpenSkinPanel(data)
  GameManager.CreatePanel("SkinWindow19")
  SkinWindow19API.Instance:Show(data.CommodityId)
  SkinWindow19API.Instance:SetSendGift()
end

function GiftCenterCtrl:ClickSendGift(data)
  GameManager.CreatePanel("GiftSkin")
  GiftSkinAPI.Instance:InitGiftSkin(data.CommodityId)
end

--初始化排序选择菜单
function GiftCenterCtrl:InitSortList()
  local listener = NTGEventTriggerProxy.Get(self.sortNow:FindChild("BtnSort").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickOpenSortList,self)
  local grid = self.sortList:FindChild("Root")
  for i=1,grid.childCount do
    local temp = grid:GetChild(i-1)
    UITools.GetLuaScript(temp.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickSelectSortType,temp.name)
  end
  self.sortList.gameObject:SetActive(false)
end
--打开或关闭列表
function GiftCenterCtrl:ClickOpenSortList()
  if self.sortList.gameObject.activeSelf then
    self.sortList.gameObject:SetActive(false)
  else
    self.sortList.gameObject:SetActive(true)
  end
end

--选择排序
function GiftCenterCtrl:ClickSelectSortType(name)
  name = tonumber(name)
  self.sortList.gameObject:SetActive(false)
  local text = self.sortList:FindChild("Root/"..name):GetComponent("UnityEngine.UI.Text").text
  self.sortNow:FindChild("LabSort"):GetComponent("UnityEngine.UI.Text").text = text
  if name == 0 then 
    table.sort(self.allShopSkinData,SortById)
    self:UpdateListBySort(self.allShopSkinData)
  else
    if name == 1 then 
      table.sort(self.allShopSkinData,SortByName)
    elseif name == 2 then 
      table.sort(self.allShopSkinData,SortByPrice)
    elseif name == 3 then 
      table.sort(self.allShopSkinData,SortByOnSaleTime)
    end
    
    if self.sortCtrl[tostring(name)] == false then 
      self.sortCtrl[tostring(name)] = true
    elseif self.sortCtrl[tostring(name)] == true then
      self.sortCtrl[tostring(name)] = false
    end
    self.sortCtrl[tostring(name)] = self.sortCtrl[tostring(name)] or false
    self:UpdateListBySort(self.allShopSkinData,self.sortCtrl[tostring(name)])
  end
end



function GiftCenterCtrl:OnDestroy()
  self.this = nil
  self = nil
end
