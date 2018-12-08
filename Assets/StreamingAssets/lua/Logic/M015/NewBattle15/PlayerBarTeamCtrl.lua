require "System.Global"
require "Logic.UICommon.Static.UITools"
class("PlayerBarTeamCtrl")

function PlayerBarTeamCtrl:Awake(this)
  self.this = this
  self.teamCtrl = this.transforms[0]:GetComponent("NTGLuaScript")
  self.headPic = this.transforms[1]:GetComponent("UnityEngine.UI.Image")
  self.name = this.transforms[2]:GetComponent("UnityEngine.UI.Text")
  self.changeBtn = this.transforms[3]
  self.hostPic = this.transforms[4]
  self.kickBtn = this.transforms[5]
  self.playerChangeBtn = this.transforms[6]
  self.aiPic = this.transforms[7]:GetComponent("UnityEngine.UI.Image")
end

function PlayerBarTeamCtrl:Start()
  self:Init()
end

function PlayerBarTeamCtrl:Init()
  if self.playerId == nil then self.playerId = 0 end
  
  self.kickBtn.gameObject:SetActive(false) 
  
  local listener
  listener = NTGEventTriggerProxy.Get(self.changeBtn.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( PlayerBarTeamCtrl.OnChangeBtnClick,self)
  
  listener = NTGEventTriggerProxy.Get(self.playerChangeBtn.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( PlayerBarTeamCtrl.OnChangeBtnClick,self)
  
  listener = NTGEventTriggerProxy.Get(self.kickBtn.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( PlayerBarTeamCtrl.OnKickBtnClick,self)
end

--这里非常绕，以后重写
function PlayerBarTeamCtrl:UpdateInfo(member, owner, isOwner, groupType)
  --Debugger.LogError("更新一个Bar")
  self.playerId = member.PlayerId
  self.isAi = member.IsAi 
  
  --单独设置踢人按钮
  self.kickBtn.gameObject:SetActive(false)
  if isOwner then 
    if member.IsAi then
      self.kickBtn.gameObject:SetActive(true)
    end
    if member.PlayerId ~= UTGData.Instance().PlayerData.Id and member.PlayerId > 0 then
      self.kickBtn.gameObject:SetActive(true)
    end         
  end
  
  --设置主机头像等
  self.hostPic.gameObject:SetActive(false)
  if member.PlayerId == owner then
    self:SetOwner(member.PlayerIcon, member.PlayerName, member.PlayerId)
  else
    if member.IsAi == true then
      self.name.text = "电脑"
      self.headPic.gameObject:SetActive(false)
      self.changeBtn.gameObject:SetActive(false)
      self.playerChangeBtn.gameObject:SetActive(false)
      self.aiPic.gameObject:SetActive(true)
    end
    if member.IsAi ==  false and member.PlayerId <= 0 then
      self.name.text = ""
      self.headPic.gameObject:SetActive(false)
      self.changeBtn.gameObject:SetActive(true)
      self.playerChangeBtn.gameObject:SetActive(false) 
      self.aiPic.gameObject:SetActive(false)
    end
    if member.PlayerId > 0 then
      self.name.text = member.PlayerName
      self.headPic:GetComponent("UnityEngine.UI.Image").sprite= UITools.GetSprite("roleicon",member.PlayerIcon)
      self.headPic.gameObject:SetActive(true)
      self.changeBtn.gameObject:SetActive(false)
      self.aiPic.gameObject:SetActive(false)
      if member.PlayerId == UTGData.Instance().PlayerData.Id then
        self.playerChangeBtn.gameObject:SetActive(false)
      else
        self.playerChangeBtn.gameObject:SetActive(true)
      end
    end
  end
  
  --如果是Party模式是不能换位置的所以这里对2种换位按钮单独处理
  if groupType == 1 then
    self.changeBtn.gameObject:SetActive(false)
    self.playerChangeBtn.gameObject:SetActive(false)
  end
end 

function PlayerBarTeamCtrl:OnKickBtnClick()
  self.teamCtrl.self:KickMember(self.pos)
end 

function PlayerBarTeamCtrl:OnChangeBtnClick()
  --Debugger.LogError("向位置为"..self.pos.."发起换位请求")

  self.teamCtrl.self:ChangePos(self.pos)
end

--Owner和Leader都是Party和Room的主机这里都用SetOwner
function PlayerBarTeamCtrl:SetOwner(avatar, name, playerId)
  self.headPic:GetComponent("UnityEngine.UI.Image").sprite= UITools.GetSprite("roleicon",avatar)
  self.headPic.gameObject:SetActive(true)
  self.changeBtn.gameObject:SetActive(false)
  self.hostPic.gameObject:SetActive(true)
  self.name.text = name
  
  if playerId ~= UTGData.Instance().PlayerData.Id then 
    self.playerChangeBtn.gameObject:SetActive(true)
  else
    self.playerChangeBtn.gameObject:SetActive(false)
  end
end

function PlayerBarTeamCtrl:SetPos(pos)
  self.pos = pos
end 
  
function PlayerBarTeamCtrl:OnDestroy()
  self.this = nil

  self.headPic.sprite=nil
  self.name.font=nil 
  self.aiPic.sprite=nil

  self = nil
end