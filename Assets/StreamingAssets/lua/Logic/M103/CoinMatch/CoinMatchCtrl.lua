--author zx
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
require "Logic.UTGData.UTGDataTemporary"
class("CoinMatchCtrl")

local json = require "cjson"

function CoinMatchCtrl:Awake(this)
  self.this = this
  self.top = this.transforms[0]
  self.middle = this.transforms[1]
  self.wait = this.transforms[2]

  self.vicNumTran = self.middle:FindChild("Vic-Num")
  self.tip = self.middle:FindChild("Tip")
  self.frameLose = self.middle:FindChild("Frame-Lose")
  self.frameGetReward = self.middle:FindChild("Frame-GetReward")

  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")

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
  self.timeStart = UTGData.Instance():StringSplit(self.bountyData.Start," ")[3]
  self.timeEnd = UTGData.Instance():StringSplit(self.bountyData.End," ")[3]
  --玩家数据
  self.playerBounty = UTGData.Instance().PlayerBountyInfos[tostring(UTGDataTemporary.Instance().BountyMatchCoinTemplateId)]
  self.state = self.playerBounty.State
  self.vicNum = self.playerBounty.Wins
  self.loseNum = self.playerBounty.Lose

  self.timeStart = self.bountyData.Start
  self.timeEnd = self.bountyData.End
  self:SetFxOk(self.middle)
end

function CoinMatchCtrl:Start()
  self:Init()
end

function CoinMatchCtrl:SetWait(boo)
  if self~=nil and self.this~=nil then
    self.wait.gameObject:SetActive(boo)
  end
end
function CoinMatchCtrl:SetFxOk(model)
  local btn = model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,btn.Length - 1 do
    model.transform:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
  end
end


function CoinMatchCtrl:Init()
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("CoinMatchPanel/Main/Top/Resource")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,self.ClickClosePanel,nil,nil,"金币大奖赛")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(topAPI)

  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.top:FindChild("But-Rule").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickRule,self)

  listener = NTGEventTriggerProxy.Get(self.middle:FindChild("But-Match").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickStartMatch,self)
  listener = NTGEventTriggerProxy.Get(self.middle:FindChild("But-GetReward").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickGetReward,self)
  listener = NTGEventTriggerProxy.Get(self.middle:FindChild("But-Reward").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickRewardInfo,self)
  listener = NTGEventTriggerProxy.Get(self.middle:FindChild("But-Buy").gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.ClickBuyTicket,self)

  if self.state ~= 3 then 
    self.middle:FindChild("But-Match").gameObject:SetActive(true)
  end
  if self.state == 3 then 
    self.middle:FindChild("But-GetReward").gameObject:SetActive(true)
    self:SetFxOk(self.middle:FindChild("But-GetReward"))
    local text = ""
    if self.vicNum == 10 then 
      text = "你赢得了10场比赛，看看获得哪些奖励吧"
    else
      text = "你输掉了3场比赛，看看获得哪些奖励吧"
    end
    self:InitTip(self.frameGetReward,text)
  elseif self.loseNum == 2 then 
    self:InitTip(self.frameLose,"你已经输掉2场比赛了，再输一场会退出本轮赏金赛")
  end
  self:InitTicketAmount()
  self:InitPlayerIcon()
  local param = self:GetMatchResultChange()
  local isShowVic = false 
  local isShowLose = false
  if param.Show == true then 
    if param.IsWin == 1 then isShowVic = true else isShowLose = true end
  end
  self:InitVicNum(self.vicNum,isShowVic)
  self:InitLoseNum(self.loseNum,isShowLose)
  self.middle:FindChild("Time/Text"):GetComponent("UnityEngine.UI.Text").text = self.bountyData.OpenDesc
end
--是否播放胜利或失败的UI动画
function CoinMatchCtrl:GetMatchResultChange()
  local result = {Show = false,IsWin = false}
  local path = NTGResourceController.GetDataPath("GlobalData").."BountyData.ini"
  if File.Exists(path) == false then
    self:WriteWinAndLoseAll(0)
  end
  local jsonData = NTGResourceController.ReadAllText(path)
  local WinAndLoseAll = json.decode(jsonData).WinAndLoseAll
  local last = self.playerBounty.LastResult
  local winLoseAll = self.vicNum + self.loseNum

  --Debugger.LogError(WinAndLoseAll)
  --Debugger.LogError(last)

  if WinAndLoseAll == winLoseAll or last == -1 then return result end
  if WinAndLoseAll > winLoseAll then 
    self:WriteWinAndLoseAll(winLoseAll)
    return result
  end
  if WinAndLoseAll < winLoseAll then 
    result.Show = true 
    result.IsWin = last
    self:WriteWinAndLoseAll(winLoseAll)
    return result
  end
  
