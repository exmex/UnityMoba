--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
require "Logic.UICommon.Static.UITools"
--require "Logic.UTGData.UTGDataTemporary"
class("ChatCtrl")
local json = require "cjson"

function ChatCtrl:Awake(this)
  self.this = this
  local listener = {}
  --Main 
  self.Main = this.transforms[0]
  local main = self.Main:FindChild("Main")
  self.window_grid = main:FindChild("Grid_Window")
  self.window_friend = main:FindChild("Window_Friend")
  self.window_friend.gameObject:SetActive(false)
  self.window_guildRecruit = main:FindChild("Window_GuildRecruit")
  self.window_guildRecruit.gameObject:SetActive(false)

  self.scroll_lineY = main:FindChild("Line").position.y

  self.typeButtonGrid = main:FindChild("Type")
  self.HornButs = main:FindChild("Horn")
  self.HornButs.gameObject:SetActive(false)

  self.temp_window = main:FindChild("Temp_Window")
  self.temp_playericon = main:FindChild("Temp_PlayerIcon")
  self.temp_chat_my = main:FindChild("Temp_My")
  self.temp_chat_other = main:FindChild("Temp_Other")
  self.temp_chat_sys = main:FindChild("Temp_Sys")
  self.temp_chat_time = main:FindChild("Temp_Time")
  self.temp_friend = main:FindChild("Temp_Friend")
  self.temp_guildRecruit = main:FindChild("Temp_GuildRecruit")

  self.chat_bighorn = main:FindChild("Horn_Big/Main")
  self.chat_bighorn.gameObject:SetActive(false)


  listener = NTGEventTriggerProxy.Get(this.transforms[2].gameObject) 
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChatCtrl.ClickCloseMainPanel,self)
  
  --OutSide
  self.OutSide = this.transforms[1]
  local outside = self.OutSide
  self.OutSide_Horn = outside:FindChild("Horn")
  self.OutSide_Common = outside:FindChild("Common")

  self.myPlayerId = UTGData.Instance().PlayerData.Id
  self.coroutine_bighorn = nil
  self.coroutine_smallhorn = nil
  self.coroutine_inputtip = nil
  self.currChannel = ""
  self.currInputParam = {}
  self.ChatTips = {}
  self.ChatData = {}
  self.FriendTipCount = 0
  self.panel_playerinfo = GameManager.CreatePanel("PlayerInfoOnChart")
  self.ani_main = self.Main:GetComponent("Animator")

  self.Delegate_NotifyChatGuildInvitationMessage = TGNetService.NetEventHanlderSelf(self.NotifyChatGuildInvitationMessage,self)
  TGNetService.GetInstance():AddEventHandler("NotifyChatGuildInvitationMessage",self.Delegate_NotifyChatGuildInvitationMessage,1)
end

function ChatCtrl:Start()
  self.self_playerinfo = self.panel_playerinfo:GetComponent("NTGLuaScript").self
  self.self_playerinfo:SetPos(self.this.transform)
end

function ChatCtrl:InitChat(tran_outside,tran_main,panelname,param)
  param = param or {}
  UTGDataOperator.Instance:SetChatList(self)
  self.OutSide.transform:SetParent(tran_outside)
  self.OutSide.transform.localPosition = Vector3.zero
  self.OutSide.transform.localRotation = Quaternion.identity
  self.OutSide.transform.localScale = Vector3.one

  self.this.transform:SetParent(tran_main)
  self.this.transform.localPosition = Vector3.zero
  self.this.transform.localRotation = Quaternion.identity
  self.this.transform.localScale = Vector3.one

  if panelname == "UTGMain" then 
    self.MainType = "All"
    self.MainFilter = {1,2,3}
    self.OutSideFilter = {1,2,3}
  elseif panelname == "15Party" then
    self.MainType = "Party"
    self.MainFilter = {5,2}
    self.OutSideFilter = {1,5,2}
    self.currInputParam.PartyId = param.PartyId
  elseif panelname == "15Room" then
    self.MainType = "Room"
    self.MainFilter = {4,2}
    self.OutSideFilter = {1,4,2}
    self.currInputParam.RoomId = param.RoomId
  elseif panelname == "BattleResult" then
    self.MainType = "BattleRoom"
    self.MainFilter = {6}
    self.OutSideFilter = {1,6}
  end 


  self:Init()
end

--Main 过滤数据
function ChatCtrl:IsFilterMain(channel)
  for k,v in pairs(self.MainFilter) do
    if tonumber(channel) == tonumber(v) then 
      return true
    end
  end
  return false
end
--Out 过滤数据
function ChatCtrl:IsFilterOutSide(channel)
  for k,v in pairs(self.OutSideFilter) do
    if tonumber(channel) == tonumber(v) then 
      return true
    end
  end
  return false
end
--初始化
function ChatCtrl:Init()
  self:InitOutSide()
  self:InitMain()
  self.Main.gameObject:SetActive(false)
