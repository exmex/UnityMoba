--author zx
require "Logic.UTGData.UTGData"
require "Logic.UTGData.UTGDataTemporary"

class("StartBountyMatchCtrl")

function StartBountyMatchCtrl:Awake(this)
  self.this = this
  self.main = this.transform
  self.wait = this.transforms[0]

  self.textRule = "一、赏金赛概述：\n1、赏金赛在指定时间段内开放，在开放时间内，指挥官可以通过购买门票开启一轮赏金赛\n2、开启一轮赏金赛需要一次性消耗8张门票，之后在该轮中不再消耗门票；\n3、一轮赏金赛中，指挥官可以进行多场比赛，当胜场达到10场，或败场达到3场后，会结束该轮赏金赛\n4、结束一轮赏金赛时，会根据指挥官的获得的胜场数，发放胜场奖励；\n5、指挥官在一轮赏金赛中胜场数越多，奖励越丰厚；\n6、奖励中包含价值<color=#e36c0a>360</color>金币的姬神碎片，专属头像，以及专属史诗皮肤；"
  
  --数据
  self.bountyData = UTGData.Instance().BountiesData[tostring(UTGDataTemporary.Instance().BountyMatchCoinTemplateId)]
  local entrance = UTGData.Instance():StringSplit(self.bountyData.Entrance,",")
  self.shopData = UTGData.Instance().ShopsData[tostring(entrance[1])][1]
  --门票ItemId
  self.coinTicketItemId = self.shopData.CommodityId
  --需要门票数
  self.needCoinTicketAmount = 8
  --最大开启次数
  self.todayMax = self.bountyData.DailyOpenLimit
  --时间
  self.timeStart = self.bountyData.Start
  self.timeEnd = self.bountyData.End
  --玩家数据
  self.playerBounty = UTGData.Instance().PlayerBountyInfos[tostring(UTGDataTemporary.Instance().BountyMatchCoinTemplateId)]
  self.todayNum = self.playerBounty.TodayOpen
  self.state = self.playerBounty.State
end

function StartBountyMatchCtrl:SetWait(boo)
  if self~=nil and self.this~=nil then
    self.wait.gameObject:SetActive(boo)
  end
end

function StartBountyMatchCtrl:Start()
  self:Init()
end

function StartBountyMatchCtrl:Init()
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.main:FindChild("But-Close").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickClosePanel,self) 
  listener = NTGEventTriggerProxy.Get(self.main:FindChild("But-Start").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickStartMatch,self)
  listener = NTGEventTriggerProxy.Get(self.main:FindChild("But-Rule").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickRule,self)

  self:InitTicketAmount()
  self.main:FindChild("Text-TodayNum"):GetComponent("UnityEngine.UI.Text").text = string.format("今日已开启次数：%d/%d",self.todayNum,self.todayMax)
end


function StartBountyMatchCtrl:ClickStartMatch()
  local param = UTGData.Instance():IsActivityOpen(self.timeStart,self.timeEnd)
  --Debugger.LogError(tostring(param.IsOpen))
  --Debugger.LogError(tostring(param.WaitSecend))
  if param.IsOpen then 
    if self.todayNum>= self.todayMax then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("今日次数已用完，请明天再来参与哟~")
      return
    end
    if self.myCoinTicketAmount<self.needCoinTicketAmount then 
      self:BuyCoinTicket()
    else
      if self.state == 1 then 
        self:SetWait(true)
        self:RequestStartBounty(self.bountyData.Id)
      else
        self:CreatePanelAsync("CoinMatch")
      end
    end
  else
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("未达到比赛开放时间，请留意界面中的开放时间提示哟")
  end

end

function StartBountyMatchCtrl:RequestStartBounty(id)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestStartBounty"),
                                JProperty.New("BountyTempId",tonumber(id)))
  request.Handler = TGNetService.NetEventHanlderSelf(StartBountyMatchCtrl.RequestStartBountyHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self:SetWait(true)
end
function StartBountyMatchCtrl:RequestStartBountyHandler(e)
  self:SetWait(false)
  if e.Type =="RequestStartBounty" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("金币门票开始生效！")
      self.playerBounty.State = 2
      if BountyMatchAPI~=nil and BountyMatchAPI.Instance~=nil then 
        BountyMatchAPI.Instance:SetState(2)
      end
      self:CreatePanelAsync("CoinMatch")
    elseif result == 4357 then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("未达到比赛开放时间，请留意界面中的开放时间提示哟")
    else
      Debugger.LogError("RequestStartBounty Result == "..result)
    end
    return true
  end
  return false
end


function StartBountyMatchCtrl:BuyCoinTicket()
  local onePrice = self.shopData.CoinPrice 
  local num = self.needCoinTicketAmount - self.myCoinTicketAmount
  local str = string.format("确定花费<color=#F4BE17FF>%d金币</color>购买%d张金币赛门票",num*onePrice,num)
  self.instanceDialog = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
  self.instanceDialog:InitNoticeForNeedConfirmNotice("提示",str, false, "", 2)
  self.instanceDialog:SetTextToCenter()
  self.instanceDialog:TwoButtonEvent("取消",StartBountyMatchCtrl.BuyCoinTicketCanel,self,
                          "确定",StartBountyMatchCtrl.BuyCoinTicketYes,self)

end

function StartBountyMatchCtrl:BuyCoinTicketYes()
  local shopData = self.shopData 
  local num = self.needCoinTicketAmount - self.myCoinTicketAmount
  self:SetWait(true) 
  UTGDataOperator.Instance:ShopBuy(shopData.Id,1,num,StartBountyMatchCtrl.BuyCoinTicketHandler,self) 
  self.instanceDialog:DestroySelf()
end
function StartBountyMatchCtrl:BuyCoinTicketCanel()
  self.instanceDialog:DestroySelf()
end

function StartBountyMatchCtrl:InitTicketAmount()
  self.myCoinTicketAmount = 0
  local itemDeck = UTGData.Instance().ItemsDeck[tostring(self.coinTicketItemId)]
  if itemDeck~=nil then self.myCoinTicketAmount = itemDeck.Amount end
  self.main:FindChild("Text-ItemAmount"):GetComponent("UnityEngine.UI.Text").text = "x"..self.myCoinTicketAmount
end

function StartBountyMatchCtrl:BuyCoinTicketHandler()
  self:SetWait(false)
  GameManager.CreatePanel("SelfHideNotice")
  SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("门票到手，天下我有")
end

function StartBountyMatchCtrl:ClickRule()
  GameManager.CreatePanel("PageText")
  PageTextAPI.instance:Init("赏金赛规则",self.textRule)
end

function StartBountyMatchCtrl:ClickClosePanel()
  Object.Destroy(self.this.transform.parent.gameObject)
end

function StartBountyMatchCtrl:CreatePanelAsync(name)
  coroutine.start(StartBountyMatchCtrl.CreatePanelAsyncMov,self,name)
end
function StartBountyMatchCtrl:CreatePanelAsyncMov(name)
  self:SetWait(true)
  local async = GameManager.CreatePanelAsync(name)
  while async.Done == false do
    coroutine.step()
  end
  self:SetWait(false)
  self:ClickClosePanel()
end

function StartBountyMatchCtrl:OnDestroy()
  self.this = nil
  self = nil
end