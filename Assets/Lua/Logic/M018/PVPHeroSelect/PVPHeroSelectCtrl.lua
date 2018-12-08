--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
require "Logic.UTGData.UTGDataTemporary"
class("PVPHeroSelectCtrl")

local json = require "cjson"

function PVPHeroSelectCtrl:Awake(this)
  self.this = this

  --添加点击事件
  local listener = NTGEventTriggerProxy.Get(this.transforms[0].gameObject)--英雄按钮
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.ClickHeroLis,self) 
  listener = NTGEventTriggerProxy.Get(this.transforms[1].gameObject)--皮肤按钮
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.ClickHeroSkinLis,self) 
  listener = NTGEventTriggerProxy.Get(this.transforms[2].gameObject)--英雄多列表——进入
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.ClickHeroBigLis,self) 
  listener = NTGEventTriggerProxy.Get(this.transforms[3].gameObject)--英雄多列表——退出
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.ClickCloseHeroBigLis,self)
  listener = NTGEventTriggerProxy.Get(this.transforms[4].gameObject)--确定
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.ClickSelectOK,self)
  listener = NTGEventTriggerProxy.Get(this.transforms[5].gameObject)--取消
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.ClickCancel,self)

  listener = NTGEventTriggerProxy.Get(this.transforms[9].gameObject)--更换
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.ClickChangePlayerSkill,self)
  
  self.skilltip = this.transforms[10]

  self.skinwu = this.transforms[13]
  self.skinwu.gameObject:SetActive(true)
  self.skinyou = this.transforms[21]
  self.skinyou.gameObject:SetActive(false)
  
  self.herowu = this.transforms[14]
  
  self.heroinfo = this.transforms[18]

  self.heroListGrid = self.this.transforms[16]
  self.skinListGrid = self.this.transforms[22]
  
  self.panel ={}
  self.panel["bigherolis"] = this.transforms[15]
  self.panel["herolis"] = this.transforms[19]
  self.panel["skinlis"] = this.transforms[20]
  self.panel["root"] = this.transform:FindChild("root")
  self.panel["middle"] = this.transform:FindChild("root/middle")
  self.panel["right"] = this.transform:FindChild("root/right")
  self.panel["left"] = this.transform:FindChild("root/left")

  self.modelRoot = self.panel["middle"]:FindChild("model")
  self.tiyanTimeTran = self.heroinfo:FindChild("tiyanTime")
  self.time_common = self.panel["right"]:FindChild("time/time/common")
  self.time_over = self.panel["right"]:FindChild("time/time/over")
  self.txttime = self.panel["right"]:FindChild("time/time/common/txt")
  self.timefx_over = self.panel["right"]:FindChild("time/time/over/fx")
  self.canUseRoleDataList = {}
  self.skinlis = {}
  self.select_role = nil
  self.herolisloaded = false 
  self.right_player = {}
  
  --一些参数
  self.param_herolis_width = 286
  self.param_herobiglis_width = 1053
  self.param_herolis_height = 643
  self.myPlayerId = UTGData.Instance().PlayerData.Id
  self.RoleLock = false
  self.roleIconTranList = {}

  --特效
  self:SetFxOk(self.heroinfo.parent)  
  self:SetFxOk(self.time_over)  

end
------tools function-------
function PVPHeroSelectCtrl:SetFxOk(model)
  local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,btn.Length - 1 do
    model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
  end
end

function PVPHeroSelectCtrl:CreateGameObject(obj,parent)
  local temp = GameObject.Instantiate(obj)
  temp.transform:SetParent(parent)
  temp.transform.localPosition = Vector3.zero
  temp.transform.localRotation = Quaternion.identity
  temp.transform.localScale = Vector3.one
  return temp
end


--------------------------

function PVPHeroSelectCtrl:Start()
  self.modelRoot:SetParent(nil)
  self.modelRoot.localPosition = Vector3.zero
  self.modelRoot.localRotation = Quaternion.identity
  self.modelRoot.localScale = Vector3.one
  self.panel["herolis"].gameObject:SetActive(false)
end

function PVPHeroSelectCtrl:Init(mainType,subType,time,partyData)
  --监听party变更
  self.Delegate_NotifyPartyChange = TGNetService.NetEventHanlderSelf(PVPHeroSelectCtrl.NotifyPartyChange,self)
  TGNetService.GetInstance():AddEventHandler("NotifyPartyChange",self.Delegate_NotifyPartyChange,1)
  --监听进入战斗加载
  self.Delegate_UpdateBattlePreStart = TGNetService.NetEventHanlderSelf(PVPHeroSelectCtrl.UpdateBattlePreStart,self)
  TGNetService.GetInstance():AddEventHandler("NotifyBattlePreStart", self.Delegate_UpdateBattlePreStart,1)
  --监听进入战斗加载
  self.Delegate_NetNotifyBattleStart = TGNetService.NetEventHanlderSelf(PVPHeroSelectCtrl.NetNotifyBattleStart,self)
  TGNetService.GetInstance():AddEventHandler("NotifyUTGPVPBattleStart",self.Delegate_NetNotifyBattleStart,1)
  --监听娱乐模式变化
  self.Delegate_NotifyBattleConfigClone = TGNetService.NetEventHanlderSelf(PVPHeroSelectCtrl.NotifyBattleConfigClone,self)
  TGNetService.GetInstance():AddEventHandler("NotifyBattleConfigClone",self.Delegate_NotifyBattleConfigClone,1)

  self.partydata = partyData 
  --芯片初始化
  PVPHeroSelectAPI.Instance:RuneInit()

  --判断模式
  self.subType = subType
  if self.subType == 80 then -- 克隆大作战
    self.cloneMode = true
  end
  if self.subType == 51 then --大乱斗
    self.daluanDouMode = true
    self:Init_DaluanDou(partyData)
  else
    self:Init_Common(partyData)
  end
  --聊天初始化
  if (partyData.MPlayerCount + partyData.MRobotCount)>=2 then
    PVPHeroSelectAPI.Instance:ChatInit(partyData.Id)
  end
  --倒计时
  --Debugger.LogError(time)
  self:IsCanelOn(time)
  self:UpdatePartyChangeData(partyData)    
end
--聊天
function PVPHeroSelectCtrl:SetPlayerChat(data)
  local playerId = tostring(data.PlayerId)
  self.chat_cor = self.chat_cor or {}
  if self.chat_cor[playerId] ~= nil then 
    coroutine.stop(self.chat_cor[playerId])
  end
  self.chat_cor[playerId] = coroutine.start(self.SetPlayerChatMov,self,playerId,data.Message) 
end
function PVPHeroSelectCtrl:SetPlayerChatMov(playerid,text)
  local temp = self.right_player[playerid]:FindChild("chat")
  temp:FindChild("Text"):GetComponent("UnityEngine.UI.Text").text = text
  temp.gameObject:SetActive(true)
  coroutine.wait(5)
  temp.gameObject:SetActive(false)
  self.chat_cor[playerid] = nil
end

