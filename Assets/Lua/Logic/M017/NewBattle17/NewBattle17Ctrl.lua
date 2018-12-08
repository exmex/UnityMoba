require "System.Global"
require "Logic.UTGData.UTGData"
class("NewBattle17Ctrl")

local json = require "cjson"

function NewBattle17Ctrl:Awake(this)
  self.this = this
  self.ourTeamRoot = this.transforms[0]
  self.otherTeamRoot = this.transforms[1]
  self.picTemp = this.transforms[2]
  self.goToGameBtn = this.transforms[3]:GetComponent("UnityEngine.UI.Button")
  self.successfulTxt = this.transforms[4]
  self.countHint = this.transforms[5]:GetComponent("UnityEngine.UI.Text")
  self.timer = this.transforms[6]:GetComponent("UnityEngine.UI.Text")

  self.alReadyPlayers = {}
  
  self.MatchResultHandler = TGNetService.NetEventHanlderSelf(NewBattle17Ctrl.OnMatchResultHandler,self)
  TGNetService.GetInstance():AddEventHandler("NotifyBattleMatchResult", self.MatchResultHandler, 0)

  self.PlayerReadyHandler = TGNetService.NetEventHanlderSelf(NewBattle17Ctrl.OnPlayerReadyHandler,self)
  TGNetService.GetInstance():AddEventHandler("NotifyConfirmMatchChange", self.PlayerReadyHandler, 0)
  
  --征召数据 - 临时存储
  self.NotifyBattleDraftChangeHandler = TGNetService.NetEventHanlderSelf(self.OnNotifyBattleDraftChangeHandler,self)
  TGNetService.GetInstance():AddEventHandler("NotifyBattleDraftChange", self.NotifyBattleDraftChangeHandler, 0)
  self.NotifyPartyChangeHandler = TGNetService.NetEventHanlderSelf(self.OnNotifyPartyChangeHandler,self)
  TGNetService.GetInstance():AddEventHandler("NotifyPartyChange", self.NotifyPartyChangeHandler, 0)

  local listener = NTGEventTriggerProxy.Get(self.goToGameBtn.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(NewBattle17Ctrl.OnGoToGameBtnClick,self)

end

function NewBattle17Ctrl:Start()

end 

function NewBattle17Ctrl:Init(teamParties,rivalParties,timer) 
  self.players = {}
  self.maxCount = 0
  self.readyCount = 0
  self.timer.text = tostring(timer)
  
  self.co_countdown = coroutine.start(NewBattle17Ctrl.CountDown,self,timer)

  local selfParty = {}
  for i = 1,#teamParties do
    for k,v in pairs(teamParties[i].Members) do 
      if v.PlayerId ~= 0 then
        table.insert(selfParty,v)
      end
    end
  end

  local enemyParty = {}
  for i = 1,#rivalParties do
    for k,v in pairs(rivalParties[i].Members) do 
      if v.PlayerId ~= 0 then
        table.insert(enemyParty,v)
      end
    end
  end

  print("enemyParty " .. #enemyParty)

  for k,v in pairs(selfParty) do
    --Debugger.LogError("自己队伍玩家ID为："..v.PlayerId)
    self.maxCount = self.maxCount + 1    
    local go = GameObject.Instantiate(self.picTemp.gameObject)
    go.transform:SetParent(self.ourTeamRoot)
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
    go.transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("roleicon",v.PlayerIcon)
    go:SetActive(true)
    table.insert(self.players, {[v.PlayerId] = go})
    if v.Confirmed then
      
      go.transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").color = Color.white
      go.transform:FindChild("Ready").gameObject:SetActive(true)
      self.readyCount = self.readyCount + 1
    end
  end

  if UTGDataOperator.Instance.battleMode == 2 then
    self.ourTeamRoot.localPosition = Vector3.New(0,0,0)
  end

  for i=1,self.otherTeamRoot.childCount - 1 do
    if self.otherTeamRoot.childCount > 1 then
      if self.co_countdown~=nil then
        print("删除coroutine") 
        coroutine.stop(self.co_countdown) 
      end 
      GameObject.Destroy(self.otherTeamRoot:GetChild(i).gameObject) 
    end
  end
  
  for k,v in pairs(enemyParty) do
    --Debugger.LogError("对方队伍玩家ID为："..v.PlayerId .. " " .. v.PlayerName .. " " .. tostring(IsAi))
    self.maxCount = self.maxCount + 1    
    local go = GameObject.Instantiate(self.picTemp.gameObject)
    go.transform:SetParent(self.otherTeamRoot)
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
    go.transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("roleicon",v.PlayerIcon)
    go:SetActive(true)
    table.insert(self.players, {[v.PlayerId] = go})
    if v.Confirmed then
      go.transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").color = Color.white
      go.transform:FindChild("Ready").gameObject:SetActive(true)
      self.readyCount = self.readyCount + 1
    end
  end
  
  self.picTemp.gameObject:SetActive(false)
  
  self.countHint.text = tostring(self.readyCount).."/"..tostring(self.maxCount)
  
  self.canClick = true
end

function NewBattle17Ctrl:OnGoToGameBtnClick()
  --Debugger.LogError("发送确认战斗消息")
  if self.canClick == false then return end
  local requestConfirmMatch = NetRequest.New()
  requestConfirmMatch.Content = JObject.New(JProperty.New("Type","RequestConfirmMatch"))
  requestConfirmMatch.Handler = TGNetService.NetEventHanlderSelf(NewBattle17Ctrl.RequestConfirmMatchHandler,self)
  TGNetService.GetInstance():SendRequest(requestConfirmMatch)
end

function NewBattle17Ctrl:RequestConfirmMatchHandler(e)
  if e.Type == "RequestConfirmMatch" then   
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then 
      --Debugger.LogError("确认进入战斗成功")
      self.canClick = false
      self.goToGameBtn.interactable = false
    end 
  end
  return true
end

function NewBattle17Ctrl:OnPlayerReadyHandler(e)
  if e.Type == "NotifyConfirmMatchChange" then    
    ----Debugger.LogString("OnPlayerReady")
    local playerId = tonumber(e.Content:get_Item("Affirmant"):ToString())
    --Debugger.LogError("playerId =="..playerId)
    for k,v in pairs(self.players) do
      --print("k,v " .. k)

      if not(v[playerId]  == nil) and self:IsContains(self.alReadyPlayers, playerId) == false then
        self:DoReady(v[playerId])
        table.insert(self.alReadyPlayers, playerId)
      end
    end  
    return true
  end
  
  return true
end

function NewBattle17Ctrl:OnMatchResultHandler(e)
  --Debugger.LogError("收到匹配结果通知")
  if e.Type == "NotifyBattleMatchResult" then    
    --Debugger.LogError("OnMatchResult")
    local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then
        local seconds = tonumber(e.Content:get_Item("Seconds"):ToString())
        local mainType = tonumber(e.Content:get_Item("BMainType"):ToString())
        local subType = tonumber(e.Content:get_Item("BSubType"):ToString())
        local teamB = json.decode(e.Content:get_Item("TeamB"):ToString()) 
        local teamA = json.decode(e.Content:get_Item("TeamA"):ToString()) 
        if teamB==nil or teamA==nil then
          --Debugger.LogError("没有party数据")
        end
        
        local selfplayerid = UTGData.Instance().PlayerData.Id
        local isOwnParty = false
        local selfPartyId = 0
        for i=1,#teamB.Members do
          if teamB.Members[i].PlayerId == selfplayerid then
            isOwnParty = true 
            break
          end        
        end
        local selfPartyData = {}
        if isOwnParty == true then
          selfPartyData = teamB
          selfPartyId = teamB.Id
        else 
          selfPartyData = teamA
          selfPartyId = teamA.Id
        end
        
          
        --Debugger.LogError("匹配准备成功")
        if subType ~= 66 then 
          self:GoToHeroSelect(mainType, subType, seconds,selfPartyData)
        end
      elseif result == 5 or result == 4 then
        self:ReMatch()
      elseif result == 2 or result == 3 then
        self:LeaveMatch(result)
      end
    return true
  end
  return true
end

--点亮界面重新进入匹配状态
function NewBattle17Ctrl:ReMatch()
  GameManager.CreatePanel("Matching")
  if needOther == false and MatchingAPI ~= nil and MatchingAPI.Instance ~= nil then
    MatchingAPI.Instance:CancelButtonControl(0) 
  end
  if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
    UTGMainPanelAPI.Instance:ShowSelf()
    if self.co_countdown~=nil then
      print("删除coroutine") 
      coroutine.stop(self.co_countdown) 
    end
    self:DestroySelf()
  end
end

--离开匹配并提示
function NewBattle17Ctrl:LeaveMatch(result)

  if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
    UTGMainPanelAPI.Instance:ShowSelf()
  end

  local function CreatePanelAsync()
    local async = GameManager.CreatePanelAsync("SelfHideNotice")
    while async.Done == false do
      coroutine.step()
    end
    if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
      local msg = ""
      if result == 2 then msg = "您未确认游戏，您已离开匹配回到大厅" end
      if result == 3 then msg = "队伍中有人未确认游戏，您已离开匹配回到大厅" end
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice(msg)
      if self.co_countdown~=nil then
        print("删除coroutine") 
        coroutine.stop(self.co_countdown) 
      end 
      self:DestroySelf()
    end
  end
  coroutine.start(CreatePanelAsync,self)
end

function NewBattle17Ctrl:DoReady(go)
  go.transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").color = Color.white
  go.transform:FindChild("Ready").gameObject:SetActive(true)
  self.readyCount = self.readyCount + 1
  
  self.countHint.text = tostring(self.readyCount).."/"..tostring(self.maxCount)
end

function NewBattle17Ctrl:GoToHeroSelect(mainType, subType, seconds,partyData)
  local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("PVPHeroSelect")
          while async.Done == false do
            coroutine.step()
          end
          if PVPHeroSelectAPI ~= nil and PVPHeroSelectAPI.Instance ~= nil then
            PVPHeroSelectAPI.Instance:SetParam(mainType, subType, seconds,partyData)
          end
          self:DestroySelf()
        end
 coroutine.start(CreatePanelAsync,self)
  
end

function NewBattle17Ctrl:CountDown(timer)
  timer = tonumber(timer)
  while timer>0 do
    self.timer.text = tostring(timer)
    coroutine.wait(1)
    timer = timer - 1
  end
  self.timer.text = "0"
  self.co_countdown = nil
  
end

--存储征召数据
function NewBattle17Ctrl:OnNotifyBattleDraftChangeHandler(e)
  if e.Type == "NotifyBattleDraftChange" then    
    UTGDataTemporary.Instance().DraftContent = e
    self:GoToDraftHeroSelect()
    return true
  end
  return true
end

function NewBattle17Ctrl:OnNotifyPartyChangeHandler(e)
  if e.Type == "NotifyPartyChange" then    
    UTGDataTemporary.Instance().DraftPartyContent = e
    return true
  end
  return true
end
--创建 征召界面
function NewBattle17Ctrl:GoToDraftHeroSelect()
  local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("DraftHeroSelect")
          while async.Done == false do
            coroutine.step()
          end
          self:DestroySelf()
        end
  coroutine.start(CreatePanelAsync,self)
end

--删除自己
function NewBattle17Ctrl:DestroySelf()
  if self~=nil and self.this~=nil then 
    Object.Destroy(self.this.transform.parent.gameObject)
  end
end


function NewBattle17Ctrl:IsContains(needCheck,element)
  -- body
  print(type(needCheck) .. " " .. type(element))
  for k,v in pairs(needCheck) do
    if v == element then
      return true
    end
  end
  return false
end


function NewBattle17Ctrl:OnDestroy()
  if self.co_countdown~=nil then
    print("删除coroutine") 
    coroutine.stop(self.co_countdown) 
  end
  TGNetService.GetInstance():RemoveEventHander("NotifyBattleMatchResult", self.MatchResultHandler)
  TGNetService.GetInstance():RemoveEventHander("NotifyConfirmMatchChange", self.PlayerReadyHandler)
  TGNetService.GetInstance():RemoveEventHander("NotifyBattleDraftChange", self.NotifyBattleDraftChangeHandler)
  TGNetService.GetInstance():RemoveEventHander("NotifyPartyChange", self.NotifyPartyChangeHandler)
  NewBattle17API.Instance = nil
  self.this = nil
  self = nil
end