--Maintenance By WYL

class("SelectBattleModeAPI")
----------------------------------------------------
function SelectBattleModeAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  SelectBattleModeAPI.Instance=self;
  -----------------------引用--------------------
  self.top=self.this.transform:FindChild("Top");
  self.buttonReturn=self.this.transform:FindChild("Top/Left/ButtonReturn").gameObject;
  self.buttonReturnToMode=self.this.transform:FindChild("Top/Left/ButtonReturnToMode").gameObject;
  --self.textBattleMode=self.this.transform:FindChild("Top/Left/Bg/TextBattleMode"):GetComponent("UnityEngine.UI.Text");
  self.buttonRule=self.this.transform:FindChild("Top/Right/ButtonRule").gameObject;
  
  self.buttonParent=self.this.transform:FindChild("Center").gameObject;
  self.CenterCanvasGroup=self.this.transform:FindChild("Center"):GetComponent("CanvasGroup");
  self.button1Versus=self.this.transform:FindChild("Center/ButtonVersus").gameObject;
  self.button2Entertain=self.this.transform:FindChild("Center/ButtonEntertain").gameObject;
  self.button3ManMachine=self.this.transform:FindChild("Center/ButtonMan-Machine").gameObject;
  self.button4CreatGame=self.this.transform:FindChild("Center/ButtonCreatGame").gameObject;
  
  self.buttonPractice=self.this.transform:FindChild("Bottom/Center/ButtonPractice").gameObject;
  self.buttonVideo=self.this.transform:FindChild("Bottom/Center/ButtonVideo").gameObject;
  -----------------------------------------------
  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end

function SelectBattleModeAPI:ResetPanel()
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("SelectBattleModePanel")
  topAPI:ShowControl(1)
  topAPI:InitTop(self,self.OnReturnButtonDown,nil,nil,"对战模式")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  self.NormalResourceAPI = topAPI
  
  self.top:SetAsLastSibling()
end

----------------------------------------------------
function SelectBattleModeAPI:Start()
  --UnityEngine.Resources.UnloadUnusedAssets();

  self:ResetPanel()  

  -----------------------------按钮添加事件---------------------------------
  local listener = NTGEventTriggerProxy.Get(self.buttonPractice);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( 
    function()
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    end
    ,self
    );
  listener = NTGEventTriggerProxy.Get(self.buttonVideo);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(
    function()
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    end
    ,self 
    );
  --
  listener = NTGEventTriggerProxy.Get(self.buttonRule);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( SelectBattleModeAPI.OnRuleButtonDown,self);
  listener = NTGEventTriggerProxy.Get( self.buttonReturn);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( SelectBattleModeAPI.OnReturnButtonDown,self);
  listener = NTGEventTriggerProxy.Get( self.buttonReturnToMode);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( SelectBattleModeAPI.OnReturnToModeButtonDown,self);
  --战斗模式选择
  listener = NTGEventTriggerProxy.Get( self.button1Versus);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( SelectBattleModeAPI.OnButton1VersusDown,self);
  listener = NTGEventTriggerProxy.Get( self.button2Entertain);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( SelectBattleModeAPI.OnButton2EntertainDown,self);
  listener = NTGEventTriggerProxy.Get( self.button3ManMachine);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( SelectBattleModeAPI.OnButton3ManMachineDown,self);
  listener = NTGEventTriggerProxy.Get( self.button4CreatGame);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( SelectBattleModeAPI.OnButton4CreatGameDown,self);
  -------------------------------------------------------------------------
end
----------------------------------------------------
function SelectBattleModeAPI:OnDestroy() 
  
  ------------------------------------
  SelectBattleModeAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end

function SelectBattleModeAPI:DestroySelf() 
  Object.Destroy(self.this.gameObject)
end

-------------------------按钮事件方法------------------------------
function SelectBattleModeAPI:OnRuleButtonDown() 
  self:GoToPanel("PageTextBattleRule",false,0)
end
function SelectBattleModeAPI:OnReturnButtonDown()
  UTGDataOperator.Instance:SetPreUIRight(self.this.transform)
  self:DestroySelf() 
