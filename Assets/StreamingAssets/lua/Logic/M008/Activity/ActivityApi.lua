require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("ActivityApi")

function ActivityApi:Awake(this) 
  self.this = this
  ActivityApi.Instance = self
end

function ActivityApi:Start()
  self.ctrl = self.this.transforms[0]:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
end

function ActivityApi:OnDestroy()
  self.this = nil
  ActivityApi.Instance = nil
  self = nil
end

function ActivityApi:updateSelectPageWhenGet(questId)
  self.ctrl.self:updateSelectPageWhenGet(questId)
end

function ActivityApi:updateSelectPageWhenTime(actiInfo,Action)
  self.ctrl.self:updateSelectPageWhenTime(actiInfo,Action)
end

