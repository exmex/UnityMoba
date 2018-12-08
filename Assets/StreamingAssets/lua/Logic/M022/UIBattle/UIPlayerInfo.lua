--Maintenance By WYL

require "Logic.UICommon.Static.UITools"

class("UIPlayerInfo")
----------------------------------------------------
function UIPlayerInfo:Awake(this) 
  self.this = this  
  -------------------------------------
  UIPlayerInfo.Instance=self;
  -------------------------------------
  self:SetParam()
  self.heroUiMountPoint=nil
  --self.heroUiMountPoint=self.this.transforms[0];
  
  self.canStartC=true;
end
function UIPlayerInfo:OnEnable()
  --需要重置的信息
  self.canStartC=true
end
----------------------------------------------------
function UIPlayerInfo:Start()
  
  self.UIDamage=UITools.GetLuaScript(self.this.transform:FindChild("Damages").gameObject,"Logic.M022.UIBattle.UIDamage")
  --self:SetState(4,20)
  --self:SetUIOwner(1)
  --self:SetPlayerInfo(1,6050)
  --self:SetPlayerInfo(1,2050)
  --self:ShowChat("智障就别来玩游戏好吗？--无脑喷患者")
  --self:ShowHonor(14) --time预留
end
----------------------------------------------------
function UIPlayerInfo:OnDestroy() 
  
  
  ------------------------------------
  UIPlayerInfo.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end

----------------------------------------------------
function UIPlayerInfo:SetParam()
    self.TipWarning=self.this.transform:FindChild("Tips/Warning").gameObject
    ---------------减益状态----------------
    self.DebuffTop=self.this.transform:FindChild("Hero/Debuff/Top").gameObject
    self.DebuffFg=self.this.transform:FindChild("Hero/Debuff/Top/Bar/BarFg"):GetComponent("UnityEngine.UI.Image");
    self.DebuffIcon=self.this.transform:FindChild("Hero/Debuff/Top/Icons/Striking"):GetComponent("UnityEngine.UI.Image");
    self.DebuffIconGO=self.this.transform:FindChild("Hero/Debuff/Top/Icons/Striking").gameObject
    self.DebuffTexts=self.this.transform:FindChild("Hero/Debuff/Texts")

    self.BarGoHome=self.this.transform:FindChild("Hero/Debuff/BarGoHome").gameObject
    self.BarGoHomeFg=self.this.transform:FindChild("Hero/Debuff/BarGoHome/BarFg"):GetComponent("UnityEngine.UI.Image");

    self.Honor=self.this.transform:FindChild("Hero/Honor").gameObject
    self.HonorImage=self.this.transform:FindChild("Hero/Honor"):GetComponent("UnityEngine.UI.Image");

    --self.coDebuff =coroutine.start( self.LerpDebuff,self,3);
    --self.coHonor=coroutine.start(self.HideHonor,self, 60,self.Honor);

    self.Chat=self.this.transform:FindChild("Hero/Chat").gameObject
    self.ChatText=self.this.transform:FindChild("Hero/Chat/Text"):GetComponent("UnityEngine.UI.Text");
    ---------------减益状态----------------

    self.uiOwnerType={}
    self.lineStoreList={}
    self.lastBloodValue=0;

	  self.y=GameObject.Find("PanelRoot"):GetComponent("UnityEngine.UI.CanvasScaler").referenceResolution.y;
    self.x=GameObject.Find("PanelRoot"):GetComponent("UnityEngine.UI.CanvasScaler").referenceResolution.x;
    self.camera= Camera.main --GameObject.Find("GameLogic"):GetComponent("Camera");
    self.wash= self.x /self.y;

    self.cHpValue=1;
    
    self.LerpGround=self.this.transform:FindChild("Hero/LerpGround"):GetComponent("UnityEngine.UI.Image");
    self.foreGroundRT= self.this.transform:FindChild("Hero/ForeGround"):GetComponent("RectTransform");
    --self.lineThick=self.this.transform:FindChild("Hero/ForeGround/LineThick").gameObject

    --Hero
    self.name = self.this.transform:FindChild("Hero/Name"):GetComponent("UnityEngine.UI.Text");
    self.hero = self.this.transform:FindChild("Hero").gameObject
    self.heroHpImage1 =  self.this.transform:FindChild("Hero/ForeGround/ForeGround1"):GetComponent("UnityEngine.UI.Image");
    self.heroHpImage2 =  self.this.transform:FindChild("Hero/ForeGround/ForeGround2"):GetComponent("UnityEngine.UI.Image");
    self.heroHpImage3 =  self.this.transform:FindChild("Hero/ForeGround/ForeGround3"):GetComponent("UnityEngine.UI.Image");
    self.ShieldGround =  self.this.transform:FindChild("Hero/ShieldGround"):GetComponent("UnityEngine.UI.Image");
    self.heroMpImage =  self.this.transform:FindChild("Hero/MP"):GetComponent("UnityEngine.UI.Image");
    self.heroExpImage =  self.this.transform:FindChild("Hero/EXP"):GetComponent("UnityEngine.UI.Image");
    self.heroBgNormal = self.this.transform:FindChild("Hero/Bg").gameObject
    self.heroBgSimple = self.this.transform:FindChild("Hero/BgSimple").gameObject
    self.heroLevelText = self.this.transform:FindChild("Hero/Level"):GetComponent("UnityEngine.UI.Text");
    --Tower
    self.tower= self.this.transform:FindChild("Tower").gameObject
    self.towerHp1= self.this.transform:FindChild("Tower/HP1"):GetComponent("UnityEngine.UI.Image");
    self.towerHp2= self.this.transform:FindChild("Tower/HP2"):GetComponent("UnityEngine.UI.Image");
    self.towerIcon= self.this.transform:FindChild("Tower/Icon"):GetComponent("UnityEngine.UI.Image");
    --Soldier
    self.soldier=self.this.transform:FindChild("Soldier").gameObject
    self.soldierHp1=self.this.transform:FindChild("Soldier/HP1"):GetComponent("UnityEngine.UI.Image");
    self.soldierHp2=self.this.transform:FindChild("Soldier/HP2"):GetComponent("UnityEngine.UI.Image");
    --私有存储 
    self.HpImage=nil
    self.MpImage=nil
    self.ExpImage=nil;
    self.LevelText=nil

    self.BgSimple=nil
    self.BgNormal=nil
    self.hpMax=nil
    self.mpMax=nil
    self.expMax=nil
    
