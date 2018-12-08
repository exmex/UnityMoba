--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("ChartCtrl")
local json = require "cjson"

function ChartCtrl:Awake(this)
  self.this = this
  self.ani = this.transform:GetComponent("Animator")
  local listener = {}
  --Main 
  local main = this.transforms[1]
  self.Main = main
  self.txt_title = main:FindChild("Txt_Title")
  self.myInfo = main:FindChild("MyInfo")
  self.scroll = main:FindChild("Scroll/ScrollView")
  self.grid_list = main:FindChild("Scroll/ScrollView/Grid")

  self.temp_playericon = main:FindChild("Temp_PlayerIcon")
  self.temp_list = main:FindChild("Temp_List")
  self.temp_list.gameObject:SetActive(false)
  self.temp_playericon.gameObject:SetActive(false)

  listener = NTGEventTriggerProxy.Get(this.transforms[0].gameObject) --返回大厅
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChartCtrl.ClickClosePanel,self)
  listener = NTGEventTriggerProxy.Get(main:FindChild("But_AllChart").gameObject) --查看所有榜单
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChartCtrl.ClickAllChart,self)
  listener = NTGEventTriggerProxy.Get(main:FindChild("But_All").gameObject) --全区
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChartCtrl.ClickShowAllChart,self)
  listener = NTGEventTriggerProxy.Get(main:FindChild("But_Friend").gameObject) --好友
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChartCtrl.ClickShowFriendChart,self)

  self.panel_charts = main:FindChild("Charts")
  for i=0,(self.panel_charts.childCount-1) do
    listener = NTGEventTriggerProxy.Get(self.panel_charts:GetChild(i).gameObject) --切换榜单
    listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(ChartCtrl.ClickSelectChart,self)
  end

  self.panel_playerinfo = GameManager.CreatePanel("PlayerInfoOnChart")

  self.IsFriendRank = false
  self.ChartType = 0
  self.myPlayerId = 0
  self.ChartDatas = {}
end

function ChartCtrl:Start()
  self:Init()
  self.self_playerinfo = self.panel_playerinfo:GetComponent("NTGLuaScript").self
  self.self_playerinfo:SetPos(self.this.transform)
end

--初始化
function ChartCtrl:Init(data,selfdata)
  self.cor_initlist = coroutine.start(self.InitList,self)
  self.IsFriendRank = ChartAPI.Instance.IsFriendRank
  self.ChartType = 1
  ChartAPI.Instance:GetRankData(self.ChartType,self.IsFriendRank,self,ChartCtrl.UpdateData)

end
--更新界面数据
function ChartCtrl:UpdateData(data,selfdata)
  self.ChartDatas = data
  self.myPlayerId = selfdata.PlayerId
  self:ChangeChartTitle(self.ChartType,self.IsFriendRank)
  self:InitMyInfo(selfdata)
  self.scroll.transform:GetComponent("UnityEngine.UI.ScrollRect").verticalNormalizedPosition = 1
  self:UpdateList(self.ChartDatas)
  self.IsWait = false
end

--查看所有榜单
function ChartCtrl:ClickAllChart(eventdata)
  local liang = eventdata.pointerPress.transform:FindChild("Liang")
  if liang.gameObject.activeSelf then 
    self.panel_charts.gameObject:SetActive(false)
    self.scroll.localPosition = Vector3.zero
    liang.gameObject:SetActive(false)
  else
    self.panel_charts.gameObject:SetActive(true)
    self.scroll.localPosition = Vector3.New(0,1000,0)
    liang.gameObject:SetActive(true)
  end
end
--切换为全区榜单
function ChartCtrl:ClickShowAllChart(eventdata)
  local liang = eventdata.pointerPress.transform:FindChild("Liang")
  if liang.gameObject.activeSelf == false or self.IsWait == false then 
    --liang.gameObject:SetActive(true)
    self.IsFriendRank = false
    ChartAPI.Instance:GetRankData(self.ChartType,self.IsFriendRank,self,ChartCtrl.UpdateData)
    self.IsWait = true
  end
