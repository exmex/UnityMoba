require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("NoticeCtrl")
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"
local Toggle = "UnityEngine.UI.Toggle"

local Data = UTGData.Instance()
function NoticeCtrl:Awake(this) 
  self.this = this
  self.item = this.transforms[0]
  self.contentItem = this.transforms[1]
  self.title = this.transforms[2]
  self.text = this.transforms[3]
  self.gotoPart = this.transforms[4]
  self:dataInit()
end

function NoticeCtrl:Start()
  self:itemCreate(self.tabAnnouncement)
end


function NoticeCtrl:OnDestroy()
  self.this = nil
  self = nil
end

function NoticeCtrl:dataInit(args)
  local tabAnnouncement = UITools.CopyTab(Data.Announcements)
  self.tabAnnouncement = {}
  for i,v in pairs(tabAnnouncement) do
    table.insert(self.tabAnnouncement,v)
  end
  local function idSort(a,b)
    if  a.Id < b.Id then
     return true
    end
    return false
  end
  table.sort(self.tabAnnouncement,idSort)
  self.tabTransById = {}
end

function NoticeCtrl:itemCreate(tabAnnouncement)
  
  for i,v in ipairs(tabAnnouncement) do
    local newTmp = GameObject.Instantiate(self.item)
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(i)
    newTmp.transform:SetParent(self.contentItem)
    newTmp.transform.localPosition = Vector3.zero
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one

    self.tabTransById[tostring(v.Id)] = newTmp
    self:itemUiSet(newTmp,v,newTmp.name)
  end
  local strTab = {}
  strTab.info = tabAnnouncement[1]
  strTab.name = "1"
  self:detailUiSet(strTab)
end

function NoticeCtrl:itemUiSet(trans,info,name)
  local labTab = trans:FindChild("LeftName")
  labTab:GetComponent(Text).text = info.TabName

  local red = trans:FindChild("Red")
  local isRead = ActivityNoticeApi.Instance:isNoticeHaveRead(info.Id)
  
  if (name == "1") then
    red.gameObject:SetActive(false)
  else
    red.gameObject:SetActive(not isRead)
  end
--  if (isRead == false) then
--    red.gameObject:SetActive(true)
--  elseif (isRead == true) then
--    red.gameObject:SetActive(false)
--  end


  --监听自己的点击事件
  local listener = trans.gameObject
  local strTab = {}
  strTab.info = info
  strTab.name = name
  UITools.GetLuaScript(listener,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.detailUiSet,strTab)
end

function NoticeCtrl:redUpdate()
  for i,v in pairs(self.tabTransById) do
    --Debugger.Log("NoticeCtrl:redUpdate "..i)
    local isRead = ActivityNoticeApi.Instance:isNoticeHaveRead(tonumber(i))
    local red = v:FindChild("Red")
    red.gameObject:SetActive(not isRead)
  end
end

function NoticeCtrl:detailUiSet(strTab,isFirst)
  --Debugger.Log("strTab.info.Id = "..strTab.info.Id)
  if (self.selectTab == nil) then
    self.selectTab = strTab.info.Id
  elseif (self.selectTab ~= strTab.info.Id) then
    self.selectTab = strTab.info.Id
  elseif (self.selectTab == strTab.info.Id) then
    return
  end
  self:leftWhiteSet(strTab.name)
  self:rightUiSet(strTab.info)
  self:onRequestRead(strTab.info.Id)
end

function NoticeCtrl:leftWhiteSet(name)
  --Debugger.Log("NoticeCtrl:leftWhiteSet = "..name)
  for i = 0,self.contentItem.childCount-1,1 do
    local obj = self.contentItem:GetChild(i);
    --Debugger.Log("NoticeCtrl:leftWhiteSet obj = "..obj.name)
    if obj.name == name then
      obj:FindChild("white").gameObject:SetActive(true)
    else
      obj:FindChild("white").gameObject:SetActive(false)
    end
  end
end

function NoticeCtrl:rightUiSet(info)
  self.title:GetComponent(Text).text = info.Title
  self.text:GetComponent(Text).text = info.Content
  if (info.URL ~= "") then
    self.gotoPart.gameObject:SetActive(true)
  elseif (info.URL == "") then
    self.gotoPart.gameObject:SetActive(false)
  end
end

function NoticeCtrl:onRequestRead(id)
--Debugger.Log("NoticeCtrl:onRequestRead  id = "..id)
  local serverRequest = NetRequest.New()
  serverRequest.Content = JObject.New(JProperty.New("Type","RequestReadAnnouncement"),
                                      JProperty.New("AnnouncementId",id) )
  serverRequest.Handler = TGNetService.NetEventHanlderSelf(NoticeCtrl.onServerRead,self)
  TGNetService.GetInstance():SendRequest(serverRequest)
end

function NoticeCtrl:onServerRead(e)
--achievement_critical_rank
  if (NoticeApi ~= nil and NoticeApi.Instance ~= nil ) then
    if e.Type == "RequestReadAnnouncement" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then
        --Debugger.Log("RequestReadAnnouncement OK")
      end
      return true
    end
  end
  return false
end

