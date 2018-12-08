--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("ChatInBattleAPI")
local json = require "cjson"

function ChatInBattleAPI:Awake(this)
  self.this = this
  ChatInBattleAPI.Instance = self
  local listener = {}
  self.SendMesPanel = this.transforms[0]
  self.Info = this.transforms[1]
  self.Main = this.transforms[2]
  self.Main.gameObject:SetActive(true)
  self.main_grid = self.Main:FindChild("Grid")
  self.inputField = self.Main:FindChild("InputField"):GetComponent("UnityEngine.UI.InputField")
  
  --监听战斗中聊天信息
  self.Delegate_QuickMessage = TGNetService.NetEventHanlderSelf(self.UpdateChatData,self)
  TGNetService.GetInstance():AddEventHandler("NoticyChatQuickMessage",self.Delegate_QuickMessage,1)
  self.Delegate_Message = TGNetService.NetEventHanlderSelf(self.UpdateChatData,self)
  TGNetService.GetInstance():AddEventHandler("NoticyChatBattleMessage",self.Delegate_Message,1)

  listener = NTGEventTriggerProxy.Get(self.SendMesPanel:FindChild("But_Open/Button").gameObject) 
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(self.OpenMainPanel,self)

  self.CDTip = self.SendMesPanel:FindChild("But_Open/Cd")
  self.CDTip.gameObject:SetActive(false)

  self.coroutine_log = {}
end

-----------------API-----------------
function ChatInBattleAPI:SetMainPos(tran)
  self.SendMesPanel.transform:SetParent(tran)
  self.SendMesPanel.transform.localPosition = Vector3.zero
  self.SendMesPanel.transform.localRotation = Quaternion.identity
  self.SendMesPanel.transform.localScale = Vector3.one
end
function ChatInBattleAPI:SetInfoPos(tran)
  self.Info.transform:SetParent(tran)
  self.Info.transform.localPosition = Vector3.zero
  self.Info.transform.localRotation = Quaternion.identity
  self.Info.transform.localScale = Vector3.one
end

function ChatInBattleAPI:OpenMainPanel()
  self.Main.gameObject:SetActive(true)
end

function ChatInBattleAPI:Start()
  self:InitMain()
  self:InitInfo()
end

function ChatInBattleAPI:GetDefaultPrefabInfo( )
  local prefabInfo = {}
  local defaultIds = {}
  local str = UTGData.Instance().ConfigData["chat_default_quick_message"].String
  defaultIds = UTGData:StringSplit(str,",")
  local data = UTGData.Instance().QuickMessagesData
  for k,v in pairs(defaultIds) do
    if data[tostring(v)] ~=nil then 
      table.insert(prefabInfo,data[tostring(v)])
    end
  end
  return prefabInfo
end

function ChatInBattleAPI:InitMain()
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.Main:FindChild("But_Close").gameObject) 
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickCloseMainPanel,self)

  self.inputField.onValidateInput = UnityEngine.UI.InputField.OnValidateInputSelf(self.MonitorInput,self)
  listener = NTGEventTriggerProxy.Get(self.inputField.gameObject) 
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(self.MonitorInputFocus,self)

  self.chatMode = "My"
  listener = NTGEventTriggerProxy.Get(self.Main:FindChild("But_Mode").gameObject) 
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickSelectMode,self)

  self.prefabInfoData = self:GetDefaultPrefabInfo()
  self:InitPrefabInfo(self.prefabInfoData)
  self.Main.gameObject:SetActive(false)

end

