
class("UIPool")
----------------------------------------------------
function UIPool:Awake(this) 
  self.this = this  
  -------------------------------------
  UIPool.Instance=self;
  -------------------------------------
  --self.pool={EZ={"EZ1","EZ2","EZ3"}}
  self.pool={}
end
----------------------------------------------------
function UIPool:Start()
  --self.this.transform:SetParent(nil);
end
----------------------------------------------------
function UIPool:OnDestroy() 

  ------------------------------------
  UIPool.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
----------------------------------------------------
function UIPool:Get(name) 
--table.contains(UIPool.pool,name)
    if(self.pool[name]~=nil and #self.pool[name]>0 	)then
    --if(table.contains(UIPool.pool,name) and #UIPool.pool[name]>0 	)then
  	local go=self.pool[name][1];
  	table.remove(self.pool[name],1)
    go:SetActive(true);--
  	return go;
  else 
    if(self.this.transform:FindChild("OriginalData/" .. name)==nil)then Debugger.LogError("UIPOOL无此预制体:" .. name) end 
  	local go=GameObject.Instantiate(self.this.transform:FindChild("OriginalData/" .. name).gameObject);
    go.name = name;
    go:SetActive(true);--
    return go;
  end

end
----------------------------------------------------
function UIPool:Return(go) 
  if(go==nil or go.gameObject==nil)then  return; end
  go:SetActive(false);--
  go.transform:SetParent(self.this.transform);
  go.transform.localPosition = Vector3.New(0, 10000, 0); 
  if(self.pool[go.name]~=nil)then
    table.insert(self.pool[go.name],go)
  else
    self.pool[go.name]={go}
  end
end    
-----------------------------------------------------
function UIPool:ReturnDelay(go,time,obj,func)
  --if(go==nil or go.gameObject==nil)then return; end
  if(obj~=nil)then
    coroutine.start( self.DelayReturn,self,go,time,obj,func)  
  else
    coroutine.start( self.DelayReturn,self,go,time)   
  end
end    
function UIPool:DelayReturn(go,time,obj,func)

  coroutine.wait(time)
  --if(go==nil or go.gameObject==nil)then return; end
  if(obj~=nil)then func(obj) end
  self:Return(go) 
end   
------------------------------------------------------