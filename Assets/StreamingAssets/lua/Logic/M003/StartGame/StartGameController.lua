--require "System.Global"
require "Logic.UTGData.UTGData"
--anthor zx
class("StartGameController")
local json = require "cjson"

function StartGameController:Awake(this)
  self.this = this

  --注册按钮事件
  local butReset = NTGEventTriggerProxy.Get(this.transforms[0].gameObject)
  butReset.onPointerClick = butReset.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(StartGameController.ClickReset, self)
  local butStartGame = NTGEventTriggerProxy.Get(this.transforms[1].gameObject)
  butStartGame.onPointerClick = butStartGame.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(StartGameController.ClickStartGame, self)
  local butSelectServer = NTGEventTriggerProxy.Get(this.transforms[2].gameObject)
  butSelectServer.onPointerClick = butSelectServer.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(StartGameController.ClickSelectServer, self)

  self.panel = {}
  self.panel["root"] = this.transforms[3].gameObject
  self.panel["chooseserver"] = this.transforms[10].gameObject
  self.panel["root"]:SetActive(false)

  --主界面服务器信息
  self.zhu_server_txtprename = this.transforms[6]
  self.zhu_server_txtname = this.transforms[4]
  self.zhu_server_image = this.transforms[5]

  --服务器列表
  self.serverlistemp = this.transforms[8]
  self.serverlisroot = this.transforms[7]
  self.but_myser = this.transforms[11].gameObject
  self.but_suggser = this.transforms[12].gameObject
  self.lastserverui = this.transforms[13]
  local butLastServer = NTGEventTriggerProxy.Get(self.lastserverui.gameObject)
  butLastServer.onPointerClick = butLastServer.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(StartGameController.ClickSelectLastServer, self)

  --上方资源条
  self.topPanel = GameManager.CreatePanel("NormalResource")

  self.HandlerTab = {}
end

function StartGameController:Start()

  self:NetGetServerList()

  local topAPI = self.topPanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("StartGamePanel/ChooseServerPanel")
  topAPI:ShowControl(1)
  topAPI:InitTop(self, StartGameController.ClickBackMainUI, nil, nil, "选择服务器")
end

--显示服务器信息(主界面)
function StartGameController:ShowServerInfo(server)
  self.selectserver = server
  self.zhu_server_txtname:GetComponent("UnityEngine.UI.Text").text = tostring(server.Name)
  self.zhu_server_txtprename:GetComponent("UnityEngine.UI.Text").text = tostring(server.Prefix)
  self.zhu_server_image:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("startgame", tostring("M003-ServerState" .. tostring(server.Status)), "UnityEngine.Sprite")
end

--网络 获取服务器信息
function StartGameController:NetGetServerList()
  --print("查询服务器信息")
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type", "RequestServerList"))
  request.Handler = TGNetService.NetEventHanlderSelf(StartGameController.NetGetServerListHandler, self)
  TGNetService.GetInstance():SendRequest(request)
end

--网络 回调 获取服务器信息

function StartGameController:NetGetServerListHandler(e)
  if e.Type == "RequestServerList" then
    --print("获取服务器信息 成功")
    print("获取服务器信息 成功")
    print(e.Content:get_Item("Result"):ToString())
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      --上次登陆
      self.lastlogon = json.decode(e.Content:get_Item("LastLogon"):ToString())
      if self.lastlogon.Addr == "" then
        --print("self.lastlogon22222")
        self.lastlogon = nil
      end

      --曾经登陆
      local everservers = json.decode(e.Content:get_Item("EverLogon"):ToString())
      self.everLogon = {}
      if everservers ~= nil then
        for i = 1, #everservers do
          self.everLogon[i] = everservers[i]
        end
      end
      --推荐登录
      local suggservers = json.decode(e.Content:get_Item("Suggested"):ToString())
      self.suggestedserver = {}

      if suggservers ~= nil then
        for k, v in pairs(suggservers) do
          self.suggestedserver[k] = v
        end
      end
      --所有服务器
      local allservers = json.decode(e.Content:get_Item("All"):ToString())
      self.allserver = {}

      for k, v in pairs(allservers) do
        self.allserver[k] = v
      end
      --初始化
      self:Init()
    else
      Debugger.LogError("Failed to get server list")
    end
    return true
  end
  return false
