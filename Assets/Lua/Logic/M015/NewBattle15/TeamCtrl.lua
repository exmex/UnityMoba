require "System.Global"

class("TeamCtrl")

function TeamCtrl:Awake(this)
  self.this = this
  self.newBattle15Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
  self.addComputerBtn = this.transforms[1]
  self.bar1 = this.transforms[2]:GetComponent("NTGLuaScript")
  self.bar2 = this.transforms[3]:GetComponent("NTGLuaScript")
  self.bar3 = this.transforms[4]:GetComponent("NTGLuaScript")
  self.bar4 = this.transforms[5]:GetComponent("NTGLuaScript")
  self.bar5 = this.transforms[6]:GetComponent("NTGLuaScript")
  --self.btnBg = this.transforms[7]
  self.bars = {self.bar1, self.bar2, self.bar3, self.bar4, self.bar5}
end

function TeamCtrl:Start()
  self:Init()
end

function TeamCtrl:Init()
  self.mainModeCode = 0
  self.owner = 0
  self.groupType = 0
  if self.this.name == "TeamOne" then    
    self.teamNo = 1
  end
  if self.this.name == "TeamTwo" then    
    self.teamNo = 2
  end

  local listener
  listener = NTGEventTriggerProxy.Get(self.addComputerBtn.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( TeamCtrl.OnAddComputerBtnClick,self)
end

function TeamCtrl:GetPalyerBarByPlayerId(playerId)
  for k,v in pairs(self.bars) do 
    if v.self ~= nil and v.self.playerId == playerId then 
      return v
    end
  end
end 

function TeamCtrl:OnAddComputerBtnClick()
  local addComputerRequest = NetRequest.New()
  addComputerRequest.Content = JObject.New(JProperty.New("Type","RequestInvite"),
                                           JProperty.New("GroupType", 2),
                                           JProperty.New("Inviteam", self.teamNo),
                                           JProperty.New("Invitee", 0))
  addComputerRequest.Handler = TGNetService.NetEventHanlderSelf(TeamCtrl.AddComputerHandler,self)
  TGNetService.GetInstance():SendRequest(addComputerRequest)
end

function TeamCtrl:AddComputerHandler(e)
  --Debugger.LogError("添加电脑响应")
  if e.Type == "RequestInvite" then   
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then      
      --Debugger.LogError("房间加电脑成功")
      return true
    end
    --Debugger.LogError("房间加电脑失败")
  end
  return true
end

--groupType 1为party 2为room
function TeamCtrl:UpdateTeam(battleMembers, owner, groupType,subType)
  self.groupType = groupType
  --Debugger.LogError("battleMembers的数量======"..#battleMembers)
  self.owner = owner
  --是否是主机的客户端
  local isOwner = (UTGData.Instance().PlayerData.Id == owner)
  
  --不是主机的话隐藏加电脑按钮,反之显示
  if groupType ~= 1 and isOwner then
    --self.btnBg.gameObject:SetActive(true)
    self.addComputerBtn.gameObject:SetActive(true)
  else
    --self.btnBg.gameObject:SetActive(false)
    self.addComputerBtn.gameObject:SetActive(false)
  end
  if subType==52 then --征召模式不显示
    self.addComputerBtn.gameObject:SetActive(false)
  end
  
  --由于服务器发过来的消息是所有队伍的总信息二teamctrl是一个队伍，所以有一下逻辑
  if #battleMembers == 1 then
    self.players[1].self:UpdateInfo(battleMembers[1], owner, isOwner, groupType)
    return
  end
  if groupType == 1 then 
    for k,v in pairs(battleMembers) do
      self.players[k].self:UpdateInfo(v, owner, isOwner, groupType)
      --Debugger.LogError("PartyTeamBar更新")
    end
    return
  end   
  if self.teamNo == 1 then 
    for k,v in pairs(battleMembers) do
      if k > (#battleMembers/2) then break end
      self.players[k].self:UpdateInfo(v, owner, isOwner, groupType)
      --Debugger.LogError("Team1更新")
    end
  end
  if self.teamNo == 2 then 
    for k,v in pairs(battleMembers) do
      if k > (#battleMembers/2) then 
        self.players[k-#battleMembers/2].self:UpdateInfo(v, owner, isOwner, groupType)
        --Debugger.LogError("Team2更新")
      end
    end
  end 

  --如果队伍已满则隐藏增加电脑按钮且是开房间模式
  if  groupType == 2 and #battleMembers == (self:GetHeroCount() * 2)then
    self.addComputerBtn.gameObject:SetActive(false)
  end
end
  
function TeamCtrl:InitRoomGame(count)
  self:SetCountAndInit(count, self.mainModeCode)
end

function TeamCtrl:InitPartyGame(count)
  self:SetCountAndInit(count, self.mainModeCode)
  self.this.transform.localPosition = Vector3.New(0, -100, 0)
  self.addComputerBtn.gameObject:SetActive(false)
  --self.btnBg.gameObject:SetActive(false)
end

--由于此类的Start函数会在一下函数被别人调用后才执行所以初一部分始化函数放在这里
function TeamCtrl:SetCountAndInit(count)
  self.playerCount = count
  self.players = {}
  for k,v in ipairs(self.bars) do 
    v.gameObject:SetActive(true)
    v.self:SetPos(k)
    table.insert(self.players, v)
    if k == count then break end
  end 
end

--获得队伍中玩家或者电脑的数量
function TeamCtrl:GetHeroCount()
  local count = 0
  for k,v in ipairs(self.players) do
    if v.self.isAi then
      count = count + 1
    elseif v.self.playerId > 0 then 
      count = count + 1
    end
  end
  return count
end

function TeamCtrl:KickMember(pos)
   self.newBattle15Ctrl.self:KickMember(self.teamNo, pos)
end 

function TeamCtrl:ChangePos(pos)
  self.newBattle15Ctrl.self:ChangePos(self.teamNo, pos)
end

function TeamCtrl:OnDestroy()
  self.this = nil
  self = nil
end