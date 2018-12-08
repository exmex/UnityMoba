require"Logic.UICommon.Static.UITools"
class("UITest")
----------------------------------------------------
function UITest:Awake(this) 
  self.this = this
  -------------------------------------

end
----------------------------------------------------
function UITest:Start()
  self.mScroll=self.this.transforms[0]:GetComponent("ScrollRect");
  self.mScroll.onValueChanged:AddListener(UnityAction.Vector2Self(self.De,self))  --別刪

end
----------------------------------------------------
function UITest:OnDestroy() 
  
  ------------------------------------
  self.this = nil
  self = nil
end
--------------------------------------------------
function UITest:De(v2) 

  Debugger.LogError("!")
  
end

