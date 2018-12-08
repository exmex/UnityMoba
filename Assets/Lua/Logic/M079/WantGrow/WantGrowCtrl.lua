require "System.Global"
require "Logic.UTGData.UTGData"

local json = require "cjson"

class("WantGrowCtrl")

function WantGrowCtrl:Awake(this) 
  self.this = this
  self.Top = this.transforms[0]
  self.Middle = this.transforms[1]
  self.Grid_List = self.Middle:FindChild("ScrollView/Grid")
  self.Bottom = this.transforms[2]
  self.Tip = this.transforms[3]
  self.Tip.gameObject:SetActive(false)
  self.vec2_exp = self.Top:FindChild("Exp"):GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta

  self.growUpChestData = UTGData.Instance().GrowUpChestsData
  self.growUpData = UTGData.Instance().GrowUpsData
  self.playerData = UTGData.Instance().PlayerData
  self.growUpDeck = UTGData.Instance().PlayerGrowUpDeck
  self.listData = {}
end 

function WantGrowCtrl:Start()
  self:Init()
end

function WantGrowCtrl:Init()
  self:InitChestData()
  self.growUpData_list = self:InitGrowUpData()
  self:InitList(self.growUpData_list)
  self:InitTop()
  self:InitBottom()
  self:UpdateData()
end
function WantGrowCtrl:UpdateData()
  --Debugger.LogError("aaaaaaaa"..self.playerData.WeeklyActivePoint.." "..self.playerData.DailyActivePoint)
  
  self.playerData = UTGData.Instance().PlayerData
  self.growUpDeck = UTGData.Instance().PlayerGrowUpDeck
  self:UpdateTop(self.playerData.DailyActivePoint,self.playerData.DailyOpenedGrowUpChestIds)
  self:UpdateBottom(self.playerData.WeeklyActivePoint,self.playerData.WeeklyOpenedGrowUpChestIds)
  self:InitListData()
  self:UpdateList(self.listData)
end

--初始化活跃任务数据
function WantGrowCtrl:InitGrowUpData()
  local data = {}
  for k,v in pairs(self.growUpData) do
    table.insert(data,v) 
  end
  local function Sort(a,b)
    return a.Id<b.Id
  end
  table.sort(data,Sort)
  return data
end
--初始化deck数据
function WantGrowCtrl:InitListData()
  self.listData = {}
  for k,v in pairs(self.growUpDeck) do
    --Debugger.LogError(k.." "..v.Progress)
    table.insert(self.listData,v) 
  end
  local function Sort(a,b)
    if a.IsDrew == b.IsDrew then 
      return a.Id<b.Id
    end
    if a.IsDrew then return false end
    return true
  end
  table.sort(self.listData,Sort)
end

--初始化宝箱数据
function WantGrowCtrl:InitChestData()
  local chestdata_day = {}
  local chestdata_week = {}
  for k,v in pairs(self.growUpChestData) do
    if v.Type == 1 then --日活跃
      table.insert(chestdata_day,v)
    end
    if v.Type == 2 then --周活跃
      table.insert(chestdata_week,v)
    end
  end
  local function Sort(a,b)
    return a.ActivePoint < b.ActivePoint
  end
  table.sort(chestdata_day,Sort)
  table.sort(chestdata_week,Sort)

  self.chestdata_day = chestdata_day
  self.chestdata_week = chestdata_week
end

