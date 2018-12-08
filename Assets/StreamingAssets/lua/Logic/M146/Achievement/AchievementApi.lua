require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("AchievementApi")

function AchievementApi:Awake(this) 
  self.this = this
  AchievementApi.Instance = self
end

function AchievementApi:Start()
  self.ctrl = self.this.transforms[0]:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
end

function AchievementApi:Init()

end

function AchievementApi:OnDestroy()
  self.this = nil
  AchievementApi.Instance = nil
  self = nil
end

function AchievementApi:updateGetAward()
  self.ctrl.self:awardDataSet()
  self.ctrl.self:awardUiSet()
  if (self.ctrl.self.awardPanel.gameObject.activeSelf == true) then
    self.ctrl.self:awardPanelListUpdate()
  end
end

  