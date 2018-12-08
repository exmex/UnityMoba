require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("AchievementCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"
local Toggle = "UnityEngine.UI.Toggle"

local Data = UTGData.Instance()

local GAwardCanGet = 1
local GAwardHaveGet = 2
local GAwardNoReach = 3

function AchievementCtrl:Awake(this) 
  self.this = this
  self.itemTmp = this.transforms[0]
  self.allContent = this.transforms[1]
  self.topBtnPart = this.transforms[2]
  self.scrollAll = this.transforms[3]
  self.scrollNotHave = this.transforms[4]
  self.notHaveContent = this.transforms[5]
  self.notHaveItem = this.transforms[6]
  self.goldEffect = this.transforms[7]

  self.btnRule = this.transforms[8]
  self.btnLookAllAward = this.transforms[9]
  self.rulePanel = this.transforms[10]
  self.detailPanel = this.transforms[11]
  self.awardPanel = this.transforms[12]
  self.rulePanelClose = this.transforms[13]
  self.detailPanelClose = this.transforms[14]
  self.awardPanelClose = this.transforms[15]
  self.silverEffect = this.transforms[16]

  self.leftPart = this.transforms[17]
  self.btnGet = this.transforms[18]
  local effectDetail1 = this.transforms[19]
  local effectDetail2 = this.transforms[20]
  self.tip = this.transforms[21]
  self:dataInit()
  self:btnInit()
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
  UTGDataOperator.Instance:EffectInit(self.goldEffect)
  UTGDataOperator.Instance:EffectInit(self.silverEffect)
  UTGDataOperator.Instance:EffectInit(effectDetail1)
  UTGDataOperator.Instance:EffectInit(effectDetail2)
  self:onRequestRank()
  self.camera = GameObject.Find("GameLogic"):GetComponent("Camera")
end

function AchievementCtrl:dataInit(args)
  self:dataFirstCupData()
  self:awardDataSet() --领取奖励情况设置
end

function AchievementCtrl:dataFirstCupData(args)
  local tabCupFirst = UITools.CopyTab(Data.AchievementsFirst) --第一级奖杯集合，不管有没有获得
  local tabAchievementsDeck = UITools.CopyTab(Data.PlayerAchievementsDeck)
  local tabFinishFirstToDel = {}
  self.tabFinishOrder = {} --已经完成
  for j,deck in pairs(tabAchievementsDeck) do
    local info = Data.AchievementsById[tostring(deck.AchievementId)]
    table.insert(self.tabFinishOrder,info)
  end

  --todo从self.tabCupFirst删去已经获得的奖杯
  for i,first in pairs(tabCupFirst) do 
    for j,deck in pairs(tabAchievementsDeck) do
      local deckType = Data.AchievementsById[tostring(deck.AchievementId)].Type
      if (first.Type == deckType) then
        table.insert(tabFinishFirstToDel,first.Id)
      end
    end
  end

  for i,val in ipairs(tabFinishFirstToDel) do
    tabCupFirst[tostring(val)] = nil
  end

  
  --已经获得的奖杯进行时间排序
  local function timeSort(a,b)
    ------Debugger.Log("Data.PlayerAchievementsDeck[tostring(a.Id)].FinishTime = "..Data.PlayerAchievementsDeck[tostring(a.Id)].FinishTime)
    ------Debugger.Log("Data.PlayerAchievementsDeck[tostring(a.Id)].FinishTime111 = "..Data:GetLeftTime(Data.PlayerAchievementsDeck[tostring(a.Id)].FinishTime))
    local aTime =  Data:GetLeftTime(Data.PlayerAchievementsDeck[tostring(a.Id)].FinishTime)
    local bTime =  Data:GetLeftTime(Data.PlayerAchievementsDeck[tostring(b.Id)].FinishTime)
    if  aTime > bTime then
     return true
    end
    return false
  end
  table.sort(self.tabFinishOrder,timeSort)

  --删去已经获得同type低级的奖杯
  local tabFinishOrderDelId = {}
  for i = #self.tabFinishOrder,1,-1 do
    local typeCupOld = self.tabFinishOrder[i].Type
    for j = i -1 ,1,-1 do
      local typeCupNew = self.tabFinishOrder[j].Type
      if (typeCupNew == typeCupOld) then --同type
        if ( self.tabFinishOrder[i].Level > self.tabFinishOrder[j].Level) then
          table.insert(tabFinishOrderDelId,j)
        elseif ( self.tabFinishOrder[i].Level < self.tabFinishOrder[j].Level) then
          table.insert(tabFinishOrderDelId,i)
        end
      end
    end
  end

  local function isDel(idx)
    local ret = false
    for i,v in ipairs(tabFinishOrderDelId) do
      if (v == idx) then
        ret = true
        break
      end
    end
    return ret
  end


  for i = #self.tabFinishOrder,1,-1 do
    if (isDel(i) == true) then
      table.remove(self.tabFinishOrder,i)
    end
  end


  --未获得的奖杯
  self.tabNoCupOrder = {}
  for k,val in pairs(tabCupFirst) do 
    if (val ~=nil) then
      table.insert(self.tabNoCupOrder,val)
    end
  end

  local function idSort(a,b)
    if a.Id  < b.Id   then
      return true
    end
    return false
  end 

  table.sort(self.tabNoCupOrder,idSort)
end


function AchievementCtrl:Start()
  self:leftUiInit()
  self:awardUiSet()
  self:topResBarInit()

  self:topToggleBtnInit()

  self:toggleUiUpdate("ScrollAll")
  self:onToggle("ScrollAll")

  self:itemCreate(self.tabFinishOrder,true)
  self:itemCreate(self.tabNoCupOrder,true)
--  self:itemCreate(self.tabNoCupOrder,false)
  self:awardPanelTopUiInit()
  
end

function AchievementCtrl:OnDestroy()
  NTGResourceController.Instance:UnloadAssetBundle("achievement", true, false)
  self.this = nil
  self = nil
end

--
function AchievementCtrl:itemCreate(tabItem,isAll)
  for i,v in ipairs(tabItem) do
    local newTmp
    if (isAll == true) then
      newTmp = GameObject.Instantiate(self.itemTmp)
    elseif (isAll == false) then
      newTmp = GameObject.Instantiate(self.notHaveItem)
    end
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(i)
    if (isAll == true) then
      newTmp.transform:SetParent(self.allContent)
    elseif (isAll == false) then
      newTmp.transform:SetParent(self.notHaveContent)
    end
   
    
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one
    newTmp.transform.localPosition = Vector3.New(0,0,0)
    self:itemUiSet(newTmp,v)

    --点击事件
    local callback = function(self, e)
      self:onClickItem(i,v)
	  end	
    UITools.GetLuaScript(newTmp.transform,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)


  end
end

--cup点击
--info为template中信息
function AchievementCtrl:onClickItem(i,info)
  ----Debugger.Log("AchievementCtrl:onClickItem = "..info.Id)
  self.detailPanel.gameObject:SetActive(true)
  self:detailPanelUpdate(info)
  self.detailPanel.gameObject:SetActive(true)
end

--更新详细面板
function AchievementCtrl:detailPanelUpdate(info)
  local typeItem = info.Type
  local title = self.detailPanel:FindChild("title")
  title:GetComponent(Text).text = info.Name

  local tip = self.detailPanel:FindChild("Tip");
  tip:GetComponent(Text).text = info.Tip


  local tabItem = Data.AchievementsByType[tostring(typeItem)]
  local item1 = self.detailPanel:FindChild("Item1")
  self:detailPanelOneUpdate(item1,tabItem["1"])
  local item2 = self.detailPanel:FindChild("Item2")
  self:detailPanelOneUpdate(item2,tabItem["2"])
  local item3 = self.detailPanel:FindChild("Item3")
  self:detailPanelOneUpdate(item3,tabItem["3"])
end

--详细面板单个更新
function AchievementCtrl:detailPanelOneUpdate(trans,info)
  --成就条件
  local labCondition = trans:FindChild("ButtonLabPart/LabCondition")
  labCondition:GetComponent(Text).text = tostring(info.Desc)

  local timePart = trans:FindChild("ButtonLabPart/OtherPart/TimePart")
  local tProgress = trans:FindChild("ButtonLabPart/OtherPart/LabProgress")
  if (info.Level == 2 or info.Level == 3) then
    local effect = trans:FindChild("effect")
    effect.gameObject:SetActive(false)
  end
   --mask设置
  local mask = trans:FindChild("Mask")
  local isFinish = self:isAchieveFinish(info.Id)
  if (isFinish == true) then
    mask.gameObject:SetActive(false)

    --时间
    local time = Data.PlayerAchievementsDeck[tostring(info.Id)].FinishTime
    local sTime = self:timeGet(time)
    tProgress.gameObject:SetActive(false)
    timePart.gameObject:SetActive(true)
    local labTime = timePart:FindChild("LabTime")
    labTime:GetComponent(Text).text = sTime
    --显示特效,这个特效需要动态更改层级，把层级提高
    if (info.Level == 2 or info.Level == 3) then
      local effect = trans:FindChild("effect")

      effect.gameObject:SetActive(true)
    end
  elseif (isFinish == false) then
    timePart.gameObject:SetActive(false)
    tProgress.gameObject:SetActive(false)
    mask.gameObject:SetActive(true)
    --显示进度
    local isProgressShow = Data.AchievementsById[tostring(info.Id)].IsProgressShow
    if (isProgressShow == 1) then
      
      tProgress.gameObject:SetActive(true)
      local progress = 0
      if (Data.PlayerAchievementProgressDeck[tostring(info.Type)] ~= nil) then
        progress = Data.PlayerAchievementProgressDeck[tostring(info.Type)].CurProgress 
      end

      local maxProgress = Data.AchievementsById[tostring(info.Id)].Progress
      local sProgress = "("..tostring(progress).."/"..tostring(maxProgress)..")"
      tProgress:GetComponent(Text).text = sProgress
    end
  end

  --cup底座设置
  local level = info.Level
  local cupBg = trans:FindChild("CupPart/"..level)
  cupBg.gameObject:SetActive(true)

  --icon设置
  local icon = cupBg:FindChild("Icon")
  icon:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("achieveicon",tostring(info.Icon),"UnityEngine.Sprite")

  --名字
  local name = trans:FindChild("LabName")
  name:GetComponent(Text).text = info.Name

  --成就积分
  local labPoint = trans:FindChild("LabInttgral")
  labPoint:GetComponent(Text).text = "成就积分"..tostring(info.Point)

  
end

--时间转换
function AchievementCtrl:timeGet(time)
  local pattern_go = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"--"2016-04-27T20:32:22+08:00"
  local year_go, month_go, day_go, hour_go, minute_go, seconds_go = tostring(time):match(pattern_go)
  local sTime = tostring(year_go).."."..tostring(month_go).."."..tostring(day_go)
  return sTime
end

--cup ui设置
--info为template中信息
function AchievementCtrl:itemUiSet(trans,info)
  --mask设置
  local mask = trans:FindChild("Mask")
  local labTime = trans:FindChild("LabTime")
  local isFinish = self:isAchieveFinish(info.Id)
  if (isFinish == true) then
    mask.gameObject:SetActive(false)

    local time = Data.PlayerAchievementsDeck[tostring(info.Id)].FinishTime
    local sTime = self:timeGet(time)
    labTime:GetComponent(Text).text = sTime

    --显示特效
    self:cupEffect(trans,info.Level)
  elseif (isFinish == false) then
    mask.gameObject:SetActive(true)
    labTime:GetComponent(Text).text = "未获得"
  end

  --cup底座设置
  local level = info.Level
  local cupBg = trans:FindChild("CupPart/"..level)
  cupBg.gameObject:SetActive(true)

  --icon设置
  local icon = cupBg:FindChild("Icon")
  icon:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("achieveicon",tostring(info.Icon),"UnityEngine.Sprite")

  --名字
  local name = trans:FindChild("LabName")
  name:GetComponent(Text).text = info.Name

end

--当前奖杯是否完成
function AchievementCtrl:isAchieveFinish(achieveId)
  local ret = false
  if (Data.PlayerAchievementsDeck[tostring(achieveId)] ~= nil) then
   ret = true
  end
  return ret
end

--在指定的父奖杯上产生特效 
--level：金或银 2 , 3
function AchievementCtrl:cupEffect(parentTrans,level,isDetail)
    if (level == 1 ) then
     return
    end
    local obj
    if (level == 2 ) then
      obj = self.silverEffect
    elseif (level == 3) then
      obj = self.goldEffect
    end
    local newTmp = GameObject.Instantiate(obj)

    if (isDetail == true) then
      local renders = newTmp:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
      for i=1,renders.Length,1 do
        renders[i-1].sortingOrder = 3; 
      end
    end


    newTmp.gameObject:SetActive(true)
    newTmp.transform:SetParent(parentTrans)

    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one
    newTmp.transform.localPosition = Vector3.New(0,0,0)
end


function AchievementCtrl:topResBarInit()
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("AchievementPanel/Ctrl/Top")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,self.DestroySelf,nil,nil,"成就")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(topAPI)
end