end
--切换为好友榜单
function ChartCtrl:ClickShowFriendChart(eventdata)
  local liang = eventdata.pointerPress.transform:FindChild("Liang")
  if liang.gameObject.activeSelf == false or self.IsWait == false then 
    --liang.gameObject:SetActive(true)
    self.IsFriendRank = true
    ChartAPI.Instance:GetRankData(self.ChartType,self.IsFriendRank,self,ChartCtrl.UpdateData)
    self.IsWait = true
  end
end
--更换标题
function ChartCtrl:ChangeChartTitle(_type,isFriend)
  _type = tonumber(_type)
  local str_pre = ""
  local str_nex = ""
  if isFriend == true then 
    str_pre = "好友" 
    self.Main:FindChild("But_All/Liang").gameObject:SetActive(false)
    self.Main:FindChild("But_Friend/Liang").gameObject:SetActive(true)
  else
    str_pre = "全区" 
    self.Main:FindChild("But_All/Liang").gameObject:SetActive(true)
    self.Main:FindChild("But_Friend/Liang").gameObject:SetActive(false)
  end
  if _type ==1 then 
    str_nex = "天梯排行"
  elseif _type ==2 then 
    str_nex = "姬神排行"
  elseif _type ==3 then 
  str_nex = "皮肤排行"
  elseif _type ==4 then 
  str_nex = "成就排行"
  elseif _type ==5 then 
  str_nex = "胜场排行"
  elseif _type ==6 then 
  str_nex = "连续胜场排行"
  elseif _type ==7 then 
  str_nex = "贵族积分排行"
  end
  self.txt_title:GetComponent("UnityEngine.UI.Text").text = str_pre..str_nex


end


--切换榜单
function ChartCtrl:ClickSelectChart(eventdata)
  local _type = tonumber(eventdata.pointerPress.transform.name)
  self.panel_charts.gameObject:SetActive(false)
  self.Main:FindChild("But_AllChart/Liang").gameObject:SetActive(false)
  self.scroll.localPosition = Vector3.zero
  if _type == self.ChartType then return end

  self.ChartType = _type
  ChartAPI.Instance:GetRankData(self.ChartType,self.IsFriendRank,self,ChartCtrl.UpdateData)
end

--生成列表
function ChartCtrl:InitList()
  for i=1,100 do
    local tempo = GameObject.Instantiate(self.temp_list)
    tempo.gameObject:SetActive(false)
    tempo.transform:SetParent(self.grid_list)
    tempo.transform.localPosition = Vector3.zero
    tempo.transform.localRotation = Quaternion.identity
    tempo.transform.localScale = Vector3.one
    tempo.name = tostring(i)
    --排名
    local num = i
    if num ==1 then 
      tempo:FindChild("Bg").gameObject:SetActive(false)
      tempo:FindChild("Liang").gameObject:SetActive(true)
      tempo:FindChild("Num/1").gameObject:SetActive(true)
    elseif num ==2 then 
      tempo:FindChild("Num/2").gameObject:SetActive(true)
    elseif num ==3 then 
      tempo:FindChild("Num/3").gameObject:SetActive(true)
    elseif num<10 then
      tempo:FindChild("Num/Grid/Ge").gameObject:SetActive(true)
      tempo:FindChild("Num/Grid/Ge").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..num,"UnityEngine.Sprite")
    elseif num<100 then 
      tempo:FindChild("Num/Grid/Ge").gameObject:SetActive(true)
      tempo:FindChild("Num/Grid/Ge").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..num%10,"UnityEngine.Sprite")
      tempo:FindChild("Num/Grid/Shi").gameObject:SetActive(true)
      tempo:FindChild("Num/Grid/Shi").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..math.floor(num/10),"UnityEngine.Sprite")
    elseif num<1000 then 
      tempo:FindChild("Num/Grid/Ge").gameObject:SetActive(true)
      tempo:FindChild("Num/Grid/Ge").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..(i%10),"UnityEngine.Sprite")
      tempo:FindChild("Num/Grid/Shi").gameObject:SetActive(true)
      tempo:FindChild("Num/Grid/Shi").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..(math.floor(i/10)%10),"UnityEngine.Sprite")
      tempo:FindChild("Num/Grid/Bai").gameObject:SetActive(true)
      tempo:FindChild("Num/Grid/Bai").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..(math.floor(i/100)),"UnityEngine.Sprite")
    end
    --头像
    self:CreatePlayerIcon(nil,tempo:FindChild("Icon_Player"))
    --tempo.gameObject:SetActive(false)
    coroutine.step()
    --coroutine.yield(WaitForSeconds.New(0.2))
  end
  self.cor_initlist = nil