end
function CoinMatchCtrl:WriteWinAndLoseAll(result)
  local path = NTGResourceController.GetDataPath("GlobalData").."BountyData.ini"
  local stream = {WinAndLoseAll = tonumber(result)}
  NTGResourceController.WriteAllText(path,json.encode(stream))
end


function CoinMatchCtrl:InitVicNum(currentNum,isShow)
  if isShow then 
    self.coroutineVicShow = coroutine.start(self.InitVicNumMov,self,currentNum)
  else
    self:ShowVicNum(currentNum)
  end
end
function CoinMatchCtrl:ShowVicNum(currentNum)
  local grid = self.vicNumTran:FindChild("Grid")
  grid:FindChild("Ge").gameObject:SetActive(false)
  grid:FindChild("Shi").gameObject:SetActive(false)
  if currentNum <10 then
    grid:FindChild("Ge").gameObject:SetActive(true)
    grid:FindChild("Ge").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..currentNum,"UnityEngine.Sprite")
  end
  if currentNum == 10 then 
    grid:FindChild("Ge").gameObject:SetActive(true)
    grid:FindChild("Ge").gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..0,"UnityEngine.Sprite")
    grid:FindChild("Shi").gameObject:SetActive(true)
  end
end
function CoinMatchCtrl:InitVicNumMov(currentNum)
  self:ShowVicNum(currentNum-1)
  local ani = self.vicNumTran:GetComponent("Animator")
  ani.enabled = true 
  coroutine.wait(0.6)
  self.vicNumTran:FindChild("Fx").gameObject:SetActive(true)
  self:SetFxOk(self.vicNumTran:FindChild("Fx"))
  self:ShowVicNum(currentNum)
end


function CoinMatchCtrl:InitLoseNum(currentNum,isShow)
  local grid = self.middle:FindChild("Grid")
  for i=1,currentNum do
    grid:GetChild(i-1):FindChild("Image").gameObject:SetActive(true)
  end
  if isShow then 
    local ani = grid:GetChild(currentNum-1):FindChild("Image"):GetComponent("Animator")
    ani.enabled = true 
  end
end

function CoinMatchCtrl:InitTip(frame,text)
  self.coroutine_tip = coroutine.start(CoinMatchCtrl.TipMov,self,frame,text)
end
function CoinMatchCtrl:TipMov(frame,text)
  local ani = self.tip:GetComponent("Animator")
  self.tip:FindChild("Main/Text"):GetComponent("UnityEngine.UI.Text").text = text
  self.tip.position = frame.position
  self.tip.gameObject:SetActive(true)
  coroutine.wait(4)
  ani:Play("Hide")
  coroutine.wait(3)
  self.tip.gameObject:SetActive(false)
end

