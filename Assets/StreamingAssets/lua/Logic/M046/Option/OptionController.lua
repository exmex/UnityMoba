require "System.Global"
require "Logic.UTGData.UTGData"

class("OptionController")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"



function OptionController:Awake(this)
  self.this = this
  self.leftPanel = self.this.transforms[0]
  self.baseOption = self.leftPanel:Find("Panel/BaseOption")
  self.controlOption = self.leftPanel:Find("Panel/ControlOption")
  self.audioOption = self.leftPanel:Find("Panel/AudioOption")
  self.controlOptionPanel = self.this.transforms[2]
  self.audioOptionPanel = self.this.transforms[3]
  self.noticeMoveCamera = self.this.transforms[4]
  self.noticeUseSkill = self.this.transforms[5]
  self.baseOptionOutSidePanel = self.this.transforms[6]
  
  
  --外部角色描边开关
  self.roleOutLineOutSideBar = self.baseOptionOutSidePanel:Find("RoleOutLine/Base/Bar")
  self.roleOutLineOutSideBase = self.baseOptionOutSidePanel:Find("RoleOutLine/Base")

  
  --高清显示
  self.highQBar = self.baseOptionOutSidePanel:Find("HQ/Base/Bar")
  self.highQBase = self.baseOptionOutSidePanel:Find("HQ/Base")
  
  --外部局内打字开关
  self.gameInputOutSideBase = self.baseOptionOutSidePanel:Find("GameInput/Base")
  self.gameInputOutSideBar = self.gameInputOutSideBase:Find("Bar")
  
  --外部摄像机高度
  self.cameraHeightOutSideBase = self.baseOptionOutSidePanel:Find("CameraHeight/Base")
  self.cameraHeightOutSideBar = self.cameraHeightOutSideBase:Find("Bar")
  
  --画面质量
  self.gQBase = self.baseOptionOutSidePanel:Find("GraphicsQ/Base")
  self.gQBar = self.gQBase:Find("Bar")
  self.gQll = self.gQBase:Find("ll")
  self.gQmm = self.gQBase:Find("mm")
  self.gQrr = self.gQBase:Find("rr")
  
  --粒子质量
  self.pQBase = self.baseOptionOutSidePanel:Find("ParticleQ/Base")
  self.pQBar = self.pQBase:Find("Bar")
  self.pQll = self.pQBase:Find("ll")
  self.pQmm = self.pQBase:Find("mm")
  self.pQrr = self.pQBase:Find("rr")
  
  --目标锁定方式
  self.targetLock1 = self.controlOptionPanel:Find("Panel/Grid/TargetLock/Selected")
  self.targetLock2 = self.controlOptionPanel:Find("Panel/Grid/TargetLock/Selected2")
  
  --技能释放方式
  self.useSkill1 = self.controlOptionPanel:Find("Panel/Grid/UseSkill/Selected")
  self.useSkill2 = self.controlOptionPanel:Find("Panel/Grid/UseSkill/Selected2")
  
  --目标筛选方式
  self.targetSelect1 = self.controlOptionPanel:Find("Panel/Grid/TargetSelect/Selected")
  self.targetSelect2 = self.controlOptionPanel:Find("Panel/Grid/TargetSelect/Selected2")

  --小兵攻击模式
  self.mobAttack1 = self.controlOptionPanel:Find("Panel/Grid/MobAttack/Selected")
  self.mobAttack2 = self.controlOptionPanel:Find("Panel/Grid/MobAttack/Selected2")

  --显示目标头像
  self.showTargetIcon1 = self.controlOptionPanel:Find("Panel/Grid/ShowTargetIcon/Selected")
  self.showTargetIcon2 = self.controlOptionPanel:Find("Panel/Grid/ShowTargetIcon/Selected2")

  --轮盘锁定方式
  self.diskLockTarget1 = self.controlOptionPanel:Find("DiskUseSkill/DiskLockTarget/Selected")
  self.diskLockTarget2 = self.controlOptionPanel:Find("DiskUseSkill/DiskLockTarget/Selected2")
  
  --轮盘呼出位置
  self.showDiskPosition1 = self.controlOptionPanel:Find("DiskUseSkill/ShowDiskPosition/Selected")
  self.showDiskPosition2 = self.controlOptionPanel:Find("DiskUseSkill/ShowDiskPosition/Selected2")
  
  --技能取消方式
  self.cancelSkill1 = self.controlOptionPanel:Find("Panel/Grid/CancelSkill/Selected")
  self.cancelSkill2 = self.controlOptionPanel:Find("Panel/Grid/CancelSkill/Selected2")

  --轮盘灵敏度
  self.diskS = self.controlOptionPanel:Find("DiskUseSkill/DiskSensitivity")
  
  --震动
  self.shockBase = self.audioOptionPanel:Find("Shock/Base")
  self.shockBar = self.shockBase:Find("Bar")

  --游戏音乐
  self.gameMusicBase = self.audioOptionPanel:Find("GameMusic/Base")
  self.gameMusicBar = self.gameMusicBase:Find("Bar")
  self.gameMusicVolumn = self.audioOptionPanel:Find("MusicVolumn")
  
  --游戏音效
  self.gameAudioBase = self.audioOptionPanel:Find("GameAudio/Base")
  self.gameAudioBar = self.gameAudioBase:Find("Bar")
  self.gameAudioVolumn = self.audioOptionPanel:Find("AudioVolumn")
  
  --语音聊天
  self.speakBase = self.audioOptionPanel:Find("Speak/Base")
  self.speakBar = self.speakBase:Find("Bar")
  self.speakVolumn = self.audioOptionPanel:Find("SpeakVolumn")
  
  --帮助按钮
  --self.helpNoticeButton1 = self.baseOptionPanel:Find("CameraMove/Image")
  self.helpNoticeButton2 = self.controlOptionPanel:Find("Panel/Grid/CancelSkill/HelpNoticeButton")
  
  --关闭窗口按钮
  self.cancelButton = self.this.transform:Find("MainFrame/CancelButton")
  
  --外部设置窗口
  
  
  --按钮事件绑定
  local listener = NTGEventTriggerProxy.Get(self.baseOption.gameObject)
  local callback1 = function(self, e)
    self:TabControl(1)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)
  
  listener = NTGEventTriggerProxy.Get(self.controlOption.gameObject)
  local callback2 = function(self, e)
    self:TabControl(2)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback2, self)
  
  listener = NTGEventTriggerProxy.Get(self.audioOption.gameObject)
  local callback3 = function(self, e)
    self:TabControl(3)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback3, self)
  
  listener = NTGEventTriggerProxy.Get(self.helpNoticeButton2.gameObject)
  local helpNotice2 = function(self, e)
    self:HelpNoticeUseSkill()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(helpNotice2, self)  
  
  

  
  --测试数据
  self.testNum = 0

  self.UICamera=GameObject.Find("GameLogic"):GetComponent("Camera")
  self.canvas= GameObject.Find("PanelRoot"):GetComponent("Canvas"); 
  self.y=self.canvas.transform:GetComponent("UnityEngine.UI.CanvasScaler").referenceResolution.y

  self.coroutines = {}
  

  
