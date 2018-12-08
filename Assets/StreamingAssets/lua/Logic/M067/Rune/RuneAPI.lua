require "System.Global"

class("RuneAPI")

function RuneAPI:Awake(this)
  self.this = this
  self.runeCtrl = this.transforms[0]:GetComponent("NTGLuaScript")
  RuneAPI.Instance = self
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end

function RuneAPI:Start()
  self:ResetPanel()
end

function RuneAPI:UpdateInfo()
  self.runeCtrl.self:UpdateCreateRune()
  self.runeCtrl.self:UpdateRuneSlots()
  self.runeCtrl.self:UpdateShowInfo()
  self.runeCtrl.self:UpdateRuneBag()
  self.runeCtrl.self:UpdatePageList()
  self.runeCtrl.self:UpdateCreateAndResolveWindow()
  --print("3333333333333")
end

function RuneAPI:ResetPanel( )
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("RunePanel/RuneCtrl/Bg")
  topAPI:ShowControl(3)
  topAPI:InitTop(self.runeCtrl.self,RuneCtrl.OnBackBtnClick,nil,nil,"芯片制作")
  topAPI:InitResource(0)
  topAPI:HideSom("Text")
  UTGDataOperator.Instance:SetResourceList(topAPI)
end

function RuneAPI:InitRuneRecommend(roleId,level)
  -- body
  self.runeCtrl.self:InitRuneRecommend(roleId,level)
end

function RuneAPI:GoToTab3()
  -- body
  self.runeCtrl.self:GoToTab3()
end

function RuneAPI:OnDestroy()
  RuneAPI.Instance = nil
  self.this = nil
  self = nil
end