end


--界面初始化
function StartGameController:Init()
  --主界面服务器信息显示
  self.panel["root"]:SetActive(true)
  if self.lastlogon ~= nil then
    --print("lastlogon111111111")
    self:ShowServerInfo(self.lastlogon)
  else
    if self.suggestedserver ~= nil and self.suggestedserver[1] ~= nil then
      self:ShowServerInfo(self.suggestedserver[1])
    else
      Debugger.LogError("No recommended server data")
    end
  end
end


--选择服务器
function StartGameController:ClickSelectServer(eventdata)
  self.panel["chooseserver"]:SetActive(true)
  self:InitServerUI()
end

--开始游戏
function StartGameController:ClickStartGame()
  if self.selectserver == nil then
    Debugger.LogError("No server selected.")
    return
  end
  GameManager.CreatePanel("Waiting")
  self:RequestUpdateAccountServer(self.selectserver.Id)
end

--告知服务器Id
function StartGameController:RequestUpdateAccountServer(serverId)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type", "RequestUpdateAccountServer"),
    JProperty.New("ServerId", tonumber(serverId)))
  request.Handler = TGNetService.NetEventHanlderSelf(StartGameController.RequestUpdateAccountServerHandler, self)
  TGNetService.GetInstance():SendRequest(request)
end

function StartGameController:RequestUpdateAccountServerHandler(e)
  if e.Type == "RequestUpdateAccountServer" then
    self:NetConnectServer(self.selectserver.Addr, tostring(self.selectserver.Port), StartGameController.NetConnectGameServerHandler)
    return true
  end
  return false
end

--连接服务器
function StartGameController:NetConnectServer(serverIp, serverPort, func)
  if func == nil then Debugger.LogError("连接服务器 回调函数为nil") end
  TGNetService.NewInstance()
  local handler = TGNetService.NetEventHanlderSelf(func, self)
  table.insert(self.HandlerTab, handler)
  TGNetService.GetInstance():AddEventHandler("Connect", handler, 0) --回调
  TGNetService.GetInstance():Start(serverIp, serverPort) --连接服务器
  GameManager.NetDispatcherHost:StartCoroutine(TGNetService.GetInstance():NetEventDispatcher())
end

--连接游戏服务器回调
function StartGameController:NetConnectGameServerHandler(e)
  if e.Type == "Connect" then
    --print("连接游戏服务器成功")
    self:NetGetAuth()
    return true
  end
  return false
end

--获取Auth 
function StartGameController:NetGetAuth()
  --print("获取Auth")
  UTGData.Instance().AccountId = self.AccountId
  UTGData.Instance().SessionKey = self.SessionKey
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type", "Auth"),
    JProperty.New("AccountId", self.AccountId),
    JProperty.New("SessionKey", self.SessionKey))
  request.Handler = TGNetService.NetEventHanlderSelf(StartGameController.NetGetAuthHandler, self)
  TGNetService.GetInstance():SendRequest(request)
end

--获取Auth 回调
function StartGameController:NetGetAuthHandler(e)
  if e.Type == "Auth" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      --print("获取Auth成功") 
      UTGData.Instance():UTGPlayerDetail(StartGameController.GetPlayerDetailDataHandler, self, StartGameController.GetPlayerDetailDataHandler1, self)
    elseif result == 0x0303 then
      --print("Session已过期")
      self.Delegate_ConnectToLoginServer = StartGameController.ReLoginToGetNewData
      self:ConnectToLoginServer()
    elseif result == 0x0304 then
      --print("Session无效")    
    end

    return true
  end
  return false
end

function StartGameController:ReLoginToGetNewData()

  NewLogin2API.Instance:ReLogin(StartGameController.SetNewSession, self)
