--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
require "Logic.UTGData.UTGDataTemporary"
class("DraftHeroSelectCtrl")

local json = require "cjson"

function DraftHeroSelectCtrl:Awake(this)
  self.this = this


  self.top = this.transforms[0]
  self.left = this.transforms[1]
  self.middle = this.transforms[2]
  self.right = this.transforms[3]
  self.bottom = this.transforms[4]
  self.change = this.transforms[5]
  self.change_main = this.transforms[7]
  self.wait = this.transforms[6]
  self.wait.gameObject:SetActive(false)
  --top
  self.top_text = self.top:FindChild("Text")
  self.top_text_last = self.top:FindChild("Text-Last")
  self.top_fx = self.top:FindChild("FX")

  --监听
  --partychange
  self.Delegate_NotifyPartyChange = TGNetService.NetEventHanlderSelf(self.NotifyPartyChange,self)
  TGNetService.GetInstance():AddEventHandler("NotifyPartyChange",self.Delegate_NotifyPartyChange,1)
  --战斗开始
  self.Delegate_NotifyBattlePreStart = TGNetService.NetEventHanlderSelf(self.NotifyBattlePreStart,self)
  TGNetService.GetInstance():AddEventHandler("NotifyBattlePreStart", self.Delegate_NotifyBattlePreStart,1)

  self.Delegate_NotifyUTGPVPBattleStart = TGNetService.NetEventHanlderSelf(self.NotifyUTGPVPBattleStart,self)
  TGNetService.GetInstance():AddEventHandler("NotifyUTGPVPBattleStart",self.Delegate_NotifyUTGPVPBattleStart,1)
  --征召配对变化通知
  self.Delegate_NotifyBattleDraftChange = TGNetService.NetEventHanlderSelf(self.NotifyBattleDraftChange,self)
  TGNetService.GetInstance():AddEventHandler("NotifyBattleDraftChange",self.Delegate_NotifyBattleDraftChange,1)
  --征召模式英雄交换请求通知
  self.Delegate_NotifyDraftRoleSwitchRequest = TGNetService.NetEventHanlderSelf(self.NotifyDraftRoleSwitchRequest,self)
  TGNetService.GetInstance():AddEventHandler("NotifyDraftRoleSwitchRequest",self.Delegate_NotifyDraftRoleSwitchRequest,1)
  --征召模式英雄交换取消通知
  self.Delegate_NotifyDraftRoleSwitchCancel = TGNetService.NetEventHanlderSelf(self.NotifyDraftRoleSwitchCancel,self)
  TGNetService.GetInstance():AddEventHandler("NotifyDraftRoleSwitchCancel",self.Delegate_NotifyDraftRoleSwitchCancel,1)
  --征召模式英雄交换成功/失败通知
  self.Delegate_NotifyDraftRoleSwitchAnswer = TGNetService.NetEventHanlderSelf(self.NotifyDraftRoleSwitchAnswer,self)
  TGNetService.GetInstance():AddEventHandler("NotifyDraftRoleSwitchAnswer",self.Delegate_NotifyDraftRoleSwitchAnswer,1)

  self.Delegate_NotifyUTGPVPBattleStart = TGNetService.NetEventHanlderSelf(self.NotifyUTGPVPBattleStart,self)
  TGNetService.GetInstance():AddEventHandler("NotifyUTGPVPBattleStart",self.Delegate_NotifyUTGPVPBattleStart,1)

  self:SetFxOk(self.top)
end
function DraftHeroSelectCtrl:SetWait(boo)
  if self~=nil and self.this~=nil then
    self.wait.gameObject:SetActive(boo)
  end
end

function DraftHeroSelectCtrl:SetFxOk(model)
  local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,btn.Length - 1 do
    model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
  end
end

function DraftHeroSelectCtrl:NotifyPartyChange(e)
  if e.Type =="NotifyPartyChange" then
    local data = json.decode(e.Content:get_Item("PartyInfo"):ToString())
    if data~=nil and self~=nil and self.this~=nil then
      self:UpdatePartyChangeData(data)
    end
    return true
  end
  return false
end
function DraftHeroSelectCtrl:UpdatePartyChangeData(data)
  local partyId = data.Id 
  if self.chatInit ~=true then 
    DraftHeroSelectAPI.Instance:ChatInit(partyId)
    self.chatInit =true
  end
  for k,v in pairs(data.Members) do
    --更新召唤师技能
    if v.PlayerSkill.Icon ~= "" then
      self.player_trans[tostring(v.PlayerId)]:FindChild("PlayerSkill/Mask/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",v.PlayerSkill.Icon,"UnityEngine.Sprite")
      if v.PlayerId == self.myPlayerId then 
        self.bottom:FindChild("PlayerSkill/Mask/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",v.PlayerSkill.Icon,"UnityEngine.Sprite")
      end
    end
    --初始化个人数据
    if v.PlayerId == self.myPlayerId and v.RoleLocked then 
      local roleid = v.Role.Id
      local skillid = v.PlayerSkill.Id
      local runepageid = v.RunePageDeckId
      self:InitMyData(roleid,skillid,runepageid)
    end
  end
end

function DraftHeroSelectCtrl:NotifyBattlePreStart(e)
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

function DraftHeroSelectCtrl:CreateLoadingPanel()
  GameManager.CreatePanel("PVPBattleLoading")
  --Debugger.LogError("进入战斗加载界面")
  PVPBattleLoadingAPI_1.Instance:SetParamBy18(self.TeamAData,self.TeamBData)
  
end

