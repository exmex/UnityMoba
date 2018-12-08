--author zx
class("DraftHeroSelectAPI")

function DraftHeroSelectAPI:Awake(this)
  self.this = this
  DraftHeroSelectAPI.Instance = self

  self.ctrl = self.this.transforms[0]:GetComponent("NTGLuaScript")

  self.ctrl_chat = self.this.transforms[1]:GetComponent("NTGLuaScript")
  self.ctrl_rune = self.this.transforms[2]:GetComponent("NTGLuaScript")
end

function DraftHeroSelectAPI:Start()
end


--断线重连 
function DraftHeroSelectAPI:UpdateDraftData(draftData,partyData)
  self.ctrl.self:UpdateUI(draftData)
  self.ctrl.self:UpdatePartyChangeData(partyData)
end



--改变召唤师技能
function DraftHeroSelectAPI:SetPlayerSkillBy20(skilldata)
  self.ctrl.self:ChangePlayerSkill(skilldata)
end

--购买皮肤成功
function DraftHeroSelectAPI:SetParamBy19(skinid)

end

--聊天初始化
function DraftHeroSelectAPI:ChatInit(partyId)
  self.ctrl_chat.self:Init(partyId)
end

--聊天
function DraftHeroSelectAPI:SetPlayerChat(data)
  self.ctrl.self:SetPlayerChat(data)
end

--符文
function DraftHeroSelectAPI:RuneInit()
  self.ctrl_rune.self:Init()
end
function DraftHeroSelectAPI:SendSelectRunePageId(pageid)
  self.ctrl.self:NetChangeRune(pageid)
end
function DraftHeroSelectAPI:SetSelectRunePageId(pageid)
  self.ctrl_rune.self:SetRunePageId(pageid)
end
function DraftHeroSelectAPI:GetDefaultRunePageId()
  return self.ctrl_rune.self:GetDefaultRunePageId()
end

function DraftHeroSelectAPI:OnDestroy()
  self.this = nil
  DraftHeroSelectAPI.Instance = nil
  self = nil
end