end

function StartGameController:SetNewSession(accountId, session)
  self.AccountId = accountId
  self.SessionKey = session
  self:ClickStartGame()
end

--下载静态数据
function StartGameController:DownLoadData()
  local result = { Done = false }
  coroutine.start(StartGameController.DownLoadDataMov, self, result)
  return result
end

function StartGameController:DownLoadDataMov(result)
  GameManager.CreatePanel("Waiting")

  UTGData.Instance():GetResourceVersion()
  UTGData.Instance():UTGDataGetConfig()
  UTGData.Instance():UTGDataGetPlayerDeck()
  UTGData.Instance():UTGDataGetFriendList()
  UTGData.Instance():GetOtherData()
  while UTGData.LoadTemplate ~= true or UTGData.LoadPlayerDeck ~= true or UTGData.LoadConfig ~= true or UTGData.LoadFriendList ~= true do
    coroutine.wait(0.05)
  end

  local result_loadMainPanel = GameManager.CreatePanelAsync("UTGMain")
  while result_loadMainPanel.Done ~= true do
    coroutine.step()
  end

  if UTGMainPanelAPI.Instance ~= nil then
    UTGMainPanelAPI.Instance:HideSelf()
    UTGMainPanelAPI.Instance:AudioControl(0)
  end

  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type", "RequestAddOnlineStatus")) --报告玩家状态已在线
  self.IsOnline = false
  request.Handler = TGNetService.NetEventHanlderSelf(StartGameController.RequestAddOnlineStatusHandler, self)
  TGNetService.GetInstance():SendRequest(request)
  while self.IsOnline ~= true do
    coroutine.wait(0.05)
  end
  local result_mainInit = UTGMainPanelAPI.Instance:Init()
  while result_mainInit.Done ~= true do
    coroutine.wait(0.05)
  end

  UTGDataOperator.Instance:ReconnectOutside(StartGameController.ReconnectOutsideNormalHandler, self, StartGameController.ReconnectOutsideSpecialHandler, self)
  while self.ReconnectOutsideOver do
    coroutine.step()
  end

  UTGMainPanelAPI.Instance:ShowSelf()
  UTGMainPanelAPI.Instance:AudioControl(0.2)

  result.Done = true
  --删除登陆和选择服务器面板
  self:DestroyNow()
end

function StartGameController:RequestAddOnlineStatusHandler(e)
  if e.Type == "RequestAddOnlineStatus" then
    self.IsOnline = true
    return true
  end
  return false
end

--重连 （无需跳转）
function StartGameController:ReconnectOutsideNormalHandler()
  self.ReconnectOutsideOver = true
  --UTGDataOperator.Instance:LoadAssetAsync()
  UTGDataOperator.Instance:InitActivityPanel()
end

--重连 （需要跳转）
function StartGameController:ReconnectOutsideSpecialHandler()
  self.ReconnectOutsideOver = true
  if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end
end

function StartGameController:GetPlayerDetailDataHandler()
  --print("xxxxxxxxxxxxxx  "..UTGData.Instance().PlayerData.Id.."   "..UTGData.Instance().PlayerData.AccountId)
  self:DownLoadData()
end

--创建名字
function StartGameController:GetPlayerDetailDataHandler1()
  coroutine.start(StartGameController.CreateSetNamePanelMov, self)
end

--加载 战斗主界面协程
function StartGameController:CreateSetNamePanelMov()
  GameManager.CreatePanel("Waiting")
  local result = GameManager.CreatePanelAsync("CreatePlayer")
  while result.Done ~= true do
    --print("deng")
    coroutine.wait(0.05)
  end
  WaitingPanelAPI.Instance:DestroySelf()
  self:HideSelf()
end

function StartGameController:HideSelf() -- 隐藏登陆和选择服务器界面 
  NewLogin2API.Instance.this.gameObject:SetActive(false)
  self.panel["root"].gameObject:SetActive(false)
end

