--author zx
class("MatchSystemAPI")

function MatchSystemAPI:Awake(this)
  self.this = this
  MatchSystemAPI.Instance = self

  self.ctrl = self.this.transforms[0]:GetComponent("NTGLuaScript")

end

function MatchSystemAPI:Start()
  
end



function MatchSystemAPI:OnDestroy()
  self.this = nil
  MatchSystemAPI.Instance = nil
  self = nil
end