end
---------------------设置锚点-----------------------
function UIPlayerInfo:SetHeroUiMountPoint(transform)
  self.heroUiMountPoint=transform
end
---------------------设置UIOwner-----------------
function UIPlayerInfo:SetUIOwner(uiOwnerType)
  if(self==nil)then return end
  self.uiOwnerType=uiOwnerType
  -- self.hero:SetActive(false);
  -- self.tower:SetActive(false);
  -- self.soldier:SetActive(false);
  ----------------状态重置---------------
  self.TipWarning:SetActive(false);
  
  ---------------------------------------
  if(uiOwnerType==1)then  --友方英雄
    self.hero:SetActive(true); Object.Destroy(self.tower); Object.Destroy(self.soldier);
    self.HpImage=self.heroHpImage1   
    self.heroHpImage1.gameObject:SetActive(true); 
    self.heroHpImage2.gameObject:SetActive(false); 
    self.heroHpImage3.gameObject:SetActive(false);

    self.DebuffTop:SetActive(false);
    self.DebuffIconGO:SetActive(false);  
    self.BarGoHome:SetActive(false); 

    --self.heroHpImage.sprite=UITools.GetSpriteBattle("uibattle","BUI-HpHeroAlly");
    self.MpImage=self.heroMpImage 
    self.LevelText= self.heroLevelText 
    self.BgSimple= self.heroBgSimple  
    self.BgNormal= self.heroBgNormal 
    self.ExpImage= self.heroExpImage 

    self.Chat:SetActive(false); 
  elseif(uiOwnerType==2)then  --敌方英雄
    self.hero:SetActive(true); Object.Destroy(self.tower); Object.Destroy(self.soldier);
    self.HpImage=self.heroHpImage2   
    self.heroHpImage2.gameObject:SetActive(true); 
    self.heroHpImage1.gameObject:SetActive(false); 
    self.heroHpImage3.gameObject:SetActive(false);

    self.DebuffTop:SetActive(false);
    self.DebuffIconGO:SetActive(false);  
    self.BarGoHome:SetActive(false); 

    --self.heroHpImage.sprite=UITools.GetSpriteBattle("uibattle","BUI-HpHeroEnemy");
    self.MpImage=self.heroMpImage 
    self.LevelText= self.heroLevelText 
    self.BgSimple= self.heroBgSimple  
    self.BgNormal= self.heroBgNormal 
    self.ExpImage= self.heroExpImage 

    self.Chat:SetActive(false); 
  elseif(uiOwnerType==3)then  --自己
    self.hero:SetActive(true); Object.Destroy(self.tower); Object.Destroy(self.soldier);
    self.HpImage=self.heroHpImage3    
    self.heroHpImage3.gameObject:SetActive(true); 
    self.heroHpImage1.gameObject:SetActive(false); 
    self.heroHpImage2.gameObject:SetActive(false);

    self.DebuffTop:SetActive(false);
    self.DebuffIconGO:SetActive(false);  
    self.BarGoHome:SetActive(false); 

    --self.heroHpImage.sprite=UITools.GetSpriteBattle("uibattle","BUI-HpHeroSelf");
    self.MpImage=self.heroMpImage 
    self.LevelText= self.heroLevelText 
    self.BgSimple= self.heroBgSimple  
    self.BgNormal= self.heroBgNormal 
    self.ExpImage= self.heroExpImage

    self.Chat:SetActive(false); 
  elseif(uiOwnerType==4)then  --友方塔
    self.tower:SetActive(true); Object.Destroy(self.hero); Object.Destroy(self.soldier);
    self.HpImage=  self.towerHp1    self.towerHp1.gameObject:SetActive(true); self.towerHp2.gameObject:SetActive(false);
    self.towerIcon.sprite=UITools.GetSpriteBattle("uibattle","BUI-TowerIconAlly");
    --self.towerHp.sprite=UITools.GetSpriteBattle("uibattle","BUI-HpHeroAlly");
  elseif(uiOwnerType==5)then  --敌方塔
    self.tower:SetActive(true); Object.Destroy(self.hero); Object.Destroy(self.soldier);
    self.HpImage=  self.towerHp2    self.towerHp2.gameObject:SetActive(true); self.towerHp1.gameObject:SetActive(false);
    self.towerIcon.sprite=UITools.GetSpriteBattle("uibattle","BUI-TowerIconEnemy"); 
    --self.towerHp.sprite=UITools.GetSpriteBattle("uibattle","BUI-HpHeroEnemy");
  elseif(uiOwnerType==6)then  --友方小兵
    self.soldier:SetActive(true); Object.Destroy(self.hero); Object.Destroy(self.tower);
    self.HpImage=self.soldierHp1     self.soldierHp1.gameObject:SetActive(true); self.soldierHp2.gameObject:SetActive(false); 
    --self.soldierHp.sprite=UITools.GetSpriteBattle("uibattle","BUI-HpAlly");
  elseif(uiOwnerType==7)then  --敌方小兵
    self.soldier:SetActive(true); Object.Destroy(self.hero); Object.Destroy(self.tower);
    self.HpImage=self.soldierHp2      self.soldierHp2.gameObject:SetActive(true); self.soldierHp1.gameObject:SetActive(false); 
    --self.soldierHp.sprite=UITools.GetSpriteBattle("uibattle","BUI-HpEnemy");
  end

