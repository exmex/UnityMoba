--在当前帧关闭，在下一帧打开
class{"UIShadowInNextFrame"}

----------------------------------------------------
function UIShadowInNextFrame:Awake(this) 
  self.this = this  
  
  self.target=self.this.transforms[0].gameObject;
end
----------------------------------------------------
function UIShadowInNextFrame:Start()
  
end
----------------------------------------------------
function UIShadowInNextFrame:OnDestroy()
  
  self.this = nil
  self = nil
end

function UIShadowInNextFrame:ShowInNextFrame()
   coroutine.start(UIShadowInNextFrame.OpenInNextFrame,self)
 
end

function UIShadowInNextFrame:OpenInNextFrame()  --Transform,Vector3
  target:SetActive(false);
  coroutine.step();
  target:SetActive(true);
end