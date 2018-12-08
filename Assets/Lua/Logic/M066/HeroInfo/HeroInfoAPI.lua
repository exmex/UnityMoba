require "System.Global"

class("HeroInfoAPI")

function HeroInfoAPI:Awake(this)
  self.this = this
  local scriptPanel = {}
  self.panel = self.this.transforms[0]
  for i = 1,3 do
    --print("^^^^^^^^^ " .. self.panel:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[i-1].luaScript)
    if self.panel:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[i-1].luaScript == "Logic.M066.HeroInfo.HeroInfoController" then
      self.heroInfoController = self.panel:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[i-1]
    end
  end  
  HeroInfoAPI.Instance = self
  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end
function HeroInfoAPI:Start()
  self:ResetPanel()
end

function HeroInfoAPI:ResetPanel( )
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  UTGDataOperator.Instance:SetResourceList(topAPI)
  topAPI:GoToPosition("HeroInfoPanel")
  topAPI:ShowControl(3)
  topAPI:InitTop(self.heroInfoController.self,HeroInfoController.DestroySelf,nil,nil,"姬神详情")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
end
function HeroInfoAPI:Init(heroId,list)
  self.heroInfoController.self:InitSelectHero(heroId,list)
end

function  HeroInfoAPI:InitTop()
  -- body
  self.heroInfoController.self:DoInitTop()
end

function HeroInfoAPI:InitCenterBySkinId(skinId,skinList)
  self.heroInfoController.self:DoInitCenterBySkinId(skinId,skinList)
end


function HeroInfoAPI:OnDestroy()
  self.this = nil 
  self = nil
  HeroInfoAPI.Instance = nil
end



