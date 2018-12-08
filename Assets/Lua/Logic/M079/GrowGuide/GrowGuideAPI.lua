require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("GrowGuideAPI")

function GrowGuideAPI:Awake(this) 
  self.this = this
  GrowGuideAPI.Instance = self
  self.Root = this.transforms[0]
  self.ctrl = self.this.transforms[0]:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
end

function GrowGuideAPI:Start()

end

function GrowGuideAPI:Init()

end

function GrowGuideAPI:ShowSelf()
--  self.Root.localPosition = Vector3.zero
--  if (GrowProcessApi~= nil and GrowProcessApi.Instance ~= nil) then
--    GrowProcessApi.Instance:contentCupSetActeive(true)
--  end
end

function GrowGuideAPI:HideSelf()
--  self.Root.localPosition = Vector3.New(0,1000,0)
--  if (GrowProcessApi~= nil and GrowProcessApi.Instance ~= nil) then
--    GrowProcessApi.Instance:contentCupSetActeive(false)
--  end
end


function GrowGuideAPI:OnDestroy()
  self.this = nil
  GrowGuideAPI.Instance = nil
  self = nil
end

function GrowGuideAPI:getMorePanelCreate(args)
  self.ctrl.self:getMorePanelOpen()
end
 
function GrowGuideAPI:updateGrowProgressRedPoint(args)
  self.ctrl.self:updateGrowProgressRedPoint()
end

function GrowGuideAPI:updateWantGrowRed()
  self.ctrl.self:updateWantGrowRed()
end

function GrowGuideAPI:gotoToPage(idx)
  if (idx == 1) then
    self.ctrl.self:ClickTab("GrowProcess")
  elseif (idx == 2) then
    self.ctrl.self:ClickTab("WantGrow")
  elseif (idx == 3) then
    self.ctrl.self:ClickTab("WantGold")
  elseif (idx == 4) then
    self.ctrl.self:ClickTab("WantRune")
  elseif (idx == 5) then
    self.ctrl.self:ClickTab("WantHero")
  end
end