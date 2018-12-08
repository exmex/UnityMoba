require "System.Global"

class("SkinWindow19API")

function SkinWindow19API:Awake(this)
  self.this = this
  self.ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
  SkinWindow19API.Instance = self
end

function SkinWindow19API:Start()
	NTGApplicationController.SetShowQuality(true)
end
function SkinWindow19API:Show(skinId)
	self.skinId = skinId
end

function SkinWindow19API:SetSendGift()
	self.sendGift = true
end

function SkinWindow19API:OnDestroy()
  SkinWindow19API.Instance = nil
  NTGApplicationController.SetShowQuality(false)
  self.this = nil
  self = nil
end