function DraftHeroSelectCtrl:NotifyUTGPVPBattleStart(e)
  if e.Type =="NotifyUTGPVPBattleStart" then
    
    --删除面板
    for i=1, (GameManager.PanelRoot.transform.childCount-1) do
      --Object.DestroyImmediate(GameManager.PanelRoot.transform:GetChild(0).gameObject,true)
      Object.Destroy(GameManager.PanelRoot.transform:GetChild(i-1).gameObject)
    end      
    
    UTGData.Instance().BattlePosition =tonumber(e.Content:get_Item("Position"):ToString())
    UTGData.Instance().BattleGroup = tonumber(e.Content:get_Item("Group"):ToString())
  
    coroutine.start(self.DoLoadBattleScene,self,e.Content:get_Item("Map"):ToString())
    
    return true
 end
 return false

end

function DraftHeroSelectCtrl:DoLoadBattleScene(mapResource)

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



function DraftHeroSelectCtrl:NotifyBattleDraftChange(e)
  if e.Type =="NotifyBattleDraftChange" then
    local data = json.decode(e.Content:get_Item("Draft"):ToString())
    if data ==nil then
      Debugger.LogError("NotifyBattleDraftChange 数据为空")
    end
    self:UpdateUI(data)
    return true
 end
 return false
end

--删除除自身外所有UI
function DraftHeroSelectCtrl:DestroyOtherUI()
  local index = tonumber(DraftHeroSelectAPI.Instance.this.transform:GetSiblingIndex())
  for i=index-1,0,-1 do   
      Object.Destroy(GameManager.PanelRoot.transform:GetChild(i).gameObject)
  end
end


function DraftHeroSelectCtrl:Start()
  if UTGDataTemporary.Instance().DraftContent~=nil then 
    self:NotifyBattleDraftChange(UTGDataTemporary.Instance().DraftContent)
  end
  if UTGDataTemporary.Instance().DraftPartyContent~=nil then 
    self:NotifyPartyChange(UTGDataTemporary.Instance().DraftPartyContent)
  end

  if UTGDataTemporary.Instance().DraftData~=nil then 
    self:UpdateUI(UTGDataTemporary.Instance().DraftData)
  end
  if UTGDataTemporary.Instance().DraftPartyData~=nil then 
    self:UpdatePartyChangeData(UTGDataTemporary.Instance().DraftPartyData)
  end

  self:DestroyOtherUI()
end

--初始化
function DraftHeroSelectCtrl:Init()
  self.player_trans = {}
  self.myPlayerId = UTGData.Instance().PlayerData.Id
  self.step = 10 --10:禁英雄 20:锁定 30:最后调整

  self.role_trans = {}
  self.skin_trans = {}
  self.temp_icon = self.middle:FindChild("Temp")

  self.select_role_tran = self.middle:FindChild("Select_Tran")
  self.select_role_tran.gameObject:SetActive(false)

  self.myTeamPlayerData = {} --我方队伍玩家数据 暂时只用playerid
  --所有角色
  self.data_allRole = {}
  for k,v in pairs(UTGData.Instance().RolesData) do
    local role = {}
    role.Id = v.Id
    role.Icon = UTGData.Instance().SkinsData[tostring(v.Skin)].Icon
    self.data_allRole[tostring(role.Id)] = role
  end
  self:Init_Top()
  self:Init_Left(self.data_draft.PartyPlayers[1])
  self:Init_Right(self.data_draft.PartyPlayers[2])

  self:Init_Bottom()
  self:Init_Middle()
  self:Init_Change()
  self:Init_MyTeamRoleIds()

  self.isInit = true
end

--
function DraftHeroSelectCtrl:GetMyRolesData()
  self.data_myRole = {}
  for i,v in ipairs(UTGData.Instance():GetOwnRoleData()) do
    local role = {}
    role.Id = v.Id
    role.Icon = UTGData.Instance().SkinsData[tostring(v.Skin)].Icon
    table.insert(self.data_myRole,role)
  end
end

--自己是否为当前操作者
function DraftHeroSelectCtrl:IsOperator()
  for k,v in pairs(self.data_draft.Operators) do
    if self.myPlayerId == v then 
      return true
    end
  end
  return false
end

