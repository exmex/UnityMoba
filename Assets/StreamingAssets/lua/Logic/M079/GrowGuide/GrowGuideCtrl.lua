require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("GrowGuideCtrl")
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"
local Toggle = "UnityEngine.UI.Toggle"

function GrowGuideCtrl:Awake(this) 
  self.this = this
  self.top = this.transforms[0]
  self.tabGrid = this.transforms[1]
  self.contentGrid = this.transforms[2]

  self.getMorePanel = this.transforms[3]
  self.getMoreCloseBtn  = this.transforms[4]
  self.getMoreDesContent = this.transforms[5]
  self.growProcessRedPoint = this.transforms[6]
  self.wantGrowRed = this.transforms[7]
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end

function GrowGuideCtrl:Start()
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("GrowGuidePanel/Panel/Top")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,self.DestroySelf,nil,nil,"成长指引")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(topAPI)
  self:Init()
  self:updateGrowProgressRedPoint()
  self:updateWantGrowRed()

end

function GrowGuideCtrl:Init()
  local listener = {}
  for i=1,self.tabGrid.childCount do
    listener = self.tabGrid:GetChild(i-1).gameObject
    UITools.GetLuaScript(listener,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickTab,listener.name)
  end

  self:btnInit()
  
  --确定一开始开启哪个页签
  local count  = 0
  local levelAward = UTGDataOperator.Instance:LevelAwardCntGet()
  local questAward = UTGDataOperator.Instance:QuestAwardCntGet()
  count = count + levelAward
  count = count + questAward
  
  local wantGrowCnt = 0
  wantGrowCnt = UTGDataOperator.Instance:WantGrowAwardCntGet()

  if (count > 0 and wantGrowCnt == 0) then
    self:ClickTab("GrowProcess")
  elseif (count == 0 ) then
    self:ClickTab("WantGrow")
  elseif (count > 0 and wantGrowCnt > 0) then
    self:ClickTab("WantGrow")
  end
  
  local sDes = self.getMoreDesContent:GetComponent(Text).text
  local limit_weekly_battle_coin =  UTGData.Instance().ConfigData["limit_weekly_battle_coin"].Int
  local limit_weekly_battle_coin_bonus = UTGData.Instance().ConfigData["limit_weekly_battle_coin_bonus"].Int
  local limit_weekly_battle_coin_penalty = UTGData.Instance().ConfigData["limit_weekly_battle_coin_penalty"].Int
  local limit_weekly_battle_coin_bonus_credit = UTGData.Instance().ConfigData["limit_weekly_battle_coin_bonus_credit"].Int
  local limit_weekly_battle_coin_penalty_credit = UTGData.Instance().ConfigData["limit_weekly_battle_coin_penalty_credit"].Int
  local grow_up_client_battle_coin_reset_time = UTGData.Instance().ConfigData["grow_up_client_battle_coin_reset_time"].Int
  
  sDes = string.gsub(sDes,"{0}",limit_weekly_battle_coin)
  sDes = string.gsub(sDes,"{1}",limit_weekly_battle_coin_bonus)
  sDes = string.gsub(sDes,"{2}",limit_weekly_battle_coin_penalty)
  sDes = string.gsub(sDes,"{3}",limit_weekly_battle_coin_bonus_credit)
  sDes = string.gsub(sDes,"{4}",limit_weekly_battle_coin_penalty_credit)
  sDes = string.gsub(sDes,"{5}",grow_up_client_battle_coin_reset_time)

  self.getMoreDesContent:GetComponent(Text).text  = sDes
end

function GrowGuideCtrl:btnInit(args)
  local listener = NTGEventTriggerProxy.Get(self.getMoreCloseBtn.gameObject)
  local callBack = function (self,e)
    self.getMorePanel.gameObject:SetActive(false)
  end
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
end

function GrowGuideCtrl:ClickTab(name)
  --临时
--  if name ~="WantGrow" and name ~= "GrowProcess" and name ~= "WantGold" then 
--    GameManager.CreatePanel("SelfHideNotice")
--    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
--    return
--  end

--  local temp = self.tabGrid:FindChild(name)
--  if temp:FindChild("Click").gameObject.activeSelf then return end
--  temp:FindChild("Click").gameObject:SetActive(true)

  self:leftUiSet(name)

  self:GoToPanel(name)
end

function GrowGuideCtrl:leftUiSet(name)
  for i = 0,self.tabGrid.childCount-1,1 do
    local obj = self.tabGrid:GetChild(i);
    if obj.name == name then
      obj:FindChild("Click").gameObject:SetActive(true)
    else
      obj:FindChild("Click").gameObject:SetActive(false)
    end
  end
end

function GrowGuideCtrl:GoToPanel(name)
  local panelname = name.."Panel"
  for i=1,self.contentGrid.childCount do
    self.contentGrid:GetChild(i-1).gameObject:SetActive(false)
  end
  local panel = self.contentGrid:FindChild(panelname)
  if panel~= nil then 
    panel.gameObject:SetActive(true)
--  else
--    coroutine.start(self.GoToPanelMov,self,name)
  end
end

function GrowGuideCtrl:GoToPanelMov(name)
  GameManager.CreatePanel("Waiting")
  local async = GameManager.CreatePanelAsync(tostring(name))
  while async.Done == false do
    coroutine.wait(0.05)
  end
  async.Panel.transform:SetParent(self.contentGrid)
  async.Panel.gameObject:SetActive(true)
  if WaitingPanelAPI~=nil and WaitingPanelAPI.Instance~=nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end
end


function GrowGuideCtrl:DestroySelf()
  Object.Destroy(self.this.transform.parent.gameObject)
  NTGResourceController.Instance:UnloadAssetBundle("growguide", true, false)
  if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
    UTGMainPanelAPI.Instance:ShowSelf()
  end
end

function GrowGuideCtrl:OnDestroy()
  self.this = nil
  self = nil
end

function GrowGuideCtrl:getMorePanelOpen(args)
  self.getMorePanel.gameObject:SetActive(true)
  --self.getMoreDesContent.localPosition = Vector3.New(-3,170,0)
end
  
function GrowGuideCtrl:getMorePanelClose(args)
  self.getMorePanel.gameObject:SetActive(false)
end

function GrowGuideCtrl:updateGrowProgressRedPoint(args)
  local count  = 0
  local levelAward = UTGDataOperator.Instance:LevelAwardCntGet()
  local questAward = UTGDataOperator.Instance:QuestAwardCntGet()
  count = count + levelAward
  count = count + questAward
  
  if (count > 0) then
    self.growProcessRedPoint.gameObject:SetActive(true)
  elseif (count == 0) then
    self.growProcessRedPoint.gameObject:SetActive(false)
  end
end

function GrowGuideCtrl:updateWantGrowRed(args)
  local count  = UTGDataOperator.Instance:WantGrowAwardCntGet()
  if (count > 0) then
    self.wantGrowRed.gameObject:SetActive(true)
  elseif (count == 0) then
    self.wantGrowRed.gameObject:SetActive(false)
  end
end