require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("WantGoldCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"
local Toggle = "UnityEngine.UI.Toggle"

local GMaxLen = 656
local Data = UTGData.Instance()
function WantGoldCtrl:Awake(this) 
  self.this = this
  self.btnGetMore = this.transforms[0]
  self.labGold = this.transforms[1]
  self.labTime = this.transforms[2]
  self.itemTmp = this.transforms[3]
  self.content = this.transforms[4]
  self.progress = this.transforms[5]
  self:dataInit()
  self:itemCreate(self.tabItem)
  self:progressUiSet()
end

function WantGoldCtrl:Start()
  self:btnInit()
  self:topUiSet()
end

function WantGoldCtrl:Init()

end

function WantGoldCtrl:OnDestroy()
  self.this = nil
  self = nil
end

function WantGoldCtrl:dataInit(args)
  self.tabItem = UITools.CopyTab(Data.GrowUpGuideGold)
  --排序按照id
  local function idSort(a,b)
    if (a.Id < b.Id) then
      return true
    end
    return false
  end 

  table.sort(self.tabItem,idSort)
end

function WantGoldCtrl:btnInit(args)
  local listener = NTGEventTriggerProxy.Get(self.btnGetMore.gameObject)
  local callBack = function (self,e)
    GrowGuideAPI.Instance:getMorePanelCreate()
  end
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
end

function WantGoldCtrl:itemCreate(tabTmp)
  for i,v in ipairs(tabTmp) do
    local newTmp = GameObject.Instantiate(self.itemTmp)
    newTmp.gameObject:SetActive(true)
    newTmp.name = tostring(i)
    newTmp.transform:SetParent(self.content)
    
    newTmp.transform.localRotation = Quaternion.identity
    newTmp.transform.localScale = Vector3.one
    newTmp.transform.localPosition = Vector3.New(0,0,0)
    self:itemUiSet(newTmp,v)
  end
end

function WantGoldCtrl:progressUiSet(args)
  local curGold = Data.PlayerGainDeck.BattleCoinWeekly
  local maxGold = Data.PlayerGainDeck.BattleCoinWeeklyLimit
  local xLen = curGold * GMaxLen/maxGold
  local oldSize = self.progress:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta
  oldSize.x = xLen
  self.progress:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = oldSize

  local sGold = tostring(Data.PlayerGainDeck.BattleCoinWeekly).."/"..tostring(Data.PlayerGainDeck.BattleCoinWeeklyLimit)
  self.labGold:GetComponent(Text).text = sGold
end

function WantGoldCtrl:itemUiSet(trans,info)
  local labName = trans:FindChild("LabTitle")
  labName:GetComponent(Text).text = info.Title

  local labDes = trans:FindChild("LabDes")
  labDes:GetComponent(Text).text = info.Desc

  local btn = trans:FindChild("BtnGoto")

    local listener = NTGEventTriggerProxy.Get(btn.gameObject)
    local callBack = function (self,e)
  --    local function func()
  --         GrowGuideAPI.Instance:HideSelf()
  --      end
  --    UTGDataOperator.Instance:SoureceGotoUi(info.SourceId,func)

        local sourceData = Data.SourcesData[tostring(info.SourceId)]
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
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)

  local spr = trans:FindChild("Image/Icon")
  local sprIcon = UITools.GetSprite("wanticon",info.Icon)
  if (sprIcon ~= nil) then
    spr:GetComponent(Image).sprite = UITools.GetSprite("wanticon",info.Icon)
  end
end

--每周的重置时间
function WantGoldCtrl:topUiSet(args)
  local grow_up_client_battle_coin_reset_time = UTGData.Instance().ConfigData["grow_up_client_battle_coin_reset_time"].String
  self.labTime:GetComponent(Text).text = grow_up_client_battle_coin_reset_time
end
