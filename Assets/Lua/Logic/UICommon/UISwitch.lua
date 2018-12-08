
class("UISwitch")
----------------------------------------------------
function UISwitch:Awake(this) 
  self.this = this  
  -------------------------------------
  UISwitch.Instance=self;
  -------------------------------------
  
  
end
----------------------------------------------------
function UISwitch:Start()

end
----------------------------------------------------
function UISwitch:OnDestroy() 
  
  
  ------------------------------------
  UISwitch.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end