--更新 UI
function DraftHeroSelectCtrl:UpdateUI(data)
  self.data_draft = data
  self.stepInit = self.stepInit or {}
  if self.isInit ~= true then 
    self:Init()
    self.isInit = true
  end
  self.step = data.Step

  self.middle:FindChild("Gray_Ban").gameObject:SetActive(false)
  self.middle:FindChild("Gray_Lock").gameObject:SetActive(false)

  if (data.Step == 10 or data.Step ==11) and self.stepInit[tostring(data.Step)] ~=true then --禁英雄
    self.middle:FindChild("Gray_Ban").gameObject:SetActive(true)
    self:UpdatePlayerStep(data)
    self.stepInit[tostring(data.Step)] =true
  elseif data.Step ==20 and self.stepInit[tostring(data.Step)] ~=true then -- 选人
    self.top_fx.gameObject:SetActive(false)
    self.top_fx.gameObject:SetActive(true)
    self.top_text:GetComponent("UnityEngine.UI.Text").text = "<color=#FE7C31FF>选</color> 姬神"
    self:GetMyRolesData()
    self:Init_HeroList(self.data_myRole,true)
    self.middle:FindChild("Gray_Lock").gameObject:SetActive(true)
    self:UpdatePlayerStep(data)
    self.stepInit[tostring(data.Step)] =true
  elseif data.Step >20 and data.Step <30 and self.stepInit[tostring(data.Step)] ~=true then -- 还是选人
    self.middle:FindChild("Gray_Lock").gameObject:SetActive(true)
    self:UpdatePlayerStep(data)
    self.stepInit[tostring(data.Step)] =true
  elseif data.Step ==30 and self.stepInit[tostring(data.Step)] ~=true then -- 调整
    self.top_fx.gameObject:SetActive(false)
    self.top_fx.gameObject:SetActive(true)
    self.coroutine_setlasttime =coroutine.start(self.SetLastTimeMov,self)
    self:SetPlayerChangeButShow()
    self.stepInit[tostring(data.Step)] =true
  end
  --禁用
  if data.Step<=20 then 
    local forbidRoleId_A = data.ForbidRoles[1][1]
    if forbidRoleId_A~=nil and forbidRoleId_A>0 and self.forbid_a~=true then 
      self.top:FindChild("Mask-A").gameObject:SetActive(true)
  self.top:FindChild("Mask-A/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",self.data_allRole[tostring(forbidRoleId_A)].Icon,"UnityEngine.Sprite") 
      self.forbid_a = true
    end
    local forbidRoleId_B = data.ForbidRoles[2][1]
    if forbidRoleId_B~=nil and forbidRoleId_B>0 and self.forbid_b~=true then 
      self.top:FindChild("Mask-B").gameObject:SetActive(true)
      self.top:FindChild("Mask-B/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",self.data_allRole[tostring(forbidRoleId_B)].Icon,"UnityEngine.Sprite") 
    end
  end

  self:UpdatePlayerIcon(data)
  --自己是否锁定
  if self.isLockRole ~= true then 
    self:Update_HeroList(self:IsOperator())
  else
    self.middle:FindChild("Gray_Lock").gameObject:SetActive(false)
    self.middle:FindChild("But_Lock").gameObject:SetActive(false)
  end

end
--设置交换按钮显示
function DraftHeroSelectCtrl:SetPlayerChangeButShow()
  local myRoleId = self.data_allPlayer[tostring(self.myPlayerId)].RoleId
  for k,v in pairs(self.myTeamRoleIds) do
    local otherPlayerId = tonumber(k)
    if otherPlayerId~=self.myPlayerId then 
      local otherRoleId = self.data_allPlayer[tostring(k)].RoleId  
      if self:IsHaveRole(self.myPlayerId,otherRoleId) and self:IsHaveRole(otherPlayerId,myRoleId) then 
        self.player_trans[tostring(k)]:FindChild("Change").gameObject:SetActive(true)
      end
    end
  end
end
--
function DraftHeroSelectCtrl:IsHaveRole(playerid,roleid) 
  for k,v in pairs(self.myTeamRoleIds[tostring(playerid)]) do
    if tonumber(roleid) == v then 
      return true
    end
  end
  return false
end
--最后调整 倒计时协程
function DraftHeroSelectCtrl:SetLastTimeMov()
  local time = 20
  self.top_text.gameObject:SetActive(false)
  self.top_text_last.gameObject:SetActive(true)
  while time>0 do 
    self.top_text_last:GetComponent("UnityEngine.UI.Text").text = string.format("最后调整00:%02d",time)
    coroutine.wait(1)
    time = time -1 
  end
  self.top_text_last:GetComponent("UnityEngine.UI.Text").text = "最后调整00:00"
end


--聊天
function DraftHeroSelectCtrl:SetPlayerChat(data)
  local playerId = tostring(data.PlayerId)
  self.chat_cor = self.chat_cor or {}
  if self.chat_cor[playerId] ~= nil then 
    coroutine.stop(self.chat_cor[playerId])
  end
  self.chat_cor[playerId] = coroutine.start(self.SetPlayerChatMov,self,playerId,data.Message)
end
function DraftHeroSelectCtrl:SetPlayerChatMov(playerid,text)
  local temp = self.player_trans[tostring(playerid)]:FindChild("Chat")
  temp:FindChild("Text"):GetComponent("UnityEngine.UI.Text").text = text
  temp.gameObject:SetActive(true)
  coroutine.wait(5)
  temp.gameObject:SetActive(false)
  self.chat_cor[playerid] = nil
end

--初始化rune playerskill
function DraftHeroSelectCtrl:InitMyData(roleid,skillid,runepageid)
  if self.roleDataInit and self.select_role_id == roleid then
    return 
  end
  --Debugger.LogError(roleid.." "..skillid.." "..runepageid)
  self.select_role_id = roleid
  --召唤师技能
  if skillid == 0 then 
    --默认召唤师技能
    self.playerskill_skilldata = UTGData.Instance():GetDefaultPlayerSkill()
    self:ChangePlayerSkill(self.playerskill_skilldata)
  else
    self.playerskill_skilldata = UTGData.Instance().SkillsData[tostring(skillid)]
  end
  self.bottom:FindChild("PlayerSkill").gameObject:SetActive(true)
  self.bottom:FindChild("PlayerSkill/Mask/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",self.playerskill_skilldata.Icon,"UnityEngine.Sprite")
  
  --符文
  if runepageid == 0 then 
    --默认芯片组
    self:NetChangeRune(DraftHeroSelectAPI.Instance:GetDefaultRunePageId())    
  else
    self.selectRunePageId = runepageid
  end
  --
  DraftHeroSelectAPI.Instance:SetSelectRunePageId(self.selectRunePageId)
  self.bottom:FindChild("Rune/Rune").localPosition = Vector3.zero

  --皮肤
  local roledeck =  UTGData.Instance():GetRoleDeckByRoleId(self.select_role_id)
  if roledeck~=nil then  -- 是自己拥有的英雄
    self.select_skin_id = roledeck.Skin
  else
    self.select_skin_id = UTGData.Instance().RolesData[tostring(roleid)].Skin
  end
  self:Init_SkinList(self.select_role_id,self.select_skin_id)

  self.roleDataInit = true
