--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("BattleResult29API")
--local json = require "cjson"

function BattleResult29API:Awake(this)
  self.this = this
  BattleResult29API.Instance = self
  self.ctrl_29 = self.this.transform:FindChild("29"):GetComponent("NTGLuaScript")
  
end

function BattleResult29API:Start()
  
end


--初始化
function BattleResult29API:Init(battleData)
  self.ctrl_29.self:Init(battleData)

end


function BattleResult29API:OnDestroy()
  self.this = nil
  self = nil
  BattleResult29API.Instance = nil
end