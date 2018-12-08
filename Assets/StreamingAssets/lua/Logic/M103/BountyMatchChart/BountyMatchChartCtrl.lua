--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("BountyMatchChartCtrl")
local json = require "cjson"

function BountyMatchChartCtrl:Awake(this)
  self.this = this
  --self.ani = this.transform:GetComponent("Animator")
  self.top = this.transforms[0]
  self.wu = this.transforms[1]
  --Main 
  local main = this.transform
  self.Main = main
  self.myInfo = main:FindChild("MyInfo")
  self.grid_list = main:FindChild("ScrollView/Grid")
  self.temp_playericon = main:FindChild("Temp_PlayerIcon")
  self.temp_list = main:FindChild("Temp_List")

  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end

function BountyMatchChartCtrl:Start()
  self:Init()
end

--请求全服排行
function BountyMatchChartCtrl:RequestServerRanks(type)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestServerRanks"),
                                JProperty.New("RankType",tonumber(type)))
  request.Handler = TGNetService.NetEventHanlderSelf(BountyMatchChartCtrl.RequestServerRanksHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self.serverType = tonumber(type)
end

--请求全服排行 回调
function BountyMatchChartCtrl:RequestServerRanksHandler(e)
  if e.Type =="RequestServerRanks" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      local datas = json.decode(e.Content:get_Item("Ranks"):ToString())
      local selfdata = json.decode(e.Content:get_Item("Self"):ToString())
      if datas == nil or selfdata == nil then  
        Debugger.LogError(" info == nil") 
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

--整理数据 
function BountyMatchChartCtrl:ClearUpData(rankdata,selfdata,type,isFriend)
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

  self:InitData(data,selfData)
end

--整理数据one
function BountyMatchChartCtrl:ClearUpOneData(data,type)
  local temp = {}
  type = tonumber(type)
  temp.PlayerId = data.PlayerId
  temp.PlayerName = data.PlayerName
  temp.PlayerIcon = data.Icon
  temp.IconFrame = UTGData.Instance().AvatarFramesData[tostring(data.IconFrameId)].Icon
  temp.VipIcon = "" 
  if data.VipLevel>0 then temp.VipIcon = "v"..data.VipLevel end
  temp.PlayerLevel = data.Level
  temp.IsOffline = data.IsOffline
  if data.IsOffline == false then     
    temp.StateStr = "在线"
  else
    temp.StateStr = "离线"
  end
  temp.TxtLeft = ""
  temp.TxtRight = ""
  if type == 8 then
    temp.TxtLeft = "获得十胜次数："
    temp.TxtRight = tostring(data.Info[1])
  end
  return temp
end

--初始化
function BountyMatchChartCtrl:Init()
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("BountyMatchChartPanel/Main/Top")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,self.ClickClosePanel,nil,nil,"排行榜")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(topAPI)

  self:RequestServerRanks(8)
end

function BountyMatchChartCtrl:InitData(data,selfdata)
  self:InitMyInfo(selfdata)
  if #data>0 then 
    self:InitList(data)
  else
    self.wu.gameObject:SetActive(true)
  end
end

function BountyMatchChartCtrl:InitList(listdata)
  self.cor_initlist = coroutine.start(self.InitListMov,self,listdata)
end

function BountyMatchChartCtrl:InitListMov(listdata)
  local count = #listdata
  for i=1,count do
    local tempo = GameObject.Instantiate(self.temp_list)
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
    --查看信息
    UITools.GetLuaScript(tempo:FindChild("Click").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,BountyMatchChartCtrl.ClickOpenPlayerInfo,data.PlayerId)
    coroutine.step()
  end

  self.cor_initlist = nil

end

--显示自己的信息
function BountyMatchChartCtrl:InitMyInfo(data)
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
  --tempo:FindChild("Txt_PlayerLevel"):GetComponent("UnityEngine.UI.Text").text = "Lv."..tostring(data.PlayerLevel)
  --信息
  tempo:FindChild("Txt_Left"):GetComponent("UnityEngine.UI.Text").text = tostring(data.TxtLeft)
  tempo:FindChild("Txt_Right"):GetComponent("UnityEngine.UI.Text").text = tostring(data.TxtRight)

end

--生成一个玩家头像
function BountyMatchChartCtrl:CreatePlayerIcon(data,_parent)
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
  temp:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",tostring(data.PlayerIcon),"UnityEngine.Sprite")
  if data.VipIcon == "" then
    temp:FindChild("Vip").gameObject:SetActive(false)
  else
    temp:FindChild("Vip").gameObject:SetActive(true)
    temp:FindChild("Vip"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("vipicon",tostring(data.VipIcon),"UnityEngine.Sprite")
  end
  temp:FindChild("Bg"):GetComponent("UnityEngine.UI.Image").sprite =NTGResourceController.Instance:LoadAsset("frameicon",tostring(data.IconFrame),"UnityEngine.Sprite") 
  
end

--显示 信息面板
function BountyMatchChartCtrl:ClickOpenPlayerInfo(playerId)
  GameManager.CreatePanel("PlayerData")
  if PlayerDataAPI~=nil and PlayerDataAPI.Instance~=nil then
     PlayerDataAPI.Instance:Init(playerId)
  end
end


function BountyMatchChartCtrl:ClickClosePanel()
  Object.Destroy(self.this.transform.parent.gameObject)
end


function BountyMatchChartCtrl:OnDestroy()
  if self.cor_initlist~=nil then coroutine.stop(self.cor_initlist) end
  self.this = nil
  self = nil
end