--*******************************
--获取玩家当前可以使用的英雄数据(玩家已有+限免+体验中+可以使用体验卡)
--*******************************
function PVPHeroSelectCtrl:GetCanUseRoleData(partyData)
  local limitRoleIdList = {}
  local ownRoleIdList = {}
  local experienceRoleIdList = {}

  limitRoleIdList = partyData.LimitFreeRoleList
  local myData = self:FindOwnInPartyData(partyData)
  ownRoleIdList = myData.OwnRoles
  experienceRoleIdList = myData.ExperienceRoles

  local RolesData = UTGData.Instance().RolesData
  local SkinsData = UTGData.Instance().SkinsData
  local temp = {} 
  for k,v in pairs(limitRoleIdList) do
    temp[tostring(v)] = {}
    temp[tostring(v)].Id = v
    temp[tostring(v)]._IsLimit = true
  end
  for k,v in pairs(ownRoleIdList) do 
    temp[tostring(v)] = temp[tostring(v)] or {}
    temp[tostring(v)].Id = v
    temp[tostring(v)]._IsOwn = true
  end
  for k,v in pairs(experienceRoleIdList) do 
    if temp[tostring(v)] == nil then
      temp[tostring(v)] = {}
      temp[tostring(v)].Id = v
      temp[tostring(v)]._IsTiYan = true
    end
  end
  for k,v in pairs(UTGData.Instance().ItemsDeck) do -- 加入体验卡
    local itemdata = UTGData.Instance().ItemsData[tostring(v.ItemId)]
    if itemdata.Type == 8 then
      local roleId = itemdata.Param[1][1]
      if temp[tostring(roleId)] == nil then 
        temp[tostring(roleId)] = {}
        temp[tostring(roleId)].Id = tonumber(roleId)
        temp[tostring(roleId)].ItemId = v.ItemId
        temp[tostring(roleId)]._IsTiYanKa = true
      end
    end
  end

  for k,v in pairs(temp) do
    if v._IsOwn ==nil then v._IsOwn =false end
    if v._IsTiYan ==nil then v._IsTiYan =false end
    if v._IsLimit ==nil then v._IsLimit =false end
    if v._IsTiYanKa ==nil then v._IsTiYanKa =false end
    v.Icon = SkinsData[tostring(RolesData[tostring(v.Id)].Skin)].Icon
  end
  --[[table.sort( usedata, function (a,b)
    if a._IsOwn == b._IsOwn then
      if a._IsOwn == b._IsOwn == true then
        return a.Id<b.Id
      end
      if a._IsLimit == b._IsLimit then
        if a._IsLimit == b._IsLimit == true then
          return a.Id<b.Id
        end
        if a._IsTiYan == b._IsTiYan  then
          if a._IsTiYan == b._IsTiYan == true then
            return a.Id<b.Id
          end
          if a._IsTiYanKa == b._IsTiYanKa  then
            return a.Id<b.Id
          end 
        else return a._IsTiYan end
      else return a._IsLimit end
    else return a._IsOwn end
    return false
  end )
  ]]
  return temp
end

--*******************************
--获取玩家当前可以使用的皮肤数据(玩家已有+限免+体验)
--*******************************
function PVPHeroSelectCtrl:GetCanUseSkinData(partyData)
  local limitSkinIdList = {}
  local ownSkinIdList = {}
  local experienceSkinIdList = {}
  limitSkinIdList = partyData.LimitFreeSkinList
  local myData = self:FindOwnInPartyData(partyData)
  ownSkinIdList = myData.OwnSkins
  experienceSkinIdList = myData.ExperienceSkins

  local SkinsData = UTGData.Instance().SkinsData
  local temp = {} 
  for k,v in pairs(limitSkinIdList) do
    temp[tostring(v)] = {}
    temp[tostring(v)].Id = v
    temp[tostring(v)]._IsLimit = true
  end
  for k,v in pairs(ownSkinIdList) do 
    temp[tostring(v)] = temp[tostring(v)] or {}
    temp[tostring(v)].Id = v
    temp[tostring(v)]._IsOwn = true
  end
  for k,v in pairs(experienceSkinIdList) do 
    if temp[tostring(v)] == nil then
      temp[tostring(v)] = {}
      temp[tostring(v)].Id = v
      temp[tostring(v)]._IsTiYan = true
    end
  end

  for k,v in pairs(UTGData.Instance().ItemsDeck) do -- 加入体验卡
    local itemdata = UTGData.Instance().ItemsData[tostring(v.ItemId)]
    if itemdata.Type == 7 then
      local skinId = itemdata.Param[1][1]
      if temp[tostring(skinId)] == nil then 
        temp[tostring(skinId)] = {}
        temp[tostring(skinId)].Id = tonumber(skinId)
        temp[tostring(skinId)].ItemId = v.ItemId
        temp[tostring(skinId)]._IsTiYanKa = true
      end
    end
  end
  for k,v in pairs(temp) do
    if v._IsOwn ==nil then v._IsOwn =false end
    if v._IsTiYan ==nil then v._IsTiYan =false end
    if v._IsLimit ==nil then v._IsLimit =false end
    if v._IsTiYanKa ==nil then v._IsTiYanKa =false end
  end
  return temp
end

--正常PVP模式
function PVPHeroSelectCtrl:Init_Common(partyData)
  self.canUseRoleDataList = self:GetCanUseRoleData(partyData)
  self:ClickHeroLis()
  self:FillPlayerSelectLis(partyData)
  self.InitCommon = true
end
--判断是否可以取消
function PVPHeroSelectCtrl:IsCanelOn(time)
  time = tonumber(time)
  if time<=0 then
    self.panel["right"]:FindChild("time/time").gameObject:SetActive(false)
    self.panel["right"]:FindChild("time/but_canel").gameObject:SetActive(true)
  else
    self.panel["right"]:FindChild("time/time").gameObject:SetActive(true)
    self.panel["right"]:FindChild("time/but_canel").gameObject:SetActive(false)
    self:DestroyOtherUI()  
    self.coroutine_countdown = coroutine.start(PVPHeroSelectCtrl.CountDownMov,self,time) 
  end
end
--删除除自身外所有UI
function PVPHeroSelectCtrl:DestroyOtherUI()
  local index = tonumber(PVPHeroSelectAPI.Instance.this.transform:GetSiblingIndex())
  for i=index-1,0,-1 do   
      Object.Destroy(GameManager.PanelRoot.transform:GetChild(i).gameObject)
  end
end

--大乱斗开启模式
function PVPHeroSelectCtrl:Init_DaluanDou(partyData)
  --Debugger.LogError("进入大乱斗模式")
  self.canUseRoleDataList = self:GetCanUseRoleData(partyData)
  self.heroinfo:FindChild("but_random").gameObject:SetActive(true)
  self.panel["left"]:FindChild("wall").gameObject:SetActive(true)
  local listener = NTGEventTriggerProxy.Get(self.heroinfo:FindChild("but_random").gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.ClickRandomRole,self) 
  self.select_role = UTGData.Instance().RolesData[tostring(self:FindOwnInPartyData(partyData).Role.Id)]
  --Debugger.LogError("进入大乱斗模式 当前第一人物  "..self.select_role.Id)
  self:FillPlayerSelectLis(partyData)
  self.panel["right"]:FindChild("but_ok").gameObject:SetActive(true) 
  self.InitDaLuanDou = true
end
--找出partydata中 自己(BattleMenber)
function PVPHeroSelectCtrl:FindOwnInPartyData(partyData)
  for k,v in pairs(partyData.Members) do
    if v.PlayerId == self.myPlayerId then 
      return v 
    end
  end
  return nil
