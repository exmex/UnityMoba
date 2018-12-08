--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("ChartAPI")
local json = require "cjson"

function ChartAPI:Awake(this)
  self.this = this
  ChartAPI.Instance = self
  self.serverType = 0
  self.friendType = 0
  self.FriendRanks = {}
  self.ServerRanks = {}
  self.FriendSelfData = {}
  self.ServerSelfData = {}
  self.IsFriendRank = true  
  self.myPlayerId = 0
  self.PanelName = ""
  self.myPlayerId = UTGData.Instance().PlayerData.Id
  self.myPlayerFrameId = UTGData.Instance().PlayerData.AvatarFrameId
end

function ChartAPI:Start()
  self.chartOnMainCtrl = self.this.transforms[0]:GetComponent("NTGLuaScript")
end

--设置位置 panelname:UTGMain ,Rank
function ChartAPI:SetPos(tran,panelname)
  self.this.transform:SetParent(tran)
  self.this.transform.localPosition = Vector3.zero
  self.this.transform.localRotation = Quaternion.identity
  self.this.transform.localScale = Vector3.one
  self.PanelName = tostring(panelname)
end


--排行榜面板
function ChartAPI:InitChartPanel()
  local function Mov() 
    local result = GameManager.CreatePanelAsync("Chart")
    while result.Done~= true do
      coroutine.wait(0.05) 
    end
    if self.PanelName == "UTGMain" then UTGMainPanelAPI.Instance:HideSelf() end
  end
  coroutine.start(Mov,self)
end
--在主界面 排行榜面板
function ChartAPI:InitChartOnMainPanel()
  local function Mov() 
    if self.PanelName == "UTGMain" then UTGMainPanelAPI.Instance:ShowSelf() end
    coroutine.wait(0.1)  
    self.chartOnMainCtrl.self:SetRankData(self.IsFriendRank)
  end
  coroutine.start(Mov,self)
end

--排行榜数据 
function ChartAPI:GetRankData(type,isFriend,delegateSelf,delegateFunc)

  self.FriendRanks = {}
  self.ServerRanks = {}
  self.FriendSelfData = {}
  self.ServerSelfData = {}

  self.IsFriendRank = isFriend  
  local ranksData = {}
  local selfdata = {}
  if isFriend == true then 
    ranksData = self.FriendRanks 
    selfdata = self.FriendSelfData
  else 
    ranksData = self.ServerRanks
    selfdata = self.ServerSelfData
  end
  if ranksData[tostring(type)] ~=nil and selfdata[tostring(type)] ~=nil then 
    if delegateFunc~=nil and delegateSelf~=nil then 
      delegateFunc(delegateSelf,ranksData[tostring(type)],selfdata[tostring(type)])
    end
  else
    self.delegateSelf = delegateSelf
    self.delegateFunc = delegateFunc
    if isFriend == true then 
      self:RequestFriendRanks(type)
    else 
      self:RequestServerRanks(type)
    end
  end
end

--重置好友排行数据 (当好友数据发生变更)
function ChartAPI:UpdateData()
  if self.IsFriendRank then
    self.FriendRanks = {}
    ChartAPI.Instance:GetRankData(1,true,self.chartOnMainCtrl.self,ChartOnMainCtrl.Init)
  end
