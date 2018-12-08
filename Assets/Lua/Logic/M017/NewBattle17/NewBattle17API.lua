require "System.Global"

class("NewBattle17API")

function NewBattle17API:Awake(this)
  self.this = this
  self.newBattle17Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
  NewBattle17API.Instance = self
end

function NewBattle17API:Init(teamParties,rivalParties,seconds)
	self.newBattle17Ctrl.self:Init(teamParties,rivalParties,seconds)
end

function NewBattle17API:OnDestroy()
  NewBattle17API.Instance = nil
  self.this = nil
  self = nil
end
