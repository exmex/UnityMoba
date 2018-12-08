require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("WantGrowAPI")

function WantGrowAPI:Awake(this) 
  self.this = this
  WantGrowAPI.Instance = self
end

function WantGrowAPI:Start()
  self.ctrl = self.this.transforms[0]:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
end

function WantGrowAPI:Init()

end

function WantGrowAPI:UpdateData()
  self.ctrl.self:UpdateData()
end

function WantGrowAPI:ShowReward(data)
  local async = GameManager.CreatePanel("GetRune")
  if GetRuneAPI.Instance ~= nil then
    GetRuneAPI.Instance:ShowReward(data) --调用显示奖励api
  end
end



function WantGrowAPI:OnDestroy()
  self.this = nil
  WantGrowAPI.Instance = nil
  self = nil
end

  