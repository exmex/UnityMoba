--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("ChatHornAPI")
local json = require "cjson"

function ChatHornAPI:Awake(this)
  self.this = this
  ChatHornAPI.Instance = self

  local listener = {}

  self.Title = this.transform:FindChild("Title")
  self.Tip = this.transform:FindChild("Tip")

  self.Input = this.transform:FindChild("InputField"):GetComponent("UnityEngine.UI.InputField")


  listener = NTGEventTriggerProxy.Get(this.transform:FindChild("Close").gameObject) 
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChatHornAPI.ClickClosePanel,self)
  listener = NTGEventTriggerProxy.Get(this.transform:FindChild("Submit").gameObject) 
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChatHornAPI.ClickSubmit,self)

  --输入
  self.Input.onValidateInput = UnityEngine.UI.InputField.OnValidateInputSelf(ChatHornAPI.MonitorInput,self)

  self.TextLimit = 0
  self.ItemId = 0
end

function ChatHornAPI:Start()

end

function ChatHornAPI:Init(horntype,itemId)
  horntype = tostring(horntype)
  self.ItemId = tonumber(itemId)
  self.Title:FindChild(horntype).gameObject:SetActive(true)
  if horntype == "Big" then 
    self.TextLimit = 50
    self.MesType = 5
  elseif horntype == "Small" then 
    self.TextLimit = 30
    self.MesType = 4
  end
  --self:UpdateTip()
end

function ChatHornAPI:UpdateTip()
  local textcount = 0
  if self.Input.text~="" then 
    textcount = self:UtfStrLen(self.Input.text)
  end
  local remindcount = self.TextLimit - textcount - 1
  self.Tip:GetComponent("UnityEngine.UI.Text").text = string.format("您还可以输入%s个字",remindcount)
end

--世界聊天
function ChatHornAPI:RequestSendPublicChatMessage(mestype,mes)
  if self.wait == true then return end
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSendPublicChatMessage"),
                                JProperty.New("MessageType",tonumber(mestype)),
                                JProperty.New("Message",tostring(mes)))
  request.Handler = TGNetService.NetEventHanlderSelf(self.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self.wait = true
end

function ChatHornAPI:RequestHandler(e)
  if e.Type =="RequestSendPublicChatMessage" then
    self.wait = false
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      Debugger.LogError("RequestSendPublicChatMessage Result == "..0)
    elseif result == 1 then
      self:ClickClosePanel()
    elseif result == 0x0901 then
      print("发送间隔过短")
    end
    return true
  end
end


--获取utf格式的字符串长度
function ChatHornAPI:UtfStrLen(str)
  local len = #str;
  local left = len;
  local cnt = 0;
  local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
  while left ~= 0 do
    local tmp=string.byte(str,-left);
    local i=#arr;
    while arr[i] do
      if tmp>=arr[i] then left=left-i;break;end
      i=i-1;
    end
    cnt=cnt+1;
  end
  return cnt;
end

--监控输出的情况
function ChatHornAPI:MonitorInput(text,charindex,addchar)
  local str = tostring(text..tolua.chartolstring(addchar))
  if self:UtfStrLen(str) > self.TextLimit then
    --[[
    if self.api_notice == nil then 
      local instance = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
      instance:InitNoticeForNeedConfirmNotice("提示", "最大输入字数20个", false, "", 1)
      instance:OneButtonEvent(ChatHornAPI.DestroyNotice, self)
      self.api_notice = instance
    end
    ]] 
    return 0
  end
  self:UpdateTip()
  return addchar
end

--关闭提示框 
function ChatHornAPI:DestroyNotice()
  self.api_notice:DestroySelf()
  self.api_notice = nil
end
  
--提交输入
function ChatHornAPI:ClickSubmit()
  local text = {}
  --Debugger.LogError(text)
  text = self.Input.text
  if text == "" then 
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不能发送空的内容哦")
    return
  end
  --Debugger.LogError(self.ItemId)
  UTGDataOperator.Instance:UseItem(self.ItemId,1,self.UseItemHandler,self)
  self:RequestSendPublicChatMessage(self.MesType,text)
  --self:RequestSendPublicChatMessage(self.MesType,text)
  --self.Input.text = ""
end
function ChatHornAPI:UseItemHandler()
  --self:ClickClosePanel()
end


--退出
function ChatHornAPI:ClickClosePanel()
  Object.Destroy(self.this.gameObject)
end


function ChatHornAPI:OnDestroy()
  self.this = nil
  ChatHornAPI.Instance = nil
  self = nil
end