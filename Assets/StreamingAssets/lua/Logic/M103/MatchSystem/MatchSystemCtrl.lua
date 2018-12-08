--author zx
class("MatchSystemCtrl")

function MatchSystemCtrl:Awake(this)
  self.this = this
  self.top = this.transforms[0]
  self.middle = this.transforms[1]
  self.bottom = this.transforms[2]

  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end

function MatchSystemCtrl:Start()
  if WaitingPanelAPI~=nil and WaitingPanelAPI.Instance~=nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end
  self:Init()
end

function MatchSystemCtrl:Init()
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("MatchSystemPanel/Main/Top")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,self.ClickClosePanel,nil,nil,"赛事系统")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(topAPI)

  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.middle:FindChild("But_Gold").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickBountyMatch,self) 
  listener = NTGEventTriggerProxy.Get(self.middle:FindChild("But_More").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickMoreMatch,self)

  listener = NTGEventTriggerProxy.Get(self.bottom:FindChild("But_Live").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickNothing,self) 
  listener = NTGEventTriggerProxy.Get(self.bottom:FindChild("But_New").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickNothing,self) 

end


function MatchSystemCtrl:ClickNothing()
	GameManager.CreatePanel("SelfHideNotice")
  SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
end

function MatchSystemCtrl:ClickBountyMatch()
  GameManager.CreatePanel("BountyMatch")
end

function MatchSystemCtrl:ClickMoreMatch()
	GameManager.CreatePanel("SelfHideNotice")
  SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("更多精彩赛事，敬请期待")
end

function MatchSystemCtrl:ClickClosePanel()
  Object.Destroy(self.this.transform.parent.gameObject)
  UTGDataOperator.Instance:SetPreUIRight(self.this.transform.parent)
end

function MatchSystemCtrl:OnDestroy()
  self.this = nil
  self = nil
end