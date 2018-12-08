--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("PlayerInfoOnChartAPI")
--local json = require "cjson"

function PlayerInfoOnChartAPI:Awake(this)
  self.this = this
  --PlayerInfoOnChartAPI.Instance = self
  local listener = {}
  --Main 
  local main = this.transforms[1]
  self.Main = main

  listener = NTGEventTriggerProxy.Get(this.transforms[0].gameObject) --关闭面板
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(PlayerInfoOnChartAPI.ClickClosePlayerInfo,self)
  listener = NTGEventTriggerProxy.Get(main:FindChild("Grid/But_AddFriend").gameObject) --添加好友
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(PlayerInfoOnChartAPI.ClickAddFriend,self)
  listener = NTGEventTriggerProxy.Get(main:FindChild("Grid/But_Info").gameObject) --查看信息
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(PlayerInfoOnChartAPI.ClickGetPlayerInfo,self)
  listener = NTGEventTriggerProxy.Get(main:FindChild("Grid/But_3V3").gameObject) --邀请3v3
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(PlayerInfoOnChartAPI.Click3v3,self)
  listener = NTGEventTriggerProxy.Get(main:FindChild("Grid/But_5V5").gameObject) --邀请5v5
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(PlayerInfoOnChartAPI.Click5v5,self)
  listener = NTGEventTriggerProxy.Get(main:FindChild("Grid/But_ForBid").gameObject) --邀请5v5
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(PlayerInfoOnChartAPI.ClickForBid,self)


end

function PlayerInfoOnChartAPI:Start()
  self.this.gameObject:SetActive(false)
end

function PlayerInfoOnChartAPI:SetPos(tran)
  self.this.transform:SetParent(tran)
  self.this.transform.localPosition = Vector3.zero
  self.this.transform.localRotation = Quaternion.identity
  self.this.transform.localScale = Vector3.one
end


--显示 信息面板
function PlayerInfoOnChartAPI:ClickOpenPlayerInfo(eventdata)
  local index = tonumber(eventdata.pointerPress.transform.parent.name)
  self.currPlayerId = self.ChartDatas[index].PlayerId
  if self.myPlayerId == self.currPlayerId  then return end
  self.panel_playerinfo.gameObject:SetActive(true)
  self:InitPlayerInfo(self.ChartDatas[index])
end

--关闭 信息面板
function PlayerInfoOnChartAPI:ClickClosePlayerInfo()
  --Object.Destroy(self.this.gameObject)
  self.this.gameObject.gameObject:SetActive(false)
end

--初始化玩家信息
function PlayerInfoOnChartAPI:Init(data,typename,canivite)
  self.currPlayerId = data.PlayerId
  if data.RankName == "" then data.RankName = "尚未参加排位赛" end
  if data.GuildName == "" then data.GuildName = "尚未参加战队" end
  if data.Identify == "" then data.Identify = "尚未参加战队" end

  self.Main:FindChild("Txt_Name"):GetComponent("UnityEngine.UI.Text").text = data.PlayerName
  self.Main:FindChild("Txt_State"):GetComponent("UnityEngine.UI.Text").text = data.StateStr
  self.Main:FindChild("Txt_Rank"):GetComponent("UnityEngine.UI.Text").text = data.RankName
  self.Main:FindChild("Txt_Team"):GetComponent("UnityEngine.UI.Text").text = data.GuildName
  self.Main:FindChild("Txt_Identify"):GetComponent("UnityEngine.UI.Text").text = data.Identify
  local grid = self.Main:FindChild("Grid")
  self.Grid = grid
  for i=grid.childCount-1,0,-1 do
    grid:GetChild(i).gameObject:SetActive(false)
  end
  if canivite == true then 
    grid:FindChild("But_3V3").gameObject:SetActive(true)
    grid:FindChild("But_5V5").gameObject:SetActive(true)
  end
  if typename == "Chart" then 
      if self:IsFriend(self.currPlayerId) == true then
      grid:FindChild("But_Info").gameObject:SetActive(true)
    else
      grid:FindChild("But_AddFriend").gameObject:SetActive(true)
      grid:FindChild("But_Info").gameObject:SetActive(true)
    end 
  elseif typename == "Chat" then 
    if self:IsFriend(self.currPlayerId) == true then 
      grid:FindChild("But_Info").gameObject:SetActive(true)
    else
      grid:FindChild("But_AddFriend").gameObject:SetActive(true)
      grid:FindChild("But_Info").gameObject:SetActive(true)
    end
    if self:IsForBid(self.currPlayerId) == true then 
      grid:FindChild("But_ForBidOver").gameObject:SetActive(true)
    else
      grid:FindChild("But_ForBid").gameObject:SetActive(true)
    end
  end
    self.this.gameObject:SetActive(true)
end
--是否为好友
function PlayerInfoOnChartAPI:IsFriend(playerId)
  for k,v in pairs(UTGData.Instance().FriendList) do
    if v.PlayerId == playerId then
      return true
    end
  end
  return false
end
--是否已屏蔽
function PlayerInfoOnChartAPI:IsForBid(playerId)
  for k,v in pairs(UTGData.Instance().ForbidList) do
    if v.PlayerId == playerId then
      return true
    end
  end
  return false
end
--屏蔽 
function PlayerInfoOnChartAPI:ClickForBid()
  if self.wait == true then return end
  self:RequestForBid(self.currPlayerId)
  self.wait = true
end
function PlayerInfoOnChartAPI:RequestForBid(playerId)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestNewForbid"),
                                JProperty.New("TargetPlayerId",tonumber(playerId)))
  request.Handler = TGNetService.NetEventHanlderSelf( PlayerInfoOnChartAPI.RequestForBidHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
function PlayerInfoOnChartAPI:RequestForBidHandler(e)
  if e.Type =="RequestNewForbid" then
    self.wait = false
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      self.Grid:FindChild("But_ForBidOver").gameObject:SetActive(true)
      self.Grid:FindChild("But_ForBid").gameObject:SetActive(false)
    elseif result == 0x0a01 then
      print("已经屏蔽了对方")
      --Debugger.LogError("RequestServerRanks Result == "..result)
    end
    return true
  end
  return false

end
--添加好友 在玩家信息框中
function PlayerInfoOnChartAPI:ClickAddFriend( )
  self:AddFriend(self.currPlayerId)
end
--添加好友
function PlayerInfoOnChartAPI:AddFriend(playerId)
  GameManager.CreatePanel("AddFriend")
  if AddFriendAPI~=nil and AddFriendAPI.Instance~=nil then
      AddFriendAPI.Instance:SetPlayerId(playerId)
  end
end

--查看信息
function PlayerInfoOnChartAPI:ClickGetPlayerInfo()
  GameManager.CreatePanel("PlayerData")
  if PlayerDataAPI~=nil and PlayerDataAPI.Instance~=nil then
    --PlayerDataAPI.Instance:Show()
     PlayerDataAPI.Instance:Init(self.currPlayerId)
  end
end
--邀请3v3
function PlayerInfoOnChartAPI:Click3v3()
  self:InitPanel_15(3,30)
end
--邀请5v5
function PlayerInfoOnChartAPI:Click5v5()
  self:InitPanel_15(5,50)
end
--跳转到 组队界面
function PlayerInfoOnChartAPI:InitPanel_15(playerCount,subType)
  GameManager.CreatePanel("NewBattle15")
  if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
    NewBattle15API.Instance:CreateParty("", playerCount,subType,1)
  end
end


function PlayerInfoOnChartAPI:OnDestroy()
  self.this = nil
  --PlayerInfoOnChartAPI.Instance = nil
  self = nil
end