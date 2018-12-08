require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("NewAchieveApi")

function NewAchieveApi:Awake(this) 
  self.this = this
  NewAchieveApi.Instance = self
end

function NewAchieveApi:Start()
  self.ctrl = self.this.transforms[0]:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
end

function NewAchieveApi:Init()

end

function NewAchieveApi:OnDestroy()
  self.this = nil
  NewAchieveApi.Instance = nil
  self = nil
end

function NewAchieveApi:uiSet(info)
  self.ctrl.self:uiSet(info)
end

  