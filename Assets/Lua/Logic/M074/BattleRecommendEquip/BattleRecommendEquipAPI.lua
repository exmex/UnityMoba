--author zx
require "System.Global"
--require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("BattleRecommendEquipAPI")

function BattleRecommendEquipAPI:Awake(this)
  self.this = this
  BattleRecommendEquipAPI.Instance = self
  self.ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
end

function BattleRecommendEquipAPI:Start()
 
end
--从73界面传入roleid
function BattleRecommendEquipAPI:SetParamBy73(id)
  self.RoleId = id
  self.ctrl.self:Init(id)
end


function BattleRecommendEquipAPI:OnDestroy()
  self.this = nil
  self = nil
end