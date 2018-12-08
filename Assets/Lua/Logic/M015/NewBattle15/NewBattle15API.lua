require "System.Global"

class("NewBattle15API")

function NewBattle15API:Awake(this)
  self.this = this
  self.newBattle15Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
  NewBattle15API.Instance = self

  self.ChatFrame = this.transform:FindChild("Chat")
  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
  
  self.canvasGroup=self.this.transform:GetComponent("CanvasGroup")
  self:SetPanelActive(false)
end


function NewBattle15API:Start()
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("NewBattle15Panel/TopPanel")
  topAPI:ShowControl(3)
  topAPI:InitTop(self.newBattle15Ctrl.self,NewBattle15Ctrl.OnBackBtnClick,nil,nil,"组队准备")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(topAPI)
  
  --local bgPanel = UTGDataOperator.Instance:SetBgToPosition(self.this.transform)
  --bgPanel:SetAsFirstSibling()

end

--初始化聊天
function NewBattle15API:InitChat(_type,param)
  if self.isLoadChat == true then return end
  self.coroutine_initchat = coroutine.start(self.InitChatMov,self,_type,param)
end
function NewBattle15API:InitChatMov(_type,param)
  local chat = GameManager.CreatePanelAsync("Chat")
  while chat.Done == false do
    coroutine.step()
  end
  local chatSelf = chat.Panel:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
  chatSelf.self:InitChat(self.ChatFrame,self.this.transform,_type,param)
  self.isLoadChat = true
  self.coroutine_initchat = nil
end

function NewBattle15API:CreateRoom(mapName, count, subTypeCode)
  self.newBattle15Ctrl.self:CreateRoom(mapName, count, subTypeCode)
end

function NewBattle15API:SetPanelActive(boo)
  if boo then 
    self.canvasGroup.alpha=1
    self.canvasGroup.blocksRaycasts = true
  else
    self.canvasGroup.alpha=0
    self.canvasGroup.blocksRaycasts = false
  end
end
function NewBattle15API:CreateParty(mapName, count, subTypeCode,mainType,difficulty)
  self.newBattle15Ctrl.self:CreateParty(mapName, count, subTypeCode,mainType,difficulty)
end

function NewBattle15API:UpdateRoom(roomInfo)
  self.newBattle15Ctrl.self:UpdateRoom(roomInfo)
end

function NewBattle15API:UpdateParty(partyInfo)
  self.newBattle15Ctrl.self:UpdateParty(partyInfo)
end

function NewBattle15API:UpdateFriendInfo(playerId, status)
  self.newBattle15Ctrl.self:UpdateFriendInfo(playerId, status)
end

function NewBattle15API:DirectUpdateRoom(roomInfo)
  self.newBattle15Ctrl.self:OnRoomChangeHandler(roomInfo)
end

function NewBattle15API:DirectUpdateParty(partyInfo)
  self.newBattle15Ctrl.self:OnPartyChangeHandler(partyInfo)
end

function NewBattle15API:UpdateFriendList()
  -- body
  self.newBattle15Ctrl.self:UpdateFriendList()
end

function NewBattle15API:UpdateFriendList()
  -- body
  self.newBattle15Ctrl.self:UpdateFriendList()
end

function NewBattle15API:DestroySelf()

  --UTGDataOperator.Instance:SetBgToPosition(GameManager.PanelRoot)
  
  Object.Destroy(self.this.gameObject)
end

function NewBattle15API:OnDestroy()
  --UTGDataOperator.Instance:BgBackToPanelRoot()
  if self.coroutine_initchat~=nil then coroutine.stop(self.coroutine_initchat) end
  NewBattle15API.Instance = nil
  self.this = nil
  self = nil
  --NTGResourceController.Instance:UnloadAssetBundle("newbattle15",true)
end