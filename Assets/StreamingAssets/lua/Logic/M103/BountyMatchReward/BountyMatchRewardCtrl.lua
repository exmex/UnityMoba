--author zx
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
require "Logic.UTGData.UTGDataTemporary"

class("BountyMatchRewardCtrl")

function BountyMatchRewardCtrl:Awake(this)
  self.this = this
  self.main = this.transform
  self.tempItem = this.transforms[0]
  self.tempList = this.transforms[1]
  self.gridList = this.transforms[2]
  self.tip = this.transforms[3]

  self.textRule = "待补充"
  --数据
  self.bountyData = UTGData.Instance().BountiesData[tostring(UTGDataTemporary.Instance().BountyMatchCoinTemplateId)]
  local bonus = UTGData.Instance():StringSplit(self.bountyData.Bonus,";")
  self.bonusData = {}
  for i,v in ipairs(bonus) do
    local one = UTGData.Instance():StringSplit(v,",")
    local data = {}
    data.Num = one[1]
    data.ItemId = one[2]
    table.insert(self.bonusData,data)
  end

  self.itemUIData = {}
end

function BountyMatchRewardCtrl:SetWait(boo)
  self.wait.gameObject:setActive(boo)
end

function BountyMatchRewardCtrl:Start()
  self:Init()
end

function BountyMatchRewardCtrl:Init()
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.main:FindChild("But-Close").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickClosePanel,self) 

  self:InitList(self.bonusData)
end
function BountyMatchRewardCtrl:CreateTransform(item,_parent)
  local tempo = GameObject.Instantiate(item)
  tempo.transform:SetParent(_parent)
  tempo.transform.localPosition = Vector3.zero
  tempo.transform.localRotation = Quaternion.identity
  tempo.transform.localScale = Vector3.one
  return tempo
end

function BountyMatchRewardCtrl:InitList(bonusData)
  for i,v in ipairs(bonusData) do
    local tempo = self:CreateTransform(self.tempList,self.gridList)
    tempo.name = tostring(i)
    tempo:FindChild("Num/Text"):GetComponent("UnityEngine.UI.Text").text = v.Num.."胜奖励"
    self:InitItemList(tempo:FindChild("Grid"),v.ItemId)
  end
end

function BountyMatchRewardCtrl:InitItemList(grid,itemId)
  local itemOneData = UTGData.Instance().ItemsData[tostring(itemId)]
  local itemOne = self:CreateTransform(self.tempItem,grid)
  itemOne:FindChild("Equal").gameObject:SetActive(true)
  self:GetResourceParam(4,itemId)
  self:InitItem(itemOne:FindChild("Item"),itemId,"1","itemicon",itemOneData.Icon,itemOneData.Quality) 

  for i,v in ipairs(itemOneData.Param) do
    local itemOne = {} 
    if v[2] == 5 then --掉落包 
      local dropData = UTGData.Instance().DropGroupsData[tostring(v[1])].Drops[1]
      local num = dropData[2]
      for i=1,num do
        local itemType = dropData[3+(i-1)*4]
        local itemId = dropData[4+(i-1)*4]
        local param = self:GetResourceParam(itemType,itemId)
        local amountText = dropData[5+(i-1)*4].."~"..dropData[6+(i-1)*4]
        itemOne = self:CreateTransform(self.tempItem,grid)
        self:InitItem(itemOne:FindChild("Item"),param.Data.Id,amountText,param.IconAb,param.Icon,param.Bg)
        if i < num then 
          itemOne:FindChild("Add").gameObject:SetActive(true)
        end
      end
    else
      local amountText = ""..v[3]
      local itemType = v[2]
      local itemId = v[1]
      local param = self:GetResourceParam(itemType,itemId)
      itemOne = self:CreateTransform(self.tempItem,grid)
      self:InitItem(itemOne:FindChild("Item"),param.Data.Id,amountText,param.IconAb,param.Icon,param.Bg)
    end
    if i < #itemOneData.Param then 
      itemOne:FindChild("Add").gameObject:SetActive(true)
    end
  end
    
end


function BountyMatchRewardCtrl:GetResourceParam(itemType,id)
  itemType = tonumber(itemType)
  local param = {Type = "",Data = {},Bg = 1,Icon = "",IconAb = ""}
  if itemType == 4 then --item
    param.Type = "Item"
    param.Data = UTGData.Instance().ItemsData[tostring(id)]
    param.Bg = param.Data.Quality
    param.IconAb = "itemicon"
  elseif itemType == 2 then
    param.Type = "Skin"  
    param.Data = UTGData.Instance().SkinsData[tostring(id)]
    param.IconAb = "roleicon"
  elseif itemType == 6 then
    param.Type = "IconFrame"  
    param.Data = UTGData.Instance().AvatarFramesData[tostring(id)]
    param.IconAb = "frameicon"
  end
  param.Icon = param.Data.Icon
  self.itemUIData[tostring(id)] = param
  return param
end

function BountyMatchRewardCtrl:InitItem(temp,itemId,amountText,iconab,icon,bg)
  temp.parent.name = ""..itemId
  temp:FindChild("Bg"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("icon",bg)
  if iconab == "roleicon" then 
    temp:FindChild("Role").gameObject:SetActive(true)
    temp:FindChild("Icon").gameObject:SetActive(false)
    temp:FindChild("Role/Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite(iconab,icon)
  end
  temp:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite(iconab,icon)
  temp:FindChild("Text"):GetComponent("UnityEngine.UI.Text").text = amountText
  local listener = NTGEventTriggerProxy.Get(temp.parent:FindChild("Click").gameObject)
  listener.onPointerDown =NTGEventTriggerProxy.PointerEventDelegateSelf(self.DownTipReward,self)
  listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(self.UpTip,self)
end


function BountyMatchRewardCtrl:InitTip(data)
  self.tip:FindChild("Main/Name"):GetComponent("UnityEngine.UI.Text").text = data.Data.Name
  self.tip:FindChild("Desc"):GetComponent("UnityEngine.UI.Text").text = data.Data.Desc
  self.tip:FindChild("Main/Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite(data.IconAb,data.Icon)
end

--按下奖励物品tip
function BountyMatchRewardCtrl:DownTipReward(eventdata)
  local temp = eventdata.pointerEnter.transform
  local data = self.itemUIData[temp.parent.name]
  if data == nil then return end
  self:InitTip(data)
  self.tip.transform.position = temp.transform.position
  self.tip.gameObject:SetActive(true)
end
--抬起tip
function BountyMatchRewardCtrl:UpTip()
  self.tip.gameObject:SetActive(false)
end

function BountyMatchRewardCtrl:ClickClosePanel()
  Object.Destroy(self.this.transform.parent.gameObject)
end




function BountyMatchRewardCtrl:OnDestroy()
  self.this = nil
  self = nil
end