--初始化Top
function WantGrowCtrl:InitTop( )
  local grid = self.Top:FindChild("Grid")
  local api = grid:GetComponent("NTGLuaScript").self
  api:ResetItemsSimple(#self.chestdata_day)
  for i=1,#api.itemList do
    local temp = api.itemList[i].transform
    self:InitChest(temp,self.chestdata_day[i])
  end
  self.max_dayhuoyue = self.chestdata_day[#self.chestdata_day].ActivePoint
end
--初始化宝箱
function WantGrowCtrl:InitChest(temp,data)
  local listener = {}
  temp.name = ""..data.Id
  temp:FindChild("Text"):GetComponent("UnityEngine.UI.Text").text = ""..data.ActivePoint
  local icon = UTGData.Instance().ItemsData[tostring(data.RewardId)].Icon 
  temp:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("itemicon",tostring(icon),"UnityEngine.Sprite")
  temp:FindChild("Over").gameObject:SetActive(false)
  temp:FindChild("Fx").gameObject:SetActive(false)
  listener = NTGEventTriggerProxy.Get(temp.gameObject)
  listener.onPointerDown =NTGEventTriggerProxy.PointerEventDelegateSelf(self.DownTipChest,self)
  listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(self.UpTip,self)
end
--更新宝箱状态 state 0:未领取 1:已领取 2:可以领取
function WantGrowCtrl:UpdateChest(temp,state)
  --Debugger.LogError(temp.name.." "..state)
  local ani = temp:FindChild("Icon"):GetComponent("Animator")
  ani.enabled = false
  temp:FindChild("Over").gameObject:SetActive(false)
  temp:FindChild("Fx").gameObject:SetActive(false)
  if state == 0 then 
    
  elseif state == 1 then 
    temp:FindChild("Over").gameObject:SetActive(true)
  elseif state == 2 then 
    ani.enabled = true
    temp:FindChild("Fx").gameObject:SetActive(true)
    local model = temp:FindChild("Fx")
    local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    for k = 0,btn.Length - 1 do
      model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
    end
  end
  
end
--更新Top
function WantGrowCtrl:UpdateTop(duoyue,openids)
  local percent = duoyue/self.max_dayhuoyue
  self.Top:FindChild("Txt_Today"):GetComponent("UnityEngine.UI.Text").text = duoyue
  local nowVec2 = Vector2.New(percent*self.vec2_exp.x,self.vec2_exp.y)
  self.Top:FindChild("Exp"):GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = nowVec2
  local grid = self.Top:FindChild("Grid")
  for i=1,grid.childCount do
    local temp = grid:GetChild(tostring(i-1))
    --Debugger.LogError(temp.name)
    if self:IsOpenChest(temp.name,openids) == true then
      self:UpdateChest(temp,1) 
    elseif duoyue>= self.growUpChestData[temp.name].ActivePoint then
      self:UpdateChest(temp,2) 
    end
  end
end
--初始化bottom
function WantGrowCtrl:InitBottom()
  local grid = self.Bottom:FindChild("Grid")
  for i=1,grid.childCount do
    local temp = grid:GetChild(i-1).transform
    self:InitChest(temp,self.chestdata_week[i])
  end
  self.max_weekhuoyue = self.chestdata_week[#self.chestdata_week].ActivePoint
end
--更新Bottom 
function WantGrowCtrl:UpdateBottom(duoyue,openids)
  local percent = duoyue/self.max_weekhuoyue
  self.Bottom:FindChild("Txt_Week"):GetComponent("UnityEngine.UI.Text").text = duoyue
  local grid = self.Bottom:FindChild("Grid")
  for i=1,grid.childCount do
    local temp = grid:GetChild(tostring(i-1))
    if self:IsOpenChest(temp.name,openids) == true then
      self:UpdateChest(temp,1) 
    elseif duoyue>= self.growUpChestData[temp.name].ActivePoint then
      self:UpdateChest(temp,2) 
    end
  end
end

--宝箱是否已领取 
function WantGrowCtrl:IsOpenChest(id,openids)
  for k,v in pairs(openids) do
    if tonumber(id) == v then return true end
  end
  return false
end

--按下奖励物品tip
function WantGrowCtrl:DownTipReward(eventdata)
  local temp = eventdata.pointerEnter.transform.parent
  local data = UTGData.Instance().ItemsData[temp.name]
  if data == nil then return end
  self:InitTip(data)
  self.Tip.transform.position = temp:FindChild("Click/Tip").transform.position
  self.Tip.gameObject:SetActive(true)
end
--按下宝箱tip
function WantGrowCtrl:DownTipChest(eventdata)
  local temp = eventdata.pointerEnter.transform
  --Debugger.LogError(temp.name)
  local chestdata = self.growUpChestData[temp.name]
  if chestdata == nil then return end
  if temp:FindChild("Over").gameObject.activeSelf then 
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("奖励已领取")
    return
  end
  if temp:FindChild("Fx").gameObject.activeSelf then 
    self:RequestOpenGrowUpChest(chestdata.Id)
    return
  end
  local rewardId = chestdata.RewardId
  local data = UTGData.Instance().ItemsData[tostring(rewardId)]
  self:InitTip(data)
  self.Tip.transform.position = temp:FindChild("Tip").transform.position
  self.Tip.gameObject:SetActive(true)
end
function WantGrowCtrl:InitTip(data)
  self.Tip:FindChild("Main/Name"):GetComponent("UnityEngine.UI.Text").text = data.Name
  self.Tip:FindChild("Desc"):GetComponent("UnityEngine.UI.Text").text = data.Desc
  self.Tip:FindChild("Main/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("itemicon",tostring(data.Icon),"UnityEngine.Sprite")
end
--抬起tip
function WantGrowCtrl:UpTip()
  self.Tip.gameObject:SetActive(false)
end

--初始化列表
function WantGrowCtrl:InitList(data)
  local api = self.Grid_List:GetComponent("NTGLuaScript").self
  if data==nil then
    api:ResetItemsSimple(0)
    Debugger.LogError("没有数据")
    return
  end
  api:ResetItemsSimple(#data)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform
    local growdata = data[i]
    tempo.name = ""..growdata.Id
    tempo:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = growdata.Title
    tempo:FindChild("Desc"):GetComponent("UnityEngine.UI.Text").text = growdata.Desc
    tempo:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("growupicon",tostring(growdata.Icon),"UnityEngine.Sprite")

    UITools.GetLuaScript(tempo:FindChild("But_Get").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickGetReward,growdata.Id)
    tempo:FindChild("But_Get").gameObject:SetActive(false)
    tempo:FindChild("But_Go").gameObject:SetActive(false)
    if growdata.SourceId>0 then
      UITools.GetLuaScript(tempo:FindChild("But_Go").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickGo,growdata.SourceId)
      tempo:FindChild("But_Go").gameObject:SetActive(true)
    end
    tempo:FindChild("Jindu").gameObject:SetActive(true)
    tempo:FindChild("Jindu/Jindu"):GetComponent("UnityEngine.UI.Text").text = string.format("%s/%s",0,growdata.MaxProgress)
    --奖励
    self:InitReward(tempo:FindChild("Grid"),growdata.Rewards)
  end

end
--初始化获得奖励
function WantGrowCtrl:InitReward(grid,data)
  local api = grid:GetComponent("NTGLuaScript").self
  if data==nil then
    api:ResetItemsSimple(0)
    Debugger.LogError("没有数据")
    return
  end
  local listener = {}
  api:ResetItemsSimple(#data)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform
    tempo.name = data[i].Id
    tempo:FindChild("Text"):GetComponent("UnityEngine.UI.Text").text = "X"..data[i].Amount
    local icon = UTGData.Instance().ItemsData[tostring(data[i].Id)].Icon 
    tempo:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("itemicon",tostring(icon),"UnityEngine.Sprite")
    listener = NTGEventTriggerProxy.Get(tempo:FindChild("Click").gameObject)
    listener.onPointerDown =NTGEventTriggerProxy.PointerEventDelegateSelf(self.DownTipReward,self)
    listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(self.UpTip,self)
  end
end

--刷新列表
function WantGrowCtrl:UpdateList(data)
  local index_forward = 0
  for i=1,#data do
    --Debugger.LogError(data[i].GrowUpId.." "..data[i].Progress)
    local tempo = self.Grid_List:FindChild(tostring(data[i].GrowUpId))
    if tempo ~= nil then 
      local growdata = self.growUpData[tostring(data[i].GrowUpId)]
      tempo:FindChild("But_Get").gameObject:SetActive(false)
      tempo:FindChild("But_Go").gameObject:SetActive(false)
      tempo:FindChild("Jindu").gameObject:SetActive(false)
      tempo:FindChild("Complete").gameObject:SetActive(false)
      if data[i].IsDrew == true then --已领取
        --Debugger.LogError("ddddd "..data[i].GrowUpId.." "..data[i].Progress)
        tempo:FindChild("Complete").gameObject:SetActive(true)
        tempo.transform:SetAsLastSibling()

      elseif data[i].Progress >= growdata.MaxProgress then --完成
        tempo:FindChild("But_Get").gameObject:SetActive(true)
        tempo:SetSiblingIndex(index_forward)
        index_forward = index_forward + 1
      else
        if growdata.SourceId>0 then tempo:FindChild("But_Go").gameObject:SetActive(true) end
        tempo:FindChild("Jindu").gameObject:SetActive(true)
        tempo:FindChild("Jindu/Jindu"):GetComponent("UnityEngine.UI.Text").text = string.format("%s/%s",data[i].Progress,growdata.MaxProgress)
      end
    end
  end
end

--领取奖励
function WantGrowCtrl:ClickGetReward(growupid)
  self:RequestDrawGrowUp(growupid)
end

          
--前往
function WantGrowCtrl:ClickGo(sourceid)
  local data = UTGData.Instance().SourcesData[tostring(sourceid)]
  if data == nil then return end
  local panelName = data.UIName
  local param = data.UIParam[1]
  self:GoToPanel(panelName,param)
end

function WantGrowCtrl:GoToPanel(name,param)
  param = param or {}
  coroutine.start(self.GoToPanelMov,self, name,param)
end
function WantGrowCtrl:GoToPanelMov(name,param)
  GameManager.CreatePanel("Waiting")
  local async = GameManager.CreatePanelAsync(tostring(name))
  while async.Done == false do
    coroutine.wait(0.05)
  end
  GrowGuideAPI.Instance:HideSelf()
  WaitingPanelAPI.Instance:DestroySelf()
  if StoreCtrl~=nil and StoreCtrl.Instance~=nil then 
    --Debugger.LogError(tonumber(param))
    StoreCtrl.Instance:GoToUI(tonumber(param))
  end
end


function WantGrowCtrl:OpenMainPanel()
  self.Main.gameObject:SetActive(true)
end


--打开宝箱
function WantGrowCtrl:RequestOpenGrowUpChest(id)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestOpenGrowUpChest"),
                                JProperty.New("GrowUpChestId",tonumber(id)))
  request.Handler = TGNetService.NetEventHanlderSelf(WantGrowCtrl.RequestHandler,self )
  TGNetService.GetInstance():SendRequest(request)
end
--领取奖励
function WantGrowCtrl:RequestDrawGrowUp(id)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestDrawGrowUp"),
                                JProperty.New("GrowUpId",tonumber(id)))
  request.Handler = TGNetService.NetEventHanlderSelf(WantGrowCtrl.RequestHandler,self )
  TGNetService.GetInstance():SendRequest(request)
end
function WantGrowCtrl:RequestHandler(e)
  if e.Type =="RequestOpenGrowUpChest" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      print("RequestOpenGrowUpChest result == 0")
    elseif result == 1 then
      --self:UpdateData()
    end
    return true
  end
  if e.Type =="RequestDrawGrowUp" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      print("RequestDrawGrowUp 失败")
    elseif result == 1 then
      --self:UpdateData()
    end
    return true
  end
  return false
end


function WantGrowCtrl:OnDestroy()
  self.this = nil
  self = nil
end