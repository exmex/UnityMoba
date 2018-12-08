
class("UISortingOrderPlus")
----------------------------------------------------
function UISortingOrderPlus:Awake(this) 
  self.this = this  
  -------------------------------------
  UISortingOrderPlus.Instance=self;
  if UISortingOrderPlus.order == nil then
  	UISortingOrderPlus.order = 100
  end
  -------------------------------------
  self.Type=self.this.ints[0]; --枚举   0：Panel   1：特效
  --self.order=self.this.ints[1]; --层级
end
----------------------------------------------------
function UISortingOrderPlus:Start()
	if(self.Type==0)then
		self.canvas = self.this:GetComponent("Canvas")
		if(self.canvas==nil)then
			self.canvas = self.this.gameObject:AddComponent(NTGLuaScript.GetType("UnityEngine.Canvas"))
			self.this.gameObject:AddComponent(NTGLuaScript.GetType("UnityEngine.UI.GraphicRaycaster"))
			self.canvas.overrideSorting = true;
			self.canvas.sortingOrder = UISortingOrderPlus.order; 
			UISortingOrderPlus.order = UISortingOrderPlus.order + 1
		end
    else
		self.renders = self.this:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))

		for i=1,self.renders.Length,1 do
			self.renders[i-1].sortingOrder = UISortingOrderPlus.order;
      UISortingOrderPlus.order = UISortingOrderPlus.order + 1 
		end
		
	end

end
----------------------------------------------------
function UISortingOrderPlus:OnDestroy() 
  
  UISortingOrderPlus.order = UISortingOrderPlus.order - 1
  ------------------------------------
  UISortingOrderPlus.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