end

function ChartCtrl:UpdateList(listdata)
  if self.coroutine_updatelist ~= nil then 
    coroutine.stop(self.coroutine_updatelist)
  end
  self.coroutine_updatelist = coroutine.start(self.UpdateListMov,self,listdata)
end

function ChartCtrl:UpdateListMov(listdata)
  local count = #listdata
  for i=1,count do
    local tempo = self.grid_list:FindChild(tostring(i))
    while tempo==nil do 
      coroutine.step()
      tempo = self.grid_list:FindChild(tostring(i))
    end
    tempo.gameObject:SetActive(true)
    coroutine.step()
    local data = listdata[i]
    --头像
    self:CreatePlayerIcon(data,tempo:FindChild("Icon_Player"))
    --名称
    tempo:FindChild("Txt_PlayerName"):GetComponent("UnityEngine.UI.Text").text = tostring(data.PlayerName)
    --等级
    tempo:FindChild("Txt_PlayerLevel"):GetComponent("UnityEngine.UI.Text").text = "Lv."..tostring(data.PlayerLevel)
    --信息
    tempo:FindChild("Txt_Left"):GetComponent("UnityEngine.UI.Text").text = tostring(data.TxtLeft)
    tempo:FindChild("Txt_Right"):GetComponent("UnityEngine.UI.Text").text = tostring(data.TxtRight)
    --排位
    if data.IsRank == true then
      tempo:FindChild("Rank").gameObject:SetActive(true)
      tempo:FindChild("Rank/Name"):GetComponent("UnityEngine.UI.Text").text = tostring(data.RankName)
      tempo:FindChild("Rank/Star"):GetComponent("UnityEngine.UI.Text").text = tostring(data.RankStar)
      tempo:FindChild("Rank/Icon").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("rankicon-"..data.RankIcon,data.RankIcon,"UnityEngine.Sprite")  
    else
      tempo:FindChild("Rank").gameObject:SetActive(false)
    end

    --加好友 or 送金币
    tempo:FindChild("But_AddFriend").gameObject:SetActive(false)
    tempo:FindChild("But_SendCoin").gameObject:SetActive(false)
    tempo:FindChild("SendCoinOver").gameObject:SetActive(false)
    if data.PlayerId ~= self.myPlayerId then
      if data.IsFriend == false then
        tempo:FindChild("But_AddFriend").gameObject:SetActive(true)
      else
        if self:GetFriendDataByPlayerId(data.PlayerId).IsGivenCoin == true then
          tempo:FindChild("SendCoinOver").gameObject:SetActive(true)
        else
          tempo:FindChild("But_SendCoin").gameObject:SetActive(true)
        end
      end  
    end 
    local listener = {}
    listener = NTGEventTriggerProxy.Get(tempo:FindChild("But_AddFriend").gameObject)--添加好友
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(ChartCtrl.ClickListAddFriend,self)
    listener = NTGEventTriggerProxy.Get(tempo:FindChild("But_SendCoin").gameObject)--送金币
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(ChartCtrl.ClickSendCoin,self)
    --查看信息
    UITools.GetLuaScript(tempo:FindChild("Click").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,ChartCtrl.ClickOpenPlayerInfo,i)
  end

  --隐藏剩余的item
  local gridCount = (self.grid_list.childCount-1)
  for j=gridCount,count,-1 do
    self.grid_list:GetChild(j).gameObject:SetActive(false)
  end
  self.coroutine_updatelist = nil

end

