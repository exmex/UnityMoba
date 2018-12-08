--author zx
require "System.Global"
--require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("RunePageChangeNameAPI")
--local json = require "cjson"

function RunePageChangeNameAPI:Awake(this)
  self.this = this
  RunePageChangeNameAPI.Instance = self
  local listener = {}
  listener = NTGEventTriggerProxy.Get(this.transforms[0].gameObject)--取消
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(RunePageChangeNameAPI.ClickCancel,self) 
  listener = NTGEventTriggerProxy.Get(this.transforms[1].gameObject)--确定
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(RunePageChangeNameAPI.ClickOk,self) 
  self.inputField = this.transforms[2]:GetComponent("UnityEngine.UI.InputField")
  self.txtname = ""
  self.runePageId = 0
end

function RunePageChangeNameAPI:Start()

end

function RunePageChangeNameAPI:SetParamBy69(runePageDeckId,runePageName)
  --Debugger.LogError("runePageDeckId= "..runePageDeckId.." runePageName = "..runePageName)
  self.runePageId = tonumber(runePageDeckId)
  self.txtname = tostring(runePageName)
  self.inputField.text = ""..self.txtname 
end


function RunePageChangeNameAPI:ClickOk()
	print("更换芯片组名称")
	local newName = self.inputField.text
	if newName == self.txtname then 
		self:ClickCancel() 
	elseif newName == "" then
		GameManager.CreatePanel("SelfHideNotice")
		SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("芯片组名字不能为空")
		self:ClickCancel()
	elseif self:utfstrlen(newName)>6 then
		GameManager.CreatePanel("SelfHideNotice")
		SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("芯片组名字长度不能超过6个字")
		self:ClickCancel()
	else
		self:NetRunePageChangeName(self.runePageId,newName)
	end
end

--获取utf格式的字符串长度
function RunePageChangeNameAPI:utfstrlen(str)
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

--网络 芯片组改名
function RunePageChangeNameAPI:NetRunePageChangeName(deckid,name)
	local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestRenameRunePage"),
  							JProperty.New("RunePageDeckId",deckid),
  							JProperty.New("Name",name))
  request.Handler = TGNetService.NetEventHanlderSelf(RunePageChangeNameAPI.NetRunePageChangeNameHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end

function RunePageChangeNameAPI:NetRunePageChangeNameHandler(e)
  if e.Type == "RequestRenameRunePage" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result ==1 then 
    	self:ClickCancel()
    end
    return true
  end
  return false
end

function RunePageChangeNameAPI:ClickCancel()
	Object.Destroy(self.this.gameObject)
end

function RunePageChangeNameAPI:OnDestroy()
  self.this = nil
  self = nil
end