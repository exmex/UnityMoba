
class("UIFxMatch")
----------------------------------------------------
function UIFxMatch:Awake(this) 
  self.this = this  
  -------------------------------------
  UIFxMatch.Instance=self;
  -------------------------------------
  self.tableFXs={}
  table.insert(self.tableFXs, self.this.gameObject)
  
end
----------------------------------------------------
function UIFxMatch:Start()

	    --特效寻找材质
    for i,v in ipairs(self.tableFXs) do 
      local btn = self.tableFXs[i]:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
      for k = 0,btn.Length - 1 do
        self.tableFXs[i]:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
      end
    end

end
----------------------------------------------------
function UIFxMatch:OnDestroy() 
  
  
  ------------------------------------
  UIFxMatch.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end