end
--初始化外面
function ChatCtrl:InitOutSide()
  self.OutSide_Common:FindChild("Txt"):GetComponent("UnityEngine.UI.Text").text = "点击这里开始聊天"
  self.OutSide_Common:FindChild("0").gameObject:SetActive(true)
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.OutSide:FindChild("Click").gameObject) 
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChatCtrl.ClickOpenMainPanel,self)
  listener = NTGEventTriggerProxy.Get(self.OutSide:FindChild("Tip").gameObject) 
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChatCtrl.ClickOutSideTip,self)
end
--刷新
function ChatCtrl:UpdateOutSide(data)
  if data~=nil then
    if self:IsFilterOutSide(data.Channel) == false then return end
    local channel = data.Channel
    local text = string.format("%s: %s",data.Player.PlayerName,data.Message) 
    local grid = self.OutSide_Common:FindChild("Grid")
    local txt = self.OutSide_Common:FindChild("Txt")
    if data.IsSmallHorn == true then 
      if self.coroutine_smallhorn~=nil then 
        coroutine.stop(self.coroutine_smallhorn)
        self.OutSide_Horn.gameObject:SetActive(false)
      end
      self.coroutine_smallhorn = coroutine.start(ChatCtrl.OutSideSmallHornMov,self,text)
    elseif data.IsBigHorn == true then 
      if UTGMainPanelAPI~=nil and UTGMainPanelAPI.Instance~=nil then 
        UTGMainPanelAPI.Instance:BigHornMove(text)
      end
    elseif data.IsSys == false then
      self.OutSide_Common:FindChild("0").gameObject:SetActive(false)
      for i=grid.childCount-1,0,-1 do
        grid:GetChild(i).gameObject:SetActive(false)
      end      
      grid:FindChild(tostring(channel)).gameObject:SetActive(true)
      txt:GetComponent("UnityEngine.UI.Text").text = tostring(text)
    end
  end
  self:UpdateOutSideTip(self.FriendTipCount)
end


--外面小喇叭
function ChatCtrl:OutSideSmallHornMov(text)
  local time = 0
  self.OutSide_Horn.gameObject:SetActive(true)
  self.OutSide_Common.gameObject:SetActive(false)
  local txt = self.OutSide_Horn:FindChild("Mask/Txt")
  txt:GetComponent("UnityEngine.UI.Text").text = text
  local startpos = Vector3.New(240,0,0)
  txt.localPosition = startpos
  coroutine.wait(0.5)
  local temp = -(240+(txt:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.x))
  --Debugger.LogError(temp.." "..(txt:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.x))
  while time<15 do 
    coroutine.step()
    txt.localPosition = txt.localPosition + Vector3.New(-0.5,0,0)
    if txt.localPosition.x <= temp then 
      txt.localPosition = startpos
    end
    time = time+Time.deltaTime
  end
  self.OutSide_Horn.gameObject:SetActive(false)
  self.OutSide_Common.gameObject:SetActive(true)
  self.coroutine_smallhorn=nil
end
--外面提示
function ChatCtrl:UpdateOutSideTip(count)
  if count>0 then
    self.OutSide:FindChild("Tip").gameObject:SetActive(true)
    --内容
    self.OutSide:FindChild("Tip/txt"):GetComponent("UnityEngine.UI.Text").text = string.format("您有<color=#FFEB0CFF>%s</color>条新信息",count)
  else
    self.OutSide:FindChild("Tip").gameObject:SetActive(false)
  end
end
--点击外面tip 跳转到好友界面
function ChatCtrl:ClickOutSideTip()
  self:ClickOpenMainPanel()
  self:ClickTypeButton("Friend")
end
--进入
function ChatCtrl:ClickOpenMainPanel()
  if self.MainType =="All" and UTGMainPanelAPI.Instance~=nil then 
    UTGMainPanelAPI.Instance:HideSelf() 
  end
  self.Main.gameObject:SetActive(true)
  self.Main.localPosition = Vector3.zero
  self.ani_main.enabled = true 
end

--初始化Main
function ChatCtrl:InitMain()
  local listener = {}
  --
  for i=(self.typeButtonGrid.childCount-1),0,-1 do
    local temp = self.typeButtonGrid:GetChild(i)
    UITools.GetLuaScript(temp.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickTypeButton,temp.name)
    temp.gameObject:SetActive(false)
  end

  self.HornButs.gameObject:SetActive(false)
  local butFriend = self.typeButtonGrid:FindChild("Friend")
  butFriend.gameObject:SetActive(true)
  local param = self.MainType
  if self.MainType =="All" then
    self.HornButs.gameObject:SetActive(true)
    listener = NTGEventTriggerProxy.Get(self.HornButs:FindChild("Big").gameObject) 
    listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChatCtrl.ClickHornBut,self)
    listener = NTGEventTriggerProxy.Get(self.HornButs:FindChild("Small").gameObject) 
    listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChatCtrl.ClickHornBut,self)
    self:UpdateGuildState()
  elseif self.MainType =="BattleRoom" then
    butFriend.gameObject:SetActive(false)
  end
  --Debugger.LogError(param)
  self.typeButtonGrid:FindChild(param).gameObject:SetActive(true)
  self:ClickTypeButton(param)
end
--发送喇叭
function ChatCtrl:ClickHornBut(eventdata)
  local name = eventdata.pointerPress.transform.name
  local currId = 0
  if name == "Big" then
    currId = UTGDataTemporary.Instance().BigHornItemId
  elseif name =="Small" then 
    currId = UTGDataTemporary.Instance().SmallHornItemId
  end
  if UTGData.Instance().ItemsDeck[tostring(currId)]~=nil then 
    GameManager.CreatePanel("ChatHorn")
    ChatHornAPI.Instance:Init(name,currId)
  else
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("未拥有该道具")
  end 

end

--点击菜单按钮
function ChatCtrl:ClickTypeButton(name)
  local temp = self.typeButtonGrid:FindChild(name)
  local liang = temp:FindChild("Liang")
  if liang.gameObject.activeSelf then return end
  for i=(self.typeButtonGrid.childCount-1),0,-1 do
    self.typeButtonGrid:GetChild(i):FindChild("Liang").gameObject:SetActive(false)
  end 
  liang.gameObject:SetActive(true)
  self.currChannel = temp.name
  self.window_friend.gameObject:SetActive(false)
  self.window_guildRecruit.gameObject:SetActive(false)
  self.typeButtonGrid:FindChild("Friend/Player").gameObject:SetActive(false)
  temp:FindChild("Tip").gameObject:SetActive(false)

  if temp.name =="Friend" then
    self:ShowFriendWindow()
  elseif temp.name =="GuildRecruit" then
    self:ShowGuildRecruitWindow()
  else
    self:ShowWindow(self:GetWindowByParam(temp.name))
  end

