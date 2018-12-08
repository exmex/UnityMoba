--author zx
require "System.Global"
--require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("PVPPlayerSkillSelectAPI")

function PVPPlayerSkillSelectAPI:Awake(this)
  self.this = this
  PVPPlayerSkillSelectAPI.Instance = self
  self.ctrl = self.this.transforms[0]:GetComponent("NTGLuaScript")
end

function PVPPlayerSkillSelectAPI:Start()

end

function PVPPlayerSkillSelectAPI:SetCurrentSkillId(id)
	self.currentId = tonumber(id)
	self.ctrl.self:Init(id)
end

function PVPPlayerSkillSelectAPI:OnDestroy()
  self.this = nil
  self = nil
  PVPPlayerSkillSelectAPI.Instance = nil
end