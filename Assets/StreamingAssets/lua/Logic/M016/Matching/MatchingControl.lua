require "System.Global"
require "Logic.UTGData.UTGData"
require "Logic.UTGData.UTGDataTemporary"


class("MatchingControl")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"
local json = require "cjson"

function MatchingControl:Awake(this)
  self.this = this
  self.matchingPanel = self.this.transforms[0]
  
  --预计匹配时间
  self.forecastTime = self.matchingPanel:Find("CountDownPanel/ForecastTime")
  
  --倒计时
  self.countDownTime = self.matchingPanel:Find("CountDownPanel/CountDownTime")
  
  --取消匹配
  self.cancelMatchingButton = self.matchingPanel:Find("CancelMatchingButton")
  self.cancelMatchingButton.gameObject:SetActive(true)
  self.button = self.matchingPanel:Find("Panel")

  --界面特效
  self.fx = self.matchingPanel:Find("CountDownPanel/R51140060")

  self.selfCancel = false

  self.dismissFlag = false
  
  local listener = NTGEventTriggerProxy.Get(self.cancelMatchingButton.gameObject)
  local callback = function(self, e)
    --print("FFFFFFFFFFFFFFFFFFFFFFFFF")
    self:CancelMatching()
    --self:Test()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)

  listener = NTGEventTriggerProxy.Get(self.button.gameObject)
  local callback = function(self, e)
    self:Notice()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback,self)

  self.RivalMatch = TGNetService.NetEventHanlderSelf(MatchingControl.EnemyMatchAction, self)
  TGNetService.GetInstance():AddEventHandler("NotifyRivalMatchResult", self.RivalMatch,1)

  self.NotifyPartyDismissedHandler = TGNetService.NetEventHanlderSelf(MatchingControl.OnNotifyPartyDismissedHandler, self)
  TGNetService.GetInstance():AddEventHandler("NotifyPartyDismissed", self.NotifyPartyDismissedHandler, 0)

  self.coroutines = {}
  
end

local json = require "cjson"


function MatchingControl:Start()
  local fxNum = self.fx:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for i = 0,fxNum.Length-1 do
    fxNum[i].material.shader = UnityEngine.Shader.Find(fxNum[i].material.shader.name)
  end
  --math.randomseed(os.time())
  --self:GetForecastTime(math.random(5,59))
  self:GetForecastTime(UTGDataOperator.Instance.matchTime)
  self:DoCountDown()
  
end

function MatchingControl:GetForecastTime(time)
  self.forecastTime:GetComponent(Text).text = "预计匹配时间 " .. string.format("%02d:%02d",0,time)
end

function MatchingControl:CountDown()
  self.time = 0
  UTGDataOperator.Instance.isMatching = true
  while(self.time < 99999) 
  do
    coroutine.wait(1)
    self.time = self.time + 1
    self.mTime = math.floor(self.time / 60)
    self.sTime = self.time - self.mTime * 60
    self.countDownTime:GetComponent(Text).text = string.format("%02d : %02d",self.mTime,self.sTime)
  end  
end

function MatchingControl:DoCountDown()
  table.insert(self.coroutines,coroutine.start(MatchingControl.CountDown,self))
end


function MatchingControl:CancelMatching()
  self.dismissFlag = true
  local cancelMatchingRequest = NetRequest.New()
  cancelMatchingRequest.Content = JObject.New(JProperty.New("Type","RequestCancelMatch"))
  cancelMatchingRequest.Handler = TGNetService.NetEventHanlderSelf(MatchingControl.CancelMatchingHandler,self)
  TGNetService.GetInstance():SendRequest(cancelMatchingRequest)
end

function MatchingControl:CancelMatchingHandler(e)
  if e.Type == "RequestCancelMatch" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      self.selfCancel = true
      --self.this:StopAllCoroutines()
      --self:LeaveParty()
      self:DestroySelf()
    else 
      --print("GGGGGGGGGGGGGGGGGGGGGGGG")
    end
    return true
  end
  return false
