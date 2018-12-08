require "System.Global"

class("WaitingPanelAPI")

function WaitingPanelAPI:Awake(this)
  self.this = this
  WaitingPanelAPI.Instance = self
end

function WaitingPanelAPI:DestroySelf()
  GameObject.DestroyImmediate(self.this.gameObject,true)
end


function WaitingPanelAPI:OnDestroy()
  self.this = nil
  self = nil
  WaitingPanelAPI.Instance = nil
end


