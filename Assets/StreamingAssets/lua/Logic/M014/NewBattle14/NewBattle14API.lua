require "System.Global"

class("NewBattle14API")

function NewBattle14API:Awake(this) 
  self.this = this
  self.newBattle14Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
  NewBattle14API.Instance = self

  self.Animator1=this.transforms[1]:GetComponent("Animator");
  self.Animator2=this.transforms[2]:GetComponent("Animator");
  self.Animator3=this.transforms[3]:GetComponent("Animator");
  self.Animator4=this.transforms[3]:GetComponent("Animator");
end

function NewBattle14API:Start()
  --UnityEngine.Resources.UnloadUnusedAssets();
end

function NewBattle14API:ShowPVPPanel()
  self.this.transform:SetAsLastSibling()
  self.newBattle14Ctrl.self:ShowPVPPanel()
  self.Animator1:Play("M014-PVP",0,0) 
end

function NewBattle14API:ShowComputerPanel()
  self.this.transform:SetAsLastSibling()
  self.newBattle14Ctrl.self:ShowComputerPanel()
  self.Animator2:Play("M014-PVP",0,0) 
end

function NewBattle14API:ShowRoomPanel()
  self.this.transform:SetAsLastSibling()
  self.newBattle14Ctrl.self:ShowRoomPanel()
  self.Animator3:Play("M014-Room",0,0) 
end

function NewBattle14API:ShowEntPanel()
  self.this.transform:SetAsLastSibling()
  self.newBattle14Ctrl.self:ShowEntPanel()
end

function NewBattle14API:DestroySelf()
  self.newBattle14Ctrl.self:DestroySelf()
end

function  NewBattle14API:ResetPanel()
  -- body
  
end

function NewBattle14API:OnDestroy()   
  NewBattle14API.Instance = nil;
  self.this = nil
  self = nil

end