end

function OptionController:Start()

  if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end




  self:RoleOutLineOutSide(nil)
  self:GameInputOutSide(nil)
  self:CameraHeightOutSide(nil)
  self:TargetLock(nil)
  self:UseSkill(nil)
  self:TargetSelect(nil)
  self:MobAttack(nil)
  self:ShowTargetIcon(nil)
  self:DiskLockTarget(nil)
  self:ShowDiskPosition(nil)
  self:CancelSkill(nil)
  self:DoDiskS(nil)
  self:GameMusic(nil)
  self:GameAudio(nil)
  self:Speak(nil)
  --self:DoCameraSiensitivityOnValueChanged(nil)
  self:DoMusicVolumn(nil)
  self:DoAudioVolumn(nil)
  self:DoSpeakVolumn(nil)
  self:Shock(nil)
  self:HighQShow(nil)
  self:GraphicsQ(nil)
  self:ParticleQ(nil)


    --初始化
  self:TabControl(1)
end





function OptionController:TabControl(tabNum)
  if tabNum == 1 then
    self.baseOption:Find("Selected1").gameObject:SetActive(true)
    self.controlOption:Find("Selected2").gameObject:SetActive(false)
    self.audioOption:Find("Selected3").gameObject:SetActive(false)
    --self.baseOptionPanel.gameObject:SetActive(false)
    self.baseOptionOutSidePanel.gameObject:SetActive(true)
    self.controlOptionPanel.gameObject:SetActive(false)
    self.audioOptionPanel.gameObject:SetActive(false)     
  elseif tabNum == 2 then
    self.baseOption:Find("Selected1").gameObject:SetActive(false)
    self.controlOption:Find("Selected2").gameObject:SetActive(true)
    self.audioOption:Find("Selected3").gameObject:SetActive(false)
    --self.baseOptionPanel.gameObject:SetActive(false)
    self.baseOptionOutSidePanel.gameObject:SetActive(false)
    self.controlOptionPanel.gameObject:SetActive(true)
    self.audioOptionPanel.gameObject:SetActive(false)
  elseif tabNum == 3 then
    self.baseOption:Find("Selected1").gameObject:SetActive(false)
    self.controlOption:Find("Selected2").gameObject:SetActive(false)
    self.audioOption:Find("Selected3").gameObject:SetActive(true)
    --self.baseOptionPanel.gameObject:SetActive(false)
    self.baseOptionOutSidePanel.gameObject:SetActive(false)
    self.controlOptionPanel.gameObject:SetActive(false)
    self.audioOptionPanel.gameObject:SetActive(true)
  end