end
--设置对话窗口grid 状态
function ChatCtrl:SetWindowListHide()
  for i=self.window_grid.childCount-1,0,-1 do
    self.window_grid:GetChild(i).gameObject:SetActive(false)
  end
end

function ChatCtrl:ShowFriendWindow()
  self.chat_bighorn.transform.localPosition = Vector3.New(-1000,0,0)
  self.window_friend.gameObject:SetActive(true)
  self:SetWindowListHide()
  local grid = self.window_friend:FindChild("Scroll/Grid")
  for i=grid.childCount-1,0,-1 do
    grid:GetChild(i).gameObject:SetActive(false)
  end
  self.FriendData = self:GetFriendData()
  local count = 0
  for k,v in pairs(self.FriendData) do
    local temp = grid:FindChild(tostring(k))
    self.ChatTips[k] = self.ChatTips[k] or 0
    if temp~=nil then 
      if v.State ~= 0 or self.ChatTips[k]>0 then 
        temp.gameObject:SetActive(true) 
      end
    else
      if v.State ~= 0 then
        --Debugger.LogError(v.PlayerId)
        self:InitFriendList(v,grid)
      end
    end
    if v.State ~=0 then count = count+1 end
  end

  if count>0 then 
    self.window_friend:FindChild("Tip/Txt"):GetComponent("UnityEngine.UI.Text").text = "选个战友，愉快的聊起来吧~"
  else
    self.window_friend:FindChild("Tip/Txt"):GetComponent("UnityEngine.UI.Text").text = "人生得意须尽欢，叫好友起床一起嗨啦~"
  end
end
function ChatCtrl:SetAsFirstSibling(tran)
  local function SetAsFirstSiblingMov()
    coroutine.step()
    tran:SetAsFirstSibling()
  end
  coroutine.start(SetAsFirstSiblingMov,self)
end

function ChatCtrl:UpdateFriendScroll(chatdata)
  local grid = self.window_friend:FindChild("Scroll/Grid")
  if chatdata~=nil then 
    local playerId = tostring(chatdata.FriendPlayerId)
    --Debugger.LogError(playerId)
    local temp = grid:FindChild(playerId)
    if temp == nil then 
      self.FriendData = self:GetFriendData()
      temp = self:InitFriendList(self.FriendData[tostring(playerId)],grid)
    end
    self:SetAsFirstSibling(temp)
    temp:FindChild("Txt"):GetComponent("UnityEngine.UI.Text").text = tostring(chatdata.Message)
  end
  --
  local count = 0
  local temp = nil
  local tip = nil
  if self.FriendData == nil then 
    self.FriendData = self:GetFriendData()
  end
  for k,v in pairs(self.FriendData) do
    self.ChatTips[k] = self.ChatTips[k] or 0
    count = self.ChatTips[k] + count
    temp = grid:FindChild(v.PlayerId)
    if temp~=nil then 
      tip = temp:FindChild("Tip")
      tip.gameObject:SetActive(false)
      if self.ChatTips[tostring(v.PlayerId)]>0 then 
        tip.gameObject:SetActive(true)
        tip:FindChild("Txt"):GetComponent("UnityEngine.UI.Text").text = tostring(self.ChatTips[tostring(v.PlayerId)])
      end
    end
    --Debugger.LogError(k.."  "..self.ChatTips[k])
  end

  tip = self.typeButtonGrid:FindChild("Friend/Tip")
  if count>0 then
    tip.gameObject:SetActive(true)
    tip:FindChild("Txt"):GetComponent("UnityEngine.UI.Text").text = tostring(count)
  else
    tip.gameObject:SetActive(false)
  end
  --Debugger.LogError(count)
  self.FriendTipCount = count
    
end
function ChatCtrl:GetFriendData()
  local data = {}
  for k,v in pairs(UTGData.Instance().FriendList) do
    local temp = {}
    temp.FriendId = v.Id
    temp.PlayerId = v.PlayerId
    temp.PlayerName = v.Name
    temp.PlayerIcon = v.Avatar
    temp.PlayerFrame = UTGData.Instance().AvatarFramesData[tostring(v.AvatarFrameId)].Icon
    temp.PlayerLevel = v.Level 
    temp.VipIcon = ""
    if v.Vip>0 then temp.VipIcon = "v"..v.Vip end
    temp.State = v.Status
    data[tostring(v.PlayerId)] = temp
  end
  return data
end
function ChatCtrl:IsFriendOffline(playerid)
  for k,v in pairs(UTGData.Instance().FriendList) do
    if v.Status == 0 and v.PlayerId == tonumber(playerid) then 
      return true
    end
  end
  return false
end
-------------战队招募-----------------
function ChatCtrl:UpdateGuildState()
  if self.MainType == "All" then 
    self.typeButtonGrid:FindChild("GuildRecruit").gameObject:SetActive(false)
    self.typeButtonGrid:FindChild("Guild").gameObject:SetActive(false)
    if UTGData.Instance().PlayerData.GuildStatus ~=1 then
      self.typeButtonGrid:FindChild("GuildRecruit").gameObject:SetActive(true)
    else
      self.typeButtonGrid:FindChild("Guild").gameObject:SetActive(true)
      self.window_guildRecruit.gameObject:SetActive(false)
    end
  end
