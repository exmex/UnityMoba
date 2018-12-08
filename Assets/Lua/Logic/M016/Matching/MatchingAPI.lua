require "System.Global"

class("MatchingAPI")

function MatchingAPI:Awake(this)
  self.this = this
  
  self.matchingControlPanel = self.this.transforms[0]:GetComponent("NTGLuaScript")
  
  MatchingAPI.Instance = self
  
end

function MatchingAPI:CancelButtonControl(memNum)
  self.matchingControlPanel.self:CancelButtonControl(memNum)
end

function MatchingAPI:DestroySelf()
  Object.Destroy(self.this.gameObject)
end


function MatchingAPI:OnDestroy()
  self.this = nil
  self = nil
  MatchingAPI.Instance = nil
end

