require "System.Global"
require "Logic.UTGData.UTGData"
require "Logic.UICommon.Static.UITools"
local json = require "cjson"

class("GrowProcessCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"
local Toggle = "UnityEngine.UI.Toggle"


local GCupStartX = 100
local GCupStartY = -100
local GCupSizeX = 100
local GCupSizeY = 150
local GCupDiffY = 148
local GCupDiffX = 354

local GLineStartX = 277
local GLienStartY = -220
local GLineAngle = 24
local GLineDiffY = 148

local GContentStarY = 20
local GViewSizeY = 660

local GIn = 0
local GUp = 1
local GDown = 2

--有等级任务时，该任务对应的三种状态
local GQuestNoFinish = 0
local GQuestFinishNoGet = 1
local GQuestFinishGet = 2

--右下角ui显示状态
local GQuestUiNo = 0 --没有
local GQuestUiPower = 1 --足够强大
local GQuestUiNoReachLevel = 2 --有但是没达到该等级
local GQuestUiNormal = 4 --有

--等级奖励的三种状态
local GLevelAwardNoReach = 0 --没打打等级
local GLevelAwardCanGet = 1 --可以领取
local GLevelAwardHaveGet = 2 --已经领取


local Data = UTGData.Instance()

function GrowProcessCtrl:Awake(this) 
  self.this = this
  self.lineTmp = this.transforms[0] --线条
  self.cupTmp = this.transforms[1] --等级奖杯
  self.contentCup = this.transforms[2]
  self.btnGotoGet = this.transforms[3]
  self.featurePart = this.transforms[4]
  self.awardPart = this.transforms[5]
  self.missionPart = this.transforms[6]
  self.curEffect = this.transforms[7]
  self.selectEffect = this.transforms[8]
  self.tip = this.transforms[9]
  self.camera = GameObject.Find("GameLogic"):GetComponent("Camera")
  
  self:dataInit()
 

  
end

function GrowProcessCtrl:Start()

  UTGDataOperator.Instance:EffectInit(self.curEffect)
  UTGDataOperator.Instance:EffectInit(self.selectEffect)


  self:contentSizeSet()
  self:cupSet(self.tabLevel)
  self:lineSet()


  self:updateGotoBtn()
  self:btnInit()
  self:firstUiSet(self.level)
end

function GrowProcessCtrl:firstUiSet(level)
  local idx = -1
  local val
  for i,v in ipairs(self.tabLevel) do
    if (v.Level == level ) then
      idx = i
      val = v
      break
    end
  end

  self:onClickCup(idx,val)
end

function GrowProcessCtrl:dataInit()
  self.selectLevel = -1
  local tabLevel = UITools.CopyTab(UTGData.Instance().PlayerLevelUpData)
  self.tabLevel = {} --剔除不存在等级奖励的条目 ,不能采用键值对因为要按顺序
  self.tabPos = {}
  self.cupNum = 0
  for i,v in pairs(tabLevel) do
    if (#v.Rewards ~= 0) then
      table.insert(self.tabLevel,v)
    end
  end
  
  self.cupNum = #self.tabLevel --奖杯多少
  --Debugger.Log("GrowProcessCtrl:dataInit self.cupNum = "..self.cupNum)

  local function levelSort(a,b)
    if (a.Level < b.Level) then
      return true
    end
    return false
  end 

  table.sort(self.tabLevel,levelSort)

  for i = 1,self.cupNum,1 do

    local posY = GContentStarY + (i-1)*GCupDiffY
    table.insert(self.tabPos,posY)
  end

  self.level = Data.PlayerData.Level  --玩家当前等级
  self.gotoCupIdx = 0 --表中第四个，并非等级的
  
end

function GrowProcessCtrl:btnInit(args)
  local listener = NTGEventTriggerProxy.Get(self.btnGotoGet.gameObject)
  local callBack = function (self,e)
    --self:contentGotoCup()

    self:firstUiSet(self.gotoLevel)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
end
function GrowProcessCtrl:contentSizeSet(args)
  --起码3或者4个起
  local diffY = 0
  if (self.cupNum % 2 == 0) then
    diffY = GCupDiffY
  end

  local sizeY = GCupStartY*(-1)+GCupDiffY*2*(math.modf(self.cupNum/2)-1)+GCupSizeY + 100
  --Debugger.Log("GrowProcessCtrl:contentSizeSet sizeY = "..sizeY)
  local bgLenX = self.contentCup:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.x
  local bgLenY = self.contentCup:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.y
  local bgLenZ = self.contentCup:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.z
  self.contentCup:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector3.New(bgLenX,sizeY,bgLenZ)
end

function GrowProcessCtrl:cupSet(tabTmp)
  self.tabCupTrans = {}
  for i,v in ipairs(tabTmp) do
    local newTmp = GameObject.Instantiate(self.cupTmp)
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(i)
    newTmp.transform:SetParent(self.contentCup)
    
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one

    local pos = Vector3.New(0,0,0)
    if (i % 2 == 1) then 
      local idx = math.modf(i/2)
      pos.x = GCupStartX
      pos.y = GCupStartY - idx*GCupDiffY*2
    elseif (i %2 == 0) then
      local idx = math.modf(i/2)-1
      pos.x = GCupStartX + GCupDiffX
      pos.y = GCupStartY - idx*GCupDiffY*2 - GCupDiffY
    end
    newTmp.transform.localPosition = pos

    local tabTmp = {}
    tabTmp.idx = i --真实idx，非等级
    tabTmp.trans = newTmp
    self.tabCupTrans[tostring(v.Level)] = tabTmp
    self:cupUiSet(newTmp,v)

    local callback = function(self, e)
      self:onClickCup(i,v)
	  end	
    UITools.GetLuaScript(newTmp.transform,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)

  end
end

function GrowProcessCtrl:lineSet()
  for i = 1,self.cupNum-1,1 do
    local newTmp = GameObject.Instantiate(self.lineTmp)
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(i)
    newTmp.transform:SetParent(self.contentCup)
    
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one

    local pos = Vector3.New(0,0,0)

    pos.x = GLineStartX
    pos.y = GLienStartY - GLineDiffY*(i-1)

    if (i % 2 == 1) then 
      newTmp:Rotate(0, 0, -24);
    elseif (i %2 == 0) then
      newTmp:Rotate(0, 0, 24);
    end

    newTmp.transform.localPosition = pos
  end
end

function GrowProcessCtrl:OnDestroy()
  self.this = nil
  self = nil
end

function GrowProcessCtrl:cupUiSet(trans,info)
  if (info.Level == self.level) then
    local cupBg = trans:FindChild("Cur")
    cupBg.gameObject:SetActive(true)

    --当前等级上有特效
    self.curEffect.gameObject:SetActive(true)
    self.curEffect.transform:SetParent(trans)
    self.curEffect.transform.localRotation = Quaternion.identity
    self.curEffect.transform.localScale = Vector3.one
    self.curEffect.transform.localPosition = Vector3.New(0,0,0)
  elseif (info.Level < self.level) then
    local cupBg = trans:FindChild("NotCur")
    cupBg.gameObject:SetActive(true)
  elseif (info.Level > self.level) then
    local cupBg = trans:FindChild("Lock")
    cupBg.gameObject:SetActive(true)
  end

  local lab = trans:FindChild("Text")
  lab:GetComponent("UnityEngine.UI.Text").text  = "Lv."..info.Level

  local red = trans:FindChild("RedPoint")
  local isWawardHaveGet = self:isCupRed(info.Level)
  if (info.Level <= self.level and isWawardHaveGet == true) then
    red.gameObject:SetActive(true)
  elseif (info.Level > self.level and isWawardHaveGet == false) then
    red.gameObject:SetActive(false)
  end
  
end
  
function GrowProcessCtrl:onClickCup(i,info)
  self.selectLevel = info.Level --当前选中的level
  --Debugger.Log("GrowProcessCtrl:onClickCup level = "..info.Level)
  self:contentGotoCup(i)
  --选中特效
  local cup  =  self.tabCupTrans[tostring(info.Level)].trans
  self.selectEffect.gameObject:SetActive(true)
  self.selectEffect.transform:SetParent(cup)
  self.selectEffect.transform.localRotation = Quaternion.identity
  self.selectEffect.transform.localScale = Vector3.one
  self.selectEffect.transform.localPosition = Vector3.New(0,0,0)

  self:rightUiSet(info)
end

function GrowProcessCtrl:contentGotoCup(idx)
  if (idx == nil) then
    idx = self.gotoCupIdx
  end
  local posGotoY  = self.tabPos[idx]
  local posCur = self.contentCup.localPosition
  local posCurY = self.contentCup.localPosition.y
  if posGotoY + GCupSizeY < posCurY + GCupSizeY then
    posCur.y = posGotoY
    self.contentCup.localPosition = posCur
  elseif  posGotoY + GCupSizeY > posCurY + GViewSizeY or posGotoY > posCurY + GViewSizeY  then
    posCur.y = posGotoY + GCupSizeY - GViewSizeY
    self.contentCup.localPosition = posCur
  end
end

function GrowProcessCtrl:rightUiSet(info)
  
  self:featureUiSet(info)
  self:awardUiSet(info)
  self:missionUiSet(info)
end

--解锁功能ui
function GrowProcessCtrl:featureUiSet(info)
  local level = info.Level
  local labTitle = self.featurePart:FindChild("Title/LabTitle")
  labTitle:GetComponent(Text).text  = "Lv"..info.Level.."解锁功能"

--  local btn1 = self.featurePart:FindChild("Part1/Button")
--  btn1:GetComponent("UnityEngine.UI.Button").interactable = false
  local part1 = self.featurePart:Find("Part1")
  local part2 = self.featurePart:Find("Part2")
  local funcNum = 0
  if (Data.LevelFunc[tostring(level)]~= nil) then
    funcNum = #Data.LevelFunc[tostring(level)]
  end
  
  if (funcNum == 0) then
    part1.gameObject:SetActive(false)
    part2.gameObject:SetActive(false)
  elseif (funcNum == 1) then
    part1.gameObject:SetActive(true)
    part2.gameObject:SetActive(false)
    self:featureOneUiSet(part1,Data.LevelFunc[tostring(level)][1])
  elseif (funcNum == 2) then
    part1.gameObject:SetActive(true)
    part2.gameObject:SetActive(true)
    self:featureOneUiSet(part1,Data.LevelFunc[tostring(level)][1])
    self:featureOneUiSet(part2,Data.LevelFunc[tostring(level)][2])
  end
end

function GrowProcessCtrl:featureOneUiSet(trans,info)
  local level = info.UnlockLevel

  local btn = trans:FindChild("Button")
  if (level <= self.level) then
    btn:GetComponent("UnityEngine.UI.Button").interactable = true
    local listener = NTGEventTriggerProxy.Get(btn.gameObject)
    local callBack = function (self,e)

      local sourceData = Data.SourcesData[tostring(info.SourceId)]
      local panelName = sourceData.UIName
      if (panelName == "GrowGuide") then
        GrowGuideAPI.Instance:gotoToPage(sourceData.UIParam[1])
      else
        local function func()
           GrowGuideAPI.Instance:HideSelf()
        end
        UTGDataOperator.Instance:SoureceGotoUi(info.SourceId,func)
      end
    end
    listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
  elseif (level > self.level) then
    btn:GetComponent("UnityEngine.UI.Button").interactable = false
    local listener = NTGEventTriggerProxy.Get(btn.gameObject)
    local callBack = function (self,e)
      
    end
    listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack, self)
  end

  local lab = trans:FindChild("Text")
  lab:GetComponent(Text).text= info.Desc

  local icon = trans:FindChild("Icon")
  local atlasName = ""
  if (info.Type == 1 or info.Type == 2 or info.Type == 3 or info.Type == 4 or info.Type == 5 or info.Type == 6 or info.Type == 7 or info.Type == 8 ) then
    atlasName = "growupicon"
  elseif (info.Type == 9) then
    atlasName = "playerskillicon"
  end
  icon:GetComponent(Image).sprite = UITools.GetSprite(atlasName,info.Icon)
end

function GrowProcessCtrl:awardUiSet(info)
  local level = info.Level
  local labTitle = self.awardPart:FindChild("Title")
  labTitle:GetComponent(Text).text  = "Lv"..info.Level.."等级奖励"

  local award1 = self.awardPart:FindChild("Part1")
  local award2 = self.awardPart:FindChild("Part2")
  local str = Data.PlayerLevelUpData[tostring(level)]
  local awardNum = #str.Rewards
  if (awardNum == 1) then
    award1.gameObject:SetActive(true)
    award2.gameObject:SetActive(false)
    self:awardOneUiSet(award1,str.Rewards[1])
  elseif (awardNum == 2) then
    award2.gameObject:SetActive(true)
    award1.gameObject:SetActive(true)
    self:awardOneUiSet(award1,str.Rewards[1])
    self:awardOneUiSet(award2,str.Rewards[2])
  end

  --领取状态 判断
  local btnGet = self.awardPart:FindChild("GetPart/BtnGet")
  local labHaveGet = self.awardPart:FindChild("GetPart/LabHaveGet")
  local state = self:levelAwardStateGet(level)
  if (state == GLevelAwardNoReach) then
    btnGet.gameObject:SetActive(false)
    labHaveGet.gameObject:SetActive(false)
  elseif (state == GLevelAwardHaveGet) then
    btnGet.gameObject:SetActive(false)
    labHaveGet.gameObject:SetActive(true)
  elseif (state == GLevelAwardCanGet) then
    btnGet.gameObject:SetActive(true)
    labHaveGet.gameObject:SetActive(false)

    local listener = NTGEventTriggerProxy.Get(btnGet.gameObject)
    local callBack = function (self,e)
      self:onClickLevelAward(questId)
    end
    listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
  end
end

function GrowProcessCtrl:awardOneUiSet(trans,info)
  local icon = trans:FindChild("Image")
  
  local itemData = Data.ItemsData[tostring(info.Id)]
  icon:GetComponent(Image).sprite = UITools.GetSprite("itemicon",itemData.Icon)

  local lab = trans:FindChild("LabNum")
  lab:GetComponent(Text).text = "X"..info.Amount

  local labName = trans:FindChild("LabName")
  labName:GetComponent(Text).text = itemData.Name
end

function GrowProcessCtrl:missionUiSet(info)
  local level = info.Level
  local noMissionPart = self.missionPart:FindChild("NoMission")
  local missionPart = self.missionPart:FindChild("Mission")
  local labEnough = noMissionPart:FindChild("LabEnough")
  local labNoLevel = noMissionPart:FindChild("LabNoLevel")
  local labNoMission = noMissionPart:FindChild("LabNoMission")
  local state = self:rightDownUiStateGet(level)
  if (state == GQuestUiPower) then
    noMissionPart.gameObject:SetActive(true)
    missionPart.gameObject:SetActive(false)
    labEnough.gameObject:SetActive(true)
    labNoLevel.gameObject:SetActive(false)
    labNoMission.gameObject:SetActive(false)
  elseif (state == GQuestUiNoReachLevel) then
    noMissionPart.gameObject:SetActive(true)
    missionPart.gameObject:SetActive(false)
    labEnough.gameObject:SetActive(false)
    labNoLevel.gameObject:SetActive(true)
    labNoMission.gameObject:SetActive(false)
  elseif (state == GQuestUiNo) then
    noMissionPart.gameObject:SetActive(true)
    missionPart.gameObject:SetActive(false)
    labEnough.gameObject:SetActive(false)
    labNoLevel.gameObject:SetActive(false)
    labNoMission.gameObject:SetActive(true)
  elseif (state == GQuestUiNormal) then
    missionPart.gameObject:SetActive(true)
    noMissionPart.gameObject:SetActive(false)
    local labTitle = missionPart:FindChild("Title")
    labTitle:GetComponent(Text).text  = "达到Lv"..info.Level.."可以解锁对应的等级任务"

    local part1 = missionPart:FindChild("Part1")
    local part2 = missionPart:FindChild("Part2")
    local questNum = #Data.LevelQuestByLevel[tostring(level)]
    if (questNum == 1) then
      part1.gameObject:SetActive(true)
      part2.gameObject:SetActive(false)
      self:questUiSet(part1,Data.LevelQuestByLevel[tostring(level)][1])
    elseif (questNum == 2) then
      part1.gameObject:SetActive(true)
      part2.gameObject:SetActive(true)
      self:questUiSet(part1,Data.LevelQuestByLevel[tostring(level)][1])
      self:questUiSet(part2,Data.LevelQuestByLevel[tostring(level)][2])
    end
  end

  
end

--等级奖励  领取了返回true
function GrowProcessCtrl:isLevelAwardHaveGet(level)
  local ret = false
  if (level <= self.level) then
    for i = 1,#Data.PlayerGrowUpProgressDeck.DrewLevelRewards,1 do
      if (Data.PlayerGrowUpProgressDeck.DrewLevelRewards[i] == level ) then
        ret = true
        return ret
      end
    end
  end
  return ret
end

--判断等级奖励的状态
function GrowProcessCtrl:levelAwardStateGet(level)
  local ret = -1
  if (level <= self.level) then
    ret = GLevelAwardCanGet
    for i = 1,#Data.PlayerGrowUpProgressDeck.DrewLevelRewards,1 do
      if (Data.PlayerGrowUpProgressDeck.DrewLevelRewards[i] == level ) then
        ret = GLevelAwardHaveGet
        break
      end
    end
  elseif (level > self.level) then
    ret = GLevelAwardNoReach
  end
  return ret
end

--是否有等级任务(要排除足够强大)
function GrowProcessCtrl:isHaveLevelQuest(level)
  local ret = false
  local isPower = Data.PlayerLevelUpData[tostring(level)].IsPowerful
  if (isPower == false) then
    if (Data.LevelQuestByLevel[tostring(level)] ~= nil) then
      ret = true
    end
  end
  return ret
end

--某个等级任务状态
function GrowProcessCtrl:levelQuestStateGet(questId)
  local ret = -1
  --Debugger.Log("GrowProcessCtrl:levelQuestStateGet questId = "..questId)
  local cur = -1
  if (Data.PlayerLevelQuestDeck[tostring(questId)] ~= nil) then
    cur = Data.PlayerLevelQuestDeck[tostring(questId)].Progress
  else
    cur = 0
  end

  local get = false
  if (Data.PlayerLevelQuestDeck[tostring(questId)] ~= nil) then
    get = Data.PlayerLevelQuestDeck[tostring(questId)].IsDrew    
  end
     
  local max =  Data.LevelQuestById[tostring(questId)].MaxProgress
  if (cur < max) then
    ret = GQuestNoFinish
  elseif (cur >= max and get == false) then
    ret = GQuestFinishNoGet
  elseif (cur >= max and get == true) then
    ret = GQuestFinishGet
  end
  return ret
end

--右下角ui显示形式
function GrowProcessCtrl:rightDownUiStateGet(level)
  local ret = -1
  local isPower = Data.PlayerLevelUpData[tostring(level)].IsPowerful
  local isHaveQuest = self:isHaveLevelQuest(level)
  if (isPower == true) then
    ret = GQuestUiPower
  elseif (isPower == false and isHaveQuest == true and level <= self.level) then
    ret = GQuestUiNormal
  elseif (isPower == false and isHaveQuest == true and level >self.level) then
    ret = GQuestUiNoReachLevel
  elseif (isPower == false and isHaveQuest == false) then
    ret = GQuestUiNo
  end
  return ret
end

--任务条的ui
function GrowProcessCtrl:questUiSet(trans,info)
  local questId = info.Id
  local labDes = trans:FindChild("LabDes")
  labDes:GetComponent(Text).text = info.Desc --描述
  local state = self:levelQuestStateGet(questId)

  local progressPart = trans:FindChild("ProgressPart")
  local labProgress = progressPart:FindChild("LabProgress")
  local labHave = trans:FindChild("LabHave")
  local btnGoto = trans:FindChild("BtnGoto")
  local btnGet = trans:FindChild("BtnGet")
  local cur = 0
  if (Data.PlayerLevelQuestDeck[tostring(questId)] ~= nil) then
    cur = Data.PlayerLevelQuestDeck[tostring(questId)].Progress
  else
    cur = 0
  end

  local max = Data.LevelQuestById[tostring(questId)].MaxProgress
  if (state == GQuestNoFinish) then --未完成前往
    progressPart.gameObject:SetActive(true)
    progressPart.gameObject:SetActive(true)
    --btnGoto.gameObject:SetActive(true)
    btnGet.gameObject:SetActive(false)
    labHave.gameObject:SetActive(false)
    labProgress:GetComponent(Text).text = cur.."/"..max
    if (Data.LevelQuestById[tostring(questId)].SourceId == -1) then
      btnGoto.gameObject:SetActive(false)
    else
      btnGoto.gameObject:SetActive(true)
      local listener = NTGEventTriggerProxy.Get(btnGoto.gameObject)
      local callBack = function (self,e)
        local sourceData = Data.SourcesData[tostring(Data.LevelQuestById[tostring(questId)].SourceId)]
        local panelName = sourceData.UIName
        if (panelName == "GrowGuide") then
          GrowGuideAPI.Instance:gotoToPage(sourceData.UIParam[1])
        else
          local function func()
             GrowGuideAPI.Instance:HideSelf()
          end
          UTGDataOperator.Instance:SoureceGotoUi(sourceData.Id,func)
        end
      end
      listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self )
    end
  elseif (state == GQuestFinishGet) then --已经完成且已经领取
    progressPart.gameObject:SetActive(false)
    btnGoto.gameObject:SetActive(false)
    btnGet.gameObject:SetActive(false)
    labHave.gameObject:SetActive(true)
  elseif (state == GQuestFinishNoGet) then --完成但是没有领取
    progressPart.gameObject:SetActive(true)
    btnGoto.gameObject:SetActive(false)
    btnGet.gameObject:SetActive(true)
    labHave.gameObject:SetActive(false)
    labProgress:GetComponent(Text).text = cur.."/"..max

    local listener = NTGEventTriggerProxy.Get(btnGet.gameObject)
    local callBack = function (self,e)
      self:onClickQuestAward(questId)
    end
    listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
    progressPart.gameObject:SetActive(false)
  end


  --显示任务的icon
  local sprIcon = trans:FindChild("IconBg/SprIcon")
  sprIcon:GetComponent(Image).sprite = NTGResourceController.Instance:LoadAsset("growupicon",tostring(info.Icon),"UnityEngine.Sprite")

  --显示任务的奖励
  local award1 = trans:FindChild("Award1")
  local award2 = trans:FindChild("Award2")
  local awardNum = #info.Rewards
  if (awardNum == 1 ) then
    award1.gameObject:SetActive(true)
    award2.gameObject:SetActive(false)
    self:questAwardUiSet(award1,info.Rewards[1])

  else
    award1.gameObject:SetActive(true)
    award2.gameObject:SetActive(true)
    self:questAwardUiSet(award1,info.Rewards[1])
    self:questAwardUiSet(award2,info.Rewards[2])
  end

