require "System.Global"
require "Logic.UICommon.Static.UITools"
class("PlayerBarInviteCtrl")

function PlayerBarInviteCtrl:Awake(this)
  self.this = this
  self.friendWindowCtrl = this.transforms[0]:GetComponent("NTGLuaScript")
  self.headPic = this.transforms[1]
  self.name = this.transforms[2]:GetComponent("UnityEngine.UI.Text")
  self.status = this.transforms[3]:GetComponent("UnityEngine.UI.Text")
  self.inviteBtn = this.transforms[4]
  self.headFrame = this.transforms[5]
end

function PlayerBarInviteCtrl:Start()
  self:Init()
end

function PlayerBarInviteCtrl:Init()
  self.isInvited = false
  
  local listener
  listener = NTGEventTriggerProxy.Get(self.inviteBtn.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( PlayerBarInviteCtrl.OnInviteBtnClick,self)
end

function PlayerBarInviteCtrl:OnInviteBtnClick()
  if self.isInvited then
    local function CreatePanelAsync()
      local async = GameManager.CreatePanelAsync("SelfHideNotice")
      while async.Done == false do
        coroutine.wait(0.05)
      end
      if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
        SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("您刚刚已经邀请过他了，请在<color=#FF0000>"..tostring(self.timer).."</color>秒后再邀请他。") 
      end
    end
    coroutine.start( CreatePanelAsync,self)
  else
    self.friendWindowCtrl.self:InviteFriend(self.playerId)
    self:SetBar(4)
    coroutine.start(self.StartInviteTimer,self)
  end
end 


function PlayerBarInviteCtrl:SetBar( status , name , playerId , avatar ,avatarFrameId, canInvite )

  if avatar ~=nil then 
    self.headPic:GetComponent("Image").sprite = UITools.GetSprite("roleicon",avatar)
  end                                         
  self.headPic:GetComponent("Image").color = Color.white


  if(avatarFrameId~=nil)then
    self.headFrame:GetComponent("Image").sprite = UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(avatarFrameId)].Icon)
  end
  self.inviteBtn.gameObject:SetActive(false)
  if playerId ~= nil then
    self.playerId = playerId
  end
  if name ~= nil then
    self.nameTemp = name
  end
  self.name.text = "<color=#FFFFFF>"..self.nameTemp.."</color>"
  if status == 0 then 
    self.status.text = "<color=#FFFFFF>离线</color>"
    self.name.text = "<color=#CCCCCC>"..self.nameTemp.."</color>"
    self.headPic:GetComponent("Image").color = Color.gray
    return
  end
  if status == 1 then 
    self.status.text = "<color=#00FF00>在线</color>"
    if(canInvite)then
      self.inviteBtn.gameObject:SetActive(true)
    end
    return
  end
  if status == 2 then 
    self.status.text = "<color=#FFF000>游戏中</color>"
    return
  end
  if status == 3 then 
    self.status.text = "<color=#FFF000>组队中</color>"
    return
  end
  if status == 4 then 
    self.status.text = "<color=#FFF000>已邀请</color>"
    --[[
    if(canInvite)then
      self.inviteBtn.gameObject:SetActive(true)
    end
    --]]
    return
  end
  if status == 5 then 
    self.status.text = "<color=#FF0000>已拒绝</color>"
    return
  end
end

function PlayerBarInviteCtrl:StartInviteTimer()
  self.isInvited = true
  self.timer = 5
  coroutine.wait(1)
  self.timer = 4
  coroutine.wait(1)
  self.timer = 3
  coroutine.wait(1)
  self.timer = 2
  coroutine.wait(1)
  self.timer = 1
  coroutine.wait(1)
  self.isInvited = false
end

function PlayerBarInviteCtrl:OnDestroy()
  self.this = nil
  self.name.font=nil
  self.status.font=nil
  self = nil
end