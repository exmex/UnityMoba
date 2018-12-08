
class("UItemplet")
----------------------------------------------------
function UItemplet:Awake(this) 
  self.this = this  
  -------------------------------------
  UItemplet.Instance=self;
  -------------------------------------
  
  
end
----------------------------------------------------
function UItemplet:Start()

end
----------------------------------------------------
function UItemplet:OnDestroy() 
  
  
  ------------------------------------
  UItemplet.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end