end

--任务单个奖励的信息
function GrowProcessCtrl:questAwardUiSet(trans,info)
  local icon = trans:FindChild("Image")
  
  local itemData = Data.ItemsData[tostring(info.Id)]
  icon:GetComponent(Image).sprite = UITools.GetSprite("itemicon",itemData.Icon)

  local lab = trans:FindChild("LabNum")
  lab:GetComponent(Text).text = "X"..info.Amount

  --点击在icon上产生tip 
  local listener = NTGEventTriggerProxy.Get(trans.gameObject)
  local callBack = function (self,e)
    --self:contentGotoCup()
    self:showTips(info.Id)
  end
  listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self )

  local callBackUp = function (self,e)
    --self:contentGotoCup()
    self.tip.gameObject:SetActive(false)
  end
  listener.onPointerUp = NTGEventTriggerProxy.PointerEventDelegateSelf(callBackUp,self )
end

function GrowProcessCtrl:showTips(rewardId)
  self.tip.gameObject:SetActive(true)
  -- body
  local data = UTGData.Instance().ItemsData[tostring(rewardId)]
  self.tip.gameObject:SetActive(true)
  local pos = self.camera:ScreenToWorldPoint(Input.mousePosition)
  --local pos = Input.mousePosition
  self.tip.position = Vector3.New(pos.x,pos.y,0)
  self.tip.localPosition = Vector3.New(self.tip.localPosition.x,self.tip.localPosition.y,0)

  self.tip:FindChild("Main/Name"):GetComponent("UnityEngine.UI.Text").text = data.Name
  self.tip:FindChild("Desc"):GetComponent("UnityEngine.UI.Text").text = data.Desc
  self.tip:FindChild("Main/Icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("itemicon",tostring(data.Icon),"UnityEngine.Sprite")
end


function GrowProcessCtrl:onClickQuestAward(questId)
  --Debugger.Log("GrowProcessCtrl:onClickQuestAward questId = "..questId)
  local serverRequest = NetRequest.New()
  serverRequest.Content = JObject.New(JProperty.New("Type","RequestDrawLevelQuest"),
                                      JProperty.New("LevelQuestId",questId))
  serverRequest.Handler = TGNetService.NetEventHanlderSelf(GrowProcessCtrl.onServerQuestAward,self)
  TGNetService.GetInstance():SendRequest(serverRequest)
end

function GrowProcessCtrl:onServerQuestAward(e)
  --Debugger.Log("GrowProcessCtrl:onServerQuestAward ")
  if e.Type == "RequestDrawLevelQuest" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if (result == 1) then
      --Debugger.Log("GrowProcessCtrl:onServerQuestAward")
      --更新任务ui
--      local info ={}
--      info.Level = self.selectLevel
--      self:missionUiSet(info)
    end
    return true
  end
  return false
end

function GrowProcessCtrl:onClickLevelAward(args)
  local serverRequest = NetRequest.New()
  serverRequest.Content = JObject.New(JProperty.New("Type","RequestDrawLevelReward"),
                                      JProperty.New("Level",self.selectLevel))
  serverRequest.Handler = TGNetService.NetEventHanlderSelf(GrowProcessCtrl.onServerLevelAward,self)
  TGNetService.GetInstance():SendRequest(serverRequest)
end

function GrowProcessCtrl:onServerLevelAward(e)
  if e.Type == "RequestDrawLevelReward" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if (result == 1) then
      --Debugger.Log("GrowProcessCtrl:onServerLevelAward")
      --更新等级奖励ui
--      local info ={}
--      info.Level = self.selectLevel
--      self:awardUiSet(info)
    end
    return true
  end
  return false
end

function GrowProcessCtrl:updateMissionUi()
  local info ={}
  info.Level = self.selectLevel
  self:missionUiSet(info)
  self:updateCupRed(self.selectLevel)
  self:updateGotoBtn()
  GrowGuideAPI.Instance:updateGrowProgressRedPoint()
end

function GrowProcessCtrl:updateLevelAwardUi()
  local info ={}
  info.Level = self.selectLevel
  self:awardUiSet(info)
  self:updateCupRed(self.selectLevel)
  self:updateGotoBtn()
  GrowGuideAPI.Instance:updateGrowProgressRedPoint()
end

function GrowProcessCtrl:updateCupRed(level)
  local trans = self.tabCupTrans[tostring(level)].trans
  local red = trans:FindChild("RedPoint")
  local isRed = self:isCupRed(level)
  if (level <= self.level and isRed == true) then
    red.gameObject:SetActive(true)
  elseif (isRed == false) then --领完奖也需要
    red.gameObject:SetActive(false)
  end
end
function GrowProcessCtrl:isCupRed(level)
  local awardState = self:levelAwardStateGet(level)

  local isQuestAward = false
  if (Data.LevelQuestByLevel[tostring(level)] ~= nil) then
    local tabQuest = Data.LevelQuestByLevel[tostring(level)]
    for i,v in pairs(tabQuest) do 
      local questState = self:levelQuestStateGet(v.Id)
      if questState == GQuestFinishNoGet then
        isQuestAward = true
        break
      end
    end
  end
  if (isQuestAward == true or awardState == GLevelAwardCanGet) then
    return true
  end
  return false
end

function GrowProcessCtrl:firstAwardCupGet(args)
  local gotoLevel = -1
  for i,val in ipairs(self.tabLevel) do
    local isAward = self:isCupRed(val.Level)
    if isAward == true then
        gotoLevel = val.Level
      break
    end
  end

  self.gotoCupIdx = self.tabCupTrans[tostring(gotoLevel)].idx
  self.gotoLevel = gotoLevel
end

function GrowProcessCtrl:isExistAwardCup(args)
  local isAward = false
  for i,val in ipairs(self.tabLevel) do
    isAward = self:isCupRed(val.Level)
    if isAward == true then
      break
    end
  end
  return isAward
end

function GrowProcessCtrl:updateGotoBtn(args)
  local isAnyAward = self:isExistAwardCup()
  if (isAnyAward == true) then
    self:firstAwardCupGet()
    --Debugger.Log("firstAwardCupGet = "..self.gotoCupIdx)
    self.btnGotoGet.gameObject:SetActive(true)
  elseif (isAnyAward == false) then
    self.btnGotoGet.gameObject:SetActive(false)
  end
end

function GrowProcessCtrl:contentCupSetActeive(active)
  self.contentCup.gameObject:SetActive(active)
end