end


function DraftHeroSelectCtrl:ChangePlayerSkill(skilldata)
  self.playerskill_skilldata = skilldata
  self:ChangeBattleConfig(3,skilldata.Id,self.ChangeBattleConfigHandler_PlayerSkill)
end
function DraftHeroSelectCtrl:ClickChangePlayerSkill()
  GameManager.CreatePanel("PVPPlayerSkillSelect")
  PVPPlayerSkillSelectAPI.Instance:SetCurrentSkillId(self.playerskill_skilldata.Id)
end

--修改芯片
function DraftHeroSelectCtrl:NetChangeRune(selectRunePageId)
  self.selectRunePageId = selectRunePageId
  --Debugger.LogError("1111111111")
  self:ChangeBattleConfig(4,self.selectRunePageId,self.ChangeBattleConfigHandler_Rune)
end



--更新玩家流程方面
function DraftHeroSelectCtrl:UpdatePlayerStep(data)
  self.cor_player = self.cor_player or {}
  for k,v in pairs(self.cor_player) do
    coroutine.stop(v)
  end
  --重置UI
  for k,v in pairs(self.player_trans) do
    v.transform:FindChild("Pre").gameObject:SetActive(false)
    v.transform:FindChild("Select").gameObject:SetActive(false)
  end
  local time = data.CountDown
  local operators = data.Operators
  local nex_operators = data.NextOperators
  --开始倒计时
  for k,v in pairs(operators) do
    self.cor_player[tostring(v)] = coroutine.start(self.SetPlayerTimeMov,self,v,time) 
  end
  --预备
  for k,v in pairs(nex_operators) do
    self.player_trans[tostring(v)]:FindChild("Pre").gameObject:SetActive(true)
  end
end

--倒计时协程
function DraftHeroSelectCtrl:SetPlayerTimeMov(playerid,time)
  local tran = self.player_trans[tostring(playerid)]:FindChild("Select")
  tran.gameObject:SetActive(true)
  self:SetFxOk(tran)
  while time>0 do 
    tran:FindChild("Time"):GetComponent("UnityEngine.UI.Text").text = ""..time
    coroutine.wait(1)
    time = time -1 
  end
  tran:FindChild("Time"):GetComponent("UnityEngine.UI.Text").text = "0"
  self.cor_player[tostring(playerid)] = nil 
end
--更新 玩家icon方面
function DraftHeroSelectCtrl:UpdatePlayerIcon(data)
  local playerdata = {}
  for k,v in pairs(data.PartyPlayers) do
    for k1,v1 in pairs(v) do
      playerdata[tostring(v1.PlayerId)] = v1
    end
  end
  self.data_allPlayer = playerdata
  for k,v in pairs(playerdata) do
    local temp = self.player_trans[tostring(k)]
    if v.RoleId>0 then 
      temp:FindChild("Icon/Mask/Icon").gameObject:SetActive(true)
      --Debugger.LogError(self.data_allRole[tostring(v.RoleId)].Icon)
      temp:FindChild("Icon/Mask/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",self.data_allRole[tostring(v.RoleId)].Icon,"UnityEngine.Sprite")
   
    end
    if v.RoleLocked == true then 
      temp:FindChild("Lock").gameObject:SetActive(true)
      if self:IsMyTeam(v.PlayerId) then 
        temp:FindChild("PlayerSkill").gameObject:SetActive(true)
      end
      if self.cor_player[tostring(v.PlayerId)]~=nil then 
        coroutine.stop(self.cor_player[tostring(v.PlayerId)])
      end
      self.player_trans[tostring(v.PlayerId)]:FindChild("Select").gameObject:SetActive(false)
      if v.PlayerId == self.myPlayerId then 
        self.isLockRole = true
      end
    end

    if v.PlayerId == self.myPlayerId and v.RoleId>0 and v.RoleLocked == false then 
      self.select_role_tran.gameObject:SetActive(true)
      self:SetSelectRoleTran(self.role_trans[tostring(self.select_role_id)])
      self.middle:FindChild("But_Lock").gameObject:SetActive(true)
    end
  end


  if self.changeInit~=true then 
    local playerids = {}
    for k,v in pairs(data.PartyPlayers) do
      for k1,v1 in pairs(v) do
        table.insert(playerids,v1.PlayerId)
      end
    end
    for i=1,#playerids do
      self.change:GetChild(i-1).name = ""..playerids[i]
    end
    self.changeInit=true
  end
end

function DraftHeroSelectCtrl:IsMyTeam(playerid)
  for k,v in pairs(self.myTeamPlayerData) do 
    if v.PlayerId == tonumber(playerid) then 
      return true
    end
  end
  return false
end

--Top初始化
function DraftHeroSelectCtrl:Init_Top()
  self.top_text:GetComponent("UnityEngine.UI.Text").text = "<color=#EAC769FF>禁</color> 姬神"
  self.top:FindChild("Mask-A").gameObject:SetActive(false)
  self.top:FindChild("Mask-B").gameObject:SetActive(false)
end
--Left初始化
function DraftHeroSelectCtrl:Init_Left(data)
  self:FillPlayer(self.left:FindChild("Grid"),data)
end
--Right初始化
function DraftHeroSelectCtrl:Init_Right(data)
  self:FillPlayer(self.right:FindChild("Grid"),data)
end
--Middle初始化
function DraftHeroSelectCtrl:Init_Middle()
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.middle:FindChild("But_Ban").gameObject)--禁止
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickBan,self) 
  listener = NTGEventTriggerProxy.Get(self.middle:FindChild("But_Lock").gameObject)--锁定
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickLock,self)
  self:Init_HeroList(self.data_allRole)  
