--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("BattleResult29Ctrl")
local json = require "cjson"

function BattleResult29Ctrl:Awake(this)
  self.this = this
  self.root = this.transforms[0]

  self.root.gameObject:SetActive(false)
  self.topRoot = self.root:FindChild("top")
  self.but_top_friend = this.transforms[1].gameObject
  self.but_top_jubao = this.transforms[2].gameObject
  self.but_top_all = this.transforms[3].gameObject
  self.but_top_data = this.transforms[4].gameObject

  self.panel_cj = this.transforms[5]
  self.panel_jubao = this.transforms[6]
  self.chatFrame = this.transforms[7]
  self.panel_blue = this.transforms[8]
  self.panel_red = this.transforms[9]


  self.Input_jubao = self.panel_jubao:FindChild("input"):GetComponent("UnityEngine.UI.InputField")

  self.obj_allPlayer = {}
  self.data_allPlayer = {}
  self.obj_all = {}
  self.myPlayerId = 0
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.root:FindChild("but_close").gameObject) --返回大厅
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.ClickBack2MainPanel,self)
  listener = NTGEventTriggerProxy.Get(self.but_top_friend.gameObject) --加好友
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.Click_Top_Friend,self)
  listener = NTGEventTriggerProxy.Get(self.but_top_jubao.gameObject) --举报
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.Click_Top_JuBao,self)
  listener = NTGEventTriggerProxy.Get(self.but_top_all.gameObject) --总览
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.Click_Top_All,self)
  listener = NTGEventTriggerProxy.Get(self.but_top_data.gameObject) --数据
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.Click_Top_Data,self)


end

function BattleResult29Ctrl:Start()

end
--初始化
function BattleResult29Ctrl:Init(data)
  self.root.gameObject:SetActive(true)
  self:Init_Top(data.isWin)
  self:Init_Common(data.duration,data.startTime,data.teamA_score,data.teamB_score,100,100)

  self:Fill_Team(data.teamA,self.panel_blue:FindChild("grid"))
  self:Fill_Team(data.teamB,self.panel_red:FindChild("grid"))
  
  self:Init_Chat()
  self:WaitClearUpBattle()
  
end

--初始化聊天
function BattleResult29Ctrl:Init_Chat()
  self.coroutine_initchat = coroutine.start(self.InitChatMov,self)
end
function BattleResult29Ctrl:InitChatMov()
  local chat = GameManager.CreatePanelAsync("Chat")
  while chat.Done == false do
    coroutine.step() 
  end
  local chatSelf = chat.Panel:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
  chatSelf.self:InitChat(self.chatFrame,self.chatFrame.parent,"BattleResult")
  self.chatFrame.gameObject:SetActive(true)
  self.coroutine_initchat = nil 
end

--显示top
function BattleResult29Ctrl:Init_Top(isVic)
  if isVic == 1 then 
    self.topRoot:FindChild("1").gameObject:SetActive(true)
  else
    self.topRoot:FindChild("0").gameObject:SetActive(true)
  end
end

--显示基础信息
function BattleResult29Ctrl:Init_Common(allTime,startTime,score_blue,score_red,pre_xy,nex_xy)
  local allTimeStr = string.format("%02d:%02d",allTime/60,allTime%60)
  self.root:FindChild("alltime"):GetComponent("UnityEngine.UI.Text").text = allTimeStr

  local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"
  local timeToConvert = tostring(startTime)
  local runyear, runmonth, runday, runhour, runminute, runseconds = timeToConvert:match(pattern)
  --print(runyear, runmonth, runday, runhour, runminute, runseconds)
  local startTimeStr = string.format("%s/%s/%s %s:%s",runyear, runmonth, runday, runhour, runminute)

  self.root:FindChild("starttime"):GetComponent("UnityEngine.UI.Text").text = startTimeStr
  self.root:FindChild("score_blue"):GetComponent("UnityEngine.UI.Text").text = tostring(score_blue)
  self.root:FindChild("score_red"):GetComponent("UnityEngine.UI.Text").text = tostring(score_red)
  local add_xy = nex_xy-pre_xy
  self.root:FindChild("txtxinyu"):GetComponent("UnityEngine.UI.Text").text = ""--string.format("信誉积分 %s（%s）",nex_xy,add_xy)
end


--初始化队伍
function BattleResult29Ctrl:Init_Team( )

end