end

--************控制设置开始
function OptionController:ChoseOne(goTable1,goTable2,status)
  if status == 0 then
    goTable1.parent:Find("Image").gameObject:SetActive(false)
    goTable2.parent:Find("Image2").gameObject:SetActive(true)
    status = 1
  elseif status == 1 then
    goTable1.parent:Find("Image").gameObject:SetActive(true)
    goTable2.parent:Find("Image2").gameObject:SetActive(false)
    status = 0
  end
  return status
end

function OptionController:TargetLock(delegate)
  local listener1 = NTGEventTriggerProxy.Get(self.targetLock1.gameObject)
  local cameraMovell = function(self, e)
    --print("UTGDataOperator.Instance.CameraMove " .. UTGDataOperator.Instance.TargetLock)
    UTGDataOperator.Instance.TargetLock = self:ChoseOne(self.targetLock1,self.targetLock2,UTGDataOperator.Instance.TargetLock)
    
    if delegate ~= nil then
      self.this:InvokeDelegate(delegate,UTGDataOperator.Instance.TargetLock)
    end
  end
  listener1.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(cameraMovell, self)
  
  local listenermm = NTGEventTriggerProxy.Get(self.targetLock2.gameObject)
  local cameraMovemm = function(self, e)
    --print("UTGDataOperator.Instance.CameraMove " .. UTGDataOperator.Instance.TargetLock)
    UTGDataOperator.Instance.TargetLock = self:ChoseOne(self.targetLock1,self.targetLock2,UTGDataOperator.Instance.TargetLock)
    
    if delegate ~= nil then
      self.this:InvokeDelegate(delegate,UTGDataOperator.Instance.TargetLock)
    end
  end  
  listenermm.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(cameraMovemm, self)  
end

function OptionController:UseSkill(delegate)
  local listener = NTGEventTriggerProxy.Get(self.useSkill1.gameObject)
  local listener2 = NTGEventTriggerProxy.Get(self.useSkill2.gameObject)
  local useSkill = function(self,e)
    UTGDataOperator.Instance.UseSkill = self:ChoseOne(self.useSkill1,self.useSkill2,UTGDataOperator.Instance.UseSkill)
    --print("UTGDataOperator.Instance.CameraMove " .. UTGDataOperator.Instance.UseSkill)
    if delegate ~= nil then
      self.this:InvokeDelegate(delegate,UTGDataOperator.Instance.UseSkill)
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(useSkill, self)  
  listener2.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(useSkill, self)
