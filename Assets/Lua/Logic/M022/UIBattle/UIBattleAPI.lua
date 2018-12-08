--Maintenance By WYL
require "Logic.UTGData.UTGData"
require "Logic.UICommon.Static.UITools"
require "Logic.UICommon.Static.UIQueue"
require "System.Global"

class("UIBattleAPI")
 UIBattleAPI.lastFingerIds={}  --上一帧的ID数组

function UIBattleAPI:BattleUpdate(data)
  self.GameDuration.text = data.GameDuration
  self.FPS.text = data.FPS
  self.TeamKill.text = data.TeamKill
  self.EnemyTeamKill.text = data.EnemyTeamKill
  self.PersonKill.text = data.PersonKill
  self.PersonDead.text = data.PersonDead
  self.PersonAssists.text = data.PersonAssists
  self.Coin.text = data.Coin
  self.NetworkLatency.text = data.NetworkLatency

  if data.TargetActive then
    self:SetTargetInfo(true, data.TargetIcon, data.TargetHp, data.TargetHpMax, data.TargetMp, data.TargetMpMax, data.TargetPAtk, data.TargetMAtk, data.TargetPDef, data.TargetMDef)
  else
    self:SetTargetInfo(false)
  end

  local p = data.Player

  self:SetBuff(p.unitBuffs)

  for i=1,6,1 do
    local s = data.SkillDatas[i-1]
    if s.Valid then
      self:SetSkillInfo(i, 2, s.Level)
      self:SetSkillInfo(i, 3, s.MaxCD)
      self:SetSkillInfo(i, 4, s.CD)
      self:SetSkillInfo(i, 5, s.MpEnough)
      self:SetSkillInfo(i, 6, {s.Id, s.MPCost, p.pAtk, p.mAtk, s.Level})

      if i <= 3 then
        self:SetSkillUpgrade(i, s.CanUpgrade)
      end
    end
  end

  for i=1,5 do
    local a = data.Ally[i-1]
    if a.Valid then
      self:SetAllyInfo(i, 2, a.HPRatio)
      self:SetAllyInfo(i, 3, a.SkillReady)
      self:SetAllyInfo(i, 4, a.ReviveCount)
    end
  end
  
  for i=1,5 do
    local e = data.Enemy[i-1]
    if e.Valid then
      self:SetEnemyInfo(i, 5, true)
      self:SetEnemyInfo(i, 0, e.Icon)      
      self:SetEnemyInfo(i, 4, e.ReviveCount)
    else
      self:SetEnemyInfo(i, 5, false)
    end
  end
end
----------------------------------------------------
function UIBattleAPI:Awake(this) 
  self.this = this  
  UIBattleAPI.Instance=self;
  ---------------------字段----------------------

  self.roleId=nil;   

  self.Coin           =self.this.transform:FindChild("Center/Coin/TextCoin"):GetComponent("UnityEngine.UI.Text");    --Text 当前金钱
  
  self.TeamKill       =self.this.transform:FindChild("TopRight/Infos/Bg/TeamKill"):GetComponent("UnityEngine.UI.Text");      --Text 团队击杀总数    
  self.EnemyTeamKill  =self.this.transform:FindChild("TopRight/Infos/Bg/EnemyTeamKill"):GetComponent("UnityEngine.UI.Text");      --Text 团队死亡总数(原名：TeamDead)
  self.PersonKill     =self.this.transform:FindChild("TopRight/Infos/Bg/PersonKill"):GetComponent("UnityEngine.UI.Text");        --Text 个人击杀数
  self.PersonDead     =self.this.transform:FindChild("TopRight/Infos/Bg/PersonDead"):GetComponent("UnityEngine.UI.Text");      --Text 个人死亡数
  self.PersonAssists  =self.this.transform:FindChild("TopRight/Infos/Bg/PersonAssists"):GetComponent("UnityEngine.UI.Text");      --Text 个人助攻数
  self.GameDuration   =self.this.transform:FindChild("TopRight/Infos/Bg/GameDuration"):GetComponent("UnityEngine.UI.Text");     --Text 游戏持续时间（原名：Time）
  self.FPS            =self.this.transform:FindChild("TopRight/Infos/Bg/FPS"):GetComponent("UnityEngine.UI.Text");             --Text 帧率
  self.NetworkLatency =self.this.transform:FindChild("TopRight/Infos/Bg/networkLatency"):GetComponent("UnityEngine.UI.Text");     --Text 网络延迟（原名：networkDelay）



  self.JoystickController={}   --NTGJoystickController(等待添加)
  self.battleUIAnimator={}     --Animator(等待添加)
  
  self.enemyList = {Icon={},HP={},HPBG={},Skill={},Dead={},Cell={},SkillBg={},reviveTime={}}          --GameObject 敌军列表
  self.enemyChildList = {Icon={},HP={},HPBG={},Skill={},Dead={},Cell={},SkillBg={},reviveTime={}}  
  self.allyList  = {Icon={},HP={},Skill={},Dead={},Cell={},SkillBg={},SkillBgHP={},reviveTime={}}   --GameObject 友军列表
  self.allyChildList  = {Icon={},HP={},Skill={},Dead={},Cell={},SkillBg={},reviveTime={}}  
   
  self.skillList={DeadTipCollider={},CanCloseCollider={true,true,true},Icon={},SkillLevel={},CountDownText={},CountDownBg={},CD={},BanSkill={},NoBlue={},Name={},
  Desc={},fxShadows={},fxIsCanNotShows={},CDMax={},LevelMax={},SkillContinue={},SkillContinueMax={},TipCD={},TipMP={},NameSJ={},TagsSJ={},TagsST={{},{},{}}}         --GameObject 技能列表
  self.SummonSkillList={DeadTipCollider={},CanCloseCollider={true,true,true}, Icon={},CD={},CDMax={}, CountDownText={},CountDownBg={},Name={},TipName={},TipCD={},TipMP={},Desc={},NameSJ={},TagsSJ={},TagsST={{},{},{}}}
  self.skillTipLast={mpCost={},pAtk={},mAtk={},level={}}
  self.summonSkillTipLast={mpCost={},pAtk={},mAtk={},level={}}
  self.skillUpgradeList={};
  self.JoyStickScripts ={} --摇杆脚本列表
  
  self.ATKButtonDownHandler=nil 
  self.ATKButtonUpHandler=nil

  
  self.selectedAxis=Vector2.zero;
  self.cancelSkill=false;
  self.boolPause=false;
  self.isDead=false
  -------------------------------------
  self.messageTipQueue=UIQueue.new()
  self:SetParam()--参数赋值 

  
end
----------------------------------------------------

function UIBattleAPI:Start()

  --UnityEngine.Resources.UnloadUnusedAssets();
  self:SetParamStart()
  self.moveJoyStick=UITools.GetLuaScript(self.this.transform:FindChild("BottomLeft/JoyStickIII/Stick").gameObject,"Logic.UICommon.UIJoyStickMove")--.inputAxis;
  -----------------------------启动协程-----------------------------
 
  self.Co_MoniUpdate = coroutine.start(self.MoniUpdate, self)  
  self.Co_ShowMessageInterval = coroutine.start( self.ShowMessageInterval,self)  
  
  --[[
  self:SetSkillInfo(4, 0,"I00000000" )
   
  self:SetSkillInfo(4, 3,67 )
  self:SetSkillInfo(4, 4,12)
    
  --local ta={ "哈哈哈哈" ,72,"sdasdsadasdsadasdasdasdasdas"  }
  --self:SetSkillInfo(4, 6,ta )
  self:SetSkillInfo(4, 9,"16 ")
  self:SetSkillInfo(5, 10,false )
  --]]
  --[[
  --------------------------方法测试------------------------
  self:SetEnemyInfo(1, 0, "I11000302")
  self:SetEnemyInfo(1, 1, true )
  self:SetEnemyInfo(1, 2, 0.6)
  self:SetEnemyInfo(1, 4, 88)
  self:SetEnemyInfo(2, 5, false)
  
  self:SetAllyInfo(1, 0, "I11000302")
  self:SetAllyInfo(1, 2, 0.8)
  self:SetAllyInfo(1, 3, false)
  self:SetAllyInfo(2, 5, false)
  self:SetAllyInfo(1, 4, 88)
  
  self:SetSkillInfo(4, 0,"I00000000" )
  self:SetSkillInfo(4, 1,6 )
  self:SetSkillInfo(4, 2,1 )
  self:SetSkillInfo(4, 3,67 )
  self:SetSkillInfo(4, 4,0 )
  self:SetSkillInfo(4, 5,false )
  local ta={ "哈哈哈哈" ,72,"sdasdsadasdsadasdasdasdasdas"  }
  self:SetSkillInfo(4, 6,ta )
  self:SetSkillInfo(4, 7,16 )
  self:SetSkillInfo(4, 8,12 )
  
  self:RegisterDelegateSummonSkill(self,self.Test2)
  self:RegisterDelegateDirective(self,self.Test3)
  self:RegisterDelegatePause(self,self.Test4)
  self:RegisterDelegateATKDown(self,self.Test5)
  self:RegisterDelegateATKUp(self,self.Test5)
  self:RegisterDelegateChooseTarget(self,self.Test6)
  
  self:SetHpCurrency(true,"I11000302",15,20,10,30,10,20,30,40)
  self:SetBuff(101,5,20,"I11000302","........................")
  self:SetBuff(102,5,20,"I11000302","........................")

  self:ReviveCountDown(74.5)  --死亡倒计时
  self:SetGameMode(5)         --设置游戏模式 3v3 5v5
  self:InitiateCapitulate(true)  --投降
  self:InitiateCapitulate(false)
  self:InitiateCapitulate(true)
  --]]
-----------------------------------------------------------------
  self.ATKCollider    =self.this.transform:FindChild("BottomRight/Colliders/ATKCollider");      
                        --GameObject 攻击碰撞区域
  self.ChoseHeroCollider     =self.this.transform:FindChild("BottomRight/Colliders/ChoseHeroCollider");      
  self.ChoseSoldierCollider=self.this.transform:FindChild("BottomRight/Colliders/ChoseSoldierCollider");   
 -----------------------摇杆脚本引用---------------------

  local JoySticks =self.this.transform:FindChild("BottomRight/JoySticks"); 
  table.insert( self.JoyStickScripts, UITools.GetLuaScript( JoySticks:FindChild("JoyStick1/Stick").gameObject ,"Logic.UICommon.UIJoyStick") )
  table.insert( self.JoyStickScripts, UITools.GetLuaScript( JoySticks:FindChild("JoyStick2/Stick").gameObject ,"Logic.UICommon.UIJoyStick") )
  table.insert( self.JoyStickScripts, UITools.GetLuaScript( JoySticks:FindChild("JoyStick3/Stick").gameObject ,"Logic.UICommon.UIJoyStick") )
  
  table.insert( self.JoyStickScripts, UITools.GetLuaScript( JoySticks:FindChild("JoyStickII1/Stick").gameObject ,"Logic.UICommon.UIJoyStick") )
  table.insert( self.JoyStickScripts, UITools.GetLuaScript( JoySticks:FindChild("JoyStickII2/Stick").gameObject ,"Logic.UICommon.UIJoyStick") )
  table.insert( self.JoyStickScripts, UITools.GetLuaScript( JoySticks:FindChild("JoyStickII3/Stick").gameObject ,"Logic.UICommon.UIJoyStick") )
  
  ---------------------碰撞区域引用-----------------------
  self.skillClickScripts={}
  table.insert(self.skillClickScripts,UITools.GetLuaScript(self.this.transform:FindChild("BottomRight/Skill1/Skill1Collider").gameObject,"Logic.UICommon.UIClick" ))
  table.insert(self.skillClickScripts,UITools.GetLuaScript(self.this.transform:FindChild("BottomRight/Skill2/Skill2Collider").gameObject,"Logic.UICommon.UIClick" ))
  table.insert(self.skillClickScripts,UITools.GetLuaScript(self.this.transform:FindChild("BottomRight/Skill3/Skill3Collider").gameObject,"Logic.UICommon.UIClick" ))

  table.insert(self.skillClickScripts,UITools.GetLuaScript(self.this.transform:FindChild("BottomRight/SummonSkill1/SummonCollider1").gameObject,"Logic.UICommon.UIClick" ))
  table.insert(self.skillClickScripts,UITools.GetLuaScript(self.this.transform:FindChild("BottomRight/SummonSkill2/SummonCollider2").gameObject,"Logic.UICommon.UIClick" ))
  table.insert(self.skillClickScripts,UITools.GetLuaScript(self.this.transform:FindChild("BottomRight/SummonSkill3/SummonCollider3").gameObject,"Logic.UICommon.UIClick" ))
  
  self.skillClickScripts[1].this.gameObject:SetActive(false)
  self.skillClickScripts[2].this.gameObject:SetActive(false)
  self.skillClickScripts[3].this.gameObject:SetActive(false)
  --------------------死亡时打开的Collider-----------------
  self.DeadColliders={}
  table.insert(self.DeadColliders,self.this.transform:FindChild("BottomRight/DeadColliders").gameObject)

  self.skillList.DeadTipCollider[1]=self.this.transform:FindChild("BottomRight/Skill1/DeadTipCollider").gameObject
  self.skillList.DeadTipCollider[2]=self.this.transform:FindChild("BottomRight/Skill2/DeadTipCollider").gameObject
  self.skillList.DeadTipCollider[3]=self.this.transform:FindChild("BottomRight/Skill3/DeadTipCollider").gameObject
  table.insert(self.DeadColliders,self.skillList.DeadTipCollider[1])
  table.insert(self.DeadColliders,self.skillList.DeadTipCollider[2])
  table.insert(self.DeadColliders,self.skillList.DeadTipCollider[3])

  self.SummonSkillList.DeadTipCollider[1]=self.this.transform:FindChild("BottomRight/SummonSkill1/DeadTipCollider").gameObject
  self.SummonSkillList.DeadTipCollider[2]=self.this.transform:FindChild("BottomRight/SummonSkill2/DeadTipCollider").gameObject
  self.SummonSkillList.DeadTipCollider[3]=self.this.transform:FindChild("BottomRight/SummonSkill3/DeadTipCollider").gameObject
  table.insert(self.DeadColliders,self.SummonSkillList.DeadTipCollider[1])
  table.insert(self.DeadColliders,self.SummonSkillList.DeadTipCollider[2])
  table.insert(self.DeadColliders,self.SummonSkillList.DeadTipCollider[3])
  --------------------------------------------------------
  -----给6个技能Down注册事件
   for i,v in pairs(self.skillClickScripts) do
      local listener = NTGEventTriggerProxy.Get(self.skillClickScripts[i].this.gameObject);
      listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        self.cancelSkillButton:GetComponent("UnityEngine.UI.Image").enabled=true;
        self.selectedAxis=self.JoyStickScripts[i].inputAxis;--点击技能按钮选中对应的摇杆轴
        self.selectedCenterImage=self.JoyStickScripts[i].tCenter:GetComponent("UnityEngine.UI.Image");
      end,self
      );
      listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        self.cancelSkillButton:GetComponent("UnityEngine.UI.Image").enabled=false;
        
      end,self
      );
  end 
