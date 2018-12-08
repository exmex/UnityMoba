require "System.Global"
require "Logic.UTGData.UTGDataTemporary"
require "Logic.UTGData.UTGData"
class("UTGDataOperator")

local json = require "cjson"

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"

local Data = UTGData.Instance()

function UTGDataOperator:Awake(this) 
  self.this = this
  UTGDataOperator.Instance = self
  self.EventHandler = {}
  self.Dialog = {}
  self.roomInfo = nil
  self.partyInfo = nil
  self.roomChangeNotify = ""
  self.partyChangeNotify = ""
  self.itemId = 0       --用于传递PackagePanel中的itemId

  self:GlobalUsefulData()

  self.NormalResourceList = {}
  self.matchTime=0;
  self.battleMode=0;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  self.ChatList = {}
  self.loadDone = false
  self.panelList = {}
  self.actiNoReadCnt = 0
  self.canBuy = false   --用于判断钻石是否已经被点券补足
end

function UTGDataOperator:Start()
  self:GlobalUsefulData()
  self:DataUpdate()
  self:NoticeControl()
  self:GetPanelEntrance()
  UTGDataTemporary.Instance():StatusData()
  self.markPlayTime = TGNetService.GetServerTime()
end

function UTGDataOperator:WriteFile(fileName,object)
  if Directory.Exists(NTGResourceController.GetDataPath("GlobalData")) == false then
    Directory.CreateDirectory(path)
  end
  local path = NTGResourceController.GetDataPath("GlobalData")..fileName
  local streamText = json.encode(object)
  NTGResourceController.WriteAllText(path,streamText)
end
function UTGDataOperator:ReadFile(fileName)
  local result = {Exists = false,Object = {}}
  if Directory.Exists(NTGResourceController.GetDataPath("GlobalData")) == false then
    Directory.CreateDirectory(path)
  end
  local path = NTGResourceController.GetDataPath("GlobalData")..fileName
  if File.Exists(path) == false then
    return result
  end
  result.Exists = true
  local jsonData = NTGResourceController.ReadAllText(path)
  result.Object = json.decode(jsonData)
  return result
end

function UTGDataOperator:AddEventHandler(eventName,func)
  self.EventHandler[eventName] = TGNetService.NetEventHanlderSelf( func,self)
  TGNetService.GetInstance():AddEventHandler(eventName, self.EventHandler[eventName],0)
end

function UTGDataOperator:RemoveEventHandler(eventName)
  TGNetService.GetInstance():RemoveEventHander(eventName, self.EventHandler[eventName])
  self.EventHandler[eventName] = nil
end

function UTGDataOperator:SetPreUIRight(tran)
  local index = tran:GetSiblingIndex()-1
  --Debugger.LogError(index)
  if index < 0 then return end

  local temp = GameManager.PanelRoot:GetChild(index)
  --Debugger.LogError("ffff  "..temp.name)
  while (temp.name == "SelfHideNoticePanel" and index >=0 )do 
      index = index - 1
      if index < 0 then return end
      temp = GameManager.PanelRoot:GetChild(index)
      --Debugger.LogError(temp.name)
  end     
 
  if temp.name == "UTGMainPanel" then 
    UTGMainPanelAPI.Instance:ShowSelf()
  elseif temp.name == "GrowGuidePanel" then 
    GrowGuideAPI.Instance:ShowSelf()
  end
  
end

function UTGDataOperator:LoadAssetAsync() -- 预加载 assetbundle
  local result = {Done = false}     
  if self.coroutine_loadAssetAsync~=nil then coroutine.stop(self.coroutine_loadAssetAsync) end
  self.coroutine_loadAssetAsync = coroutine.start(UTGDataOperator.LoadAssetAsyncMov,self,result)
  --coroutine.start(UTGDataOperator.LoadAssetAsyncMain,self)

  return result
end

function UTGDataOperator:LoadAssetAsyncMain() -- 在主界面的预加载特效
  if UTGMainPanelAPI ~=nil and UTGMainPanelAPI.Instance ~=nil then
    UTGMainPanelAPI.Instance:SetLoadFx(true)
  end
  while self.AllPanelLoad == false do
    coroutine.wait(0.1)
  end
  if UTGMainPanelAPI ~=nil and UTGMainPanelAPI.Instance ~=nil then
    UTGMainPanelAPI.Instance:SetLoadFx(false)
  end
end


function UTGDataOperator:LoadAssetAsyncMov(result)

  self.panelList  = {"SelectBattleMode","NewBattle14","NewBattle15","PVPHeroSelect","HeroInfo","Store","Rank","shader","Rune","GuildNo","GuildHave"}

  self.assetLoader = NTGResourceController.AssetLoader.New()
  --self.panelList.assetLoader = 

  while #self.panelList>0 do
    local name = self.panelList[1]
    self.assetLoader:LoadAsset(name,name .. "Panel")
    self.currentAssetName = name
    table.remove(self.panelList,1)
      while self.assetLoader.Done == false do
        coroutine.step()
      end
    coroutine.wait(0.05)
  end
  self.assetLoader:Close()
  self.assetLoader = nil
  self.coroutine_loadAssetAsync = nil
end