function AchievementCtrl:DestroySelf()
  Object.Destroy(self.this.transform.parent.gameObject)
  if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
    UTGMainPanelAPI.Instance:ShowSelf()
  end
end

function AchievementCtrl:topToggleBtnInit(args)
  for i = 0, self.topBtnPart.childCount-1,1 do
    local btn = self.topBtnPart:GetChild(i)
    local name = btn.name
    local listener = NTGEventTriggerProxy.Get(btn.gameObject)
    local callBack = function (self,e)
      self:toggleUiUpdate(name)
      self:onToggle(name)
    end
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
  end
end

--切换全部和尚未获得 
function AchievementCtrl:onToggle(name)
  if (name == "ScrollAll") then
    self.scrollAll.gameObject:SetActive(true)
    self.scrollNotHave.gameObject:SetActive(false)
  elseif (name == "ScrollNotHave") then
    self.scrollAll.gameObject:SetActive(false)

    --如果尚未获得未创建则创建一次
    local notContent = self.scrollNotHave:FindChild("Viewport/notHaveContent")
    if notContent.childCount == 0 then
      self:itemCreate(self.tabNoCupOrder,false)
    end

    self.scrollNotHave.gameObject:SetActive(true)
  end
end

function AchievementCtrl:toggleUiUpdate(name)
  for i = 0,self.topBtnPart.childCount-1,1 do
    local obj = self.topBtnPart:GetChild(i);
    if obj.name == name then
      obj:FindChild("Image").gameObject:SetActive(true)
    else
      obj:FindChild("Image").gameObject:SetActive(false)
    end
  end