-----------------------------------------------------------------
  --[[
  self:ShowMessage(0,1,nil,nil,nil) 
    self:ShowMessage(0,2,nil,nil,nil) 
      self:ShowMessage(0,3,nil,nil,nil) 
        self:ShowMessage(0,4,false,"I11000302",nil) 
          self:ShowMessage(0,5,true,"I11000302",nil) 
            self:ShowMessage(0,6,true,"I11000302",nil) 
              self:ShowMessage(0,7,true,"I11000302",nil) 
                self:ShowMessage(0,8,true,"I11000302",nil) 
  self:ShowMessage(1,0,false,"I11000302","I11000302")    
    self:ShowMessage(1,1,true,"I11000302","I11000302") 
      self:ShowMessage(1,2,true,"I11000302","I11000302") 
        self:ShowMessage(1,3,true,"I11000302","I11000302") 
          self:ShowMessage(1,4,true,"I11000302","I11000302") 
            self:ShowMessage(1,5,true,"I11000302","I11000302") 
              self:ShowMessage(1,6,true,"I11000302","I11000302")   
  self:ShowMessage(2,3,false,"I11000302","I11000302")       
    self:ShowMessage(2,4,true,"I11000302","I11000302")  
      self:ShowMessage(2,5,true,"I11000302","I11000302")  
        self:ShowMessage(2,6,true,"I11000302","I11000302")  
          self:ShowMessage(2,7,true,"I11000302","I11000302")  
            self:ShowMessage(2,8,true,"I11000302","I11000302")                 
  --]]

  --self:MiniMapCreate(1,1,1)
  --self:MiniMapCreate(2,1,2)
  --self:MiniMapCreate(3,2,1)
  --self:MiniMapCreate(4,2,2)
  --self:MiniMapCreate(5,3)
  --self:MiniMapCreate(6,4,1,"I11000302")
  --self:MiniMapCreate(7,4,2,"I11000302")
  --self:MiniMapCreate("8",5,1)  
  --self:MiniMapCreate(9,5,2)
  -----------------------------------------------------------
 
  --self:MiniMapRefresh(3,2,0.6)
  --self:MiniMapRefresh(3,1,Vector2.one)
  --self:MiniMapDestroy(3)
  --self:MiniMapDestroy("8",5,1)  
  
  --self:RefreshRecoEquip(nil,{{ 12001303,1 },{12001304 , 980}})--刷新推荐武器
  --self:ShowDictate() --显示指令信息

  --self:SetSkillInfo(4, 6,{20140811,15,30,40,4})
  --self:SetSummonSkillInfo(1, 6,{20140811,15,30,40,4})
end
function UIBattleAPI:OnEnable()
end
---------------------模拟Update--------------------
function UIBattleAPI:MoniUpdate()

  if(tostring(Application.platform) == tostring(UnityEngine.RuntimePlatform.WindowsEditor) )then
    while(true) do  
      coroutine.step()
      self.moveJoyStick.inputAxis.x = Input.GetAxis("Horizontal")
      self.moveJoyStick.inputAxis.y = Input.GetAxis("Vertical")
    end
  end 
    --[[
    -------------------记录Id------------------
    UIBattleAPI.lastFingerIds={} 
    for i=1,Input.touches.Length,1 do
      UIBattleAPI.lastFingerIds[i]=Input.touches[i-1].fingerId
    end
    --]]
     
    
    --[[
    self.XXX.text=tostring(Input.touchCount) 
    if( Input.touchCount>0 )then
    
    self.XXX1.text=tostring(Input.touches[0].fingerId)   
    self.XXX11.text=tostring(Input.GetTouch(0).position)
    else
      self.XXX1.text=tostring("X")
      self.XXX11.text=tostring("X")
    end
    if( Input.touchCount>1 )then
    
    self.XXX2.text=tostring(Input.touches[1].fingerId)  
    self.XXX22.text=tostring(Input.GetTouch(1).position)
    else
      self.XXX2.text=tostring("X")
      self.XXX22.text=tostring("X")
    end
    if( Input.touchCount>2 )then
   
    self.XXX3.text=tostring(Input.touches[2].fingerId)  
    self.XXX33.text=tostring(Input.GetTouch(2).position)
    else
      self.XXX3.text=tostring("X")
      self.XXX33.text=tostring("X")
    end
    --]]

  


  -------------------------------------------
end
---------------------------------------------------
----------------------------------------------------
function UIBattleAPI:OnDestroy()
  coroutine.stop(self.Co_MoniUpdate)
  coroutine.stop(self.Co_ShowMessageInterval)
  coroutine.stop(self.Co_CountDownRevive)


  

  UITools.Sprites=nil
  UIBattleAPI.Instance=nil;
  self.this = nil
  self = nil
end
----------------------------------------------------
function UIBattleAPI:SetRoleId(roleId) 
  self.roleId=roleId;
end
----------------------------------------------------
function UIBattleAPI:HideTips()
  self.skillTip1.gameObject:SetActive(false);
  self.skillTip2.gameObject:SetActive(false);
  self.skillTip3.gameObject:SetActive(false);
  self.skillTip4.gameObject:SetActive(false);
  self.skillTip5.gameObject:SetActive(false);
  self.skillTip6.gameObject:SetActive(false);
end
--------------------断线重连提示--------------------
function UIBattleAPI:SetReconnectTip(bool)
  self.Reconnect:SetActive(bool);
end
-----------------------设置基本信息----------------------
function UIBattleAPI:SetBasicInfo(Coin,TeamKill,EnemyTeamKill,PersonKill,PersonDead,PersonAssists,GameDuration,FPS,NetworkLatency)
  self.Coin.text          =math.floor( Coin )                  -- 当前金钱
  self.TeamKill.text      =TeamKill              -- 团队击杀总数    
  self.EnemyTeamKill.text =EnemyTeamKill         -- 团队死亡总数
  self.PersonKill.text    =PersonKill            -- 个人击杀数
  self.PersonDead.text    =PersonDead            -- 个人死亡数
  self.PersonAssists.text =PersonAssists         -- 个人助攻数
  self.GameDuration.text  =GameDuration          -- 游戏持续时间
  self.FPS.text           =FPS                   -- 帧率
  self.NetworkLatency.text=NetworkLatency    
end 
-----------------------设置指令按钮CD---------------------
function UIBattleAPI:SetDirectiveCD(index, heroInfoType,param)

  if(heroInfoType==0)then      --CD总时间
    self.DirectiveCDMax=param;
  elseif(heroInfoType==1)then     --设置当前CD时间
    for k,v in pairs(self.directiveButtons) do
      v:GetChild("CD"):GetComponent("UnityEngine.UI.Image").fillAmount=param/self.DirectiveCDMax
    end
  end
end
-----------------------设置敌人属性-----------------------
function UIBattleAPI:SetEnemyInfo(index, heroInfoType,param)
  --当前index从1开始
  if(heroInfoType==0)then     --设置头像
    if(param~=0 and param~="" and param~=nil)then   
      --self.enemyChildList.Icon[index].sprite=UITools.GetSpriteBattle("uibattle", param ) --ToString()
        
       
        
          self.enemyChildList.Icon[index].sprite=UITools.GetSpriteBattle("uibattle", param);
   

    end
  elseif(heroInfoType==1)then --是否置灰
    self.enemyChildList.Dead[index]:SetActive(param);
    if(param)then
      self.enemyChildList.HP[index].color = Color.gray;
    else
      self.enemyChildList.HP[index].color = Color.white;
    end
  
  elseif(heroInfoType==2)then --显示血量
    self.enemyChildList.HP[index].fillAmount = param;
       
  elseif(heroInfoType==3)then --是否显示技能
    --敌人不显示技能
  elseif(heroInfoType==4)then --复活时间
    if(param<1)then
      self.enemyChildList.reviveTime[index].enabled=false
      self.enemyChildList.reviveTime[index].text= "";
    else
      self.enemyChildList.reviveTime[index].enabled=true
      self.enemyChildList.reviveTime[index].text= math.floor(param)
    end
  elseif(heroInfoType==5)then --是否显示头像
    self.enemyList.Icon[index].gameObject:SetActive(param);
    self.enemyList.Dead[index].gameObject:SetActive(param);
    --self.enemyList.HP[index].gameObject:SetActive(param);
    self.enemyList.Cell[index].gameObject:SetActive(param);
    self.enemyList.reviveTime[index].gameObject:SetActive(param);
    --self.enemyChildList.reviveTime[index].text= "";
  end
end
-----------------------设置友军属性-----------------------
function UIBattleAPI:SetAllyInfo(index, heroInfoType,param)  
  --当前index从1开始
  if(heroInfoType==0)then     --设置头像
    if(param~=0 and param~="" and param~=nil)then
      --self.allyChildList.Icon[index].sprite=UITools.GetSpriteBattle("uibattle", param ) --ToString()

      
        
          self.allyChildList.Icon[index].sprite=UITools.GetSpriteBattle("uibattle", param);
      

    end
  elseif(heroInfoType==1)then --是否置灰
  --友军头像不需要置灰
  
  elseif(heroInfoType==2)then --显示血量
    self.allyChildList.HP[index].fillAmount = param;
    if(self.allyChildList.HP[index].fillAmount<=0)then
      self.allyChildList.Dead[index].fillAmount=1
      self.allyChildList.reviveTime[index].enabled=true;
      self.allyList.SkillBgHP[index].fillAmount=0
    else
      self.allyChildList.Dead[index].fillAmount=0
      self.allyChildList.reviveTime[index].enabled=false;
      self.allyList.SkillBgHP[index].fillAmount=1
    end
  elseif(heroInfoType==3)then --是否显示技能
    self.allyChildList.Skill[index]:SetActive(param);

  elseif(heroInfoType==4)then 

    if(param<1)then
      self.allyChildList.reviveTime[index].enabled=false
      self.allyChildList.reviveTime[index].text= ""
    else
      self.allyChildList.reviveTime[index].enabled=true
      self.allyChildList.reviveTime[index].text= math.floor(param);
    end

  elseif(heroInfoType==5)then --是否显示头像
    self.allyList.Icon[index].gameObject:SetActive(param);
    self.allyList.Dead[index].gameObject:SetActive(param);
    self.allyList.HP[index].gameObject:SetActive(param);
    self.allyList.Cell[index].gameObject:SetActive(param);
    self.allyList.SkillBg[index].gameObject:SetActive(param);
    self.allyList.Skill[index].gameObject:SetActive(param);
    self.allyList.reviveTime[index].gameObject:SetActive(param);
    self.allyList.SkillBgHP[index].gameObject:SetActive(param);
    self.allyChildList.reviveTime[index].text= ""
  end
end
-----------------------设置技能信息-----------------------
function UIBattleAPI:SetSkillInfo(index, skillInfoType,param)
  if(index<=3)then
    if(skillInfoType==0)then --头像
      if(param~=0 and param~="" and param~=nil)then
        --self.skillList.Icon[index].sprite=UITools.GetSpriteBattle("skillicon-" .. self.roleId, param );

 
         
          self.skillList.Icon[index].sprite=UITools.GetSpriteBattle("skillicon-" .. self.roleId, param );


      end
    elseif(skillInfoType==1)then  --最高等级
      self.skillList.LevelMax[index]=param;
    
    elseif(skillInfoType==2)then  --当前等级
      if(self.skillList.LevelMax[index]~=0)then
        self.skillList.SkillLevel[index].fillAmount=param /self.skillList.LevelMax[index];
        self.currentSkillLevel=param
      end
      --[[
      if(param==0)then  --等级为0，置灰
        --self.skillList.BanSkill[index]:SetActive(true);
        
          if(self.skillList.CanCloseCollider[index]==true)then 
            self.skillClickScripts[index].this.gameObject:SetActive(false);
            self.skillList.DeadTipCollider[index]:SetActive(true); 
          end
        
      else
        --self.skillList.BanSkill[index]:SetActive(false);

        self.skillClickScripts[index].this.gameObject:SetActive(true);
        self.skillList.DeadTipCollider[index]:SetActive(false);
      end
      --]]
      
    elseif(skillInfoType==3)then  --CD总时间
        self.skillList.CDMax[index]=param;
    
    elseif(skillInfoType==4)then  --设置当前CD时间
      --self.skillList.CD[index].fillAmount = param/self.skillList.CDMax[index];
      if(self.isDead==true)then
        if(self.skillList.CanCloseCollider[index]==true)then
          self.skillClickScripts[index].this.gameObject:SetActive(false);
          self.skillList.DeadTipCollider[index]:SetActive(true);
        end
      else
        if(param<=0)then  
          --self.skillList.CD[index].fillAmount=0
          if(self.currentSkillLevel~=0)then 
            self.skillClickScripts[index].this.gameObject:SetActive(true);
            self.skillList.DeadTipCollider[index]:SetActive(false);
          else
            self.skillClickScripts[index].this.gameObject:SetActive(false);
            self.skillList.DeadTipCollider[index]:SetActive(true);
          end
        else
          --self.skillList.CD[index].fillAmount=1 
          if(self.skillList.CanCloseCollider[index]==true)then
            self.skillClickScripts[index].this.gameObject:SetActive(false);
            self.skillList.DeadTipCollider[index]:SetActive(true);
          end
        end
      end
      self.skillList.CountDownText[index].text =  tostring( math.ceil(param) );
      if(param<=0)then
        self.skillList.CountDownText[index].enabled = false;
        --self.skillList.CountDownBg[index].enabled = false;
      else
        self.skillList.CountDownText[index].enabled = true;
        --self.skillList.CountDownBg[index].enabled = true;
      end
      --之前有CD完成之后特效的播放
      
      if(param<=0)then
      --if(math.Approximately(self.skillList.CD[index].fillAmount,0))then 
        if(self.fxIsCanNotShows[index] == false)then

          self:ShowInNextFrame(self.FX_CDOvers[index]);
          self.fxIsCanNotShows[index] = true;    
          self.skillTips[index].gameObject:SetActive(false);
        end
      else
      --elseif(self.skillList.CD[index].fillAmount>0)then
        self.fxIsCanNotShows[index] = false;  
      end
      
    elseif(skillInfoType==5)then  --空蓝
      self.skillList.NoBlue[index]:SetActive(not param);
                                                        --self:SetSkillInfo(4, 6,{20140811,15,30,40,4}) 
    elseif(skillInfoType==6)then  --技能提示信息                        param结构{SkillId,MPCost,pAtk,mAtk,level}
      --self.skillTipLast={mpCost={},pAtk={},mAtk={},level={}}
      --self.summonSkillTipLast={mpCost={},pAtk={},mAtk={},level={}}
      
      if(self.skillTipLast.mpCost[index]~=nil)then
        if( self.skillTipLast.mpCost[index] ~= param[2] or self.skillTipLast.pAtk[index] ~= param[3] 
          or self.skillTipLast.mAtk[index] ~= param[4] or self.skillTipLast.level[index] ~= param[5])then

          self.skillTipLast.mpCost[index] = param[2]
          self.skillTipLast.pAtk[index] = param[3]
          self.skillTipLast.mAtk[index] = param[4]
          self.skillTipLast.level[index] = param[5]
          -------------------------------------------------------
          local name;
          local tags;
          if(self.skillList.NameSJ[index]==nil)then
            self.skillList.NameSJ[index]=UTGData.Instance().SkillsData[tostring(param[1])].Name;
            self.skillList.TagsSJ[index]=UTGData.Instance().SkillsData[tostring(param[1])].Tags;
            name=self.skillList.NameSJ[index];
            tags=self.skillList.TagsSJ[index];
          else
            name=self.skillList.NameSJ[index];   
            tags=self.skillList.TagsSJ[index];  
          end
          
          self.skillList.Name[index].text=  name
          for i=1,#tags,1 do 
            if(tags[i]~="")then
              --self.skillList.TagsST[index][i].sprite=UITools.GetSpriteBattle("uibattle","BUI-Tag" .. tags[i])

                
                self.skillList.TagsST[index][i].sprite=UITools.GetSpriteBattle("uibattle","BUI-Tag" .. tags[i])
            

              self.skillList.TagsST[index][i].gameObject:SetActive(true);
            end
          end                                                                    --角色ID，技能Id    --  pAtkLast   mAtkLast   levelLast
          self.skillList.Desc[index].text=UTGData.Instance():GetSkillDescByParam(self.roleId,param[1],{pAtk= param[3],mAtk=param[4],level=param[5]})  -- tostring( param[3]); 
          self.skillList.TipCD[index].text="CD:" .. tostring( self.skillList.CDMax[index]) .. "秒";
          self.skillList.TipMP[index].text="法力消耗:" .. tostring( param[2]);
          -------------------------------------------------------
        end
      else
        
        self.skillTipLast.mpCost[index] = param[2]
        self.skillTipLast.pAtk[index] = param[3]
        self.skillTipLast.mAtk[index] = param[4]
        self.skillTipLast.level[index] = param[5]
        -------------------------------------------------------
        local name;
        local tags;
        if(self.skillList.NameSJ[index]==nil)then
          self.skillList.NameSJ[index]=UTGData.Instance().SkillsData[tostring(param[1])].Name;
          self.skillList.TagsSJ[index]=UTGData.Instance().SkillsData[tostring(param[1])].Tags;
          name=self.skillList.NameSJ[index];
          tags=self.skillList.TagsSJ[index];
        else
          name=self.skillList.NameSJ[index];   
          tags=self.skillList.TagsSJ[index];  
        end
          
        self.skillList.Name[index].text=  name
        for i=1,#tags,1 do 
          if(tags[i]~="")then
            --self.skillList.TagsST[index][i].sprite=UITools.GetSpriteBattle("uibattle","BUI-Tag" .. tags[i])

           
              
                self.skillList.TagsST[index][i].sprite=UITools.GetSpriteBattle("uibattle","BUI-Tag" .. tags[i])
            

            self.skillList.TagsST[index][i].gameObject:SetActive(true);
          end
        end                                                                    --角色ID，技能Id    --  pAtkLast   mAtkLast   levelLast
        self.skillList.Desc[index].text=UTGData.Instance():GetSkillDescByParam(self.roleId,param[1],{pAtk= param[3],mAtk=param[4],level=param[5]})  -- tostring( param[3]); 
        self.skillList.TipCD[index].text="CD:" .. tostring( self.skillList.CDMax[index]) .. "秒";
        self.skillList.TipMP[index].text="法力消耗:" .. tostring( param[2]);
        -------------------------------------------------------
      end
      
    elseif(skillInfoType==7)then  --持续性技能持续剩余时间
      self.skillList.SkillContinueMax[index]=param
    elseif(skillInfoType==8)then  --持续性技能持续剩余时间
      self.skillList.SkillContinue[index].fillAmount=param/self.skillList.SkillContinueMax[index];
    end
  else
    self:SetSummonSkillInfo(index-3, skillInfoType,param)
  end
