require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("WantGoldApi")

function WantGoldApi:Awake(this) 
  self.this = this
  WantGoldApi.Instance = self
end

function WantGoldApi:Start()
  self.ctrl = self.this.transforms[0]:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
end

function WantGoldApi:Init()

end

function WantGoldApi:OnDestroy()
  self.this = nil
  WantGoldApi.Instance = nil
  self = nil
end

function WantGoldApi:progressUiSet(args)
  self.ctrl.self:progressUiSet()
end

  