function StartGameController:DestroyNow() -- 删除登陆和选择服务器界面
  Object.Destroy(NewLogin2API.Instance.this.gameObject)
  Object.Destroy(self.this.gameObject)

  NTGResourceController.Instance:UnloadAssetBundle("StartGame", true, false)
  NTGResourceController.Instance:UnloadAssetBundle("NewLogin2", true, false)
  NTGResourceController.Instance:UnloadAssetBundle("bg-login", true, false)
end


--注销
function StartGameController:ClickReset()
  --self.Delegate_ConnectToLoginServer = StartGameController.ResetSucceed
  self:ConnectToLoginServer()
  self:ResetSucceed()
end

function StartGameController:ResetSucceed()
  if NewLogin2API ~= nil and NewLogin2API.Instance ~= nil then
    NewLogin2API.Instance:StartGameToHere()
  end
  GameObject.Destroy(self.this.gameObject)
end

--连接登陆服务器
function StartGameController:ConnectToLoginServer()

  self:NetConnectServer(UTGData.Instance().LoginServerIp, UTGData.Instance().LoginServerPort, StartGameController.ConnectToLoginServerHandler)
end

--连接登陆服务器 回调
function StartGameController:ConnectToLoginServerHandler(e)
  if e.Type == "Connect" then
    --print("连接登陆服务器成功")
    if self.Delegate_ConnectToLoginServer ~= nil and self ~= nil then
      self.Delegate_ConnectToLoginServer(self)
    end

    return true
  end
  return false
end

--选择服务器界面初始化
function StartGameController:InitServerUI()
  if self.serveruiload ~= true then
    self.serveruiload = true
  else
    return
  end

  self.rightserverlisAPI = self.this.transforms[9]:GetComponent("NTGLuaScript").self
  --排序
  self:SortServer(self.everLogon)
  self:SortServer(self.suggestedserver)
  self:SortServer(self.allserver)
  --初始化上次登陆
  if self.lastlogon ~= nil then
    self.lastserverui.gameObject:SetActive(true)
    local tempo = self.lastserverui
    tempo:FindChild("SequenceNumber"):GetComponent("UnityEngine.UI.Text").text = self.lastlogon.Prefix
    tempo:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = self.lastlogon.Name
    tempo:FindChild("State"):GetComponent("UnityEngine.UI.Image").sprite =
    NTGResourceController.Instance:LoadAsset("startgame", tostring("M003-ServerState" .. tostring(self.lastlogon.Status)), "UnityEngine.Sprite")
    if self.lastlogon.Suggested == 1 then
      tempo:FindChild("Recommend").gameObject:SetActive(true)
    else
      tempo:FindChild("Recommend").gameObject:SetActive(false)
    end
  else
    self.lastserverui.gameObject:SetActive(false)
  end
  --初始化左侧列表
  self:InitLeftServerLis()
  --默认第一次选中推荐服务器
  self.tempserverdata = {}
  self.tempserverdata = self.suggestedserver
  self:InitServerList(self.suggestedserver)
  self:ShowServerLisButLiang(self.but_suggser)
end

