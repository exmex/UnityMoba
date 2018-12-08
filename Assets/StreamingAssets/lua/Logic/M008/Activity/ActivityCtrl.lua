require "System.Global"
require "Logic.UTGData.UTGData"

class("ActivityCtrl")
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"
local Toggle = "UnityEngine.UI.Toggle"

local json = require "cjson"
local Data = UTGData.Instance()

local GProCanGet = 0 --可以领
local GProNoGet = 1 --不可领
local GProHaveGet = 2 --已经领

local GTimeCanGet = 0 --时间可以领取
local GTimeNoGet = 1 --时间未到
local GTimeHaveGet = 2 --时间已经领取

local GExCanGet = 0 --兑换可以
local GExNoGet = 1 --兑换不可

local GOpenCanGet = 0 --开服可以领
local GOpenNoGet = 1 --不可领
local GOpenHaveGet = 2 --已经领

function ActivityCtrl:Awake(this) 
  self.this = this
  self.leftItem = this.transforms[0]
  self.leftContent = this.transforms[1]
  self.btnDetail =this.transforms[2] 
  self.btnReturn = this.transforms[3]
  self.labDesTitle = this.transforms[4]
  self.labMiniDes = this.transforms[5]
  self.labDes = this.transforms[6]
  self.scrollDes = this.transforms[7]
  self.labTime = this.transforms[8]
  self.awardPart = this.transforms[9]
  self.questItem = this.transforms[10]
  self.awardItem = this.transforms[11]
  self.tip = this.transforms[12]
  self.exQuestItem = this.transforms[13]
  self.btnDetail.gameObject:SetActive(true)
  self.camera = GameObject.Find("GameLogic"):GetComponent("Camera")
end

function ActivityCtrl:Start()

  self:dataInit()
  
  self:btnInit()
  self:onRequestActivity()

end

function ActivityCtrl:OnDestroy()
  self.this = nil
  self = nil
end

function ActivityCtrl:dataInit(args)
  self.tabActi = {}
  self:readDeckGet()
  self.isDataOK = false
end
--创建左边
function ActivityCtrl:leftItemCreate(tabTmp)
  for i = 0, self.leftContent.childCount-1,1 do
    local obj = self.leftContent:GetChild(i)
    Object.Destroy(obj.gameObject)
  end
  for i,v in ipairs(tabTmp) do
    local newTmp = GameObject.Instantiate(self.leftItem)
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(v.Id)
    newTmp.transform:SetParent(self.leftContent)
    newTmp.transform.localPosition = Vector3.zero
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one

    self:leftItemUiSet(newTmp,v)
  end
end

function ActivityCtrl:leftItemUiSet(trans,info)
  if (info.TagColor ~= -1) then
    local tagColor = trans:FindChild("TipPart/"..tostring(info.TagColor))
    tagColor.gameObject:SetActive(true)
    local tagName = tagColor:FindChild("Text")
    tagName:GetComponent(Text).text = info.TagName
  end
  
  local tabName = trans:FindChild("LeftName")
  tabName:GetComponent(Text).text = info.TabName
  local red = trans:FindChild("Red")
  local isRed = self:isLeftItemRed(info)
  red.gameObject:SetActive(isRed)


   --监听自己的点击事件
  local listener = trans.gameObject
  local strTab = {}
  strTab.info = info
  strTab.name = trans.name

  UITools.GetLuaScript(listener,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.detailUiSet,strTab)

end

--点击左边，UI设置
function ActivityCtrl:detailUiSet(strTab)
  --记录当前选中页
  if (self.selectTab == nil) then
    self.selectTab = strTab.info.Id
  elseif (self.selectTab ~= strTab.info.Id) then
    self.selectTab = strTab.info.Id
  elseif (self.selectTab == strTab.info.Id) then
    return
  end
  
  self:readDeckWrite(tonumber(strTab.name))--阅读了新的活动
  --刷新红点
  self:oneRedUpdate(strTab.info.Id)
  self:leftWhiteSet(strTab.name)
  self:rightUiSet(strTab.info)
  self:totalRedUpdate()
  UTGDataOperator.Instance:actiRedUpdate()
  self.labDesTitle:GetComponent(Text).text = "活动介绍"
  --self:onRequestRead(strTab.info.Id)
