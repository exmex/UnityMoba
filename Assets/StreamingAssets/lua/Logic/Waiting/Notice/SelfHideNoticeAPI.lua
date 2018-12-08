require "System.Global"

class("SelfHideNoticeAPI")

function SelfHideNoticeAPI:Awake(this)
  self.this = this
  
  self.selfHideNoticePanel = self.this.transforms[0]:GetComponent("NTGLuaScript")
  
  SelfHideNoticeAPI.Instance = self
end

function SelfHideNoticeAPI:InitNoticeForSelfHideNotice(text)
  self.selfHideNoticePanel.self:InitInfo(text)
end

function SelfHideNoticeAPI:DestroySelf()
  Object.Destroy(self.this.gameObject)
end


function SelfHideNoticeAPI:OnDestroy()
  SelfHideNoticeAPI.Instance = nil
  self.this = nil
  self = nil
end


