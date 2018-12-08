--author zx
class("BountyMatchAPI")

function BountyMatchAPI:Awake(this)
  self.this = this
  BountyMatchAPI.Instance = self

  self.ctrl = self.this.transforms[0]:GetComponent("NTGLuaScript")

end

function BountyMatchAPI:Start()
  
end

function BountyMatchAPI:SetState(state)
  self.ctrl.self.state = state
end


function BountyMatchAPI:OnDestroy()
  self.this = nil
  BountyMatchAPI.Instance = nil
  self = nil
end