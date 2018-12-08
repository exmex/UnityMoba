require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("WantHeroCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"
local Toggle = "UnityEngine.UI.Toggle"

local Data = UTGData.Instance()
function WantHeroCtrl:Awake(this) 
  self.this = this
  self.itemTmp = this.transforms[0]
  self.content = this.transforms[1]
  self:dataInit()
  self:itemCreate(self.tabItem)
end

function WantHeroCtrl:Start()
  
end

function WantHeroCtrl:Init()

end

function WantHeroCtrl:OnDestroy()
  self.this = nil
  self = nil
end

function WantHeroCtrl:dataInit(args)
  self.tabItem = UITools.CopyTab(Data.GrowUpGuideHero)
  --≈≈–Ú∞¥’’id
  local function idSort(a,b)
    if (a.Id < b.Id) then
      return true
    end
    return false
  end 

  table.sort(self.tabItem,idSort)
end

function WantHeroCtrl:itemCreate(tabTmp)
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

function WantHeroCtrl:itemUiSet(trans,info)
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
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self )

  local spr = trans:FindChild("Image/Icon")
  local sprIcon = UITools.GetSprite("wanticon",info.Icon)
  if (sprIcon ~= nil) then
    spr:GetComponent(Image).sprite = UITools.GetSprite("wanticon",info.Icon)
  end
end

