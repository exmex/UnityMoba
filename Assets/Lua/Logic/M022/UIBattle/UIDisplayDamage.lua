
class("UIDisplayDamage")
----------------------------------------------------
function UIDisplayDamage:Awake(this) 
  self.this = this  
  -------------------------------------
  UIDisplayDamage.Instance=self;
  -------------------------------------
  
  self.animator = self.this:GetComponent("Animator");
end
----------------------------------------------------
function UIDisplayDamage:Start()
  
end
----------------------------------------------------
function UIDisplayDamage:OnDestroy() 
  
  
  ------------------------------------
  UIDisplayDamage.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
-----------------------------------------------------
function UIDisplayDamage:DisplayDamage(damageType,damage,critical)
	local numberCreater = UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater")
	  if(damageType==0)then  --物理
      if (critical) then
        numberCreater.critical = critical; 
        numberCreater.numberType = damageType;
        numberCreater:SetValue ( damage);
   
        self.animator:SetTrigger("Crit");
      else
        numberCreater.critical = critical; 
        numberCreater.numberType = damageType;
        numberCreater:SetValue ( damage);
        self.this.transform.localPosition = Vector3.New(Mathf.Random(-20, 20),Mathf.Random(0, 20),0);
        self.animator:SetTrigger("Normal");
      end    	
	  elseif(damageType==1)then  --法术
      if (critical) then
        numberCreater.critical = critical; 
        numberCreater.numberType = damageType;
        numberCreater:SetValue ( damage);
      

        self.animator:SetTrigger("Crit");
      else
        numberCreater.critical = critical; 
        numberCreater.numberType = damageType;
        numberCreater:SetValue ( damage);
        self.this.transform.localPosition = Vector3.New(Mathf.Random(-20, 20),Mathf.Random(0, 20),0);
        self.animator:SetTrigger("Normal");
      end      
    elseif(damageType==2)then  --回血
      numberCreater.critical = critical; 
      numberCreater.numberType = damageType;
      numberCreater:SetValue ( damage);
   
      self.animator:SetTrigger("Recover");
    elseif(damageType==4)then  --真实伤害
      numberCreater.critical = critical; 
      numberCreater.numberType = damageType;
      numberCreater:SetValue ( damage);
      self.this.transform.localPosition = Vector3.New(Mathf.Random(-20, 20),Mathf.Random(0, 20),0);
      self.animator:SetTrigger("Normal");
    elseif(damageType==6)then  --金钱	
      numberCreater.critical = critical; 
      numberCreater.numberType = damageType;
      numberCreater:SetValue ( damage);

      self.animator:SetTrigger("Recover");
	end

end