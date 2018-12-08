--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
class("PVPHeroSelectChatCtrl")

local json = require "cjson"

function PVPHeroSelectChatCtrl:Awake(this)
  self.this = this

  self.click = this.transform:FindChild("Click")
  self.click.gameObject:SetActive(false)
  self.input = this.transform:FindChild("Input")
  self.temp_text = this.transform:FindChild("Input/Temp_Text")
  self.temp_text.gameObject:SetActive(false)

  self.prefabInfo = {"多发信号交流","我打野","我走中路","我打ADC","我打辅助",
  "来个坦克","来个射手","来个法师","来个刺客","来个辅助","注意阵容搭配","交个朋友吧~"}

end

function PVPHeroSelectChatCtrl:Start()
  
end

function PVPHeroSelectChatCtrl:Init(partyId)
  UTGDataOperator.Instance:SetChatList(self)
  self.partyId = tonumber(partyId)
  self.click.gameObject:SetActive(true)
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.click:FindChild("Click").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectChatCtrl.ClickOpenInput,self)
  listener = NTGEventTriggerProxy.Get(self.input:FindChild("Click").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectChatCtrl.ClickCloseInput,self)
  listener = NTGEventTriggerProxy.Get(self.input:FindChild("List/But_ChatInfo").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectChatCtrl.ClickInputListBut,self)
  listener = NTGEventTriggerProxy.Get(self.input:FindChild("List/But_ChatLog").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectChatCtrl.ClickInputListBut,self)

  self.inputField = self.input:FindChild("InputField"):GetComponent("UnityEngine.UI.InputField")
  self.inputField.onValidateInput = UnityEngine.UI.InputField.OnValidateInputSelf(self.MonitorInput,self)

  listener = NTGEventTriggerProxy.Get(self.input:FindChild("But_Submit").gameObject) 
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickSubmit,self)

  self.click_text = self.click:FindChild("Text")
  self.input_scroll_info = self.input:FindChild("List/Scroll_ChatInfo")
  self.input_scroll_log = self.input:FindChild("List/Scroll_ChatLog")
  --填入默认话语
  for i=1,#self.prefabInfo do
    self:InitScrollInfoText(self.prefabInfo[i],self.input_scroll_info)
  end
  
end
--接收聊天消息
function PVPHeroSelectChatCtrl:PushChatInfo(e)
  local chatmes = json.decode(e.Content:get_Item("ChatMessage"):ToString())
  local channel = chatmes.MessageChannel
  if channel~=5 then return end --过滤不是队伍聊天的信息

  local playerid = chatmes.Sender.PlayerId
  local playername = chatmes.Sender.PlayerName
  local mestype = tonumber(chatmes.MessageType)
  local mes = tostring(chatmes.Message)
  local data = {}
  --PlayerId
  data.PlayerId = playerid
  --PlayerName
  data.PlayerName = playername
  --信息
  data.Message = mes
  --信息，详细
  data.MessageDetail = string.format("%s:%s",data.PlayerName,data.Message)
  self:UpdateData(data)

end
--------接口--------

--更新数据
function PVPHeroSelectChatCtrl:UpdateData(data)
  self.click_text:GetComponent("UnityEngine.UI.Text").text = data.MessageDetail
  self:InitScrollLogText(data,self.input_scroll_log)
  if PVPHeroSelectAPI~=nil and PVPHeroSelectAPI.Instance~=nil then 
    PVPHeroSelectAPI.Instance:SetPlayerChat(data)
  end
  if DraftHeroSelectAPI~=nil and DraftHeroSelectAPI.Instance~=nil then 
    DraftHeroSelectAPI.Instance:SetPlayerChat(data)
  end
end


--------------------

--聊天记录
function PVPHeroSelectChatCtrl:InitScrollLogText(data,scroll)
  local temp = self:CreateScrollText(scroll)
  temp:FindChild("Text"):GetComponent("UnityEngine.UI.Text").text = data.MessageDetail
  temp:FindChild("Click").gameObject:SetActive(false)