function UTGDataOperator:UILoadAsset(assetLoader)
  self.panelAssetLoading = self.panelAssetLoading or {}
  self.loadFlag = true
  while #self.panelList ~= 0 do
    if self.panelList[#self.panelList].loadType == 1 then
      self.panelAssetLoading[name] = true
      assetLoader:LoadAsset(self.panelList[#self.panelList].name,self.panelList[#self.panelList].name .. "Panel")
      table.remove(self.panelList,#self.panelList)
      while assetLoader.Done == false do
        coroutine.step()
      end
    else
      local result 
      result = GameManager.CreatePanelAsync(self.panelList[#self.panelList].name)
      while result.Done == false do
        coroutine.step()
      end
      table.remove(self.panelList,#self.panelList)
      if StoreCtrl ~= nil and StoreCtrl.Instance ~= nil then
        StoreCtrl.Instance:partActive(0)
        coroutine.step()
      end
      self.loadDone = true
    end
  end
  self.loadFlag = false
end


function UTGDataOperator:ResultType(result)
  local resultFeedback = ""
  if result == -1 then
    resultFeedback = "服务器睡（维）觉（护）了"       --服务器维护
  elseif result == 2 then 
    resultFeedback = "服务器记（数）忆（据）读取错误"    --服务器DB出错
  elseif result == 3 then
    resultFeedback = "服务器口袋（cache）里的东西乱（错）了"      --服务器cache出错
  elseif result == 4 then
    resultFeedback = "客户端参数有误"
  elseif result == 10 then
    resultFeedback = "玩家并不存在"
  elseif result == 11 then
    resultFeedback = "玩家已经在线"
  elseif result == 21 then
    resultFeedback = "当前房间的玩家正在战斗中"
  elseif result == 22 then
    resultFeedback = "当前房间人数已满"
  elseif result == 31 then
    resultFeedback = "匹配等待中"
  elseif result == 32 then
    resultFeedback = "匹配超时"
  elseif result == 40 then
    resultFeedback = "玩家不在战斗中"
  elseif result == 41 then
    resultFeedback = "英雄选择超时，战斗已经准备开始"
  elseif result == 42 then
    resultFeedback = "选择了重复的英雄"
  elseif result == 43 then
    resultFeedback = "当前英雄尚未获得，不可选择"
  elseif result == 44 then
    resultFeedback = "玩家已经选择了英雄"
  elseif result == 50 then
    resultFeedback = "该武器不存在"
  elseif result == 51 then
    resultFeedback = "玩家不在战斗中"
  elseif result == 52 then
    resultFeedback = "购买武器金钱不足"
  elseif result == 60 then
    resultFeedback = "该装备不存在"
  elseif result == 61 then
    resultFeedback = "不在战斗中"
  elseif result == 62 then
    resultFeedback = "目标位置已存在装备"
  elseif result == 63 then
    resultFeedback = "目标位置无装备"
  elseif result == 64 then
    resultFeedback = "购买装备金钱不足"
  elseif result == 11 then
    resultFeedback = "装备槽已满"
  end
  
  return resultFeedback
end

--***********************
--调用全局面板
--***********************

local typeName = ""
local func = ""

--[[
local co = coroutine.create(function ()

    local async = GameManager.CreatePanelAsync(typeName)
    while async.Done == false do
      coroutine.yield(0.05)
    end  
    end)

function UTGDataOperator:GetPanel(typeNameThis)
  typeName = typeNameThis
  UTGDataOperator.Instance():StartCoroutine(NTGLuaCoroutine.New(UTGDataOperator.Instance(), UTGDataOperator.GlobalPanel,typeName))
  --coroutine.resume(co)
end

function UTGDataOperator:GlobalPanel(name)
  local async = GameManager.CreatePanelAsync(name)
  while async.Done == false do
    coroutine.yield(WaitForSeconds.New(0.05))
  end
  if async.Done == true then
    self:StopCoroutine(NTGLuaCoroutine.New(self, NTGDataOperator.GlobalPanel))
  end
end  
--]]
--***********************调用结束

function UTGDataOperator:NoticeControl()
  self.headIconNotice = false
  if(self.friendNotice==nil)then
    self.friendNotice = false
  end
  self.emailNotice = false
  self.playNowNotice = false
  self.playNowActivityNotice = false
  self.adventureNotice = false
  self.adventureActivityNotice = false
  self.ladderNotice = false
  self.ladderActivityNotice = false
  self.ladderLockAllNotice = false
  self.bounitMatchNotice = false
  self.bounitMatchActivityNotice = false
  self.bounitMatchLockAllNotice = false
  self.showNotice = false
  self.activityNotice = false
  self.activityNoticeCount = 0
  self.heroNotice = false
  self.runeNotice = false
  ---判断是否查看过新增召唤师技能
  self.skillNotice = false
  local skillNoticeData = self:ReadFile("PlayerSkillNotice.ini")
  if skillNoticeData.Exists then 
    self.skillNotice = skillNoticeData.Object.RedPoint
  end
  -------------------------------
  self.prepareNotice = false
  self.achievementNotice = false
  self.packageNotice = false
  self.fullBottomButtonNotice = false
  self.preparArrowToUpOrDown = true       --true:up     false:down
  self.netDelayShowOrHide = false         --true:show   false:hide
  self.isMatching = false
  self.battleGroupButtonNotice = false
  self.battleGroupButtonNoticeII = false
  --self.actiRed = false
end

function UTGDataOperator:DataUpdate()
  -- body
  self.itemDataUpdate = true    --背包数据更新

end

function  UTGDataOperator:GlobalUsefulData()
  -- body
  --金币增益

  self.TimesLimitDoubleMoney_Time = 0
  self.TimesLimitDoubleMoney_Rate = 0
  self.HoursLimitDoubleMoney_Hour = 0
  self.HoursLimitDoubleMoney_Rate = 0

  --经验增益
  self.TimesLimitDoubleEXP_Time = 0
  self.TimesLimitDoubleEXP_Rate = 0
  self.HoursLimitDoubleEXP_Hour = 0
  self.HoursLimitDoubleEXP_Rate = 0

  --英雄体验
  self.TryHero = {}
  self.TryHeroList = {}

  --皮肤体验
  self.TrySkin = {}
  self.TrySkinList = {}
end

function UTGDataOperator:GetPanelEntrance()
  -- body
  self.PreEquipsPanelEntrance = ""
  self.RunePanelEntrance = ""
  self.PackagePanelEntrance = ""
end

function UTGDataOperator:Invitation(e)
  if GameManager.PanelRoot:GetChild((GameManager.PanelRoot.childCount) - 1).name ~= "NewBattle15panel" or 
      GameManager.PanelRoot:GetChild((GameManager.PanelRoot.childCount) - 1).name ~= "NewBattle19panel" then
  if e.Type == "NotifyInvitation" then
      UTGDataTemporary.Instance().InviterId = tonumber(e.Content:get_Item("InviterId"):ToString())
      UTGDataTemporary.Instance().InviterName = tostring(e.Content:get_Item("InviterName"):ToString())
      UTGDataTemporary.Instance().GroupType = tonumber(e.Content:get_Item("GroupType"):ToString())
      UTGDataTemporary.Instance().GroupId = tonumber(e.Content:get_Item("GroupId"):ToString())
      UTGDataTemporary.Instance().GroupName = tostring(e.Content:get_Item("GroupName"):ToString())
      UTGDataTemporary.Instance().SubType = tonumber(e.Content:get_Item("BSubType"):ToString())
      UTGDataTemporary.Instance().MainType=tonumber(e.Content:get_Item("BMainType"):ToString());
      UTGDataTemporary.Instance().InviterIcon=tostring(e.Content:get_Item("InviterIcon"):ToString());
      UTGDataTemporary.Instance().InviterIconFrame=tonumber(e.Content:get_Item("InviterIconFrameId"):ToString());
      UTGDataTemporary.Instance().InviterGrade=tonumber(e.Content:get_Item("InviterGrade"):ToString());
      print("UTGDataTemporary.Instance().SubType " .. UTGDataTemporary.Instance().SubType)
      local msg = "邀请您组队"
      self.mapName = ""
      self.count = 0
      if (UTGDataTemporary.Instance().MainType == 1) then
        msg = msg.."<color=#FF7F00>实战对抗·</color>"
        self.mapName = "实战对抗"
      end
      if (UTGDataTemporary.Instance().MainType == 2) then
        msg = msg.."<color=#FF7F00>娱乐模式·</color>"
        self.mapName = "娱乐模式"
      end
      if (UTGDataTemporary.Instance().MainType == 3) then
        msg = msg.."<color=#FF7F00>人机练习·</color>"
        self.mapName = "人机练习"
      end
      if (UTGDataTemporary.Instance().MainType == 4) then
        msg = msg.."<color=#FF7F00>开房间·</color>"
        self.mapName = "开房间"
      end
      if (UTGDataTemporary.Instance().MainType == 5) then
        msg = msg.."<color=#FF7F00>排位赛</color>"
        self.mapName = "排位赛"
      end
      if UTGDataTemporary.Instance().SubType == 10 then
        msg = msg.."<color=#FF7F00>1V1红枫桥门</color>"
        self.mapName = "1V1红枫桥门"
        self.count = 1
      end
      if UTGDataTemporary.Instance().SubType == 30 then
        msg = msg.."<color=#FF7F00>3V3拉法叶公路</color>"
        self.mapName = "3V3长平攻防战"
        self.count = 3
      end
      if UTGDataTemporary.Instance().SubType == 50 then
        msg = msg.."<color=#FF7F00>5V5战争岛屿</color>"
        self.mapName = "5V5战争岛屿"
        self.count = 5
      end
      if UTGDataTemporary.Instance().SubType == 51 then
        msg = msg.."<color=#FF7F00>5V5酒吧大乱斗</color>"
        self.mapName = "5V5长平攻防战"
        self.count = 5
      end
      if UTGDataTemporary.Instance().SubType == 62 then
        msg = msg.."<color=#FF7F00>5V5战争岛屿</color>"
        self.mapName = "5V5长平攻防战"
        self.count = 5
      end
      self.msgg = msg
      --GameManager.CreatePanel("NeedConfirmNotice", nil)
      self:ListenPanelLoadDone1()
    return true
  end
  end
  return false
end

function UTGDataOperator:UpdateFriendStatus(e)
  if e.Type == "NotifyFriendStatus" then
    self.FriendId = tonumber(e.Content:get_Item("FriendId"):ToString())
    self.Status = tonumber(e.Content:get_Item("Status"):ToString())
    
    if(Data.FriendList==nil or Data.FriendList[tostring(self.FriendId)]==nil)then
      return true
    end
    Data.FriendList[tostring(self.FriendId)].Status = self.Status

    for i = 1,GameManager.PanelRoot.childCount do
      if GameManager.PanelRoot:GetChild(i-1).name == "NewBattle15Panel" then
        if NewBattle15API.Instance ~= nil then
          NewBattle15API.Instance:UpdateFriendInfo(self.FriendId,self.Status)
        end
      end
    end
    
  end
  return true
end

function UTGDataOperator:EnterPartySelect()
  if self.wait_RequestAnswerInvitation == true then return end
  if UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject.name == "ButtonLeft" then
    --Cancel
    --self.Dialog[#self.Dialog]:GetComponent("NTGLuaScript").self:DestroySelf() 
    --table.remove(self.Dialog,#self.Dialog)  
    self.agree = 0
  else 
    --Enter
    
    self.roomChangeNotify = TGNetService.NetEventHanlderSelf( UTGDataOperator.RoomChangeHandler,self)
    TGNetService.GetInstance():AddEventHandler("NotifyRoomChange", self.roomChangeNotify,1)
    self.partyChangeNotify = TGNetService.NetEventHanlderSelf( UTGDataOperator.PartyChangeHandler,self)
    TGNetService.GetInstance():AddEventHandler("NotifyPartyChange", self.partyChangeNotify,1)
    self.agree = 1
  end
  
  if self.agree == 1 then 
    --GameManager.CreatePanel("NewBattle15")
    --self.this:StartCoroutine(NTGLuaCoroutine.New(self, UTGDataOperator.ListenPanelLoadDone))
    local EnterPartySelectRequest = NetRequest.New()
    EnterPartySelectRequest.Content = JObject.New(JProperty.New("Type","RequestAnswerInvitation"),
                                              JProperty.New("GroupType",UTGDataTemporary.Instance().GroupType),
                                              JProperty.New("GroupId",UTGDataTemporary.Instance().GroupId),
                                              JProperty.New("Inviter",UTGDataTemporary.Instance().InviterId),
                                              JProperty.New("Agree",self.agree))
    EnterPartySelectRequest.Handler = TGNetService.NetEventHanlderSelf(UTGDataOperator.EnterPartySelectHandler,self)
    TGNetService.GetInstance():SendRequest(EnterPartySelectRequest)
  else
    local EnterPartySelectRequest = NetRequest.New()
    EnterPartySelectRequest.Content = JObject.New(JProperty.New("Type","RequestAnswerInvitation"),
                                              JProperty.New("GroupType",UTGDataTemporary.Instance().GroupType),
                                              JProperty.New("GroupId",UTGDataTemporary.Instance().GroupId),
                                              JProperty.New("Inviter",UTGDataTemporary.Instance().InviterId),
                                              JProperty.New("Agree",self.agree))
    EnterPartySelectRequest.Handler = TGNetService.NetEventHanlderSelf(UTGDataOperator.EnterPartySelectHandler,self)
    TGNetService.GetInstance():SendRequest(EnterPartySelectRequest) 
  end
  self.wait_RequestAnswerInvitation = true
end
function UTGDataOperator:EnterPartySelectHandler(e)
  self.wait_RequestAnswerInvitation = false
  if e.Type == "RequestAnswerInvitation" then
    
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      if self.agree == 0 then
          self.Dialog[#self.Dialog]:GetComponent("NTGLuaScript").self:DestroySelf()
          --table.remove(self.Dialog,#self.Dialog)
      elseif self.agree == 1 then
        

        for k = #self.Dialog,1,-1 do
          self.Dialog[k]:GetComponent("NTGLuaScript").self:DestroySelf()
          --table.remove(self.Dialog,k)
        end
        coroutine.start(UTGDataOperator.ListenPanelLoadDone,self)
             
      end
    elseif result == 771 then
      --print("当前队伍满员")
        self.Dialog[#self.Dialog]:GetComponent("NTGLuaScript").self:DestroySelf() 
        table.remove(self.Dialog,#self.Dialog)
        GameManager.CreatePanel("SelfHideNotice")
        if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("当前队伍已满员")
        end
    elseif result == 777 then
        self.Dialog[#self.Dialog]:GetComponent("NTGLuaScript").self:DestroySelf()
        table.remove(self.Dialog,#self.Dialog) 
        GameManager.CreatePanel("SelfHideNotice")
        if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("当前队伍已解散")
        end
    elseif result == 515 then
        self.Dialog[#self.Dialog]:GetComponent("NTGLuaScript").self:DestroySelf()
        table.remove(self.Dialog,#self.Dialog) 
        GameManager.CreatePanel("SelfHideNotice")
        if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("当前队伍已满员")
        end
    elseif result == 0 then
        self.Dialog[#self.Dialog]:GetComponent("NTGLuaScript").self:DestroySelf()
    end


    return true
  end
  return false
end

function  UTGDataOperator:RoomChangeHandler(e)
  -- body
  if e.Type == "NotifyRoomChange" then
    self.roomInfo = e
    return true
  end
end

function  UTGDataOperator:PartyChangeHandler(e)
  -- body
  if e.Type == "NotifyPartyChange" then
    self.partyInfo = e
    return true
  end
end

function UTGDataOperator:ListenPanelLoadDone()
  local result = GameManager.CreatePanelAsync("NewBattle15")
  while result.Done ~= true do
    coroutine.wait(0.05)
  end
  
  if result.Done == true then
    --[[
    local EnterPartySelectRequest = NetRequest.New()
    EnterPartySelectRequest.Content = JObject.New(JProperty.New("Type","RequestAnswerInvitation"),
                                              JProperty.New("GroupType",UTGDataTemporary.Instance().GroupType),
                                              JProperty.New("GroupId",UTGDataTemporary.Instance().GroupId),
                                              JProperty.New("Inviter",UTGDataTemporary.Instance().InviterId),
                                              JProperty.New("Agree",self.agree))
    EnterPartySelectRequest.Handler = TGNetService.NetEventHanlderSelf(UTGDataOperator.EnterPartySelectHandler)
    TGNetService.GetInstance():SendRequest(EnterPartySelectRequest)  
    ]]

    coroutine.wait(0.1)

    --[[
    if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
      UTGMainPanelAPI.Instance:HideSelf()
    end
    ]]
    if NewBattle15API.Instance ~= nil then
      if self.roomInfo ~= nil then
        NewBattle15API.Instance:DirectUpdateRoom(self.roomInfo)
        self.roomInfo = nil
      end
      if self.partyInfo ~= nil then
        NewBattle15API.Instance:DirectUpdateParty(self.partyInfo)
        self.partyInfo = nil
      end 
    end
    TGNetService.GetInstance():RemoveEventHander("NotifyRoomChange", self.roomChangeNotify)
    TGNetService.GetInstance():RemoveEventHander("NotifyPartyChange", self.partyChangeNotify)
    --self.Dialog[#self.Dialog]:GetComponent("NTGLuaScript").self:DestroySelf()  
  end 
end

function UTGDataOperator:ListenPanelLoadDone1()
  local result = self:CreateDialog("NeedConfirmNotice")
  result:InitNoticeForNeedConfirmNotice("提示", UTGDataTemporary.Instance().InviterName, true, self.msgg, 2)
  if UTGDataTemporary.Instance().MainType == 5 then
    result:RankInvitation(UTGDataTemporary.Instance().InviterName,
                        UTGDataTemporary.Instance().InviterIcon,
                        UTGDataTemporary.Instance().InviterIconFrame,
                        UTGDataTemporary.Instance().InviterGrade,
                        self.msgg)
  end
  result:TwoButtonEvent("取消", UTGDataOperator.EnterPartySelect, self, "确认", UTGDataOperator.EnterPartySelect, self)
  result:SetTextToCenter()
end

function UTGDataOperator:GetHeroClassIcon(class)
  if class == 1 then
    self.ClassIconResource = ""
  elseif class == 2 then
    self.ClassIconResource = ""
  elseif class == 3 then
    self.ClassIconResource = ""
  elseif class == 4 then
    self.ClassIconResource = ""
  elseif class == 5 then
    self.ClassIconResource = ""
  end
  return self.ClassIconResource
end

function UTGDataOperator:GetSortedPropertiesByKey(typeName,id)
  local data = ""
  if typeName == "Skin" then
    data = UTGData.Instance().SkinsData[tostring(id)]
  elseif typeName == "Equip" then
    data = UTGData.Instance().EquipsData[tostring(id)]
  elseif typeName == "RunePVP" then
    data = UTGData.Instance().RunesData[tostring(id)].PVPAttr
  elseif typeName == "RunePVE" then
    data = UTGData.Instance().RunesData[tostring(id)].PVEAttr
  end
  if data ==nil then
    Debugger.LogError("GetSortedPropertiesByKey "..typeName.." id = "..id .." 找不到对应数据")
  end
  local skinProperties = {}
  for k,v in pairs(data) do
    local everyProperty = {[1] = {"XX",1},[2] = ""}--结构定义
    local temp = self:GetTemplateAttrCHSNameByKey(k)
    if temp ~=nil and v ~=0 then
      everyProperty[1][1] = temp[1]
      everyProperty[1][2] = temp[2]
      if typeName=="RunePVP" then
        if v>0 and v<=0.1 then everyProperty[2] = v*100 .. "%"
        else everyProperty[2] = v end
      else
        if v>0 and v<1 then
          everyProperty[2] = v*100 .. "%"
        else
          everyProperty[2] = v
        end
      end
      table.insert(skinProperties,everyProperty)
    end
  end
  --从小到大排序
  local isF = true
  for j=1 ,#skinProperties do
    isF = true
    for i=#skinProperties-1,j,-1 do
      if skinProperties[i][1][2] >skinProperties[i+1][1][2] then
          local temp = skinProperties[i]
          skinProperties[i] = skinProperties[i+1]
          skinProperties[i+1] =temp
         isF = false
       end
    end
    if isF then break end
  end 
  local foruse = {}
  for i = 1,#skinProperties do
    local temp = {Des = skinProperties[i][1][1],Attr = skinProperties[i][2]}
    --print("MMMMMMMMMMMMMMM " .. temp.Des)
    --print("AAAAAAAAAAAAAAA " .. temp.Attr)
    table.insert(foruse,temp)
  end
  return foruse
end

function UTGDataOperator:GetTemplateAttrCHSNameByKey(key)
  local CHSName = nil
  if key == "HP" then
    CHSName = {"最大生命",1}
  elseif key == "MP" then
    CHSName = {"最大法力",2}
  elseif key == "PAtk" then
    CHSName = {"物理攻击",3}
  elseif key == "MAtk" then
    CHSName = {"导术攻击",4}
  elseif key == "PDef" then
    CHSName = {"物理防御",5}
  elseif key == "MDef" then
    CHSName = {"导术抗性",6}
  elseif key == "MoveSpeed" then
    CHSName = {"移动速度",7}
  elseif key == "PpenetrateValue" then
    CHSName = {"物理穿透",8}
  elseif key == "PpenetrateRate" then
    CHSName = {"物理穿透率",9}
  elseif key == "MpenetrateValue" then
    CHSName = {"导术穿透",10}
  elseif key == "MpenetrateRate" then
    CHSName = {"导术穿透率",11}
  elseif key == "AtkSpeed" then
    CHSName = {"攻速加成",12}
  elseif key == "CritRate" then
    CHSName = {"暴击几率",13}
  elseif key == "CritEffect" then
    CHSName = {"暴击效果",14}
  elseif key == "PHpSteal" then
    CHSName = {"物理吸血",15}
  elseif key == "MHpSteal" then
    CHSName = {"导术吸血",16}
  elseif key == "CdReduce" then
    CHSName = {"冷却缩减",17}
  elseif key == "Tough" then
    CHSName = {"控性",18}
  elseif key == "HpRecover5s" then
    CHSName = {"每5s回血",19}
  elseif key == "MpRecover5s" then
    CHSName = {"每5s回能",20}
  end
  return CHSName
end

function UTGDataOperator:PlayerCurrencyChange(e)
  if e.Type == "NotifyPlayerCurrencyChange" then
    --存储新的玩家资源信息
    self.Action = tonumber(e.Content:get_Item("Action"):ToString())
    Data.PlayerData.Coin = tonumber(e.Content:get_Item("Coin"):ToString())
    Data.PlayerData.Gem = tonumber(e.Content:get_Item("Gem"):ToString())
    Data.PlayerData.Voucher = tonumber(e.Content:get_Item("Voucher"):ToString())
    --Data.PlayerData.Coin = tonumber(e.Content:get_Item("Coin"):ToString())    --芯片碎片
    
    
    
    for i = 1,GameManager.PanelRoot.childCount do
      if GameManager.PanelRoot:GetChild(i-1).name == "" then
        
      elseif GameManager.PanelRoot:GetChild(i-1).name == "" then
      
      end
    end
    return true
  end
  return false
end

function UTGDataOperator:OptionChange()
  print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
  local path = NTGResourceController.GetDataPath("GlobalData")
  if Directory.Exists(path) and File.Exists(path .. "OptionData.ini") then
    local jo = NTGResourceController.ReadAllText(path .. "OptionData.ini")
    local wantData = json.decode(jo)
    if wantData ~= nil then
      self.RoleOutLine = {wantData.RoleOutLine}        --0：角色描边关   1：角色描边开
      self.RoleOutLineOutSide = {wantData.RoleOutLineOutSide} 
      self.ShowFPS = {wantData.ShowFPS}            --0：帧数关       1：帧数开
      self.GameInput = {wantData.GameInput}          --0：局内打字关   1：局内打字开
      self.GameInputOutSide = {wantData.GameInputOutSide}
      self.CameraHeight = {wantData.CameraHeight}        --0：相机高度关   1：相机高度开
      self.CameraHeightOutSide = {wantData.CameraHeightOutSide}
      self.TargetInfo = {wantData.TargetInfo}
      self.CameraMove = {wantData.CameraMove}         --0：相机移动关   1：相机移动遥感    2：相机移动滑动
      self.CameraSensitivity = wantData.CameraSensitivity  --镜头敏感度:0~1数值
      self.TargetLock = wantData.TargetLock         --0：目标锁定-自由目标模式    1：目标锁定-锁定目标模式
      self.UseSkill = wantData.UseSkill           --0：辅助轮盘施法        1：自动简易施法
      self.TargetSelect = wantData.TargetSelect       --0：优先血量最少        1：优先最近单位
      self.ShowDiskPosition = wantData.ShowDiskPosition   --0：指定位置            1：手指位置
      self.CancelSkill = wantData.CancelSkill        --0：指定区域            1：指定位置
      self.MobAttack = wantData.MobAttack   --0：普通攻击    1：补刀键攻击
      self.ShowTargetIcon = wantData.ShowTargetIcon   --0：不显示头像   1：显示可攻击头像
      self.DiskLockTarget = wantData.DiskLockTarget  -- 0：轮盘锁定    1：头像锁定
      self.Shock = {wantData.Shock}   
      self.GameMusic = {wantData.GameMusic}          --0：游戏音乐关          1：游戏音乐开
      self.GameAudio = {wantData.GameAudio}        --0：游戏音效关          1：游戏音效开
      self.Speak = {wantData.Speak}              --0：语音聊天关          1：语音聊天开
      self.GameType = 0           --0：单人游戏            1：多人游戏
      self.CanSurrender = 0       --0：不可投降            1：可以投降
      self.WhereToUse = 0         --0：主界面点击          1：战斗中点击
      self.HQ = {wantData.HQ}
      self.GQ = {wantData.GQ}
      self.PQ = {wantData.PQ}
    end
  else
    if File.Exists(path .. "OptionData.ini") == false then
      --Directory.CreateDirectory(path)
    end 
    --System.IO.File.Create(path .. "OptionData.ini")
    self.RoleOutLine = {0}        --0：角色描边关   1：角色描边开
    self.RoleOutLineOutSide = {0} 
    self.ShowFPS = {0}            --0：帧数关       1：帧数开
    self.GameInput = {0}          --0：局内打字关   1：局内打字开
    self.GameInputOutSide = {0}
    self.CameraHeight = {0}        --0：相机高度关   1：相机高度开
    self.CameraHeightOutSide = {0}
    self.TargetInfo = {0}
    self.CameraMove = {0}         --0：相机移动关   1：相机移动遥感    2：相机移动滑动
    self.CameraSensitivity = 0  --镜头敏感度:0~100数值
    self.TargetLock = 0         --0：目标锁定-自由目标模式    1：目标锁定-锁定目标模式
    self.UseSkill = 0           --0：辅助轮盘施法        1：自动简易施法
    self.TargetSelect = 0       --0：优先血量最少        1：优先最近单位
    self.ShowDiskPosition = 0   --0：指定位置            1：手指位置
    self.CancelSkill = 0        --0：指定区域            1：指定位置
    self.MobAttack = 0   --0：普通攻击    1：补刀键攻击
    self.ShowTargetIcon = 0   --0：不显示头像   1：显示可攻击头像
    self.DiskLockTarget = 0  -- 0：轮盘锁定    1：头像锁定
    self.Shock = {0}
    self.GameMusic = {0}          --0：游戏音乐关          1：游戏音乐开
    self.GameAudio = {0}        --0：游戏音效关          1：游戏音效开
    self.Speak = {0}              --0：语音聊天关          1：语音聊天开
    self.GameType = 0           --0：单人游戏            1：多人游戏
    self.CanSurrender = 0       --0：不可投降            1：可以投降
    self.WhereToUse = 0         --0：主界面点击          1：战斗中点击
    self.HQ = {0}
    self.GQ = {0}
    self.PQ = {0}
  end
end

function UTGDataOperator:RecordOption()
  -- body 
  local stream = {RoleOutLine = self.RoleOutLine[1] , RoleOutLineOutSide = self.RoleOutLineOutSide[1] , ShowFPS = self.ShowFPS[1] , GameInput = self.GameInput[1], TargetInfo = self.TargetInfo[1]
                  , GameInputOutSide = self.GameInputOutSide[1] , CameraHeight = self.CameraHeight[1] , CameraHeightOutSide = self.CameraHeightOutSide[1] , CameraMove = self.CameraMove[1]
                  , CameraSensitivity = self.CameraSensitivity , TargetLock = self.TargetLock , UseSkill = self.UseSkill , TargetSelect = self.TargetSelect
                  , ShowDiskPosition = self.ShowDiskPosition , CancelSkill = self.CancelSkill , MobAttack = self.MobAttack , ShowTargetIcon = self.ShowTargetIcon
                  , DiskLockTarget = self.DiskLockTarget , Shock = self.Shock[1] , GameMusic = self.GameMusic[1] , GameAudio = self.GameAudio[1]  
                  , Speak = self.Speak[1] , HQ = self.HQ[1] , GQ = self.GQ[1] , PQ = self.PQ[1]
                }
  local path1 = NTGResourceController.GetDataPath("GlobalData") .. "OptionData.ini"
  NTGResourceController.WriteAllText(path1,json.encode(stream))
end





function UTGDataOperator:Test(num)
  --print("TestTestTestTest " .. num)
end


--***********************
--资源更新Notify
--***********************

--添加监听
function UTGDataOperator:AddNotifyChat() --监听聊天信息
  if self.IsAddNotifyChat~=nil and self.IsAddNotifyChat==true then return end
  self:AddEventHandler("NotifyChatMessage",UTGDataOperator.AddNotifyChatChange)
  self.IsAddNotifyChat = true
end
function UTGDataOperator:AddNotifyChatChange(e)
  if e.Type == "NotifyChatMessage" then
    for k,v in pairs(self.ChatList) do
      if v~=nil and v.this~=nil then 
        v:PushChatInfo(e)
      end
    end
    return true
  end
  return false
end
function UTGDataOperator:SetChatList(chatself)
  for i=#self.ChatList,1,-1 do
    if self.ChatList[i] == nil or self.ChatList[i].this == nil then 
      table.remove(self.ChatList,i)
    end
  end
  table.insert(self.ChatList,chatself)
end

-----------断线重连-----------------
function UTGDataOperator:AddNotifyConnect()
  self:AddEventHandler("Connect",UTGDataOperator.NotifyConnectHandler)
  self:AddEventHandler("Disconnect",UTGDataOperator.NotifyDisconnectHandler) 
end
function UTGDataOperator:NotifyDisconnectHandler(e)
  if e.Type == "Disconnect" then
    if self:IsInBattle() == false then 
      self:ReconnectLoadingStart()
    end
    return false
  end
  return false
end
function UTGDataOperator:ReconnectLoadingStart()
  local function Mov()
    coroutine.wait(2)
    GameManager.CreatePanel("Waiting")
    if self.coroutine_reconnect_time_count == nil then 
      self.coroutine_reconnect_time_count = coroutine.start(self.ReconnectTimeCount,self)
    end
    self.coroutine_reconnect_loading = nil
  end
  if self.coroutine_reconnect_loading~=nil then coroutine.stop(self.coroutine_reconnect_loading) end
  self.coroutine_reconnect_loading = coroutine.start(Mov,self)
end
function UTGDataOperator:ReconnectTimeCount()
  local time = 0
  while time<30 do 
    coroutine.wait(1)
    time = time + 1
    --Debugger.LogError(time)
  end

  --提示 退回登录界面
  if WaitingPanelAPI~=nil and WaitingPanelAPI.Instance~=nil then 
      WaitingPanelAPI.Instance:DestroySelf()
  end
  local instance = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
  instance:InitNoticeForNeedConfirmNotice("提示", "你与服务器断开连接，请重新登陆。", false, "", 1)
  instance:SetTextToCenter()
  instance:OneButtonEvent("确定",self.BackToLogin, self)

  self.coroutine_reconnect_time_count = nil
end
function UTGDataOperator:BackToLogin()
  self:CleanPanelRoot()
  GameManager.CreatePanel("NewLogin2")
end
function UTGDataOperator:IsInBattle()
  if UIBattleAPI~=nil and UIBattleAPI.Instance~=nil then 
    return true
  end
  return false
end
function UTGDataOperator:NotifyConnectHandler(e)
  if e.Type == "Connect" then
    if self.coroutine_reconnect_loading~=nil then coroutine.stop(self.coroutine_reconnect_loading) end
    if self.coroutine_reconnect_time_count~=nil then coroutine.stop(self.coroutine_reconnect_time_count) end
    self.coroutine_reconnect_loading=nil
    self.coroutine_reconnect_time_count=nil
    self:RequestGetAuth()
    return false
  end
  return false
end
function UTGDataOperator:RequestGetAuth()
  if UTGData.Instance().AccountId ==nil or UTGData.Instance().SessionKey==nil then return end
  --Debugger.Log(UTGData.Instance().AccountId.." "..UTGData.Instance().SessionKey)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","Auth"),
                                JProperty.New("AccountId",UTGData.Instance().AccountId),
                                JProperty.New("SessionKey",UTGData.Instance().SessionKey))
  request.Handler = TGNetService.NetEventHanlderSelf(self.RequestGetAuthHandler, self)
  TGNetService.GetInstance():SendRequest(request)
end
function UTGDataOperator:RequestGetAuthHandler(e)
  if e.Type == "Auth" then
    local request = NetRequest.New()
    request.Content = JObject.New(JProperty.New("Type","RequestAddOnlineStatus"))
    TGNetService.GetInstance():SendRequest(request)
    if WaitingPanelAPI~=nil and WaitingPanelAPI.Instance~=nil then 
      WaitingPanelAPI.Instance:DestroySelf()
    end
    return true
  end
  return false
end
function UTGDataOperator:AddNotifyPublicDataChange()
  --断线重连
  self:AddNotifyConnect()
  --Player信息变化
  self:AddEventHandler("NotifyPlayerDetailChange",UTGDataOperator.NotifyPlayerDetailChange)
  --Player已有金钱变化通知
  self:AddEventHandler("NotifyPlayerCurrencyChange",UTGDataOperator.NotifyPlayerCurrencyChange)
  --Player有roledeck信息变化
  self:AddEventHandler("NotifyPlayerRoleChange",UTGDataOperator.NotifyPlayerRoleChange)
  --Player有skindeck信息变化
  self:AddEventHandler("NotifyPlayerSkinChange",UTGDataOperator.NotifyPlayerSkinChange)
  --Player有rune信息变化
  self:AddEventHandler("NotifyPlayerRuneChange",UTGDataOperator.NotifyPlayerRuneChange)
  --Player有芯片组变化
  self:AddEventHandler("NotifyPlayerRunePageChange",UTGDataOperator.NotifyPlayerRunePageChange)
  --Player有芯片槽信息变化
  self:AddEventHandler("NotifyPlayerRuneSlotChange",UTGDataOperator.NotifyPlayerRuneSlotChange)
  self:AddEventHandler("NotifyPlayerItemChange",UTGDataOperator.NotifyPlayerItemChange)
  self:AddEventHandler("NotifyPlayerFriendChange",UTGDataOperator.NotifyPlayerFriendChange)
  self:AddEventHandler("NotifyPlayerFriendCandidateChange",self.playerFriendCandidateChangeNotify)
  self:AddEventHandler("NotifyPlayerForbidChange",UTGDataOperator.NotifyPlayerForbidChange)
  self:AddEventHandler("NotifyPlayerGrowUpChange",UTGDataOperator.NotifyPlayerGrowUpChange)
  self:AddEventHandler("NotifyNewPlayerSkill",UTGDataOperator.NotifyNewPlayerSkill)
  --等级任务
  self:AddEventHandler("NotifyPlayerLevelQuestChange",UTGDataOperator.NotifyPlayerLevelQuestChange)
  --等级奖励
  self:AddEventHandler("NotifyPlayerGrowUpDeckChange",UTGDataOperator.NotifyPlayerGrowUpDeckChange)
  --玩家获取
  self:AddEventHandler("NotifyPlayerGainChange",UTGDataOperator.NotifyPlayerGainChange)
  ----------------------------------------------------------------------------For:GuildAPI By:WYL--
  --自己筹备中战队
  self:AddEventHandler("NotifyPreparingGuildChange",self.PreparingGuildChangeNotify)  --Notify更新自己筹备中的战队
  self:AddEventHandler("NotifyPreparingGuildInfoChange",self.PreparingGuildInfoChangeNotify)  --Notify更新自己筹备中的战队Info
  self:AddEventHandler("NotifyPreparingGuildMemberChange",self.PreparingGuildMemberChangeNotify)  --Notify更新自己筹备中的战队成员
  --自己正式的战队
  self:AddEventHandler("NotifyGuildChange",self.GuildChangeNotify)
  self:AddEventHandler("NotifyGuildInfoChange",self.GuildInfoChangeNotify)
  self:AddEventHandler("NotifyGuildMemberChange",self.GuildMemberChangeNotify)
  --通知有新的战队申请
  self:AddEventHandler("NotifyGuildNewApplication",self.GuildNewApplicationNotify)
  --------------------------------------------------------------------------------------成就相关 --
  --成就信息变化
  self:AddEventHandler("NotifyPlayerAchievementInfoChange",UTGDataOperator.PlayerAchievementInfoChange)
  --获得新成就
  self:AddEventHandler("NotifyPlayerNewAchievement",UTGDataOperator.PlayerNewAchievement)
  --玩家成就进度
  self:AddEventHandler("NotifyPlayerAchievementProgressChange",UTGDataOperator.PlayerAchievementProgressChange)
  --玩家公告变化
  self:AddEventHandler("NotifyPlayerActivityChange",UTGDataOperator.PlayerActivityChange)
  --活动领取变化
  self:AddEventHandler("NotifyPlayerActivityQuestChange",UTGDataOperator.PlayerActivityQuestChange)
  --活动时间变化
  self:AddEventHandler("NotifyActivityQuestChange",UTGDataOperator.ActivityQuestChange)
end

--活动时间变化
function UTGDataOperator:ActivityQuestChange(e)
  if e.Type == "NotifyActivityQuestChange" then
    Debugger.Log("通知 NotifyActivityQuestChange---------------------------------------")
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local data = json.decode(e.Content:get_Item("ActivityQuest"):ToString())
    if data ==nil then Debugger.LogError("ActivityQuest nil") end
    if Action ==1 or Action == 2 then --新增 or 更新
      self.tabActiQuest[tostring(data.Id)] = data
    elseif Action ==3 then --删除
      self.tabActiQuest[tostring(data.Id)] = nil
    end

    if (ActivityApi ~= nil and ActivityApi.Instance ~= nil) then
      ActivityApi.Instance:updateSelectPageWhenTime(data,Action)
    end

    
     local awardRed = self:isActiQuestExistCanGetAward()
     if (awardRed == true or self.actiNoReadCnt > 0) then
      self.actiRed = true
     elseif (awardRed == false and self.actiNoReadCnt == 0) then
      self.actiRed = false
     end
    if (UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil) then
      UTGMainPanelAPI.Instance:UpdateNotice()
    end
    return true
  end
  return false
end

--活动领取变化
function UTGDataOperator:PlayerActivityQuestChange(e)
  if e.Type == "NotifyPlayerActivityQuestChange" then
    Debugger.Log("通知 NotifyPlayerActivityQuestChange--------------------------------------")
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local data = json.decode(e.Content:get_Item("PlayerActivityQuest"):ToString())
    if data ==nil then Debugger.LogError("PlayerActivityQuest nil") end
    if Action ==1 or Action == 2 then --新增 or 更新
      UTGData.Instance().PlayerActivityQuestDeck[tostring(data.ActivityQuestId)] = data
    elseif Action ==3 then --删除
      UTGData.Instance().PlayerActivityQuestDeck[tostring(data.ActivityQuestId)] = nil
    end

    if (ActivityApi ~= nil and ActivityApi.Instance ~= nil) then
      ActivityApi.Instance:updateSelectPageWhenGet(data.ActivityQuestId)
    end

     local awardRed = self:isActiQuestExistCanGetAward()
     if (awardRed == true or self.actiNoReadCnt > 0) then
      self.actiRed = true
     elseif (awardRed == false and self.actiNoReadCnt == 0) then
      self.actiRed = false
     end

      if (self.actiRed == false) then
        Debugger.Log("UTGDataOperator:PlayerActivityQuestChange(e) false")
      elseif (self.actiRed == true) then
        Debugger.Log("UTGDataOperator:PlayerActivityQuestChange(e) true")
      end
    if (UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil) then
      UTGMainPanelAPI.Instance:UpdateNotice()
    end

    return true
  end
  return false
end


--玩家公告变化
function UTGDataOperator:PlayerActivityChange(e)
  if e.Type == "NotifyPlayerActivityChange" then
    --Debugger.Log("--NotifyPlayerActivityChange")
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local data = json.decode(e.Content:get_Item("PlayerActivity"):ToString())
    if data ==nil then Debugger.LogError("PlayerActivity nil") end
    if Action ==1 or Action == 2 then --新增 or 更新
      UTGData.Instance().PlayerActivityDeck = data
    elseif Action ==3 then --删除
      UTGData.Instance().PlayerActivityDeck = nil
    end

    if NoticeApi~= nil and NoticeApi.Instance~=nil then
      NoticeApi.Instance:updateRed()
    end

--    for i,v in pairs(Data.PlayerActivityDeck.ReadAnnouncements) do
--      Debugger.Log("Data.PlayerActivityDeck.ReadAnnouncements   "..v)
--    end
    return true
  end
  return false
end

--成就信息变化,进行刷新成就奖励
function UTGDataOperator:PlayerAchievementInfoChange(e) 
  if e.Type == "NotifyPlayerAchievementInfoChange" then
    --Debugger.Log("--NotifyPlayerAchievementInfoChange")
    self.oldAchieveDeck = UITools.CopyTab(UTGData.Instance().PlayerAchievementInfoDeck)
    local Data = UTGData.Instance().PlayerAchievementInfoDeck
    local data = json.decode(e.Content:get_Item("PlayerAchievementInfo"):ToString())
    if data ==nil then Debugger.LogError("PlayerAchievementInfo nil") end
    UTGData.Instance().PlayerAchievementInfoDeck = data

    if AchievementApi~= nil and AchievementApi.Instance~=nil then
      AchievementApi.Instance:updateGetAward()
    end
    return true
  end
  return false
end

--获得新成就：弹窗
function UTGDataOperator:PlayerNewAchievement(e) 
  if e.Type == "NotifyPlayerNewAchievement" then
    --Debugger.Log("--NotifyPlayerNewAchievement")
    local Data = UTGData.Instance().PlayerAchievementsDeck
    local data = json.decode(e.Content:get_Item("PlayerAchievement"):ToString())
    if data ==nil then Debugger.LogError("PlayerAchievement nil") end
    Data[tostring(data.AchievementId)] = data

    local newAchieveDeck = UITools.CopyTab(UTGData.Instance().PlayerAchievementInfoDeck)
    local tabOne = {}
    tabOne.old = self.oldAchieveDeck
    tabOne.new = newAchieveDeck
    tabOne.id = data.AchievementId

    if (self.tabAchieveNew == nil) then
      self.tabAchieveNew = {}
    end
    table.insert(self.tabAchieveNew,tabOne)
    return true
  end
  return false
end

--玩家成就进度
function UTGDataOperator:PlayerAchievementProgressChange(e) 
  if e.Type == "NotifyPlayerAchievementProgressChange" then
    --Debugger.Log("--NotifyPlayerAchievementProgressChange")
    local Data = UTGData.Instance().PlayerAchievementProgressDeck
    local data = json.decode(e.Content:get_Item("PlayerAchievementProgress"):ToString())
    if data ==nil then Debugger.LogError("PlayerAchievementProgressChange nil") end
    
    Data[tostring(data.Type)] = data

    return true
  end
  return false
end
---------------------------------------------------------通知有新的战队申请--
function UTGDataOperator:GuildNewApplicationNotify(e)  
 
  if e.Type == "NotifyGuildNewApplication" then
    local data = json.decode(e.Content:ToString())
    
    UTGDataOperator.Instance.battleGroupButtonNotice =true 
    if(UTGMainPanelAPI~=nil and UTGMainPanelAPI.Instance~=nil )then
      UTGMainPanelAPI.Instance:UpdateNotice()
    end
    if(GuildHaveAPI~=nil and GuildHaveAPI.Instance~=nil )then
      GuildHaveAPI.Instance.II2_ApplicationPoint.gameObject:SetActive(true)  --此界面的红点
    end
    
    return true;
  else
    return false;
  end
end
---------------------------------------------------------Notify更新自己的战队--
function UTGDataOperator:GuildChangeNotify(e)   --Debugger.LogError("S1")
  --应该只是刚加入战队用一次，其他情况点击按钮或者Notify更新局部信息或成员
  if e.Type == "NotifyGuildChange" then
    local data = json.decode(e.Content:ToString())
    if(data.Action==1 or data.Action==2)then
        UTGData.Instance().MyselfGuild =data.Guild;
      --数据整理 for Action
      local members={};
      for k,v in pairs(UTGData.Instance().MyselfGuild.Members) do
        members[tostring(v.Id)]=v;
      end
      UTGData.Instance().MyselfGuild.Members=members;
      
      if GuildHaveAPI ~= nil and GuildHaveAPI.Instance ~= nil then
        --战队-信息
        GuildHaveAPI.Instance:InitializeMyselfGuildDetailInfo(UTGData.Instance().MyselfGuild)
        GuildHaveAPI.Instance:InitializeMyselfGuildDetailMembers(UTGData.Instance().MyselfGuild)
        --战队-成员
        GuildHaveAPI.Instance:InitializeMyselfGuildInfo(UTGData.Instance().MyselfGuild)
        GuildHaveAPI.Instance:InitializeMyselfGuildMembers(UTGData.Instance().MyselfGuild.Members)
        --GuildHaveAPI.Instance:ShowPanel("II","II1");--------------------------------------------------------------------->>
      end
    end
    
    
    
    return true;
  else
    return false;
  end
end
---------------------------------------------------------Notify更新自己的战队Info--
function UTGDataOperator:GuildInfoChangeNotify(e)  --Debugger.LogError("S2")
  --应该只是刚加入战队用一次，其他情况点击按钮或者Notify更新局部信息或成员
  if e.Type == "NotifyGuildInfoChange" then
    local data = json.decode(e.Content:ToString())
    if(data.Action==1 or data.Action==2)then
      --数据整理 for Action
      UTGData.Instance().MyselfGuild.Id               = data.GuildInfo.Id;
      UTGData.Instance().MyselfGuild.IconId             = data.GuildInfo.IconId        
      UTGData.Instance().MyselfGuild.Name             = data.GuildInfo.Name             
      UTGData.Instance().MyselfGuild.Declaration      = data.GuildInfo.Declaration        
      UTGData.Instance().MyselfGuild.Leader           = data.GuildInfo.Leader          
      UTGData.Instance().MyselfGuild.MemberLimit      = data.GuildInfo.MemberLimit    
      UTGData.Instance().MyselfGuild.MemberAmount     = data.GuildInfo.MemberAmount   
      UTGData.Instance().MyselfGuild.Star             = data.GuildInfo.Star            
      UTGData.Instance().MyselfGuild.Level            = data.GuildInfo.Level          
      UTGData.Instance().MyselfGuild.SeasonActivePoint= data.GuildInfo.SeasonActivePoint
      UTGData.Instance().MyselfGuild.WeekActivePoint  = data.GuildInfo.WeekActivePoint  
      UTGData.Instance().MyselfGuild.LimitLevel       = data.GuildInfo.LimitLevel   
      UTGData.Instance().MyselfGuild.LimitGrade       = data.GuildInfo.LimitGrade     
      UTGData.Instance().MyselfGuild.LimitIsCheck     = data.GuildInfo.LimitIsCheck     

      if GuildHaveAPI ~= nil and GuildHaveAPI.Instance ~= nil then
        --战队-信息
        GuildHaveAPI.Instance:InitializeMyselfGuildDetailInfo(UTGData.Instance().MyselfGuild)
        --战队-成员
        --GuildHaveAPI.Instance:InitializeMyselfGuildMembers(UTGData.Instance().MyselfGuild.Members)
        GuildHaveAPI.Instance:InitializeMyselfGuildInfo(UTGData.Instance().MyselfGuild)
      end
    end

    return true;
  else
    return false;
  end
end
---------------------------------------------------------Notify更新自己的战队成员--
function UTGDataOperator:GuildMemberChangeNotify(e)  --Debugger.LogError("S3")

  if e.Type == "NotifyGuildMemberChange" then
    local data = json.decode(e.Content:ToString())
    
    --数据整理，以适合Action
    if data.Action ==1 or data.Action == 2 then --新增 or 更新
    
      UTGData.Instance().MyselfGuild.Members[tostring(data.GuildMember.Id)] = data.GuildMember 

    elseif data.Action ==3 then --删除
     
      UTGData.Instance().MyselfGuild.Members[tostring(data.GuildMember.Id)] = nil
    end

    if GuildHaveAPI ~= nil and GuildHaveAPI.Instance ~= nil then
      --战队-信息
      GuildHaveAPI.Instance:InitializeMyselfGuildDetailMembers(UTGData.Instance().MyselfGuild)
      --战队-成员
      GuildHaveAPI.Instance:InitializeMyselfGuildMembers(UTGData.Instance().MyselfGuild.Members)
      --GuildHaveAPI.Instance:InitializeMyselfGuildInfo(UTGData.Instance().MyselfGuild)
    end
    
    return true;
  else
    return false;
  end
end
---------------------------------------------------------Notify更新自己筹备中的战队--
function UTGDataOperator:PreparingGuildChangeNotify(e) --Debugger.LogError("S11")
  --应该只是刚加入筹备中的战队用一次，其他情况点击按钮或者Notify更新局部信息或成员
  if e.Type == "NotifyPreparingGuildChange" then
    local data = json.decode(e.Content:ToString())
    if(data.Action==1 or data.Action==2)then
      --数据整理，以适合Action
      UTGData.Instance().MyselfPreparingGuildData=data.PreparingGuild 
      --[[
      for k,v in pairs(data.PreparingGuild) do
        Debugger.LogError("KEY:" .. k);
        Debugger.LogError("VALUE:" .. tostring(v));
      end
      --]]

      local members={}
      for k,v in pairs(UTGData.Instance().MyselfPreparingGuildData.Members) do
        members[tostring(v.Id)]=v;
      end
      UTGData.Instance().MyselfPreparingGuildData.Members=members

      if GuildNoAPI ~= nil and GuildNoAPI.Instance ~= nil then
        GuildNoAPI.Instance:InitializeMyselfPreparingGuildDetailMembers(UTGData.Instance().MyselfPreparingGuildData)  --初始化自己战队成员
        GuildNoAPI.Instance:InitializeMyselfPreparingGuildDetailInfo(UTGData.Instance().MyselfPreparingGuildData) 
      end
    end
    return true;
  else
    return false;
  end
end
---------------------------------------------------------Notify更新自己筹备中的战队Info--
function UTGDataOperator:PreparingGuildInfoChangeNotify(e) --Debugger.LogError("S22")

  if e.Type == "NotifyPreparingGuildInfoChange" then
    local data = json.decode(e.Content:ToString())
    if(data.Action==1 or data.Action==2)then
      --数据整理，以适合Action
      UTGData.Instance().MyselfPreparingGuildData.Id           =data.PreparingGuildInfo.Id
      UTGData.Instance().MyselfPreparingGuildData.IconId       =data.PreparingGuildInfo.IconId
      UTGData.Instance().MyselfPreparingGuildData.Name         =data.PreparingGuildInfo.Name
      UTGData.Instance().MyselfPreparingGuildData.Declaration  =data.PreparingGuildInfo.Declaration
      UTGData.Instance().MyselfPreparingGuildData.Leader       =data.PreparingGuildInfo.Leader
      UTGData.Instance().MyselfPreparingGuildData.EndTime      =data.PreparingGuildInfo.EndTime
      UTGData.Instance().MyselfPreparingGuildData.MemberAmount =data.PreparingGuildInfo.MemberAmount

      if GuildNoAPI ~= nil and GuildNoAPI.Instance ~= nil then
        --GuildNoAPI.Instance:InitializeMyselfPreparingGuildDetailMembers(UTGData.Instance().MyselfPreparingGuildData)  --初始化自己战队成员
        GuildNoAPI.Instance:InitializeMyselfPreparingGuildDetailInfo(UTGData.Instance().MyselfPreparingGuildData) 
      end
    end
    return true;
  else
    return false;
  end
end
---------------------------------------------------------Notify更新自己筹备中的战队成员--
function UTGDataOperator:PreparingGuildMemberChangeNotify(e) --Debugger.LogError("S33")

  if e.Type == "NotifyPreparingGuildMemberChange" then
    local data = json.decode(e.Content:ToString())
 
    --数据整理，以适合Action
    if data.Action ==1 or data.Action == 2 then --新增 or 更新
      UTGData.Instance().MyselfPreparingGuildData.Members[tostring(data.PreparingGuildMember.Id)]=data.PreparingGuildMember
    elseif data.Action ==3 then --删除
      UTGData.Instance().MyselfPreparingGuildData.Members[tostring(data.PreparingGuildMember.Id)] = nil
    end

    if GuildNoAPI ~= nil and GuildNoAPI.Instance ~= nil then
      GuildNoAPI.Instance:InitializeMyselfPreparingGuildDetailMembers(UTGData.Instance().MyselfPreparingGuildData)  --初始化自己战队成员
      --GuildNoAPI.Instance:InitializeMyselfPreparingGuildDetailInfo(UTGData.Instance().MyselfPreparingGuildData) 
    end
    return true;
  else
    return false;
  end
end
--玩家获取变化
function UTGDataOperator:NotifyPlayerGainChange(e)
  if e.Type == "NotifyPlayerGainChange" then
    --Debugger.Log("NotifyPlayerGainChange")
    local playerData = UTGData.Instance().PlayerData
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerGainChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local data = json.decode(e.Content:get_Item("PlayerGain"):ToString())
    if data ==nil then Debugger.LogError("NotifyPlayerGainChange nil") end
    if Action ==1 or Action == 2 then --新增 or 更新
      UTGData.Instance().PlayerGainDeck = data
    elseif Action ==3 then --删除
      UTGData.Instance().PlayerGainDeck = nil
    end
    
    if WantGoldApi ~= nil and WantGoldApi.Instance ~= nil then
      WantGoldApi.Instance:progressUiSet()
    end
    return true
  end
  return false
end

--等级任务
function UTGDataOperator:NotifyPlayerLevelQuestChange(e) 
  if e.Type == "NotifyPlayerLevelQuestChange" then
    --Debugger.Log("等级任务 UTGDataOperator:NotifyPlayerLevelQuestChange2222222222")
    local playerData = UTGData.Instance().PlayerData
    local Data = UTGData.Instance().PlayerLevelQuestDeck
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerGrowUpChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local data = json.decode(e.Content:get_Item("PlayerLevelQuests"):ToString())
    if data ==nil then Debugger.LogError("NotifyPlayerLevelQuestChange nil") end
    if Action ==1 or Action == 2 then --新增 or 更新
      for k,v in pairs(data) do
        Data[tostring(v.LevelQuestId)] = v
      end
    elseif Action ==3 then --删除
      for k,v in pairs(data) do
        Data[tostring(v.LevelQuestId)] = nil
      end
    end
    
    if GrowProcessApi ~= nil and GrowProcessApi.Instance ~= nil then
      GrowProcessApi.Instance:updateMissionUi()
    end
    return true
  end
  return false
end

--等级奖励
function UTGDataOperator:NotifyPlayerGrowUpDeckChange(e)
  if e.Type == "NotifyPlayerGrowUpDeckChange" then
    --Debugger.Log("等级奖励 UTGDataOperator:NotifyPlayerGrowUpDeckChange")
    local playerData = UTGData.Instance().PlayerData
    local Data = UTGData.Instance().PlayerGrowUpProgressDeck
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerGrowUpDeckChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local data = json.decode(e.Content:get_Item("PlayerGrowUpDeck"):ToString())
    if data ==nil then Debugger.LogError("NotifyPlayerGrowUpDeckChange nil") end
    if Action ==1 or Action == 2 then --新增 or 更新
      UTGData.Instance().PlayerGrowUpProgressDeck = data
    elseif Action ==3 then --删除
      Data = nil
    end
    
    if GrowProcessApi ~= nil and GrowProcessApi.Instance ~= nil then
      GrowProcessApi.Instance:updateLevelAwardUi()
    end
    return true
  end
  return false
end


function UTGDataOperator:NotifyPlayerReward(e)
  -- body
  print("NotifyRewards " .. e.Type)
  if e.Type == "NotifyRewards" then
    local rewards = json.decode(e.Content:get_Item("Rewards"):ToString())
    print("rewards " .. #rewards)

    if WantGrowAPI ~= nil and WantGrowAPI.Instance ~= nil then
      WantGrowAPI.Instance:ShowReward(rewards)
    end
    local function callBack()
      if GetRuneAPI ~= nil and GetRuneAPI.Instance ~= nil then
        GetRuneAPI.Instance:ShowReward(rewards)
      end
    end
    self:CreatePanelAsync("GetRune",callBack)
    return true
  end
  return false
end

function UTGDataOperator:NotifyPlayerDetailChange(e)
  if e.Type == "NotifyPlayerDetailChange" then
    --print("NotifyPlayerDetailChange -- change")
    local playerData = UTGData.Instance().PlayerData

    local LastGuildStatus = UTGData.Instance().PlayerData.GuildStatus  

    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerDetailChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local Player = json.decode(e.Content:get_Item("Player"):ToString())
    --Debugger.LogError("Player.Exp ==  "..Player.Exp)
    if Action ==1 then --新增
      UTGData.Instance().PlayerData = Player
    elseif Action ==2 then --更新
      UTGData.Instance().PlayerData = Player
    elseif Action ==3 then --删除
      UTGData.Instance().PlayerData = Player
    end
    
    if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
      UTGMainPanelAPI.Instance:UpdateExpBar()
      UTGMainPanelAPI.Instance:UpdatePlayerName()
    end
    if PlayerDataAPI ~= nil and PlayerDataAPI.Instance ~= nil then
      PlayerDataAPI.Instance:UpdatePlayerName()
      PlayerDataAPI.Instance:UpdatePlayerFrame()
      PlayerDataAPI.Instance:ChangeFrame() 
    end
    if WantGrowAPI ~= nil and WantGrowAPI.Instance ~= nil then
      WantGrowAPI.Instance:UpdateData()
    end

    if(LastGuildStatus ~= UTGData.Instance().PlayerData.GuildStatus)then  
      

        if(UTGData.Instance().PlayerData.GuildStatus==0)then
          if GuildNoAPI ~= nil and GuildNoAPI.Instance ~= nil then
            GuildNoAPI.Instance:OnButtonClick_I1()
          else

            Object.Destroy(GuildHaveAPI.Instance.this.gameObject)
            self:GoToOtherPanel("GuildNo",function ()
            if GuildNoAPI ~= nil and GuildNoAPI.Instance ~= nil then
              GuildNoAPI.Instance:OnButtonClick_I1()
            end
            if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
              WaitingPanelAPI.Instance:DestroySelf()
            end
            end,self)
            GameManager.CreatePanel("Waiting")


          end
        elseif(UTGData.Instance().PlayerData.GuildStatus==1)then  --会发其他Notify，所以这里并不需要处理\
          if GuildHaveAPI ~= nil and GuildHaveAPI.Instance ~= nil then
            GuildHaveAPI.Instance:ShowPanel("II","II1");
          else

            Object.Destroy(GuildNoAPI.Instance.this.gameObject)
            self:GoToOtherPanel("GuildHave",function ()
            GuildHaveAPI.Instance:ShowPanel("II","II1");
            if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
              WaitingPanelAPI.Instance:DestroySelf()
            end
            end,self)
            GameManager.CreatePanel("Waiting")

          end
          


          --[[
          UTGData.Instance():GuildLastWeekRankRequest()
          UTGData.Instance():GuildWeekRankRequest()
          UTGData.Instance():GuildLevelSeasonRankRequest() 
          UTGData.Instance():GuildSeasonRankRequest() 
          --]]
          
        elseif(UTGData.Instance().PlayerData.GuildStatus==2)then

        elseif(UTGData.Instance().PlayerData.GuildStatus==3)then 
          
        end
      
    end
    
    for k,v in pairs(self.ChatList) do
      if v~=nil and v.this~=nil then 
        v:UpdateGuildState(e)
      end
    end

    if ChartAPI~=nil and ChartAPI.Instance~=nil then
      ChartAPI.Instance:UpdateSelfPlayerIcon()
    end

    return true
  end
  return false
end
function UTGDataOperator:NotifyPlayerCurrencyChange(e)
  if e.Type == "NotifyPlayerCurrencyChange" then
    --print("ChangeChangeChangeChangeChange")
    local playerData = UTGData.Instance().PlayerData
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerCurrencyChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local Coin = tonumber(e.Content:get_Item("Coin"):ToString())
    local Gem = tonumber(e.Content:get_Item("Gem"):ToString())
    local Voucher = tonumber(e.Content:get_Item("Voucher"):ToString())
    local RunePiece = tonumber(e.Content:get_Item("RunePiece"):ToString())
    local GuildCoin = tonumber(e.Content:get_Item("GuildCoin"):ToString())
    if Action ==1 then --新增
      playerData.Coin = playerData.Coin+Coin
      playerData.Gem = playerData.Gem+Gem
      playerData.Voucher = playerData.Voucher+Voucher
      playerData.RunePiece = playerData.RunePiece+RunePiece
      playerData.GuildCoin = playerData.GuildCoin + GuildCoin
    elseif Action ==2 then --更新
      playerData.Coin = Coin
      playerData.Gem = Gem
      playerData.Voucher = Voucher
      playerData.RunePiece = RunePiece
      playerData.GuildCoin = GuildCoin
    elseif Action ==3 then --删除
      playerData.Coin = playerData.Coin-Coin
      playerData.Gem = playerData.Gem-Gem
      playerData.Voucher = playerData.Voucher-Voucher
      playerData.RunePiece = playerData.RunePiece-RunePiece
      playerData.GuildCoin = playerData.GuildCoin - GuildCoin
    end


    self:UpdateResourceData()
    if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
      UTGMainPanelAPI.Instance:UpdateResource()
      UTGMainPanelAPI.Instance:UpdatePlayerName()
    end


    return true
  end
  return false
end

function UTGDataOperator:NotifyPlayerRoleChange(e)
  if e.Type == "NotifyPlayerRoleChange" then
    local playerData = UTGData.Instance().PlayerData
    local rolesDeckData = UTGData.Instance().RolesDeck
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerRoleChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local RoleDeck = json.decode(e.Content:get_Item("RoleDeck"):ToString())
    if RoleDeck ==nil then Debugger.LogError("NotifyPlayerRoleChange RoleDeck错误 ") end
    local deckid = RoleDeck.Id
    if Action ==1 then --新增
      self.TryHero = {}
      UTGData.Instance().RolesDeck[tostring(deckid)] = RoleDeck
      UTGData.Instance().RolesDeckData[tostring(RoleDeck.RoleId)] = RoleDeck
      if RoleDeck.IsOwn == false then
          table.insert(self.TryHero,RoleDeck.RoleId)
          table.insert(self.TryHero,RoleDeck.ExperienceCountDown)
          self.TryHeroList[tostring(RoleDeck.RoleId)] = self.TryHero
      end
    elseif Action ==2 then --更新
      --Debugger.LogError("pre = "..UTGData.Instance().RolesDeck[tostring(deckid)].ProficiencyValue.." nex = "..RoleDeck.ProficiencyValue)
      UTGData.Instance().RolesDeck[tostring(deckid)] = RoleDeck
      UTGData.Instance().RolesDeckData[tostring(RoleDeck.RoleId)] = RoleDeck
      if RoleDeck.IsOwn == false then
          table.insert(self.TryHero,RoleDeck.RoleId)
          table.insert(self.TryHero,RoleDeck.ExperienceCountDown)
          self.TryHeroList[tostring(RoleDeck.RoleId)] = self.TryHero
      end
    elseif Action ==3 then --删除
      UTGData.Instance().RolesDeck[tostring(deckid)] = nil
      UTGData.Instance().RolesDeckData[tostring(RoleDeck.RoleId)] = nil
      if RoleDeck.IsOwn == false then
        self.TryHeroList[RoleDeck.RoleId] = nil
      end
    end

    if UTGDataTemporary.Instance().shopPageID == 1 then
      if StoreRecommendCtrl ~= nil and StoreRecommendCtrl.Instance ~= nil then
        StoreRecommendCtrl.Instance:ApiUpdateNew()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 2 then
      if StoreNewCtrl ~= nil and StoreNewCtrl.Instance ~= nil then
        StoreNewCtrl.Instance:ApiUpdateAll()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 3 then
      if StoreHeroCtrl ~= nil and StoreHeroCtrl.Instance ~= nil then
        StoreHeroCtrl.Instance:ApiUpdateHeroList()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 4 then
      if StoreSkinCtrl ~= nil and StoreSkinCtrl.Instance ~= nil then
        StoreSkinCtrl.Instance:ApiUpdateHeroList()
      end
    end

    if HeroInfoAPI ~= nil and HeroInfoAPI.Instance ~= nil then
      HeroInfoAPI.Instance:Init(HeroInfoAPI.Instance.heroInfoController.self.HeroId,HeroInfoAPI.Instance.heroInfoController.self.HeroList)
      HeroInfoAPI.Instance:InitCenterBySkinId(HeroInfoAPI.Instance.heroInfoController.self.selectedSkinId,HeroInfoAPI.Instance.heroInfoController.self.SkinList)
    end


    return true
  end
  return false
end

function UTGDataOperator:NotifyPlayerSkinChange(e)
  if e.Type == "NotifyPlayerSkinChange" then
    local playerData = UTGData.Instance().PlayerData
    local skinsDeck = UTGData.Instance().SkinsDeck
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerSkinChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local SkinDeck = json.decode(e.Content:get_Item("SkinDeck"):ToString())
    if SkinDeck ==nil then Debugger.LogError("NotifyPlayerSkinChange SkinDeck ") end
    local deckid = SkinDeck.Id
    if Action ==1 then --新增
      self.TrySkin = {}
      skinsDeck[tostring(deckid)] = SkinDeck
      UTGData.Instance().SkinsDeckData[tostring(SkinDeck.SkinId)] = SkinDeck
      if SkinDeck.IsOwn == false then
        table.insert(self.TrySkin,SkinDeck.SkinId)
        table.insert(self.TrySkin,SkinDeck.ExperienceCountDown)
        self.TrySkinList[tostring(SkinDeck.SkinId)] = self.TrySkin
      end
    elseif Action ==2 then --更新
      skinsDeck[tostring(deckid)] = SkinDeck
      UTGData.Instance().SkinsDeckData[tostring(SkinDeck.SkinId)] = SkinDeck
      if SkinDeck.IsOwn == false then
        table.insert(self.TrySkin,SkinDeck.SkinId)
        table.insert(self.TrySkin,SkinDeck.ExperienceCountDown)
        self.TrySkinList[tostring(SkinDeck.SkinId)] = self.TrySkin
      end
    elseif Action ==3 then --删除
      skinsDeck[tostring(deckid)] = nil
      UTGData.Instance().SkinsDeckData[tostring(SkinDeck.SkinId)] = nil
    end

    if UTGDataTemporary.Instance().shopPageID == 1 then
      if StoreRecommendCtrl ~= nil and StoreRecommendCtrl.Instance ~= nil then
        StoreRecommendCtrl.Instance:ApiUpdateNew()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 2 then
      if StoreNewCtrl ~= nil and StoreNewCtrl.Instance ~= nil then
        StoreNewCtrl.Instance:ApiUpdateAll()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 3 then
      if StoreHeroCtrl ~= nil and StoreHeroCtrl.Instance ~= nil then
        StoreHeroCtrl.Instance:ApiUpdateHeroList()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 4 then
      if StoreSkinCtrl ~= nil and StoreSkinCtrl.Instance ~= nil then
        StoreSkinCtrl.Instance:ApiUpdateHeroList()
      end
    end

    if HeroInfoAPI ~= nil and HeroInfoAPI.Instance ~= nil then
      HeroInfoAPI.Instance:Init(HeroInfoAPI.Instance.heroInfoController.self.HeroId,HeroInfoAPI.Instance.heroInfoController.self.HeroList)
      HeroInfoAPI.Instance:InitCenterBySkinId(HeroInfoAPI.Instance.heroInfoController.self.selectedSkinId,HeroInfoAPI.Instance.heroInfoController.self.SkinList)
    end


    return true
  end
  return false
end

function UTGDataOperator:NotifyPlayerRuneChange(e)
  if e.Type == "NotifyPlayerRuneChange" then
    local playerData = UTGData.Instance().PlayerData
    local runesDeckData = UTGData.Instance().RunesDeck
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerRuneChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local RuneDeck = json.decode(e.Content:get_Item("RuneDecks"):ToString())
    if RuneDeck ==nil then Debugger.LogError("NotifyPlayerRuneChange RuneDeck ") end
    local deckid = {}
    for k,v in pairs(RuneDeck) do
      deckid = v.RuneId
      if Action ==1 then --新增
        runesDeckData[tostring(deckid)] = v
      elseif Action ==2 then --更新
        runesDeckData[tostring(deckid)] = v
      elseif Action ==3 then --删除
        runesDeckData[tostring(deckid)] = nil
      end
    end
    --[[
    for k,v in pairs(Data.RunesDeck) do
      print(k .. " aaa " .. v.Amount)
    end  
    ]]
    --更新界面数据
    self:UpdatePanelData()
    return true
  end
  return false
end

function UTGDataOperator:NotifyPlayerRunePageChange(e)
  if e.Type == "NotifyPlayerRunePageChange" then
    local playerData = UTGData.Instance().PlayerData
    local runePagesDeckData = UTGData.Instance().RunePagesDeck
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerRunePageChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local RunePageDeck = json.decode(e.Content:get_Item("RunePageDecks"):ToString())
    if runePagesDeckData ==nil then Debugger.LogError("NotifyPlayerRunePageChange RunePageDeck ") end
    local deckid = {}
    for k,v in pairs(RunePageDeck) do
      deckid = v.Id
      if Action ==1 then --新增
        runePagesDeckData[tostring(deckid)] = v
      elseif Action ==2 then --更新
        runePagesDeckData[tostring(deckid)] = v
      elseif Action ==3 then --删除
        runePagesDeckData[tostring(deckid)] = nil
      end
    end
    --更新界面数据
    self:UpdatePanelData()
    
    return true
  end
  return false
end

function UTGDataOperator:NotifyPlayerRuneSlotChange(e)
  if e.Type == "NotifyPlayerRuneSlotChange" then
    local playerData = UTGData.Instance().PlayerData
    local runeSlotsDeckData = UTGData.Instance().RuneSlotsDeck
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerRuneSlotChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local RuneSlotDeck = json.decode(e.Content:get_Item("RuneSlotDecks"):ToString())
    if runeSlotsDeckData ==nil then Debugger.LogError("NotifyPlayerRuneSlotChange RuneSlotDeck ") end
    local deckid = {}
    for k,v in pairs(RuneSlotDeck) do
      deckid = v.Id
      if Action ==1 then --新增
        runeSlotsDeckData[tostring(deckid)] = v
        self.runeNotice = true
        if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
          UTGMainPanelAPI.Instance:UpdateNotice()
        end
      elseif Action ==2 then --更新
        runeSlotsDeckData[tostring(deckid)] = v
      elseif Action ==3 then --删除
        runeSlotsDeckData[tostring(deckid)] = nil
      end
    end
    --更新界面数据
    self:UpdatePanelData()
    
    return true
  end
  return false
end

function UTGDataOperator:NotifyPlayerItemChange(e)
  if e.Type == "NotifyPlayerItemChange" then
    local playerData = UTGData.Instance().PlayerData
    local itemDeckData = UTGData.Instance().ItemsDeck
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerRuneSlotChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local itemDeck = json.decode(e.Content:get_Item("ItemDeck"):ToString())
    if itemDeckData ==nil then Debugger.LogError("NotifyPlayerItemChange ItemDeck ") end
    local deckid = itemDeck.ItemId
    if Action ==1 then --新增
      itemDeckData[tostring(deckid)] = itemDeck
    elseif Action ==2 then --更新
      itemDeckData[tostring(deckid)] = itemDeck
    elseif Action ==3 then --删除
      itemDeckData[tostring(deckid)] = nil
    end 

    --print("ItemDeck更新")
    --更新界面数据
    self.itemDataUpdate = true
    if PackageAPI ~= nil and PackageAPI.Instance ~= nil then
      PackageAPI.Instance:TypeControl()
    end

    if UTGDataTemporary.Instance().shopPageID == 2 then
      if StoreNewCtrl ~= nil and StoreNewCtrl.Instance ~= nil then
        StoreNewCtrl.Instance:ApiUpdatePartNum()
      end
    end

    if UTGDataTemporary.Instance().shopPageID == 1 then
      if StoreRecommendCtrl ~= nil and StoreRecommendCtrl.Instance ~= nil then
        StoreRecommendCtrl.Instance:ApiUpdateNew()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 2 then
      if StoreNewCtrl ~= nil and StoreNewCtrl.Instance ~= nil then
        StoreNewCtrl.Instance:ApiUpdateAll()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 3 then
      if StoreHeroCtrl ~= nil and StoreHeroCtrl.Instance ~= nil then
        StoreHeroCtrl.Instance:ApiUpdateHeroList()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 4 then
      if StoreSkinCtrl ~= nil and StoreSkinCtrl.Instance ~= nil then
        StoreSkinCtrl.Instance:ApiUpdateHeroList()
      end
    end
    
    if StartBountyMatchAPI~=nil and StartBountyMatchAPI.Instance~=nil then
      StartBountyMatchAPI.Instance:UpdateData()
    end

    if CoinMatchAPI~=nil and CoinMatchAPI.Instance~=nil then
      CoinMatchAPI.Instance:UpdateData()
    end

    if (self:isBelongTabExItem(deckid) == true) then
     local awardRed = self:isActiQuestExistCanGetAward()
     if (awardRed == true or self.actiNoReadCnt > 0) then
      self.actiRed = true
     elseif (awardRed == false and self.actiNoReadCnt == 0) then
      self.actiRed = false
     end

      if (self.actiRed == true) then
        Debugger.Log("UTGDataOperator:NotifyPlayerItemChange(e) true ")
      elseif (self.actiRed == false) then
        Debugger.Log("UTGDataOperator:NotifyPlayerItemChange(e) false ")
      end
      if (UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil) then
        UTGMainPanelAPI.Instance:UpdateNotice()
      end
    end
    return true
  end
  return false
end


function UTGDataOperator:NotifyPlayerFriendChange(e)
  -- body
  if e.Type == "NotifyPlayerFriendChange" then
    local playerData = UTGData.Instance().PlayerData
    local friendData = UTGData.Instance().FriendList
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerRuneSlotChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local friendList = json.decode(e.Content:get_Item("Friend"):ToString())
    if friendList ==nil then Debugger.LogError("NotifyPlayerItemChange ItemDeck ") end
    local friend = friendList.PlayerId
    if Action ==1 then --新增
      friendData[tostring(friend)] = friendList
    elseif Action ==2 then --更新
      friendData[tostring(friend)] = friendList
    elseif Action ==3 then --删除
      friendData[tostring(friend)] = nil
    end


    --更新界面数据
    self.friendListUpdate = true

    if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
      NewBattle15API.Instance:UpdateFriendList()
    end
    
    if ChartAPI ~= nil and ChartAPI.Instance ~= nil then
      ChartAPI.Instance:UpdateData()
    end
    
    if(FriendAPI~=nil and FriendAPI.Instance~=nil )then 
      FriendAPI.Instance:FriendListRequest()
    end

    return true
  end
  return false
end


function UTGDataOperator:playerFriendCandidateChangeNotify(e)
  -- body
  
  if e.Type == "NotifyPlayerFriendCandidateChange" then
   
    local Action = tonumber(e.Content:get_Item("Action"):ToString())

    local friendCandidate  = json.decode(e.Content:get_Item("FriendCandidate"):ToString())
    
   

    if Action ==1 then --新增 
     
      UTGData.Instance().FriendCandidateList[tostring(friendCandidate.PlayerId)] = friendCandidate
    elseif Action ==2 then --更新
   
      UTGData.Instance().FriendCandidateList[tostring(friendCandidate.PlayerId)] = friendCandidate
    elseif Action ==3 then --删除
  
      UTGData.Instance().FriendCandidateList[tostring(friendCandidate.PlayerId)] = nil
    end

    --好友红点
    local Size=0
    for k,v in pairs(UTGData.Instance().FriendCandidateList) do
      Size=Size+1
    end
   
    if(Size~=0)then  
      UTGDataOperator.Instance.friendNotice =true 
    else 
      UTGDataOperator.Instance.friendNotice =false
    end 
    if(UTGMainPanelAPI~=nil and UTGMainPanelAPI.Instance~=nil )then 
      UTGMainPanelAPI.Instance:UpdateNotice()
    end
    
    if(FriendAPI~=nil and FriendAPI.Instance~=nil )then 
      FriendAPI.Instance:FriendListRequest()
    end
    

    return true
  end
  return false
end
function UTGDataOperator:NotifyPlayerForbidChange(e)
  -- body
  if e.Type == "NotifyPlayerForbidChange" then
    local playerData = UTGData.Instance().PlayerData
    local forbidData = UTGData.Instance().ForbidList
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerForbidChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local forbid = json.decode(e.Content:get_Item("Forbid"):ToString())
    if forbid ==nil then Debugger.LogError("NotifyPlayerForbidChange nil") end
    local id = forbid.PlayerId
    if Action ==1 then --新增
      forbidData[tostring(id)] = forbid
    elseif Action ==2 then --更新
      forbidData[tostring(id)] = forbid
    elseif Action ==3 then --删除
      forbidData[tostring(id)] = nil
    end


    --更新界面数据
    self.friendListUpdate = true

    if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
      NewBattle15API.Instance:UpdateFriendList()
    end
    
    if(FriendAPI~=nil and FriendAPI.Instance~=nil )then 
      FriendAPI.Instance:FriendListRequest()
    end

    return true
  end
  return false
end
--更新 GrowUp
function UTGDataOperator:NotifyPlayerGrowUpChange(e)
  -- body
  if e.Type == "NotifyPlayerGrowUpChange" then
    local playerData = UTGData.Instance().PlayerData
    local Data = UTGData.Instance().PlayerGrowUpDeck
    local PlayerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(PlayerId) then Debugger.LogError("NotifyPlayerGrowUpChange PlayerId错误 "..PlayerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local data = json.decode(e.Content:get_Item("PlayerGrowUps"):ToString())
    if data ==nil then Debugger.LogError("NotifyPlayerGrowUpChange nil") end
    if Action ==1 or Action == 2 then --新增 or 更新
      for k,v in pairs(data) do
        Data[tostring(v.Id)] = v
      end
    elseif Action ==3 then --删除
      for k,v in pairs(data) do
        Data[tostring(v.Id)] = nil
      end
    end
    
    if WantGrowAPI ~= nil and WantGrowAPI.Instance ~= nil then
      WantGrowAPI.Instance:UpdateData()
    end

    if GrowGuideAPI ~= nil and GrowGuideAPI.Instance ~= nil then
      GrowGuideAPI.Instance:updateWantGrowRed()
    end
    return true
  end
  return false
end

function UTGDataOperator:NotifyNewPlayerSkill(e)
  if e.Type == "NotifyNewPlayerSkill" then
    local playerSkillId = tonumber(e.Content:get_Item("PlayerSkillId"):ToString())
    UTGData.Instance().PlayerSkillDeckIds[tostring(playerSkillId)] = playerSkillId
    self:WriteFile("PlayerSkillNotice.ini",{RedPoint = true})
    self.skillNotice = true
    return true
  end
  return false
end

--更新playerShop的Deck内容
function UTGDataOperator:NotifyPlayerShopChange(e)
  -- body
  if e.Type == "NotifyPlayerShopChange" then
    local playerData = UTGData.Instance().PlayerData
    local playerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(playerId) then Debugger.LogError("NotifyPlayerForbidChange PlayerId错误 "..playerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    print("111 " .. Data.PlayerShopsDeck.VoucherTreasureLuckyPoint)
    local playerShop = json.decode(e.Content:get_Item("PlayerShop"):ToString())
    print("222 " .. playerShop.VoucherTreasureLuckyPoint)
    if playerShop ==nil then Debugger.LogError("NotifyPlayerForbidChange nil") end
    local id = playerShop.PlayerId
    if Action ==1 then --新增
      table.insert(Data.PlayerShopsDeck,playerShop)
    elseif Action ==2 then --更新
      Data.PlayerShopsDeck = playerShop
      print("333 " .. Data.PlayerShopsDeck.VoucherTreasureLuckyPoint)
    elseif Action ==3 then --删除
      for i = #Data.PlayerShopsDeck,1,-1 do
        if Data.PlayerShopsDeck[i].Id == playerShop.Id then
          table.remove(Data.PlayerShopsDeck,i)
        end
      end
    end

    if StoreRunePanelAPI ~= nil and StoreRunePanelAPI.Instance ~= nil then
      StoreRunePanelAPI.Instance:UpdateUI()
    end

    if StoreLotteryPanelAPI ~= nil and StoreLotteryPanelAPI.Instance ~= nil then
      StoreLotteryPanelAPI.Instance:UpdateUI()
    end

    if StorePreferentialPanelAPI ~= nil and StorePreferentialPanelAPI.Instance ~= nil then
      StorePreferentialPanelAPI.Instance:UpdateUI()
    end

    if UTGDataTemporary.Instance().shopPageID == 1 then
      if StoreRecommendCtrl ~= nil and StoreRecommendCtrl.Instance ~= nil then
        StoreRecommendCtrl.Instance:ApiUpdateNew()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 2 then
      if StoreNewCtrl ~= nil and StoreNewCtrl.Instance ~= nil then
        StoreNewCtrl.Instance:ApiUpdateAll()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 3 then
      if StoreHeroCtrl ~= nil and StoreHeroCtrl.Instance ~= nil then
        StoreHeroCtrl.Instance:ApiUpdateHeroList()
      end
    elseif UTGDataTemporary.Instance().shopPageID == 4 then
      if StoreSkinCtrl ~= nil and StoreSkinCtrl.Instance ~= nil then
        StoreSkinCtrl.Instance:ApiUpdateHeroList()
      end
    end


    return true    
  end
  return false
end

function UTGDataOperator:NotifyPlayerMailChange(e)
  -- body
  if e.Type == "NotifyPlayerMailChange" then
    local playerData = UTGData.Instance().PlayerData
    local playerId = e.Content:get_Item("PlayerId"):ToString()
    if playerData.Id ~=tonumber(playerId) then Debugger.LogError("NotifyPlayerForbidChange PlayerId错误 "..playerId) end
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local playerMail = json.decode(e.Content:get_Item("Mails"):ToString())
    for k,v in pairs(playerMail[1]) do
      print("playerMail " .. k)
    end
    local Category = tonumber(json.decode(e.Content:get_Item("Category"):ToString()))
    if playerMail ==nil then Debugger.LogError("NotifyPlayerMailChange nil") end
    local id = playerMail.PlayerId
    print("Action " .. Action)
    if Action ==1 then --新增
      if Category == 1 then
        for i = 1,#playerMail do
          table.insert(UTGDataTemporary.Instance().FriendEmail,playerMail[i])
        end
      else
        for i = 1,#playerMail do
          table.insert(UTGDataTemporary.Instance().SystemEmail,playerMail[i])
        end
      end

      self.emailNotice = true
      if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
        UTGMainPanelAPI.Instance:UpdateNotice()
      end
    elseif Action ==2 then --更新
      print("Category " .. Category)
      if Category == 1 then
        for k = 1,#playerMail do
          for i = 1,#UTGDataTemporary.Instance().FriendEmail do
            if UTGDataTemporary.Instance().FriendEmail[i].Id == playerMail[k].Id then
              UTGDataTemporary.Instance().FriendEmail[i] = playerMail[k]
            end
          end
        end
      else
        for k = 1,#playerMail do
          for i = 1,#UTGDataTemporary.Instance().SystemEmail do
            print("asdfasdf " .. UTGDataTemporary.Instance().SystemEmail[i].Id .. " " .. playerMail[k].Id)
            if UTGDataTemporary.Instance().SystemEmail[i].Id == playerMail[k].Id then
              UTGDataTemporary.Instance().SystemEmail[i] = playerMail[k]
            end
          end
        end
      end      
    elseif Action ==3 then --删除
      print("Category " .. Category)
      if Category == 1 then
        for k = #playerMail,1,-1 do
          for i = #UTGDataTemporary.Instance().FriendEmail,1,-1 do
            if UTGDataTemporary.Instance().FriendEmail[i].Id == playerMail[k].Id then
              table.remove(UTGDataTemporary.Instance().FriendEmail,i)
            end
          end
        end
      else
        for k = #playerMail,1,-1 do
          for i = #UTGDataTemporary.Instance().SystemEmail,1,-1 do
            if UTGDataTemporary.Instance().SystemEmail[i].Id == playerMail[k].Id then
              table.remove(UTGDataTemporary.Instance().SystemEmail,i)
            end
          end
        end
      end
    end

    if EmailAPI ~= nil and EmailAPI.Instance ~= nil then
      EmailAPI.Instance:GetOrderedList()
      print("ssssssssssssss " .. EmailAPI.Instance.controller.self.currentPage)
      if EmailAPI.Instance.controller.self.currentPage == 1 then
        EmailAPI.Instance:InitFriendList()
      else
        EmailAPI.Instance:InitSystemList()
        print("Tttttttttttttttttttttt")
      end
      EmailAPI.Instance:UnReadMail()
    end

    return true    
  end
  return false
end

function UTGDataOperator:NotifyPlayerAvatarFrameChange(e)
  -- body
  if e.Type == "NotifyPlayerAvatarFrameChange" then
    local playerId = tonumber(json.decode(e.Content:get_Item("PlayerId"):ToString()))
    local Action = tonumber(e.Content:get_Item("Action"):ToString())
    local AvatarFrame =  json.decode(e.Content:get_Item("AvatarFrame"):ToString())
    if Action == 1 then
      Data.PlayerAvatarFramesDeck[tostring(AvatarFrame.AvatarFrameId)] = AvatarFrame
    elseif Action == 2 then
      Data.PlayerAvatarFramesDeck[tostring(AvatarFrame.AvatarFrameId)] = AvatarFrame
    else
      Data.PlayerAvatarFramesDeck[tostring(AvatarFrame.AvatarFrameId)] = nil
    end
    return true
  end
  return false
end

function UTGDataOperator:NotifyPlayerNew(e)
  -- body
  if e.Type == "NotifyPlayerNew" then
    local playerId = tonumber(json.decode(e.Content:get_Item("PlayerId"):ToString()))
    local News = json.decode(e.Content:get_Item("News"):ToString())
    self.newModelTag = "new"
    self:DoGoToNewModelPanel(News)
    if StoreNewCtrl ~= nil and StoreNewCtrl.Instance ~= nil then
      StoreNewCtrl.Instance:ApiModelActive(false)
    end
    return true
  end
  return false
end

function UTGDataOperator:NotifyPlayerNewExperience(e)
  -- body
   if e.Type == "NotifyPlayerNewExperience" then
    local playerId = tonumber(json.decode(e.Content:get_Item("PlayerId"):ToString()))
    local NewExperience = json.decode(e.Content:get_Item("NewExperiences"):ToString())
    self.newModelTag = "experience"
    --print("self.newModelTag " .. self.newModelTag)
    if PVPHeroSelectAPI~=nil and PVPHeroSelectAPI.Instance~=nil then 
    else
      self:DoGoToNewModelPanel(NewExperience)
    end
    if StoreNewCtrl ~= nil and StoreNewCtrl.Instance ~= nil then
      StoreNewCtrl.Instance:ApiModelActive(false)
    end
    return true
  end
  return false 
end

function UTGDataOperator:NotifyTips(e)
  -- body
  if e.Type == "NotifyTips" then
    local tip = tostring(e.Content:get_Item("Tips"):ToString())
    print("aaaaaaaa " .. tip .. " " .. type(tip))
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice(tip)
    end

    return true
  end
  return false
end


--资源更新后 调用API 刷新界面数据
function UTGDataOperator:UpdateResourceData()
  for k,v in pairs(self.NormalResourceList) do
    if v ~=nil and v.this ~=nil then 
      v:UpdateResource()
    end
  end
end

function UTGDataOperator:SetResourceList(_self_nr)
  -- body
  for i=#self.NormalResourceList,1 do
    if self.NormalResourceList[i] ==nil or self.NormalResourceList[i].this ==nil then 
      table.remove(self.NormalResourceList,i)
    end
  end
  table.insert(self.NormalResourceList,_self_nr)
end

--芯片界面
function UTGDataOperator:UpdatePanelData()
  --Debugger.LogError("UpdatePanelData")
  if RuneAPI ~=nil and RuneAPI.Instance~=nil then
    RuneAPI.Instance:UpdateInfo()
  end
  if BreakRuneAPI ~=nil and BreakRuneAPI.Instance~=nil then
    BreakRuneAPI.Instance:UpdateData()
  end
end

--********* 资源更新Notify end **************

--***************获取连线结点
function UTGDataOperator:FindNode(itself)
  self.NodeRight = {}
  
  for k,v in pairs(Data.PVPMallsData) do
    for i = 1,#Data.PVPMallsData[k].PreEquips do
      if itself.EquipId == Data.PVPMallsData[k].PreEquips[i] then
        table.insert(self.NodeRight,Data.PVPMallsData[k].EquipId)
      end
    end
  end

  return self.NodeRight
end

function UTGDataOperator:ItemDemands(intItemDemand)
  local Demands = {}
  Demands.DemandsIdForCompose = {}
  Demands.DemandsCategoryForCompose = {}
  Demands.DemandsAmountForCompose = {}
  for i = 1,#intItemDemand do
      if intItemDemand[i] ~= nil and intItemDemand[i][1] == 0 then
        if #intItemDemand[i] == 3 then
          Demands.DemandsId = intItemDemand[i][1]
          Demands.DemandsCategory = intItemDemand[i][2]
          Demands.DemandsAmount = intItemDemand[i][3]
        elseif #intItemDemand[i] == 2 then
          Demands.DemandsId = intItemDemand[i][1]
          Demands.DemandsCategory = intItemDemand[i][2]
          Demands.DemandsAmount = 0
        elseif #intItemDemand[i] == 1 then
          Demands.DemandsId = 0
          Demands.DemandsCategory = intItemDemand[i][1]
          Demands.DemandsAmount = 0    
        end
      end
      
      if intItemDemand[i] ~= nil and intItemDemand[i][1] ~= 0 then
        if #intItemDemand[i] == 3 then
          table.insert(Demands.DemandsIdForCompose,intItemDemand[i][1])
          table.insert(Demands.DemandsCategoryForCompose,intItemDemand[i][2])
          table.insert(Demands.DemandsAmountForCompose,intItemDemand[i][3])
        end  
      end

  end
  
  return Demands
end

function  UTGDataOperator:CreateDialog(name)
  -- body
  local dialogSelf = GameManager.CreateDialog(name)
  table.insert(self.Dialog,dialogSelf)
  return dialogSelf:GetComponent("NTGLuaScript").self
end

function UTGDataOperator:GetStrLength(str)
  -- body
  local len = #str
  local left = len
  local cnt = 0
  local arr = {0,0xc0,0xe0,0xf0,0xf8,0xfc}
  while left ~= 0 do
    local tmp = string.byte(str,-left)
    local i = # arr
    while arr[i] do
      if tmp >= arr[i] then
        left = left - i
        break
      end
      i = i-1
    end
    cnt = cnt + 1
  end
  return cnt
end

function UTGDataOperator:CountPlayTime()
  -- body
  coroutine.start(UTGDataOperator.PlayTimeCountDown,self)
end

function UTGDataOperator:PlayTimeCountDown()
  -- body
  self.playTime = 0
  while (true) do
    self.playTime = self.playTime + 1
    coroutine.wait(1)
  end
end

function UTGDataOperator:UseItem(itemId,amount,networkDelegateDelegate,networkDelegateSelf)
  -- body
  self.itemType = Data.ItemsData[tostring(itemId)].Type
  self.itemId = itemId

    self.useItemDelegate = networkDelegate
    self.useItemDelegateSelf = networkDelegateSelf
    local UseItemRequest = NetRequest.New()

    UseItemRequest.Content = JObject.New(JProperty.New("Type", "RequestUseItem"),
                        JProperty.New("ItemId",itemId),
                        JProperty.New("Amount",amount))
    UseItemRequest.Handler = TGNetService.NetEventHanlderSelf(UTGDataOperator.UseItemHandler,self)
    TGNetService.GetInstance():SendRequest(UseItemRequest)
  end
function UTGDataOperator:UseItemHandler(e)
  -- body
  if e.Type == "RequestUseItem" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      if self.itemType == 5 then    --次数倍卡
        if Data.ItemsData[tostring(self.itemId)].Param[1][1] == 1 then   --经验 
          UTGDataOperator.Instance.TimesLimitDoubleMoney_Time = UTGDataOperator.Instance.TimesLimitDoubleMoney_Time + Data.ItemsData[tostring(self.itemId)].Param[1][2]
          UTGDataOperator.Instance.TimesLimitDoubleMoney_Rate = Data.ItemsData[tostring(self.itemId)].Param[1][3]
        elseif Data.ItemsData[tostring(self.itemId)].Param[1][1] == 2 then    --金币
          UTGDataOperator.Instance.TimesLimitDoubleEXP_Time = UTGDataOperator.Instance.TimesLimitDoubleEXP_Time + Data.ItemsData[tostring(self.itemId)].Param[1][2]
          UTGDataOperator.Instance.TimesLimitDoubleEXP_Rate = Data.ItemsData[tostring(self.itemId)].Param[1][3]     
        end
        if PackageAPI ~= nil and PackageAPI.Instance ~= nil then
          PackageAPI.Instance:CloseSubPanel()
        end
      elseif self.itemType == 6 then        --限时倍卡
        if Data.ItemsData[tostring(self.itemId)].Param[1][1] == 2 then     --金币
          UTGDataOperator.Instance.HoursLimitDoubleMoney_Hour = Data.ItemsData[tostring(self.itemId)].Param[1][2]
          UTGDataOperator.Instance.HoursLimitDoubleMoney_Rate = Data.ItemsData[tostring(self.itemId)].Param[1][3]
        elseif Data.ItemsData[tostring(self.itemId)].Param[1][1] == 1 then     --经验
          UTGDataOperator.Instance.HoursLimitDoubleEXP_Hour = Data.ItemsData[tostring(self.itemId)].Param[1][2]
          UTGDataOperator.Instance.HoursLimitDoubleEXP_Rate = Data.ItemsData[tostring(self.itemId)].Param[1][3]     
        end
        if PackageAPI ~= nil and PackageAPI.Instance ~= nil then
          PackageAPI.Instance:CloseSubPanel()
        end
      elseif self.itemType == 7 then    --皮肤体验卡
        local isFirstSkin = true
        for k,v in pairs(Data.SkinsDeck) do
          if Data.ItemsData[tostring(self.itemId)].Param[1][1] == v.SkinId then
            isFirstSkin = false
          end
        end
        if isFirstSkin == true then
          GameManager.CreatePanel("SelfHideNotice")
          if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("开启体验皮肤" .. Data.ItemsData[tostring(self.itemId)].Name .. ",体验时间为" .. 
                                                                            Data.ItemsData[tostring(self.itemId)].Param[1][2] .. "小时")
          end
          --print("打开获得新皮肤界面")
          if PackageAPI ~= nil and PackageAPI.Instance ~= nil then
            PackageAPI.Instance:TypeControl()
          end
        end
      elseif self.itemType == 8 then     --英雄体验卡
        local isFirstRole = true
        for k,v in pairs(Data.SkinsDeck) do
          if Data.ItemsData[tostring(self.itemId)].Param[1][1] == v.RoleId then
            isFirstRole = false
          end
        end
        if isFirstRole == true then
          GameManager.CreatePanel("SelfHideNotice")
          if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("开启体验英雄" .. Data.ItemsData[tostring(self.itemId)].Name .. ",体验时间为" .. 
                                                                            Data.ItemsData[tostring(self.itemId)].Param[1][2] .. "小时")
          end
          --print("打开获得新英雄界面")
          if PackageAPI ~= nil and PackageAPI.Instance ~= nil then
            PackageAPI.Instance:TypeControl()
          end
        end
      elseif self.itemType == 9 then    --大喇叭
      elseif self.itemType == 10 then    --小喇叭
      elseif self.itemType == 11 then     --宝箱
      end

      if self.useItemDelegate ~= nil and self.useItemDelegateSelf ~= nil then
        self.useItemDelegate(self.useItemDelegateSelf)
      end



    end
    return true
  end
  return false
end

function UTGDataOperator:GoToOtherPanel(name,fun,funself)
    if fun ~= nil then
      coroutine.start(UTGDataOperator.GoToOtherPanelCoroutine,self,name,fun,funself)
    else 
      coroutine.start(UTGDataOperator.GoToOtherPanelCoroutine,self,name)
    end   
end

function UTGDataOperator:GoToOtherPanelCoroutine(name,fun,funself)
  local async = GameManager.CreatePanelAsync(name)
  while async.Done == false do
    coroutine.wait(0.05)
  end
  
  if async.Done == true and fun ~= nil then
    fun(funself)
  end
end

function UTGDataOperator:NotifyPlayerOffline(e)
  -- body
  if e.Type == "NotifyPlayerOffline" then

    local desc = tostring(e.Content:get_Item("Desc"):ToString())
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice(desc)
    end

    --TGNetService.GetInstance():Stop()

    return true
  else
    return false
  end
end

function UTGDataOperator:NotifyPlayerGradeChange(e)
  -- body
  if e.Type == "NotifyPlayerGradeChange" then
    local playerGrade = json.decode(e.Content:get_Item("Grade"):ToString())
    self.PrePlayerGrade = Data.PlayerGradeDeck
    Data.PlayerGradeDeck = playerGrade
    return true
  else
    return false
  end
end
--self.exchangeShopType 1:ShopBuy() 2:芯片抽奖 3:夺宝
function UTGDataOperator:ShopBuy(shopId,payType,amount,networkDelegate,networkDelegateSelf)

  if payType == 2 and self.canBuy == false then
    local needprice = Data.ShopsDataById[tostring(shopId)].GemPrice * amount
    if Data.PlayerData.Gem < needprice then
      self:VoucherToGemNotice(needprice,1,self.ShopBuy,self,{ShopId = shopId,PayType = payType,Amount = amount,NetworkDelegate = networkDelegate,NetworkDelegateSelf = networkDelegateSelf})

      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end

      if GiftDetailsAPI ~= nil and GiftDetailsAPI.Instance ~= nil then
        GiftDetailsAPI.Instance:DestroySelf()
      end

      if PropDetailsAPI ~= nil and PropDetailsAPI.Instance ~= nil then
        PropDetailsAPI.Instance:DestroySelf()
      end

      if BuyHeroAPI ~= nil and BuyHeroAPI.Instance ~=  nil then
        BuyHeroAPI.Instance:DestroySelf()
      end

      if BuySkinAPI ~= nil and BuySkinAPI.Instance ~=  nil then
        BuySkinAPI.Instance:DestroySelf()
      end      
      return
    end
  end

  GameManager.CreatePanel("Waiting")
  self.shopId = shopId
  self.buyDelegate = networkDelegate
  self.buyDelegateSelf = networkDelegateSelf
  local BuyRequest = NetRequest.New()
  BuyRequest.Content = JObject.New(JProperty.New("Type", "RequestShopBuy"),
                      JProperty.New("ShopId",shopId),
                      JProperty.New("PayType",payType),
                      JProperty.New("Amount",amount))
  BuyRequest.Handler = TGNetService.NetEventHanlderSelf(UTGDataOperator.ShopBuyHandler,self)
  TGNetService.GetInstance():SendRequest(BuyRequest)  
end

function UTGDataOperator:ShopBuyHandler(e)
  -- body
  if e.Type == "RequestShopBuy" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    self.canBuy = false
    if result == 1 then
      --GameManager.CreatePanel("SelfHideNotice")
      --SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("购买成功")

      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end

      if GiftDetailsAPI ~= nil and GiftDetailsAPI.Instance ~= nil then
        GiftDetailsAPI.Instance:DestroySelf()
      end

      if PropDetailsAPI ~= nil and PropDetailsAPI.Instance ~= nil then
        PropDetailsAPI.Instance:DestroySelf()
      end

      if BuyHeroAPI ~= nil and BuyHeroAPI.Instance ~=  nil then
        BuyHeroAPI.Instance:DestroySelf()
      end

      if BuySkinAPI ~= nil and BuySkinAPI.Instance ~=  nil then
        BuySkinAPI.Instance:DestroySelf()
      end
--[[
      if UTGDataTemporary.Instance().shopPageID == 1 then
        if StoreRecommendCtrl ~= nil and StoreRecommendCtrl.Instance ~= nil then
          StoreRecommendCtrl.Instance:ApiUpdateNew()
        end
      elseif UTGDataTemporary.Instance().shopPageID == 2 then
        if StoreNewCtrl ~= nil and StoreNewCtrl.Instance ~= nil then
          StoreNewCtrl.Instance:ApiUpdateAll()
        end
      elseif UTGDataTemporary.Instance().shopPageID == 3 then
        if StoreHeroCtrl ~= nil and StoreHeroCtrl.Instance ~= nil then
          StoreHeroCtrl.Instance:ApiUpdateHeroList()
        end
      elseif UTGDataTemporary.Instance().shopPageID == 4 then
        if StoreSkinCtrl ~= nil and StoreSkinCtrl.Instance ~= nil then
          StoreSkinCtrl.Instance:ApiUpdateHeroList()
        end
      end
]]
      if self.buyDelegate~=nil then 
        self.buyDelegate(self.buyDelegateSelf)
      end
      return true
    elseif result == 2824 then
      local dialog = self:CreateDialog("NeedConfirmNotice")
      dialog:InitNoticeForNeedConfirmNotice("提示", "未拥有英雄", false, "" ,1 ,false)
      dialog:OneButtonEvent("确定",dialog.DestroySelf, dialog)
      dialog:SetTextToCenter()
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end
      return true
    elseif result == 2818 then
      if PropDetailsAPI ~= nil and PropDetailsAPI.Instance ~= nil then
        PropDetailsAPI.Instance:DestroySelf()
      end

      if GiftDetailsAPI ~= nil and GiftDetailsAPI.Instance ~= nil then
        GiftDetailsAPI.Instance:DestroySelf()
      end
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end
      GameManager.CreatePanel("SelfHideNotice")
      if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
        if Data.ShopsDataById[tostring(self.shopId)].LimitType == 1 then
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("此商品已达到限购上限，无法购买")
        else
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已达到今日限额")
        end
      end
      return true
    elseif result == 2819 then
      local dialog = self:CreateDialog("NeedConfirmNotice")
      dialog:InitNoticeForNeedConfirmNotice("提示", "您的金币不足", false, "",1,false)
      dialog:OneButtonEvent("确定",dialog.DestroySelf, dialog)
      dialog:SetTextToCenter()
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end
      return true
    elseif result == 2820 then
      return true
    elseif result == 2821 then
      local dialog = self:CreateDialog("NeedConfirmNotice")
      dialog:InitNoticeForNeedConfirmNotice("提示", "点券不足", false, "",2,false)
      dialog:TwoButtonEvent("取消",dialog.DestroySelf, dialog,
                              "购买点券",dialog.DestroySelfWithNotice, dialog)
      dialog:SetTextToCenter()
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end  
      return true
    elseif result == 2830 then
      local dialog = self:CreateDialog("NeedConfirmNotice")
      dialog:InitNoticeForNeedConfirmNotice("提示", "已达到购买上限", false, "",1,false)
      dialog:OneButtonEvent("确定",dialog.DestroySelf, dialog)
      dialog:SetTextToCenter()
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end      
      return true     
    end
  end
  return false
end

--点券兑换宝石
function UTGDataOperator:VoucherToGemNotice(needGem,shopType,func,funcSelf,args)
  local needVoucher = needGem - Data.PlayerData.Gem
  if needVoucher<=0 then return false end
  self.exchangeShopType = shopType
  self.voucherToGemFunc = func
  self.voucherToGemFuncSelf = funcSelf
  self.voucherToGemFuncArgs = args
  local dialog = self:CreateDialog("NeedConfirmNotice")
  self.dialogTemp = dialog
  dialog:InitNoticeForNeedConfirmNotice("提示", "确认花费<color=#FFED00FF>"..needGem.."</color>钻石么？\n您还差"..needVoucher.."钻石，将使用<color=#FFED00FF>"..needVoucher.."</color>点券补足", false, "",2,false)
  dialog:TwoButtonEvent("取消",function() 
                                self.exchangeShopType = 0
                                dialog:DestroySelf()
                                if RuneAPI ~= nil and RuneAPI.Instance ~= nil then
                                  RuneAPI.Instance.runeCtrl.self.alreadyDelete = false end
                              end,self,
                          "确定",function() 
                                  dialog:DestroySelf()
                                  self:VoucherToGem(needVoucher) 
                                  end, self)
  dialog:SetTextToCenter()
  return true 
end
function UTGDataOperator:VoucherNotEnoughNotice()
  local dialog = self:CreateDialog("NeedConfirmNotice")
  dialog:InitNoticeForNeedConfirmNotice("提示", "点券不足", false, "",2,false)
  dialog:TwoButtonEvent("取消",dialog.DestroySelf, dialog,
                          "购买点券",dialog.DestroySelfWithNotice, dialog)
  dialog:SetTextToCenter()
end
function UTGDataOperator:VoucherToGem(amount)
  GameManager.CreatePanel("Waiting")
  local voucherToGemRequest = NetRequest.New()
  voucherToGemRequest.Content = JObject.New(JProperty.New("Type", "RequestExchangeVoucherToGem"),
                      JProperty.New("Amount",amount))
  voucherToGemRequest.Handler = TGNetService.NetEventHanlderSelf(UTGDataOperator.VoucherToGemHandler,self)
  TGNetService.GetInstance():SendRequest(voucherToGemRequest)   
end
function UTGDataOperator:VoucherToGemHandler(e)
  -- body
  if e.Type == "RequestExchangeVoucherToGem" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      self.canBuy = true
      if self.voucherToGemFunc~=nil and self.voucherToGemFuncSelf ~=nil then 
        local agrs = self.voucherToGemFuncArgs
        if self.exchangeShopType == 1 then 
          self.voucherToGemFunc(self.voucherToGemFuncSelf,agrs.ShopId,agrs.PayType,agrs.Amount,agrs.NetworkDelegate,agrs.NetworkDelegateSelf)
        elseif self.exchangeShopType == 2 then 
          self.voucherToGemFunc(self.voucherToGemFuncSelf,agrs.PayType,agrs.Num)
        elseif self.exchangeShopType == 3 then 
          self.voucherToGemFunc(self.voucherToGemFuncSelf,agrs.PayType,agrs.Num)
        elseif self.exchangeShopType == 4 then
          self.voucherToGemFunc(self.voucherToGemFuncSelf)
        end
        self.voucherToGemFunc = nil
        self.voucherToGemFuncSelf = nil 
        self.voucherToGemFuncArgs = nil
        self.exchangeShopType = 0
        self.canBuy = false
      end
    elseif result == 2821 then
      if RuneAPI ~= nil and RuneAPI.Instance ~= nil then
        RuneAPI.Instance.runeCtrl.self.alreadyDelete = false
      end
      self:VoucherNotEnoughNotice()
    end
    if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
      WaitingPanelAPI.Instance:DestroySelf()
    end  
    return true
  end
  return false
end

function UTGDataOperator:BuyAndWearSkin(shopId,payType,networkDelegateDelegate,networkDelegateSelf)
  -- body
  GameManager.CreatePanel("Waiting")
  self.buyAndWearDelegate = networkDelegate
  self.buyAndWearDelegateSelf = networkDelegateSelf
  local buyAndWearRequest = NetRequest.New()
  buyAndWearRequest.Content = JObject.New(JProperty.New("Type", "RequestBuyAndWearSkin"),
                      JProperty.New("ShopId",shopId),
                      JProperty.New("PayType",payType))
  buyAndWearRequest.Handler = TGNetService.NetEventHanlderSelf(UTGDataOperator.BuyAndWearSkinHandler,self)
  TGNetService.GetInstance():SendRequest(buyAndWearRequest)  
end

function UTGDataOperator:BuyAndWearSkinHandler(e)
  -- body
  if e.Type == "RequestBuyAndWearSkin" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      --GameManager.CreatePanel("SelfHideNotice")
      --SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("购买并穿戴成功")
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end
      return true
    elseif result == 2824 then
      local dialog = self:CreateDialog("NeedConfirmNotice")
      dialog:InitNoticeForNeedConfirmNotice("提示", "未拥有英雄", false,"", 1,false)
      dialog:OneButtonEvent("确定",dialog.DestroySelf, dialog)
      dialog:SetTextToCenter()
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end
      return true
    elseif result == 2819 then
      local dialog = self:CreateDialog("NeedConfirmNotice")
      dialog:InitNoticeForNeedConfirmNotice("提示", "您的金币不足", false, "",1,false)
      dialog:OneButtonEvent("确定",dialog.DestroySelf, dialog)
      dialog:SetTextToCenter()
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end
      return true
    elseif result == 2820 then
      local dialog = self:CreateDialog("NeedConfirmNotice")
      dialog:InitNoticeForNeedConfirmNotice("提示", "您的钻石不足", false, "",1,false)
      dialog:OneButtonEvent("确定",dialog.DestroySelf, dialog)
      dialog:SetTextToCenter()
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end
      return true
    elseif result == 2821 then
      local dialog = self:CreateDialog("NeedConfirmNotice")
      dialog:InitNoticeForNeedConfirmNotice("提示", "点券不足", false, "",2,false)
      dialog:TwoButtonEvent("取消",dialog.DestroySelf, dialog,
                              "购买点券",dialog.DestroySelfWithNotice, dialog) 
      dialog:SetTextToCenter()
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end
      return true     
    end
  end
  return false
end

function UTGDataOperator:ExchangePartCommodity(partShopId,networkDelegateDelegate,networkDelegateSelf)
  -- body
  GameManager.CreatePanel("Waiting")
  self.exchangePartCommodityDelegate = networkDelegate
  self.exchangePartCommodityDelegateSelf = networkDelegateSelf
  local exchangePartCommodityRequest = NetRequest.New()
  exchangePartCommodityRequest.Content = JObject.New(JProperty.New("Type", "RequestExchangePartCommodity"),
                      JProperty.New("PartShopId",partShopId))
  exchangePartCommodityRequest.Handler = TGNetService.NetEventHanlderSelf(UTGDataOperator.ExchangePartCommodityHandler,self)
  TGNetService.GetInstance():SendRequest(exchangePartCommodityRequest)  
end

function UTGDataOperator:ExchangePartCommodityHandler(e)
  -- body
  if e.Type == "RequestExchangePartCommodity" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      --GameManager.CreatePanel("SelfHideNotice")
      --SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("购买并穿戴成功")
      if PartShopAPI ~= nil and PartShopAPI.Instance ~= nil then
        PartShopAPI.Instance:UpdatePieceAndList()
      end
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end
    elseif result == 2822 then
      local dialog = self:CreateDialog("NeedConfirmNotice")
      dialog:InitNoticeForNeedConfirmNotice("提示", "您的姬神碎片不足", false,"", 1,false)
      dialog:OneButtonEvent("确定",dialog.DestroySelf, dialog)
      dialog:SetTextToCenter()
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end
    elseif result == 2823 then
      local dialog = self:CreateDialog("NeedConfirmNotice")
      dialog:InitNoticeForNeedConfirmNotice("提示", "您的皮肤碎片不足", false, "" ,1,false)
      dialog:OneButtonEvent("确定",dialog.DestroySelf, dialog)
      dialog:SetTextToCenter()
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end    
    end
    return true
  end
  return false
end

function UTGDataOperator:CloseDialog()
  -- body
  --self.Dialog[#self.Dialog]:GetComponent("NTGLuaScript").self:DestroySelf()
end

function UTGDataOperator:DoGoToNewModelPanel(list)
  -- body
    coroutine.start(UTGDataOperator.GoToNewModelPanel,self,list)
end

function UTGDataOperator:GoToNewModelPanel(list)
  -- body
  local async = GameManager.CreatePanelAsync("ShowModle")
  while async.Done == false do
    coroutine.wait(0.05)
  end
  local lock = false
  if ShowModleAPI ~= nil and ShowModleAPI.Instance ~= nil then
    if EmailAPI ~= nil and EmailAPI.Instance ~= nil then
      ShowModleAPI.Instance:RegisterDelegate(EmailAPI.Instance,EmailAPI.Instance.GetNextReward,true)
      lock = true
    end 
    ShowModleAPI.Instance:Init(list)
    if self.newModelTag ~= nil then
      if self.newModelTag == "experience" then
        local str = "体验时间" .. list[1].ExperienceDays .. "天"
        ShowModleAPI.Instance:SetLimitTime(str)
        self.newModelTag = nil
      end
    end
  end 
end

function UTGDataOperator:OnDestroy()
  if self.coroutine_reconnect_time_count ~= nil then coroutine.stop(self.coroutine_reconnect_time_count) end
  UTGDataOperator.Instance = nil
  self.this = nil
  self = nil
end

--source表跳转ui
function UTGDataOperator:SoureceGotoUi(sourceId,func)
  Debugger.Log("GrowProcessCtrl:questGoto sourceId = "..sourceId)
  local data = Data.SourcesData[tostring(sourceId)]
  if data == nil then return end
  local panelName = data.UIName
  local param = data.UIParam[1]

  param = param or {}
  local function gotoOther(args)
    GameManager.CreatePanel("Waiting")
    local async = GameManager.CreatePanelAsync(tostring(panelName))
    while async.Done == false do
      coroutine.wait(0.05)
    end
    if func ~= nil then
      func()
    end
    if (WaitingPanelAPI~=nil and WaitingPanelAPI.Instance ~= nil) then
      WaitingPanelAPI.Instance:DestroySelf()
    end


    if (UTGMainPanelAPI~= nil and UTGMainPanelAPI.Instance ~= nil) then
      UTGMainPanelAPI.Instance:HideSelf()
    end
    if (panelName == "Store") then
      if StoreCtrl~=nil and StoreCtrl.Instance~=nil then 
        StoreCtrl.Instance:GoToUI(tonumber(param))
      end
    elseif (panelName == "Rune") then
      if RuneAPI ~= nil and RuneAPI.Instance ~= nil then
        RuneAPI.Instance:GoToTab3()
      end
    end
  end
  coroutine.start(gotoOther,self)
end

--统计等级奖的个数
function UTGDataOperator:LevelAwardCntGet()
  local cnt = 0
  local tabLevel = UITools.CopyTab(UTGData.Instance().PlayerLevelUpData)
  local realTabLevel = {} --剔除不存在等级奖励的条目 

  local cupNum = 0
  for i,v in pairs(tabLevel) do
    if (#v.Rewards ~= 0) then
      table.insert(realTabLevel,v)
    end
  end
  local function levelSort(a,b)
    if (a.Level < b.Level) then
      return true
    end
    return false
  end 
  table.sort(realTabLevel,levelSort)

  local haveGet = #Data.PlayerGrowUpProgressDeck.DrewLevelRewards
  local mylevel = Data.PlayerData.Level --当前等级

  --计算可以领取的个数
  for i,val in ipairs(realTabLevel) do
    if (val.Level <= mylevel) then
      cnt = cnt + 1
    end
  end

  cnt = cnt - haveGet
  return cnt
end

--统计任务奖励的个数
function UTGDataOperator:QuestAwardCntGet()
  local cnt = 0
  local tabLevel = UITools.CopyTab(UTGData.Instance().PlayerLevelUpData)
  local realTabLevel = {} --剔除不存在等级奖励的条目 

  for i,v in pairs(tabLevel) do
    if (#v.Rewards ~= 0) then
      table.insert(realTabLevel,v)
    end
  end
  local function levelSort(a,b)
    if (a.Level < b.Level) then
      return true
    end
    return false
  end 
  table.sort(realTabLevel,levelSort)
  local mylevel = Data.PlayerData.Level --当前等级
  for i,val in ipairs(realTabLevel) do
    if (Data.LevelQuestByLevel[tostring(val.Level)] ~= nil) then
      local tabLevelQuest = Data.LevelQuestByLevel[tostring(val.Level)]
      for j,valj in ipairs(tabLevelQuest) do
        if (Data.PlayerLevelQuestDeck[tostring(valj.Id)] ~= nil) then
          local questDeck = Data.PlayerLevelQuestDeck[tostring(valj.Id)]
          if (questDeck.Progress >= valj.MaxProgress and questDeck.IsDrew == false) then
            cnt = cnt + 1
          end
        end
      end
    end
    --等级一旦超过不参加统计
    if (val.Level > mylevel) then
      break
    end
  end
  return cnt
end

--我要成长可领取统计
function UTGDataOperator:WantGrowAwardCntGet()
  local growDeck = UTGData.Instance().PlayerGrowUpDeck
  local count = 0
  for k,v in pairs(growDeck) do
    local growdata = UTGData.Instance().GrowUpsData[tostring(v.GrowUpId)]
    if growdata~=nil then 
      if v.Progress>=growdata.MaxProgress and v.IsDrew == false then 
        count = count+1
      end
    end
  end
  return count
end

--特效找shader
function UTGDataOperator:EffectInit(trans)
 local tabRender = trans:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,tabRender.Length - 1 do
    trans:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(tabRender[k].material.shader.name)
  end
end

--是否有成就奖励可以领取
function UTGDataOperator:isAchieveAwardCanGet()
  local ret = false
  local level = Data.PlayerAchievementInfoDeck.Level
  for i,val in pairs(Data.AchievementLevelUpsWithAward) do
   if (val.Level <= level) then
     local state = self:achieveAwardStateGet(val.Level)
     if state == 1 then
      ret = true
      break
     end
   end
  end
  return ret
end

--得到成就奖励的状态：1:可领取，2：已经领取 3：未达到
function UTGDataOperator:achieveAwardStateGet(level)
  local ret = 0
  local myLevel = Data.PlayerAchievementInfoDeck.Level
  if (level > myLevel) then
    ret = 3
  elseif (level <= myLevel) then
    ret = 1
    for i,val in pairs(Data.PlayerAchievementInfoDeck.DrewLevelRewards) do
      if (val == level) then
        ret = 2
        break
      end
    end
  end
  return ret
end

--是否存在新成就
function UTGDataOperator:isExistNewAchieve()
  local ret = false
  if (self.tabAchieveNew ~= nil) then
    if (#self.tabAchieveNew >= 1) then
     ret = true
    end
  end
  return ret
end

--弹出成就面板
function UTGDataOperator:NewAchievePanelOpen(func)
  local isNew = self:isExistNewAchieve()
  if ( isNew == false) then
    if (func ~= nil) then
      func()
    end
  elseif (isNew == true) then
    if (self.tabAchieveNew ~= nil) then
      if (#self.tabAchieveNew >= 1) then
          local function CreatePanelAsync()
            Debugger.Log("NewAchieve")
            local async = GameManager.CreatePanelAsync("NewAchieve")
            --GameManager.CreatePanel("Waiting")
            while async.Done == false do
              coroutine.wait(0.03)
            end
  --          if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
  --           WaitingPanelAPI.Instance:DestroySelf()
  --          end
            if (func~= nil) then
              func()
            end

            if (NewAchieveApi ~= nil and NewAchieveApi.Instance ~= nil) then
              NewAchieveApi.Instance:uiSet(self.tabAchieveNew[1])
            end
            table.remove(self.tabAchieveNew,1)
          end
          coroutine.start(CreatePanelAsync,self)
      end
    end
  end
end

--登陆成功后进入主界面 显示活动等页面
function UTGDataOperator:InitActivityPanel()
  if UTGData.Instance().PlayerActivityDeck.IsSignInToday == false then 
    self:CreatePanelAsync("CumulativeLogin")
  else
    self:CreatePanelAsync("Notice")
  end
  UTGDataOperator.Instance:LoadAssetAsync()
end

function UTGDataOperator:CreatePanelAsync(panelName,func)
  local function Mov( )
    GameManager.CreatePanel("Waiting")
    local async = GameManager.CreatePanelAsync(panelName)
    while async.Done == false do
      coroutine.step()
    end
    if WaitingPanelAPI~=nil and WaitingPanelAPI.Instance~=nil then 
      WaitingPanelAPI.Instance:DestroySelf()
    end
    if func~=nil then func(self) end
  end
  coroutine.start(Mov,self)
end

--战斗外重连
function UTGDataOperator:ReconnectOutside(networkDelegate,networkDelegateSelf,networkDelegate2,networkDelegateSelf2)
  -- body
  self.ReconnectOutsideNetWorkDelegate = networkDelegate
  self.ReconnectOutsideNetWorkDelegateSelf = networkDelegateSelf
  self.ReconnectOutsideSpecialNetWorkDelegate = networkDelegate2
  self.ReconnectOutsideSpecialNetWorkDelegateSelf = networkDelegateSelf2

  local ReconnectOutsideRequest = NetRequest.New()
  ReconnectOutsideRequest.Content = JObject.New(JProperty.New("Type","RequestReconnectStage"))
  ReconnectOutsideRequest.Handler = TGNetService.NetEventHanlderSelf(UTGDataOperator.ReconnectOutsideHandler,self)
  TGNetService.GetInstance():SendRequest(ReconnectOutsideRequest)   
end
function UTGDataOperator:ReconnectOutsideHandler(e)
  -- body
  if e.Type == "RequestReconnectStage" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      local stage = tonumber(e.Content:get_Item("Stage"):ToString())
      local partyInfo = json.decode(e.Content:get_Item("PartyInfo"):ToString())
      --Debugger.LogError(stage)
      if stage == 1 then
        --正常流程
        if self.ReconnectOutsideNetWorkDelegate ~= nil and self.ReconnectOutsideNetWorkDelegateSelf ~= nil then
          self.ReconnectOutsideNetWorkDelegate(self.ReconnectOutsideNetWorkDelegateSelf)
        end
      else
        if self.ReconnectOutsideSpecialNetWorkDelegate ~= nil and self.ReconnectOutsideSpecialNetWorkDelegateSelf ~= nil then
          self.ReconnectOutsideSpecialNetWorkDelegate(self.ReconnectOutsideSpecialNetWorkDelegateSelf)
        end
      end

      if stage == 2 then
        local content = json.decode(e.Content:get_Item("Content"):ToString())

        --相应操作，检查当前PanelRoot下是否包括所需要的页面，如果有，直接使用，如果没有，创建
        if NewBattle17API ~= nil and NewBattle17API.Instance ~= nil then
          NewBattle17API.Instance:Init(content.TeamParties,content.RivalParties,content.Seconds)
        else
          GameManager.CreatePanel("NewBattle17")
          NewBattle17API.Instance:Init(content.TeamParties,content.RivalParties,content.Seconds)
        end
      elseif stage == 3 or stage == 5 then
        local content = json.decode(e.Content:get_Item("Content"):ToString())
        if content.BSubType ~= 66 then
          if PVPHeroSelectAPI ~= nil and PVPHeroSelectAPI.Instance ~= nil then
            PVPHeroSelectAPI.Instance:UpdatePartyChangeData(partyInfo)
          else
            local function DoReconnectPVPHeroSelect()
              -- body
              if PVPHeroSelectAPI ~= nil and PVPHeroSelectAPI.Instance ~= nil then
                PVPHeroSelectAPI.Instance:SetParam(content.BMainType,content.BSubType,content.Seconds,partyInfo)
              end

            end
            self:GoToOtherPanel("PVPHeroSelect",DoReconnectPVPHeroSelect,self)
          end
        else
          if DraftHeroSelectAPI ~= nil and DraftHeroSelectAPI.Instance ~= nil then
            DraftHeroSelectAPI.Instance:UpdateDraftData(content,partyInfo)
          else
            UTGDataTemporary.Instance().DraftData = content
            UTGDataTemporary.Instance().DraftPartyData = partyInfo
            self:GoToOtherPanel("DraftHeroSelect")           
          end

        end
      elseif stage == 4 then

      end

      --取数据

    else
      --正常流程
      if self.ReconnectOutsideNetWorkDelegate ~= nil and self.ReconnectOutsideNetWorkDelegateSelf ~= nil then
        self.ReconnectOutsideNetWorkDelegate(self.ReconnectOutsideNetWorkDelegateSelf)
      end
    end

    return true
  end
  return false
end

function UTGDataOperator:CleanPanelRoot()
  -- body
  for i = GameManager.PanelRoot.childCount-1,0,-1 do
    GameObject.Destroy(GameManager.PanelRoot:GetChild(i).gameObject)
  end
end

--时间转换time转为2016.6.6的字符串
function UTGDataOperator:timeStringGet(time)
  local pattern_go = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"--"2016-04-27T20:32:22+08:00"
  local year_go, month_go, day_go, hour_go, minute_go, seconds_go = tostring(time):match(pattern_go)
  local sTime = tostring(year_go).."."..tostring(month_go).."."..tostring(day_go)
  return sTime
end

--活动相关
--得到某个活动可领奖的个数
function UTGDataOperator:actiAwardCnt(info)
  local cnt = 0
  if (#info.ActivityQuests > 0) then
    if (info.ActivityQuests[1].Type == 1) then
      for i,v in ipairs(info.ActivityQuests) do
        if ( self:progressStateGet(v) == 0) then
          cnt = cnt + 1
        end
      end
    elseif (info.ActivityQuests[1].Type == 2) then
      for i,v in ipairs(info.ActivityQuests) do
        if ( self:timeStateGet(v) == 0) then
          cnt = cnt + 1
        end
      end 
    elseif (info.ActivityQuests[1].Type == 3) then
      for i,v in ipairs(info.ActivityQuests) do
        if ( self:exchangeStateGet(v) == 0) then
          cnt = cnt + 1
        end
      end 
    elseif (info.ActivityQuests[1].Type == 4) then
      for i,v in ipairs(info.ActivityQuests) do
        if ( self:openStateGet(v) == 0) then
          cnt = cnt + 1
        end
      end
    end
  end
  return cnt
end
 
function UTGDataOperator:progressStateGet(info)
  local GProCanGet = 0 --可以领
  local GProNoGet = 1 --不可领
  local GProHaveGet = 2 --已经领

  local ret = -1
  if (info.Type ~= 1) then
    return -1
  end  

  local cur = 0
  local isFinish = false
  local max = tonumber(info.Param[2])
  if (info.IsOpen == true and Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
    isFinish = Data.PlayerActivityQuestDeck[tostring(info.Id)].IsFinished
  end

  if (info.IsOpen == false and Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
    local isDrew = false
    if (Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
      isDrew = Data.PlayerActivityQuestDeck[tostring(info.Id)].IsDrew
    end
    if (isDrew == true) then
      ret = GProHaveGet
      return ret
    end
  end

  if (isFinish == false) then
    ret = GProNoGet
  elseif (isFinish == true) then
    local isDrew = false
    if (Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
      isDrew = Data.PlayerActivityQuestDeck[tostring(info.Id)].IsDrew
    end
    if isDrew == true then
      ret = GProHaveGet
    elseif isDrew == false then
      ret = GProCanGet
    end
  end
  return ret
end

--时间状态得到
function UTGDataOperator:timeStateGet(info)
  local GTimeCanGet = 0 --时间可以领取
  local GTimeNoGet = 1 --时间未到
  local GTimeHaveGet = 2 --时间已经领取
  local ret = -1
  if (info.IsOpen == true) then --
    local isDrew = false
    if (Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
      isDrew = Data.PlayerActivityQuestDeck[tostring(info.Id)].IsDrew
    end
    if (isDrew == false) then
      ret = GTimeCanGet
    elseif (isDrew == true) then
      ret = GTimeHaveGet
    end
  elseif (info.IsOpen == false) then
    local isDrew = false
    if (Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
      isDrew = Data.PlayerActivityQuestDeck[tostring(info.Id)].IsDrew
    end
    if (isDrew == false) then
      ret = GTimeNoGet
    elseif (isDrew == true) then
      ret = GTimeHaveGet
    end
  end
  return ret
end

--兑换状态得到,每次兑换完都要客户端自己更新
function UTGDataOperator:exchangeStateGet(info)
  local GExCanGet = 0 --兑换可以
  local GExNoGet = 1 --兑换不可
  local ret = -1
  local ownNum = 0
  if (Data.ItemsDeck[tostring(info.Param[1])] ~= nil) then
    ownNum = Data.ItemsDeck[tostring(info.Param[1])].Amount
  end

  local needNum = tonumber(info.Param[2])
 
  if (ownNum < needNum) then
    ret= GExNoGet
  elseif (info.IsOpen == true and ownNum >= needNum) then
    if (tonumber(info.Param[3]) == -1) then --无限兑换
      ret = GExCanGet
    else
      local haveEx = 0
      if (Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
        haveEx = Data.PlayerActivityQuestDeck[tostring(info.Id)].Param[1]
      end
      local maxEx = tonumber(info.Param[3])
      if (haveEx < maxEx) then
        ret = GExCanGet
      elseif (haveEx >= maxEx) then
        ret = GExNoGet
      end
    end
  end
  return ret
end

--向服务器请求活动数据，主界面刷新红点用
function UTGDataOperator:onRequestActivity()
  Debugger.Log("UTGDataOperator:onRequestActivity------------------------------")
  local serverRequest = NetRequest.New()
  serverRequest.Content = JObject.New(JProperty.New("Type","RequestCurrentActivity"))
  serverRequest.Handler = TGNetService.NetEventHanlderSelf(UTGDataOperator.onGetActivity,self)
  TGNetService.GetInstance():SendRequest(serverRequest)
end

--得到活动数据保存
function UTGDataOperator:onGetActivity(e)
  Debugger.Log("UTGDataOperator:onGetActivity----------------------------------1111111")
  if e.Type == "RequestCurrentActivity" then
    Debugger.Log("UTGDataOperator:onGetActivity-----------------------------------------")
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if (result == 1) then
      local tabActi = json.decode(e.Content:get_Item("Activities"):ToString())
      self.tabActiQuest = {}
      for i,val in ipairs(tabActi) do
        for j,valQuest in ipairs(val.ActivityQuests) do
          self.tabActiQuest[tostring(valQuest.Id)] = valQuest
        end
      end
    end
    return true
  end
  return false
end

function UTGDataOperator:tabActiQuestCreate(tamTmp)
  if (self.tabActiQuest == nil) then
    self.tabActiQuest = {}
    for i,val in ipairs(tamTmp) do
      for j,valQuest in ipairs(val.ActivityQuests) do
        self.tabActiQuest[tostring(valQuest.Id)] = valQuest
        --Debugger.Log("UTGDataOperator:tabActiQuestCreate = "..valQuest.Id)
      end
    end
    self:tabExchangeItemCreate() --生成兑换物品表
  end

  --每次打开活动面板，更新主界面红点
     local awardRed = self:isActiQuestExistCanGetAward()
     if (awardRed == true or self.actiNoReadCnt > 0) then
      self.actiRed = true
     elseif (awardRed == false and self.actiNoReadCnt == 0) then
      self.actiRed = false
     end
--    if (self.activityNotice == true) then
--      Debugger.Log("UTGDataOperator:tabActiQuestCreate true------------")
--    else
--      Debugger.Log("UTGDataOperator:tabActiQuestCreate false------------")
--    end
    if (UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil) then
      UTGMainPanelAPI.Instance:UpdateNotice()
    end
end

function UTGDataOperator:actiRedUpdate()
     local awardRed = self:isActiQuestExistCanGetAward()
     if (awardRed == true or self.actiNoReadCnt > 0) then
      self.actiRed = true
     elseif (awardRed == false and self.actiNoReadCnt == 0) then
      self.actiRed = false
     end
    if (UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil) then
      UTGMainPanelAPI.Instance:UpdateNotice()
    end
end
--兑换物品表
function UTGDataOperator:tabExchangeItemCreate()
  for i,val in pairs(self.tabActiQuest) do
    if (val.Type == 3) then
      local itemId = tonumber(val.Param[1])
      if (self.tabExItem == nil) then
        self.tabExItem = {}
      end
      table.insert(self.tabExItem,itemId)
    end
  end
end

function UTGDataOperator:isBelongTabExItem(id)
  local ret = false
  if (self.tabExItem ~= nil) then
    for i,val in ipairs(self.tabExItem) do  
      if (val == id) then
        ret = true
      end
    end
  end
  return ret
end

--判断是否某个活动的任务可以领取
function UTGDataOperator:isOneActiQuestCanGetAward(info)
  local ret = false
  if (info.Type == 1) then 
      if ( self:progressStateGet(info) == 0) then
        ret = true
      end
  elseif (info.Type == 2) then
      if ( self:timeStateGet(info) == 0) then
        ret = true
      end 
  elseif (info.Type == 3) then
      if ( self:exchangeStateGet(info) == 0) then
        ret = true
      end 
  elseif (info.Type == 4) then
      if ( self:openStateGet(info) == 0) then
        ret = true
      end  
  end
  return ret
end

--判断开服活动状态
function UTGDataOperator:openStateGet(info)
  local GProCanGet = 0 --可以领
  local GProNoGet = 1 --不可领
  local GProHaveGet = 2 --已经领
  local ret = -1
  if (info.Type ~= 4) then
    return
  end  

  local cur = 0
  local isFinish = false
  if (info.IsOpen == true and Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
    --cur = Data.PlayerActivityQuestDeck[tostring(info.Id)].Param[1]
    isFinish = Data.PlayerActivityQuestDeck[tostring(info.Id)].IsFinished
  end

  if (info.IsOpen == false and Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
    local isDrew = false
    if (Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
      isDrew = Data.PlayerActivityQuestDeck[tostring(info.Id)].IsDrew
    end
    if (isDrew == true) then
      ret = GProHaveGet
      return ret
    end
  end

  if (isFinish == false) then
    ret = GProNoGet
  elseif (isFinish == true) then
    local isDrew = false
    if (Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
      isDrew = Data.PlayerActivityQuestDeck[tostring(info.Id)].IsDrew
    end
    if isDrew == true then
      ret = GProHaveGet
    elseif isDrew == false then
      ret = GProCanGet
    end
  end
  return ret
end

function UTGDataOperator:isActiQuestExistCanGetAward()
  local ret = false
  if (self.tabActiQuest ~= nil) then
    for i,val in pairs(self.tabActiQuest) do
      if (self:isOneActiQuestCanGetAward(val) == true) then
        Debugger.Log("UTGDataOperator:isActiQuestExistCanGetAward = "..val.Id)
        ret = true
        break
      end
    end
  end
  return ret
end