end

--Bottom初始化
function DraftHeroSelectCtrl:Init_Bottom()
  self.bottom:FindChild("Rune/Rune").localPosition = Vector3.New(0,-500,0)
  DraftHeroSelectAPI.Instance:RuneInit()

  self.bottom:FindChild("PlayerSkill").gameObject:SetActive(false)
  local listener = NTGEventTriggerProxy.Get(self.bottom:FindChild("PlayerSkill/But").gameObject)--更换
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickChangePlayerSkill,self) 

end
function DraftHeroSelectCtrl:Reset_MiddleScroll()
  self.middle:FindChild("But_Hero/Liang").gameObject:SetActive(false)
  self.middle:FindChild("But_Skin/Liang").gameObject:SetActive(false)
  local grid = self.middle:FindChild("Scroll/Grid")
  for i=grid.childCount-1,0,-1 do
    Object.Destroy(grid:GetChild(i).gameObject)
  end
  self:SetSelectRoleTran(self.middle)
  self.select_role_tran.gameObject:SetActive(false)
  self.role_trans = {}
end
function DraftHeroSelectCtrl:SetSelectRoleTran(tran)
  self.select_role_tran:SetParent(tran)
  self.select_role_tran.transform.localPosition = Vector3.zero
  self.select_role_tran.transform.localRotation = Quaternion.identity
  self.select_role_tran.transform.localScale = Vector3.one
  self.select_role_tran:SetAsFirstSibling()
end

function DraftHeroSelectCtrl:Update_HeroList(isOpen)
  for k,v in pairs(self.role_trans) do
    if isOpen then
      v:FindChild("Mask/Icon-Lock").gameObject:SetActive(false)
      v:FindChild("Bg-Lock").gameObject:SetActive(false)
    else
      v:FindChild("Mask/Icon-Lock").gameObject:SetActive(true)
      v:FindChild("Bg-Lock").gameObject:SetActive(true)
    end
  end
  if isOpen then 
    for k,v in pairs(self:GetForbidRoleIds()) do
      local temp = self.role_trans[tostring(v)] 
      if temp~=nil then
        temp:FindChild("Mask/Icon-Lock").gameObject:SetActive(true)
        temp:FindChild("Bg-Lock").gameObject:SetActive(true)
      end
    end
  end
end
--获得不能选择的role
function DraftHeroSelectCtrl:GetForbidRoleIds()
  local roleIds = {}
  --禁用的
  for k,v in pairs(self.data_draft.ForbidRoles) do
    for k1,v1 in pairs(v) do
      table.insert(roleIds,v1)
    end
  end
  --别人已经选择的
  for k,v in pairs(self.data_draft.PartyPlayers) do
    for k1,v1 in pairs(v) do
      if v1.RoleId>0 then 
        table.insert(roleIds,v1.RoleId)
      end
    end
  end
  return roleIds
end
function DraftHeroSelectCtrl:Init_HeroList(rolesdata,ismy)
  ismy = ismy or false
  self:Reset_MiddleScroll()
  self.middle:FindChild("But_Hero/Liang").gameObject:SetActive(true)
  self:SetFxOk(self.middle:FindChild("But_Hero/Liang"))
  local data = {}
  if ismy then 
    data = rolesdata
  else
    for k,v in pairs(rolesdata) do
    table.insert(data,v)
    end
    local function Sort(a,b)
      return a.Id<b.Id
    end
    table.sort(data,Sort)
  end
  
  local grid = self.middle:FindChild("Scroll/Grid")
  local temp = {}
  for i=1,#data do
    temp = GameObject.Instantiate(self.temp_icon)
    temp.name = tostring(i)
    self.role_trans[tostring(data[i].Id)] = temp
    temp.gameObject:SetActive(true)
    temp.transform:SetParent(grid)
    temp.transform.localPosition = Vector3.zero
    temp.transform.localRotation = Quaternion.identity
    temp.transform.localScale = Vector3.one
    local roleicon_sprite = NTGResourceController.Instance:LoadAsset("roleicon",data[i].Icon,"UnityEngine.Sprite")
    temp:FindChild("Mask/Icon"):GetComponent("UnityEngine.UI.Image").sprite = roleicon_sprite
    temp:FindChild("Mask/Icon-Lock"):GetComponent("UnityEngine.UI.Image").sprite = roleicon_sprite
    temp:FindChild("Mask/Icon-Lock").gameObject:SetActive(true)
    if ismy then
      UITools.GetLuaScript(temp.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickSelectRole_Lock,data[i].Id)
    else
      UITools.GetLuaScript(temp.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickSelectRole_ForBid,data[i].Id)
    end
  end
end

function DraftHeroSelectCtrl:GetSkinData(roleid)
  local skindata = {}
  for k,v in pairs(UTGData.Instance().SkinsData) do
    if v.RoleId == tonumber(roleid) then
      local skin = {}
      skin.Id = v.Id 
      skin.Icon = v.Icon
      skin.IsOwn = UTGData.Instance():IsOwnSkinBySkinId(skin.Id)
      table.insert(skindata,skin)
    end
  end
  local function Sort(a,b)
    if a.IsOwn == b.IsOwn then 
      return a.Id<b.Id
    end
    return a.IsOwn
  end
  table.sort(skindata,Sort)
  return skindata
end 