end

function AchievementCtrl:gotoNewAchieve(args)
    local function CreatePanelAsync()
    ----Debugger.Log("NewAchieve")
    local async = GameManager.CreatePanelAsync("NewAchieve")
    while async.Done == false do
      coroutine.wait(0.05)
    end
  end
  coroutine.start(CreatePanelAsync,self)
end
function AchievementCtrl:btnInit(args)
  local listener = NTGEventTriggerProxy.Get(self.btnRule.gameObject)
  local callBack = function (self,e)
    self.rulePanel.gameObject:SetActive(true)
    --self:gotoNewAchieve()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)

  listener = NTGEventTriggerProxy.Get(self.rulePanelClose.gameObject)
  callBack = function (self,e)
    self.rulePanel.gameObject:SetActive(false)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)


  listener = NTGEventTriggerProxy.Get(self.btnLookAllAward.gameObject)
  callBack = function (self,e)
    self.awardPanel.gameObject:SetActive(true)
    self:awardPanelListUpdate()--更新列表
    
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)

  listener = NTGEventTriggerProxy.Get(self.awardPanelClose.gameObject)
  callBack = function (self,e)
    self.awardPanel.gameObject:SetActive(false)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)

  listener = NTGEventTriggerProxy.Get(self.detailPanelClose.gameObject)
  callBack = function (self,e)
    self.detailPanel.gameObject:SetActive(false)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)