end
--请求全服排行
function ChartAPI:RequestServerRanks(type)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestServerRanks"),
                                JProperty.New("RankType",tonumber(type)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChartAPI.RequestServerRanksHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self.serverType = tonumber(type)
end
--请求好友排行
function ChartAPI:RequestFriendRanks(type)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestFriendRanks"),
                                JProperty.New("RankType",tonumber(type)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChartAPI.RequestFriendRanksHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self.friendType = tonumber(type)
end
--请求全服排行 回调
function ChartAPI:RequestServerRanksHandler(e)
  if e.Type =="RequestServerRanks" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      local datas = json.decode(e.Content:get_Item("Ranks"):ToString())
      local selfdata = json.decode(e.Content:get_Item("Self"):ToString())
      if datas == nil or selfdata == nil then  
        Debugger.LogError("rank info == nil") 
      else
        self:ClearUpData(datas,selfdata,self.serverType,false)
      end
    else
      Debugger.LogError("RequestServerRanks Result == "..result)
    end
    return true
  end
  return false
end

--请求好友排行 回调
function ChartAPI:RequestFriendRanksHandler(e)
  if e.Type =="RequestFriendRanks" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      local datas = json.decode(e.Content:get_Item("Ranks"):ToString())
      local selfdata = json.decode(e.Content:get_Item("Self"):ToString())
      if datas == nil or selfdata == nil then
        Debugger.LogError("rank info == nil") 
      else
        self:ClearUpData(datas,selfdata,self.friendType,true)
      end
    else
      Debugger.LogError("RequestFriendRanks Result == "..result)
    end
    return true
  end
  return false
end

--判断是否为好友
function ChartAPI:IsMyFriend(playerId)
  for k,v in pairs(UTGData.Instance().FriendList) do
    if v.PlayerId == playerId then
      return true
    end
  end
  return false
end



--整理数据 
function ChartAPI:ClearUpData(rankdata,selfdata,type,isFriend)
  local data = {}
  local selfData = {}
  local myPlayerId = selfdata.PlayerId
  local myOrder = 1000
  type = tostring(type)
  for i=1,#rankdata do
    local temp = self:ClearUpOneData(rankdata[i],type)
    if temp.PlayerId == myPlayerId then myOrder = i end
    table.insert(data,temp)
  end
  selfData = self:ClearUpOneData(selfdata,type)
  selfData.Num = myOrder

  if isFriend == true then 
    self.FriendRanks[type] = data
    self.FriendSelfData[type] = selfData
  else
    self.ServerRanks[type]= data
    self.ServerSelfData[type] = selfData
  end

  if self.delegateSelf~=nil and self.delegateFunc~=nil then 
    self.delegateFunc(self.delegateSelf,data,selfData)
    self.delegateSelf=nil
    self.delegateFunc=nil
  end

end

--整理数据one
function ChartAPI:ClearUpOneData(data,type)
  local temp = {}
  type = tonumber(type)
  temp.PlayerId = data.PlayerId
  temp.PlayerName = data.PlayerName
  temp.PlayerIcon = data.Icon
  temp.PlayerFrame = ""
  if data.IconFrameId>0 then
    local frameId = 0 
    if temp.PlayerId == self.myPlayerId then frameId = self.myPlayerFrameId else frameId = data.IconFrameId end
    temp.PlayerFrame = UTGData.Instance().AvatarFramesData[tostring(frameId)].Icon 
  end
  temp.VipIcon = "" 
  if data.VipLevel>0 then temp.VipIcon = "v"..data.VipLevel end
  temp.PlayerLevel = data.Level
  temp.IsOffline = data.IsOffline
  if data.IsOffline == false then     
    temp.StateStr = "在线"
  else
    temp.StateStr = "离线"
  end
  --是否是好友
  local result_friend = self:IsMyFriend(temp.PlayerId)
  if self:IsMyFriend(temp.PlayerId) == true then
    temp.IsFriend = true
  else
    temp.IsFriend = false
  end
  temp.TxtLeft = ""
  temp.TxtRight = ""
  temp.IsRank = false
  temp.RankName ="尚未参加排位赛"
  local grade = UTGData.Instance().GradesData[tostring(data.Grade)]
  if grade ~=nil then temp.RankName =grade.Title end
  temp.RankStar = ""
  temp.RankIcon = ""

  if type ==1 then --排位
    local gradeinfo = UTGData.Instance().GradesData[tostring(data.Info[1])]
      if #data.Info>1 then 
        if tonumber(data.Info[1]) == 0 then 
          temp.TxtLeft = "本赛季尚未参加排位赛" 
          temp.RankName = "尚未参加排位赛"
        else
          temp.IsRank = true
          temp.RankStar = "x"..data.Info[2]
          temp.RankIcon = gradeinfo.IconMain
          temp.RankName = gradeinfo.Title
        end
      end
  elseif type ==2 then--英雄
    temp.TxtLeft = "拥有的姬神"
    temp.TxtRight = tostring(data.Info[1])
  elseif type ==3 then--皮肤
    temp.TxtLeft = "拥有的皮肤"
    temp.TxtRight = tostring(data.Info[1])
  elseif type ==4 then--成就
    temp.TxtLeft = "成就等级"
    temp.TxtRight = tostring(data.Info[1])
  elseif type ==5 then--胜场
    temp.TxtLeft = "胜场数"
    temp.TxtRight = tostring(data.Info[1])
  elseif type ==6 then--连续胜场
    temp.TxtLeft = "连续胜场数"
    temp.TxtRight = tostring(data.Info[1])
  elseif type ==7 then--贵族积分
    temp.TxtLeft = "贵族积分"
    temp.TxtRight = tostring(data.Info[1])
  end
  --战队
  temp.GuildName = "尚未加入战队"
  --战队中身份
  temp.Identify = "尚未加入战队"
  return temp
end

--更换头像框后，要刷新排行榜UI
function ChartAPI:GetNewAvatarFrameId()
  local id = UTGData.Instance().PlayerData.AvatarFrameId
  if self.myPlayerFrameId ~= id then 
    self.myPlayerFrameId = id 
    return true
  end
  return false
end
function ChartAPI:UpdateSelfPlayerIcon()
  if self:GetNewAvatarFrameId() then 
    local icon = UTGData.Instance().AvatarFramesData[tostring(self.myPlayerFrameId)].Icon
    self.chartOnMainCtrl.self:UpdateSelfPlayerIcon(icon)
  end
end
function ChartAPI:OnDestroy()
  self.this = nil
  self = nil
  ChartAPI.Instance = nil
end