function DraftHeroSelectCtrl:Init_SkinList(roleid,skinid)
  local data = {}
  data = self:GetSkinData(roleid) 
  self:Reset_MiddleScroll()
  self.middle:FindChild("But_Skin/Liang").gameObject:SetActive(true)
  self:SetFxOk(self.middle:FindChild("But_Skin/Liang"))
  local grid = self.middle:FindChild("Scroll/Grid")
  local temp = {}

  for i=1,#data do
    temp = GameObject.Instantiate(self.temp_icon)
    temp.name = tostring(i)
    self.skin_trans[tostring(data[i].Id)] = temp
    temp.gameObject:SetActive(true)
    temp.transform:SetParent(grid)
    temp.transform.localPosition = Vector3.zero
    temp.transform.localRotation = Quaternion.identity
    temp.transform.localScale = Vector3.one
    local roleicon_sprite = NTGResourceController.Instance:LoadAsset("roleicon",data[i].Icon,"UnityEngine.Sprite")
    temp:FindChild("Mask/Icon"):GetComponent("UnityEngine.UI.Image").sprite = roleicon_sprite
    temp:FindChild("Mask/Icon-Lock"):GetComponent("UnityEngine.UI.Image").sprite = roleicon_sprite
    if data[i].IsOwn then--该皮肤玩家拥有
      temp:FindChild("Mask/Icon-Lock").gameObject:SetActive(false)
    else
      temp:FindChild("Mask/Icon-Lock").gameObject:SetActive(true)      
    end

    UITools.GetLuaScript(temp.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickSelectSkin,data[i].Id)
  end
  self:ClickSelectSkin(skinid)
end

