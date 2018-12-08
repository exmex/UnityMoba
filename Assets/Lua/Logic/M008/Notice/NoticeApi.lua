require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("NoticeApi")

function NoticeApi:Awake(this) 
  self.this = this
  NoticeApi.Instance = self
end

function NoticeApi:Start()
  self.ctrl = self.this.transforms[0]:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
end

function NoticeApi:Init()

end

function NoticeApi:OnDestroy()
  self.this = nil
  NoticeApi.Instance = nil
  self = nil
end

function NoticeApi:updateRed()
  self.ctrl.self:redUpdate()
  ActivityNoticeApi.Instance:redNoticeUpdate()
end
  