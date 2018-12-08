require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("GrowProcessApi")

function GrowProcessApi:Awake(this) 
  self.this = this
  GrowProcessApi.Instance = self
end

function GrowProcessApi:Start()
  self.ctrl = self.this.transforms[0]:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
end

function GrowProcessApi:Init()

end

function GrowProcessApi:OnDestroy()
  self.this = nil
  GrowProcessApi.Instance = nil
  self = nil
end

function GrowProcessApi:updateMissionUi(args)
  self.ctrl.self:updateMissionUi()
end

function GrowProcessApi:updateLevelAwardUi(args)
  self.ctrl.self:updateLevelAwardUi()
end

function GrowProcessApi:contentCupSetActeive(active)
  self.ctrl.self:contentCupSetActeive(active)
end