end

--左边面板初始化显示玩家成就等级
function AchievementCtrl:leftUiInit(args)
  --当前等级
  local curLevel  = Data.PlayerAchievementInfoDeck.Level
  local labCurLevel = self.leftPart:FindChild("TopBg/LabAchieveLevel")
  labCurLevel:GetComponent(Text).text = "成就等级"..tostring(Data.PlayerAchievementInfoDeck.Level)

  ----Debugger.Log("local curExp = Data.PlayerAchievementInfoDeck.Exp = ".. Data.PlayerAchievementInfoDeck.Exp)
  --经验进度
  if (Data.AchievementLevelUps[tostring(curLevel+1)] ~= nil) then --当前不是满级
    local curExp = Data.PlayerAchievementInfoDeck.Exp
    local maxExp = Data.AchievementLevelUps[tostring(curLevel)].NextExp
    local labExp = self.leftPart:FindChild("TopBg/LabProgress")
    labExp:GetComponent(Text).text = tostring(curExp).."/"..tostring(maxExp)
    local sprExp = self.leftPart:FindChild("TopBg/IconPart/ProgressBg/Progress")
    sprExp:GetComponent(Image).fillAmount = curExp/maxExp
  else --满级,只显示上一级的状态
    local curExp = Data.AchievementLevelUps[tostring(curLevel-1)].NextExp
    local maxExp = Data.AchievementLevelUps[tostring(curLevel-1)].NextExp
    local labExp = self.leftPart:FindChild("TopBg/LabProgress")
    labExp:GetComponent(Text).text = tostring(curExp).."/"..tostring(maxExp)
    local sprExp = self.leftPart:FindChild("TopBg/IconPart/ProgressBg/Progress")
    sprExp:GetComponent(Image).fillAmount = 1
  end
  --装备icon
  local sprIcon = self.leftPart:FindChild("TopBg/IconPart/IconMask/Icon");
  sprIcon:GetComponent(Image).sprite = NTGResourceController.Instance:LoadAsset("equipicon",tostring(Data.AchievementLevelUps[tostring(curLevel)].Icon),"UnityEngine.Sprite")

end

