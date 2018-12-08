require "System.Global"

local json = require "cjson"

class("RegistPanelCtrl")

function RegistPanelCtrl:Awake(this)
  self.this = this
  self.userNameInput = this.transforms[1]
  self.passwordInput = this.transforms[2]
  self.passwordConfirmInput = this.transforms[3]
  self.registAndLoginBtn = this.transforms[4]
  self.backBtn = this.transforms[5]
  self.errorMsgPanel1 = this.transforms[6]
  self.errorMsg1 = this.transforms[7]
  self.errorMsgPanel2 = this.transforms[8]
  self.errorMsg2 = this.transforms[9]
  self.errorMsgPanel3 = this.transforms[10]
  self.errorMsg3 = this.transforms[11]
  self.newLogin2Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
end

function RegistPanelCtrl:Start()
  self:Init()
end

function RegistPanelCtrl:Init()
  local listener
  listener = NTGEventTriggerProxy.Get(self.backBtn.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(RegistPanelCtrl.OnBackBtn,self)
  
  listener = NTGEventTriggerProxy.Get(self.registAndLoginBtn.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(RegistPanelCtrl.OnRegistAndLoginBtn,self)
  
  listener = NTGEventTriggerProxy.Get(self.userNameInput.gameObject)
  listener.onDeselect = listener.onDeselect + NTGEventTriggerProxy.BaseEventDelegateSelf(RegistPanelCtrl.OnUserNameInputOver,self)
  
  listener = NTGEventTriggerProxy.Get(self.passwordInput.gameObject)
  listener.onDeselect = listener.onDeselect + NTGEventTriggerProxy.BaseEventDelegateSelf(RegistPanelCtrl.OnPasswordInputOver,self) 
  
  listener = NTGEventTriggerProxy.Get(self.passwordConfirmInput.gameObject)
  listener.onDeselect = listener.onDeselect + NTGEventTriggerProxy.BaseEventDelegateSelf(RegistPanelCtrl.OnPasswordConfirmInputOver,self) 
end

function RegistPanelCtrl:OnBackBtn()
  self:ClearAll()
  self.newLogin2Ctrl.self:RegistToLogin()
end

function RegistPanelCtrl:OnRegistAndLoginBtn()
  if self:CheckAll() then
    self:Regist(self.userNameInput:GetComponent("UnityEngine.UI.InputField").text ,self.passwordInput:GetComponent("UnityEngine.UI.InputField").text)
  end
end

function RegistPanelCtrl:OnUserNameInputOver()
  self:CheckUserName(21)
end

function RegistPanelCtrl:OnPasswordInputOver()
  self:CheckPassword(6)
end

function RegistPanelCtrl:OnPasswordConfirmInputOver()
  local txtPassWordConfirm = self.passwordConfirmInput:GetComponent("UnityEngine.UI.InputField").text
  if txtPassWordConfirm == nil or txtPassWordConfirm == "" then return end
  self:CheckPasswordConfirm()
end

function RegistPanelCtrl:CheckAll()
  if self:CheckUserName(21) == false then return false end
  if self:CheckPassword(6) == false then return false end
  if self:CheckPasswordConfirm() == false then 
    self.errorMsgPanel3.gameObject:SetActive(true)
    self.errorMsg3:GetComponent("UnityEngine.UI.Text").text = "与输入密码不一致"
    return false 
  end
  return true
end

function RegistPanelCtrl:CheckUserName(maxByteCount)
  local txtUserName = self.userNameInput:GetComponent("UnityEngine.UI.InputField").text
  if txtUserName == "" then
    self.errorMsgPanel1.gameObject:SetActive(true)
    self.errorMsg1:GetComponent("UnityEngine.UI.Text").text = "请输入账号"
    return false
  end
  if string.len(txtUserName) > maxByteCount then
    self.errorMsgPanel1.gameObject:SetActive(true)
    self.errorMsg1:GetComponent("UnityEngine.UI.Text").text = "不能超过"..maxByteCount.."个字节"
    return false
  end
  if string.find(txtUserName, " ") then
    self.errorMsgPanel1.gameObject:SetActive(true)
    self.errorMsg1:GetComponent("UnityEngine.UI.Text").text = "账号中不能使用空格"
    return false
  end
  
  self.errorMsgPanel1.gameObject:SetActive(false)
  return true
end

function RegistPanelCtrl:CheckPassword(maxByteCount)
  local txtPassWord = self.passwordInput:GetComponent("UnityEngine.UI.InputField").text
  if string.len(txtPassWord) < maxByteCount then
    self.errorMsgPanel2.gameObject:SetActive(true)
    self.errorMsg2:GetComponent("UnityEngine.UI.Text").text = "不能低于"..maxByteCount.."个字节"
    return false
  end
  
  local checkCount = 0
  if string.match(txtPassWord, "%l") ~= nil then
    checkCount = checkCount + 1
  end
  if string.match(txtPassWord, "%u") ~= nil then
    checkCount = checkCount + 1
  end
  if string.match(txtPassWord, "%d") ~= nil then
    checkCount = checkCount + 1
  end
  if checkCount < 2 then
    self.errorMsgPanel2.gameObject:SetActive(true)
    self.errorMsg2:GetComponent("UnityEngine.UI.Text").text = "须包含数字、大小写字母中的任意两项"
    return false
  end 
  
  self.errorMsgPanel2.gameObject:SetActive(false)
  return true
end

function RegistPanelCtrl:CheckPasswordConfirm()
  local txtPassWord = self.passwordInput:GetComponent("UnityEngine.UI.InputField").text
  local txtPassWordConfirm = self.passwordConfirmInput:GetComponent("UnityEngine.UI.InputField").text
  if txtPassWord ~=  txtPassWordConfirm then
    self.errorMsgPanel3.gameObject:SetActive(true)
    self.errorMsg3:GetComponent("UnityEngine.UI.Text").text = "与输入密码不一致"
    return false
  end
  
  self.errorMsgPanel3.gameObject:SetActive(false)
  return true
end

function RegistPanelCtrl:ClearAll()
  self.errorMsgPanel1.gameObject:SetActive(false)
  self.errorMsgPanel2.gameObject:SetActive(false)
  self.errorMsgPanel3.gameObject:SetActive(false)
  self.userNameInput:GetComponent("UnityEngine.UI.InputField").text = ""
  self.passwordInput:GetComponent("UnityEngine.UI.InputField").text = ""
  self.passwordConfirmInput:GetComponent("UnityEngine.UI.InputField").text = ""
end

function RegistPanelCtrl:Regist(username,password,networkDelegate,networkDelegateSelf)
  self.registerUsername = username
  self.registerPassword = password
  self.registerNetworkDelegate = networkDelegate
  self.registerNetworkDelegateSelf = networkDelegateSelf
  local registerRequest = NetRequest.New()
  registerRequest.Content = JObject.New(JProperty.New("Type","RequestNewAccount"),
                                          JProperty.New("UserName",username),
                                          JProperty.New("Password",password),
                                          JProperty.New("DeviceType","All"),
                                          JProperty.New("DeviceId","6969696969696969696"),
                                          JProperty.New("AccountType","All"))
  registerRequest.Handler = TGNetService.NetEventHanlderSelf(RegistPanelCtrl.RegisterHandler,self)
  TGNetService.GetInstance():SendRequest(registerRequest)
end

function RegistPanelCtrl:RegisterHandler(e)
  if e.Type == "RequestNewAccount" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      self.lastUsername = self.registerUsername
      self.lastPassword = self.registerPassword
      
      if self.registerNetworkDelegate ~= nil then
        self.registerNetworkDelegateSelf:registerNetworkDelegate()
      end
      
      self.newLogin2Ctrl.self.loginPanel.self:Login(self.lastUsername, self.lastPassword)
      --print("注册成功")
      return true
    end
    if result == 6 then
      self.errorMsgPanel1.gameObject:SetActive(true)
      self.errorMsg1:GetComponent("UnityEngine.UI.Text").text = "账户已存在"
      return true
    end
    if result == 3 then
      self.errorMsgPanel1.gameObject:SetActive(true)
      self.errorMsg1:GetComponent("UnityEngine.UI.Text").text = "账户格式不正确"
      return true
    end
    self.errorMsgPanel1.gameObject:SetActive(true)
    self.errorMsg1:GetComponent("UnityEngine.UI.Text").text = "未知错误"
    return true
  end
end

function RegistPanelCtrl:LoginSuccess()
  self:ClearAll()
  GameManager.CreatePanel("StartGame")
  self.newLogin2Ctrl.self:GoToStartGame()
end

function LoginPanelCtrl:OnDestroy()
  self.this = nil
  self = nil
end
  