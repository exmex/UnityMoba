
class("UINumberCreater")
----------------------------------------------------
function UINumberCreater:Awake(this) 
  self.this = this  
  -------------------------------------
  UINumberCreater.Instance=self;
  -------------------------------------
  self.numberType=nil;
  self.distance=18
  self.length=0
  self.type="";
  self.critical=false;
end
----------------------------------------------------
function UINumberCreater:Start()
	-- self.numberType=1
 -- self:SetValue(567)
end
----------------------------------------------------
function UINumberCreater:OnDestroy() 
  
  
  ------------------------------------
  UINumberCreater.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
-----------------------------------------------------
function UINumberCreater:SetValue(v)
    
    	--UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater").numberType = damageType;
    	--UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater").Value = damage;
  if(self.numberType==0)then --物理
  self.type="a";  self.distance=14;
	elseif(self.numberType==1)then  --法术
    	self.type="m";  self.distance=14;
  elseif(self.numberType==2)then  --回血
      self.type="c";  self.distance=14;
  elseif(self.numberType==4)then  --真实伤害
      self.type="t";  self.distance=14;
  elseif(self.numberType==6)then  --金钱	
      self.type="g";  self.distance=14;
	end

  
  
  local s= tostring( math.floor(v))      
  if(type(v)~="number")then Debugger.LogError("非数字类型" .. v) return end
  if(v<0)then Debugger.LogError("伤害负数" .. v) return end

	self.length=#s
  for i=1,self.length,1 do
      local go=UIPool.Instance:Get(self.type ..  string.sub(s,i,i) );
    	go.transform:SetParent(self.this.transform)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.New(    self.distance*((i-1)-0.5*self.length+0.5)    ,0,0)
      UIPool.Instance:ReturnDelay(go, 0.95)
  end

  if(self.critical and self.numberType==0)then --暴击且物理
      local go=UIPool.Instance:Get("aCrit" );
      go.transform:SetParent(self.this.transform)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.New(    self.distance*(-0.5*self.length+0.5-1.5)    ,0,0)
      UIPool.Instance:ReturnDelay(go, 0.95)
  end
  if(self.critical and self.numberType==1)then --暴击且法术
  
      local go=UIPool.Instance:Get("mCrit" );
      go.transform:SetParent(self.this.transform)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.New(    self.distance*(-0.5*self.length+0.5-1.5)    ,0,0)
      UIPool.Instance:ReturnDelay(go, 0.95)
  end
  if(self.numberType==2)then --回血
      local go=UIPool.Instance:Get("cAdd" );
      go.transform:SetParent(self.this.transform)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.New(    self.distance*(-0.5*self.length+0.5-1.5)    ,0,0)
      UIPool.Instance:ReturnDelay(go, 0.95)
  end
  if(self.numberType==6)then --金钱
      local go=UIPool.Instance:Get("gAdd" );
      go.transform:SetParent(self.this.transform)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.New(    self.distance*(-0.5*self.length+0.5-1.5)    ,0,0)
      UIPool.Instance:ReturnDelay(go, 0.95)
  end
  

end