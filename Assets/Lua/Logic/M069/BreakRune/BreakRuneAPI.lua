--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
require "Logic.UTGData.UTGDataTemporary"
class("BreakRuneAPI")
local json = require "cjson"

function BreakRuneAPI:Awake(this)
  self.this = this
  BreakRuneAPI.Instance = self
 end

function BreakRuneAPI:Start()
  self.ctrl = self.this.gameObject:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[1]
end


function BreakRuneAPI:UpdateData()
	--Debugger.LogError("UpdateRuneData")
	self.ctrl.self:UpdateRuneData()
end



function BreakRuneAPI:OnDestroy()
  self.this = nil
  self = nil
  BreakRuneAPI.Instance = nil
end