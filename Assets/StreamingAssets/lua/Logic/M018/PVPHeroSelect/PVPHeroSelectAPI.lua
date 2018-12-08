--author zx
class("PVPHeroSelectAPI")

function PVPHeroSelectAPI:Awake(this)
  PVPHeroSelectAPI.Instance = self
  self.this = this
  local butOk = NTGEventTriggerProxy.Get(this.transforms[0].gameObject)
  butOk.onPointerDown = butOk.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectAPI.DragCube,self)

  self.cube = this.transforms[1]:FindChild("root")
  self.desk = this.transforms[1]:FindChild("desk")
  self.cubespeed = this.floats[0]

  self.ctrl_tran = self.this.transforms[2]
  self.chat_tran = self.this.transforms[3]
  self.rune_tran = self.this.transforms[4]

  self.ctrl = self.ctrl_tran:GetComponent("NTGLuaScript")
  self.ctrl_chat = self.chat_tran:GetComponent("NTGLuaScript")
  self.ctrl_rune = self.rune_tran:GetComponent("NTGLuaScript")
end

function PVPHeroSelectAPI:Start()
  NTGApplicationController.SetShowQuality(true)

end

function PVPHeroSelectAPI:DragCube()
  self.cor_drag = coroutine.start(PVPHeroSelectAPI.DragMov,self)
end
function PVPHeroSelectAPI:DragMov()

  local startpos = Input.mousePosition
  --print(startpos)
  local offet = {}
  local isClick = true
  while Input.GetMouseButton(0) do  
    coroutine.step() 
    offet = (Input.mousePosition-startpos).x
    if math.abs(offet) > 0.1 then isClick = false end
    startpos = Input.mousePosition
    self.cube.localEulerAngles = self.cube.localEulerAngles + Vector3.New(0,-self.cubespeed*offet,0)
    self.desk.localEulerAngles = self.desk.localEulerAngles + Vector3.New(0,-self.cubespeed*offet,0)
  end
  if isClick then
    self.ctrl.self:SetModelPlayerAnimator()
  end
  self.cor_drag = nil
end



function PVPHeroSelectAPI:SetParam(maintype,subtype,time,partydata)
  time = time or 0
  self.ctrl.self:Init(maintype,subtype,time,partydata)
end

function PVPHeroSelectAPI:UpdatePartyChangeData(partydata)
  self.ctrl.self:UpdatePartyChangeData(partydata)
end

--改变召唤师技能
function PVPHeroSelectAPI:SetPlayerSkillBy20(skilldata)
  self.ctrl.self:ChangePlayerSkill(skilldata)
end

--购买皮肤成功
function PVPHeroSelectAPI:SetParamBy19(skinid)

end

--聊天初始化
function PVPHeroSelectAPI:ChatInit(partyId)
  self.ctrl_chat.self:Init(partyId)
end
--聊天
function PVPHeroSelectAPI:SetPlayerChat(data)
  self.ctrl.self:SetPlayerChat(data)
end

--符文
function PVPHeroSelectAPI:RuneInit()
  self.ctrl_rune.self:Init()
end
function PVPHeroSelectAPI:SendSelectRunePageId(pageid)
  self.ctrl.self:NetChangeRune(pageid)
end
function PVPHeroSelectAPI:SetSelectRunePageId(pageid)
  self.ctrl_rune.self:SetRunePageId(pageid)
end
function PVPHeroSelectAPI:GetDefaultRunePageId()
  return self.ctrl_rune.self:GetDefaultRunePageId()
end

function PVPHeroSelectAPI:OnDestroy()
  if self.cor_drag~=nil then coroutine.stop(self.cor_drag) end
  NTGApplicationController.SetShowQuality(false)
  self.this = nil
  self = nil
  PVPHeroSelectAPI.Instance = nil
end