function CoinMatchCtrl:InitPlayerIcon()
  local temp = self.middle:FindChild("PlayerIcon")
  local data = UTGData.Instance().PlayerData
  local vipIcon = "v"..data.Vip
  local framIcon = UTGData.Instance().AvatarFramesData[tostring(data.AvatarFrameId)].Icon
  temp:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("roleicon",tostring(data.Avatar))
  if data.Vip>0 then
    temp:FindChild("Vip").gameObject:SetActive(true)
    temp:FindChild("Vip"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("vipicon",vipIcon)
  end
  temp:FindChild("Bg"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("frameicon",framIcon)
end

function CoinMatchCtrl:InitTicketAmount()
  local amount = 0
  local itemDeck = UTGData.Instance().ItemsDeck[tostring(self.coinTicketItemId)]
  if itemDeck~=nil then amount = itemDeck.Amount end
  self.middle:FindChild("Text-ItemAmount"):GetComponent("UnityEngine.UI.Text").text = "x"..amount
end

function CoinMatchCtrl:ClickBuyTicket()
  self:CreatePanelAsync("PropDetails",CoinMatchCtrl.ClickBuyTicketCallBack)
end
function CoinMatchCtrl:ClickBuyTicketCallBack()
    --PropDetailsAPI:DataInit(itemId,isLock,maxNum,buyType,singlePrice,itemType)  --id，是否有限购，可购买的最大数量，购买类型（1金币2宝石3点券），单价
  PropDetailsAPI.Instance:DataInit(self.coinTicketItemId,false,0,1,self.shopData.CoinPrice,4,CoinMatchCtrl.BuyTicketOver,self)
end
function CoinMatchCtrl:BuyTicketOver()
  GameManager.CreatePanel("SelfHideNotice")
  SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("门票到手，天下我有")
end

function CoinMatchCtrl:ClickStartMatch()
  local param = UTGData.Instance():IsActivityOpen(self.timeStart,self.timeEnd)
  if param.IsOpen == false then 
    local instance = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
    instance:InitNoticeForNeedConfirmNotice("提示", "未达到比赛开放时间，请留意界面中的开放时间提示哟", false, "", 1)
    instance:SetTextToCenter()
    instance:OneButtonEvent("确定",function () instance:DestroySelf() end,self)
  else
    self:CreatePanelAsync("NewBattle15",CoinMatchCtrl.ClickStartMatchCallBack)
  end
end
function CoinMatchCtrl:ClickStartMatchCallBack()
  NewBattle15API.Instance:CreateParty("",1,71,7)
end
function CoinMatchCtrl:ClickGetReward()
  self:RequestPickBountyPrize(self.bountyData.Id)
end
function CoinMatchCtrl:RequestPickBountyPrize(id)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestPickBountyPrize"),
                                JProperty.New("BountyTempId",tonumber(id)))
  request.Handler = TGNetService.NetEventHanlderSelf(CoinMatchCtrl.RequestPickBountyPrizeHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self:SetWait(true)
end
function CoinMatchCtrl:RequestPickBountyPrizeHandler(e)
  self:SetWait(false)
  if e.Type =="RequestPickBountyPrize" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      self:WriteWinAndLoseAll(0)
      --重置界面参数
      if BountyMatchAPI~=nil and BountyMatchAPI.Instance~=nil then 
        BountyMatchAPI.Instance:SetState(1)
      end
      self:InitRewardPanel()
    else
      Debugger.LogError("RequestPickBountyPrize Result == "..result)
    end
    return true
  end
  return false
end


function CoinMatchCtrl:InitRewardPanel()
  local itemId = 0
  local bonus = UTGData.Instance():StringSplit(self.bountyData.Bonus,";")
  local bonusData = {}
  for i,v in ipairs(bonus) do
    local one = UTGData.Instance():StringSplit(v,",")
    local data = {}
    data.Num = one[1]
    data.ItemId = one[2]
    table.insert(bonusData,data)
  end
  for i,v in ipairs(bonusData) do
    if tonumber(v.Num) == self.vicNum then 
      itemId = v.ItemId 
      break
    end
  end
  GameManager.CreatePanel("BountyMatchGetReward")
  if BountyMatchGetRewardAPI~=nil and BountyMatchGetRewardAPI.Instance~=nil then 
    BountyMatchGetRewardAPI.Instance:Init(itemId)
  end

  --获取赏金联赛信息
  UTGData.Instance():RequestPlayerBountyInfo()

end

function CoinMatchCtrl:ClickRewardInfo()
  self:CreatePanelAsync("BountyMatchReward")
end

function CoinMatchCtrl:ClickRule()
  GameManager.CreatePanel("PageText")
  PageTextAPI.instance:Init("赏金赛规则",self.textRule)
end

function CoinMatchCtrl:ClickClosePanel()
  Object.Destroy(self.this.transform.parent.gameObject)
end

function CoinMatchCtrl:CreatePanelAsync(name,func)
  self:SetWait(true)
  coroutine.start(CoinMatchCtrl.CreatePanelAsyncMov,self,name,func)
end
function CoinMatchCtrl:CreatePanelAsyncMov(name,func)
  local async = GameManager.CreatePanelAsync(name)
  while async.Done == false do
    coroutine.step()
  end
  self:SetWait(false)
  if func~=nil then func(self) end
end


function CoinMatchCtrl:OnDestroy()
  if self.coroutine_tip~=nil then coroutine.stop(self.coroutine_tip) end
  if self.coroutineVicShow~=nil then coroutine.stop(self.coroutineVicShow) end
  self.this = nil
  self = nil
end