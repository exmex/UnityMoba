require "System.Global"
require "Logic.M002.NewLogin.LoginUtils"

local json = require "cjson"

class("LoginPanelCtrl")

function LoginPanelCtrl:Awake(this)
    self.this = this
    self.userNameInput = this.transforms[1]
    self.passwordInput = this.transforms[2]
    self.loginBtn = this.transforms[3]
    self.registBtn = this.transforms[4]
    self.errorMsgPanel1 = this.transforms[5]
    self.errorMsg1 = this.transforms[6]:GetComponent("UnityEngine.UI.Text")
    self.newLogin2Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
    self.root = this.transform:FindChild("root")
    self.root.gameObject:SetActive(false)
end

function LoginPanelCtrl:Start()
    self:Init()
end

function LoginPanelCtrl:Init()
    self.accountInfo = {}

    local listener
    listener = NTGEventTriggerProxy.Get(self.loginBtn.gameObject)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(LoginPanelCtrl.OnLoginBtn, self)

    listener = NTGEventTriggerProxy.Get(self.registBtn.gameObject)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(LoginPanelCtrl.OnRegistBtn, self)
end

function LoginPanelCtrl:OnRegistBtn()
    self.newLogin2Ctrl.self:LoginToRegist()
end

function LoginPanelCtrl:OnLoginBtn(go)
    --self:LoginSuccess() return
    self:Login(self.userNameInput:GetComponent("UnityEngine.UI.InputField").text, self.passwordInput:GetComponent("UnityEngine.UI.InputField").text)
end

function LoginPanelCtrl:AutoLogin()
    local path = NTGResourceController.GetDataPath("GlobalData")
    if Directory.Exists(path) == false then
        self.root.gameObject:SetActive(true)
        Directory.CreateDirectory(path)
    else
        local wantData = {}
        if File.Exists(path .. "GlobalData.ini") == true then
            local jo = NTGResourceController.ReadAllText(path .. "GlobalData.ini")
            wantData = json.decode(jo)
        end
        if wantData.LastUsername ~= nil and wantData.LastUsername ~= "" then
            self.lastUsername = wantData.LastUsername
            self.lastPassword = wantData.LastPassword
            --print(self.lastUsername)
            self:Login(self.lastUsername, self.lastPassword)
        else
            self.root.gameObject:SetActive(true)
        end
    end
end

function LoginPanelCtrl:Login(username, password, networkDelegate, networkDelegateSelf)
    if username == "" or password == "" then return end
    NewLogin2API.Instance:SetWaitPanel(true)
    self.loginNetworkDelegate = networkDelegate
    self.loginNetworkDelegateSelf = networkDelegateSelf

    self.lastUserName = username
    self.lastPassword = password

    local loginRequest = NetRequest.New()
    loginRequest.Content = JObject.New(JProperty.New("Type", "Login"),
        JProperty.New("UserName", username),
        JProperty.New("Password", password),
        JProperty.New("DeviceType", "All"),
        JProperty.New("DeviceId", "6969696969696969696"))
    loginRequest.Handler = TGNetService.NetEventHanlderSelf(LoginPanelCtrl.LoginHandler, self)
    TGNetService.GetInstance():SendRequest(loginRequest)
end



function LoginPanelCtrl:ReLogin(callBack, callBacker)
    local loginRequest = NetRequest.New()
    loginRequest.Content = JObject.New(JProperty.New("Type", "Login"),
        JProperty.New("UserName", self.lastUserName),
        JProperty.New("Password", self.lastPassword),
        JProperty.New("DeviceType", "All"),
        JProperty.New("DeviceId", "6969696969696969696"))
    loginRequest.Handler = TGNetService.NetEventHanlderSelf(LoginPanelCtrl.ReLoginHandler, self)
    self.reLoginCallBack = callBack
    self.reLoginCaller = callBacker
    TGNetService.GetInstance():SendRequest(loginRequest)
end

function LoginPanelCtrl:ReLoginHandler(e)
    if e.Type == "Login" then
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 1 then
            self.accountInfo.AccountId = tonumber(e.Content:get_Item("AccountId"):ToString())
            self.accountInfo.Session = e.Content:get_Item("Session"):ToString()

            local accountId = tonumber(e.Content:get_Item("AccountId"):ToString())
            local session = e.Content:get_Item("Session"):ToString()

            if self.reLoginCallBack ~= nil then
                self.reLoginCallBack(self.reLoginCaller, accountId, session)
            end
            return true
        end
    end
    return false
end

function LoginPanelCtrl:LoginHandler(e)
    if e.Type == "Login" then
        --NewLogin2API.Instance:SetWaitPanel(false)  
        local result = tonumber(e.Content:get_Item("Result"):ToString())
        if result == 1 then
            self.accountInfo.AccountId = tonumber(e.Content:get_Item("AccountId"):ToString())
            self.accountInfo.Session = e.Content:get_Item("Session"):ToString()
            self:LoginSuccess()

            if self.loginNetworkDelegate ~= nil then
                self.loginNetworkDelegateSelf:loginNetworkDelegate()
            end
        else
            NewLogin2API.Instance:SetWaitPanel(false)
            self.root.gameObject:SetActive(true)
            self.errorMsgPanel1.gameObject:SetActive(true)
            self.errorMsg1.text = "账号或密码错误"
        end
        return true
    end
    return false
end

function LoginPanelCtrl:SaveUserLoginInfo()
    local path = NTGResourceController.GetDataPath("GlobalData") .. "GlobalData.ini"
    if self.lastUserName ~= nil and self.lastUserName ~= "" then
        local stream = { LastUsername = self.lastUserName, LastPassword = self.lastPassword }
        NTGResourceController.WriteAllText(path, json.encode(stream))
    end
end

function LoginPanelCtrl:LoginSuccess()
    -- body
    coroutine.start(LoginPanelCtrl.DoLoginSuccess, self)
end

function LoginPanelCtrl:DoLoginSuccess()
    --print("登陆成功")
    self:SaveUserLoginInfo()
    self.userNameInput:GetComponent("UnityEngine.UI.InputField").text = ""
    self.passwordInput:GetComponent("UnityEngine.UI.InputField").text = ""
    self.result = false
    coroutine.start(LoginPanelCtrl.PreLoadMainPanelBundle, self)
    while self.result == false do
        coroutine.step()
    end
    GameManager.CreatePanel("StartGame")
    StartGameAPI.Instance:SetParam(self.accountInfo.AccountId, self.accountInfo.Session)
    self.newLogin2Ctrl.self:GoToStartGame()
    NewLogin2API.Instance:SetWaitPanel(false)
end

function LoginPanelCtrl:PreLoadMainPanelBundle()
    -- body
    self.assetLoader = NTGResourceController.AssetLoader.New()
    self.assetLoader:LoadAsset("UTGMain", "UTGMainPanel")
    while self.assetLoader.Done == false do
        coroutine.step()
    end
    self.result = self.assetLoader.Done
    self.assetLoader:Close()
    self.assetLoader = nil
end

function LoginPanelCtrl:OnDestroy()
    self.this = nil
    self.errorMsg1.font = nil
    self = nil
end

  