--显示自己的信息
function ChartCtrl:InitMyInfo(data)
  local tempo = self.myInfo
  --排名
  local numTran = tempo:FindChild("Num")
  for i=numTran.childCount-1,0,-1 do
    numTran:GetChild(i).gameObject:SetActive(false)
  end
  local grid = tempo:FindChild("Num/Grid")
  grid.gameObject:SetActive(true)
  for i=grid.childCount-1,0,-1 do
    grid:GetChild(i).gameObject:SetActive(false)
  end

  local num = data.Num
  if num ==1 then 
    numTran:FindChild("1").gameObject:SetActive(true)
  elseif num ==2 then 
    numTran:FindChild("2").gameObject:SetActive(true)
  elseif num ==3 then 
    numTran:FindChild("3").gameObject:SetActive(true)
  elseif num<10 then
    numTran:FindChild("Txt").gameObject:SetActive(true)
    grid:FindChild("Ge").gameObject:SetActive(true)
    grid:FindChild("Ge").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..num,"UnityEngine.Sprite")
  elseif num<=100 then 
    numTran:FindChild("Txt").gameObject:SetActive(true)
    grid:FindChild("Ge").gameObject:SetActive(true)
    grid:FindChild("Ge").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..num%10,"UnityEngine.Sprite")
    grid:FindChild("Shi").gameObject:SetActive(true)
    grid:FindChild("Shi").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..math.floor(num/10),"UnityEngine.Sprite")
    if num == 100 then
      grid:FindChild("Bai").gameObject:SetActive(true)
      grid:FindChild("Bai").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum","1","UnityEngine.Sprite")  
    end
  elseif num>100 then 
    numTran:FindChild("Txt").gameObject:SetActive(true)
    numTran:FindChild("Loser").gameObject:SetActive(true)
  end
  --头像
  if tempo:FindChild("Icon/Icon")==nil then 
    self:CreatePlayerIcon(data,tempo:FindChild("Icon"))
  end
  --名称
  tempo:FindChild("Txt_PlayerName"):GetComponent("UnityEngine.UI.Text").text = tostring(data.PlayerName)
  --等级
  tempo:FindChild("Txt_PlayerLevel"):GetComponent("UnityEngine.UI.Text").text = "Lv."..tostring(data.PlayerLevel)
  --信息
  tempo:FindChild("Txt_Left"):GetComponent("UnityEngine.UI.Text").text = tostring(data.TxtLeft)
  tempo:FindChild("Txt_Right"):GetComponent("UnityEngine.UI.Text").text = tostring(data.TxtRight)
  --排位
  if data.IsRank == true then
    tempo:FindChild("Rank").gameObject:SetActive(true)
    tempo:FindChild("Rank/Name"):GetComponent("UnityEngine.UI.Text").text = tostring(data.RankName)
    tempo:FindChild("Rank/Star"):GetComponent("UnityEngine.UI.Text").text = tostring(data.RankStar)
    tempo:FindChild("Rank/Icon").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("rankicon-"..data.RankIcon,data.RankIcon,"UnityEngine.Sprite")
   
  else
    tempo:FindChild("Rank").gameObject:SetActive(false)
  end
end