end
--聊天信息选择
function PVPHeroSelectChatCtrl:InitScrollInfoText(text,scroll)
  local temp = self:CreateScrollText(scroll)
  temp:FindChild("Text"):GetComponent("UnityEngine.UI.Text").text = text
  temp:FindChild("Click").gameObject:SetActive(true)
  UITools.GetLuaScript(temp:FindChild("Click").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickInfoText,text)
end

function PVPHeroSelectChatCtrl:CreateScrollText(scroll)
  local temp = GameObject.Instantiate(self.temp_text)
  temp.name = "text"
  temp.gameObject:SetActive(true)
  temp.transform:SetParent(scroll:FindChild("Grid"))
  temp.transform.localPosition = Vector3.zero
  temp.transform.localRotation = Quaternion.identity
  temp.transform.localScale = Vector3.one
  return temp
end
--
function  PVPHeroSelectChatCtrl:ClickInfoText(text)
  if self.coroutine_inputtip~=nil then
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("您说话太快了，请稍等哟~")
    return
  end
  self:RequestSendTrialPartyChatMessage(self.partyId,1,text)
  self:InputCD()
end

--队伍聊天
function PVPHeroSelectChatCtrl:RequestSendTrialPartyChatMessage(partyid,mestype,mes)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSendTrialPartyChatMessage"),
                                JProperty.New("TrialpartyId",tonumber(partyid)),
                                JProperty.New("MessageType",tonumber(mestype)),
                                JProperty.New("Message",tostring(mes)))
  request.Handler = TGNetService.NetEventHanlderSelf(self.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
function PVPHeroSelectChatCtrl:RequestHandler(e)
  if e.Type =="RequestSendTrialPartyChatMessage" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      Debugger.LogError("RequestSendTrialPartyChatMessage Result == "..0)
    elseif result == 1 then
    end
    return true
  end
  return false
end


--打开聊天
function PVPHeroSelectChatCtrl:ClickOpenInput()
  self.input.gameObject:SetActive(true)
  self.click.gameObject:SetActive(false)
end
--关闭聊天
function PVPHeroSelectChatCtrl:ClickCloseInput()
  self.input.gameObject:SetActive(false)
  self.click.gameObject:SetActive(true)
end
--点击聊天列表左侧按钮
function PVPHeroSelectChatCtrl:ClickInputListBut(eventdata)
  local temp = eventdata.pointerPress.transform
  local liang = temp:FindChild("Liang")
  if liang.gameObject.activeSelf then return end
  liang.gameObject:SetActive(true)
  if temp.name == "But_ChatInfo" then
    self.input:FindChild("List/But_ChatLog/Liang").gameObject:SetActive(false)
    self.input_scroll_info.gameObject:SetActive(true)
    self.input_scroll_log.gameObject:SetActive(false)
  else
    self.input:FindChild("List/But_ChatInfo/Liang").gameObject:SetActive(false)
    self.input_scroll_log.gameObject:SetActive(true)
    self.input_scroll_info.gameObject:SetActive(false)
  end
end


--输入CD 
function PVPHeroSelectChatCtrl:InputCD()
  if self.coroutine_inputtip ~= nil then coroutine.stop(self.coroutine_inputtip) end
  self.coroutine_inputtip = coroutine.start(self.InputCDMov,self)
end
function PVPHeroSelectChatCtrl:InputCDMov()
  coroutine.wait(5)
  self.coroutine_inputtip = nil
end

--监控输出的情况
function PVPHeroSelectChatCtrl:MonitorInput(text,charindex,addchar)
  local str = tostring(text..tolua.chartolstring(addchar))
  if UTGData.Instance():StringLength(str) > 20 then 
    return 0
  end
  return addchar
end

--提交输入
function PVPHeroSelectChatCtrl:ClickSubmit()
  local text = {}
  --Debugger.LogError(text)
  text = self.inputField.text
  if text == "" then 
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不能发送空的内容哦")
    return
  end
  if self.coroutine_inputtip~=nil then
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("您说话太快了，请稍等哟~")
    return
  end
  self:RequestSendTrialPartyChatMessage(self.partyId,1,text)
  self.inputField.text = ""
  self:InputCD()
end

function PVPHeroSelectChatCtrl:OnDestroy()
  if self.coroutine_inputtip ~= nil then coroutine.stop(self.coroutine_inputtip) end
  self.this = nil
  self = nil
end