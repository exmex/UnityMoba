
class("UIDisplayMessage")
----------------------------------------------------
function UIDisplayMessage:Awake(this) 
  self.this = this  
  -------------------------------------
  UIDisplayMessage.Instance=self;
  -------------------------------------
  
  self.animator = self.this:GetComponent("Animator");

    self.Bg=self.this.transform:FindChild("Bg"):GetComponent("UnityEngine.UI.Image");
  if(self.this.transform:FindChild("IconLeft")~=nil)then
  self.iconLeft=self.this.transform:FindChild("IconLeft"):GetComponent("UnityEngine.UI.Image"); end
   if(self.this.transform:FindChild("IconRight")~=nil)then
  self.iconRight=self.this.transform:FindChild("IconRight"):GetComponent("UnityEngine.UI.Image"); end
 if(self.this.transform:FindChild("IconLeft/Cell")~=nil)then
  self.cellLeft=self.this.transform:FindChild("IconLeft/Cell"):GetComponent("UnityEngine.UI.Image");end
   if(self.this.transform:FindChild("IconRight/Cell")~=nil)then
  self.cellRight=self.this.transform:FindChild("IconRight/Cell"):GetComponent("UnityEngine.UI.Image");end

end
----------------------------------------------------
function UIDisplayMessage:Start()

end
----------------------------------------------------
function UIDisplayMessage:OnDestroy() 
  
  
  ------------------------------------
  UIDisplayMessage.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
-----------------------------------------------------
function UIDisplayMessage:DisplayMessage(bg,anim,Type,amount,killerIsAlly,killerIcon,victimIcon)

  if(self.iconLeft~=nil)then
 
    if(killerIcon~=0 and killerIcon~="" and killerIcon~=nil)then
      self.iconLeft.sprite=UITools.GetSpriteBattle("uibattle",killerIcon);
    end
  end

  if(self.iconRight~=nil)then
   
    if(victimIcon~=0 and victimIcon~="" and victimIcon~=nil)then
      self.iconRight.sprite=UITools.GetSpriteBattle("uibattle",victimIcon);
    end
  end

  if(self.cellLeft~=nil)then
    if(killerIsAlly)then
      self.cellLeft.sprite=UITools.GetSpriteBattle("uibattle","BUI-CellAlly");
    else
      self.cellLeft.sprite=UITools.GetSpriteBattle("uibattle","BUI-CellEnemy");
    end
  end

  if(self.cellRight~=nil)then
    if(killerIsAlly)then
      self.cellRight.sprite=UITools.GetSpriteBattle("uibattle","BUI-CellEnemy");
    else
      self.cellRight.sprite=UITools.GetSpriteBattle("uibattle","BUI-CellAlly");
    end
  end

  if(self.Bg~=nil)then
    self.Bg.sprite=bg  --UITools.GetSpriteBattle("uibattle",bg);
  end

  self.animator:SetTrigger(anim);
	
  --[[
	if(damageType==0)then  --物理
      if (critical) then
        UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater").numberType = damageType;
        UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater"):SetValue ( damage);
         UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater").critical = critical;
        self.animator:SetTrigger("Crit");
      else
        UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater").numberType = damageType;
        UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater"):SetValue ( damage);
        self.animator:SetTrigger("Normal");
      end    	
	elseif(damageType==1)then  --法术
      if (critical) then
        UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater").numberType = damageType;
        UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater"):SetValue ( damage);
         UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater").critical = critical;

        self.animator:SetTrigger("Crit");
      else
        UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater").numberType = damageType;
        UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater"):SetValue ( damage);
        self.animator:SetTrigger("Normal");
      end      
    elseif(damageType==2)then  --回血
      UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater").numberType = damageType;
      UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater"):SetValue ( damage);
      self.animator:SetTrigger("Normal");
    elseif(damageType==4)then  --真实伤害
      UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater").numberType = damageType;
      UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater"):SetValue ( damage);
      self.animator:SetTrigger("Normal");
    elseif(damageType==6)then  --金钱	
      UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater").numberType = damageType;
      UITools.GetLuaScript(self.this.transform:FindChild("Number").gameObject,"Logic.UICommon.UINumberCreater"):SetValue ( damage);
      self.animator:SetTrigger("Normal");
	end
--]]
end