end

function OptionController:TargetSelect(delegate)
  local listener = NTGEventTriggerProxy.Get(self.targetSelect1.gameObject)
  local listener2 = NTGEventTriggerProxy.Get(self.targetSelect2.gameObject)
  local targetSelect = function(self,e)
    UTGDataOperator.Instance.TargetSelect = self:ChoseOne(self.targetSelect1,self.targetSelect2,UTGDataOperator.Instance.TargetSelect)
    --print("UTGDataOperator.Instance.CameraMove " .. UTGDataOperator.Instance.TargetSelect)
    if delegate ~= nil then
      self.this:InvokeDelegate(delegate,UTGDataOperator.Instance.TargetSelect)
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(targetSelect, self)  
  listener2.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(targetSelect, self)
end

function OptionController:MobAttack(delegate)
  local listener = NTGEventTriggerProxy.Get(self.mobAttack1.gameObject)
  local listener2 = NTGEventTriggerProxy.Get(self.mobAttack2.gameObject)
  local mobAttack = function(self,e)
    UTGDataOperator.Instance.MobAttack = self:ChoseOne(self.mobAttack1,self.mobAttack2,UTGDataOperator.Instance.MobAttack)
    --print("UTGDataOperator.Instance.CameraMove " .. UTGDataOperator.Instance.MobAttack)
    if delegate ~= nil then
      self.this:InvokeDelegate(delegate,UTGDataOperator.Instance.MobAttack)
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(mobAttack, self)  
  listener2.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(mobAttack, self)
end

function OptionController:ShowTargetIcon(delegate)
  local listener = NTGEventTriggerProxy.Get(self.showTargetIcon1.gameObject)
  local listener2 = NTGEventTriggerProxy.Get(self.showTargetIcon2.gameObject)
  local cancelSkill = function(self,e)
    UTGDataOperator.Instance.ShowTargetIcon = self:ChoseOne(self.showTargetIcon1,self.showTargetIcon2,UTGDataOperator.Instance.ShowTargetIcon)
    --print("UTGDataOperator.Instance.CameraMove " .. UTGDataOperator.Instance.ShowTargetIcon)
    if delegate ~= nil then
      self.this:InvokeDelegate(delegate,UTGDataOperator.Instance.ShowTargetIcon)
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(showTargetIcon, self)  
  listener2.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(showTargetIcon, self)
end

function OptionController:DiskLockTarget(delegate)
  local listener = NTGEventTriggerProxy.Get(self.diskLockTarget1.gameObject)
  local listener2 = NTGEventTriggerProxy.Get(self.diskLockTarget2.gameObject)
  local diskLockTarget = function(self,e)
    UTGDataOperator.Instance.DiskLockTarget = self:ChoseOne(self.diskLockTarget1,self.diskLockTarget2,UTGDataOperator.Instance.DiskLockTarget)
    --print("UTGDataOperator.Instance.CameraMove " .. UTGDataOperator.Instance.DiskLockTarget)
    if delegate ~= nil then
      self.this:InvokeDelegate(delegate,UTGDataOperator.Instance.DiskLockTarget)
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(diskLockTarget, self)  
  listener2.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(diskLockTarget, self)
end

function OptionController:ShowDiskPosition(delegate)
  local listener = NTGEventTriggerProxy.Get(self.showDiskPosition1.gameObject)
  local listener2 = NTGEventTriggerProxy.Get(self.showDiskPosition2.gameObject)
  local showDiskPosition = function(self,e)
    UTGDataOperator.Instance.ShowDiskPosition = self:ChoseOne(self.showDiskPosition1,self.showDiskPosition2,UTGDataOperator.Instance.ShowDiskPosition)
    --print("UTGDataOperator.Instance.CameraMove " .. UTGDataOperator.Instance.ShowDiskPosition)
    if delegate ~= nil then
      self.this:InvokeDelegate(delegate,UTGDataOperator.Instance.ShowDiskPosition)
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(showDiskPosition, self)  
  listener2.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(showDiskPosition, self)
