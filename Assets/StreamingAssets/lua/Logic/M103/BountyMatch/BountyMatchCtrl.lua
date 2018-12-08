--author zx
require "Logic.UTGData.UTGData"
class("BountyMatchCtrl")

function BountyMatchCtrl:Awake(this)
  self.this = this
  self.top = this.transforms[0]
  self.middle = this.transforms[1]
  self.bottom = this.transforms[2]

  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")

  self.bountyData = UTGData.Instance().BountiesData[tostring(UTGDataTemporary.Instance().BountyMatchCoinTemplateId)]
  
  self.timeStart = self.bountyData.Start
  self.timeEnd = self.bountyData.End

  self.playerBounty = UTGData.Instance().PlayerBountyInfos[tostring(UTGDataTemporary.Instance().BountyMatchCoinTemplateId)]
  self.state = self.playerBounty.State

end

function BountyMatchCtrl:Start()
  self:Init()
end

function BountyMatchCtrl:Init()
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("BountyMatchPanel/Main/Top")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,self.ClickClosePanel,nil,nil,"赏金联赛")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(topAPI)
  
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.middle:FindChild("But_Gold").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickGoldMatch,self) 
  listener = NTGEventTriggerProxy.Get(self.middle:FindChild("But_Gem").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickGemMatch,self)
  listener = NTGEventTriggerProxy.Get(self.middle:FindChild("But_More").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickMoreMatch,self)

  listener = NTGEventTriggerProxy.Get(self.bottom:FindChild("But_Chart").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickChart,self) 

  self:InitGoldMatchTime()
end

function BountyMatchCtrl:InitGoldMatchTime()
  self.textGoldTime = self.middle:FindChild("Text-GoldTime")
  local param = UTGData.Instance():IsActivityOpen(self.timeStart,self.timeEnd)
  if param.IsOpen then 
    self.textGoldTime:GetComponent("UnityEngine.UI.Text").text = "比赛进行中"
  else
    self.cor = coroutine.start(self.GoldMatchTimeMov,self,param.WaitSecond)
  end
end
function BountyMatchCtrl:GoldMatchTimeMov(time)
  local Text = self.textGoldTime:GetComponent("UnityEngine.UI.Text")
  while time>0 do 
    local hour = math.floor(time/3600) 
    local min = math.floor((time%3600)/60) 
    local secend = math.floor((time%3600)%60)
    Text.text = string.format("距离开始还有 %02d:%02d:%02d",hour,min,secend)
    coroutine.wait(1)
    time = time-1
  end
  Text.text = "比赛进行中"
end

function BountyMatchCtrl:ClickChart()
  GameManager.CreatePanel("BountyMatchChart")
end

function BountyMatchCtrl:ClickGoldMatch()
  if self.state~=1 then 
    GameManager.CreatePanel("CoinMatch")
  else
    GameManager.CreatePanel("StartBountyMatch")
  end
end

function BountyMatchCtrl:ClickGemMatch()
  GameManager.CreatePanel("SelfHideNotice")
  SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("赛事即将开放")
end

function BountyMatchCtrl:ClickMoreMatch()
	GameManager.CreatePanel("SelfHideNotice")
  SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("更多精彩赛事，敬请期待")
end

function BountyMatchCtrl:ClickClosePanel()
  Object.Destroy(self.this.transform.parent.gameObject)
end



function BountyMatchCtrl:OnDestroy()
  if self.cor~=nil then coroutine.stop(self.cor) end
  self.this = nil
  self = nil
end