end

function MatchingControl:LeaveParty()
  local leavePartyRequest = NetRequest.New()
  leavePartyRequest.Content = JObject.New(JProperty.New("Type","RequestLeaveParty"))
  leavePartyRequest.Handler = TGNetService.NetEventHanlderSelf(MatchingControl.LeavePartyHandler,self)
  TGNetService.GetInstance():SendRequest(leavePartyRequest)
end

function MatchingControl:LeavePartyHandler(e)
  if e.Type == "RequestLeaveParty" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then

    else 
      --print("GGGGGGGGGGGGGGGGGGGGGGGG")
    end
    return true
  end
  return false
end

function MatchingControl:CancelButtonControl(memNum)
  
  if memNum == nil then
    memNum = 0
  end
   
  if memNum == 1 then 
    --print("********************************")
    self.cancelMatchingButton.gameObject:SetActive(false)
  end  
end

function MatchingControl:EnemyMatchAction(e)
  if e.Type == "NotifyRivalMatchResult" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      self.cancelMatchingButton.gameObject:SetActive(false)
      local teamParties = json.decode(e.Content:get_Item("TeamParties"):ToString())
      local rivalParties = json.decode(e.Content:get_Item("RivalParties"):ToString())
      self.Seconds = tonumber(e.Content:get_Item("Seconds"):ToString())      
                        
      self:GoToMainPanelUI(teamParties,rivalParties,self.Seconds)
            
    end
    return true
  end
  return false  
end

function MatchingControl:GoToMainPanelUI(teamParties,rivalParties,seconds)
  coroutine.start(MatchingControl.WaitForCreatePanel, self,teamParties,rivalParties,seconds)
end

function MatchingControl:WaitForCreatePanel(teamParties,rivalParties,seconds)
  
  local async = GameManager.CreatePanelAsync("NewBattle17")
  while async.Done == false do
    coroutine.step()
  end
  if NewBattle17API.Instance ~= nil then
    NewBattle17API.Instance:Init(teamParties,rivalParties,seconds)
  end

  self.this:StopAllCoroutines()
  MatchingAPI.Instance:DestroySelf()
end

function MatchingControl:Notice()
  -- body
  coroutine.start(MatchingControl.WaitForCreateNotice,self)
end

function MatchingControl:WaitForCreateNotice()
  
  local async = GameManager.CreatePanelAsync("SelfHideNotice")
  while async.Done == false do
    coroutine.step()
  end
  
  if SelfHideNoticeAPI.Instance ~= nil then
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("您正处于匹配队列中")
  end
end

function MatchingControl:OnNotifyPartyDismissedHandler(e)
  --Debugger.LogError("收到Party解散通知")
  if e.Type == "NotifyPartyDismissed" then
    
    if self.dismissFlag == false then
      GameManager.CreatePanel("SelfHideNotice")
      if SelfHideNoticeAPI~= nil and SelfHideNoticeAPI.Instance~= nil then
        SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("队伍解散")
      end
    end

    if MatchingAPI ~= nil and MatchingAPI.Instance ~= nil then MatchingAPI.Instance:DestroySelf() end
  end
  return true
end

function MatchingControl:DestroySelf()
  -- body
  if self.this ~= nil then
    GameObject.Destroy(self.this.transform.parent.gameObject)
  end
end


function MatchingControl:Test()
  MatchingAPI.Instance:DestroySelf()
end

function MatchingControl:OnDestroy()
  TGNetService.GetInstance():RemoveEventHander("NotifyRivalMatchResult", self.RivalMatch)
  TGNetService.GetInstance():RemoveEventHander("NotifyPartyDismissed", self.NotifyPartyDismissedHandler)
  for i = 1,#self.coroutines do
    coroutine.stop(self.coroutines[i])
  end
  self.this = nil
  self = nil
end