end
-----------------------设置召唤师技能信息-----------------------
function UIBattleAPI:SetSummonSkillInfo(index, skillInfoType,param)
  
  if(skillInfoType==0)then --头像
    if(param~=0 and param~="" and param~=nil)then
      --self.SummonSkillList.Icon[index].sprite=UITools.GetSpriteBattle("playerskillicon", param );

      
       
        self.SummonSkillList.Icon[index].sprite=UITools.GetSpriteBattle("playerskillicon", param );
      

    end
  elseif(skillInfoType==1)then  --最高等级
 
  
  elseif(skillInfoType==2)then  --当前等级
   
    
  elseif(skillInfoType==3)then  --CD总时间
    self.SummonSkillList.CDMax[index]=param;
  
  elseif(skillInfoType==4)then  --设置当前CD时间
    --self.SummonSkillList.CD[index].fillAmount = param/self.SummonSkillList.CDMax[index]; --Debugger.LogError(self.SummonSkillList.CD[index].fillAmount)
    if(self.isDead==true)then
      if(self.SummonSkillList.CanCloseCollider[index]==true )then 
        self.skillClickScripts[index+3].this.gameObject:SetActive(false);
        self.SummonSkillList.DeadTipCollider[index]:SetActive(true);
      end
    else
      if(param<=0)then 
            --self.SummonSkillList.CD[index].fillAmount=0
            self.skillClickScripts[index+3].this.gameObject:SetActive(true);
            self.SummonSkillList.DeadTipCollider[index]:SetActive(false);
      else
            --self.SummonSkillList.CD[index].fillAmount=1 
            if(self.SummonSkillList.CanCloseCollider[index]==true )then 
              self.skillClickScripts[index+3].this.gameObject:SetActive(false);
              self.SummonSkillList.DeadTipCollider[index]:SetActive(true);
            end
      end
    end

    self.SummonSkillList.CountDownText[index].text =  tostring( math.ceil(param) );
    if(param<=0)then
      self.SummonSkillList.CountDownText[index].enabled = false;
      --self.SummonSkillList.CountDownBg[index].enabled = false;
      
    else
      self.SummonSkillList.CountDownText[index].enabled = true;
      --self.SummonSkillList.CountDownBg[index].enabled = true;
    end
    if(param<=0)then
    --if(math.Approximately(self.SummonSkillList.CD[index].fillAmount,0))then
        if(self.fxIsCanNotShows[index+3] == false)then
          self.fxIsCanNotShows[index+3] = true;    
          self.skillTips[index+3].gameObject:SetActive(false);
        end
    else
    --elseif(self.skillList.CD[index].fillAmount>0)then
        self.fxIsCanNotShows[index+3] = false;  
    end
  
  elseif(skillInfoType==5)then  --空蓝
    
    
  elseif(skillInfoType==6)then  --技能提示信息

    if(self.summonSkillTipLast.mpCost[index]~=nil)then
        if( self.summonSkillTipLast.mpCost[index] ~= param[2] or self.summonSkillTipLast.pAtk[index] ~= param[3] 
          or self.summonSkillTipLast.mAtk[index] ~= param[4] or self.summonSkillTipLast.level[index] ~= param[5])then

          self.summonSkillTipLast.mpCost[index] = param[2]
          self.summonSkillTipLast.pAtk[index] = param[3]
          self.summonSkillTipLast.mAtk[index] = param[4]
          self.summonSkillTipLast.level[index] = param[5]
          -------------------------------------------------------
            local name;
            local tags;
            if(self.SummonSkillList.NameSJ[index]==nil)then
              self.SummonSkillList.NameSJ[index]=UTGData.Instance().SkillsData[tostring(param[1])].Name;
              self.SummonSkillList.TagsSJ[index]=UTGData.Instance().SkillsData[tostring(param[1])].Tags;
              name=self.SummonSkillList.NameSJ[index];
              tags=self.SummonSkillList.TagsSJ[index];
            else
              name=self.SummonSkillList.NameSJ[index];   
              tags=self.SummonSkillList.TagsSJ[index];  
            end
            self.SummonSkillList.TipName[index].text=  name
            for i=1,#tags,1 do
              if(tags[i]~="")then
                --self.SummonSkillList.TagsST[index][i].sprite=UITools.GetSpriteBattle("uibattle","BUI-Tag" .. tags[i])

              
                    
                    self.SummonSkillList.TagsST[index][i].sprite=UITools.GetSpriteBattle("uibattle","BUI-Tag" .. tags[i])
                

                self.SummonSkillList.TagsST[index][i].gameObject:SetActive(true);
              end
            end
            self.SummonSkillList.Desc[index].text= UTGData.Instance():GetSkillDescByParam(self.roleId,param[1],{pAtk= param[3],mAtk=param[4],level=param[5]})  
            self.SummonSkillList.TipCD[index].text="CD:" .. tostring( self.skillList.CDMax[index]) .. "秒";
            self.SummonSkillList.TipMP[index].text="法力消耗:" .. tostring( param[2]);
          -------------------------------------------------------
        end
      else
        self.summonSkillTipLast.mpCost[index] = param[2]
        self.summonSkillTipLast.pAtk[index] = param[3]
        self.summonSkillTipLast.mAtk[index] = param[4]
        self.summonSkillTipLast.level[index] = param[5]
        -------------------------------------------------------
            local name;
            local tags;
            if(self.SummonSkillList.NameSJ[index]==nil)then
              self.SummonSkillList.NameSJ[index]=UTGData.Instance().SkillsData[tostring(param[1])].Name;
              self.SummonSkillList.TagsSJ[index]=UTGData.Instance().SkillsData[tostring(param[1])].Tags;
              name=self.SummonSkillList.NameSJ[index];
              tags=self.SummonSkillList.TagsSJ[index];
            else
              name=self.SummonSkillList.NameSJ[index];   
              tags=self.SummonSkillList.TagsSJ[index];  
            end
            self.SummonSkillList.TipName[index].text=  name
            for i=1,#tags,1 do
              if(tags[i]~="")then
                --self.SummonSkillList.TagsST[index][i].sprite=UITools.GetSpriteBattle("uibattle","BUI-Tag" .. tags[i])

                
                    
                    self.SummonSkillList.TagsST[index][i].sprite=UITools.GetSpriteBattle("uibattle","BUI-Tag" .. tags[i])
                

                self.SummonSkillList.TagsST[index][i].gameObject:SetActive(true);
              end
            end
            self.SummonSkillList.Desc[index].text= UTGData.Instance():GetSkillDescByParam(self.roleId,param[1],{pAtk= param[3],mAtk=param[4],level=param[5]})  
            self.SummonSkillList.TipCD[index].text="CD:" .. tostring( self.skillList.CDMax[index]) .. "秒";
            self.SummonSkillList.TipMP[index].text="法力消耗:" .. tostring( param[2]);
        -------------------------------------------------------
      end

  elseif(skillInfoType==7)then  --持续性技能持续剩余时间
   
  elseif(skillInfoType==8)then  --持续性技能持续剩余时间
   
  elseif(skillInfoType==9)then  --名称
      self.SummonSkillList.Name[index].text = param;
  elseif(skillInfoType==10)then  --隐藏按钮
    if(index==1)then
      self.SummonSkill1P.gameObject:SetActive(param);
    elseif(index==2)then
      self.SummonSkill2P.gameObject:SetActive(param);
    elseif(index==3)then
      self.SummonSkill3P.gameObject:SetActive(param);
    end
  end
end
-------------------------AddBuff自毁----------------------------
function UIBattleAPI:SetBuff(array)  --icon,desc,ratio    

  for i=1,8,1 do
    if(i<=array.Count)then  --#array
      --array[i-1].id
      if(self.tableBuff[i]["GO"].activeSelf==false)then
        self.tableBuff[i]["GO"]:SetActive(true);
      end
      --self.tableBuff[i]["icon"].sprite   = UITools.GetSpriteBattle("skillicon-" .. self.roleId,array:get_Item(i-1).icon) --i get_Item

      
         
          self.tableBuff[i]["icon"].sprite=UITools.GetSpriteBattle("skillicon-" .. self.roleId,array:get_Item(i-1).icon)
      

      self.tableBuff[i]["desc"].text     = array:get_Item(i-1).desc  --i
      self.tableBuff[i]["cd"].fillAmount = array:get_Item(i-1).ratio  --i
    else
      if(self.tableBuff[i]["GO"].activeSelf==true)then
        self.tableBuff[i]["GO"]:SetActive(false);
      end
    end
  end
end
-----------------------技能升级显示-----------------------
function UIBattleAPI:SetSkillUpgrade(index,isActive)

  self.skillUpgradeList[index]:SetActive(isActive);
  if(self.tableShowLast[index]~=isActive)then
    self.tableShowLast[index]=isActive
    self:ShowInNextFrameII(self.FX_UpSkillButton1) 
    self:ShowInNextFrameII(self.FX_UpSkillButton2) 
    self:ShowInNextFrameII(self.FX_UpSkillButton3) 
  end
end
--------------------当前目标血量等信息--------------------
function UIBattleAPI:SetTargetInfo(isActive,Icon,currentHp,maxHp,currentMp,maxMp,ValueA,ValueM,ValueAD,ValueMD)
  if(isActive==false)then
    self.targetInfos[8].transform.parent.gameObject:SetActive(false);
    return;
  end

  self.targetInfos[8].transform.parent.gameObject:SetActive(true);
  --Debugger.LogError( Icon)
  if(Icon~=0 and Icon~="" and Icon~=nil)then
    --self.targetInfos[1].sprite=UITools.GetSpriteBattle("uibattle",Icon)

    
   
      self.targetInfos[1].sprite=UITools.GetSpriteBattle("uibattle",Icon)
    

  end
  self.targetInfos[2].fillAmount =currentHp / maxHp;
  self.targetInfos[3].text=math.ceil(currentHp) .. "/" .. math.ceil(maxHp)
  self.targetInfos[4].fillAmount =currentMp / maxMp;
  self.targetInfos[5].text=math.floor( ValueA);
  self.targetInfos[6].text=math.floor(ValueM);
  self.targetInfos[7].text=math.floor(ValueAD);
  self.targetInfos[8].text=math.floor(ValueMD);
end
------------------------------复活计时----------------------------
function UIBattleAPI:ReviveCountDown(second)
    
  
  self.Co_CountDownRevive= coroutine.start(self.CountDownRevive ,self , second) 
end
function UIBattleAPI:CountDownRevive(second)

  --开始死亡打开Collider
  for k,v in pairs(self.DeadColliders) do
    v:SetActive(true)
  end
  self.isDead=true

  if(self.reviveTime.activeSelf==false)then
    self.reviveTime:SetActive(true)
  end 

  while(second>0.1) do   
    second=second-Time.deltaTime
    --local hS=""
    local mS=""
    local sS=""

    --local h= math.floor(second/3600)
    local m= math.floor(second%3600/60)
    local s= math.floor(second%60)

    --if(h<10)then
    --  hS= "0" .. h;
    --else
    --  hS= h;
    --end
    
    if(m<10)then
      mS= "0" .. m;
    else
      mS= m;
    end

    if(s<10)then
      sS= "0" .. s;
    else
      sS= s;
    end

    self.textReviveTime.text=mS .. ":" ..  sS;

    coroutine.step();
  end

  if(self.reviveTime.activeSelf==true)then
    self.reviveTime:SetActive(false)
  end  
  
  --结束死亡关闭Collider
  for k,v in pairs(self.DeadColliders) do
    v:SetActive(false)
  end
  self.isDead=false
  self:HideTips()
end
------------------------------发起投降----------------------------
function UIBattleAPI:InitiateCapitulate(bool)
  
  if(not self.Capitulate.activeSelf)then
    self.Capitulate:SetActive(true);
  end

  for i=1,self.CapitulateGroup.childCount,1 do
    if(not self.CapitulateGroup:GetChild(i-1):GetChild(0).gameObject.activeSelf)then
      self.CapitulateGroup:GetChild(i-1):GetChild(0).gameObject:SetActive(true);
      if(bool)then
        self.CapitulateGroup:GetChild(i-1):GetChild(0):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-Capitulate")
      else
        self.CapitulateGroup:GetChild(i-1):GetChild(0):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-Capitulate2")
      end
      break
    end
  end 
