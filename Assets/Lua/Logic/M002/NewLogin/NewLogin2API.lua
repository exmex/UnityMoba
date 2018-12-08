require "System.Global"

class("NewLogin2API")

function NewLogin2API:Awake(this)
  self.this = this
  self.newLogin2Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
  self.waitPanel = this.transforms[1]
  NewLogin2API.Instance = self
  
end

function NewLogin2API:Start()

end

function NewLogin2API:StartGameToHere()
  self.newLogin2Ctrl.self:StartGameToHere()
end

function NewLogin2API:ReLogin(callBack,caller)
  self.newLogin2Ctrl.self:ReLogin(callBack,caller)
end

function NewLogin2API:SetWaitPanel(boo)
  self.waitPanel.gameObject:SetActive(boo)
end


function NewLogin2API:OnDestroy()
  NewLogin2API.Instance = nil
  self.this = nil
  self = nil
end
