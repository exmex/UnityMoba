--author zx
class("CoinMatchAPI")

function CoinMatchAPI:Awake(this)
  self.this = this
  CoinMatchAPI.Instance = self

  self.ctrl = self.this.transforms[0]:GetComponent("NTGLuaScript")

end

function CoinMatchAPI:Start()
  
end

function CoinMatchAPI:UpdateData()
  self.ctrl.self:InitTicketAmount()
end

function CoinMatchAPI:ClosePanel()
  Object.Destroy(self.this.transform.gameObject)
end

function CoinMatchAPI:OnDestroy()
  self.this = nil
  CoinMatchAPI.Instance = nil
  self = nil
end