end 
---------------------隐藏血条等信息-------------
function UIPlayerInfo:HideHPInfo(bool)

  if( self.uiOwnerType==1)then  --友方英雄
    self.hero:SetActive(bool);
   
  elseif( self.uiOwnerType==2)then  --敌方英雄
    self.hero:SetActive(bool);
  
  elseif( self.uiOwnerType==3)then  --自己
    self.hero:SetActive(bool);
  
  elseif( self.uiOwnerType==4)then  --友方塔
    self.tower:SetActive(bool);

  elseif( self.uiOwnerType==5)then  --敌方塔
    self.tower:SetActive(bool);
  
  elseif( self.uiOwnerType==6)then  --友方小兵
    self.soldier:SetActive(bool);
    
  elseif( self.uiOwnerType==7)then  --敌方小兵
    self.soldier:SetActive(bool);
  end

  

end

--------------------------------------------------------------------------

function UIPlayerInfo:SetPlayerInfo(maxHP,currentHP,maxMP,currentMP,level,name,maxEXP,currentEXP,currentShield)
    
    --最大HP
    self.hpMax=maxHP

    if(self.uiOwnerType==1 or   self.uiOwnerType==2 or   self.uiOwnerType==3)then
      
      self:SetLattice(maxHP)

      --最大MP
      if(maxMP~=nil)then
        self.mpMax=maxMP
      end
      -- if(self.BgSimple~=nil and param==0)then
        --self.BgSimple:SetActive(true);
        --self.BgNormal:SetActive(false);
      --  end
      --当前MP
      if(currentEXP~=nil and self.MpImage~=nil)then
         self.MpImage.fillAmount=currentMP/self.mpMax
      end

      --等级
      if(level~=nil and self.LevelText~=nil)then
        self.LevelText.text=level
      end
      --名字
      if(name~=nil and self.name~=nil)then
        self.name.text=name
      end

      --最大EXP
      if(maxEXP~=nil)then
        self.expMax=maxEXP
      end
      --当前EXP
      if(currentEXP~=nil and self.ExpImage~=nil)then
        self.ExpImage.fillAmount=currentEXP/self.expMax
      end
      --end

    end
    

    if(self.uiOwnerType==1 or   self.uiOwnerType==2 or   self.uiOwnerType==3)then
      --当前HP
      if(currentShield==nil or currentShield==0 )then
        self.HpImage.fillAmount= currentHP/self.hpMax 
        self.ShieldGround.fillAmount= 0
      elseif(currentShield~=nil and currentShield~=0)then
        self.HpImage.fillAmount= (currentHP-currentShield)/self.hpMax 
        self.ShieldGround.fillAmount= currentHP/self.hpMax
      end
    else
      self.HpImage.fillAmount= currentHP/self.hpMax 
    end
    if(self.uiOwnerType==1 or   self.uiOwnerType==2 or   self.uiOwnerType==3)then
      if(self.cHpValue>self.HpImage.fillAmount and math.abs(self.cHpValue-self.HpImage.fillAmount)>0.01 )then
      --if( not math.Approximately(self.cHpValue, self.HpImage.fillAmount) )then
        --伤害数字  
          --血条效果
          if(self.canStartC==true)then  
            coroutine.start( self.LerpHP,self)
          end
      elseif(self.cHpValue<self.HpImage.fillAmount and math.abs(self.cHpValue-self.HpImage.fillAmount)>0.1 )then
          --血条效果
          if(self.canStartC==true)then  
            coroutine.start(  self.LerpHP,self)
          end
      end
    end
 