--生成队伍UI 
function BattleResult29Ctrl:Fill_Team(data,grid)
  local api = grid:GetComponent("NTGLuaScript").self
  if data==nil then
    api:ResetItemsSimple(0)
    Debugger.LogError("队伍数据不存在~~~~~~")
    return
  end

  api:ResetItemsSimple(#data)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform
    if data[i].IsAi == false then
      self.obj_allPlayer[tostring(data[i].PlayerId)] = tempo
      self.data_allPlayer[tostring(data[i].PlayerId)] = data[i]
    end
    table.insert(self.obj_all,tempo)
    local listener = {}
    tempo.name = tostring(data[i].PlayerId)
    tempo:FindChild("mask/icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",tostring(data[i].RoleIcon),"UnityEngine.Sprite")
    tempo:FindChild("rolelv"):GetComponent("UnityEngine.UI.Text").text = tostring(data[i].RoleLv)
    tempo:FindChild("rolename"):GetComponent("UnityEngine.UI.Text").text = tostring(data[i].RoleName)
    -- 是玩家本人
    if data[i].IsMe then 
      tempo:FindChild("playername_own"):GetComponent("UnityEngine.UI.Text").text = ""..data[i].PlayerName
      tempo:FindChild("own").gameObject:SetActive(true)
      self.myPlayerId = data[i].PlayerId
    else
      tempo:FindChild("playername"):GetComponent("UnityEngine.UI.Text").text = ""..data[i].PlayerName
    end
    -- 是MPV
    if data[i].IsMVP then tempo:FindChild("mvp").gameObject:SetActive(true) end 
    --成就
    local grid_cj = tempo:FindChild("grid_cj")
    local count_cj = 0 
    for k,v in pairs(data[i].Title) do
      for k1,v1 in pairs(v) do
        if v1 == true then
          grid_cj:GetChild(count_cj).gameObject:SetActive(true)
          grid_cj:GetChild(count_cj):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("BattleResult28",tostring(k1),"UnityEngine.Sprite") 
          count_cj = count_cj + 1
        end
      end
    end
    listener = NTGEventTriggerProxy.Get(tempo:FindChild("grid_cj").gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.Click_ShowPanel_CJ,self)
    --装备
    local grid_equip = tempo:FindChild("common/grid_equip")
    for j=1,6 do
      if data[i].EquipIcon[j] ~="" then
        grid_equip:GetChild(j-1):FindChild("icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("equipicon",tostring(data[i].EquipIcon[j]),"UnityEngine.Sprite")
      else
        grid_equip:GetChild(j-1):FindChild("icon").gameObject:SetActive(false)
      end
    end
    --击杀 死亡 助攻 金币
    tempo:FindChild("common/kill"):GetComponent("UnityEngine.UI.Text").text = ""..data[i].KillAmount
    tempo:FindChild("common/dead"):GetComponent("UnityEngine.UI.Text").text = ""..data[i].DeadAmount
    tempo:FindChild("common/sec"):GetComponent("UnityEngine.UI.Text").text = ""..data[i].SecAmount
    tempo:FindChild("common/coin"):GetComponent("UnityEngine.UI.Text").text = ""..data[i].CoinAmount
    --总输出 对英雄伤害 承受伤害
    --Debugger.LogError("data[i].AllNum == "..data[i].AllNum)
    tempo:FindChild("data/all/num"):GetComponent("UnityEngine.UI.Text").text = ""..data[i].AllNum
    tempo:FindChild("data/hero/num"):GetComponent("UnityEngine.UI.Text").text = ""..data[i].HeroNum
    tempo:FindChild("data/pain/num"):GetComponent("UnityEngine.UI.Text").text = ""..data[i].PainNum

    tempo:FindChild("data/all/img"):GetComponent("UnityEngine.UI.Image").fillAmount = data[i].AllPer
    tempo:FindChild("data/hero/img"):GetComponent("UnityEngine.UI.Image").fillAmount = data[i].HeroPer
    tempo:FindChild("data/pain/img"):GetComponent("UnityEngine.UI.Image").fillAmount = data[i].PainPer

    tempo:FindChild("data/all/percent"):GetComponent("UnityEngine.UI.Text").text = string.format("%d%%",(data[i].AllPer*100))
    tempo:FindChild("data/hero/percent"):GetComponent("UnityEngine.UI.Text").text =string.format("%d%%",(data[i].HeroPer*100))
    tempo:FindChild("data/pain/percent"):GetComponent("UnityEngine.UI.Text").text =string.format("%d%%",(data[i].PainPer*100))
    --是否 可以添加好友 可以举报
    data[i].CanAddFriend = false
    data[i].CanJuBao = false
    if data[i].IsAi == false and data[i].PlayerId>0 then
      if self:IsMyFriend(data[i].PlayerId) ==false and data[i].PlayerId ~=self.myPlayerId then
        data[i].CanAddFriend = true
        data[i].CanJuBao = true
      end
    end

    --添加 加好友 举报 事件
    listener = NTGEventTriggerProxy.Get(tempo:FindChild("but_friend").gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.Click_ShowPanel_AddFriend,self)
    listener = NTGEventTriggerProxy.Get(tempo:FindChild("but_jubao").gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.Click_ShowPanel_JuBao,self)
  end

  --默认
  self:Click_Top_Friend()
  self:Click_Top_All()
end


--显示 称号面板
function BattleResult29Ctrl:Click_ShowPanel_CJ()
  self.panel_cj.gameObject:SetActive(true)
  local listener = NTGEventTriggerProxy.Get(self.panel_cj:FindChild("close").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.Click_ClosePanel_CJ,self)
end
--关闭 称号面板
function BattleResult29Ctrl:Click_ClosePanel_CJ()
  self.panel_cj.gameObject:SetActive(false)
end

--显示 加好友面板
function BattleResult29Ctrl:Click_ShowPanel_AddFriend(eventdata)
  local playerId = eventdata.pointerPress.transform.parent.name
  self.data_allPlayer[playerId].CanAddFriend = false
  self.obj_allPlayer[playerId]:FindChild("but_friend").gameObject:SetActive(false)

  GameManager.CreatePanel("AddFriend")
  if AddFriendAPI~=nil and AddFriendAPI.Instance~=nil then
      AddFriendAPI:SetPlayerId(tonumber(playerId))
  end

end

--判断是否为好友
function BattleResult29Ctrl:IsMyFriend(playerId)
  for k,v in pairs(UTGData.Instance().FriendList) do
    if v.PlayerId == playerId then
      return true
    end
  end
  return false
end


--显示 举报面板
function BattleResult29Ctrl:Click_ShowPanel_JuBao(eventdata)
  local playerId = eventdata.pointerPress.transform.parent.name
  self.data_allPlayer[playerId].CanJuBao = false
  self.obj_allPlayer[playerId]:FindChild("but_jubao").gameObject:SetActive(false)

  self.panel_jubao.gameObject:SetActive(true)
  self.panel_jubao:FindChild("title"):GetComponent("UnityEngine.UI.Text").text = "您正在举报"..self.data_allPlayer[playerId].PlayerName

  local listener = {}
  for i=1,self.panel_jubao:FindChild("grid").childCount do
    local temp = self.panel_jubao:FindChild("grid"):GetChild(i-1):GetComponent("UnityEngine.UI.Toggle")
    temp.isOn = false
  end
  self.Input_jubao.text = "请输入你要举报的内容（最多80字）"

  listener = NTGEventTriggerProxy.Get(self.panel_jubao:FindChild("close").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.Click_ClosePanel_JuBao,self)
  listener = NTGEventTriggerProxy.Get(self.panel_jubao:FindChild("but_close").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.Click_ClosePanel_JuBao,self)
  listener = NTGEventTriggerProxy.Get(self.panel_jubao:FindChild("but_ok").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult29Ctrl.Click_Send_JuBao,self)
end

--发送举报信息
function BattleResult29Ctrl:Click_Send_JuBao()
  local info = self.Input_jubao.text
  if self:utfstrlen(info)>80 then
    return
  else
  end
  self.panel_jubao.gameObject:SetActive(false)
end

--关闭 举报面板
function BattleResult29Ctrl:Click_ClosePanel_JuBao()
  self.panel_jubao.gameObject:SetActive(false)
end


--显示 添加好友
function BattleResult29Ctrl:Show_AddFriend()
  for k,v in pairs(self.obj_allPlayer) do
    v:FindChild("but_friend").gameObject:SetActive(false)
    v:FindChild("but_jubao").gameObject:SetActive(false)
    if self.data_allPlayer[k].CanAddFriend then
      v:FindChild("but_friend").gameObject:SetActive(true)
    end
  end
end

--显示 举报玩家
function BattleResult29Ctrl:Show_JuBao()
  for k,v in pairs(self.obj_allPlayer) do
    v:FindChild("but_friend").gameObject:SetActive(false)
    v:FindChild("but_jubao").gameObject:SetActive(false)
    if self.data_allPlayer[k].CanJuBao then
      v:FindChild("but_jubao").gameObject:SetActive(true)
    end
  end
end

--显示 总览
function BattleResult29Ctrl:Show_All()
  self.panel_blue:FindChild("common").gameObject:SetActive(true)
  self.panel_blue:FindChild("data").gameObject:SetActive(false)
  self.panel_red:FindChild("common").gameObject:SetActive(true)
  self.panel_red:FindChild("data").gameObject:SetActive(false)
  for i=1,#self.obj_all do
    local temp = self.obj_all[i]
    temp:FindChild("common").gameObject:SetActive(true)
    temp:FindChild("data").gameObject:SetActive(false)
  end
end

--显示 数据
function BattleResult29Ctrl:Show_Data()
  self.panel_blue:FindChild("common").gameObject:SetActive(false)
  self.panel_blue:FindChild("data").gameObject:SetActive(true)
  self.panel_red:FindChild("common").gameObject:SetActive(false)
  self.panel_red:FindChild("data").gameObject:SetActive(true)
  for i=1,#self.obj_all do
    local temp = self.obj_all[i]
    temp:FindChild("common").gameObject:SetActive(false)
    temp:FindChild("data").gameObject:SetActive(true)
  end
end


--右上 好友
function BattleResult29Ctrl:Click_Top_Friend()
  self.but_top_friend:SetActive(false)
  self.but_top_jubao:SetActive(true)
  self:Show_AddFriend()
end
--右上 举报
function BattleResult29Ctrl:Click_Top_JuBao()
  self.but_top_friend:SetActive(true)
  self.but_top_jubao:SetActive(false)
  self:Show_JuBao()
end
--右上 总览
function BattleResult29Ctrl:Click_Top_All()
  self.but_top_all:SetActive(false)
  self.but_top_data:SetActive(true)
  self:Show_All()
end
--右上 数据
function BattleResult29Ctrl:Click_Top_Data()
  self.but_top_data:SetActive(false)
  self.but_top_all:SetActive(true)
  self:Show_Data()
end

--获取utf格式的字符串长度
function BattleResult29Ctrl:utfstrlen(str)
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

--打扫战场 创建主面板
function BattleResult29Ctrl:WaitClearUpBattle()
  coroutine.start(BattleResult29Ctrl.WaitClearUpBattleMov,self)
end

--加载主界面
function BattleResult29Ctrl:WaitClearUpBattleMov()
  while self.coroutine_initchat~=nil do
    coroutine.step()
  end

  local result = GameManager.CreatePanelAsync("UTGMain")
  while result.Done~= true do
    coroutine.step() 
  end
  if UTGMainPanelAPI.Instance ~=nil then 
    UTGMainPanelAPI.Instance:HideSelf() 
    UTGMainPanelAPI.Instance:AudioControl(0)

    local result_mian = UTGMainPanelAPI.Instance:Init()
    while result_mian.Done~= true do
      coroutine.step() 
    end
  end
  
  local result_LoadAsset = UTGDataOperator.Instance:LoadAssetAsync()

  self.root:FindChild("loading").gameObject:SetActive(false)
  self.root:FindChild("but_close").gameObject:SetActive(true)
end

--返回大厅
function BattleResult29Ctrl:ClickBack2MainPanel()

  local function anonyFunc(args)
    UTGMainPanelAPI.Instance:ShowSelf()
    UTGMainPanelAPI.Instance:AudioControl(0.2)
    local request = NetRequest.New()
    request.Content = JObject.New(JProperty.New("Type","RequestRemoveBattleStatus"))--移除玩家战斗状态
    TGNetService.GetInstance():SendRequest(request)
  
    Object.Destroy(BattleResult29API.Instance.this.gameObject)
  end

  UTGDataOperator.Instance:NewAchievePanelOpen(anonyFunc)
end



function BattleResult29Ctrl:OnDestroy()
  NTGResourceController.Instance:UnloadAssetBundle("BattleResult29", true,false)
  NTGResourceController.Instance:UnloadAssetBundle("BattleResult28", true,false)
  
  self.this = nil
  self = nil
end