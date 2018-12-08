--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
class("PVPHeroSelectRuneCtrl")

local json = require "cjson"

function PVPHeroSelectRuneCtrl:Awake(this)
  self.this = this
  self.runeList = this.transform:FindChild("List")
  self.runeListGrid = self.runeList:FindChild("Scroll/Grid")
  self.runeNow = this.transform:FindChild("Now")
  self.tip = this.transform:FindChild("Tip")


end

function PVPHeroSelectRuneCtrl:Start()
  
end

--------对外接口--------

function PVPHeroSelectRuneCtrl:SendRunePageId(id)
  id = tonumber(id)
  if PVPHeroSelectAPI~=nil and PVPHeroSelectAPI.Instance~=nil then
    PVPHeroSelectAPI.Instance:SendSelectRunePageId(id)
  end
  if DraftHeroSelectAPI~=nil and DraftHeroSelectAPI.Instance~=nil then
    DraftHeroSelectAPI.Instance:SendSelectRunePageId(id)
  end
  
end

function PVPHeroSelectRuneCtrl:SetRunePageId(id)
  for i=1,#self.runePagesData do
    if id == self.runePagesData[i].Id then 
      self.selectRunePageId = self.runePagesData[i].Id
      self:ShowNowRune(self.runePagesData[i])
      return
    end
  end
end

function PVPHeroSelectRuneCtrl:GetDefaultRunePageId()
  return self.runePagesData[1].Id
end
----------------------

function PVPHeroSelectRuneCtrl:Init( )
  --芯片
  listener = NTGEventTriggerProxy.Get(self.this.transform:FindChild("But_Tip").gameObject)--查看芯片信息
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf(self.DownRuneTip,self)
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf(self.UpRuneTip,self)
  listener = NTGEventTriggerProxy.Get(self.this.transform:FindChild("But_List").gameObject)--打开芯片列表
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickRuneList,self)

  self:InitRunePageData()
    self.runeList.gameObject:SetActive(true)
  self:FillRuneList(self.runePagesData)
  self.runeList.gameObject:SetActive(false)
end

--显示芯片组
function PVPHeroSelectRuneCtrl:ShowNowRune(defaultrune)
  self.runeNow:FindChild("Num"):GetComponent("UnityEngine.UI.Text").text = defaultrune.AllLevel
  self.runeNow:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = defaultrune.Name
end

--初始化芯片组数据
function PVPHeroSelectRuneCtrl:InitRunePageData()
  self.runePagesData = {}
  
  for k,v in pairs(UTGData.Instance().RunePagesDeck) do
    local pagedata = {}
    pagedata.Id = v.Id
    pagedata.Name = v.Name
    pagedata.AllLevel = 0  
    local runesData = {}
    for k,v in pairs(UTGData.Instance().RuneSlotsDeck) do
      if v.RunePageDeckId == pagedata.Id and v.RuneId>0 then 
        local runedata = UTGData.Instance().RunesData[tostring(v.RuneId)]
        table.insert(runesData,runedata)
      end
    end
    for i=1,#runesData do
      pagedata.AllLevel =pagedata.AllLevel+runesData[i].Level  
    end
    --Debugger.LogError(pagedata.Id,pagedata.Name)
    table.insert(self.runePagesData,pagedata)
  end
  local function pagesortfunc(a,b)
      return a.Id < b.Id
  end
  table.sort(self.runePagesData,pagesortfunc)
  --[[
  for k,v in pairs(self.runePagesData) do
    Debugger.LogError(k.."  "..v.Id.."  "..v.Name)
  end
  ]]
end

--打开或者关闭芯片列表
function PVPHeroSelectRuneCtrl:ClickRuneList()
  if self.runeList.gameObject.activeSelf then 
   self.runeList.gameObject:SetActive(false)
  else
    self.runeList.gameObject:SetActive(true)
  end
end

--生成芯片组
function PVPHeroSelectRuneCtrl:FillRuneList(data)

  local api =self.runeListGrid:GetComponent("NTGLuaScript").self
  if data==nil then
    api:ResetItemsSimple(0)
    return
  end
  api:ResetItemsSimple(#data)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform
    tempo.name = tostring(i)    
    tempo:FindChild("Num"):GetComponent("UnityEngine.UI.Text").text = data[i].AllLevel
    tempo:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = data[i].Name

    UITools.GetLuaScript(tempo.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickSelectRune,data[i].Id)
  end
end

--选中芯片
function PVPHeroSelectRuneCtrl:ClickSelectRune(id)
  if self.selectRunePageId ~= id then 
    self:SendRunePageId(id)
  end
  self.runeList.gameObject:SetActive(false)
end

--生成芯片加成的信息
function PVPHeroSelectRuneCtrl:GetRuneTipData(id)
   local runePageId  = tonumber(id)
   local useData = {}
   local runesData = {}
    for k,v in pairs(UTGData.Instance().RuneSlotsDeck) do
      if v.RunePageDeckId == runePageId and v.RuneId>0 then 
        local runedata = UTGData.Instance().RunesData[tostring(v.RuneId)]
        table.insert(runesData,runedata)
      end
    end
    local allAttr = {}
    for i=1,#runesData do
      local runeAttrs = {}
      runeAttrs = runesData[i].PVPAttr

      for k,v in pairs(runeAttrs) do
        local temp = UTGDataOperator.Instance:GetTemplateAttrCHSNameByKey(k)
        if temp~=nil and v>0 then
          local des = temp[1]
          local kkk = tostring(temp[2])
          local order = temp[2]
          if allAttr[kkk] ~=nil then
            allAttr[kkk].Attr = allAttr[kkk].Attr+v
          else
            allAttr[kkk] = {}
            allAttr[kkk].Des = des
            allAttr[kkk].Order = order
            allAttr[kkk].Attr = v
          end
        end 
      end
    end

    for k,v in pairs(allAttr) do
      table.insert(useData,v)
    end

    local function sortfunc(a,b)
      return a.Order < b.Order
    end
    table.sort(useData,sortfunc)
    --[[
    for i=1,#useData do
      print("i= "..i.." Des="..useData[i].Des.." Attr="..useData[i].Attr.." Order="..useData[i].Order)
    end
    ]]
    return useData
end 
--查看芯片信息
function PVPHeroSelectRuneCtrl:DownRuneTip()
  self.tip.gameObject:SetActive(true)
  --31FA65FF
  local data = self:GetRuneTipData(self.selectRunePageId) 
  local api = self.tip:FindChild("Grid"):GetComponent("NTGLuaScript").self
  if api ==nil or data==nil then Debugger.LogError("芯片数据 or API 为Nil 无法显示Tip") end
  api:ResetItemsSimple(#data)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform   
    tempo.name = tostring(i)
    if data[i].Attr <0.1 then
      tempo:FindChild("Des"):GetComponent("UnityEngine.UI.Text").text = data[i].Des.." <color=#31FA65FF>+"..(data[i].Attr*100).."%".."</color>"
    else
      tempo:FindChild("Des"):GetComponent("UnityEngine.UI.Text").text = data[i].Des.." <color=#31FA65FF>+"..data[i].Attr.."".."</color>"
    end
  end
end

function PVPHeroSelectRuneCtrl:UpRuneTip()
  self.tip.gameObject:SetActive(false)
end


function PVPHeroSelectRuneCtrl:OnDestroy()
  self.this = nil
  self = nil
end