end
------------------------------隐藏重置投降----------------------------
function UIBattleAPI:HideCapitulate(bool)
  
  self.Capitulate:SetActive(true);
  
  for i=1,self.CapitulateGroup.childCount,1 do
      self.CapitulateGroup:GetChild(i-1):GetChild(0).gameObject:SetActive(false);    
  end 
end
-------------------------------设置游戏模式-------------------------
function UIBattleAPI:SetGameMode(playerCount)
  for i=1,playerCount,1 do
     self.CapitulateGroup:GetChild(i-1).gameObject:SetActive(true)
  end
end
----------------------初始化小地图单位------------------------
function UIBattleAPI:MiniMapCreate(id,type,camp,icon)  --camp:0自己，1友军 ，2敌方  --type:1基地，2塔，3Boss，4英雄，5小兵，
    --if(self.tableUnit[id]~=nil)then
    --  return;
    --end
    --Debugger.LogError("创建" .. id)
    local go
    --self.tableUnit={} 
    if(type==4)then --英雄
      
      if(camp==0)then                  
        go =UIPool.Instance:Get("MapHeroSelf");  go.transform:SetParent(self.miniMap:FindChild("HeroAllys")); self.heroSelfId=id;
      elseif(camp==1)then
        go =UIPool.Instance:Get("MapHeroAlly");  go.transform:SetParent(self.miniMap:FindChild("HeroAllys"));
      elseif(camp==2)then
        go =UIPool.Instance:Get("MapHeroEnemy"); go.transform:SetParent(self.miniMap:FindChild("HeroEnemies"));
      end
      if(icon~=0 and icon~="" and icon~=nil)then
        go.transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle",icon)
      end
      
    elseif(type==5)then --小兵
  
      if(camp==1)then
        go =UIPool.Instance:Get("MapAlly");  
        go.transform:SetParent(self.miniMap:FindChild("Allys"));
      elseif(camp==2)then
        go =UIPool.Instance:Get("MapEnemy");
        go.transform:SetParent(self.miniMap:FindChild("Enemies"));
      end
    
      
    elseif(type==3)then
    
      go =UIPool.Instance:Get("MapDragonSmall");
      go.transform:SetParent(self.miniMap:FindChild("Boss"));
    elseif(type==6)then
      go =UIPool.Instance:Get("MapDragonBig");
      go.transform:SetParent(self.miniMap:FindChild("Boss"));
    elseif(type==1)then
    
      if(camp==1)then
         go =UIPool.Instance:Get("MapBaseB");
        go.transform:SetParent(self.miniMap:FindChild("BaseBs"));
      elseif(camp==2)then
         go =UIPool.Instance:Get("MapBaseR");
         go.transform:SetParent(self.miniMap:FindChild("BaseRs"));
      end
     
    elseif(type==2)then
 
      if(camp==1)then
         go =UIPool.Instance:Get("MapTowerB");
        go.transform:SetParent(self.miniMap:FindChild("TowerBs"));
      elseif(camp==2)then
         go =UIPool.Instance:Get("MapTowerR");
         go.transform:SetParent(self.miniMap:FindChild("TowerRs"));
      end

    
    end
    go.transform.localScale = Vector3.one; 
    go.transform.localPosition = Vector3.New(-1000,0,0);

    self.tableUnit[id]=go;
    self.tableUnitType[id]=type
    self.tableUnitCamp[id]=camp
    self.tableUnitIcon[id]=icon
     --Debugger.LogError("存入类型：" .. type(id))
  
    local listener = NTGEventTriggerProxy.Get(go);
        listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
          function ()
            
            --友方客户端显示按下特效============================================================================================================================
            --self.this:InvokeDelegate(self.delegateSyncMapFx,self.heroSelfId,id)  --Send
            self:SyncMapFx(id)  self:SyncMapTip(self.heroSelfId,id)
            --更改大小及碰撞
            self.miniMapRT.localScale=Vector3.one
            self.MapColliderSmall:SetActive(true)
            self.MapColliderBig:SetActive(false)
            self.MapSmall:SetActive(true)
            self.MapBig:SetActive(false)
          end,self
        )

    return go;    
end
----------------------更新小地图单位------------------------
function UIBattleAPI:MiniMapRefresh(id,syncType,param)  --1坐标或2血量
  if(syncType==2)then
    self.tableUnit[id].transform:FindChild("Hp"):GetComponent("UnityEngine.UI.Image").fillAmount=param;
  elseif(syncType==1)then 
    self.tableUnit[id].transform.localPosition=Vector3.New( self.miniMapRT.sizeDelta.x*(param.x-0.5),self.miniMapRT.sizeDelta.y*(param.y-0.5),0  )
  end
end
----------------------销毁小地图单位------------------------
function UIBattleAPI:MiniMapDestroy(id)
    --if(self.tableUnit[id]==nil)then
    --  return;
    --end

  --[[
  if(self.tableUnit[id]==nil)then
    Debugger.LogError("<color=#FFFF00>重复移出："  .. id .. "</color>")
  else
    Debugger.LogError("移出："  .. id .. "\t实体：" .. self.tableUnit[id].name .. "\t类型：" .. self.tableUnitType[id] .. "\t阵营：" .. self.tableUnitCamp[id] .. "\t图标：" .. self.tableUnitIcon[id] )
  end
  --]]
  UIPool.Instance:Return(self.tableUnit[id]) 
  
  self.tableUnit[id]=nil
  self.tableUnitType[id]=nil
  self.tableUnitCamp[id]=nil
  self.tableUnitIcon[id]=nil