end

function ActivityCtrl:leftWhiteSet(name)
  Debugger.Log("ActivityCtrl:leftWhiteSet = "..name)
  for i = 0,self.leftContent.childCount-1,1 do
    local obj = self.leftContent:GetChild(i);
    if obj.name == name then
      obj:FindChild("white").gameObject:SetActive(true)
    else
      obj:FindChild("white").gameObject:SetActive(false)
    end
  end
end

function ActivityCtrl:rightUiSet(info)
  --时间
  local sTime = ""
  if (info.Type == 1) then
    sTime = "永久"
  elseif (info.Type == 2 or info.Type == 3 or info.Type  == 4) then
    local sStartTime = UTGDataOperator.Instance:timeStringGet(info.StartTime)
    local sEndTime = UTGDataOperator.Instance:timeStringGet(info.EndTime)
    sTime = sStartTime .. " ~ "..sEndTime
  end
  self.labTime:GetComponent(Text).text = sTime

  self.labMiniDes:GetComponent(Text).text = info.Introduction
  self.labDes:GetComponent(Text).text = info.Desc

  if (info.Introduction == "" and info.Desc ~= "" and #info.ActivityQuests == 0) then
    self.labMiniDes.gameObject:SetActive(false)
    self.scrollDes.gameObject:SetActive(true)
    self.awardPart.gameObject:SetActive(false)
    self.btnDetail.gameObject:SetActive(false)
    self.btnReturn.gameObject:SetActive(false)
  elseif (info.Introduction ~= "" and info.Desc ~= "" and #info.ActivityQuests > 0) then
    self.labMiniDes.gameObject:SetActive(true)
    self.scrollDes.gameObject:SetActive(false)
    self.awardPart.gameObject:SetActive(true)
    self.btnDetail.gameObject:SetActive(true)
    self.btnReturn.gameObject:SetActive(false)
  elseif (info.Introduction ~= "" and info.Desc == "" and #info.ActivityQuests > 0) then
    self.labMiniDes.gameObject:SetActive(true)
    self.scrollDes.gameObject:SetActive(false)
    self.awardPart.gameObject:SetActive(true)
    self.btnDetail.gameObject:SetActive(false)
    self.btnReturn.gameObject:SetActive(false)
  end

  --显示奖励项目
  --self:questItemCreate(info.ActivityQuests)
  for i = 0,self.awardPart.childCount-1,1 do
    local obj = self.awardPart:GetChild(i)
    Object.Destroy(obj.gameObject)
  end
  if (#info.ActivityQuests > 0) then
    Debugger.Log("#info.ActivityQuests > 0) create")
    self:questItemOrderCreate(info.ActivityQuests)
    --self:questItemCreate(info.ActivityQuests)
  end
end

--按照可以领取，去完成，已经领取排序
function ActivityCtrl:questItemOrderCreate(info)
  if (info[1].Type == 1) then
    local tabCan = {}
    local tabNo = {}
    local tabHave = {}
    for i,v in ipairs(info) do
      local state = UTGDataOperator.Instance:progressStateGet(v)
      if (state == GProCanGet) then
        table.insert(tabCan,v)
      elseif (state == GProNoGet) then
        table.insert(tabNo,v)
      elseif (state == GProHaveGet) then
        table.insert(tabHave,v)
      end
    end 
    Debugger.Log("ActivityCtrl:questItemOrderCreate  "..#tabCan.."  "..#tabNo.."  "..#tabHave )
    self:questItemCreate(tabCan)
    self:questItemCreate(tabNo)
    self:questItemCreate(tabHave)
  elseif (info[1].Type == 2) then
    local tabCan = {}
    local tabNo = {}
    local tabHave = {}
    for i,v in ipairs(info) do
      local state = UTGDataOperator.Instance:timeStateGet(v)
      if (state == GTimeCanGet) then
        table.insert(tabCan,v)
      elseif (state == GTimeNoGet) then
        table.insert(tabNo,v)
      elseif (state == GTimeHaveGet) then
        table.insert(tabNo,v)
      end
    end
    self:questItemCreate(tabCan)
    self:questItemCreate(tabNo)
    self:questItemCreate(tabHave)
  elseif (info[1].Type == 3) then
    self:questItemCreate(info)
    --self:ecQuestItemCreate(info)
  elseif (info[1].Type == 4) then
    local tabCan = {}
    local tabNo = {}
    local tabHave = {}
    for i,v in ipairs(info) do
      local state = UTGDataOperator.Instance:openStateGet(v)
      if (state == GProCanGet) then
        table.insert(tabCan,v)
      elseif (state == GProNoGet) then
        table.insert(tabNo,v)
      elseif (state == GProHaveGet) then
        table.insert(tabHave,v)
      end
    end 
    Debugger.Log("ActivityCtrl:questItemOrderCreate  "..#tabCan.."  "..#tabNo.."  "..#tabHave )
    self:questItemCreate(tabCan)
    self:questItemCreate(tabNo)
    self:questItemCreate(tabHave)
  end

end

function ActivityCtrl:ecQuestItemCreate(info)
  for i,v in ipairs(info) do
    local newTmp = GameObject.Instantiate(self.exQuestItem)
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(v.Id)
    newTmp.transform:SetParent(self.awardPart)
    newTmp.transform.localPosition = Vector3.zero
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one

    self:questUiSet(newTmp,v)
  end
end

function ActivityCtrl:questItemCreate(info)
  Debugger.Log("ActivityCtrl:questItemCreate(info)")
  for i,v in ipairs(info) do
    local newTmp
    if (v.Type == 1 or v.Type == 2 or v.Type == 4) then
      newTmp = GameObject.Instantiate(self.questItem)
    elseif (v.Type == 3) then
      newTmp = GameObject.Instantiate(self.exQuestItem)
    end
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(v.Id)
    newTmp.transform:SetParent(self.awardPart)
    newTmp.transform.localPosition = Vector3.zero
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one

    self:questUiSet(newTmp,v)
  end
end

function ActivityCtrl:questUiSet(trans,info)
  --显示条目上的奖励
  self:awardItemCreate(trans,info.Rewards)

  --显示des
  local labDes = trans:FindChild("GetPart/LabDes")
  local sDes = ""
  if (info.Type == 1) then --进度型要读取玩家的进度
--    if (tonumber(info.Param[3]) == 1) then
--      local max = tonumber(info.Param[2])
--      local cur = 0
--      if (Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
--        cur = Data.PlayerActivityQuestDeck[tostring(info.Id)].Param[1]
--      end
--      sDes = info.Desc.." "..cur.."/"..max
--    elseif (tonumber(info.Param[3]) == 0) then
--      sDes = info.Desc
--    end
    local max = tonumber(info.Param[2])
    local cur = 0
    if (Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
      cur = Data.PlayerActivityQuestDeck[tostring(info.Id)].Param[1]
    end
    sDes = info.Desc
    sDes = string.gsub(sDes,"{0}",cur)
    sDes = string.gsub(sDes,"{1}",max)

  elseif (info.Type == 2) then
    sDes = info.Desc
  elseif (info.Type == 3) then
    if (tonumber(info.Param[3]) == -1) then
      sDes = info.Desc
    else
      local haveEx = 0
      if (Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
        haveEx = Data.PlayerActivityQuestDeck[tostring(info.Id)].Param[1]
      end
      local maxEx = tonumber(info.Param[3])
      --sDes = "限制兑换次数"..haveEx.."/"..maxEx
      sDes = info.Desc
      sDes = string.gsub(sDes,"{0}",haveEx)
      sDes = string.gsub(sDes,"{1}",maxEx)
    end
    self:exItemCreate(trans,info)
    self:exNumShow(trans,info)
  elseif (info.Type == 4) then
    local max = tonumber(info.Param[3])
    local cur = 0
    if (Data.PlayerActivityQuestDeck[tostring(info.Id)] ~= nil) then
      cur = Data.PlayerActivityQuestDeck[tostring(info.Id)].Param[1]
    end
    sDes = info.Desc
    sDes = string.gsub(sDes,"{0}",cur)
    sDes = string.gsub(sDes,"{1}",max)
  end
  labDes:GetComponent(Text).text = sDes

  --显示按钮状态
  self:btnUiSet(trans,info)
end

--兑换数量显示
function ActivityCtrl:exNumShow(trans,info)
  local labOwn = trans:FindChild("LabOwn")
  local labNeed = trans:FindChild("LabMax")
  local ownNum = 0
  if (Data.ItemsDeck[tostring(info.Param[1])] ~= nil) then
    ownNum = Data.ItemsDeck[tostring(info.Param[1])].Amount
  end
  local needNum = tonumber(info.Param[2])
  labNeed:GetComponent(Text).text = "/"..needNum
  labOwn:GetComponent(Text).text = ownNum
  if (ownNum < needNum) then
    labOwn:GetComponent(Text).color = Color.New(255/255, 1/255, 1/255, 1)
  elseif (ownNum >= needNum) then
  end
end
--兑换item显示
function ActivityCtrl:exItemCreate(trans,info)
  local item = trans:FindChild("ExItem")
  local itemInfo = {}
  itemInfo.Id = tonumber(info.Param[1])
  itemInfo.Type = 4
  itemInfo.Amount = tonumber(info.Param[2])
  self:awardUiSet(item,itemInfo,true,false)
end
--按钮状态设定，要重新绑定按钮的响应事件
function ActivityCtrl:btnUiSet(trans,info)
  local btnNo = trans:FindChild("GetPart/BtnNo")
  local labNo = btnNo:FindChild("Text"):GetComponent(Text)
  local btnGet = trans:FindChild("GetPart/BtnGet")
  local labGet = btnGet:FindChild("Text"):GetComponent(Text)
  local haveGet = trans:FindChild("GetPart/HaveGetPart")

  btnNo.gameObject:SetActive(false)
  btnGet.gameObject:SetActive(false)
  haveGet.gameObject:SetActive(false)
  btnNo:GetComponent("UnityEngine.UI.Button").interactable = true 
  if (info.Type == 1) then --进度型
    local state = UTGDataOperator.Instance:progressStateGet(info)
    if (state == GProCanGet) then
      self:btnGetSet(btnGet,info)
    elseif (state == GProNoGet) then
      if (info.SourceId ~= -1) then
        self:btnGotoSet(btnNo,info)
      elseif (info.SourceId == -1) then
        self:btnGetFalseSet(btnGet,info)
      end
    elseif (state == GProHaveGet) then
      haveGet.gameObject:SetActive(true)
    end
  elseif (info.Type == 2) then --时限型
    local state = UTGDataOperator.Instance:timeStateGet(info)
    if (state == GTimeCanGet) then
      self:btnGetSet(btnGet,info)
    elseif (state == GProNoGet) then
      self:btnTimeNoSet(btnNo,info)
    elseif (state == GTimeHaveGet) then
      haveGet.gameObject:SetActive(true)
    end
  elseif (info.Type == 3) then --兑换
    local state = UTGDataOperator.Instance:exchangeStateGet(info)
    if (state == GExCanGet) then
      self:btnGetSet(btnGet,info)
    elseif (state == GExNoGet) then
      self:btnExNoSet(btnGet,info)
    end
  elseif (info.Type == 4) then --开服
    local state = UTGDataOperator.Instance:openStateGet(info)
    if (state == GProCanGet) then
      self:btnGetSet(btnGet,info)
    elseif (state == GProNoGet) then
      if (info.SourceId ~= -1) then
        self:btnGotoSet(btnNo,info)
      elseif (info.SourceId == -1) then
        self:btnGetFalseSet(btnGet,info)
      end
    elseif (state == GProHaveGet) then
      haveGet.gameObject:SetActive(true)
    end
  end 
end

--领取按钮设置
function ActivityCtrl:btnGetSet(trans,info)
  trans.gameObject:SetActive(true)
  local lab = trans:FindChild("Text"):GetComponent(Text)
  if (info.Type == 1 or info.Type == 2 or info.Type == 4) then
    lab.text = "领取"
  elseif (info.Type == 3) then
    lab.text = "兑换"
  end
  local listener = NTGEventTriggerProxy.Get(trans.gameObject)
  local callBack = function (self,e)
    self:onRequestGetAward(info.Id)
  end
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
end

--不可领取设置
function ActivityCtrl:btnGetFalseSet(trans,info)
  trans.gameObject:SetActive(true)
  local lab = trans:FindChild("Text"):GetComponent(Text)
  if (info.Type == 1 or info.Type == 2 or info.Type == 4) then
    lab.text = "领取"
  elseif (info.Type == 3) then
    lab.text = "兑换"
  end
  trans:GetComponent("UnityEngine.UI.Button").interactable = false 
  local lab = trans:FindChild("Text")
  lab:GetComponent(Text).color = Color.New(200/255, 200/255, 200/255, 1)
  local listener = NTGEventTriggerProxy.Get(trans.gameObject)
  local callBack = function (self,e)
  end
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
end


--不可兑换按钮
function ActivityCtrl:btnExNoSet(trans,info)
  trans.gameObject:SetActive(true)
  local lab = trans:FindChild("Text"):GetComponent(Text)

  if (info.Type == 3) then
    lab.text = "兑换"
  end
  trans:GetComponent("UnityEngine.UI.Button").interactable = false 
  local lab = trans:FindChild("Text")
  lab:GetComponent(Text).color = Color.New(200/255, 200/255, 200/255, 1)
  local listener = NTGEventTriggerProxy.Get(trans.gameObject)
  local callBack = function (self,e)
  end
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
end
--时间未到按钮设置
function ActivityCtrl:btnTimeNoSet(trans,info)
  trans.gameObject:SetActive(true)
  local lab = trans:FindChild("Text"):GetComponent(Text)
  if (info.Type == 2) then
    lab.text = "时间未到"
  end
  trans:GetComponent("UnityEngine.UI.Button").interactable = false 
  local lab = trans:FindChild("Text")
  lab:GetComponent(Text).color = Color.New(200/255, 200/255, 200/255, 1)
  local listener = NTGEventTriggerProxy.Get(trans.gameObject)
  local callBack = function (self,e)
  end
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
end

--前往按钮设置
function ActivityCtrl:btnGotoSet(trans,info)
  trans.gameObject:SetActive(true)
  local lab = trans:FindChild("Text"):GetComponent(Text)
  lab.text = "去完成"
  local listener = NTGEventTriggerProxy.Get(trans.gameObject)
  local callBack = function (self,e)
    local function func()
      ActivityNoticeApi.Instance:destroy()
    end
    UTGDataOperator.Instance:SoureceGotoUi(info.SourceId,func)
  end
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
end

--活动上的奖励
function ActivityCtrl:awardItemCreate(trans,info)
  for i,v in ipairs(info) do
    local newTmp = GameObject.Instantiate(self.awardItem)
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(v.Id)
    local awardPart = trans:FindChild("AwardPart")
    newTmp.transform:SetParent(awardPart)
    newTmp.transform.localPosition = Vector3.zero
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one

    self:awardUiSet(newTmp,v,true)
  end
end

--已读，是否有奖励
function ActivityCtrl:isLeftItemRed(info)
  local ret = false
  local isHaveRead = self:isHaveRead(info.Id)
  --Debugger.Log("isHaveRead = false")
  local isCanGet = self:isCanGet(info)
  if (isHaveRead == false or isCanGet == true) then
  --if (isCanGet == true) then
    ret = true
    Debugger.Log("isHaveRead = true")
  end
  return ret
end

function ActivityCtrl:btnInit(args)
  local listener = NTGEventTriggerProxy.Get(self.btnDetail.gameObject)
  local callBack = function (self,e)
    self:onBtnDetailDeal(true)
  end
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)

  listener = NTGEventTriggerProxy.Get(self.btnReturn.gameObject)
  callBack = function (self,e)
    self:onBtnDetailDeal(false)
  end
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
end

function ActivityCtrl:onBtnDetailDeal(isDetail)
    self.btnDetail.gameObject:SetActive(not isDetail)
    self.btnReturn.gameObject:SetActive(isDetail)
    if (isDetail == true) then
      self.labDesTitle:GetComponent(Text).text = "活动详情"
    elseif (isDetail == false) then
      self.labDesTitle:GetComponent(Text).text = "活动介绍"
    end
    self.labMiniDes.gameObject:SetActive(not isDetail)
    self.scrollDes.gameObject:SetActive(isDetail)
    self.awardPart.gameObject:SetActive(not isDetail)
end


function ActivityCtrl:onRequestActivity()
  Debugger.Log("onRequestActivity")
  local serverRequest = NetRequest.New()
  serverRequest.Content = JObject.New(JProperty.New("Type","RequestCurrentActivity"))
  serverRequest.Handler = TGNetService.NetEventHanlderSelf(ActivityCtrl.onGetActivity,self)
  TGNetService.GetInstance():SendRequest(serverRequest)
end

function ActivityCtrl:onGetActivity(e)
  if e.Type == "RequestCurrentActivity" then
    Debugger.Log("RequestCurrentActivity")
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if (result == 1) then
      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
        WaitingPanelAPI.Instance:DestroySelf()
      end
      ActivityNoticeApi.Instance:ShowSelf()
      self.isDataOK = true
      self.tabActi = json.decode(e.Content:get_Item("Activities"):ToString())
      self:actiSort()
      --刷新面板
      self:panelUpdate()
      self:questWithActiMapInit()
      self:tabActiByIdInit()
      self:totalRedUpdate()
      UTGDataOperator.Instance:tabActiQuestCreate(self.tabActi)
      --显示第一个
        local strTab = {}
        strTab.info = self.tabActi[1]
        strTab.name = tostring(self.tabActi[1].Id)
      self:detailUiSet(strTab)
    end
    return true
  end
  return false
end

--排序活动
function ActivityCtrl:actiSort()
  --先按order排序
  local function orderSort(a,b)
    if  a.Order < b.Order then
     return true
    end
    return false
  end
  table.sort(self.tabActi,orderSort)

  --领取完的排在最后面
  local function haveGetAllSort(a,b)
    local isA = self:isOneGetAllAward(a)
    local isB = self:isOneGetAllAward(b)
    if (isA == false and isB == true) then
      return true
    end
    return false
  end
  table.sort(self.tabActi,haveGetAllSort)

  
end

function ActivityCtrl:tabActiByIdInit()
  self.tabActiById = {}
  for i,v in ipairs(self.tabActi) do
    self.tabActiById[tostring(v.Id)] = v
  end
end

--questID找到actiId
function ActivityCtrl:questWithActiMapInit()
  self.tabQuest = {}
  for i,v in ipairs(self.tabActi) do
    for j,val in ipairs(v.ActivityQuests) do
      self.tabQuest[tostring(val.Id)] = val.ActivityId
    end
  end
end

function ActivityCtrl:panelUpdate()
  self:leftItemCreate(self.tabActi)
end

--活动本地存档获取
function ActivityCtrl:readDeckGet(args)
  self.tabReadDeck = {}
  local path = NTGResourceController.GetDataPath("GlobalData")
  local LocalE = ""
  self.lastUserName = ""
  local wantData = {}
  if File.Exists(path .. "GlobalData.ini") == true then
      local jo = NTGResourceController.ReadAllText(path .. "GlobalData.ini")
      wantData = json.decode(jo)
      self.lastUserName = wantData.LastUsername
  end
  if Directory.Exists(path) and File.Exists(path .. "ActivityData.ini") then
    localE = json.decode(NTGResourceController.ReadAllText(path .. "ActivityData.ini"))
    self.tabReadDeck = localE[tostring(self.lastUserName)]
  end

  if (self.tabReadDeck == nil) then
    self.tabReadDeck = {}
  end
end

--判断当前活动是否已读
function ActivityCtrl:isHaveRead(id)
  local ret = false
  for i, v in ipairs(self.tabReadDeck) do
    if (v == id) then
      ret = true
      break
    end
  end
  return ret
end

--新增已经读取的新的活动
function ActivityCtrl:readDeckWrite(id)
  local retWriteOk = false 

  if (#self.tabReadDeck == 0) then
    retWriteOk = true
  elseif (#self.tabReadDeck > 0) then
    retWriteOk = true
    for i,v in ipairs(self.tabReadDeck) do
      if  v == id then
        retWriteOk = false
        break
      end
    end
  end

  if (retWriteOk == false) then
    return
  end

  table.insert(self.tabReadDeck,id)
  local path = NTGResourceController.GetDataPath("GlobalData") .. "ActivityData.ini"
  local stream = {[tostring(self.lastUserName)] = self.tabReadDeck}  --tostring(self.lastUserName)
  --local stream = {ActivityHaveReadId = self.tabReadDeck} 
  NTGResourceController.WriteAllText(path,json.encode(stream))
end

function ActivityCtrl:awardUiSet(trans,info,isTip,isShowNumFlg)
  
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
      trans:Find("Text").gameObject:SetActive(true)
      trans:Find("Text"):GetComponent(Text).text = num
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
			  itemNum = Data.PlayerData.Coin --.. "个"
        atlasMini = "resourceicon"
        iconMini = Data.ItemsData[tostring(info.Id)].Icon
		  elseif itemData.Type == 14 then
			  trans:Find("Image/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(info.Id)].Icon)
			  trans:Find("Image/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(74,74)
			  itemDesc = itemData.Desc
			  itemNum = Data.PlayerData.Gem --.. "个"
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
			  itemNum = Data.PlayerData.RunePiece --.. "个"
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

  if (isShowNumFlg == false) then
    trans:Find("Text").gameObject:SetActive(false)
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

function ActivityCtrl:showTips(itemName,itemNum,itemDesc,atlasMini,iconMini,isShowNum)
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

function ActivityCtrl:onRequestGetAward(id)
  Debugger.Log("onRequestGetAward = "..id)
  local serverRequest = NetRequest.New()
  serverRequest.Content = JObject.New(JProperty.New("Type","RequestDrawActivityReward"),
                                      JProperty.New("ActivityQuestId",id))
  serverRequest.Handler = TGNetService.NetEventHanlderSelf(ActivityCtrl.onGetAward,self)
  TGNetService.GetInstance():SendRequest(serverRequest)
end

function ActivityCtrl:onGetAward(e)
  if e.Type == "RequestDrawActivityReward" then
    Debugger.Log("RequestDrawActivityReward")
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if (result == 1) then
      --刷新面板

    elseif (result == 4866 ) then
      GameManager.CreatePanel("SelfHideNotice")
      if SelfHideNoticeAPI ~= nil then
        SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("活动任务未完成")
      end
    elseif (result == 4867) then
      GameManager.CreatePanel("SelfHideNotice")
      if SelfHideNoticeAPI ~= nil then
        SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在活动时间中")
      end
    elseif (result == 4868) then
      GameManager.CreatePanel("SelfHideNotice")
      if SelfHideNoticeAPI ~= nil then
        SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经领取过活动任务奖励")
      end
    end
    return true
  end
  return false
end

--当领取时，activity本身不会改变，如果是在当前选中活动，直接更新它的详细内容
function ActivityCtrl:updateSelectPageWhenGet(questId)
  Debugger.Log("ActivityCtrl:updateSelectPageWhenGet1111")
  if (self.isDataOK == false) then
    return
  end
  if (self:isQuestBelongSelect(questId) == false) then
    Debugger.Log("ActivityCtrl:updateSelectPageWhenGet22222")
    return
  end

  --是否刷新左边面板变化
  local actiId = self.tabQuest[tostring(questId)]
  local actiInfo = self.tabActiById[tostring(actiId)]--self:actiInfoGetById(actiId)
  local isGetAll = self:isOneGetAllAward(actiInfo)

  self:oneRedUpdate(actiId)

  if (isGetAll == true) then
    self:actiSort()
    self:panelUpdate()
  end

  local selectTmp = self.selectTab
  self.selectTab = nil
  local strTab = {}
  strTab.name = tostring(selectTmp)
  strTab.info = self:actiInfoGetById(selectTmp)
  self:detailUiSet(strTab)

end

--时间变化，当前活动是时间的话，且传来开启或关闭的消息
function ActivityCtrl:updateSelectPageWhenTime(actiInfo,Action)
  if (self.isDataOK == false) then
    return
  end
  if (Action ~= 2) then
    return
  end

  --活动信息更新
  local idx = self:actiIdxGetById(actiInfo.ActivityId)

  local idxQuest = 0
  for i, v in ipairs(self.tabActi[idx].ActivityQuests) do
    if (v.Id == actiInfo.Id) then
      idxQuest = i
      break
    end
  end
  self.tabActi[idx].ActivityQuests[idxQuest] = actiInfo

  if (idx == self.selectTab) then
    local selectTmp = self.selectTab
    self.selectTab = nil
    local strTab = {}
    strTab.name = tostring(actiInfo.Id)
    strTab.info = actiInfo
    self:detailUiSet(strTab)
  end
end

function ActivityCtrl:actiInfoGetById(id)
  local val
  for i, v in ipairs(self.tabActi) do
    if (v.Id == id) then
      val = v
      break
    end
  end
  return val
end

--判断传来的任务id是否等于当前激活的活动
function ActivityCtrl:isQuestBelongSelect(questId)
  Debugger.Log("ActivityCtrl:isQuestBelongSelect = "..questId.." self.selectTab = "..self.selectTab)
  local info = self:actiInfoGetById(self.selectTab)
  local ret = false
  if (info ~= nil) then
    for i,v in ipairs(info.ActivityQuests) do
      if (v.Id == questId) then
        ret = true
        break
      end
    end
  end
  return ret
end

--actiId属于哪idx
function ActivityCtrl:actiIdxGetById(actiId)
  local idx = 0
  for i, v in ipairs(self.tabActi) do
    if (v.Id == actiId) then
      idx = i
      break
    end
  end
  return idx
end

--判断某个活动是否领取完
function ActivityCtrl:isOneGetAllAward(info)
  local isAll = false
  if (#info.ActivityQuests > 0) then
    if (info.ActivityQuests[1].Type == 1 or info.ActivityQuests[1].Type == 2) then
      local numHave = #info.ActivityQuests
      local numCnt = 0
      for i,v in ipairs(info.ActivityQuests) do
        if ( Data.PlayerActivityQuestDeck[tostring(v.Id)] ~= nil) then
          if (Data.PlayerActivityQuestDeck[tostring(v.Id)].IsDrew == true) then
            numCnt = numCnt + 1
          end
        end
      end
      if (numHave == numCnt) then
        isAll = true
      end
    end
  end
  return isAll
end

function ActivityCtrl:isCanGet(info)
  local isRet = false
  local cnt = UTGDataOperator.Instance:actiAwardCnt(info)
  if (cnt > 0) then
    isRet = true
  end
  return isRet
end

function ActivityCtrl:oneRedUpdate(actiId)
  local trans = self.leftContent:FindChild(tostring(actiId))
  local red = trans:FindChild("Red")
  local info = self.tabActiById[tostring(actiId)]
  local isRed = self:isLeftItemRed(info)
  red.gameObject:SetActive(isRed)

  self:totalRedUpdate()
end

function ActivityCtrl:totalRedUpdate()
  local cntTotal = 0
  for i,val in ipairs(self.tabActi) do
    local cnt = UTGDataOperator.Instance:actiAwardCnt(val)
    cntTotal = cntTotal + cnt
  end

  --计数多少活动未读
  local cntRead = 0
  for i,val in ipairs(self.tabActi) do
    if (self:isHaveRead(val.Id) == false) then
      cntRead = cntRead + 1
    end
  end

  UTGDataOperator.Instance.actiNoReadCnt = cntRead
  cntTotal = cntTotal + cntRead
  --更新真身界面的
  ActivityNoticeApi.Instance:redActiUpdate(cntTotal)

end