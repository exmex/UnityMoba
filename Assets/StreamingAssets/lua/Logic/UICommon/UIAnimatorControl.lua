require "System.Global"

UIAnimatorControl = {}
----------------------------------------------------
function UIAnimatorControl:New(o)
  local o = o or {}
  setmetatable(o, UIAnimatorControl.lua)
  UIAnimatorControl.__index = UIAnimatorControl
  return o
end
----------------------------------------------------
function UIAnimatorControl:Awake(this) 
  self.this = this  

end
----------------------------------------------------
function UIAnimatorControl:Start()
  
  self.animator = self.this:GetComponent("Animator");
  

  
end

function UIAnimatorControl:OnEnable()
   --Debugger.LogError(self.animator)    

  self.animator:SetInteger( "Show" ,1 );
end
----------------------------------------------------
function UIAnimatorControl:OnDestroy()
  
  self.this = nil
  self = nil
  
end