
class("UIPlayerAPI")
----------------------------------------------------
function UIPlayerAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  UIPlayerAPI.Instance=self;
  -------------------------------------
  
  
end
----------------------------------------------------
function UIPlayerAPI:Start()
	self.UIPool=self.this.transform:FindChild("UIPool")
	self.UIPool:SetParent(nil);
end
----------------------------------------------------
function UIPlayerAPI:OnDestroy() 
  
  ------------------------------------
  UIPlayerAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end