end
function SelectBattleModeAPI:OnReturnToModeButtonDown() 
  NewBattle14API.Instance:DestroySelf()
    self:ShowModeButtons(true) 
    self.buttonReturnToMode:SetActive(false);
    self.NormalResourceAPI:InitTop(self,self.OnReturnButtonDown,nil,nil,"对战模式")
end
function SelectBattleModeAPI:OnButton1VersusDown() 
  if(NewBattle14API == nil or NewBattle14API.instance == nil)then
    self:GoToPanel("NewBattle14",false,1)
  else
    --NewBattle14API.instance.this.gameObject:SetActive(true); --必要的时候让脚本提供者提供方法关掉，要么还是让他自己Destroy掉方便些
  end
  self.NormalResourceAPI:InitTop(self,self.OnReturnButtonDown,nil,nil,"实时对战")
  --self.textBattleMode.text="实时对战"
  self:ShowModeButtons(false) 
  self.buttonReturnToMode:SetActive(true);
end
function SelectBattleModeAPI:OnButton2EntertainDown() 
if(NewBattle14API == nil or NewBattle14API.instance == nil)then
    self:GoToPanel("NewBattle14",false,2)
  else
    --NewBattle14API.instance.this.gameObject:SetActive(true); --必要的时候让脚本提供者提供方法关掉，要么还是让他自己Destroy掉方便些
  end
  self.NormalResourceAPI:InitTop(self,self.OnReturnButtonDown,nil,nil,"娱乐模式")
  --self.textBattleMode.text="实时对战"
  self:ShowModeButtons(false) 
  self.buttonReturnToMode:SetActive(true);
end
function SelectBattleModeAPI:OnButton3ManMachineDown() 
  self:GoToPanel("NewBattle14",false,3)
  self.NormalResourceAPI:InitTop(self,self.OnReturnButtonDown,nil,nil,"人机练习")
  --self.textBattleMode.text="人机练习";
  
end
function SelectBattleModeAPI:OnButton4CreatGameDown() 
  self:GoToPanel("NewBattle14",false,4)
  self.NormalResourceAPI:InitTop(self,self.OnReturnButtonDown,nil,nil,"开房间")
  --self.textBattleMode.text="开房间";
  
end
---------------------------------------------------------
function SelectBattleModeAPI:ShowModeButtons(bool) 

  --self.buttonParent:SetActive(bool);
  if(bool==true)then
    self.CenterCanvasGroup.alpha=1;
    self.CenterCanvasGroup.blocksRaycasts = true;     
  else
    self.CenterCanvasGroup.alpha=0;
    self.CenterCanvasGroup.blocksRaycasts = false;     
  end
 
end
----------------------------------------------------------------------
function SelectBattleModeAPI:GoToPanel(stringPanel,boolDestoySelf,enum)  --panel名称，是否销毁当前界面
  coroutine.start( SelectBattleModeAPI.WaitForCreatePanel,self,stringPanel,boolDestoySelf,enum)
end

function SelectBattleModeAPI:WaitForCreatePanel(stringPanel,boolDestoySelf,enum)
  
  local async = GameManager.CreatePanelAsync (stringPanel)
  while async.Done == false do
    coroutine.wait(0.05)
  end
  if(boolDestoySelf)then
    self:DestroySelf() 
  end
  
  
  
  if(enum==1)then
    NewBattle14API.Instance:ShowPVPPanel()
    self:ShowModeButtons(false) 
    self.buttonReturnToMode:SetActive(true);
  elseif(enum==2)then
    NewBattle14API.Instance:ShowEntPanel()
    self:ShowModeButtons(false) 
    self.buttonReturnToMode:SetActive(true);
  elseif(enum==3)then
    NewBattle14API.Instance:ShowComputerPanel()
    self:ShowModeButtons(false) 
    self.buttonReturnToMode:SetActive(true);
  elseif(enum==4)then
    NewBattle14API.Instance:ShowRoomPanel()
    self:ShowModeButtons(false) 
    self.buttonReturnToMode:SetActive(true);
  end
 
 
end
-----------------------------------------------------------------------