end
function ChatCtrl:ShowGuildRecruitWindow()
  self.chat_bighorn.transform.localPosition = Vector3.New(-1000,0,0)
  self.window_guildRecruit.gameObject:SetActive(true)
  self:SetWindowListHide()
  if self.initGuildRecruitWindow~=true then self:RequestGuildInvitationHistory() end
end
function ChatCtrl:InitGuildRecruitWindow(data)
  self.initGuildRecruitWindow = true
  self.coroutine_initGuildRecruitList = coroutine.start(self.InitGuildRecruitListMov,self,data)
end
function ChatCtrl:InitGuildRecruitListMov(data)
  local grid = self.window_guildRecruit:FindChild("Scroll/Grid")
  for i,v in ipairs(data) do
    self:InitGuildRecruitList(v,grid)
    coroutine.step()
  end
  self.coroutine_initGuildRecruitList=nil
end
function ChatCtrl:UpdateGuildRecruitWindow(data)
  local grid = self.window_guildRecruit:FindChild("Scroll/Grid")
  self:InitGuildRecruitList(data,grid)
end
function ChatCtrl:ClickApplyGuild(id)
  self:RequestApplyGuild(id)
end
function ChatCtrl:RequestApplyGuild(id)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestApplyGuild"),
                                JProperty.New("GuildId",tonumber(id)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChatCtrl.RequestApplyGuildHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
function ChatCtrl:RequestApplyGuildHandler(e)
  if e.Type =="RequestApplyGuild" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      Debugger.LogError("RequestApplyGuildHandler Result == "..0)
    else
      local str = ""
      if result == 1 then str = "申请加入战队成功！" end
      if result == 0x0f01 then str = "已经加入战队" end
      if result == 0x0f02 then str = "已经响应筹备战队" end
      if result == 0x0f06 then str = "已经申请了该战队" end
      if result == 0x0f12 then str = "不符合申请条件" end
      if result == 0x0f14 then str = "申请次数过多，目前还不能申请" end
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice(str)
    end
    return true
  end
  return false
end
function ChatCtrl:NotifyChatGuildInvitationMessage(e)
  if e.Type =="NotifyChatGuildInvitationMessage" then
    if self.MainType == "All" then
      local data = json.decode(e.Content:get_Item("GuildInvitationMessage"):ToString())
      self:UpdateGuildRecruitWindow(data)
    end
    return true
  end
  return false
end
-------------战队招募 end-----------------

--世界聊天
function ChatCtrl:RequestSendPublicChatMessage(mestype,mes)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSendPublicChatMessage"),
                                JProperty.New("MessageType",tonumber(mestype)),
                                JProperty.New("Message",tostring(mes)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChatCtrl.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
--私人聊天
function ChatCtrl:RequestSendPrivateChatMessage(playerid,mestype,mes)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSendPrivateChatMessage"),
                                JProperty.New("ReceiverId",tonumber(playerid)),
                                JProperty.New("MessageType",tonumber(mestype)),
                                JProperty.New("Message",tostring(mes)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChatCtrl.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
--房间聊天
function ChatCtrl:RequestSendRoomChatMessage(roomid,mestype,mes)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSendRoomChatMessage"),
                                JProperty.New("RoomId",tonumber(roomid)),
                                JProperty.New("MessageType",tonumber(mestype)),
                                JProperty.New("Message",tostring(mes)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChatCtrl.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
--队伍聊天
function ChatCtrl:RequestSendTrialPartyChatMessage(partyid,mestype,mes)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSendTrialPartyChatMessage"),
                                JProperty.New("TrialpartyId",tonumber(partyid)),
                                JProperty.New("MessageType",tonumber(mestype)),
                                JProperty.New("Message",tostring(mes)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChatCtrl.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
--战斗房间聊天
function ChatCtrl:RequestSendBattleChatRoomMessage(mestype,mes)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSendBattleChatRoomMessage"),
                                JProperty.New("MessageType",tonumber(mestype)),
                                JProperty.New("Message",tostring(mes)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChatCtrl.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
--战队聊天
function ChatCtrl:RequestSendGuildChatMessage(mestype,mes)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSendGuildChatMessage"),
                                JProperty.New("MessageType",tonumber(mestype)),
                                JProperty.New("Message",tostring(mes)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChatCtrl.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
--获取战队邀请历史记录
function ChatCtrl:RequestGuildInvitationHistory()
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestGuildInvitationHistory"))
  request.Handler = TGNetService.NetEventHanlderSelf(ChatCtrl.RequestHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end


function ChatCtrl:RequestHandler(e)
  if e.Type =="RequestSendPublicChatMessage" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      Debugger.LogError("RequestSendPublicChatMessage Result == "..0)
    elseif result == 1 then
    elseif result == 0x0901 then
      print("发送间隔过短")
    end
    return true
  end
  if e.Type =="RequestSendPrivateChatMessage" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      Debugger.LogError("RequestSendPrivateChatMessage Result == "..0)
    elseif result == 1 then
    elseif result == 0x0902 then
      print("双方已不是好友关系，发送失败")
    end
    return true
  end
  if e.Type =="RequestSendRoomChatMessage" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      Debugger.LogError("RequestSendRoomChatMessage Result == "..0)
    elseif result == 1 then
    end
    return true
  end
  if e.Type =="RequestSendTrialPartyChatMessage" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      Debugger.LogError("RequestSendTrialPartyChatMessage Result == "..0)
    elseif result == 1 then
    end
    return true
  end
  if e.Type =="RequestSendBattleChatRoomMessage" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      Debugger.LogError("RequestSendBattleChatRoomMessage Result == "..0)
    elseif result == 1 then
    end
    return true
  end
  if e.Type =="RequestSendGuildChatMessage" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 0 then
      Debugger.LogError("RequestSendGuildChatMessage Result == "..0)
    elseif result == 1 then
    end
    return true
  end
  if e.Type =="RequestGuildInvitationHistory" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    local data = json.decode(e.Content:get_Item("List"):ToString())
    if result == 0 then
      Debugger.LogError("RequestGuildInvitationHistory Result == "..0)
    elseif result == 1 and data ~=nil then
      self:InitGuildRecruitWindow(data)
    end
    return true
  end

  return false
end


function ChatCtrl:PushChatInfo(e)
  local chatmes = json.decode(e.Content:get_Item("ChatMessage"):ToString())
  local sender = chatmes.Sender
  local sendtime = chatmes.SendTime
  local mestype = tonumber(chatmes.MessageType)
  local receiverId = tonumber(chatmes.ReceiverId)
  local data = {}
  data.ReceiverId = receiverId
  --频道
  data.Channel = tonumber(chatmes.MessageChannel)
  data.IsSmallHorn = false
  data.IsBigHorn = false
  if mestype == 4 then data.IsSmallHorn = true end
  if mestype == 5 then data.IsBigHorn = true end
  data.IsMy = false
  data.IsSys = false
  data.IsOther = false
  if sender.PlayerId == self.myPlayerId and data.IsSmallHorn == false and data.IsBigHorn == false then
    data.IsMy = true
  end
  if sender.Type==1 then data.IsSys = true end 
  if data.IsSys == false and data.IsMy == false then data.IsOther = true end
  --信息
  data.Message = tostring(chatmes.Message)
  --时间
  data.SendTime = sendtime

  --玩家信息
  --for k,v in pairs(sender) do
    --Debugger.LogError(k.." "..v)
  --end
  local player = {}
  player.PlayerId = sender.PlayerId
  player.PlayerName = sender.PlayerName
  player.PlayerIcon = sender.Avatar
  player.PlayerFrame = UTGData.Instance().AvatarFramesData[tostring(sender.AvatarFrameId)].Icon
  player.VipIcon = ""
  if sender.Vip >0 then player.VipIcon = string.format("v%d",sender.Vip) end
  player.PlayerLevel = sender.Level 
  player.RankName = sender.GradeName
  player.GuildName = sender.GuildName
  player.Identify = sender.GuildPosition
  player.IsOffline = true
  if sender.Status ~= 0 then     
    player.StateStr = "在线"
    player.IsOffline = false
  elseif sender.Status == 0 then     
    player.StateStr = "离线"
  end
  player.RankName = sender.GradeName 
  player.GuildName = sender.GuildName 
  player.Identify = sender.GuildPosition 
  data.Player = player

  self:UpdateMain(data)
  self:UpdateOutSide(data)
end

function ChatCtrl:GetChannelNameById(id)
  id = tonumber(id)
  local name = ""
  if id == 1 then --综合
    name = "All"
  elseif id ==3 then --战队
    name = "Guild"
  elseif id ==4 then --房间
    name = "Room"
  elseif id ==5 then --队伍
    name = "Party"
  elseif id ==6 then --战斗队伍
    name = "BattleRoom"
  end
  return name
end

function ChatCtrl:UpdateMain(data)
  if self:IsFilterMain(data.Channel) == false then return end
  local window = nil
  local grid = nil
  local isDown = false
  --如果是大喇叭  逻辑独立 不走下面
  if data.IsBigHorn == true then 
    self:InitBigHornChat(data)
    return
  end
  --判断window 和 grid
  if data.Channel == 2 then
    data.FriendPlayerId = data.ReceiverId
    if data.ReceiverId == self.myPlayerId then 
      data.FriendPlayerId = data.Player.PlayerId
    end
    window = self:GetWindowByParam(tostring(data.FriendPlayerId))
  else
    window = self:GetWindowByParam(self:GetChannelNameById(data.Channel))
  end 

  grid = window:FindChild("Scroll/Grid")
  --判断是否自动顶上
  if window.gameObject.activeSelf then 
    if self:IsOutLine(grid) == false or data.IsMy == true then 
      isDown = true 
    end
  end
  --保存聊天信息
  self.ChatData[window.name] = self.ChatData[window.name] or {}
  if data.IsSys == false then 
    table.insert(self.ChatData[window.name],data)
  end
  --判断是否超时 插入时间
  if #self.ChatData[window.name]>1 then 
    local preTime = self.ChatData[window.name][(#self.ChatData[window.name]-1)].SendTime
    local currTime = tostring(data.SendTime)
    --Debugger.LogError(preTime.."  "..currTime)
    if UTGData.Instance():GetLeftTime(preTime)<-60 then
      local pattern_go = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"--"2016-04-27T20:32:22+08:00",
      local year_go, month_go, day_go, hour_go, minute_go, seconds_go = tostring(currTime):match(pattern_go) 
      local time = string.format("%02d:%02d:%02d",hour_go,minute_go,seconds_go)
      self:InitTimeChat(time,grid)
    end
  end
  --插入信息
  if data.IsMy == true then 
    self:InitMyChat(data,grid)
  elseif data.IsSys == true then
    self:InitSysChat(data,grid) 
  elseif data.IsOther == true then
    self:InitOtherChat(data,grid) 
  end

  if isDown == true then 
    self:SetWindowGridPos(window)
  elseif data.IsMy~=true then
    self.ChatTips[window.name] = self.ChatTips[window.name] or 0 
    self.ChatTips[window.name] = self.ChatTips[window.name] + 1
    --Debugger.LogError("self.ChatTips[window.name] "..self.ChatTips[window.name])
    if self.ChatTips[window.name]>50 then 
      Object.Destroy(grid:GetChild(0).gameObject)
      self.ChatTips[window.name] = 50
    end
    if window.gameObject.activeSelf then 
       --Debugger.LogError("11111 "..self.ChatTips[window.name])
       self:InitChatTip(window:FindChild("Tip"),self.ChatTips[window.name])
      if self.tip_coro == nil then  
        self.tip_coro = coroutine.start(ChatCtrl.ObserveWindowGridPos,self,window)
      end
    else
      --刷新菜单tip
      if data.Channel ~= 2 then 
        self:UpdateButTip(window.name)
      end
    end
  end
  --刷新 好友列表
  if data.Channel == 2 then 
    self:UpdateFriendScroll(data)
  end
end
--更新菜单键上的tip
function ChatCtrl:UpdateButTip(name)
  local count = 0
  local tip ={}
  count = self.ChatTips[name]
  tip = self.typeButtonGrid:FindChild(name.."/Tip")
  if count>0 then
    tip.gameObject:SetActive(true)
    tip:FindChild("Txt"):GetComponent("UnityEngine.UI.Text").text = tostring(count)
  else
    tip.gameObject:SetActive(false)
  end
end

function ChatCtrl:SetWindowGridPos(window)
  local function SetWindowGridPosMov()
    coroutine.step()
    window:FindChild("Scroll"):GetComponent("UnityEngine.UI.ScrollRect").verticalNormalizedPosition = 0
    self.ChatTips[window.name]=0
    self.coroutine_SetWindowGridPos = nil 
  end 
  if self.coroutine_SetWindowGridPos ~=nil then coroutine.stop(self.coroutine_SetWindowGridPos) end
  self.coroutine_SetWindowGridPos = coroutine.start(SetWindowGridPosMov,self)
end

function ChatCtrl:IsOutLine(grid)
  if grid.childCount == 0 then return false end
  self.scroll_lineY = self.Main:FindChild("Main/Line").position.y
  return (grid:GetChild(grid.childCount-1).transform.position.y<self.scroll_lineY)
end
function ChatCtrl:ObserveWindowGridPos(window)
  while window:FindChild("Scroll"):GetComponent("UnityEngine.UI.ScrollRect").verticalNormalizedPosition >0.01 do
    --Debugger.LogError(self:GetScrollGridPos(scroll))
    coroutine.step()
  end
  self.ChatTips[window.name] = 0
  window:FindChild("Tip").gameObject:SetActive(false)
  self.tip_coro = nil
end
function ChatCtrl:ClickWindowTip(window)
  self:SetWindowGridPos(window)
  self.ChatTips[window.name] = 0
  window:FindChild("Tip").gameObject:SetActive(false)
end
--通过 参数 得到对话窗口
function ChatCtrl:GetWindowByParam(param)
  local temp = self.window_grid:FindChild(tostring(param))
  if temp == nil then 
    temp = self:CreateItem(self.temp_window,self.window_grid,param)
    temp.gameObject:SetActive(false)
    --tip
    UITools.GetLuaScript(temp:FindChild("Tip").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickWindowTip,temp)
    temp:FindChild("Tip").gameObject:SetActive(false)
    --对话栏
    local inputField = temp:FindChild("Input/InputField"):GetComponent("UnityEngine.UI.InputField")
    inputField.onValidateInput = UnityEngine.UI.InputField.OnValidateInputSelf(ChatCtrl.MonitorInput,self)
    --提交
    UITools.GetLuaScript(temp:FindChild("Input/Submit").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickSubmit,{Name = temp.name,InputField = inputField})
  end
  return temp
end
--显示对话窗口
function ChatCtrl:ShowWindow(window)
  for i=self.window_grid.childCount-1,0,-1 do
    self.window_grid:GetChild(i).gameObject:SetActive(false)
  end
  window.gameObject:SetActive(true)
  --大喇叭显示
  self.chat_bighorn.transform.localPosition = Vector3.New(0,0,0)
  self:SetWindowGridPos(window)
end

--生成Item
function ChatCtrl:CreateItem(item,parent,name)
  local temp = GameObject.Instantiate(item)
  temp.name = tostring(name)
  temp.gameObject:SetActive(true)
  temp.transform:SetParent(parent)
  temp.transform.localPosition = Vector3.zero
  temp.transform.localRotation = Quaternion.identity
  temp.transform.localScale = Vector3.one
  return temp
end

--生成一个玩家头像
function ChatCtrl:InitPlayerIcon(data,_parent,scroll)
  local parent_icon = _parent:FindChild("Icon")
  for i=(parent_icon.childCount-1),0,-1 do
    Object.Destroy(parent_icon:GetChild(i).gameObject)
  end
  local temp = self:CreateItem(self.temp_playericon,parent_icon,data.PlayerId)
  if data == nil then return end
  _parent:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = data.PlayerName
  temp:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",tostring(data.PlayerIcon),"UnityEngine.Sprite")
  temp:FindChild("Vip").gameObject:SetActive(false)
  if data.VipIcon ~= "" then 
    temp:FindChild("Vip").gameObject:SetActive(true)
    temp:FindChild("Vip"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("vipicon",tostring(data.VipIcon),"UnityEngine.Sprite")
  end
  temp:FindChild("Bg"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("frameicon",tostring(data.PlayerFrame),"UnityEngine.Sprite")
  temp:FindChild("Level/Txt"):GetComponent("UnityEngine.UI.Text").text = data.PlayerLevel
  if scroll~=nil then
    UITools.GetLuaScript(temp:FindChild("Click").gameObject,"Logic.UICommon.UIDragScrollRect").scrollRect = scroll:GetComponent("ScrollRect")
    UITools.GetLuaScript(temp:FindChild("Click").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickPlayerIcon,data)
  end
end
--点击头像
function ChatCtrl:ClickPlayerIcon(data)
  if data.PlayerId == self.myPlayerId then return end
  --GameManager.CreatePanel("PlayerInfoOnChart")
  local canInvite = false 
  if self.currChannel == "Friend" then canInvite = true end
  --PlayerInfoOnChartAPI.Instance:Init(data,"Chat",canInvite)
  self.self_playerinfo:Init(data,"Chat",canInvite)
end
--VIP 改变对话颜色
function ChatCtrl:VIPChangeMessage(text)
  local txt = string.format("<color=#FEED23FF>%s</color>",text)
  return txt
end
--显示自己的对话
function ChatCtrl:InitMyChat(data,grid)
  local temp = self:CreateItem(self.temp_chat_my,grid,"My")
  --头像
  self:InitPlayerIcon(data.Player,temp:FindChild("Player"),grid.parent)
  --对话
  local Mes = data.Message
  if data.Player.VipIcon~="" then Mes = self:VIPChangeMessage(Mes) end
  temp:FindChild("Mes/Mes/txt"):GetComponent("UnityEngine.UI.Text").text = Mes
end

--显示他人/小喇叭 对话
function ChatCtrl:InitOtherChat(data,grid)
  local temp = self:CreateItem(self.temp_chat_other,grid,"Other")
  --头像
  self:InitPlayerIcon(data.Player,temp:FindChild("Player"),grid.parent)
  --对话
  local mes = temp:FindChild("Mes")
  if data.IsSmallHorn == true then 
    mes:FindChild("Common").gameObject:SetActive(false)
    mes:FindChild("Horn").gameObject:SetActive(true)
    mes:FindChild("Horn/txt"):GetComponent("UnityEngine.UI.Text").text = "<color=#11223300>隐身</color>"..data.Message
  else
    mes:FindChild("Common").gameObject:SetActive(true)
    mes:FindChild("Horn").gameObject:SetActive(false)
    local Mes = data.Message
    if data.Player.VipIcon~="" then Mes = self:VIPChangeMessage(Mes) end
    mes:FindChild("Common/txt"):GetComponent("UnityEngine.UI.Text").text = Mes
  end

end
--显示系统公告
function ChatCtrl:InitSysChat(data,grid)
  local temp = self:CreateItem(self.temp_chat_sys,grid,"Sys") 
  --内容
  temp:FindChild("txt"):GetComponent("UnityEngine.UI.Text").text = data.Message
end

--显示大喇叭 
function ChatCtrl:InitBigHornChat(data)
  local temp = self.chat_bighorn
  --头像
  self:InitPlayerIcon(data.Player,temp:FindChild("Player"))
  --对话
  temp:FindChild("Txt"):GetComponent("UnityEngine.UI.Text").text = data.Message
  --持续30秒
  if self.coroutine_bighorn~=nil then 
    coroutine.stop(self.coroutine_bighorn)
  end
  self.coroutine_bighorn = coroutine.start(ChatCtrl.BigHornChatMov,self)
end
function ChatCtrl:BigHornChatMov( )
  self.chat_bighorn.gameObject:SetActive(true)
  coroutine.wait(30)
  self.chat_bighorn.gameObject:SetActive(false)
  self.coroutine_bighorn=nil
end

--显示时间
function ChatCtrl:InitTimeChat(time,grid)
  local temp = self:CreateItem(self.temp_chat_time,grid,"Time")
  --内容
  temp:FindChild("Txt"):GetComponent("UnityEngine.UI.Text").text = tostring(time)
end

--初始化好友列表
function ChatCtrl:InitFriendList(data,grid)
  local temp = self:CreateItem(self.temp_friend,grid,data.PlayerId) 
  --头像
  self:InitPlayerIcon(data,temp:FindChild("Player"))
  --内容
  temp:FindChild("Txt"):GetComponent("UnityEngine.UI.Text").text = "点击和他聊天"
  UITools.GetLuaScript(temp:FindChild("Click").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickOpenFriendChatPanel,data.PlayerId)
  return temp
end

--战队招募列表
function ChatCtrl:InitGuildRecruitList(data,grid)
  local temp = self:CreateItem(self.temp_guildRecruit,grid,data.GuildId) 
  --头像
  local player = temp:FindChild("Player")
  player:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = data.PlayerName
  player:FindChild("Level"):GetComponent("UnityEngine.UI.Text").text = data.PlayerLevel
  player:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite =UITools.GetSprite("roleicon",data.PlayerAvatar)
  --内容
  local levelLimit = "无等级限制"
  local gradeLimit = "无段位限制"
  if data.GuildLimitLevel>0 then levelLimit = ""..data.GuildLimitLevel end
  if data.GuildLimitGrade>0 then gradeLimit = ""..UTGData.Instance().GradesData[tostring(data.GuildLimitGrade)].Title end
  temp:FindChild("Txt"):GetComponent("UnityEngine.UI.Text").text = string.format("<color=#6EC1FFFF>%s</color>邀请玩家加入，共创属于我们的荣耀！<color=#BBBBBBFF>(等级限制：%s，段位限制：%s)</color>",data.GuildName,levelLimit,gradeLimit)
  UITools.GetLuaScript(temp:FindChild("But_Apply").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickApplyGuild,data.GuildId)
end

--打开好友聊天
function ChatCtrl:ClickOpenFriendChatPanel(playerId)
  playerId = tostring(playerId)
  self.FriendData = self:GetFriendData()
  self.typeButtonGrid:FindChild("All/Liang").gameObject:SetActive(false)
  self.typeButtonGrid:FindChild("Friend/Player").gameObject:SetActive(true)
  self.typeButtonGrid:FindChild("Friend/Player/txt"):GetComponent("UnityEngine.UI.Text").text = self.FriendData[playerId].PlayerName
  self.window_friend.gameObject:SetActive(false)
  self.currChannel = "Friend"
  self.currInputParam.PlayerId = tonumber(playerId)
  local window = self:GetWindowByParam(playerId)
  self:ShowWindow(window)
  self.ChatTips[playerId] = 0
  self:SetWindowGridPos(window)
  self:UpdateFriendScroll()
end
--显示提示
function ChatCtrl:InitChatTip(tip,count)
  tip.gameObject:SetActive(true) 
  tip:FindChild("txt"):GetComponent("UnityEngine.UI.Text").text = string.format("您有<color=#FFEB0CFF>%s</color>条新信息",count)
end

--获取utf格式的字符串长度
function ChatCtrl:UtfStrLen(str)
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
function ChatCtrl:MonitorInput(text,charindex,addchar)
  local str = tostring(text..tolua.chartolstring(addchar))
  if self:UtfStrLen(str) > 20 then 
    if self.api_notice == nil then 
      local instance = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
      instance:InitNoticeForNeedConfirmNotice("提示", "最大输入字数20个", false, "", 1)
      instance:SetTextToCenter()
      instance:OneButtonEvent("确定",ChatCtrl.DestroyNotice, self)
      self.api_notice = instance
      UnityEngine.EventSystems.EventSystem.current:SetSelectedGameObject(nil)--current.currentSelectedGameObject = nil
    end
    return 0
  end
  return addchar
end
--关闭提示框 
function ChatCtrl:DestroyNotice()
  self.api_notice:DestroySelf()
  self.api_notice = nil
end
--输入CD 
function ChatCtrl:InputCD(tip)
  self.coroutine_inputtip = coroutine.start(ChatCtrl.InputCDMov,self,tip) 
end
function ChatCtrl:InputCDMov(tip)
  local playerLv = UTGData.Instance().PlayerData.Level
  local time = 0
  local lv_bound = tonumber(UTGData.Instance().ConfigData["chat_public_cd_critical_level"].Int)
  local high_cd = tonumber(UTGData.Instance().ConfigData["chat_public_high_level_cd"].Int)
  local low_cd = tonumber(UTGData.Instance().ConfigData["chat_public_low_level_cd"].Int)
  --20级以下玩家发言CD为40秒，20级及以上玩家发言CD为20秒
  if playerLv>lv_bound then 
    time =low_cd
  else
    time = high_cd
  end
  while time>0 do 
    tip:GetComponent("UnityEngine.UI.Text").text = string.format("请点击输入[<color=#A12827FF>%d秒</color>]后可以发言",time)
    coroutine.wait(1)
    time = time -1
  end
  tip:GetComponent("UnityEngine.UI.Text").text = "请点击输入"
  self.coroutine_inputtip = nil
end
--提交输入
function ChatCtrl:ClickSubmit(args)
  local name = args.Name
  local text = args.InputField.text
  --Debugger.LogError(text)
  if text == "" then 
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不能发送空的内容哦")
    return
  end
  if self.currChannel == "All" then 
    if self.coroutine_inputtip~=nil then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("您说话太快了，请稍等哟~")
      return
    end
    self:RequestSendPublicChatMessage(1,text)
    self:InputCD(args.InputField.transform:FindChild("Tip"))

  else
    if self.currChannel == "Friend" then
      if self:IsFriendOffline(self.currInputParam.PlayerId) then 
        GameManager.CreatePanel("SelfHideNotice")
        SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("对方已离线")
        return
      end
      self:RequestSendPrivateChatMessage(self.currInputParam.PlayerId,2,text)    
    end
    if self.currChannel == "Party" then
      self:RequestSendTrialPartyChatMessage(self.currInputParam.PartyId,2,text)    
    end
    if self.currChannel == "Room" then
      self:RequestSendRoomChatMessage(self.currInputParam.RoomId,2,text)    
    end
    if self.currChannel == "BattleRoom" then
      self:RequestSendBattleChatRoomMessage(2,text)    
    end
    if self.currChannel == "Guild" then
      self:RequestSendGuildChatMessage(2,text)    
    end
      
  end
  args.InputField.text = ""
end


--退出
function ChatCtrl:ClickCloseMainPanel()
  self.ani_main:Play("hide")
  coroutine.start(ChatCtrl.ClickClosePanelMov,self)
end

function ChatCtrl:ClickClosePanelMov()
  coroutine.wait(0.3)
  if self.MainType =="All" then
    if FriendAPI~=nil and FriendAPI.Instance~=nil then
      FriendAPI.Instance:ShowSelf()
    elseif UTGMainPanelAPI.Instance~=nil then 
      UTGMainPanelAPI.Instance:ShowSelf()
    end 
  end
  self:UpdateOutSide()
  self:ClickTypeButton(self.MainType)
  self.Main.gameObject:SetActive(false)
end


function ChatCtrl:OnDestroy()
  if self.coroutine_inputtip~=nil then coroutine.stop(self.coroutine_inputtip) end
  if self.coroutine_bighorn~=nil then coroutine.stop(self.coroutine_bighorn) end
  if self.coroutine_smallhorn~=nil then coroutine.stop(self.coroutine_smallhorn) end
  if self.tip_coro~=nil then coroutine.stop(self.tip_coro) end
  if self.coroutine_initGuildRecruitList~=nil then coroutine.stop(self.coroutine_initGuildRecruitList) end
  if self.coroutine_SetWindowGridPos ~=nil then coroutine.stop(self.coroutine_SetWindowGridPos) end
  TGNetService.GetInstance():RemoveEventHander("NotifyChatGuildInvitationMessage",self.Delegate_NotifyChatGuildInvitationMessage)

  self.this = nil
  self = nil
end