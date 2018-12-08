--author zx
class("StartBountyMatchAPI")

function StartBountyMatchAPI:Awake(this)
  self.this = this
  StartBountyMatchAPI.Instance = self

  self.ctrl = self.this.transforms[0]:GetComponent("NTGLuaScript")

end

function StartBountyMatchAPI:Start()
  
end

function StartBountyMatchAPI:UpdateData()
  self.ctrl.self:InitTicketAmount()
end


function StartBountyMatchAPI:OnDestroy()
  self.this = nil
  StartBountyMatchAPI.Instance = nil
  self = nil
end