end

------------------------只在最大血量改变时执行一次------------------------


function UIPlayerInfo:SetLattice(bloodValue)
  
  if(bloodValue==self.lastBloodValue)then return end 
  if(self.foreGroundRT==nil)then return end
  
  if(self.uiOwnerType==1 or   self.uiOwnerType==2 or   self.uiOwnerType==3)then
    self.lastBloodValue=bloodValue

    for k,v in pairs(self.lineStoreList) do
      UIPool.Instance:Return(v)
    end 
    self.lineStoreList={}
    
    local v=bloodValue/self.foreGroundRT.rect.width;
    for i=1,bloodValue,1000 do
      local go= UIPool.Instance:Get("LineThick");
      go.transform:SetParent(self.foreGroundRT);
      go.transform.localPosition=Vector3.New(i/v-0.5*self.foreGroundRT.rect.width,0,0);
      go.transform.localScale=Vector3.one
      go.transform.localRotation = Quaternion.identity
      table.insert(self.lineStoreList,go)
    end
  end

end
function UIPlayerInfo:LerpHP()
  self.canStartC=false  
  --while( not math.Approximately(self.cHpValue, self.HpImage.fillAmount)) do
  while( math.abs(self.cHpValue-self.HpImage.fillAmount)>0.01 )do
    if(self.HpImage~=nil )then
      self.cHpValue=Mathf.Lerp(self.cHpValue, self.HpImage.fillAmount, Time.deltaTime * 5) 
    --if(math.abs(self.scrollRect.horizontalNormalizedPosition - self.f)<0.001)then
    --  self.scrollRect.horizontalNormalizedPosition =self.f
    --end
      self.LerpGround.fillAmount=self.cHpValue      -- 0.0001
     
    end
    coroutine.step()
  end
  self.cHpValue=self.HpImage.fillAmount
  self.LerpGround.fillAmount=self.cHpValue 
  
 
  self.canStartC=true
end
---------------展示信息----------------
function UIPlayerInfo:ShowSign(type,bool)
  if(type==1)then --野怪头顶叹号
    self.TipWarning:SetActive(bool);
  end
