require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("WantRuneApi")

function WantRuneApi:Awake(this) 
  self.this = this
  WantRuneApi.Instance = self
end

function WantRuneApi:Start()
  self.ctrl = self.this.transforms[0]:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
end

function WantRuneApi:Init()

end

function WantRuneApi:OnDestroy()
  self.this = nil
  WantRuneApi.Instance = nil
  self = nil
end

  