end
-------------------------指令提示---------------------------
function UIBattleAPI:ShowDictate(typeIcon,typeText,sponsorId,targetId) 
  
  --UITools.GetSpriteBattle("uibattle","BUI-CenterCircleRed") ; 
  --self.tableDictateTip={}--指令提示集合
  local go =UIPool.Instance:Get("DictateTip");
  
  go.transform:FindChild("Bg/IconDictate"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle",typeIcon) ; 
  go.transform:FindChild("Bg/Text"):GetComponent("UnityEngine.UI.Text").text=typeText
  if(self.tableUnitIcon[sponsorId]~=0 and self.tableUnitIcon[sponsorId]~="" and self.tableUnitIcon[sponsorId]~=nil)then 
    go.transform:FindChild("Bg/IconRole1"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle",self.tableUnitIcon[sponsorId]) ; 
    if(self.tableUnitCamp[sponsorId]==0)then
      go.transform:FindChild("Bg/IconRole1/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellSelf") ; 
    elseif(self.tableUnitCamp[sponsorId]==1)then
      go.transform:FindChild("Bg/IconRole1/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellAlly") ; 
    else
      go.transform:FindChild("Bg/IconRole1/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellEnemy") ; 
    end
  end
  if(self.tableUnitIcon[targetId]~=0 and self.tableUnitIcon[targetId]~="" and self.tableUnitIcon[targetId]~=nil)then 
    go.transform:FindChild("Bg/IconRole2").gameObject:SetActive(true);
    if(self.tableUnitCamp[targetId]==0)then
      go.transform:FindChild("Bg/IconRole2/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellSelf") ; 
    elseif(self.tableUnitCamp[targetId]==1)then
      go.transform:FindChild("Bg/IconRole2/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellAlly") ; 
    else
      go.transform:FindChild("Bg/IconRole2/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellEnemy") ; 
    end
    go.transform:FindChild("Bg/IconRole2"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle",self.tableUnitIcon[targetId]) ; 
  else
    go.transform:FindChild("Bg/IconRole2").gameObject:SetActive(false);
  end
  go:GetComponent("Animator"):Play("BUI-DictateTip",0,0) ;
  UIPool.Instance:ReturnDelay(go,5,self,function() table.remove(self.tableDictateTip,1)     end)
  
  go.transform:SetParent(self.dictateTips);
  go.transform.localScale = Vector3.one; 

  if(#self.tableDictateTip==0)then                         
    self.tipZero=true;--归零区分处理逻辑：一种是清空之后新加的第二个，就直接放在Y60的位置；一种是尚未清空，这时候60被第一个占用，第二个就把第一个顶上去
    go.transform.localPosition = Vector3.New(0, 120, 0);  table.insert(self.tableDictateTip,go);
  elseif(#self.tableDictateTip==1)then                      
    if(self.tipZero==true)then                                                              
      go.transform.localPosition = Vector3.New(0, 60, 0);   table.insert(self.tableDictateTip,go);
    else                                                                                                       
      go.transform.localPosition = Vector3.New(0, 0, 0);   table.insert(self.tableDictateTip,go);
      for k,v in pairs( self.coroutineTable) do --停止协程
        coroutine.stop(v)
      end
      self.coroutineTable={} --清空协程列表
      for i=1,#self.tableDictateTip,1 do
        local co= coroutine.start( self.LerpDictateTip , self , self.tableDictateTip[i].transform , Vector3.New(0, (#self.tableDictateTip+1-i)*60, 0) )
        table.insert(self.coroutineTable,co)  --插入协程列表
      end

    end
    self.tipZero=false;--归零
  else                                                      
    go.transform.localPosition = Vector3.New(0, 0, 0);    table.insert(self.tableDictateTip,go);
    for k,v in pairs( self.coroutineTable) do --停止协程
      coroutine.stop(v)
    end
    self.coroutineTable={} --清空协程列表

    for i=1,#self.tableDictateTip,1 do
      local co=coroutine.start(  self.LerpDictateTip , self ,self.tableDictateTip[i].transform , Vector3.New(0, (#self.tableDictateTip+1-i)*60, 0) )
      table.insert(self.coroutineTable,co)  --插入协程列表
    end
    
  end
end
function UIBattleAPI:ShowChatTip(chatText,icon,camp) 
  
  --self.tableDictateTip={}--指令提示集合
  local go =UIPool.Instance:Get("ChatTip");
  
  --go.transform:FindChild("Bg/IconDictate"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle",typeIcon) ; 
  go.transform:FindChild("Bg/Text"):GetComponent("UnityEngine.UI.Text").text=chatText
  if(icon~=0 and icon~="" and icon~=nil)then --self.tableUnitIcon[sponsorId] 
    go.transform:FindChild("Bg/IconRole1"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle",icon) ; 
    --if(self.tableUnitCamp[sponsorId]==0)then
    if(camp==0)then
      go.transform:FindChild("Bg/IconRole1/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellSelf") ; 
    --elseif(self.tableUnitCamp[sponsorId]==1)then
    elseif(camp==1)then
      go.transform:FindChild("Bg/IconRole1/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellAlly") ; 
    else
      go.transform:FindChild("Bg/IconRole1/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellEnemy") ; 
    end
  end
  --[[
  if(self.tableUnitIcon[targetId]~=0 and self.tableUnitIcon[targetId]~="" and self.tableUnitIcon[targetId]~=nil)then 
    go.transform:FindChild("Bg/IconRole2").gameObject:SetActive(true);
    if(self.tableUnitCamp[targetId]==0)then
      go.transform:FindChild("Bg/IconRole2/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellSelf") ; 
    elseif(self.tableUnitCamp[targetId]==1)then
      go.transform:FindChild("Bg/IconRole2/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellAlly") ; 
    else
      go.transform:FindChild("Bg/IconRole2/Cell"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-CellEnemy") ; 
    end
    go.transform:FindChild("Bg/IconRole2"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle",self.tableUnitIcon[targetId]) ; 
  else
    go.transform:FindChild("Bg/IconRole2").gameObject:SetActive(false);
  end
  --]]
  go:GetComponent("Animator"):Play("BUI-DictateTip",0,0) ;
  UIPool.Instance:ReturnDelay(go,5,self,function() table.remove(self.tableDictateTip,1)     end)
  
  go.transform:SetParent(self.dictateTips);
  go.transform.localScale = Vector3.one; 

  if(#self.tableDictateTip==0)then                         
    self.tipZero=true;--归零区分处理逻辑：一种是清空之后新加的第二个，就直接放在Y60的位置；一种是尚未清空，这时候60被第一个占用，第二个就把第一个顶上去
    go.transform.localPosition = Vector3.New(0, 120, 0);  table.insert(self.tableDictateTip,go);
  elseif(#self.tableDictateTip==1)then                      
    if(self.tipZero==true)then                                                              
      go.transform.localPosition = Vector3.New(0, 60, 0);   table.insert(self.tableDictateTip,go);
    else                                                                                                       
      go.transform.localPosition = Vector3.New(0, 0, 0);   table.insert(self.tableDictateTip,go);
      for k,v in pairs( self.coroutineTable) do --停止协程
            coroutine.stop(v)
      end
      self.coroutineTable={} --清空协程列表
      for i=1,#self.tableDictateTip,1 do
        local co=coroutine.start(  self.LerpDictateTip ,self , self.tableDictateTip[i].transform , Vector3.New(0, (#self.tableDictateTip+1-i)*60, 0) )
        table.insert(self.coroutineTable,co)  --插入协程列表
      end

    end
    self.tipZero=false;--归零
  else                                                      
    go.transform.localPosition = Vector3.New(0, 0, 0);    table.insert(self.tableDictateTip,go);
    for k,v in pairs( self.coroutineTable) do --停止协程
         coroutine.stop(v)
    end
    self.coroutineTable={} --清空协程列表

    for i=1,#self.tableDictateTip,1 do
      local co=coroutine.start( self.LerpDictateTip , self , self.tableDictateTip[i].transform , Vector3.New(0, (#self.tableDictateTip+1-i)*60, 0) )
      table.insert(self.coroutineTable,co)  --插入协程列表
    end
    
  end
end
-----------------------------------同步小地图标记--------------------------------
function UIBattleAPI:SyncMapTipSign(sponsorId,targetId)
  self:ShowDictate("BUI-Sign","注意",sponsorId,targetId) 
end
-----------------------------------同步小地图普通提示----------------------------
function UIBattleAPI:SyncMapTip(sponsorId,targetId)

  local typeIcon,typeText;
  if(self.tableUnitCamp[targetId]==0 or self.tableUnitCamp[targetId]==1)then  --点击友方
    typeIcon="BUI-RB2";  --盾牌图片
    if(self.tableUnitType[targetId]==4)then  --英雄显示保护 其他显示撤退
      typeText="保护";
    else
      typeText="撤退";
    end
  else  --点击敌方
    typeIcon="BUI-RB1";  --手雷图片
    typeText="进攻";
  end

  self:ShowDictate(typeIcon,typeText,sponsorId,targetId) 
  --self:ShowChatTip("聊天测试","I11000501",2) 
end
-----------------------------------同步指令按钮----------------------------------
function UIBattleAPI:SyncMapTipDictate(sponsorId,type)

  local typeIcon,typeText;
  if(type=="1")then  --进攻
    typeIcon="BUI-RB1";  
    typeText="进攻";
  elseif(type=="2")then  --防御
    typeIcon="BUI-RB2";  
    typeText="进攻";
  else  --type==3集合
    typeIcon="BUI-RB3";  
    typeText="进攻";
  end

  self:ShowDictate(typeIcon,typeText,sponsorId,targetId)       
end
---------------------------------------------------------------------
function UIBattleAPI:LerpDictateTip(currentT, nextPos) --Transform,Vector3
  
  if(currentT)then
    while(true)do
      currentT.localPosition = Vector3.Lerp(currentT.localPosition, nextPos, 0.1); 
        --currentT.localPosition = Vector3.Slerp(Vector3.one, nextPos, 0.05);
      coroutine.step();
      --Debugger.LogError( currentT.localPosition)     Debugger.LogError(nextPos)  Debugger.LogError(currentT.localPosition.x - nextPos.x)
      if(math.abs(currentT.localPosition.y - nextPos.y)< 0.01)then
        break;
      end
    end
  end
end
-------------------------信息提示---------------------------
function UIBattleAPI:ShowMessage(type,amount,killerIsAlly,killerIcon,victimIcon) 

    local bg;
    local anim;
    local go
    if(type==0)then
    
      bg=self.Sprites.BUI_K_A_Normal_Bg
      anim="T1"
      if(amount==1)then      --欢迎来到
        go =UIPool.Instance:Get("MessageTI");
      elseif(amount==2)then  --5秒之后
        go =UIPool.Instance:Get("MessageTII");
      elseif(amount==3)then  --双方军团开始出兵
        go =UIPool.Instance:Get("MessageTIII");
      elseif(amount==4)then  --退出游戏             需要参数:阵营，Icon
        go =UIPool.Instance:Get("MessageTCB");
      elseif(amount==5)then  --重新连接             需要参数:阵营，Icon
        go =UIPool.Instance:Get("MessageTCR");
      elseif(amount==6)then  --攻城车加入战场       需要参数:阵营，（Icon）
        go =UIPool.Instance:Get("MessageT0");
      elseif(amount==7)then  --派出超级兵           需要参数:阵营，（Icon）
        killerIcon="I16011011";
        if(killerIsAlly)then
          go =UIPool.Instance:Get("MessageT1");--我方
        else
          go =UIPool.Instance:Get("MessageT2");--敌方
        end  
      elseif(amount==8)then  --摧毁防御塔           需要参数:阵营，（Icon）
        if(killerIsAlly)then
          go =UIPool.Instance:Get("MessageT3");--我方
        else
          go =UIPool.Instance:Get("MessageT4");--敌方
        end 
      end

    elseif(type==1)then --连杀
    
      
       
      if(amount==0)then      --一血
        go =UIPool.Instance:Get("MessageK0"); anim="K2"; if(killerIsAlly)then  bg=self.Sprites.BUI_K_A_First_Bg else bg=self.Sprites.BUI_K_E_First_Bg end;
      elseif(amount==1)then  --击杀
        go =UIPool.Instance:Get("MessageK1"); anim="K1"; if(killerIsAlly)then  bg=self.Sprites.BUI_K_A_Normal_Bg else bg=self.Sprites.BUI_K_E_Normal_Bg end;
      elseif(amount==2)then  --双杀
        go =UIPool.Instance:Get("MessageK2"); anim="K2"; if(killerIsAlly)then  bg=self.Sprites.BUI_K_A_II_Bg else bg=self.Sprites.BUI_K_E_II_Bg end;
      elseif(amount==3)then  --
        go =UIPool.Instance:Get("MessageK3"); anim="K3"; if(killerIsAlly)then  bg=self.Sprites.BUI_K_A_II_Bg else bg=self.Sprites.BUI_K_E_II_Bg end;
      elseif(amount==4)then  --
        go =UIPool.Instance:Get("MessageK4"); anim="K3"; if(killerIsAlly)then  bg=self.Sprites.BUI_K_A_II_Bg else bg=self.Sprites.BUI_K_E_II_Bg end;
      elseif(amount==5)then  --
        go =UIPool.Instance:Get("MessageK5"); anim="K3"; if(killerIsAlly)then  bg=self.Sprites.BUI_K_A_II_Bg else bg=self.Sprites.BUI_K_E_II_Bg end;
      elseif(amount==6)then  --团灭
        go =UIPool.Instance:Get("MessageK6"); anim="K2"; if(killerIsAlly)then  bg=self.Sprites.BUI_K_A_II_Bg else bg=self.Sprites.BUI_K_E_II_Bg end;
      else                   --默认
        go =UIPool.Instance:Get("MessageK5"); anim="K3"; if(killerIsAlly)then  bg=self.Sprites.BUI_K_A_II_Bg else bg=self.Sprites.BUI_K_E_II_Bg end;
      end

    elseif(type==2)then --累计击杀

      if(killerIsAlly)then
        bg=self.Sprites.BUI_K_A_IV_Bg
      else
        bg=self.Sprites.BUI_K_E_IV_Bg
      end
      anim="K2"
      if(amount==3)then      --累计3个
        go =UIPool.Instance:Get("MessageKC3");
      elseif(amount==4)then  --累计4个
        go =UIPool.Instance:Get("MessageKC4");
      elseif(amount==5)then  --
        go =UIPool.Instance:Get("MessageKC5");
      elseif(amount==6)then  --
        go =UIPool.Instance:Get("MessageKC6");
      elseif(amount==7)then  --
        go =UIPool.Instance:Get("MessageKC7");
      elseif(amount==8)then  --终结
        go =UIPool.Instance:Get("MessageKC8");
      else                   --默认
        go =UIPool.Instance:Get("MessageKC7");
      end

    end

    go.transform:SetParent(self.Message);
    go.transform.localPosition=Vector3.zero
    go.transform.localScale=Vector3.one
    go.transform.localRotation = Quaternion.identity 
    UIQueue.Enqueue(self.messageTipQueue,{UITools.GetLuaScript(go,"Logic.M022.UIBattle.UIDisplayMessage"),bg,anim,type,amount,killerIsAlly,killerIcon,victimIcon})
end
-------------------------信息提示Co-------------------------
function UIBattleAPI:ShowMessageInterval() 
  coroutine.step() 
  while(true)do
    if(UIQueue.NotNull(self.messageTipQueue))then
      local o=UIQueue.Dequeue(self.messageTipQueue)
     
      o[1]:DisplayMessage(o[2],o[3],o[4],o[5],o[6],o[7],o[8])


      UIPool.Instance:ReturnDelay(o[1].this.gameObject,4) 
      coroutine.wait(3)
    end 
    coroutine.step()
  end
end
----------------------友方客户端显示标记--------------------
function UIBattleAPI:SyncMapFxSign(ratioPos)--形参Vector2(0~1，0~1)
      local s=UIPool.Instance:Get("MiniMapSign");
      s.transform:SetParent(self.miniMap)
      s.transform.localScale=Vector3.one
      s.transform.localPosition=Vector3.New( self.miniMapRT.sizeDelta.x*(ratioPos.x),self.miniMapRT.sizeDelta.y*(ratioPos.y-1),0  )
      UIPool.Instance:ReturnDelay(s,4)
end  
----------------------友方客户端显示特效--------------------
function UIBattleAPI:SyncMapFx(id)--可能需要传ID
   
    local GO;  
    if(self.tableUnitCamp[id]==0 or self.tableUnitCamp[id]==1)then --如果camp是己方
      GO = self.tableUnit[id].transform:FindChild("FXs/W").gameObject   
    else  --UIPool.Instance:ReturnDelay(s,4)
      GO = self.tableUnit[id].transform:FindChild("FXs/B").gameObject
    end
   
    GO:SetActive(true);
    self:SetActiveFalse(GO)
end  
----------------------友方客户端显示特效被攻击--------------
function UIBattleAPI:SyncMapFxDamage(id)--可能需要传ID
    --type
    local GO;
    --if(camp==0 or camp==1)then
      GO = self.tableUnit[id].transform:FindChild("FXs/R").gameObject    
    --else  --UIPool.Instance:ReturnDelay(s,4)
      --GO = go.transform:FindChild("FXs/B").gameObject
    --end
    GO:SetActive(true);
    self:SetActiveFalse(GO)
end  
----------------------友方客户端显示指令特效--------------
function UIBattleAPI:SyncMapFxDictate(id,type)--可能需要传ID
    local GO;
    if(type=="1")then
      GO = self.tableUnit[id].transform:FindChild("FXs/B").gameObject    
    elseif(type=="2")then
      GO = self.tableUnit[id].transform:FindChild("FXs/W").gameObject    
    else
      GO = self.tableUnit[id].transform:FindChild("FXs/G").gameObject    
    end
    GO:SetActive(true);
    self:SetActiveFalse(GO)
end  
----------------------关闭小地图上的特效--------------------
function UIBattleAPI:SetActiveFalse(go)--w，y，b，r

  coroutine.start( self.CloseInTime,self,go)
end
--------------------------------------------------------------
function UIBattleAPI:CloseInTime(go)--w，y，b，r
  coroutine.wait(4)
  go:SetActive(false);
end
function UIBattleAPI:ShowInNextFrame(go)
  
  if(self.Coros[go.name]~=nil)then
    coroutine.stop(self.Coros[go.name])  --为了不快速按的时候，协程冲突
  end
  self.Coros[go.name]=coroutine.start( self.OpenInNextFrame,self,go)
  
end
function UIBattleAPI:OpenInNextFrame(target)  --Transform,Vector3
  target:SetActive(false);
  coroutine.step();
  target:SetActive(true); --Debugger.LogError("是");
  coroutine.wait(2)
  target:SetActive(false);
end
function UIBattleAPI:ShowInNextFrameII(go)  --这个播放之后不隐藏
  
  if(self.Coros[go.name]~=nil)then
    coroutine.stop(self.Coros[go.name])
  end
  self.Coros[go.name]=coroutine.start( self.OpenInNextFrameII,self,go)
  
end
function UIBattleAPI:OpenInNextFrameII(target)  --Transform,Vector3
  target:SetActive(false);
  coroutine.step();
  target:SetActive(true); --Debugger.LogError("是");
end
function UIBattleAPI:ShowAfterTime(go,time) 

  if(self.Coros[go.name]~=nil)then
    coroutine.stop(self.Coros[go.name])
  end
  self.Coros[go.name]=coroutine.start( self.ShowAfterTimeCo,self,go,time)  
  
end
function UIBattleAPI:ShowAfterTimeCo(target,time)  --Transform,Vector3
  target:SetActive(false);
  coroutine.wait(time)
  target:SetActive(true); --Debugger.LogError("是");
  coroutine.wait(2)
  target:SetActive(false);
end
----------------------------设置参数--------------------------
function UIBattleAPI:SetParam()
    
    self.Coros={}
    
    self.Reconnect=self.this.transform:FindChild("Reconnect").gameObject

    self.fxIsCanNotShows={false,false,false}
    --self.fxIsCanNotShows={true,true,true}
  --上次是否开关技能升级按钮
    self.tableShowLast={true,true,true}
  --可爱的特效们
    self.tableFXs={};

    self.FX_EquipClick1=self.this.transform:FindChild("Center/RecoEffects/R51140120I").gameObject  table.insert( self.tableFXs,self.FX_EquipClick1 )
    self.FX_EquipClick2=self.this.transform:FindChild("Center/RecoEffects/R51140120II").gameObject  table.insert( self.tableFXs,self.FX_EquipClick2 )

    self.FX_UpSkillButton1=self.this.transform:FindChild("BottomRight/UpgradeSkill1/R51140180I").gameObject  table.insert( self.tableFXs,self.FX_UpSkillButton1 ) 
    self.FX_UpSkillButton2=self.this.transform:FindChild("BottomRight/UpgradeSkill2/R51140180II").gameObject  table.insert( self.tableFXs,self.FX_UpSkillButton2 ) 
    self.FX_UpSkillButton3=self.this.transform:FindChild("BottomRight/UpgradeSkill3/R51140180III").gameObject  table.insert( self.tableFXs,self.FX_UpSkillButton3 ) 
    
    self.FX_UpLevelMove1=self.this.transform:FindChild("BottomRight/Skill1/R51140190I").gameObject  table.insert( self.tableFXs,self.FX_UpLevelMove1 ) --点击升级按钮
    self.FX_UpLevelMove2=self.this.transform:FindChild("BottomRight/Skill2/R51140190II").gameObject  table.insert( self.tableFXs,self.FX_UpLevelMove2 )--点击升级按钮
    self.FX_UpLevelMove3=self.this.transform:FindChild("BottomRight/Skill3/R51140190III").gameObject  table.insert( self.tableFXs,self.FX_UpLevelMove3 )--点击升级按钮

    self.FX_LevelUp1=self.this.transform:FindChild("BottomRight/Skill1/R51140190BI").gameObject  table.insert( self.tableFXs,self.FX_LevelUp1 )
    self.FX_LevelUp2=self.this.transform:FindChild("BottomRight/Skill2/R51140190BII").gameObject  table.insert( self.tableFXs,self.FX_LevelUp2 )
    self.FX_LevelUp3=self.this.transform:FindChild("BottomRight/Skill3/R51140190BIII").gameObject  table.insert( self.tableFXs,self.FX_LevelUp3 )
    
    self.FX_CDOvers={}
    self.FX_CDOver1=self.this.transform:FindChild("BottomRight/Skill1/R51140200I").gameObject  table.insert( self.tableFXs,self.FX_CDOver1 )
    self.FX_CDOver2=self.this.transform:FindChild("BottomRight/Skill2/R51140200II").gameObject  table.insert( self.tableFXs,self.FX_CDOver2 )
    self.FX_CDOver3=self.this.transform:FindChild("BottomRight/Skill3/R51140200III").gameObject  table.insert( self.tableFXs,self.FX_CDOver3 )
    self.FX_CDOvers={self.FX_CDOver1,self.FX_CDOver2,self.FX_CDOver3}

    self.FX_Click1=self.this.transform:FindChild("BottomRight/Skill1/R51140220I").gameObject  table.insert( self.tableFXs,self.FX_Click1 )
    self.FX_Click2=self.this.transform:FindChild("BottomRight/Skill2/R51140220II").gameObject  table.insert( self.tableFXs,self.FX_Click2 )
    self.FX_Click3=self.this.transform:FindChild("BottomRight/Skill3/R51140220III").gameObject  table.insert( self.tableFXs,self.FX_Click3 )

    self.FX_ATK=self.this.transform:FindChild("BottomRight/Colliders/ATKCollider/R51140210I").gameObject  table.insert( self.tableFXs,self.FX_ATK )
    self.FX_SelectHero=self.this.transform:FindChild("BottomRight/Colliders/ChoseHeroCollider/R51140210II").gameObject  table.insert( self.tableFXs,self.FX_SelectHero)
    self.FX_SelectSoldier=self.this.transform:FindChild("BottomRight/Colliders/ChoseSoldierCollider/R51140210III").gameObject  table.insert( self.tableFXs, self.FX_SelectSoldier )
    --特效寻找材质
    for i,v in ipairs(self.tableFXs) do 
      local btn = self.tableFXs[i]:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
      for k = 0,btn.Length - 1 do
        self.tableFXs[i]:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
      end
    end
  

  --当前角色Id
  

  --指令协程列表
  self.coroutineTable={}
  --指令提示集合
  self.tableDictateTip={}
  --推荐装备的父物体
  self.RecoEquipParent=self.this.transform:FindChild("Center/RecoEquips")

  self.buttonDetail=self.this.transform:FindChild("TopRight/Infos/Bg/ButtonDetail").gameObject
  local listener = NTGEventTriggerProxy.Get(  self.buttonDetail);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
      BattleInfoAPI.Instance:OpenControl()
    end,self
  )
  -------------------------------------------------------------
  self.buttonPopRight=self.this.transform:FindChild("BottomRight/ButtonPop").gameObject
 
  self.buttonOpenShop=self.this.transform:FindChild("Center/Coin").gameObject
  listener = NTGEventTriggerProxy.Get(  self.buttonOpenShop);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
      PVPMallAPI.Instance:OpenPanel()
    end,self
  )

  self.dictateTips=self.this.transform:FindChild("Center/DictateMask/DictateTips")

  self.Capitulate=self.this.transform:FindChild("Center/Capitulate").gameObject
  self.CapitulateGroup=self.this.transform:FindChild("Center/Capitulate/CapitulateGroup")
  
  self.reviveTime=self.this.transform:FindChild("Center/ReviveCountDown").gameObject
  self.textReviveTime=self.this.transform:FindChild("Center/ReviveCountDown/Text"):GetComponent("UnityEngine.UI.Text")
  
  self.Message=self.this.transform:FindChild("Message")
  -------------------------------Buff-----------------------------
  self.BuffsParent=self.this.transform:FindChild("BottomRight/Buffs")
  self.tableBuff={{},{},{},{},{},{},{},{}}
  for i=1,8,1 do
    self.tableBuff[i]["GO"]=self.BuffsParent:GetChild(i-1).gameObject;
    self.tableBuff[i]["icon"]=self.BuffsParent:GetChild(i-1):FindChild("Buff"):GetComponent("UnityEngine.UI.Image")
    self.tableBuff[i]["desc"]=self.BuffsParent:GetChild(i-1):FindChild("Tip/Desc"):GetComponent("UnityEngine.UI.Text")
    self.tableBuff[i]["cd"]=self.BuffsParent:GetChild(i-1):FindChild("CD"):GetComponent("UnityEngine.UI.Image")
  end
  ---------------------------小地图相关---------------------------
  self.heroSelfId=""
  self.tableUnit={}  
  self.tableUnitType={}
  self.tableUnitCamp={}
  self.tableUnitIcon={}
  self.miniMapPrefabs = self.this.transform:FindChild("TopLeft/MiniMap/Prefabs")
  self.miniMap= self.this.transform:FindChild("TopLeft/MiniMap/I/Map")
  self.miniMapRT=self.miniMap:GetComponent("RectTransform")
  -----------------------当前目标血量等信息-----------------------
  self.targetInfos={}
  table.insert(self.targetInfos, self.this.transform:FindChild("TopRight/HPcurrency/Bg/Icon"):GetComponent("UnityEngine.UI.Image") )  --1
  table.insert(self.targetInfos, self.this.transform:FindChild("TopRight/HPcurrency/Bg/HPCurrency"):GetComponent("UnityEngine.UI.Image") )     --2
  table.insert(self.targetInfos, self.this.transform:FindChild("TopRight/HPcurrency/Bg/HPCurrency/CurrentSlashMax"):GetComponent("UnityEngine.UI.Text")  ) --3
  table.insert(self.targetInfos, self.this.transform:FindChild("TopRight/HPcurrency/Bg/MPCurrency"):GetComponent("UnityEngine.UI.Image")  )--4
  table.insert(self.targetInfos, self.this.transform:FindChild("TopRight/HPcurrency/Bg/TextATK"):GetComponent("UnityEngine.UI.Text")  ) --5
  table.insert(self.targetInfos, self.this.transform:FindChild("TopRight/HPcurrency/Bg/TextATKMagic"):GetComponent("UnityEngine.UI.Text")  )--6 
  table.insert(self.targetInfos, self.this.transform:FindChild("TopRight/HPcurrency/Bg/TextDEF"):GetComponent("UnityEngine.UI.Text")  ) --7
  table.insert(self.targetInfos, self.this.transform:FindChild("TopRight/HPcurrency/Bg/TextDEFMagic"):GetComponent("UnityEngine.UI.Text")  )--8 
  ----------------------------暂停按键----------------------------
  self.PauseButton= self.this.transform:FindChild("TopRight/ButtonPause").gameObject 
  ----------------------------指令按键----------------------------
  self.directiveButtons={}
  table.insert(self.directiveButtons, self.this.transform:FindChild("TopRight/Directive/Button1").gameObject )
  table.insert(self.directiveButtons, self.this.transform:FindChild("TopRight/Directive/Button2").gameObject ) 
  table.insert(self.directiveButtons, self.this.transform:FindChild("TopRight/Directive/Button3").gameObject ) 
  --table.insert(self.directiveButtons, self.this.transform:FindChild("TopRight/Directive/Button4").gameObject ) 
  
  ------------------------------------------------>>>技能相关<<<------------------------------------------------
  --给取消技能按钮添加事件 
  self.cancelSkillButton= self.this.transform:FindChild("TopRight/CancelSkillCollider").gameObject;
  local listener = NTGEventTriggerProxy.Get(  self.cancelSkillButton);
  listener.onPointerEnter = listener.onPointerEnter + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
      self.cancelSkill=true;   
      self.selectedCenterImage.sprite=UITools.GetSpriteBattle("uibattle","BUI-CenterCircleRed") ;  
      self.this:InvokeDelegate(self.delegateChangeColor,self.cancelSkill) --true红色
    end,self
  )
  listener.onPointerExit = listener.onPointerExit + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
      self.cancelSkill=false;  
      self.selectedCenterImage.sprite=UITools.GetSpriteBattle("uibattle","BUI-CenterCircleBlue") ;
      self.this:InvokeDelegate(self.delegateChangeColor,self.cancelSkill)
      --Debugger.LogError("EXIT")
      --self.this:InvokeDelegate(self.delegateSkillUp, self.idSkillUp)
    end,self
  )
 
 
  ---------------------------------------------------召唤师技能引用---------------------------------------------
  self.SummonSkill1P = self.this.transform:FindChild("BottomRight/SummonSkill1");
  self.SummonSkill2P = self.this.transform:FindChild("BottomRight/SummonSkill2");
  self.SummonSkill3P = self.this.transform:FindChild("BottomRight/SummonSkill3");
  
  table.insert( self.SummonSkillList.Icon,self.SummonSkill1P:FindChild("Icon"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.SummonSkillList.Icon,self.SummonSkill2P:FindChild("Icon"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.SummonSkillList.Icon,self.SummonSkill3P:FindChild("Icon"):GetComponent("UnityEngine.UI.Image"))
  
  table.insert( self.SummonSkillList.CD,self.SummonSkill1P:FindChild("CD"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.SummonSkillList.CD,self.SummonSkill2P:FindChild("CD"):GetComponent("UnityEngine.UI.Image"))  
  table.insert( self.SummonSkillList.CD,self.SummonSkill3P:FindChild("CD"):GetComponent("UnityEngine.UI.Image"))
  
  table.insert( self.SummonSkillList.CountDownText,self.SummonSkill1P:FindChild("CountDownText"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.CountDownText,self.SummonSkill2P:FindChild("CountDownText"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.CountDownText,self.SummonSkill3P:FindChild("CountDownText"):GetComponent("UnityEngine.UI.Text"))
  
  --table.insert( self.SummonSkillList.CountDownBg,self.SummonSkill1P:FindChild("CountDownBg"):GetComponent("UnityEngine.UI.Image")) 
  --table.insert( self.SummonSkillList.CountDownBg,self.SummonSkill2P:FindChild("CountDownBg"):GetComponent("UnityEngine.UI.Image")) 
  --table.insert( self.SummonSkillList.CountDownBg,self.SummonSkill3P:FindChild("CountDownBg"):GetComponent("UnityEngine.UI.Image")) 

  table.insert( self.SummonSkillList.Name,self.SummonSkill1P:FindChild("Name"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.Name,self.SummonSkill2P:FindChild("Name"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.Name,self.SummonSkill3P:FindChild("Name"):GetComponent("UnityEngine.UI.Text"))
  ---------------------------------------------------技能引用---------------------------------------------------
  local skill1P = self.this.transform:FindChild("BottomRight/Skill1");
  local skill2P = self.this.transform:FindChild("BottomRight/Skill2");
  local skill3P = self.this.transform:FindChild("BottomRight/Skill3");

  table.insert( self.skillList.Icon,skill1P:FindChild("IconMask/Icon"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.Icon,skill2P:FindChild("IconMask/Icon"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.Icon,skill3P:FindChild("IconMask/Icon"):GetComponent("UnityEngine.UI.Image"))
  
  table.insert( self.skillList.SkillLevel,skill1P:FindChild("SkillLevel"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.SkillLevel,skill2P:FindChild("SkillLevel"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.SkillLevel,skill3P:FindChild("SkillLevel"):GetComponent("UnityEngine.UI.Image"))
  
  table.insert( self.skillList.CountDownText,skill1P:FindChild("CountDownText"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.skillList.CountDownText,skill2P:FindChild("CountDownText"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.skillList.CountDownText,skill3P:FindChild("CountDownText"):GetComponent("UnityEngine.UI.Text"))

  --table.insert( self.skillList.CountDownBg,skill1P:FindChild("CountDownBg"):GetComponent("UnityEngine.UI.Image"))
  --table.insert( self.skillList.CountDownBg,skill2P:FindChild("CountDownBg"):GetComponent("UnityEngine.UI.Image"))
  --table.insert( self.skillList.CountDownBg,skill3P:FindChild("CountDownBg"):GetComponent("UnityEngine.UI.Image"))
  
  table.insert( self.skillList.CD,skill1P:FindChild("CD"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.CD,skill2P:FindChild("CD"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.CD,skill3P:FindChild("CD"):GetComponent("UnityEngine.UI.Image"))
  
  table.insert( self.skillList.BanSkill,skill1P:FindChild("BanSkill").gameObject)
  table.insert( self.skillList.BanSkill,skill2P:FindChild("BanSkill").gameObject)
  table.insert( self.skillList.BanSkill,skill3P:FindChild("BanSkill").gameObject)
  
  table.insert( self.skillList.NoBlue,skill1P:FindChild("NoBlue").gameObject)
  table.insert( self.skillList.NoBlue,skill2P:FindChild("NoBlue").gameObject)
  table.insert( self.skillList.NoBlue,skill3P:FindChild("NoBlue").gameObject)

  table.insert( self.skillList.SkillContinue,skill1P:FindChild("Continue"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.SkillContinue,skill2P:FindChild("Continue"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.SkillContinue,skill3P:FindChild("Continue"):GetComponent("UnityEngine.UI.Image"))
  
  ------------------------技能Tip引用------------------------    
  
  self.skillTips={}

  self.skillTip1 = self.this.transform:FindChild("BottomRight/SkillTips/SkillTip1");  table.insert(self.skillTips,self.skillTip1)
  self.skillTip2 = self.this.transform:FindChild("BottomRight/SkillTips/SkillTip2");  table.insert(self.skillTips,self.skillTip2)
  self.skillTip3 = self.this.transform:FindChild("BottomRight/SkillTips/SkillTip3");  table.insert(self.skillTips,self.skillTip3)
     
  table.insert( self.skillList.Name,self.skillTip1:FindChild("NameElement/Text"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.skillList.Name,self.skillTip2:FindChild("NameElement/Text"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.skillList.Name,self.skillTip3:FindChild("NameElement/Text"):GetComponent("UnityEngine.UI.Text"))
  
  table.insert( self.skillList.TipCD,self.skillTip1:FindChild("CDElement/CD"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.skillList.TipCD,self.skillTip2:FindChild("CDElement/CD"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.skillList.TipCD,self.skillTip3:FindChild("CDElement/CD"):GetComponent("UnityEngine.UI.Text"))

  table.insert( self.skillList.TipMP,self.skillTip1:FindChild("CDElement/MP"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.skillList.TipMP,self.skillTip2:FindChild("CDElement/MP"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.skillList.TipMP,self.skillTip3:FindChild("CDElement/MP"):GetComponent("UnityEngine.UI.Text"))

  table.insert( self.skillList.Desc,self.skillTip1:FindChild("Desc"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.skillList.Desc,self.skillTip2:FindChild("Desc"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.skillList.Desc,self.skillTip3:FindChild("Desc"):GetComponent("UnityEngine.UI.Text"))

  table.insert( self.skillList.TagsST[1],self.skillTip1:FindChild("NameElement/Tag1"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.TagsST[1],self.skillTip1:FindChild("NameElement/Tag2"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.TagsST[2],self.skillTip2:FindChild("NameElement/Tag1"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.TagsST[2],self.skillTip2:FindChild("NameElement/Tag2"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.TagsST[3],self.skillTip3:FindChild("NameElement/Tag1"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.skillList.TagsST[3],self.skillTip3:FindChild("NameElement/Tag2"):GetComponent("UnityEngine.UI.Image"))

  self.skillTip4 = self.this.transform:FindChild("BottomRight/SkillTips/SkillTip4");  table.insert(self.skillTips,self.skillTip4) 
  self.skillTip5 = self.this.transform:FindChild("BottomRight/SkillTips/SkillTip5");  table.insert(self.skillTips,self.skillTip5)
  self.skillTip6 = self.this.transform:FindChild("BottomRight/SkillTips/SkillTip6");  table.insert(self.skillTips,self.skillTip6)

  table.insert( self.SummonSkillList.TipName,self.skillTip4:FindChild("NameElement/Text"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.TipName,self.skillTip5:FindChild("NameElement/Text"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.TipName,self.skillTip6:FindChild("NameElement/Text"):GetComponent("UnityEngine.UI.Text"))
  
  table.insert( self.SummonSkillList.TipCD,self.skillTip4:FindChild("CDElement/CD"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.TipCD,self.skillTip5:FindChild("CDElement/CD"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.TipCD,self.skillTip6:FindChild("CDElement/CD"):GetComponent("UnityEngine.UI.Text"))

  table.insert( self.SummonSkillList.TipMP,self.skillTip4:FindChild("CDElement/MP"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.TipMP,self.skillTip5:FindChild("CDElement/MP"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.TipMP,self.skillTip6:FindChild("CDElement/MP"):GetComponent("UnityEngine.UI.Text"))

  table.insert( self.SummonSkillList.Desc,self.skillTip4:FindChild("Desc"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.Desc,self.skillTip5:FindChild("Desc"):GetComponent("UnityEngine.UI.Text"))
  table.insert( self.SummonSkillList.Desc,self.skillTip6:FindChild("Desc"):GetComponent("UnityEngine.UI.Text"))

  table.insert( self.SummonSkillList.TagsST[1],self.skillTip4:FindChild("NameElement/Tag1"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.SummonSkillList.TagsST[1],self.skillTip4:FindChild("NameElement/Tag2"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.SummonSkillList.TagsST[2],self.skillTip5:FindChild("NameElement/Tag1"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.SummonSkillList.TagsST[2],self.skillTip5:FindChild("NameElement/Tag2"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.SummonSkillList.TagsST[3],self.skillTip6:FindChild("NameElement/Tag1"):GetComponent("UnityEngine.UI.Image"))
  table.insert( self.SummonSkillList.TagsST[3],self.skillTip6:FindChild("NameElement/Tag2"):GetComponent("UnityEngine.UI.Image"))

  --[[
  local fxController = self.this.transform:FindChild("BottomRight/Skills/FXs/FXController"); 
  table.insert( self.skillList.fxShadows ,   UITools.GetLuaScript( fxController:FindChild("FXControllerII1"),"Logic.UICommon.UIShadowInNextFrame")   )
  table.insert( self.skillList.fxShadows ,   UITools.GetLuaScript( fxController:FindChild("FXControllerII2"),"Logic.UICommon.UIShadowInNextFrame")   )
  table.insert( self.skillList.fxShadows ,   UITools.GetLuaScript( fxController:FindChild("FXControllerII3"),"Logic.UICommon.UIShadowInNextFrame")   )
 --]]
 
 -------------------------------------------------------------------------------------------------------------
  local UpgradeSkills=self.this.transform:FindChild("BottomRight"); 
  table.insert( self.skillUpgradeList ,UpgradeSkills:FindChild("UpgradeSkill1").gameObject );
  table.insert( self.skillUpgradeList ,UpgradeSkills:FindChild("UpgradeSkill2").gameObject );
  table.insert( self.skillUpgradeList ,UpgradeSkills:FindChild("UpgradeSkill3").gameObject );
  
   ------------------------------------------------>>>技能相关End<<<------------------------------------------------
  -----------------------友军引用-------------------------
  local allyIconP = self.this.transform:FindChild("TopLeft/Friends/IconsMaskAlly");
  for i=1,allyIconP.childCount,1 do
    table.insert(self.allyList.Icon,allyIconP:GetChild(i-1))
    table.insert(self.allyChildList.Icon,allyIconP:GetChild(i-1):GetChild(0):GetComponent("UnityEngine.UI.Image"))
  end
  
 
  
  local allyCellP = self.this.transform:FindChild("TopLeft/Friends/Cells");
  for i=1,allyCellP.childCount,1 do
    table.insert(self.allyList.Cell,allyCellP:GetChild(i-1))
  end
  
  local allyBgP = self.this.transform:FindChild("TopLeft/Friends/Bgs");
  for i=1,allyBgP.childCount,1 do
    table.insert(self.allyList.SkillBg,allyBgP:GetChild(i-1):GetChild(0):GetChild(0))
  end
  for i=1,allyBgP.childCount,1 do
    table.insert(self.allyList.SkillBgHP,allyBgP:GetChild(i-1):GetChild(0):GetChild(1):GetComponent("UnityEngine.UI.Image"))
  end
  
  local allyHpP = self.this.transform:FindChild("TopLeft/Friends/Hps");
  for i=1,allyHpP.childCount,1 do
    table.insert(self.allyList.HP,allyHpP:GetChild(i-1))
    table.insert(self.allyChildList.HP,allyHpP:GetChild(i-1):GetChild(0):GetComponent("UnityEngine.UI.Image"))
  end
  
   local allySkillP = self.this.transform:FindChild("TopLeft/Friends/Skills");
  for i=1,allySkillP.childCount,1 do
    table.insert(self.allyList.Skill,allySkillP:GetChild(i-1))
    table.insert(self.allyChildList.Skill,allySkillP:GetChild(i-1):GetChild(0).gameObject)
  end

  local reviveTimeP=self.this.transform:FindChild("TopLeft/Friends/ReviveTimes"); 
  for i=1,reviveTimeP.childCount,1 do  
    table.insert(self.allyList.reviveTime,reviveTimeP:GetChild(i-1))
    table.insert(self.allyChildList.reviveTime,reviveTimeP:GetChild(i-1):GetChild(0):GetComponent("UnityEngine.UI.Text"))
  end
  
  local deadP = self.this.transform:FindChild("TopLeft/Friends/Deads"); 
  for i=1,deadP.childCount,1 do
    table.insert(self.allyList.Dead,deadP:GetChild(i-1))
    table.insert(self.allyChildList.Dead,deadP:GetChild(i-1):GetChild(0):GetComponent("UnityEngine.UI.Image"))
  end
 
  -----------------------敌人引用-------------------------
  local reviveTimeP=self.this.transform:FindChild("TopLeft/Enemies/ReviveTimes"); 
  for i=1,reviveTimeP.childCount,1 do  
    table.insert(self.enemyList.reviveTime,reviveTimeP:GetChild(i-1))
    table.insert(self.enemyChildList.reviveTime,reviveTimeP:GetChild(i-1):GetChild(0):GetComponent("UnityEngine.UI.Text"))
  end

  local iconP = self.this.transform:FindChild("TopLeft/Enemies/IconsMaskEnemy"); 
  for i=1,iconP.childCount,1 do
    table.insert(self.enemyList.Icon,iconP:GetChild(i-1))
    table.insert(self.enemyChildList.Icon,iconP:GetChild(i-1):GetChild(0):GetComponent("UnityEngine.UI.Image"))
  end
  
  local deadP = self.this.transform:FindChild("TopLeft/Enemies/Deads"); 
  for i=1,deadP.childCount,1 do
    table.insert(self.enemyList.Dead,deadP:GetChild(i-1))
    table.insert(self.enemyChildList.Dead,deadP:GetChild(i-1):GetChild(0):GetComponent("UnityEngine.UI.Image"))
  end
  
  local cellP = self.this.transform:FindChild("TopLeft/Enemies/Cells");
  for i=1,cellP.childCount,1 do
    table.insert(self.enemyList.Cell,cellP:GetChild(i-1))
    
  end
  

 


  --------------------------------------------------------
end
function UIBattleAPI:SetParamStart()
  --sprite存储
  self.Sprites={}
  self.Sprites.BUI_K_A_Normal_Bg=UITools.GetSpriteBattle("uibattle","BUI-K-A-Normal-Bg");
  self.Sprites.BUI_K_A_First_Bg=UITools.GetSpriteBattle("uibattle","BUI-K-A-First-Bg");
  self.Sprites.BUI_K_E_First_Bg=UITools.GetSpriteBattle("uibattle","BUI-K-E-First-Bg");
  self.Sprites.BUI_K_E_Normal_Bg=UITools.GetSpriteBattle("uibattle","BUI-K-E-Normal-Bg");
  self.Sprites.BUI_K_A_II_Bg=UITools.GetSpriteBattle("uibattle","BUI-K-A-II-Bg");
  self.Sprites.BUI_K_E_II_Bg=UITools.GetSpriteBattle("uibattle","BUI-K-E-II-Bg");
  self.Sprites.BUI_K_A_IV_Bg=UITools.GetSpriteBattle("uibattle","BUI-K-A-IV-Bg");
  self.Sprites.BUI_K_E_IV_Bg=UITools.GetSpriteBattle("uibattle","BUI-K-E-IV-Bg");
  self.Sprites.SkillIcon={}
  self.Sprites.PlayerSkillIcon={}
  self.Sprites.EquipIcon={}
  -------------------------按住或拖拽移动相机------------------------------->>>
  self.y=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.y
  self.x=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.x
  self.camera=GameObject.Find("GameLogic"):GetComponent("Camera");

  self.MapColliderSmall=self.this.transform:FindChild("TopLeft/MiniMap/I/Map/MapColliderSmall").gameObject
  self.MapColliderBig=self.this.transform:FindChild("TopLeft/MiniMap/I/Map/MapColliderBig").gameObject
  self.MapSmall=self.this.transform:FindChild("TopLeft/MiniMap/I/Map/MapSmall").gameObject
  self.MapBig=self.this.transform:FindChild("TopLeft/MiniMap/I/Map/MapBig").gameObject
  self.MapSign=self.this.transform:FindChild("TopLeft/MiniMap/I/Map/Sign")

  local listener = NTGEventTriggerProxy.Get(  self.MapColliderSmall);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
      local viewPos = self.camera:ScreenToViewportPoint(Input.mousePosition);
      --以左下角为中心的坐标0~1
      local t=Vector2.New( (viewPos.x*self.x)/self.miniMapRT.sizeDelta.x , (self.miniMapRT.sizeDelta.y-(1-viewPos.y)*self.y)/self.miniMapRT.sizeDelta.y )
      --移动摄像机=======================================================================================================================================
    end,self
  )
  listener.onDrag = listener.onDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
      local viewPos = self.camera:ScreenToViewportPoint(Input.mousePosition);
      --以左下角为中心的坐标0~1
      local t=Vector2.New( (viewPos.x*self.x)/self.miniMapRT.sizeDelta.x , (self.miniMapRT.sizeDelta.y-(1-viewPos.y)*self.y)/self.miniMapRT.sizeDelta.y )
      --移动摄像机=======================================================================================================================================
    end,self
  )
  -------------------------每个客户端显示标记-------------------------------->>>
  listener = NTGEventTriggerProxy.Get(  self.MapColliderBig);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
      local viewPos = self.camera:ScreenToViewportPoint(Input.mousePosition);
      --以左下角为中心的坐标0~1
      local v=Vector2.New( (viewPos.x*self.x)/(self.miniMapRT.sizeDelta.x*2.43) , (self.miniMapRT.sizeDelta.y*2.43-(1-viewPos.y)*self.y)/(self.miniMapRT.sizeDelta.y*2.43) )
      --每个客户端显示标记===============================================================================================================================
      --self.this:InvokeDelegate(self.delegateSyncMapFxSign,self.heroSelfId,v)  --Send
      self:SyncMapFxSign(v);    self:SyncMapTipSign(self.heroSelfId)
      --更改大小及碰撞
      self.miniMapRT.localScale=Vector3.one
      self.MapColliderSmall:SetActive(true)
      self.MapColliderBig:SetActive(false)
      self.MapSmall:SetActive(true)
      self.MapBig:SetActive(false)
    end,self
  )
  ----------------------------放大镜按钮事件-------------------------------->>>
  self.buttonMagnify=self.this.transform:FindChild("TopLeft/Buttons/ButtonMagnify").gameObject
  listener = NTGEventTriggerProxy.Get(  self.buttonMagnify);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
      --更改大小及碰撞
      self.miniMapRT.localScale=Vector3.New(2.43,2.43,2.43)
      self.MapColliderSmall:SetActive(false)
      self.MapColliderBig:SetActive(true)
      self.MapSmall:SetActive(false)
      self.MapBig:SetActive(true)
    end,self
  )
  ------------------------------装备所需数据-------------------------------->>>
  
  --------------------------商店商品排序-------------------------                                 
  local sortTable={}
  for k,v in pairs(UTGData.Instance().PVPMallsData) do
    table.insert(sortTable,v)
  end
    
  table.sort(sortTable,function(a,b) return tonumber(a.Id)<tonumber(b.Id) end )--按Id排序        
  ----------------------------对表进行深拷贝----------------------------
  self.tableCopyMall=UITools.CopyTab(sortTable);
  
  -----------------------------插入右节点----------------------------
  for k,v in pairs(self.tableCopyMall) do
    for k1,v1 in pairs(v.PreEquips) do--对装备的左节点集合中的元素，直接将其当前对应的装备ID，插入到原表中对应自己装备Id的右节点中
      for k2,v2 in pairs(self.tableCopyMall) do
        if(v2.EquipId==v1)then
          if(v2.NextEquips==nil)then
            v2.NextEquips={}
            v2.NextEquips[#v2.NextEquips+1]=v.EquipId;
          else
            v2.NextEquips[#v2.NextEquips+1]=v.EquipId;
          end
        end
      end
    end
  end
  --------------------从Equip表取所需值添加进来,清晰结构，减少界面操作时的复杂度-----------------------
  for k,v in pairs(self.tableCopyMall) do
    for  i1,v1 in pairs(UTGData.Instance().EquipsData) do
      if(v.EquipId==v1.Id)then
        v.Name=v1.Name
        v.Icon=v1.Icon
        v.AttrDesc={}
        if(v1.HP~=0)then  table.insert(v.AttrDesc, "+" .. v1.HP .. "生命")  end             -- float64 //生命值
        if(v1.MP~=0)then  table.insert(v.AttrDesc, "+" .. v1.MP .. "法力")  end             -- float64 //法力值
        if(v1.PAtk~=0)then  table.insert(v.AttrDesc, "+" .. v1.PAtk .. "攻击")  end     
        if(v1.MAtk~=0)then  table.insert(v.AttrDesc, "+" .. v1.MAtk .. "法强")  end  
        if(v1.PDef~=0)then  table.insert(v.AttrDesc, "+" .. v1.PDef .. "护甲")  end  
        if(v1.MDef~=0)then  table.insert(v.AttrDesc, "+" .. v1.MDef .. "法抗")  end  
        if(v1.MoveSpeed~=0)then  table.insert(v.AttrDesc, "+" .. v1.MoveSpeed*100 .. "%移速")  end  
        if(v1.PpenetrateValue~=0)then  table.insert(v.AttrDesc, "+" .. v1.PpenetrateValue .. "物理护甲穿透值")  end  
        if(v1.PpenetrateRate~=0)then  table.insert(v.AttrDesc, "+" .. v1.PpenetrateRate*100 .. "%物理护甲穿透率")  end  
        if(v1.MpenetrateValue~=0)then  table.insert(v.AttrDesc, "+" .. v1.MpenetrateValue .. "法术护甲穿透值")  end  
        if(v1.MpenetrateRate~=0)then  table.insert(v.AttrDesc, "+" .. v1.MpenetrateRate*100 .. "%法术护甲穿透率")  end  
        if(v1.AtkSpeed~=0)then  table.insert(v.AttrDesc, "+" .. v1.AtkSpeed*100 .. "%攻速")  end 
        if(v1.CritRate~=0)then  table.insert(v.AttrDesc, "+" .. v1.CritRate*100 .. "%暴击")  end
        if(v1.CritEffect~=0)then  table.insert(v.AttrDesc, "+" .. v1.CritEffect*100 .. "%暴击效果")  end
        if(v1.PHpSteal~=0)then  table.insert(v.AttrDesc, "+" .. v1.PHpSteal*100 .. "%物理吸血")  end
        if(v1.MHpSteal~=0)then  table.insert(v.AttrDesc, "+" .. v1.MHpSteal*100 .. "%法术吸血")  end
        if(v1.CdReduce~=0)then  table.insert(v.AttrDesc, "+" .. v1.CdReduce*100 .. "%减CD")  end
        if(v1.Tough~=0)then  table.insert(v.AttrDesc, "+" .. v1.Tough*100 .. "%韧性")  end
        if(v1.HpRecover5s~=0)then  table.insert(v.AttrDesc, "+" .. v1.HpRecover5s .. "回血")  end
        if(v1.MpRecover5s~=0)then  table.insert(v.AttrDesc, "+" .. v1.MpRecover5s .. "回蓝")  end
        
        if(v1.PassiveSkills~=nil)then
          for k2,v2 in pairs(v1.PassiveSkills) do
            for k3,v3 in pairs(UTGData.Instance().SkillsData)  do   
              if(v2==v3.Id)then
                if(v.SkillDescs==nil)then
                  v.SkillDescs={}
                  table.insert(v.SkillDescs,v3.Desc)
                else
                  table.insert(v.SkillDescs,v3.Desc)
                end
                if(v.SkillDescsName==nil)then 
                  v.SkillDescsName={}
                  table.insert(v.SkillDescsName,v3.Name)
                else
                  table.insert(v.SkillDescsName,v3.Name)
                end
                break;
              end
            end
          end
        end
        break;
      end
    end
  end
  
  ---------------------------------------------------------------
  self.tableCopyMallDictionary={}
  for k,v in pairs(self.tableCopyMall) do
    self.tableCopyMallDictionary[tostring(v.EquipId)]=v
  end
  ---------------------------------------------------------------

end
----------------------------注册人物技能事件3个及召唤师技能-------------------------->>>
function UIBattleAPI:RegisterDelegateSkill(delegate)
  self.skillClickScripts[1]:RegisterClickDelegate(self,function() self.this:InvokeDelegate(delegate, "1") self:ShowInNextFrame(self.FX_Click1) end)
  self.skillClickScripts[2]:RegisterClickDelegate(self,function () self.this:InvokeDelegate(delegate, "2") self:ShowInNextFrame(self.FX_Click2)  end)
  self.skillClickScripts[3]:RegisterClickDelegate(self,function () self.this:InvokeDelegate(delegate, "3") self:ShowInNextFrame(self.FX_Click3)  end)
   
  local listener = NTGEventTriggerProxy.Get(self.skillClickScripts[1].this.gameObject);
  listener.onEndDrag = listener.onEndDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          self.this:InvokeDelegate(delegate, "1") 
          self:ShowInNextFrame(self.FX_Click1)  
        end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[2].this.gameObject);
  listener.onEndDrag = listener.onEndDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          self.this:InvokeDelegate(delegate, "2")  
          self:ShowInNextFrame(self.FX_Click2)  
        end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[3].this.gameObject);
  listener.onEndDrag = listener.onEndDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          self.this:InvokeDelegate(delegate, "3")  
          self:ShowInNextFrame(self.FX_Click3)  
        end
      end,self
      );

  self.skillClickScripts[4]:RegisterClickDelegate(self,function () self.this:InvokeDelegate(delegate, "4") end) --多跟了参数应该不影响，不会被赋值而已
  self.skillClickScripts[5]:RegisterClickDelegate(self,function () self.this:InvokeDelegate(delegate, "5") end) 
  self.skillClickScripts[6]:RegisterClickDelegate(self,function () self.this:InvokeDelegate(delegate, "6") end) 
  
  local listener = NTGEventTriggerProxy.Get(self.skillClickScripts[4].this.gameObject);
  listener.onEndDrag = listener.onEndDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function () 
        if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
           self.this:InvokeDelegate(delegate, "4")
           
        end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[5].this.gameObject);
  listener.onEndDrag = listener.onEndDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function () 
        if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
           self.this:InvokeDelegate(delegate, "5")
       
        end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[6].this.gameObject);
  listener.onEndDrag = listener.onEndDrag + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function () 
        if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          --func(obj,3);
          self.this:InvokeDelegate(delegate, "6")
        
        end
      end,self
      );
end
function UIBattleAPI:RegisterDelegateSkillDown(delegate)
  --self.skillClickScripts[1]:RegisterClickDelegate(self,function() self.this:InvokeDelegate(delegate, "1") end) 
  --self.skillClickScripts[2]:RegisterClickDelegate(self,function () self.this:InvokeDelegate(delegate, "2") end)
  --self.skillClickScripts[3]:RegisterClickDelegate(self,function () self.this:InvokeDelegate(delegate, "3") end)
  self.delegateSkillDown=delegate
  local listener = NTGEventTriggerProxy.Get(self.skillClickScripts[1].this.gameObject);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          self.this:InvokeDelegate(delegate, "1") 
          self.skillList.CanCloseCollider[1]=false; 
        --end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[2].this.gameObject);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          self.this:InvokeDelegate(delegate, "2")
          self.skillList.CanCloseCollider[2]=false; 
        --end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[3].this.gameObject);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          self.this:InvokeDelegate(delegate, "3")
          self.skillList.CanCloseCollider[3]=false; 
        --end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[4].this.gameObject);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          self.this:InvokeDelegate(delegate, "4")
          self.SummonSkillList.CanCloseCollider[1]=false; 
        --end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[5].this.gameObject);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          self.this:InvokeDelegate(delegate, "5")
          self.SummonSkillList.CanCloseCollider[2]=false; 
        --end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[6].this.gameObject);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          self.this:InvokeDelegate(delegate, "6")
          self.SummonSkillList.CanCloseCollider[3]=false; 
        --end
      end,self
      );
end
function UIBattleAPI:RegisterDelegateSkillUp(delegate)
  --self.skillClickScripts[1]:RegisterClickDelegate(self,function() self.this:InvokeDelegate(delegate, "1") end) 
  --self.skillClickScripts[2]:RegisterClickDelegate(self,function () self.this:InvokeDelegate(delegate, "2") end)
  --self.skillClickScripts[3]:RegisterClickDelegate(self,function () self.this:InvokeDelegate(delegate, "3") end)
  
  self.delegateSkillUp=delegate

  local listener = NTGEventTriggerProxy.Get(self.skillClickScripts[1].this.gameObject);
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          --self.idSkillUp="1"
          self.this:InvokeDelegate(delegate, "1") 
          self.skillList.CanCloseCollider[1]=true;
        --end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[2].this.gameObject);
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          --self.idSkillUp="2"
          self.this:InvokeDelegate(delegate, "2") 
          self.skillList.CanCloseCollider[2]=true;
        --end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[3].this.gameObject);
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          --self.idSkillUp="3"
          self.this:InvokeDelegate(delegate, "3")
          self.skillList.CanCloseCollider[3]=true; 
        --end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[4].this.gameObject);
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          --self.idSkillUp="3"
          self.this:InvokeDelegate(delegate, "4")
          self.SummonSkillList.CanCloseCollider[1]=true; 
        --end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[5].this.gameObject);
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          --self.idSkillUp="3"
          self.this:InvokeDelegate(delegate, "5")
          self.SummonSkillList.CanCloseCollider[2]=true; 
        --end
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillClickScripts[6].this.gameObject);
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
        --if(self.cancelSkill==false)then --如果技能未关闭，通过移进移出关闭按钮改变此Bool
          --self.idSkillUp="3"
          self.this:InvokeDelegate(delegate, "6")
          self.SummonSkillList.CanCloseCollider[3]=true; 
        --end
      end,self
      );
end
function UIBattleAPI:RegisterDelegateChangeRangeColor(delegate)
  
  self.delegateChangeColor=delegate;  
end
----------------------------技能升级事件--------------------------------->>>
function UIBattleAPI:RegisterDelegateUpgradeSkill(delegate)
  local listener = NTGEventTriggerProxy.Get(self.skillUpgradeList[1]);  
  listener.onPointerClick  = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
           self.this:InvokeDelegate(delegate, "1")
           self:ShowInNextFrame (self.FX_UpLevelMove1)  
           self:ShowAfterTime (self.FX_LevelUp1,0.5)--这个需要隔的时间长点
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillUpgradeList[2]);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
           self.this:InvokeDelegate(delegate, "2")
           self:ShowInNextFrame (self.FX_UpLevelMove2)
           self:ShowAfterTime (self.FX_LevelUp2,0.5)
      end,self
      );
  listener = NTGEventTriggerProxy.Get(self.skillUpgradeList[3]); 
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
           self.this:InvokeDelegate(delegate, "3")
           self:ShowInNextFrame (self.FX_UpLevelMove3)
           self:ShowAfterTime (self.FX_LevelUp3,0.5)
      end,self
      );
end
---------------------------注册指令按键事件4个------------------------------->>>
function UIBattleAPI:RegisterDelegateDirective(delegate)
  for k,v in pairs(self.directiveButtons) do
    UITools.GetLuaScript(v,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,
      function ()
        self.this:InvokeDelegate(delegate,self.heroSelfId, tostring(k) )
        self:SyncMapFxDictate(self.heroSelfId,tostring(k))   self:SyncMapTipDictate(self.heroSelfId,tostring(k))  
      end
      )
  end
end
----------------------------暂停按钮事件1个---------------------------------->>>
function UIBattleAPI:RegisterDelegatePause(delegate)
  UITools.GetLuaScript(self.PauseButton,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,
    function ()
        self.this:InvokeDelegate(delegate)
      end
      )--有待商榷最后的Bool谁传
  UITools.GetLuaScript(self.PauseButton,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,
    function ()
      if(self.boolPause)then
        self.PauseButton.transform:GetChild(0):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-RBStop"); 
        self.boolPause=not self.boolPause
      else
        self.PauseButton.transform:GetChild(0):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("uibattle","BUI-RBPlay"); 
        self.boolPause=not self.boolPause
      end
    end
    )
end
-------------------------------攻击按下-------------------------------------->>>
function UIBattleAPI:RegisterDelegateATKDown(delegate)
  
  local listener = NTGEventTriggerProxy.Get(self.ATKCollider.gameObject);
  listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
          self.selectedAxis=Vector2.zero;

          self.this:InvokeDelegate(delegate)
          self.this:InvokeDelegate(self.delegateSkillDown, "0")
          
          self:ShowInNextFrame (self.FX_ATK)
      end ,self 
    );
end
-------------------------------攻击抬起-------------------------------------->>>
function UIBattleAPI:RegisterDelegateATKUp(delegate)
  local listener = NTGEventTriggerProxy.Get(self.ATKCollider.gameObject);
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf( 
      function ()
          self.this:InvokeDelegate(delegate)
          self.this:InvokeDelegate(self.delegateSkillUp, "0")
      end ,self 
    );
end
-------------------------------目标选择-------------------------------------->>>
function UIBattleAPI:RegisterDelegateChooseTarget(delegate) 
  local listener = NTGEventTriggerProxy.Get(self.ChoseHeroCollider.gameObject);
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf(
    function ()
      self.this:InvokeDelegate(delegate, "1")
      self:ShowInNextFrame (self.FX_SelectHero)
    end,self
    );
  listener = NTGEventTriggerProxy.Get(self.ChoseSoldierCollider.gameObject);
  listener.onPointerUp = listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf(
    function ()
      self.this:InvokeDelegate(delegate, "2")
      self:ShowInNextFrame (self.FX_SelectSoldier)
    end,self
    );
end
-------------------------------角色数据更新---------------------------------->>>
function UIBattleAPI:RegisterDelegateUpdateHeroDetailData(delegate) 
  local listener = NTGEventTriggerProxy.Get(  self.buttonPopRight);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function ()
      self.this:InvokeDelegate(delegate)
      BattleHeroDetailAPI.Instance:ShowUI()
    end,self
  )
end
--------------------------友方客户端显示按下特效----------------------------->>>
function UIBattleAPI:RegisterDelegateSyncMapFx(delegate) 
  self.delegateSyncMapFxSign=delegate; 
end
function UIBattleAPI:RegisterDelegateSyncMapFxSign(delegate) 
  self.delegateSyncMapFxSign=delegate; 
end
function UIBattleAPI:RegisterDelegateSendQuickMessage(delegate) 
  --Add聊天界面
  self.chatDelegate=delegate
  self:GoToPanel("ChatInBattle")
end
function UIBattleAPI:OnChatCreated() 
  ChatInBattleAPI.Instance:SetMainPos(self.this.transform:FindChild("TopRight/AnchorChatMain"))
  ChatInBattleAPI.Instance:SetInfoPos(self.this.transform:FindChild("BottomLeft/AnchorChatInfo"))
  ChatInBattleAPI.Instance:RegisterDelegateSendQuickMessage(self.chatDelegate)
end
--------------------------------API------------------------------
function UIBattleAPI:RefreshRecoEquip(equipTable)--刷新推荐武器
  --将子物体放入UIPool
  while(self.RecoEquipParent.childCount>0)do
    local damage=self.RecoEquipParent:GetChild(0)   
    UIPool.Instance:Return(damage.gameObject) 
  end
  local a=0;
  for kI,vI in pairs(equipTable) do
    --从UIPool取值
    local go =UIPool.Instance:Get("RecoEquip"); 
    go.transform:SetParent(self.RecoEquipParent);
    go.transform.localScale = Vector3.one; 
    go.transform.localPosition = Vector3.New(0, 0, 0);
    --赋值
   
    go.transform:FindChild("Coin"):GetComponent("UnityEngine.UI.Text").text=vI[2] --价格
    go:GetComponent("Animator"):Play("M022-RecoEquip",0,0) ;
    
    
  --for k,v in pairs(self.tableCopyMall) do
    
    --if(v.EquipId==vI[1])then 
        --名字
        --[[
        for k,v in pairs(self.tableCopyMallDictionary) do
          Debugger.LogError(">>>>>>>>>")
          Debugger.LogError(k)  Debugger.LogError(v)
          if()
        end
        Debugger.LogError("TTTTTTTTTTTTTTTTTTTTTTTTTT")
        Debugger.LogError( tostring(vI[1]) )
        
        for k2,v2 in pairs(v) do
          print(k2,v2)
        end
        --]]
        local v=self.tableCopyMallDictionary[tostring(vI[1])]
        go.transform:FindChild("Texts/Name"):GetComponent("UnityEngine.UI.Text").text=v.Name
        --go.transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSpriteBattle("equipicon",v.Icon)

        if(self.Sprites.EquipIcon[v.Icon]~=nil)then
          go.transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite=self.Sprites.EquipIcon[v.Icon]
        else
          self.Sprites.EquipIcon[v.Icon]=UITools.GetSpriteBattle("equipicon",v.Icon)
          go.transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite=self.Sprites.EquipIcon[v.Icon]
        end

        a=a+1;    
        local listener = NTGEventTriggerProxy.Get(go.transform:FindChild("Icon").gameObject); 
        listener.onPointerClick =NTGEventTriggerProxy.PointerEventDelegateSelf( 
            function ()
           
                PVPMallAPI.Instance:BuyEquipOutside(vI[1],vI[3],vI[2])
                if(kI==1)then
                  self:ShowInNextFrame (self.FX_EquipClick1)
                else
                  self:ShowInNextFrame (self.FX_EquipClick2)
                end
            end,self
            );
        
        local tl=go.transform:FindChild("Texts/LayoutElement").gameObject 

        local totalAttrDesc=""
        if(#v.AttrDesc~=0)then
          for i,vII in pairs(v.AttrDesc) do
            totalAttrDesc=totalAttrDesc .. " " .. vII;
          end
          if(tl.activeSelf==false)then
            tl:SetActive(true) 
          end
        else 
          if(tl.activeSelf==true)then
            tl:SetActive(false) 
          end 
        end

        local a1=go.transform:FindChild("Texts/LayoutElement/Attr1")
        local a2=go.transform:FindChild("Texts/LayoutElement/Attr2")
        local a3=go.transform:FindChild("Texts/LayoutElement/Nothing")
        a1:GetComponent("UnityEngine.UI.Text").text=tostring(totalAttrDesc)
        a2:GetComponent("UnityEngine.UI.Text").text=tostring(totalAttrDesc)
        a3:GetComponent("UnityEngine.UI.Text").text=tostring(totalAttrDesc)

        if(UITools.WidthOfString(totalAttrDesc,0)<=30)then

          if(a1.gameObject.activeSelf==false)then
            a1.gameObject:SetActive(true)
          end
          if(a2.gameObject.activeSelf==true)then
            a2.gameObject:SetActive(false)
          end 
          if(a3.gameObject.activeSelf==true)then
            a3.gameObject:SetActive(false)
          end
          
        else 

          if(a1.gameObject.activeSelf==true)then
            a1.gameObject:SetActive(false)
          end
          if(a2.gameObject.activeSelf==false)then
            a2.gameObject:SetActive(true)
          end 
          if(a3.gameObject.activeSelf==false)then
            a3.gameObject:SetActive(true)
          end

        end


        local totalSkillDescName=""
        if(v.SkillDescsName~=nil)then  
          for i,vIII in pairs(v.SkillDescsName) do 
             totalSkillDescName=totalSkillDescName .. "【" .. vIII .. "】";
          end
          go.transform:FindChild("Texts/Desc").gameObject:SetActive(true)
        else 
          go.transform:FindChild("Texts/Desc").gameObject:SetActive(false)
        end 
        go.transform:FindChild("Texts/Desc"):GetComponent("UnityEngine.UI.Text").text=tostring("唯一被动:" .. totalSkillDescName)

    --end
  --end

  end
end
----------------------------------------------------------------------
function UIBattleAPI:GoToPanel(stringPanel)  --panel名称，是否销毁当前界面
 
  coroutine.start( UIBattleAPI.GoToPanelCo,self,stringPanel)
end

function UIBattleAPI:GoToPanelCo(stringPanel)
  
  local async = GameManager.CreatePanelAsync(stringPanel)
  while async.Done == false do
    coroutine.step()
  end
  self:OnChatCreated() 

end