end
---------------减益状态----------------
function UIPlayerInfo:SetState(type,time)
  
  if(type==1)then --减速
    local go=UIPool.Instance:Get("DebuffDeceleration");  

    go.transform:SetParent( self.DebuffTexts) 
    go.transform.localPosition=Vector3.zero
    go.transform.localScale=Vector3.one
    go.transform.localRotation = Quaternion.identity

    UIPool.Instance:ReturnDelay(go,5)
  elseif(type==2)then --恢复生命与法力
    local go=UIPool.Instance:Get("DebuffRecover");  

    go.transform:SetParent( self.DebuffTexts) 
    go.transform.localPosition=Vector3.zero
    go.transform.localScale=Vector3.one
    go.transform.localRotation = Quaternion.identity

    UIPool.Instance:ReturnDelay(go,5)
  elseif(type==3)then --击飞
    local go=UIPool.Instance:Get("DebuffStriking"); 

    go.transform:SetParent( self.DebuffTexts) 
    go.transform.localPosition=Vector3.zero
    go.transform.localScale=Vector3.one
    go.transform.localRotation = Quaternion.identity

    UIPool.Instance:ReturnDelay(go,5)

    self.DebuffTop:SetActive(true);
    self.DebuffIconGO:SetActive(true);
    self.DebuffIcon.sprite=UITools.GetSpriteBattle("uibattle","BUI-DebuffStriking")
    if(self.coDebuff~=nil)then
      coroutine.stop(self.coDebuff);
    end
    self.coDebuff=coroutine.start(self.LerpDebuff,self, time,self.DebuffFg);
  elseif(type==4)then --眩晕
    local go=UIPool.Instance:Get("DebuffVertigo"); 

    go.transform:SetParent( self.DebuffTexts) 
    go.transform.localPosition=Vector3.zero
    go.transform.localScale=Vector3.one
    go.transform.localRotation = Quaternion.identity

    UIPool.Instance:ReturnDelay(go,5)

    self.DebuffTop:SetActive(true); 
    self.DebuffIconGO:SetActive(true);
    self.DebuffIcon.sprite=UITools.GetSpriteBattle("uibattle","BUI-DebuffVertigo")
    
    if(self.coDebuff~=nil)then
      coroutine.stop(self.coDebuff);
    end
    self.coDebuff =coroutine.start( self.LerpDebuff,self,time,self.DebuffFg);
  elseif(type==5)then --回城
    self.BarGoHome:SetActive(true); 

     if(self.coDebuff~=nil)then
      coroutine.stop(self.coDebuff);
    end
    self.coDebuff =coroutine.start(self.LerpDebuff,self, time,self.BarGoHomeFg);
   
  end

end
---------------显示勋章----------------
function UIPlayerInfo:ShowHonor(honorId) --time预留
   self.Honor:SetActive(true); 
   self.HonorImage.sprite=UITools.GetSpriteBattle("honoricon", UTGData.Instance().BattleHonorsData[tostring(honorId)].Icon)
    if(self.coHonor~=nil)then
      coroutine.stop(self.coHonor)
    end
    self.coHonor =coroutine.start( self.HideHonor,self,60,self.Honor);
end
----------------------------------------------------
function UIPlayerInfo:LerpDebuff(time,fillImage)
  local cTime=time
  while(cTime>0 ) do
    cTime=cTime-Time.deltaTime
    fillImage.fillAmount =cTime/time
    coroutine.step()
  end

  self.DebuffTop:SetActive(false);
  self.DebuffIconGO:SetActive(false);  

  self.BarGoHome:SetActive(false); 
end
----------------------------------------------------
function UIPlayerInfo:HideHonor(time,honorGo)
  coroutine.wait(60)
  honorGo:SetActive(false);
end
-----------------------聊天气泡---------------------
function UIPlayerInfo:ShowChat(words)
  --if(self.uiOwnerType==1 or   self.uiOwnerType==2 or   self.uiOwnerType==3)then --如果是英雄继续
    self.Chat:SetActive(true); 
    self.ChatText.text=words;
    --coroutine.stop(self.coDebuff);
    self.coShowChat =coroutine.start( self.HideChat,self,words);

  --end
end

function UIPlayerInfo:HideChat()
  coroutine.wait(4)
  self.Chat:SetActive(false); 
end
----------------------------------------------------
---------------------LateUpdate-----------------
--[[
function UIPlayerInfo:LateUpdate()
    if (self.heroUiMountPoint~=nil)then 
      self.this.transform.localPosition = self:WorldToScreen(self.heroUiMountPoint.position);
    end
end
--]]
----------------------------------------------------
-- function UIPlayerInfo:WorldToScreen(worldPos)
--   local screenPos = self.camera:WorldToViewportPoint(worldPos);

--   return Vector3.New((screenPos.x - 0.5) * self.y * self.wash, (screenPos.y - 0.5) * self.y, 0);
-- end