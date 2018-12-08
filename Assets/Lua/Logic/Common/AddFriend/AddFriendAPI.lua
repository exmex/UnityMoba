--author zx
require "System.Global"
class("AddFriendAPI")

function AddFriendAPI:Awake(this)
  AddFriendAPI.Instance = self
  self.this = this
  self.Input_friend = self.this.transform:FindChild("input")

  local listener = NTGEventTriggerProxy.Get(self.this.transform:FindChild("close").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(AddFriendAPI.ClosePanel,self)

  listener = NTGEventTriggerProxy.Get(self.this.transform:FindChild("but_ok").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(AddFriendAPI.ClickAddFriend,self)
end

function AddFriendAPI:Start()

end

function AddFriendAPI:SetPlayerId(id)
	self.playerId = tonumber(id)
end

function AddFriendAPI:ClickAddFriend()
	local info = self.Input_friend:GetComponent("UnityEngine.UI.InputField").text
  	--Debugger.LogError(info)
  	if self:utfstrlen(info)>15 then
    	return
  	else
    	self:RequestSendFriendApplication(self.playerId,info)
    	self:ClosePanel()
  	end
end

--获取utf格式的字符串长度
function AddFriendAPI:utfstrlen(str)
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

function AddFriendAPI:RequestSendFriendApplication(playerId,mes)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSendFriendApplication"),
                                JProperty.New("TargetPlayerId",tonumber(playerId)),
                                JProperty.New("Message",tostring(mes)))
  request.Handler = TGNetService.NetEventHanlderSelf(self.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
function AddFriendAPI:RequestHandler(e)
  if e.Type =="RequestSendFriendApplication" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      Debugger.LogError("RequestSendFriendApplication Result == "..0)
    elseif result == 1 then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("发送好友请求成功")
    elseif result == 1537 then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("好友请求已发送")
    end
    return true
  end
  return false
end

function AddFriendAPI:ClosePanel()
	Object.Destroy(self.this.gameObject)
end

function AddFriendAPI:OnDestroy()
  self.this = nil
  self = nil
  AddFriendAPI.Instance = nil
end
