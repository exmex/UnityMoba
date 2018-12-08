require "System.Global"

class("WaitingPanelController")

function WaitingPanelController:Awake(this)
  self.this = this
end

function WaitingPanelController:Start()
  
end

function WaitingPanelController:DestroySelf()
  
end


function WaitingPanelController:OnDestroy()
  self.this = nil
  self = nil
end