end

--刷新随机英雄 花费
function PVPHeroSelectCtrl:UpdateRandomRolePrice(count)
  local txt = self.heroinfo:FindChild("but_random/txt"):GetComponent("UnityEngine.UI.Text")
  local data = {}
  local temp = UTGData.Instance().ConfigData["randomrole"].String --格式为"次数,货币类型,货币数量;次数,货币类型,货币数量;..."

  local temp1 = UTGData.Instance():StringSplit(temp,";")
  for i=1,#temp1 do
    local onedata = UTGData.Instance():StringSplit(temp1[i],",")
    table.insert(data,onedata)
  end

  local lastprice = 0
  local nexprice = 0
  for i=1,#data do 
    if i==#data then lastprice = tonumber(data[i][3]) end
    if tonumber(data[i][1]) == tonumber(count) then nexprice = tonumber(data[i][3]) end
  end
  if tonumber(count)<5 then
    if count==1 then txt.text = "免费" end
    if count>1 then txt.text = ""..nexprice end
  else 
    txt.text = ""..lastprice
  end
  
end

--随机英雄
function PVPHeroSelectCtrl:ClickRandomRole()
  if self.RoleLock then return end
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSelectRandomRole"))
  request.Handler = TGNetService.NetEventHanlderSelf(PVPHeroSelectCtrl.RandomRoleHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
function PVPHeroSelectCtrl:RandomRoleHandler(e)
    if e.Type =="RequestSelectRandomRole" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      
    else
      Debugger.LogError("随机英雄失败 result= "..result)
    end
    return true
  end
  return false
end




--网络
--克隆大作战
function PVPHeroSelectCtrl:NotifyBattleConfigClone(e)
 if e.Type =="NotifyBattleConfigClone" then
    local time = tonumber(e.Content:get_Item("Seconds"):ToString())
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("双方进入最后调整阶段")
    if self.coroutine_countdown~=nil then coroutine.stop(self.coroutine_countdown) end
    self.coroutine_countdown = coroutine.start(PVPHeroSelectCtrl.CountDownMov,self,time) 
    self.cloneLastChange = true
    return true
 end
 return false
end

--进入战斗加载界面
function PVPHeroSelectCtrl:UpdateBattlePreStart(e)
 if e.Type =="NotifyBattlePreStart" then
    local teamA = json.decode(e.Content:get_Item("TeamA"):ToString())
    local teamB = json.decode(e.Content:get_Item("TeamB"):ToString())
    if teamA ==nil or teamB ==nil then
      Debugger.LogError("Team数据为空")
    end
    self.TeamAData = teamA
    self.TeamBData = teamB    
    self:CreateLoadingPanel()
    return true
 end
 return false
end

function PVPHeroSelectCtrl:CreateLoadingPanel()
  GameManager.CreatePanel("PVPBattleLoading")
  --Debugger.LogError("进入战斗加载界面")
  PVPBattleLoadingAPI_1.Instance:SetParamBy18(self.TeamAData,self.TeamBData)
  
end

--收到战斗开始通知
function PVPHeroSelectCtrl:NetNotifyBattleStart(e)
 if e.Type =="NotifyUTGPVPBattleStart" then
    
    --删除面板
    for i=1, (GameManager.PanelRoot.transform.childCount-1) do
      --Object.DestroyImmediate(GameManager.PanelRoot.transform:GetChild(0).gameObject,true)
      Object.Destroy(GameManager.PanelRoot.transform:GetChild(i-1).gameObject)
    end      
    
    UTGData.Instance().BattlePosition =tonumber(e.Content:get_Item("Position"):ToString())
    UTGData.Instance().BattleGroup = tonumber(e.Content:get_Item("Group"):ToString())
    coroutine.start( PVPHeroSelectCtrl.DoLoadBattleScene,self,e.Content:get_Item("Map"):ToString())

    return true
 end
 return false
end

function PVPHeroSelectCtrl:DoLoadBattleScene(mapResource)

  --Debugger.LogString("Start Loading Map " .. mapResource)
  local load = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync(mapResource, UnityEngine.SceneManagement.LoadSceneMode.Additive)  
  while load.isDone ~= true do
    coroutine.step()
    ----Debugger.LogString("Loading Map " .. mapResource .. " " .. load.progress)    
    PVPBattleLoadingAPI_1.Instance:SetLoadProgress(30 * load.progress)    
  end
  --Debugger.LogString("Loading Map " .. mapResource .. " Done")
  PVPBattleLoadingAPI_1.Instance:SetLoadProgress(30)    
  UnityEngine.SceneManagement.SceneManager.SetActiveScene(UnityEngine.SceneManagement.SceneManager.GetSceneByName(mapResource))

  --Debugger.LogString("Start Loading BattleLogicScene")
  load = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync("NTGBattleLogic", UnityEngine.SceneManagement.LoadSceneMode.Additive)  
  while load.isDone ~= true do
    coroutine.step()
    ----Debugger.LogString("Loading BattleLogicScene " .. load.progress)    
    PVPBattleLoadingAPI_1.Instance:SetLoadProgress(30 + 20 * load.progress)    
  end
  --Debugger.LogString("Loading BattleLogicScene Done")
  PVPBattleLoadingAPI_1.Instance:SetLoadProgress(50)   

end
--监听NotifyPartyChange
function PVPHeroSelectCtrl:NotifyPartyChange(e)
 if e.Type =="NotifyPartyChange" then
    local data = json.decode(e.Content:get_Item("PartyInfo"):ToString())
    if data~=nil and self~=nil and self.this~=nil then
      self:UpdatePartyChangeData(data)     
    end
    return true
 end
 return false
end
function PVPHeroSelectCtrl:UpdatePartyChangeData(data)
  self.partydata = data
  self:UpdatePlayerSelectLis(data) -- 更新玩家列表
  --大乱斗模式
  if self.InitDaLuanDou == true then   
    local newmember = self:FindOwnInPartyData(data)
    --Debugger.LogError("得到更新的RandomCount "..newmember.RandomCount )
    self:UpdateRandomRolePrice(newmember.RandomCount)
  end
  --普通模式
  if self.InitCommon == true then
    --Debugger.LogError("刷新英雄选择列表状态 NotifyPartyChange  ")
    self:UpdateHeroSelectLis(data) -- 更新英雄列表 
  end
end
--确认出战配置
function PVPHeroSelectCtrl:ConfirmBattleConfig(netDelegateSelf,netDelegate)
  self.confirmBattleConfigDelegateSelf = netDelegateSelf
  self.confirmBattleConfigDelegate = netDelegate
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestConfirmBattleConfig"))
  request.Handler = TGNetService.NetEventHanlderSelf(PVPHeroSelectCtrl.ConfirmBattleConfigHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end

function PVPHeroSelectCtrl:ConfirmBattleConfigHandler(e)
  if e.Type =="RequestConfirmBattleConfig" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      if self.confirmBattleConfigDelegateSelf ~= nil and self~=nil and self.this~=nil then
        self.confirmBattleConfigDelegate(self.confirmBattleConfigDelegateSelf)
      end 
    end
    return true
  end
  return false
end

--修改出战配置
function PVPHeroSelectCtrl:ChangeBattleConfig(changetype,changeid,netDelegate)
  
  if changetype == 1 then 
    if self.changeBattleConfigDelegate_role ~=nil then return end
    self.changeBattleConfigDelegate_role = netDelegate
  elseif changetype == 2  then 
    if self.changeBattleConfigDelegate_skin ~=nil then return end
    self.changeBattleConfigDelegate_skin = netDelegate
  elseif changetype == 3  then 
    if self.changeBattleConfigDelegate_playerSkill ~=nil then return end
    self.changeBattleConfigDelegate_playerSkill = netDelegate
  elseif changetype == 4  then 
    if self.changeBattleConfigDelegate_rune ~=nil then return end
    self.changeBattleConfigDelegate_rune = netDelegate 
  end
  --if self.waitNet_ChangeBattleConfig == true then return end
  self.changeBattleConfigDelegate = netDelegate
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestChangeBattleConfig"),
                                JProperty.New("ChangeType",tonumber(changetype)),
                                JProperty.New("ChangeId",tonumber(changeid)))
  request.Handler = TGNetService.NetEventHanlderSelf(PVPHeroSelectCtrl.ChangeBattleConfigHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  --self.waitNet_ChangeBattleConfig = true
end

function PVPHeroSelectCtrl:ChangeBattleConfigHandler(e)
  if e.Type =="RequestChangeBattleConfig" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    --Debugger.LogError("asdasdasdasdas "..result)  
    if self~=nil and self.this ~=nil then    
      if self.changeBattleConfigDelegate_role ~= nil then
        self.changeBattleConfigDelegate_role(self,result)
        self.changeBattleConfigDelegate_role = nil
      end
      if self.changeBattleConfigDelegate_skin ~= nil then
        self.changeBattleConfigDelegate_skin(self,result)
        self.changeBattleConfigDelegate_skin = nil
      end
      if self.changeBattleConfigDelegate_playerSkill ~= nil then
        self.changeBattleConfigDelegate_playerSkill(self,result)
        self.changeBattleConfigDelegate_playerSkill = nil
      end
      if self.changeBattleConfigDelegate_rune ~= nil then
        self.changeBattleConfigDelegate_rune(self,result)
        self.changeBattleConfigDelegate_rune = nil
      end    
    end
    return true
  end
  return false
end

--取消出战配置
function PVPHeroSelectCtrl:CancelBattleConfig(netDelegateSelf,netDelegate)
  self.cancelBattleConfigDelegateSelf = netDelegateSelf
  self.cancelBattleConfigDelegate = netDelegate
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestCancelBattleConfig"))
  request.Handler = TGNetService.NetEventHanlderSelf(PVPHeroSelectCtrl.CancelBattleConfigHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end

function PVPHeroSelectCtrl:CancelBattleConfigHandler(e)

  if e.Type =="RequestCancelBattleConfig" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 and self~=nil and self.this~=nil then
      if self.cancelBattleConfigDelegateSelf ~= nil then
        self.cancelBattleConfigDelegate(self.cancelBattleConfigDelegateSelf)
      end 
    end
    return true
  end
  return false
end

--点击，显示英雄大列表
function PVPHeroSelectCtrl:ClickHeroBigLis(eventdata)
  self.panel["bigherolis"].gameObject:SetActive(true)  
  self.panel["herolis"].gameObject:SetActive(false)
  local scroll = self.heroListGrid.parent
  local grid = self.heroListGrid
  local scrollParent = self.panel["bigherolis"]:FindChild("scroll").transform
  scroll:SetParent(scrollParent) 
  scroll:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector2.New(self.param_herobiglis_width,self.param_herolis_height)
  grid:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector2.New(self.param_herobiglis_width,self.param_herolis_height)
end

--点击，关闭英雄大列表
function PVPHeroSelectCtrl:ClickCloseHeroBigLis(eventdata)
  local scroll = self.heroListGrid.parent
  local grid = self.heroListGrid
  local scrollParent = self.panel["herolis"].transform
  scroll:SetParent(scrollParent) 
  scroll:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector2.New(self.param_herolis_width,self.param_herolis_height)
  grid:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector2.New(self.param_herolis_width,self.param_herolis_height)

  self.panel["bigherolis"].gameObject:SetActive(false)
  self.panel["herolis"].gameObject:SetActive(true)
  
end

--生成英雄选择列表
function PVPHeroSelectCtrl:FillHeroSelectLis(canUseData)
  local grid = self.heroListGrid
  local tempRoleIcon = self.panel["herolis"]:FindChild("temp")
  local data = {}
  for k,v in pairs(canUseData) do
    table.insert(data,v)
  end
  table.sort(data,function (a,b) return a.Id<b.Id end)
  for i=1,#data do
    local tempo = self:CreateGameObject(tempRoleIcon,grid)
    tempo.name = tostring(i)
    self.roleIconTranList[tostring(data[i].Id)] = tempo
    --Debugger.LogError(tostring(UTGData.Instance().SkinsData[tostring(data[i].Skin)].Id))
    local roleicon_sprite = NTGResourceController.Instance:LoadAsset("roleicon",data[i].Icon,"UnityEngine.Sprite")
    tempo:FindChild("mask/icon"):GetComponent("UnityEngine.UI.Image").sprite = roleicon_sprite
    tempo:FindChild("wu/icon"):GetComponent("UnityEngine.UI.Image").sprite = roleicon_sprite

    if data[i]._IsLimit == true then--是限免英雄
      tempo:FindChild("free").gameObject:SetActive(true)
    elseif data[i]._IsTiYanKa == true then
      tempo:FindChild("useCard").gameObject:SetActive(true)
    elseif data[i]._IsTiYan == true then
      tempo:FindChild("tiyan").gameObject:SetActive(true)
    end

    UITools.GetLuaScript(tempo.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickHeroIcon,data[i].Id)
  end

end

--刷新英雄选择列表状态
function PVPHeroSelectCtrl:UpdateHeroSelectLis(partyData)
  if self.RoleLock == true then
    return
  end
  for k,v in pairs(self.roleIconTranList) do
    v:FindChild("wu").gameObject:SetActive(false)
    v:FindChild("liang").gameObject:SetActive(false)
  end
  for k,v in pairs(partyData.Members) do
    local temp = self.roleIconTranList[tostring(v.Role.Id)]
    if temp~=nil then 
      if self.cloneMode ~= true then 
        temp:FindChild("wu").gameObject:SetActive(true)
      end
      if v.PlayerId == self.myPlayerId then 
        temp:FindChild("liang").gameObject:SetActive(true)
      end
    end
  end
end



--点击，显示英雄列表
function PVPHeroSelectCtrl:ClickHeroLis()
  self.panel["herolis"].gameObject:SetActive(true)
  self.panel["skinlis"].localPosition = Vector3.New(0,1000,0)
  self.this.transforms[0]:FindChild("liang").gameObject:SetActive(true)--英雄
  self.this.transforms[1]:FindChild("liang").gameObject:SetActive(false)--皮肤
  
  if self.herolisloaded==false then
    self:FillHeroSelectLis(self.canUseRoleDataList) 
    self.herolisloaded = true 
  end
  
end

--点击皮肤按钮，显示皮肤列表
function PVPHeroSelectCtrl:ClickHeroSkinLis()
  self.panel["herolis"].gameObject:SetActive(false)
  self.panel["skinlis"].localPosition = Vector3.zero
  self.this.transforms[0]:FindChild("liang").gameObject:SetActive(false)--英雄
  self.this.transforms[1]:FindChild("liang").gameObject:SetActive(true)--皮肤
end


--生成皮肤选择列表
function PVPHeroSelectCtrl:FillHeroSkinLis(dataList,canUseDataList)
  local grid = self.skinListGrid 
  local tempSkinIcon = self.panel["skinlis"]:FindChild("temp")
  local data = {}
  for k,v in pairs(dataList) do
    table.insert(data,v)
  end
  table.sort(data,function (a,b) return a.Id<b.Id end)

  self.skinIconTranList = {}
  for i=grid.childCount-1,0,-1 do
    Object.Destroy(grid:GetChild(i).gameObject)
  end
  for i=1,#data do
    local tempo = self:CreateGameObject(tempSkinIcon,grid)
    tempo.name = tostring(i)
    self.skinIconTranList[tostring(data[i].Id)] = tempo
    local skinicon_sprite = NTGResourceController.Instance:LoadAsset("roleicon",tostring(""..data[i].Icon),"UnityEngine.Sprite")
    tempo:FindChild("mask/icon"):GetComponent("UnityEngine.UI.Image").sprite = skinicon_sprite
    tempo:FindChild("wu/icon"):GetComponent("UnityEngine.UI.Image").sprite = skinicon_sprite
    tempo:FindChild("wu").gameObject:SetActive(false)
    local canUseData = canUseDataList[tostring(data[i].Id)]
    if canUseData == nil then 
      tempo:FindChild("wu").gameObject:SetActive(true) 
    else
      if canUseData._IsLimit then 
        tempo:FindChild("free").gameObject:SetActive(true) 
      end
      if canUseData._IsTiYan then
        tempo:FindChild("tiyan").gameObject:SetActive(true) 
      end
    end
    if self.select_role.Skin == data[i].Id then 
      tempo:FindChild("wu").gameObject:SetActive(false)
    end 
    UITools.GetLuaScript(tempo.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickSkinIcon,data[i].Id)
  end
end

--点击英雄皮肤Icon
function PVPHeroSelectCtrl:ClickSkinIcon(skinId)
  local tran = self.skinIconTranList[tostring(skinId)]
  if tran.transform:FindChild("wu").gameObject.activeSelf == true then
    --GameManager.CreatePanel("SkinWindow19")
    --SkinWindow19API.Instance:Show(self.skinlis[tonumber(index)].Id)
    return
  end
  if tran.transform:FindChild("liang").gameObject.activeSelf == true then return end
  self:ClickSkinIconNetRequest(skinId)
end

--修改皮肤 net request
function PVPHeroSelectCtrl:ClickSkinIconNetRequest(skinId)
  if self.waitNet_ChangeSkin == true then return end
  self.clickskinicon_id = skinId
  self:ChangeBattleConfig(2,skinId,PVPHeroSelectCtrl.ClickSkinIconNetHandler)
  self.waitNet_ChangeSkin = true
end

--修改皮肤成功 net handler
function PVPHeroSelectCtrl:ClickSkinIconNetHandler(result)
  if result == 1 then 
    for k,v in pairs(self.skinIconTranList) do
      v:FindChild("liang").gameObject:SetActive(false)
    end
    self.skinIconTranList[tostring(self.clickskinicon_id)]:FindChild("liang").gameObject:SetActive(true)

    self.select_skin_id = self.clickskinicon_id
    self:ShowSkinData(self.select_skin_id)
    self:SetSkinModel(self.skinlis[tostring(self.select_skin_id)])
    --是否是体验skin
    self.tiyanTimeTran:FindChild("skin").gameObject:SetActive(false)
    if self.coroutine_experience_skin ~=nil then coroutine.stop(self.coroutine_experience_skin) end
    if self.canUseSkinData[tostring(self.select_skin_id)]~=nil and self.canUseSkinData[tostring(self.select_skin_id)]._IsTiYan then 
      local skindeck = UTGData.Instance().SkinsDeckData[tostring(self.select_skin_id)]
      local time = UTGData.Instance():GetLeftTime(skindeck.ExperienceTime)
      self.coroutine_experience_skin = coroutine.start(self.ExperienceTimeMov,self,time,2)
    end 
  else
    Debugger.Log("选择完皮肤"..self.clickskinicon_id.." result = "..result)
  end
  self.waitNet_ChangeSkin = false
end

--显示皮肤信息
function PVPHeroSelectCtrl:ShowSkinData(skinid)
  --print("显示皮肤信息"..skinid)
  local data = UTGDataOperator.Instance:GetSortedPropertiesByKey("Skin",tostring(self.select_skin_id))
  local api = self.skinyou:FindChild("scroll/grid"):GetComponent("NTGLuaScript").self
  if data==nil then
    api:ResetItemsSimple(0)
    return
  end
  api:ResetItemsSimple(#data)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform
    tempo.name = tostring(i)   
    tempo:FindChild("name"):GetComponent("UnityEngine.UI.Text").text = tostring(data[i].Des)
    tempo:FindChild("attr"):GetComponent("UnityEngine.UI.Text").text = tostring("+"..data[i].Attr)
  end
end

--点击英雄头像 
function PVPHeroSelectCtrl:ClickHeroIcon(roleId)
  local temp = self.roleIconTranList[tostring(roleId)]
  local isSelect = false
  if temp:FindChild("liang").gameObject.activeSelf or temp:FindChild("wu").gameObject.activeSelf then
    isSelect = true
  end
  if isSelect == false then 
    local roleData = self.canUseRoleDataList[tostring(roleId)]
    if roleData._IsTiYanKa then 
      self:UseRoleExperienceCard(roleId)
    else
      self:ClickHeroIconNetRequest(roleId) 
    end

  end
  if self.panel["bigherolis"].gameObject.activeSelf then --在大列表 
    self:ClickCloseHeroBigLis()     
  end
end
function PVPHeroSelectCtrl:UseRoleExperienceCard(roleId)
  local data = self.canUseRoleDataList[tostring(roleId)]
  self.instanceDialog_card_itemId = data.ItemId
  self.card_roleId = roleId
  local str = string.format("是否立即使用%s体验卡",UTGData.Instance().RolesData[tostring(roleId)].Name)
  self.instanceDialog = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
  self.instanceDialog:InitNoticeForNeedConfirmNotice("提示",str, false, "", 2)
  self.instanceDialog:SetTextToCenter()
  self.instanceDialog:TwoButtonEvent("取消",PVPHeroSelectCtrl.UseRoleExperienceCardCanel,self,
                          "确定",PVPHeroSelectCtrl.UseRoleExperienceCardYes,self)

end
function PVPHeroSelectCtrl:UseRoleExperienceCardCanel()
  self.instanceDialog:DestroySelf()
  self.instanceDialog_card_itemId = nil
  self.instanceDialog = nil
end
function PVPHeroSelectCtrl:UseRoleExperienceCardYes()
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestUseExperienceCardInBattleConfig"),
                                JProperty.New("ItemId",tonumber(self.instanceDialog_card_itemId)))
  request.Handler = TGNetService.NetEventHanlderSelf(PVPHeroSelectCtrl.UseRoleExperienceCardHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self:UseRoleExperienceCardCanel()
end
function PVPHeroSelectCtrl:UseRoleExperienceCardHandler(e)
  if e.Type =="RequestUseExperienceCardInBattleConfig" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      local temp = self.roleIconTranList[tostring(self.card_roleId)]
      temp:FindChild("useCard").gameObject:SetActive(false)
      temp:FindChild("tiyan").gameObject:SetActive(true)
      self.canUseRoleDataList[tostring(self.card_roleId)]._IsTiYanKa = false
      self.canUseRoleDataList[tostring(self.card_roleId)]._IsTiYan = true
      self:ClickHeroIconNetRequest(self.card_roleId)

    else
      Debugger.LogError("RequestUseExperienceCardInBattleConfig Result == "..result)
    end
    return true
  end
  return false
end

--修改英雄 net request
function PVPHeroSelectCtrl:ClickHeroIconNetRequest(roleId)
  if self.waitNet_ChangeRole == true then return end
  self:ChangeBattleConfig(1,tonumber(roleId),PVPHeroSelectCtrl.ClickHeroIconNetHandler)
  self.waitNet_ChangeRole = true
end

--修改英雄成功 net handler
function PVPHeroSelectCtrl:ClickHeroIconNetHandler(result)
  Debugger.Log("选择完英雄 result = "..result)
  if result == 1 then 
    self.panel["right"]:FindChild("but_ok").gameObject:SetActive(true) 
  end
  self.waitNet_ChangeRole = false
end


function PVPHeroSelectCtrl:InitRoleData(roleid,skillid,runepageid,islock)
  if islock == false then 
    self.panel["right"]:FindChild("but_ok").gameObject:SetActive(true) 
  end
  --召唤师技能
  if skillid == 0 then 
    --默认召唤师技能
    self.playerskill_skilldata = UTGData.Instance():GetDefaultPlayerSkill()
    self:ChangePlayerSkill(self.playerskill_skilldata)
  else
    self.playerskill_skilldata = UTGData.Instance().SkillsData[tostring(skillid)]
    self.heroinfo.transform:FindChild("playerskill/icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",tostring(self.playerskill_skilldata.Icon),"UnityEngine.Sprite")
  end
  --符文
  if runepageid == 0 then 
    --默认芯片组
    self:NetChangeRune(PVPHeroSelectAPI.Instance:GetDefaultRunePageId())    
  else
    self.selectRunePageId = runepageid
    PVPHeroSelectAPI.Instance:SetSelectRunePageId(self.selectRunePageId)
  end

  if self.select_role_id ~= roleid then
    self.select_role_id = roleid
    self.select_role = UTGData.Instance().RolesData[tostring(roleid)]
      
    self:InitSkinData(self.select_role_id)
    self:ShowRole(self.select_role)

    --切换到选择皮肤列表
    if self.RoleLock == true or self.daluanDouMode then 
      self:ClickHeroSkinLis()
    end

    self:ExperienceTimeTranActive(false)
    --是否是体验role
    local roledeck =  UTGData.Instance():GetRoleDeckByRoleId(roleid)
    if self.coroutine_experience_role ~=nil then coroutine.stop(self.coroutine_experience_role) end
    if self.canUseRoleDataList[tostring(roleid)]~=nil and self.canUseRoleDataList[tostring(roleid)]._IsTiYan then 
      local time = UTGData.Instance():GetLeftTime(roledeck.ExperienceTime)
      self.coroutine_experience_role = coroutine.start(self.ExperienceTimeMov,self,time,1)
    end 
  end
  if islock ~= self.RoleLock then 
    self.RoleLock = islock
    self.panel["right"]:FindChild("but_ok").gameObject:SetActive(false) 
    local api = self.heroListGrid
    for i=1,api.childCount do
      local tempo = api:GetChild(i-1)   
      tempo:FindChild("wu").gameObject:SetActive(true) 
      tempo:FindChild("liang").gameObject:SetActive(false) 
    end
    self:ClickHeroSkinLis()
  end
end
function PVPHeroSelectCtrl:InitSkinData(roleId)
  self.canUseSkinData = self.canUseSkinData or self:GetCanUseSkinData(self.partydata)
  --选择出皮肤
  self.skinlis = UTGData.Instance():GetSkinDataByRoleId(roleId)

  self.skinwu.gameObject:SetActive(false)
  self.skinyou.gameObject:SetActive(true)
  self:FillHeroSkinLis(self.skinlis,self.canUseSkinData)

  local roledeck =  UTGData.Instance():GetRoleDeckByRoleId(roleId)
  if roledeck~=nil then
    local data = self.canUseSkinData[tostring(roledeck.Skin)]
    if data~=nil and data._IsTiYanKa==false then 
      self:ClickSkinIcon(roledeck.Skin)
    else
      self:ClickSkinIcon(self.select_role.Skin)
    end
  else
    self:ClickSkinIcon(self.select_role.Skin) --self.select_skin_id = self.select_role.Skin
  end

end
function PVPHeroSelectCtrl:ExperienceTimeTranActive(boo)
  for i=self.tiyanTimeTran.childCount-1,0,-1 do
    self.tiyanTimeTran:GetChild(i).gameObject:SetActive(boo)
  end
end
function PVPHeroSelectCtrl:ExperienceTimeMov(time,exType)
  if time<0 then time = 0 end
  local str = ""
  local str_format1 = ""
  local str_format2 = ""
  local temp = nil
  if exType ==1 then 
    str_format1 = "姬神体验时间剩余 <color=#FFED00FF>%d</color>天<color=#FFED00FF>%d</color>时"
    str_format2 = "姬神体验时间剩余 <color=#FFED00FF>%02d:%02d:%02d</color>"
    temp = self.tiyanTimeTran:FindChild("role/Text")
  elseif exType == 2 then 
    str_format1 = "皮肤体验时间剩余 <color=#FFED00FF>%d</color>天<color=#FFED00FF>%d</color>时"
    str_format2 = "皮肤体验时间剩余 <color=#FFED00FF>%02d:%02d:%02d</color>"
    temp = self.tiyanTimeTran:FindChild("skin/Text")
  end
  temp.parent.gameObject:SetActive(true)
  if time/3600 >24 then
    str = string.format(str_format1,math.floor(time/(3600*24)),math.floor((time%(3600*24))/3600))
    temp:GetComponent("UnityEngine.UI.Text").text = str
  else
    local hour = 0
    local min =0
    local sec = 0
    while time>0 do 
      hour = math.floor(time/3600)
      min = math.floor((time%3600)/60)
      sec = math.floor((time%3600)%60)
      str = string.format(str_format2,hour,min,sec)
      temp:GetComponent("UnityEngine.UI.Text").text = str
      coroutine.wait(1)
      time = time-1
    end
    str = string.format(str_format2,0,0,0)
    temp:GetComponent("UnityEngine.UI.Text").text = str
  end

  if exType ==1 then 
    self.coroutine_experience_role =nil
  elseif exType == 2 then 
    self.coroutine_experience_skin =nil
  end
end

--显示英雄信息
function PVPHeroSelectCtrl:ShowRole(roledata)
  --Debugger.LogError("创建人物  "..roledata.Id .."  "..skindata.Id)
  if roledata ~=nil then
    self.herowu.gameObject:SetActive(false)
  end

  self.heroinfo.localPosition = Vector3.zero

  local tempo = self.heroinfo 
  tempo:FindChild("txtname"):GetComponent("UnityEngine.UI.Text").text = ""..roledata.Name
  tempo:FindChild("txtclass"):GetComponent("UnityEngine.UI.Text").text = "定位  "..roledata.Position
  tempo:FindChild("classicon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("classicon",tostring("ClassIcon"..roledata.Class),"UnityEngine.Sprite")
  --技能
  self.skilllis= {}
  for i =1,4 do 
    self.skilllis[i] =  UTGData.Instance().SkillsData[tostring(roledata.Skills[i+1])]
    --Debugger.LogError("id  "..self.skilllis[i].Id)
  end
  for i=1,4 do
    tempo:FindChild("skill/"..tostring(i)):FindChild("icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("skillicon-"..roledata.Id,""..self.skilllis[i].Icon,"UnityEngine.Sprite")
  end
  --召唤师技能
  self.heroinfo.transform:FindChild("playerskill/icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",""..self.playerskill_skilldata.Icon,"UnityEngine.Sprite")
  --技能
  local listener={}
  for i=1,self.this.transforms[8].childCount do
    listener = NTGEventTriggerProxy.Get(self.this.transforms[8]:GetChild(i-1).gameObject)
    listener.onPointerDown =NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.DownSkillTip,self)
    listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.UpSkillTip,self)
  end
  --召唤师技能
  listener = NTGEventTriggerProxy.Get(self.heroinfo.transform:FindChild("playerskill").gameObject)
  listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.DownZHSkillTip,self)
  listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(PVPHeroSelectCtrl.UpSkillTip,self)
  
end

--更换皮肤模型
function PVPHeroSelectCtrl:SetSkinModel(skindata)
  -- skindata.Resource 
  local tempo = self.panel["middle"]
  local temp_model = self.modelRoot:FindChild("root/model")

  tempo:FindChild("rawevent").gameObject:SetActive(true)
  self.modelRoot:FindChild("root").localRotation = Quaternion.identity

  --删除模型
  for i=1,temp_model.childCount do
    --Object.DestroyImmediate(temp_model:GetChild(i-1).gameObject,true)
    Object.Destroy(temp_model:GetChild(i-1).gameObject)
  end
  if self.model_ab_name~=nil then 
    NTGResourceController.Instance:UnloadAssetBundle(self.model_ab_name,true, false)
  end
  self.model_ab_name = nil
  self.fxShow = nil
  self.fxPlay = nil
  self.modelAnimator = nil
  --创建模型
  self.model_ab_name = "skin"..skindata.Resource
  local temp  = NTGResourceController.Instance:LoadAsset("skin"..skindata.Resource,tostring(""..skindata.Resource.."-Show"))
  if temp ==nil or temp:Equals(nil) then return end
  local model = self:CreateGameObject(temp,temp_model)
  model.gameObject:SetActive(true)
  --model.gameObject.layer = LayerMask.NameToLayer("Player")
  --model.name = "model"
  self.modelAnimator = model:GetComponent("Animator")

  local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,btn.Length - 1 do
    --print("btn[k].material.shader.name " .. btn[k].transform.name)
    if k ~= btn.Length-1 and btn[k].transform.name ~= btn[k+1].transform.name then
      for i = 0,btn[k].materials.Length-1 do
        model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].materials[i].shader = UnityEngine.Shader.Find(btn[k].materials[i].shader.name)
      end
    end
  end
  self.modelAnimator:SetTrigger("show")
  --人物展示特效
  if model.transform:FindChild("FX-Show") ~= nil then
    self.fxShow = model.transform:FindChild("FX-Show")
    local fx = self.fxShow:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
    local renderer = self.fxShow:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    for k = 0,renderer.Length - 1 do
      self.fxShow:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(renderer[k].material.shader.name)
    end
    for k = 0,fx.Length - 1 do
        fx[k]:Play()
    end
  end

  if model.transform:FindChild("FX-Play") ~= nil then
      self.fxPlay = model.transform:FindChild("FX-Play")
  end

end

function PVPHeroSelectCtrl:SetModelPlayerAnimator()
  if self.modelAnimator ~= nil then
    self.modelAnimator:SetTrigger("play")
  end
  if self.fxPlay ~= nil then
    local fx = self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.ParticleSystem"))
    local renderer = self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))

    for k = 0,renderer.Length - 1 do
      self.fxPlay:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(renderer[k].material.shader.name)
    end

    for k = 0,fx.Length - 1 do
      fx[k]:Play()
    end
  end
  
