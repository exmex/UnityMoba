--Maintenance By YL

class("HintAPI")
----------------------------------------------------
function HintAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  HintAPI.Instance=self;
  -------------------------------------
  self.hintText=self.this.transform:FindChild("Center/Pop/Text")
  self.buttonEnter=self.this.transform:FindChild("Center/Pop/ButtonEnter").gameObject;
end
----------------------------------------------------
function HintAPI:Start()
local listener = NTGEventTriggerProxy.Get( self.buttonEnter);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( HintAPI.OnEnterButtonDown,self);
end
----------------------------------------------------


function HintAPI:OnDestroy() 
  
  
  ------------------------------------
  HintAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
----------------------------------------------------
function HintAPI:Hint(desc)
  self.hintText:GetComponent("UnityEngine.UI.Text").text=desc;
end
--------------------------------
function HintAPI:OnEnterButtonDown()
  Object.Destroy(self.this.gameObject);
end