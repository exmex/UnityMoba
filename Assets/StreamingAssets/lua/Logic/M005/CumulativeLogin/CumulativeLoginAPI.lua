--author zx
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"

class("CumulativeLoginAPI")

local json = require "cjson"

function CumulativeLoginAPI:Awake(this)
  self.this = this
  CumulativeLoginAPI.Instance = self
  self.main = self.this.transforms[0]
  self.nowDayFx = self.this.transforms[1]
  self.tip = self.this.transforms[2]
  --self.ctrl = self.this.transforms[0]:GetComponent("NTGLuaScript")
  self:SetFxOk(self.main)

  self.deckData = UTGData.Instance().PlayerActivityDeck 
end

function CumulativeLoginAPI:Start()
  self:Init()
end

function CumulativeLoginAPI:Init()
  if self.deckData.IsSignInToday then self:ClosePanel() return end
  local listData = {}
  for k,v in pairs(UTGData.Instance().SignInsData) do
    local one = {}
    one.Day = v.Day
    one.Id = v.Reward.Id
    one.Type = v.Reward.Type
    one.Amount = v.Reward.Amount
    table.insert(listData,one)
  end
  local function SortByDay(a,b)
    return a.Day<b.Day
  end
  table.sort(listData,SortByDay)
  self.listData = listData

  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.main:FindChild("But_Get").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.GetReward,self)

  self.main:FindChild("Text_Time"):GetComponent("UnityEngine.UI.Text").text = "活动时间："..self.deckData.SignInTimeDesc
  self.main:FindChild("Text_Des"):GetComponent("UnityEngine.UI.Text").text = "活动期间累积登陆七天即可获得相对应奖励"
  self:InitGrid(listData,self.deckData.SignInDays+1)

end

function CumulativeLoginAPI:InitGrid(listData,nowDay)
  local grid = self.main:FindChild("Grid") 
  for i=1,#listData do
    local temp = grid:GetChild(i-1)
    local data = listData[i]
    local iconAb = ""
    local icon = ""
    local name = ""
    if data.Type == 1 then --hero
      iconAb = "roleicon"
    elseif data.Type == 2 then --skin
      iconAb = "roleicon"
    elseif data.Type == 3 then --rune
      iconAb = "runeicon"
    elseif data.Type == 4 then --item
      iconAb = "itemicon"
      local itemData = UTGData.Instance().ItemsData[tostring(data.Id)]
      if itemData == nil then Debugger.LogError(data.Id) end
      icon = itemData.Icon
      name = itemData.Name
    end
    temp:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite(iconAb,icon)
    temp:FindChild("Icon").gameObject:SetActive(true)
    if data.Amount>1 then
      temp:FindChild("Text_Amount"):GetComponent("UnityEngine.UI.Text").text = ""..data.Amount
    end
    temp:FindChild("Text_Name"):GetComponent("UnityEngine.UI.Text").text = name

    if i == nowDay and nowDay~=#listData then 
      temp:FindChild("Text_Day_Liang"):GetComponent("UnityEngine.UI.Text").text = string.format("第%d天",i)
      temp:FindChild("Liang").gameObject:SetActive(true)
      --Fx
      self.nowDayFx:SetParent(temp:FindChild("Fx"))
      self.nowDayFx.localPosition = Vector3.zero
      self.nowDayFx.gameObject:SetActive(true)
      self:SetFxOk(self.nowDayFx)
    else
      temp:FindChild("Text_Day"):GetComponent("UnityEngine.UI.Text").text = string.format("第%d天",i)
    end

    if i<nowDay then
      temp:FindChild("Over").gameObject:SetActive(true)
    else
      local downTemp = temp:FindChild("Down")
      downTemp.name = tostring(i)
      local listener = NTGEventTriggerProxy.Get(downTemp.gameObject)
      listener.onPointerDown =NTGEventTriggerProxy.PointerEventDelegateSelf(self.DownTipReward,self)
      listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(self.UpTip,self)
    end
  end
end

function CumulativeLoginAPI:InitTip(data)
  local itemData = UTGData.Instance().ItemsData[tostring(data.Id)]
  self.tip:FindChild("Main/Name"):GetComponent("UnityEngine.UI.Text").text = itemData.Name
  self.tip:FindChild("Desc"):GetComponent("UnityEngine.UI.Text").text = itemData.Desc
  self.tip:FindChild("Main/Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("itemicon",itemData.Icon)
end

--按下奖励物品tip
function CumulativeLoginAPI:DownTipReward(eventdata)
  local temp = eventdata.pointerEnter.transform
  local index = tonumber(temp.name)
  local data = self.listData[index]
  if data == nil then return end
  self:InitTip(data)
  self.tip.transform.position = temp.transform.position
  self.tip.gameObject:SetActive(true)
end
--抬起tip
function CumulativeLoginAPI:UpTip()
  self.tip.gameObject:SetActive(false)
end

function CumulativeLoginAPI:GetReward()
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestDrawSignInReward"))
  --request.Handler = TGNetService.NetEventHanlderSelf(StartGameController.RequestHandler, self)
  TGNetService.GetInstance():SendRequest(request)
  self:ClosePanel()
end


function CumulativeLoginAPI:RequestDrawSignInRewardHandler(e)

end

function StartGameController:RequestUpdateAccountServerHandler(e)
  if e.Type =="RequestUpdateAccountServer" then
    self:NetConnectServer(self.selectserver.Addr,tostring(self.selectserver.Port),StartGameController.NetConnectGameServerHandler)
    return true
  end
  return false
end

function CumulativeLoginAPI:ClosePanel()
  Object.Destroy(self.this.transform.gameObject)
  UTGDataOperator.Instance:CreatePanelAsync("Notice")
end


function CumulativeLoginAPI:SetFxOk(model)
  local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,btn.Length - 1 do
    model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
  end
end

function CumulativeLoginAPI:OnDestroy()
  self.this = nil
  CumulativeLoginAPI.Instance = nil
  self = nil
  NTGResourceController.Instance:UnloadAssetBundle("CumulativeLogin",true, false)
end