function AchievementCtrl:onRequestRank(args)
  local serverRequest = NetRequest.New()
  serverRequest.Content = JObject.New(JProperty.New("Type","RequestPlayerAchievementRank"))
  serverRequest.Handler = TGNetService.NetEventHanlderSelf(AchievementCtrl.onServerRank,self)
  TGNetService.GetInstance():SendRequest(serverRequest)
end

function AchievementCtrl:onServerRank(e)
--achievement_critical_rank
  ----Debugger.Log("RequestPlayerAchievementRank")
  if e.Type == "RequestPlayerAchievementRank" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      local rank = tonumber(e.Content:get_Item("Rank"):ToString())
      ----Debugger.Log("RequestPlayerAchievementRank rank = "..rank)
      local limitRank =  UTGData.Instance().ConfigData["achievement_critical_rank"].Int
      local labRank = self.leftPart:FindChild("TopBg/LabRank")
      if (rank <= limitRank) then
        labRank:GetComponent(Text).text = tostring(rank)
      elseif (rank > limitRank) then
        labRank:GetComponent(Text).text = "未上榜"
      end
    end
    return true
  end
  return false
end


function AchievementCtrl:awardDataSet()
  local tabAward = UITools.CopyTab(Data.AchievementLevelUpsWithAward)
  local tabAwardOrder = {}
  self.tabAwardCanGet = {}
  self.tabAwardNoReach = {}
  self.tabAwardHaveGet = {}
  for i,val in pairs(tabAward) do
    table.insert(tabAwardOrder,val)
  end

  local function levelSort(a,b)
    if a.Level  < b.Level   then
      return true
    end
    return false
  end 
  table.sort(tabAwardOrder,levelSort)

  for i,val in ipairs(tabAwardOrder) do
    local state = UTGDataOperator.Instance:achieveAwardStateGet(val.Level)
    if (state == GAwardCanGet) then
      table.insert(self.tabAwardCanGet,val)
    elseif (state == GAwardHaveGet) then
      table.insert(self.tabAwardHaveGet,val)
    elseif (state == GAwardNoReach) then
      table.insert(self.tabAwardNoReach,val)
    end
  end

end

