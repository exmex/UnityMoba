--author zx
class("GiftCenterAPI")

function GiftCenterAPI:Awake(this)
  self.this = this
  GiftCenterAPI.Instance = self

  self.ctrl = self.this.transforms[0]:GetComponent("NTGLuaScript")

end

function GiftCenterAPI:Start()

end


function GiftCenterAPI:OnDestroy()
  self.this = nil
  GiftCenterAPI.Instance = nil
  self = nil
end