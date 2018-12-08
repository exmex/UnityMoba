--author zx
require "System.Global"
--require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("BattleMallSelectHeroAPI")

function BattleMallSelectHeroAPI:Awake(this)
  self.this = this
  BattleMallSelectHeroAPI.Instance = self
  self.ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
end

----------API---------
function BattleMallSelectHeroAPI:GetRune()
  self.isRune = true
  self.ctrl.self:Init()
end

function BattleMallSelectHeroAPI:GetEquip()
  self.isRune = false
  self.ctrl.self:Init()
end

function BattleMallSelectHeroAPI:OnDestroy()
  self.this = nil
  BattleMallSelectHeroAPI.Instance = nil
  self = nil
end