end

--修改芯片
function PVPHeroSelectCtrl:NetChangeRune(selectRunePageId)
  if self.waitNet_ChangeRune ==true then return end
  self.selectRunePageId = selectRunePageId
  --Debugger.LogError("1111111111")
  self:ChangeBattleConfig(4,self.selectRunePageId,PVPHeroSelectCtrl.NetChangeRuneFunc)
  self.waitNet_ChangeRune = true
end
--修改芯片 成功
function PVPHeroSelectCtrl:NetChangeRuneFunc(result)
  if result==1 then 
  end
  self.waitNet_ChangeRune = false
end

--显示技能Tip信息
function PVPHeroSelectCtrl:ShowSkillTip(data,skilltype)
  skilltype = skilltype or 0
  if skilltype == 1 then
    self.skilltip:FindChild("txtcd"):GetComponent("UnityEngine.UI.Text").text = "被动"
    self.skilltip:FindChild("txtmp"):GetComponent("UnityEngine.UI.Text").text = ""
  elseif skilltype == 2 then 
    self.skilltip:FindChild("txtcd"):GetComponent("UnityEngine.UI.Text").text = "CD:  "..data.Cd.."秒"
    self.skilltip:FindChild("txtmp"):GetComponent("UnityEngine.UI.Text").text = ""
  else
    self.skilltip:FindChild("txtcd"):GetComponent("UnityEngine.UI.Text").text = "CD:  "..data.Cd.."秒"
    self.skilltip:FindChild("txtmp"):GetComponent("UnityEngine.UI.Text").text = "法力消耗:  "..data.MpCost
  end
  self.skilltip:FindChild("txtname"):GetComponent("UnityEngine.UI.Text").text = data.Name
  --描述
  local desc = UTGData.Instance():GetSkillDescByParam(self.select_role.Id,data.Id)
  self.skilltip:FindChild("txtdes"):GetComponent("UnityEngine.UI.Text").text = desc

  --tag
  local tag = self.skilltip:FindChild("tag")
  --Debugger.LogError("data.Cd "..data.Cd .." data.mp "..data.MpCost .." data.tag "..#data.Tags)
  for i=1,tag.childCount do
    tag:GetChild(i-1).gameObject:SetActive(false)
  end
  for i=1,#data.Tags do
    --Debugger.LogError(" data.tag "..data.Tags[i])
    tag:FindChild(tostring(data.Tags[i])).gameObject:SetActive(true)
  end
  self.skilltip.gameObject:SetActive(true)
end 
--查看普通技能
function PVPHeroSelectCtrl:DownSkillTip(eventdata)
  if eventdata.pointerEnter.transform.parent ~= self.this.transforms[8] then
    return
  end
  
  local index = eventdata.pointerEnter.name
  --local index = eventdata.lastPress.name
  --local index = UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject.name
  --Debugger.LogError(" index  "..index)
  --Debugger.LogError("  "..self.skilllis[index])
  if tonumber(index)==4 then 
    self:ShowSkillTip(self.skilllis[tonumber(index)],1) 
  else
    self:ShowSkillTip(self.skilllis[tonumber(index)])
  end

  self.skilltip.gameObject:SetActive(true)
end

--查看召唤师技能
function PVPHeroSelectCtrl:DownZHSkillTip(eventdata)
  self.skilltip.gameObject:SetActive(true)
  self:ShowSkillTip(self.playerskill_skilldata,2)
end


function PVPHeroSelectCtrl:UpSkillTip()
  self.skilltip.gameObject:SetActive(false)
end
--点击更换召唤师技能
function PVPHeroSelectCtrl:ClickChangePlayerSkill()
  GameManager.CreatePanel("PVPPlayerSkillSelect")
  PVPPlayerSkillSelectAPI.Instance:SetCurrentSkillId(self.playerskill_skilldata.Id)
end

--更换召唤师技能
function PVPHeroSelectCtrl:ChangePlayerSkill(skilldata)
  self:ChangeBattleConfig(3,skilldata.Id,PVPHeroSelectCtrl.ChangePlayerSkillFunc)
end

--修改召唤师技能成功
function PVPHeroSelectCtrl:ChangePlayerSkillFunc()
 
end

--倒计时协程
function PVPHeroSelectCtrl:CountDownMov(time)
  self.time_common.gameObject:SetActive(true)
  self.time_over.gameObject:SetActive(false)
  self.timefx_over.gameObject:SetActive(false)

  while time > 0 do
    if time <= 5   then
      self.time_common.gameObject:SetActive(false)
      self.time_over.gameObject:SetActive(true)
      self.timefx_over.gameObject:SetActive(true)
    else
      self.txttime:GetComponent("UnityEngine.UI.Text").text = string.format("00:%02d",time)
    end
    coroutine.wait(1)
    time = time - 1
  end
  self.coroutine_countdown = nil
end

--选择完英雄 确定
function PVPHeroSelectCtrl:ClickSelectOK()
  self:ConfirmBattleConfig(self,PVPHeroSelectCtrl.ClickSelectOKFunc)
end

function PVPHeroSelectCtrl:ClickSelectOKFunc()
  
end

--取消
function PVPHeroSelectCtrl:ClickCancel()
   self:CancelBattleConfig(self,PVPHeroSelectCtrl.ClickCancelFunc)
   
end
function PVPHeroSelectCtrl:ClickCancelFunc()
  GameObject.Destroy(PVPHeroSelectAPI.Instance.this.gameObject)

end
--生成玩家选择列表
function PVPHeroSelectCtrl:FillPlayerSelectLis(data)
  local api = self.this.transforms[23]:GetComponent("NTGLuaScript").self
  if data==nil then
    api:ResetItemsSimple(0)
    return
  end
  local member = data.Members
  --过滤空数据
  for i=#member, 1, -1 do 
    if member[i].PlayerId ==0 and member[i].IsAi == false then 
      --Debugger.LogError("ffffffffffffffffff  "..i)
      table.remove(member,i) 
    end 
  end
  api:ResetItemsSimple(#member)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform   
    tempo.name = tostring(member[i].PlayerId)
    self.right_player[tostring(member[i].PlayerId)] = tempo
    if member[i].PlayerId == UTGData.Instance().PlayerData.Id then
      tempo:FindChild("own").gameObject:SetActive(true)
      tempo:FindChild("ownname").gameObject:SetActive(true)
      tempo:FindChild("txtname").gameObject:SetActive(false)
      tempo:FindChild("ownname"):GetComponent("UnityEngine.UI.Text").text = member[i].PlayerName
    end  
    tempo:FindChild("ok").gameObject:SetActive(false)
    tempo:FindChild("mask").gameObject:SetActive(false)
    tempo:FindChild("txtname"):GetComponent("UnityEngine.UI.Text").text = member[i].PlayerName
    --电脑
    if member[i].IsAi then
      tempo:FindChild("mask").gameObject:SetActive(true)
      tempo:FindChild("mask/ai").gameObject:SetActive(true)
      tempo:FindChild("ok").gameObject:SetActive(true)
      tempo:FindChild("txtname"):GetComponent("UnityEngine.UI.Text").text ="电脑"
     end 
  end
    
end

--刷新player选择列表状态
function PVPHeroSelectCtrl:UpdatePlayerSelectLis(data)
  local member = data.Members
  local lock = 0
  for k,v in pairs(member) do
    local tempo = self.right_player[tostring(v.PlayerId)]
    if tempo~=nil then
      if v.PlayerSkill.Id >0 then --召唤师技能
        tempo:FindChild("skill").gameObject:SetActive(true)
        tempo:FindChild("skill/icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",tostring(v.PlayerSkill.Icon),"UnityEngine.Sprite")
      else
        tempo:FindChild("skill").gameObject:SetActive(false)
      end
      if tonumber(v.Role.Id) >0 then  --头像
        tempo:FindChild("mask").gameObject:SetActive(true)
        local roleicon = UTGData.Instance().SkinsData[tostring(UTGData.Instance().RolesData[tostring(v.Role.Id)].Skin)].Icon
        tempo:FindChild("mask/icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",tostring(roleicon),"UnityEngine.Sprite")
      end
      if v.RoleLocked == true then --是否确认准备
        lock = lock + 1
        tempo:FindChild("ok").gameObject:SetActive(true)
      end
      if v.PlayerId == self.myPlayerId then 
        if v.Role.Id>0 then 
          self:InitRoleData(v.Role.Id,v.PlayerSkill.Id,v.RunePageDeckId,v.RoleLocked)
        end
      end
    end
  end
  if lock == #member and self.cloneMode and self.cloneLastChange~=true and self.cloneSelectOk ~=true then 
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("我方已选定，等待对方选择")
    self.cloneSelectOk = true
  end
end

function PVPHeroSelectCtrl:OnDestroy()
  if self.coroutine_countdown ~= nil then coroutine.stop(self.coroutine_countdown) end
  if self.coroutine_experience_role ~=nil then coroutine.stop(self.coroutine_experience_role) end
  if self.chat_cor~=nil then
    for k,v in pairs(self.chat_cor) do 
      coroutine.stop(v)
    end
  end
  TGNetService.GetInstance():RemoveEventHander("NotifyPartyChange",self.Delegate_NotifyPartyChange)
  TGNetService.GetInstance():RemoveEventHander("NotifyBattlePreStart", self.Delegate_UpdateBattlePreStart)
  TGNetService.GetInstance():RemoveEventHander("NotifyUTGPVPBattleStart", self.Delegate_NetNotifyBattleStart)
  TGNetService.GetInstance():RemoveEventHander("NotifyBattleConfigClone", self.Delegate_NotifyBattleConfigClone)
  Object.Destroy(self.modelRoot.gameObject) 
  self.this = nil
  self= nil
end