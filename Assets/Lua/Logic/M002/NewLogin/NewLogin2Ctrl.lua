require "System.Global"
require "Logic.M002.NewLogin.LoginUtils"

local json = require "cjson"

class("NewLogin2Ctrl")

function NewLogin2Ctrl:Awake(this) 
  self.this = this
  self.verNo = this.transforms[2]:GetComponent("UnityEngine.UI.Text")
  self.loginPanel = this.transforms[0]:GetComponent("NTGLuaScript")
  self.loginPanelRoot = this.transforms[0]:FindChild("root")
  self.registPanel = this.transforms[1]:GetComponent("NTGLuaScript")
  self.HandlerTab = {}
end

function NewLogin2Ctrl:Start()
  self:Init()
end

function NewLogin2Ctrl:Init()
  self.verNo = ""
  if TGNetService.GetInstance():IsRunning() then 
    TGNetService.NewInstance()
  end

  local handler = TGNetService.NetEventHanlderSelf(NewLogin2Ctrl.LoginConnected, self)
  table.insert(self.HandlerTab,handler)

  TGNetService.GetInstance():AddEventHandler("Connect",handler, 0)--回调
  TGNetService.GetInstance():Start("127.0.0.1", 25001)  --("115.29.19.68", 25001)--连接服务器
  GameManager.NetDispatcherHost:StartCoroutine(TGNetService.GetInstance():NetEventDispatcher())

end

function NewLogin2Ctrl:LoginConnected(e)
  if e.Type == "Connect" then   
    --Debugger.LogString("Server Connected")
    self.loginPanel.self:AutoLogin()
    return true
  end
  return true
end

function NewLogin2Ctrl:LoginToRegist()
  self.loginPanelRoot.gameObject:SetActive(false)
  self.registPanel.gameObject:SetActive(true)
end

function NewLogin2Ctrl:RegistToLogin()
  self.loginPanelRoot.gameObject:SetActive(true)
  self.registPanel.gameObject:SetActive(false)
end

function NewLogin2Ctrl:StartGameToHere()
  self.this.gameObject:SetActive(true)
  self.loginPanelRoot.gameObject:SetActive(true)
  self.registPanel.gameObject:SetActive(false)
end

function NewLogin2Ctrl:GoToStartGame()
  self.loginPanelRoot.gameObject:SetActive(false)
  self.registPanel.gameObject:SetActive(false)
end

function NewLogin2Ctrl:ReLogin(callBack,caller)
  self.loginPanel.self:ReLogin(callBack,caller)
end

function NewLogin2Ctrl:OnDestroy()
  for i=#self.HandlerTab,1,-1 do
    TGNetService.GetInstance():RemoveEventHander("Connect",self.HandlerTab[i])
  end

  self.this = nil
  self = nil
end

  