--设置提示语句
function ChatInBattleAPI:InitPrefabInfo(data)
  local api = self.main_grid:GetComponent("NTGLuaScript").self
  if data==nil then
    api:ResetItemsSimple(0)
    Debugger.LogError("没有玩家数据")
    return
  end
  api:ResetItemsSimple(#data)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform
    tempo:FindChild("Text"):GetComponent("UnityEngine.UI.Text").text = data[i].Desc
    UITools.GetLuaScript(tempo.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickPrefabInfo,i)
  end
end
--选择提示语句
function ChatInBattleAPI:ClickPrefabInfo(id)
  self:RequestSendBattleQuickMessage(id)
end

--切换全体/我方
function ChatInBattleAPI:ClickSelectMode(eventdata)
  local temp = eventdata.pointerPress.transform
  if self.chatMode == "My" then 
    temp:FindChild("My").gameObject:SetActive(false)
    temp:FindChild("All").gameObject:SetActive(true)
    self.chatMode = "All"
  else
    temp:FindChild("My").gameObject:SetActive(true)
    temp:FindChild("All").gameObject:SetActive(false)
    self.chatMode = "My"
  end
end
--点击预制信息 发送
function ChatInBattleAPI:ClickPrefabInfo(index)
  index = tonumber(index)
  local id = self.prefabInfoData[index].Id
  self:RequestSendBattleQuickMessage(id)
end

--
function ChatInBattleAPI:InitInfo( )
  self.temp_text = self.Info:FindChild("Temp_Text")
  self.temp_text.gameObject:SetActive(false)
  self.info_grid = self.Info:FindChild("Grid")
end

function ChatInBattleAPI:SetLogInfo(text)
  local temp = GameObject.Instantiate(self.temp_text)
  temp.name = "LogInfo"
  temp.gameObject:SetActive(true)
  temp.transform:SetParent(self.info_grid)
  temp.transform.localPosition = Vector3.zero
  temp.transform.localRotation = Quaternion.identity
  temp.transform.localScale = Vector3.one
  temp:GetComponent("UnityEngine.UI.Text").text = tostring(text)
  local cor = coroutine.start(self.LogInfoMov,self,temp.transform)
  table.insert(self.coroutine_log,cor)
end

function ChatInBattleAPI:LogInfoMov(tran)
  coroutine.wait(10)
  Object.Destroy(tran.gameObject)
end


--快捷聊天
function ChatInBattleAPI:RequestSendBattleQuickMessage(mesId)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSendBattleQuickMessage"),
                                JProperty.New("QuickMessageId",tonumber(mesId)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChatInBattleAPI.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
--打字聊天
function ChatInBattleAPI:RequestSendBattleMessage(sendtype,mes)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSendBattleMessage"),
                                JProperty.New("SendType",tonumber(sendtype)),
                                JProperty.New("Message",tostring(mes)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChatInBattleAPI.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
function ChatInBattleAPI:RequestHandler(e)
  if e.Type =="RequestSendBattleQuickMessage" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      print("RequestSendBattleQuickMessage 发送 失败")
    elseif result == 0x0003 then
      print("RequestSendBattleQuickMessage 客户端参数有误(通用)")
    elseif result == 0x0905 then
      print("RequestSendBattleQuickMessage 不在战斗中")
    elseif result == 1 then
      self:ClickCloseMainPanel()
      self:StartMessageCd(5)
    end
    return true
  end
  if e.Type =="RequestSendBattleMessage" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      print("RequestSendBattleMessage 发送 失败")
    elseif result == 0x0003 then
      print("RequestSendBattleMessage 客户端参数有误(通用)")
    elseif result == 0x0905 then
      print("RequestSendBattleMessage 不在战斗中")
    elseif result == 1 then
      self:ClickCloseMainPanel()
    end
    return true
  end
  return false
end

function ChatInBattleAPI:UpdateChatData(e)
  if e.Type == "NoticyChatQuickMessage" then
    local chatmes = json.decode(e.Content:get_Item("ChatQuickMessage"):ToString())
    local playerId = tonumber(chatmes.SenderId)
    local bubbleMes = tostring(chatmes.BubbleContent)
    local noticeMes = tostring(chatmes.NoticeContent)

    --Debugger.LogError(playerId.." bubbleMes = "..bubbleMes.." noticeMes = "..noticeMes.." ")
    
    if bubbleMes ~= "" then
      self.this:InvokeDelegate(self.SendQuickMessageDelegate,playerId,1,bubbleMes)
    end
    if noticeMes ~= "" then
      self.this:InvokeDelegate(self.SendQuickMessageDelegate,playerId,2,noticeMes)
    end

    --playerId:玩家id type:(1:气泡聊天 2:公告聊天)
    --self.this:InvokeDelegate(self.SendQuickMessageDelegate,playerId,Mes)

    return true
  end
  if e.Type == "NoticyChatBattleMessage" then
    local chatmes = json.decode(e.Content:get_Item("BattleMessage"):ToString())
    local playerId = tonumber(chatmes.SenderId)
    local playerName = tostring(chatmes.SenderName)
    local roleName = tostring(chatmes.SenderRoleName)
    local mes = tostring(chatmes.Message)
    local sendtype = tonumber(chatmes.SendType)

    local text = ""
    if sendtype == 1 then --我方
      text = string.format("<color=#3CD4E1FF>%s（%s）：</color>%s",playerName,roleName,mes)
    elseif sendtype == 2 then --全部
      text = string.format("<color=#FF0800FF>【全部】%s（%s）：</color>%s",playerName,roleName,mes)
    end
    self:UpdateInfo(text)
    return true
  end

  return false
end

------------------------------注册-------------------------------------
function ChatInBattleAPI:RegisterDelegateSendQuickMessage(delegate)
  self.SendQuickMessageDelegate = delegate
end

function ChatInBattleAPI:StartMessageCd(cdtime)
  self.coroutine_inputcd = coroutine.start(self.MessageCdMov,self,cdtime)
end
function ChatInBattleAPI:MessageCdMov(cdtime)
  self.CDTip.gameObject:SetActive(true)
  self.CDTip:GetComponent("UnityEngine.UI.Image").fillAmount = 1
  local time = 0
  while time<cdtime do 
    coroutine.step()
    self.CDTip:GetComponent("UnityEngine.UI.Image").fillAmount = 1-time/cdtime
    time = time+Time.deltaTime
  end
  self.CDTip.gameObject:SetActive(false)
end

function ChatInBattleAPI:UpdateInfo(text)
  self:SetLogInfo(text)
end

--监控输出的情况
function ChatInBattleAPI:MonitorInput(text,charindex,addchar)
  local str = tostring(text..tolua.chartolstring(addchar))
  if UTGData.Instance():StringLength(str) > 15 then 
    return 0
  end
  return addchar
end

function ChatInBattleAPI:MonitorInputFocus()
  if self.coroutine_inputfocus~=nil then 
    coroutine.stop(self.coroutine_inputfocus)
  end
  self.coroutine_inputfocus = coroutine.start(self.MonitorInputFocusMov,self)
end
function ChatInBattleAPI:MonitorInputFocusMov()
  while self.inputField.isFocused == true do
    coroutine.step()
  end
  --Debugger.LogError(self.inputField.text)
  local text = self.inputField.text
  local sendtype = 0 
  if self.chatMode == "My" then 
    sendtype = 1
  elseif self.chatMode == "All" then
    sendtype = 2
  end
  self:RequestSendBattleMessage(sendtype,text)
  self.inputField.text = ""
end


--退出
function ChatInBattleAPI:ClickCloseMainPanel()
  self.Main.gameObject:SetActive(false)
end

function ChatInBattleAPI:OnDestroy()
  for k,v in pairs(self.coroutine_log) do 
    coroutine.stop(v)
  end
  coroutine.stop(self.coroutine_inputfocus)
  coroutine.stop(self.coroutine_inputcd)
  
  TGNetService.GetInstance():RemoveEventHander("NoticyChatQuickMessage",self.Delegate_QuickMessage)
  TGNetService.GetInstance():RemoveEventHander("NoticyChatBattleMessage",self.Delegate_Message)
  self.this = nil
  ChatInBattleAPI.Instance = nil
  self = nil
end