function DraftHeroSelectCtrl:FillPlayer(grid,data)
  local api = grid:GetComponent("NTGLuaScript").self
  api:ResetItemsSimple(#data)
  --Debugger.LogError("")
  for i=1,#api.itemList do
    local temp = api.itemList[i].transform
    temp.name = tostring(i)
    self.player_trans[tostring(data[i].PlayerId)] = temp
    temp:FindChild("Icon/Mask/Icon").gameObject:SetActive(false)
    if data[i].PlayerId == self.myPlayerId then
      self.myTeamPlayerData = data
      temp:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = string.format("<color=#F7ED57FF>%s</color>",data[i].PlayerName)
    else
      temp:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = data[i].PlayerName
    end
    temp:FindChild("PlayerSkill").gameObject:SetActive(false)
    temp:FindChild("Lock").gameObject:SetActive(false)
    temp:FindChild("Chat").gameObject:SetActive(false)
    UITools.GetLuaScript(temp:FindChild("Change").gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickChange,data[i].PlayerId)
    temp:FindChild("Change").gameObject:SetActive(false)
  end

end

function DraftHeroSelectCtrl:ClickSelectRole_ForBid(roleid)
  if self.role_trans[tostring(roleid)]:FindChild("Mask/Icon-Lock").gameObject.activeSelf then 
    return
  end
  self.select_role_tran.gameObject:SetActive(true)
  self:SetSelectRoleTran(self.role_trans[tostring(roleid)])
  self.select_role_id = tonumber(roleid)
  self.middle:FindChild("But_Ban").gameObject:SetActive(true)

end

--禁用
function DraftHeroSelectCtrl:ClickBan()
  self:RequestForbidDraftRole(self.select_role_id)
end
function DraftHeroSelectCtrl:RequestForbidDraftRole(roleid)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestForbidDraftRole"),
                                JProperty.New("RoleId",tonumber(roleid)))
  request.Handler = TGNetService.NetEventHanlderSelf(self.RequestForbidDraftRoleHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self:SetWait(true)
end
function DraftHeroSelectCtrl:RequestForbidDraftRoleHandler(e)
  self:SetWait(false)
  if e.Type =="RequestForbidDraftRole" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 and self~=nil and self.this~=nil then 
      self.middle:FindChild("But_Ban").gameObject:SetActive(false)
    end
    return true
  end
  return false
end

--选择role
function DraftHeroSelectCtrl:ClickSelectRole_Lock(roleid)
  if self.role_trans[tostring(roleid)]:FindChild("Mask/Icon-Lock").gameObject.activeSelf then 
    return
  end
  self:ChangeBattleConfig(1,roleid,self.ChangeBattleConfigHandler_Role)
end
function DraftHeroSelectCtrl:ChangeBattleConfigHandler_Role(result)
  if result~=1 then
    print("ChangeBattleConfigHandler_Role "..result)
  end

end
function DraftHeroSelectCtrl:ChangeBattleConfigHandler_Skin(result)
  if result~=1 then
    print("ChangeBattleConfigHandler_Skin "..result)
  else
    self:ClickSelectSkin(self.select_skin_id)
  end
end
function DraftHeroSelectCtrl:ChangeBattleConfigHandler_Rune(result)
  if result~=1 then
    print("ChangeBattleConfigHandler_Rune "..result)
  else
    DraftHeroSelectAPI.Instance:SetSelectRunePageId(self.selectRunePageId)
  end
end
function DraftHeroSelectCtrl:ChangeBattleConfigHandler_PlayerSkill(result)
  if result~=1 then
    print("ChangeBattleConfigHandler_PlayerSkill "..result)
  else
    self.bottom:FindChild("PlayerSkill/Mask/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",self.playerskill_skilldata.Icon,"UnityEngine.Sprite")
  end
end

--修改出战配置
function DraftHeroSelectCtrl:ChangeBattleConfig(changetype,changeid,netDelegate)
  if changetype == 1 then 
    if self.changeBattleConfigDelegate_role ~=nil then return end
    self.changeBattleConfigDelegate_role = netDelegate
    self.select_role_id = tonumber(changeid)
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
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestChangeDraftConfig"),
                                JProperty.New("ChangeType",tonumber(changetype)),
                                JProperty.New("ChangeId",tonumber(changeid)))
  request.Handler = TGNetService.NetEventHanlderSelf(self.ChangeBattleConfigHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self:SetWait(true)
  --self.waitNet_ChangeBattleConfig = true
end

function DraftHeroSelectCtrl:ChangeBattleConfigHandler(e)
  self:SetWait(false)
  if e.Type =="RequestChangeDraftConfig" then
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

--锁定
function DraftHeroSelectCtrl:ClickLock()
  self:ConfirmBattleConfig()
end
--确认出战配置
function DraftHeroSelectCtrl:ConfirmBattleConfig()
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestConfirmDraftConfig"))
  request.Handler = TGNetService.NetEventHanlderSelf(self.ConfirmBattleConfigHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self:SetWait(true)
end
function DraftHeroSelectCtrl:ConfirmBattleConfigHandler(e)
  self:SetWait(false)
  if e.Type =="RequestConfirmDraftConfig" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 and self~=nil and self.this~=nil  then
      self.middle:FindChild("But_Lock").gameObject:SetActive(false)     
    end
    return true
  end
  return false
end

--选中skin
function DraftHeroSelectCtrl:ClickSelectSkin(skinid)
  local temp = self.skin_trans[tostring(skinid)]
  if temp==nil then return end
  if temp:FindChild("Mask/Icon-Lock").gameObject.activeSelf then 
    print("buy it!")
    return
  end
  self.select_role_tran.gameObject:SetActive(true)
  self:SetSelectRoleTran(temp)
  if self.select_skin_id == skinid then return end
  self.select_skin_id = skinid
  self:ChangeBattleConfig(2,self.select_skin_id,self.ChangeBattleConfigHandler_Skin)
end

function DraftHeroSelectCtrl:NotifyDraftRoleSwitchRequest(e)
  if e.Type =="NotifyDraftRoleSwitchRequest" then
    local request = tonumber(e.Content:get_Item("Requester"):ToString())
    if request > 0 and self~=nil and self.this~=nil then
      self:Show_Change(request,false)
    end

    return true
 end
 return false
end

function DraftHeroSelectCtrl:NotifyDraftRoleSwitchCancel(e)
  if e.Type =="NotifyDraftRoleSwitchCancel" then
    local canceller = tonumber(e.Content:get_Item("Canceller"):ToString())
    if canceller~=self.myPlayerId and self~=nil and self.this~=nil then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("对方取消交换")
      self.change_main.gameObject:SetActive(false)
    end

    return true
 end
 return false
end

function DraftHeroSelectCtrl:NotifyDraftRoleSwitchAnswer(e)
  if e.Type =="NotifyDraftRoleSwitchAnswer" then
    local replier = tonumber(e.Content:get_Item("Replier"):ToString())
    local agree = e.Content:get_Item("Agree"):ToString()

    if self~=nil and self.this~=nil then
      if agree == "True" then 
        GameManager.CreatePanel("SelfHideNotice")
        SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("交换姬神成功")
      else
        --Debugger.LogError("replier = "..replier)
        if replier~=self.myPlayerId then 
          GameManager.CreatePanel("SelfHideNotice")
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("对方取消交换")
        end
      end
      self.change_main.gameObject:SetActive(false)
    end
    return true
 end
 return false
end

--获取 我队 各队友可用roleId
function DraftHeroSelectCtrl:Init_MyTeamRoleIds()
  self.myTeamRoleIds = {}
  self.temp_myTeamPlayerIds = {}
  for k,v in pairs(self.data_draft.PartyPlayers) do
    for k1,v1 in pairs(v) do
      if v1.PlayerId == self.myPlayerId then 
        for k2,v2 in pairs(v) do
          table.insert(self.temp_myTeamPlayerIds,v2.PlayerId)
        end
      end
    end
  end
  self:RequestPlayerValidRoles(self.temp_myTeamPlayerIds[1])
end


function DraftHeroSelectCtrl:RequestPlayerValidRoles(playerid)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestPlayerValidRoles"),
                                JProperty.New("PlayerId",tonumber(playerid)))
  request.Handler = TGNetService.NetEventHanlderSelf(self.RequestPlayerValidRolesHandler,self)
  TGNetService.GetInstance():SendRequest(request)
end
function DraftHeroSelectCtrl:RequestPlayerValidRolesHandler(e)
  if e.Type =="RequestPlayerValidRoles" then
    local roleIds = json.decode(e.Content:get_Item("RoleIds"):ToString())
    if roleIds~=nil and self~=nil and self.this~=nil then 
      self.myTeamRoleIds[tostring(self.temp_myTeamPlayerIds[1])] = roleIds
      table.remove(self.temp_myTeamPlayerIds,1)
      if #self.temp_myTeamPlayerIds>0 then
        self:RequestPlayerValidRoles(self.temp_myTeamPlayerIds[1])
      end
    end
    return true
 end
 return false
end

function DraftHeroSelectCtrl:RequestSwitchDraftRoles(playerid)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSwitchDraftRoles"),
                                JProperty.New("RequestedPlayerId",tonumber(playerid)))
  request.Handler = TGNetService.NetEventHanlderSelf(self.RequestSwitchDraftRolesHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self.change_playerid = playerid
  self:SetWait(true)
end
function DraftHeroSelectCtrl:RequestSwitchDraftRolesHandler(e)
  self:SetWait(false)
  if e.Type =="RequestSwitchDraftRoles" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1  and self~=nil and self.this~=nil then 

    end
    return true
 end
 return false
end




function DraftHeroSelectCtrl:Init_Change()
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.change_main:FindChild("But_He/Yes").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickChangeYes,self) 
  listener = NTGEventTriggerProxy.Get(self.change_main:FindChild("But_He/No").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickChangeNo,self) 
  listener = NTGEventTriggerProxy.Get(self.change_main:FindChild("But_You/No").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickChangeCanel,self) 