end

function OptionController:CancelSkill(delegate)
  local listener = NTGEventTriggerProxy.Get(self.cancelSkill1.gameObject)
  local listener2 = NTGEventTriggerProxy.Get(self.cancelSkill2.gameObject)
  local cancelSkill = function(self,e)
    UTGDataOperator.Instance.CancelSkill = self:ChoseOne(self.cancelSkill1,self.cancelSkill2,UTGDataOperator.Instance.CancelSkill)
    --print("UTGDataOperator.Instance.CameraMove " .. UTGDataOperator.Instance.CancelSkill)
    if delegate ~= nil then
      self.this:InvokeDelegate(delegate,UTGDataOperator.Instance.CancelSkill)
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(cancelSkill, self)  
  listener2.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(cancelSkill, self)
end

function OptionController:DoDiskS(delegate)
  if delegate ~= nil then
    table.insert(self.coroutines,coroutine.start(OptionController.DiskS,delegate, self))
  end
end

function OptionController:DiskS(delegate)
  local preNum = 0
  while (true) do
    if preNum ~= self.diskS:GetComponent("UnityEngine.UI.Scrollbar").value then
      preNum = self.diskS:GetComponent("UnityEngine.UI.Scrollbar").value
      if delegate ~= nil then
        self.this:InvokeDelegate(delegate,preNum)
      end
    end
    coroutine.wait(0.1)
  end
end





--************控制设置结束

--************音效设置开始

function OptionController:Shock(delegate)
   local ob = self.shockBar:Find("Image"):GetComponent("NTGLuaScript").self
   ob.delegate = delegate
   ob.status[1] = UTGDataOperator.Instance.RoleOutLine 
end

function OptionController:GameMusic(delegate)
   local ob = self.gameMusicBar:Find("Image"):GetComponent("NTGLuaScript").self
   ob.delegate = delegate
   ob.status[1] = UTGDataOperator.Instance.GameMusic    
end

function OptionController:GameAudio(delegate)
   local ob = self.gameAudioBar:Find("Image"):GetComponent("NTGLuaScript").self
   ob.delegate = delegate
   ob.status[1] = UTGDataOperator.Instance.GameAudio    
end

function OptionController:Speak(delegate)
   local ob = self.speakBar:Find("Image"):GetComponent("NTGLuaScript").self
   ob.delegate = delegate
   ob.status[1] = UTGDataOperator.Instance.Speak 
end

function OptionController:DoMusicVolumn(delegate)
  if delegate ~= nil then  
    table.insert(self.coroutines,coroutine.start(OptionController.MusicVolumn,self,delegate))
  end
end

function OptionController:MusicVolumn(delegate)
  local preNum = 0
  while (true) do
    if preNum ~= self.gameMusicVolumn:GetComponent("UnityEngine.UI.Scrollbar").value then
      preNum = self.gameMusicVolumn:GetComponent("UnityEngine.UI.Scrollbar").value
      self.this:InvokeDelegate(delegate,preNum)
    end
    coroutine.wait(0.1)
  end
end

function OptionController:DoAudioVolumn(delegate)
  if delegate ~= nil then
    table.insert(self.coroutines,coroutine(OptionController.AudioVolumn,self,delegate))
  end
end

function OptionController:AudioVolumn(delegate)
  local preNum = 0
  while (true) do
    if preNum ~= self.gameAudioVolumn:GetComponent("UnityEngine.UI.Scrollbar").value then
      preNum = self.gameAudioVolumn:GetComponent("UnityEngine.UI.Scrollbar").value
      self.this:InvokeDelegate(delegate,preNum)
    end
    coroutine.wait(0.1)
  end
end

function OptionController:DoSpeakVolumn(delegate)
  if delegate ~= nil then
    table.insert(self.coroutines,coroutine.start(OptionController.SpeakVolumn,self,delegate))
  end
end

