require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("WantHeroApi")

function WantHeroApi:Awake(this) 
  self.this = this
  WantHeroApi.Instance = self
end

function WantHeroApi:Start()
  self.ctrl = self.this.transforms[0]:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
end

function WantHeroApi:Init()

end

function WantHeroApi:OnDestroy()
  self.this = nil
  WantHeroApi.Instance = nil
  self = nil
end

  