--奖励显示，包含领取按钮状态更改
function AchievementCtrl:awardUiSet(args)
  local isCanGet = false
  local level = 0
  local tabAward = {}
  if (#self.tabAwardCanGet > 0) then
    ----Debugger.Log("self.tabAwardCanGet")
    tabAward = self.tabAwardCanGet[1].Rewards
    level = self.tabAwardCanGet[1].Level
    isCanGet = true
  elseif (#self.tabAwardNoReach > 0) then
    tabAward = self.tabAwardNoReach[1].Rewards
    level = self.tabAwardNoReach[1].Level
    ----Debugger.Log("self.tabAwardNoReach")
  elseif (#self.tabAwardHaveGet > 0) then --满级了且全部领取了显示最后一个已经领取的奖励
    tabAward = self.tabAwardHaveGet[#self.tabAwardHaveGet].Rewards
    ----Debugger.Log("self.tabAwardHaveGet")
    level = self.tabAwardHaveGet[#self.tabAwardHaveGet].Level
  end

  local labLevel = self.leftPart:FindChild("LabLeveAward")
  labLevel:GetComponent(Text).text = tostring(level).."级奖励"

  if (isCanGet == false) then
    self.btnGet:GetComponent("UnityEngine.UI.Button").interactable = false
    local image = self.btnGet:FindChild("Image")
    image:GetComponent("UnityEngine.UI.Button").interactable = false
    local listener = NTGEventTriggerProxy.Get(self.btnGet.gameObject)
    local callBack = function (self,e)
    end
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
  elseif (isCanGet == true) then
    self.btnGet:GetComponent("UnityEngine.UI.Button").interactable = true
    local image = self.btnGet:FindChild("Image")
    image:GetComponent("UnityEngine.UI.Button").interactable = true
    local listener = NTGEventTriggerProxy.Get(self.btnGet.gameObject)
    local callBack = function (self,e)
      self:onSendServerGetAward(level)
    end
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
  end


  local part1 = self.leftPart:FindChild("ItemPart/Part1")
  local part2 = self.leftPart:FindChild("ItemPart/Part2")
  if (#tabAward == 1) then
    ----Debugger.Log("self.tabAward = 1")
    self:awardItemOneSet(part1,tabAward[1])
    part1.gameObject:SetActive(true)
    part2.gameObject:SetActive(false)
  elseif (#tabAward == 2) then
    ----Debugger.Log("self.tabAward = 2")
    self:awardItemOneSet(part1,tabAward[1])
    self:awardItemOneSet(part2,tabAward[2])
    part1.gameObject:SetActive(true)
    part2.gameObject:SetActive(true)
  end
  
end

function AchievementCtrl:onSendServerGetAward(level)
  local serverRequest = NetRequest.New()
  serverRequest.Content = JObject.New(JProperty.New("Type","RequestDrawAchievementLevelReward"),
                                      JProperty.New("Level",level) )
  serverRequest.Handler = TGNetService.NetEventHanlderSelf(AchievementCtrl.onGetServerGetAward,self)
  TGNetService.GetInstance():SendRequest(serverRequest)
end

--领取奖励服务器回调=
function AchievementCtrl:onGetServerGetAward(e)
  ----Debugger.Log("AchievementCtrl:onServerGetGetAward")
  if e.Type == "RequestDrawAchievementLevelReward" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      ----Debugger.Log("AchievementCtrl:onServerGetGetAward result = 1")
    end
    return true
  end
  return false
end

function AchievementCtrl:awardItemOneSet(trans,info,isTip)
  
  local quality = 0
	local icon = ""
  local itemName = ""
  local itemNum = 0
  local itemDesc = ""
  local atlasMini = ""
  local iconMini = ""
  local isShowNum = false
	  if info.Type == 4 then
		  quality = Data.ItemsData[tostring(info.Id)].Quality
	  elseif info.Type == 1 or info.Type == 2 then
		  quality = 4
	  elseif info.Type == 3 then
		  quality = Data.RunesData[tostring(info.Id)].Level
	  end
		  trans:GetComponent(Image).sprite = UITools.GetSprite("icon",quality)
	  local num = 0
	  num = info.Amount

    if (num == 1 ) then
      trans:Find("Text").gameObject:SetActive(false)
    elseif (num > 1) then
      trans:Find("Text").gameObject:SetActive(true)
      trans:Find("Text"):GetComponent(Text).text = num
    end
	  
	  --trans:Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("icon",info.Icon)
	  if  info.Type == 1 then
		  --trans:Find("Name"):GetComponent(Text).text = Data.RolesData[tostring(info.Id)].Name
		  itemName = Data.RolesData[tostring(info.Id)].Name
		  itemNum = 1
		  itemDesc = Data.RolesData[tostring(info.Id)].Desc
		  icon = Data.SkinsData[tostring(Data.RolesData[tostring(info.Id)].Skin)].Icon
		  trans:Find("Icon").gameObject:SetActive(false)	--显示通用道具icon
		  trans:Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
		  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",icon)
		  --trans:Find("Hero").gameObject:SetActive(true)
      atlasMini = "roleicon"
      iconMini = icon
	  elseif 	info.Type == 2 then
		  --trans:Find("Name"):GetComponent(Text).text = Data.SkinsData[tostring(info.Id)].Name
		  itemName = Data.SkinsData[tostring(info.Id)].Name
		  itemDesc = Data.SkinsData[tostring(info.Id)].Desc
		  ItemNum = 1
		  icon = Data.SkinsData[tostring(info.Id)].Icon
		  trans:Find("Icon").gameObject:SetActive(false)	--显示通用道具icon
		  trans:Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
		  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",icon)
      atlasMini = "roleicon"
      iconMini = icon
	  elseif	info.Type == 3 then
		  --trans:Find("Name"):GetComponent(Text).text = Data.RunesData[tostring(info.Id)].Name
		  itemName = Data.RunesData[tostring(info.Id)].Name
		      if Data.RunesDeck[tostring(info.Id)] ~= nil then
		        itemNum = Data.RunesDeck[tostring(info.Id)].Amount
		      else
		        itemNum = 0
		      end
		  local attrs = UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",info.Id)
		  local str = ""
		  for i = 1,#attrs do
			      if i == #attrs then
			        str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr
			      else
			        str = str .. attrs[i].Des .. "      +" .. attrs[i].Attr .. "\n"
			      end
		  end
		  itemDesc = str				
		  icon = Data.RunesData[tostring(info.Id)].Icon
		  trans:Find("Icon").gameObject:SetActive(false)
		  trans:Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
		  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",icon)
		  trans:Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(65,74)
      atlasMini = "runeicon"
      iconMini = icon
      isShowNum = true
	  else
		  trans:Find("Icon").gameObject:SetActive(false)
		  --trans:Find("Name"):GetComponent(Text).text = Data.ItemsData[tostring(info.Id)].Name
		  itemName = Data.ItemsData[tostring(info.Id)].Name
		  local itemData = Data.ItemsData[tostring(info.Id)]
		  if itemData.Type == 8 then
			  trans:Find("Hero").gameObject:SetActive(true)
			  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",
																										  Data.SkinsData[tostring(Data.RolesData[tostring(itemData.Param[1][1])].Skin)].Icon)
			  itemDesc = Data.RolesData[tostring(itemData.Param[1][1])].Desc
			  itemNum = Data.ItemsDeck[tostring(info.Id)].Amount
        atlasMini = "roleicon"
        iconMini = Data.SkinsData[tostring(Data.RolesData[tostring(itemData.Param[1][1])].Skin)].Icon
		  elseif itemData.Type == 7 then
			  trans:Find("Skin").gameObject:SetActive(true)
			  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",
																										  Data.SkinsData[tostring(itemData.Param[1][1])].Icon)
			  itemDesc = Data.SkinsData[tostring(itemData.Param[1][1])].Desc
			  itemNum = Data.ItemsDeck[tostring(info.Id)].Amount
        atlasMini = "roleicon"
        iconMini = Data.SkinsData[tostring(itemData.Param[1][1])].Icon
		  elseif itemData.Type == 13 then
			  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(info.Id)].Icon)
			  trans:Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(74,74)
			  itemDesc = itemData.Desc
			  itemNum = Data.PlayerData.Coin .. "个"
        atlasMini = "resourceicon"
        iconMini = Data.ItemsData[tostring(info.Id)].Icon
		  elseif itemData.Type == 14 then
			  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(info.Id)].Icon)
			  trans:Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(74,74)
			  itemDesc = itemData.Desc
			  itemNum = Data.PlayerData.Gem .. "个"
        atlasMini = "resourceicon"
        iconMini = Data.ItemsData[tostring(info.Id)].Icon
		  elseif itemData.Type == 15 then
			  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(info.Id)].Icon)
			  trans:Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(74,74)
			  itemDesc = itemData.Desc
			  itemNum = Data.PlayerData.Exp
        atlasMini = "resourceicon"
        iconMini = Data.ItemsData[tostring(info.Id)].Icon
		  elseif itemData.Type == 17 then
			  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(info.Id)].Icon)
			  trans:Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(74,74)
			  itemNum = Data.PlayerData.RunePiece .. "个"
			  itemDesc = itemData.Desc
        atlasMini = "itemicon"
        iconMini = Data.ItemsData[tostring(info.Id)].Icon
		  elseif itemData.Type == 20 then
			  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(info.Id)].Icon)
			  itemNum = Data.PlayerData.DailyActivePoint
			  itemDesc = itemData.Desc				
        atlasMini = "itemicon"
        iconMini = Data.ItemsData[tostring(info.Id)].Icon
      elseif itemData.Type == 23 then --点券
        trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(info.Id)].Icon)
			  itemNum = Data.PlayerData.Voucher
			  itemDesc = itemData.Desc				
        atlasMini = "resourceicon"
        iconMini = Data.ItemsData[tostring(info.Id)].Icon
        trans:Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(74,74)
		  else
			  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(info.Id)].Icon)
			  itemDesc = itemData.Desc
        ------Debugger.Log("+++++++++++++++++++++++++++info.Id = "..info.Id)
        if (Data.ItemsDeck[tostring(info.Id)]~=nil) then
			    itemNum = Data.ItemsDeck[tostring(info.Id)].Amount
        end
        atlasMini = "itemicon"
        iconMini = Data.ItemsData[tostring(info.Id)].Icon
		  end

		  --icon = Data.ItemsData[tostring(info.Id)].Icon
		  trans:Find("Icon").gameObject:SetActive(false)	--显示通用道具icon
		  trans:Find("Image/Icon").gameObject:SetActive(true)		--隐藏特殊道具icon
    end

  if (isTip == true) then
      --点击在icon上产生tip 
    local listener = NTGEventTriggerProxy.Get(trans.gameObject)
    local callBack = function (self,e)
      --self:contentGotoCup()
      self:showTips(itemName,itemNum,itemDesc,atlasMini,iconMini,isShowNum)
    end
    listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self )

    local callBackUp = function (self,e)
      --self:contentGotoCup()
      self.tip.gameObject:SetActive(false)
    end
    listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callBackUp,self )
  end