--复制服务器列表
function StartGameController:InitLeftServerLis()
  local listener = NTGEventTriggerProxy.Get(self.but_myser.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(StartGameController.ClickMyServer, self)
  listener = NTGEventTriggerProxy.Get(self.but_suggser.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(StartGameController.ClickSuggestServer, self)
  --所有服务器
  local yeshu = math.ceil(table.getn(self.allserver) / 10)
  --print(yeshu)
  for i = 1, yeshu do
    local tempo = GameObject.Instantiate(self.serverlistemp)
    tempo.gameObject:SetActive(true)
    tempo.name = i
    tempo.transform:SetParent(self.serverlisroot.transform)
    tempo.transform.localPosition = Vector3.zero
    tempo.transform.localRotation = Quaternion.identity
    tempo.transform.localScale = Vector3.one
    local str = tostring((i - 1) * 10 + 1) .. "区-" .. tostring(i * 10) .. "区"
    tempo:FindChild("txt"):GetComponent("UnityEngine.UI.Text").text = str
    tempo:FindChild("liang/txt"):GetComponent("UnityEngine.UI.Text").text = str
    --添加点击事件
    local listener = NTGEventTriggerProxy.Get(tempo.gameObject)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(StartGameController.ClickAllServer, self)
  end
end

--我的服务器
function StartGameController:ClickMyServer(eventdata)
  self.tempserverdata = {}
  self.tempserverdata = self.everLogon
  self:InitServerList(self.everLogon)
  self:ShowServerLisButLiang(eventdata.pointerPress)
end

--推荐服务器
function StartGameController:ClickSuggestServer(eventdata)
  self.tempserverdata = {}
  self.tempserverdata = self.suggestedserver
  self:InitServerList(self.suggestedserver)
  self:ShowServerLisButLiang(eventdata.pointerPress)
end

--分页服务器
function StartGameController:ClickAllServer(eventdata)
  local num = tonumber(eventdata.pointerPress.name)
  local a = 1
  self.tempserverdata = {}
  for i = (num - 1) * 10 + 1, #self.allserver do
    self.tempserverdata[a] = self.allserver[i]
    a = a + 1
  end
  self:InitServerList(self.tempserverdata)
  self:ShowServerLisButLiang(eventdata.pointerPress)
end

--只显示所选服务器列表选择按钮的亮边
function StartGameController:ShowServerLisButLiang(selectbut)
  for i = 1, self.serverlisroot.childCount do
    self.serverlisroot:GetChild(i - 1):FindChild("liang").gameObject:SetActive(false)
  end
  selectbut.transform:FindChild("liang").gameObject:SetActive(true)
end

--选择上次服务器
function StartGameController:ClickSelectLastServer(eventdata)
  --local index = tonumber(eventdata.pointerPress.name)
  self.selectserver = self.lastlogon
  self:ClickBackMainUI()
  self:ShowServerInfo(self.selectserver)
end

--在服务器列表中 选择服务器

function StartGameController:ClickSelectServerInList(eventdata)
  local index = tonumber(eventdata.pointerPress.name)
  self.selectserver = self.tempserverdata[index]
  self:ClickBackMainUI()
  self:ShowServerInfo(self.selectserver)
end

--生成服务器列表再右侧显示区域
function StartGameController:InitServerList(data)
  if data == nil then
    self.rightserverlisAPI:ResetItemsSimple(0)
    return
  end

  self.rightserverlisAPI:ResetItemsSimple(table.getn(data))
  for i = 1, #self.rightserverlisAPI.itemList do
    local tempo = self.rightserverlisAPI.itemList[i].transform
    tempo.name = tostring(i)
    tempo:FindChild("SequenceNumber"):GetComponent("UnityEngine.UI.Text").text = data[i].Prefix
    tempo:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = data[i].Name
    tempo:FindChild("State"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("startgame", tostring("M003-ServerState" .. tostring(data[i].Status)), "UnityEngine.Sprite")
    if data[i].Suggested == 1 then
      tempo:FindChild("Recommend").gameObject:SetActive(true)
    else
      tempo:FindChild("Recommend").gameObject:SetActive(false)
    end
    --添加点击事件
    local listener = NTGEventTriggerProxy.Get(tempo.gameObject)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(StartGameController.ClickSelectServerInList, self)
  end
end

--返回主界面

function StartGameController:ClickBackMainUI()
  self.panel["chooseserver"]:SetActive(false)
end

function StartGameController:SortServer(a)
  if a == nil then
    Debugger.LogError("服务器列表为空~~~")
    return
  end
  local function sort(a, b)
    return a.Order < b.Order
  end

  table.sort(a, sort)
end

function StartGameController:OnDestroy()
  for i = #self.HandlerTab, 1, -1 do
    TGNetService.GetInstance():RemoveEventHander("Connect", self.HandlerTab[i])
  end
  self.this = nil
  self = nil
end