--生成一个玩家头像
function ChartCtrl:CreatePlayerIcon(data,_parent)
  local temp = _parent:FindChild("Icon")
  if temp == nil then 
    temp = GameObject.Instantiate(self.temp_playericon)
    temp.name = "Icon"
    temp.gameObject:SetActive(true)
    temp.transform:SetParent(_parent)
    temp.transform.localPosition = Vector3.zero
    temp.transform.localRotation = Quaternion.identity
    temp.transform.localScale = Vector3.one
  end
  if data == nil then return end
  if data.PlayerIcon~="" then 
    temp:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",tostring(data.PlayerIcon),"UnityEngine.Sprite")
    temp:FindChild("Icon").gameObject:SetActive(true)
  end
  if data.VipIcon == "" then
    temp:FindChild("Vip").gameObject:SetActive(false)
  else
    temp:FindChild("Vip").gameObject:SetActive(true)
    temp:FindChild("Vip"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("vipicon",tostring(data.VipIcon),"UnityEngine.Sprite")
  end
  if data.PlayerFrame ~= "" then
    temp:FindChild("Bg"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("frameicon",tostring(data.PlayerFrame),"UnityEngine.Sprite")
    temp:FindChild("Bg").gameObject:SetActive(true)
  end
  --在线
  temp:FindChild("OffLine").gameObject:SetActive(false)
  if data.IsOffline == true and data.PlayerId ~=self.myPlayerId then
    temp:FindChild("OffLine").gameObject:SetActive(true)
  end
  
end
--显示 信息面板
function ChartCtrl:ClickOpenPlayerInfo(index)
  self.currPlayerId = self.ChartDatas[index].PlayerId
  if self.myPlayerId == self.currPlayerId  then return end
  --GameManager.CreatePanel("PlayerInfoOnChart")
  local canInvite = false
  if ChartAPI.Instance:IsMyFriend(self.currPlayerId) == true then canInvite = true end
  --PlayerInfoOnChartAPI.Instance:Init(self.ChartDatas[index],"Chart",canInvite) 
  self.self_playerinfo:Init(self.ChartDatas[index],"Chart",canInvite) 
end

--添加好友 列表上添加
function ChartCtrl:ClickListAddFriend(eventdata)
  local index = tonumber(eventdata.pointerPress.transform.parent.name)
  local playerId = self.ChartDatas[index].PlayerId
  self:AddFriend(playerId)
end

--判断是否为好友
function ChartCtrl:GetFriendDataByPlayerId(playerId)
  for k,v in pairs(UTGData.Instance().FriendList) do
    if v.PlayerId == playerId then
      return v
    end
  end
  return nil
end

--添加好友
function ChartCtrl:AddFriend(playerId)
  GameManager.CreatePanel("AddFriend")
  if AddFriendAPI~=nil and AddFriendAPI.Instance~=nil then
      AddFriendAPI:SetPlayerId(playerId)
  end
end
--送金币
function ChartCtrl:ClickSendCoin(eventdata)
  local temp = eventdata.pointerPress.transform.parent
  local index = tonumber(temp.name)
  local friendId = self:GetFriendDataByPlayerId(self.ChartDatas[index].PlayerId).Id 
  self:RequestGiveFriendCoin(friendId)
  temp:FindChild("But_SendCoin").gameObject:SetActive(false)
  temp:FindChild("SendCoinOver").gameObject:SetActive(true)
end
function ChartCtrl:RequestGiveFriendCoin(friendid)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestGiveFriendCoin"),
                                JProperty.New("FriendId",tonumber(friendid)))
  request.Handler = TGNetService.NetEventHanlderSelf(ChartCtrl.RequestGiveFriendCoinHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self.friendType = tonumber(type)
end
function ChartCtrl:RequestGiveFriendCoinHandler(e)
  if e.Type =="RequestGiveFriendCoin" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
    else
      --Debugger.LogError("RequestGiveFriendCoin Result == "..result)
    end
    return true
  end
  return false
end

--返回大厅
function ChartCtrl:ClickClosePanel()
  if self.cor_initlist~=nil then coroutine.stop(self.cor_initlist) end
  if self.coroutine_updatelist~=nil then coroutine.stop(self.coroutine_updatelist) end
  self.cor_initlist=nil
  self.coroutine_updatelist=nil
  self.ani:Play("hide")
  coroutine.start(ChartCtrl.ClickClosePanelMov,self)
end

function ChartCtrl:ClickClosePanelMov()
  coroutine.wait(0.3)
  self.this.gameObject:SetActive(false)
  coroutine.step()
  ChartAPI.Instance:InitChartOnMainPanel()
  coroutine.wait(0.1)
  Object.Destroy(self.this.gameObject)

end


function ChartCtrl:OnDestroy()
  if self.cor_initlist~=nil then coroutine.stop(self.cor_initlist) end
  if self.coroutine_updatelist~=nil then coroutine.stop(self.coroutine_updatelist) end
  self.this = nil
  self = nil
end