function OptionController:SpeakVolumn(delegate)
  local preNum = 0
  while (true) do
    if preNum ~= self.speakVolumn:GetComponent("UnityEngine.UI.Scrollbar").value then
      preNum = self.speakVolumn:GetComponent("UnityEngine.UI.Scrollbar").value
      self.this:InvokeDelegate(delegate,preNum)
    end
    coroutine.wait(0.1)
  end
end

--************音效设置结束

--************外部基础设置

function OptionController:HighQShow(delegate)
   local ob = self.highQBar:Find("Image"):GetComponent("NTGLuaScript").self
   ob.delegate = delegate
   ob.status[1] = UTGDataOperator.Instance.HQ
end

function OptionController:RoleOutLineOutSide(delegate)
   local ob = self.roleOutLineOutSideBar:Find("Image"):GetComponent("NTGLuaScript").self
   ob.delegate = delegate
   ob.status[1] = UTGDataOperator.Instance.RoleOutLineOutSide 
end

function OptionController:GameInputOutSide(delegate)
   local ob = self.gameInputOutSideBar:Find("Image"):GetComponent("NTGLuaScript").self
   ob.delegate = delegate
   ob.status[1] = UTGDataOperator.Instance.GameInputOutSide  
end

function OptionController:CameraHeightOutSide(delegate)
   local ob = self.cameraHeightOutSideBar:Find("Image"):GetComponent("NTGLuaScript").self
   ob.delegate = delegate
   ob.status[1] = UTGDataOperator.Instance.CameraHeightOutSide     
end

function OptionController:GraphicsQ(delegate)
   local ob = self.gQBar:Find("Image"):GetComponent("NTGLuaScript").self
   ob.delegate = delegate
   ob.status[1] = UTGDataOperator.Instance.GQ
   ob.ll = "低"
   ob.mm = "中"
   ob.rr = "高"     
end

function OptionController:ParticleQ(delegate)
   local ob = self.pQBar:Find("Image"):GetComponent("NTGLuaScript").self
   ob.delegate = delegate
   ob.status[1] = UTGDataOperator.Instance.PQ
   ob.ll = "低"
   ob.mm = "中"
   ob.rr = "高" 
end

--************外部基础设置结束
function OptionController:NeedSHPanel(text)
  table.insert(self.coroutines,coroutine.start(OptionController.NeedOtherPanelCoroutine,self,text))
end

function OptionController:NeedOtherPanelCoroutine(text)
  local async = GameManager.CreatePanelAsync("SelfHideNotice")
  while async.Done == false do
    coroutinewait(0.05)
  end
  
  if async.Done == true then
    if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
      SelfHideNoticeAPI.Instance.InitNoticeForSelfHideNotice(text)
    end
  end
end


function OptionController:HelpNoticeUseSkill()
  self.noticeUseSkill.gameObject:SetActive(true)
  local listener = NTGEventTriggerProxy.Get(self.noticeUseSkill:Find("Frame/IKnow").gameObject)
  local showHide = function(self, e)
    self.noticeUseSkill.gameObject:SetActive(false)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(showHide, self)   
end

function OptionController:Init()
  -- body
  
end





function OptionController:ClosePanel()
  -- body
  self.this.transform.parent.localPosition = Vector3.New(-1290,0,0)
  UTGDataOperator.Instance:RecordOption()
  --self.this:StopAllCoroutines()
end

function OptionController:OpenPanel()
  -- body
  self.this.transform.parent.localPosition = Vector3.New(0,0,0)
  --self:DoMusicVolumn(delegate)
  --self:DoAudioVolumn(delegate)
  --self:DoSpeakVolumn(delegate)
  --self:DoDiskS(delegate)
end


function OptionController:DestroySelf()
  if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
    --print("aaaaaaaaa")
    UTGMainPanelAPI.Instance:ShowSelf()
  end
  --print("BBBBBBBBBBB")
  self.this:StopAllCoroutines()
  UTGDataOperator.Instance:RecordOption()
  Object.Destroy(self.this.transform.parent.gameObject) 
end







function OptionController:Test(num)
  --print("UTGDataOperator.Instance.RoleOutLine " .. num)
end