end

function AchievementCtrl:showTips(itemName,itemNum,itemDesc,atlasMini,iconMini,isShowNum)
  self.tip.gameObject:SetActive(true)
  -- body
  self.tip.gameObject:SetActive(true)
  local pos = self.camera:ScreenToWorldPoint(Input.mousePosition)
  self.tip.position = Vector3.New(pos.x,pos.y,0)
  self.tip.localPosition = Vector3.New(self.tip.localPosition.x,self.tip.localPosition.y,0)

  --self.tip:FindChild("Main/Name"):GetComponent("UnityEngine.UI.Text").text = itemName
  self.tip:FindChild("Desc"):GetComponent("UnityEngine.UI.Text").text = itemDesc
  self.tip:FindChild("Main/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset(atlasMini,iconMini,"UnityEngine.Sprite")

  local type1 = self.tip:FindChild("Main/Type1")
  local type2 = self.tip:FindChild("Main/Type2")
  if (isShowNum == false) then
    type1.gameObject:SetActive(true)
    type2.gameObject:SetActive(false)
    type1:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = itemName
  elseif (isShowNum == true) then
    type1.gameObject:SetActive(false)
    type2.gameObject:SetActive(true)
    type2:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = itemName
    type2:FindChild("Num"):GetComponent("UnityEngine.UI.Text").text = itemNum
  end
end

function AchievementCtrl:awardPanelTopUiInit(args)
  local mailId = UTGData.Instance().ConfigData["achievement_level_up_mail"].Int
 
  local awardInfo = Data.MailInfosData[tostring(mailId)].Rewards[1]
  local awardName = Data.ItemsData[tostring(awardInfo.AttachmentId)].Name
  local awardNum = awardInfo.AttachmentNum
  local sSub = tostring(awardNum)..tostring(awardName)
  local labLevelAward = self.awardPanel:FindChild("LabLevelAward")
  local sLevelAward = labLevelAward:GetComponent(Text).text
  sLevelAward = string.gsub(sLevelAward,"{0}",sSub)
  labLevelAward:GetComponent(Text).text = sLevelAward

end


function AchievementCtrl:awardPanelListUpdate(args)
  local content = self.awardPanel:FindChild("Scroll View/Viewport/Content")
  for i = 0,content.childCount-1,1 do
    local obj = content:GetChild(i)
    Object.Destroy(obj.gameObject)
  end
  self:awardPanelItemCreate(self.tabAwardCanGet,GAwardCanGet)
  self:awardPanelItemCreate(self.tabAwardNoReach,GAwardNoReach)
  self:awardPanelItemCreate(self.tabAwardHaveGet,GAwardHaveGet)
end

function AchievementCtrl:awardPanelItemCreate(tabTmp,state)
  local content = self.awardPanel:FindChild("Scroll View/Viewport/Content")
  local item = self.awardPanel:FindChild("Item")
  for i,val in ipairs(tabTmp) do
    local newTmp = GameObject.Instantiate(item)
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(i)
    newTmp.transform:SetParent(content)
    newTmp.transform.localPosition = Vector3.zero
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one

    self:awardPanelItemUiSet(newTmp,val,state)
  end
end

function AchievementCtrl:awardPanelItemUiSet(trans,info,state)
  local icon = trans:FindChild("IconPart/Mask/Icon")
  icon:GetComponent(Image).sprite =  NTGResourceController.Instance:LoadAsset("equipicon",info.Icon,"UnityEngine.Sprite")

  local name = trans:FindChild("IconPart/LabName")
  name:GetComponent(Text).text = tostring(info.Level).."级奖励"

  --奖励部分
  local part1 = trans:FindChild("AwardPart/Part1")
  local part2 = trans:FindChild("AwardPart/Part2")
  local tabAward = info.Rewards
  if (#tabAward == 1) then
    ----Debugger.Log("self.tabAward = 1")
    self:awardItemOneSet(part1,tabAward[1],true)
    part1.gameObject:SetActive(true)
    part2.gameObject:SetActive(false)
  elseif (#tabAward == 2) then
    ----Debugger.Log("self.tabAward = 2")
    self:awardItemOneSet(part1,tabAward[1],true)
    self:awardItemOneSet(part2,tabAward[2],true)
    part1.gameObject:SetActive(true)
    part2.gameObject:SetActive(true)
  end

  local bgYellow = trans:FindChild("BgPart/HaveGet")
  local bg = trans:FindChild("BgPart/NotHaveGet")
  local labNoReach = trans:FindChild("GetPart/LabNoReach")
  local labHaveGet = trans:FindChild("GetPart/LabHaveGet")
  local btnGet = trans:FindChild("GetPart/BtnGet")
 
  if (state == GAwardCanGet) then
    bg.gameObject:SetActive(true)
    btnGet.gameObject:SetActive(true)

    --领取按钮
    local callback = function()
      self:onSendServerGetAward(info.Level)
	  end	

    local uiClick=UITools.GetLuaScript(btnGet.transform,"Logic.UICommon.UIClick") 
    uiClick:RegisterClickDelegate(self,callback)    

  elseif (state == GAwardNoReach) then
    bg.gameObject:SetActive(true)
    labNoReach.gameObject:SetActive(true)
  elseif (state == GAwardHaveGet) then
    bgYellow.gameObject:SetActive(true)
    labHaveGet.gameObject:SetActive(true)
  end

end