end
--交换
function DraftHeroSelectCtrl:ClickChange(playerid)
  self:RequestSwitchDraftRoles(playerid)
end
function DraftHeroSelectCtrl:RequestSwitchDraftRoles(playerid)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestSwitchDraftRoles"),
                                JProperty.New("RequestedPlayerId",tonumber(playerid)))
  request.Handler = TGNetService.NetEventHanlderSelf(self.RequestSwitchDraftRolesHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self.change_playerid = playerid
  self:SetWait(true)
end
function DraftHeroSelectCtrl:RequestSwitchDraftRolesHandler(e)
  self:SetWait(false)
  if e.Type =="RequestSwitchDraftRoles" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1  and self~=nil and self.this~=nil then 
      self:Show_Change(self.change_playerid,true)
    end
    return true
 end
 return false
end

--show
function DraftHeroSelectCtrl:Show_Change(playerid,isActive) 
  self.change_main.gameObject:SetActive(true)
  local temp = nil
  if isActive then 
    temp = self.change:FindChild(tostring(playerid))
  else
    temp = self.change:FindChild(tostring(self.myPlayerId))
  end
  self.change_main.position = temp.position

  self.change_main:FindChild("But_You").gameObject:SetActive(false)
  self.change_main:FindChild("But_He").gameObject:SetActive(false)
  local icon_youget = self.data_allRole[tostring(self.data_allPlayer[tostring(playerid)].RoleId)].Icon 
  local icon_heget = self.data_allRole[tostring(self.data_allPlayer[tostring(self.myPlayerId)].RoleId)].Icon 

  if isActive then 
    self.change_main:FindChild("But_You").gameObject:SetActive(true)
  else
    self.change_main:FindChild("But_He").gameObject:SetActive(true)
  end

  self.change_main:FindChild("You/Mask/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",icon_youget,"UnityEngine.Sprite")
  self.change_main:FindChild("He/Mask/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",icon_heget,"UnityEngine.Sprite")
end
function DraftHeroSelectCtrl:ClickChangeCanel()
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestCancelDraftRolesSwitch"))
  request.Handler = TGNetService.NetEventHanlderSelf(self.RequestCancelDraftRolesSwitchHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self:SetWait(true)
end
function DraftHeroSelectCtrl:RequestCancelDraftRolesSwitchHandler(e)
  self:SetWait(false)
  if e.Type =="RequestCancelDraftRolesSwitch" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1  and self~=nil and self.this~=nil then 
      self.change_main.gameObject:SetActive(false)
    end
    return true
 end
 return false
end
function DraftHeroSelectCtrl:ClickChangeYes()
  self:RequestAnswerDraftRolesSwitch(true)
end
function DraftHeroSelectCtrl:ClickChangeNo()
  self:RequestAnswerDraftRolesSwitch(false)
end
function DraftHeroSelectCtrl:RequestAnswerDraftRolesSwitch(agree)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestAnswerDraftRolesSwitch"),
                                JProperty.New("Agree",agree))
  request.Handler = TGNetService.NetEventHanlderSelf(self.RequestAnswerDraftRolesSwitchHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self:SetWait(true)
end
function DraftHeroSelectCtrl:RequestAnswerDraftRolesSwitchHandler(e)
  self:SetWait(false)
  if e.Type =="RequestAnswerDraftRolesSwitch" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1  and self~=nil and self.this~=nil then 
      self.change_main.gameObject:SetActive(false)
    end
    return true
 end
 return false
end


function DraftHeroSelectCtrl:OnDestroy()
  UTGDataTemporary.Instance().DraftContent=nil
  UTGDataTemporary.Instance().DraftPartyContent=nil
  UTGDataTemporary.Instance().DraftData = nil
  UTGDataTemporary.Instance().DraftPartyData = nil
  self.cor_player = self.cor_player or {}
  for k,v in pairs(self.cor_player) do 
    coroutine.stop(v)
  end
  self.chat_cor = self.chat_cor or {}
  for k,v in pairs(self.chat_cor) do 
    coroutine.stop(v)
  end
  if self.coroutine_setlasttime~=nil then 
    coroutine.stop(self.coroutine_setlasttime) 
  end
  TGNetService.GetInstance():RemoveEventHander("NotifyPartyChange", self.Delegate_NotifyPartyChange)
  TGNetService.GetInstance():RemoveEventHander("NotifyBattlePreStart", self.Delegate_NotifyBattlePreStart)
  TGNetService.GetInstance():RemoveEventHander("NotifyUTGPVPBattleStart", self.Delegate_NotifyUTGPVPBattleStart)
  TGNetService.GetInstance():RemoveEventHander("NotifyBattleDraftChange", self.Delegate_NotifyBattleDraftChange)
  TGNetService.GetInstance():RemoveEventHander("NotifyDraftRoleSwitchRequest", self.Delegate_NotifyDraftRoleSwitchRequest)
  TGNetService.GetInstance():RemoveEventHander("NotifyDraftRoleSwitchCancel", self.Delegate_NotifyDraftRoleSwitchCancel)
  TGNetService.GetInstance():RemoveEventHander("NotifyDraftRoleSwitchAnswer", self.Delegate_NotifyDraftRoleSwitchAnswer)
  TGNetService.GetInstance():RemoveEventHander("NotifyUTGPVPBattleStart", self.Delegate_NotifyUTGPVPBattleStart)

  self.this = nil
  self = nil
end