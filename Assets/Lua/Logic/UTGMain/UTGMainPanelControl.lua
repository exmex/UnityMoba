require "System.Global"
require "Logic.UTGData.UTGData"
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGDataTemporary" 


class("UTGMainPanelControl")

--替代太长的字段名，懒得每次写==
local Data = UTGData.Instance()
local Text = "Text"
local Image = "Image"
local Slider = "Slider"
local RectTrans = "RectTransform"
local json = require "cjson"

function UTGMainPanelControl:Awake(this)
  self.this = this
  self.rootFrame = self.this.transform:FindChild("Root")
  self.topFrame = self.this.transforms[0]
  self.midFrame = self.this.transforms[1]
  self.bottomFrame = self.this.transforms[2]
  self.expTips = self.this.transforms[3]
  self.coinTips = self.this.transforms[4]
  self.jewelTips = self.this.transforms[5]
  self.ticketTips = self.this.transforms[6]
  self.signalTips = self.this.transforms[7]
  self.fx3 = self.this.transforms[8]
  self.fx4 = self.this.transforms[9]
  
  
  --玩家头像
  self.playerHeadIcon = self.topFrame:Find("PlayerHeadIcon")
   
  local listener = NTGEventTriggerProxy.Get( self.playerHeadIcon.gameObject)
            listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( 
              function ()
                self:GoToPanel("PlayerData",0)  --创建玩家资料面板
                
              end
              , self)
  --玩家vip信息
  self.playerVip = self.topFrame:Find("Panel/Image")

  --玩家信息更新提示
  --self.playerInfoNotice = self.playerHeadIcon:Find("PlayerInfoNotice-image")
  
  --玩家姓名
  self.playerName = self.topFrame:Find("Panel/Text")
  
  --玩家等级进度条及等级信息
  self.expSlider = self.topFrame:Find("Image/ExpCircle")
  self.expClickZone = self.expSlider:Find("ExpPanel")
  self.currentExp = self.topFrame:Find("ExpPanel/CurrentExp")
  self.maxExpOnCurrentLevel = self.topFrame:Find("ExpPanel/MaxExp")
  self.playerLevel = self.topFrame:Find("HeadFrameBase/Level")
  self.expSpacing = self.topFrame:Find("ExpPanel/Spacing")
  self.fullLevel = self.topFrame:Find("ExpPanel/FullLevel")
  
  --玩家首充续充按钮
  self.firstPayButton = self.topFrame:Find("NormalResource/FirstPay-button")
  self.continuePayButton = self.topFrame:Find("NormalResource/ContinuePay-button")
  
  --玩家资源文字
  self.coinNum = self.topFrame:Find("NormalResource/Coin-image/CoinNum-text")
  self.jewelNum = self.topFrame:Find("NormalResource/Jewel-image/JewelNum-text")
  self.ticketNum = self.topFrame:Find("NormalResource/Ticket-image/TicketNum-text")
  
  --资源相关按钮
  self.ticketButton = self.topFrame:Find("NormalResource/Ticket-image/TicketAddButton-button")
  
  --资源tips入口
  self.coinTipsButton = self.topFrame:Find("NormalResource/Coin-image/CoinIcon-image")
  self.jewelTipsButton = self.topFrame:Find("NormalResource/Jewel-image/JewelIcon-image")
  self.ticketTipsButton = self.topFrame:Find("NormalResource/Ticket-image/TicketIcon-image")
  
  --好友按钮及新好友提示标志
  self.friendButton = self.topFrame:Find("NormalResource/Friend-button")
  self.newFriendNotice = self.friendButton:Find("FriendsInfoNotice-image")
  
  --邮件按钮及新邮件提示标志
  self.emailButton = self.topFrame:Find("NormalResource/Email-button")
  self.newEmailNotice = self.emailButton:Find("EmailNotice-image")
  
  --设置按钮
  self.optionButton = self.topFrame:Find("OptionAndSignal/OptionButton-button")
  
  --跑马灯
  self.bigHorn = self.midFrame:Find("NoticeBar/BigHornBg/BigHornMask-mask/BigHorn")
  self.bigHornBg = self.midFrame:Find("NoticeBar/BigHornBg")
  self.waveShort = self.bigHorn:Find("BigHornIcon/WaveShort")
  self.bigHornLight = self.bigHornBg:Find("Light")
  self.bigHornBg.gameObject:SetActive(false)
  --对战模式按钮及提示
  self.playNowButton = self.midFrame:Find("PlayNowButton-button")
  self.playNowNewNotice = self.midFrame:Find("PlayNowButton-button/NoticeNew-image")
  self.playNowActivityBeginNotice = self.midFrame:Find("PlayNowButton-button/ActivityBeginNotice-image")
  self.animatorController = self.midFrame:Find("AnimatorControl")
  
  --冒险模式按钮及提示
  --self.adventureButton = self.midFrame:Find("AdventureButton-button")
  --self.adventureNewNotice = self.midFrame:Find("AdventureButton-button/NoticeNew-image")
  --self.adventureActivityBeginNotice = self.midFrame:Find("AdventureButton-button/ActivityBeginNotice-image")
  
  --排位赛模式按钮及提示及锁
  self.ladderButton = self.midFrame:Find("LadderButton-button")
  self.ladderNewNotice = self.ladderButton:Find("NoticeNew-image")
  self.ladderActivityBeginNotice = self.ladderButton:Find("ActivityBeginNotice-image")
  self.ladderLock = self.ladderButton:Find("Lock")
  self.ladderLockMask = self.ladderButton:Find("Lock/Mask-image")
  self.ladderLockIcon = self.ladderButton:Find("Lock/LockIcon-image")
  self.ladderLockNotice = self.ladderButton:Find("Lock/LockNotice-image")
  self.ladderLockOpenLevel = self.ladderLockNotice:Find("OpenLevel-text")
  
  --赏金联赛模式按钮及提示及锁
  self.levelBountyMatch = UTGData.Instance().BountiesData[tostring(UTGDataTemporary.Instance().BountyMatchCoinTemplateId)].LevelLimit
  self.bounitMatchButton = self.midFrame:Find("BounitMatchButton-button")
  self.bounitMatchNewNotice = self.bounitMatchButton:Find("NoticeNew-image")
  self.bounitMatchActivityBeginNotice = self.bounitMatchButton:Find("ActivityBeginNotice-image")
  self.bounitMatchLock = self.bounitMatchButton:Find("Lock")
  self.bounitMatchLockMask = self.bounitMatchLock:Find("Mask-image")
  self.bounitMatchLockIcon = self.bounitMatchLock:Find("LockIcon-image")
  self.bounitMatchLockNotice = self.bounitMatchLock:Find("LockNotice-image")
  self.bounitMatchLockOpenLevel = self.bounitMatchLockNotice:FindChild("Image/OpenLevel-text")
  --右侧商城按钮及提示
  self.shopButton = self.midFrame:Find("RightPanel/ShopButton-button")
  self.shopButtonNotice = self.shopButton:Find("ShopUpdateNotice-image")
  
  --右侧活动按钮及提示
  self.activityButton = self.midFrame:Find("RightPanel/ActivityButton-button")
  self.activityButtonNotice = self.activityButton:Find("ActivityNumNotice-image")
  --self.activityButtonNoticeNum = self.activityButtonNotice:Find("Text")

  --观战按钮
  --self.watchingGameButton  = self.midFrame:Find("RightPanel/WatchingGameButton-button")

  --攻略按钮
  self.strategyButton = self.midFrame:Find("RightPanel/StrategyButton-button")
  
  --底部Button Zone面板
  self.buttonZone = self.bottomFrame:Find("ButtonZone")

  self.buttonZoneSpacing = self.bottomFrame:Find("Spacings")
  
  --底部机娘按钮及提示
  self.heroButton = self.bottomFrame:Find("ButtonZone/Hero-button")
  self.heroButtonNotice = self.heroButton:Find("UpdateNotice-image")
  
  --底部外挂装置按钮及提示
  self.runeButton = self.bottomFrame:Find("ButtonZone/Rune-button")
  self.runeButtonNotice = self.runeButton:Find("UpdateNotice-image")
  
  --底部技能按钮及提示
  self.skillButton = self.bottomFrame:Find("ButtonZone/Skill-button")
  self.skillButtonNotice = self.skillButton:Find("UpdateNotice-image")
  
  --底部整装按钮及提示
  self.preparButton = self.bottomFrame:Find("ButtonZone/Prepar-button")
  self.preparButtonNotice = self.preparButton:Find("UpdateNotice-image")
  --self.preparSubMenuPanel = self.preparButton:Find("SubMenu")
  --self.preparArrow = self.preparButton:Find("Arrow")
  --self.preparPreEquipButton = self.preparSubMenuPanel:Find("PreEquip")
  --self.preparFastMsgButton = self.preparSubMenuPanel:Find("FastMsg")
  
  
  --底部成就按钮及提示
  self.achievementButton = self.bottomFrame:Find("ButtonZone/Achievement-button")
  self.achievementButtonNotice = self.achievementButton:Find("UpdateNotice-image")
  
  --底部战队按钮及提示
  self.battleGroupButton = self.bottomFrame:Find("ButtonZone/BattleGroup-button")
  self.battleGroupButtonNotice = self.battleGroupButton:Find("UpdateNotice-image")
  self.battleGroupButtonNoticeII = self.battleGroupButton:Find("UpdateNotice-imageII")
  
  --底部背包按钮及提示
  self.packageButton = self.bottomFrame:Find("ButtonZone/Package-button")
  self.packageButtonNotice = self.packageButton:Find("UpdateNotice-image")

  --右下角按钮 
  self.waiterButton = self.bottomFrame:Find("BottomRightWaiter-button")
  --右下角信息（小红点 and tip）
  self.tipGrowGuide = self.bottomFrame:Find("GrowGuideTip")
  self.tipGrowGuide.gameObject:SetActive(false)

  --首胜倒计时
  self.firstWinCountDownNum = self.bottomFrame:Find("FirstVictory/FirstVictoryCountDown")
  self.firstWinIcon = self.bottomFrame:Find("FirstVictory/Icon")
  self.firstWinIconGray = self.bottomFrame:Find("FirstVictory/IconGray")
  self.firstWinTitle = self.bottomFrame:Find("FirstVictory/Title")
  self.firstWinAvaliable = self.bottomFrame:Find("FirstVictory/Text")
  
  --网络延迟
  self.signalBase = self.topFrame:Find("OptionAndSignal/SignalBase-image")
  self.signalImage = self.topFrame:Find("OptionAndSignal/SignalBase-image/Signal-image")
  self.signalImageYellow = self.topFrame:Find("OptionAndSignal/SignalBase-image/SignalYellow-image")
  self.signalImageRed = self.topFrame:Find("OptionAndSignal/SignalBase-image/SignalRed-image")
  self.littleSignalImage = self.signalTips:Find("Signal-image")
  self.littleSignallabel = self.signalTips:Find("SignalDelay-label")

  --主界面特效
  self.mainFx = {}
  table.insert(self.mainFx,self.midFrame:Find("PlayNowButton-button/R51140020"))
  table.insert(self.mainFx,self.midFrame:Find("PlayNowButton-button/R51140030"))
  table.insert(self.mainFx,self.fx3)
  table.insert(self.mainFx,self.fx4)

  --排行榜
  self.rankFrame = self.rootFrame.transform:FindChild("LeftRank")
  --底部聊天
  self.chatFrame = self.rootFrame:FindChild("ChatFrame")


  --测试按钮
  self.testImage = self.this.transform:Find("Root/Image")

  
  
  
  
  
  
  --按钮事件绑定
  local listener
  listener = NTGEventTriggerProxy.Get(self.heroButton.gameObject)
  local callback = function(self, e)
    self:GoToOtherPanel("PreviewHero","false")
    GameManager.CreatePanel("Waiting")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)  
  
  listener = NTGEventTriggerProxy.Get(self.preparButton.gameObject)
  local callback1 = function(self, e)
    --self:SubMenuControl()
    self:DoGoToPreEquipPanel("PreviewEquip","false")
    GameManager.CreatePanel("Waiting")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)
  
  listener = NTGEventTriggerProxy.Get(self.signalImage.gameObject)
  local callback2 = function(self, e)
    self:ShowSignalFrame()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback2, self)
  
  listener = NTGEventTriggerProxy.Get(self.playNowButton.gameObject)
  local callback3 = function(self, e)
    self:GoToOtherPanel("SelectBattleMode","false")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback3, self)
  
  listener = NTGEventTriggerProxy.Get(self.playNowButton.gameObject)
  local callback31 = function(self, e)
    self.midFrame:Find("PlayNowButton-button"):GetComponent("Animator"):SetTrigger("SizeChange")
  end
  listener.onPointerDown = NTGEventTriggerProxy.PointerEventDelegateSelf(callback31, self)

--[[
  listener = NTGEventTriggerProxy.Get(self.adventureButton.gameObject)
  local callback32 = function(self, e)
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    end    
  end
  listener.onPointerClick = listener.onPointerClick + DelegateFactory.NTGEventTriggerProxy_PointerEventDelegate_Self(self, callback32)

  listener = NTGEventTriggerProxy.Get(self.adventureButton.gameObject)
  local callback33 = function(self, e)
    self.midFrame:Find("AdventureButton-button"):GetComponent("Animator"):SetTrigger("ASC")
  end
  listener.onPointerDown = listener.onPointerDown + DelegateFactory.NTGEventTriggerProxy_PointerEventDelegate_Self(self, callback33)
  ]]
  listener = NTGEventTriggerProxy.Get(self.packageButton.gameObject)
  local callback4 = function(self, e)
    self:GoToOtherPanel("Package","false")
    GameManager.CreatePanel("Waiting")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback4, self)
  
  listener = NTGEventTriggerProxy.Get(self.achievementButton.gameObject)
  local callback5 = function(self, e)
--    GameManager.CreatePanel("SelfHideNotice")
--    if SelfHideNoticeAPI ~= nil then
--      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
--    end

    --成就面板
    self:GoToOtherPanel("Achievement","false")
    GameManager.CreatePanel("Waiting")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback5, self)
  
  
  
  listener = NTGEventTriggerProxy.Get(self.skillButton.gameObject)
  local callback6 = function(self, e)
    self:GoToOtherPanel("PlayerSkill","false")
    GameManager.CreatePanel("Waiting")
    print("PlayerSkill")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback6, self)

  listener = NTGEventTriggerProxy.Get(self.runeButton.gameObject)
  local callback7 = function(self, e)
    self:GoToOtherPanel("Rune","false")
    GameManager.CreatePanel("Waiting")
    print("Rune")
    UTGDataOperator.Instance.RunePanelEntrance = "UTGMainPanel"
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback7, self)
  
  listener = NTGEventTriggerProxy.Get(self.optionButton.gameObject)
  local callback8 = function(self, e)
    self:GoToOtherPanel("Option","false")
    GameManager.CreatePanel("Waiting")
    UTGDataOperator.Instance.WhereToUse = 0 
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback8, self)
  
--[[
  listener = NTGEventTriggerProxy.Get(self.preparPreEquipButton.gameObject)
  local callback9 = function(self, e)
    self:DoGoToPreEquipPanel("PreviewEquip","false")
    GameManager.CreatePanel("Waiting")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback9, self)

  listener = NTGEventTriggerProxy.Get(self.preparFastMsgButton.gameObject)
  local callback91 = function(self, e)
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback91, self)
 ]] 
  
  listener = NTGEventTriggerProxy.Get(self.ladderButton.gameObject)
  local callback10 = function(self, e)
    if self.CurrentSeasonResult ~= 1 then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("赛季未开始，请耐心等待")
    else
      self:GoToOtherPanel("Rank","false")
      GameManager.CreatePanel("Waiting")
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback10, self)
  
  listener = NTGEventTriggerProxy.Get(self.bounitMatchButton.gameObject)
  local callback11 = function(self, e)
    if Data.PlayerData.Level < self.levelBountyMatch then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("等级还不够参加比赛哦，加油升级吧")
    else
      self:GoToOtherPanel("MatchSystem","false")
      GameManager.CreatePanel("Waiting")
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback11, self)  
  
  
  listener = NTGEventTriggerProxy.Get(self.friendButton.gameObject)
  local callback11 = function(self, e)
    self:GoToOtherPanel("Friend","false")
    GameManager.CreatePanel("Waiting")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback11, self) 


  

  listener = NTGEventTriggerProxy.Get(self.shopButton.gameObject)
  local callbackShop = function(self, e)
--    GameManager.CreatePanel("SelfHideNotice")
--    if SelfHideNoticeAPI ~= nil then
--      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
--    end
    self:GoToOtherPanel("Store","false")
    GameManager.CreatePanel("Waiting")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackShop, self) 

  listener = NTGEventTriggerProxy.Get(self.activityButton.gameObject)
  local callbackActivity = function(self, e)
--    GameManager.CreatePanel("SelfHideNotice")
--    if SelfHideNoticeAPI ~= nil then
--      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
--    end
    local function CreatePanelAsync()
      local async = GameManager.CreatePanelAsync("Notice")
      GameManager.CreatePanel("Waiting")
      while async.Done == false do
        coroutine.wait(0.03)
      end
--      if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
--        WaitingPanelAPI.Instance:DestroySelf()
--      end
    end
    coroutine.start(CreatePanelAsync,self)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackActivity, self) 

  listener = NTGEventTriggerProxy.Get(self.waiterButton.gameObject)
  local callbackWaiter = function(self, e)
    self:GoToOtherPanel("GrowGuide","false")
    GameManager.CreatePanel("Waiting")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackWaiter, self) 

  listener = NTGEventTriggerProxy.Get(self.firstPayButton.gameObject)
  local callbackTest = function(self, e)
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackTest, self)

  listener = NTGEventTriggerProxy.Get(self.emailButton.gameObject)
  local callbackEmail = function(self, e)
    self:GoToOtherPanel("Email","false")
    --GameManager.CreatePanel("SelfHideNotice")
    --if SelfHideNoticeAPI ~= nil then
      --SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    --end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackEmail,self)

  listener = NTGEventTriggerProxy.Get(self.ticketButton.gameObject)
  local callbackTicket = function(self, e)
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackTicket, self)

  listener = NTGEventTriggerProxy.Get(self.strategyButton.gameObject)
  local callbackStrategy = function(self, e)
    GameManager.CreatePanel("SelfHideNotice")
    if SelfHideNoticeAPI ~= nil then
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
    end
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackStrategy,self)
 
  --添加监听事件
  UTGDataOperator.Instance:NoticeControl()
  self:AddEvent()


  --状态标志
  self.netDelayShowOrHide = false
  
  --self:WakeUpControl()

  self.coroutines = {}

  self:ValidLimitFreeRoleListRequest()
end

function UTGMainPanelControl:gc()
  -- body
  Data:GetTemplateFromLocal()
end

function UTGMainPanelControl:Start()

  

  self.expTips.gameObject:SetActive(false)
  self.coinTips.gameObject:SetActive(false)
  self.jewelTips.gameObject:SetActive(false)
  self.ticketTips.gameObject:SetActive(false)
  self.battleGroupButton.gameObject:SetActive(false)

  --首胜倒计时处理
  local leftTime = Data.PlayerData.NextFirstWinTime
  self.leftTime = Data:GetLeftTime(leftTime)

  if self.leftTime > 0 then
    self:DoFirstWinCountDown(self.leftTime)
  end
  self:InitPlayerInfo()
  self:InitPlayerResource()
  self:DoOperatSignalDelay()
  UTGDataTemporary.Instance():RuneDataInit() --luo符文数据初始化
  UTGDataTemporary.Instance():RankNameColor()
  UTGDataOperator.Instance:OptionChange()
  UTGDataOperator.Instance:AddNotifyPublicDataChange()


  UTGDataOperator.Instance:GlobalUsefulData()
  self:SevenButtomButton()
  
  --临时
  self.preparArrowToUpOrDown = false
  

  --特效寻找材质-临时
  for i,v in ipairs(self.mainFx) do
    local btn = self.mainFx[i]:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    for k = 0,btn.Length - 1 do
      self.mainFx[i]:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(btn[k].material.shader.name)
    end
  end

  --执行初始化notice方法
  self:InitAllNotice()
  self:InitGameTypeButton()


  --测试
  self.testImage:GetComponent(Image).sprite = UITools.GetSprite("rankicon-" .. "I18000001","I18000001")


end

function UTGMainPanelControl:Init( )
  local result = {Done = false}   
  coroutine.start(UTGMainPanelControl.InitMov,self,result)
  return result
end

function UTGMainPanelControl:InitMov(result )
  --创建排行榜面板
  local chartonmain = GameManager.CreatePanelAsync("ChartOnMain")
  while chartonmain.Done == false do
    coroutine.step()
  end
  self:InitRank()
  --创建聊天面板
  local chat = GameManager.CreatePanelAsync("Chat")
  while chat.Done == false do
    coroutine.step()
  end
  local chatSelf = chat.Panel:GetComponent(NTGLuaScript.GetType("NTGLuaScript"))
  chatSelf.self:InitChat(self.chatFrame,self.this.transform,"UTGMain")
  --添加聊天监听
  UTGDataOperator.Instance:AddNotifyChat()
  --获取赏金联赛信息
  UTGData.Instance():RequestPlayerBountyInfo()
  while UTGData.LoadPlayerBountyInfo ~= true do
    coroutine.step()
  end
  self:SendNowSeason()
  while self.wait_CurrentSeasonResult == true do
    coroutine.step()
  end
  result.Done = true
end

function UTGMainPanelControl:SendNowSeason()
  -- body
  local seasonInfoRequest = NetRequest.New()
  seasonInfoRequest.Content=JObject.New(JProperty.New("Type","RequestCurrentSeasonInfo"))
  seasonInfoRequest.Handler=TGNetService.NetEventHanlderSelf(UTGMainPanelControl.SeasonInfoHandler,self)
  TGNetService.GetInstance():SendRequest(seasonInfoRequest)
  self.wait_CurrentSeasonResult = true
end

function UTGMainPanelControl:SeasonInfoHandler(e)
  if e.Type == "RequestCurrentSeasonInfo" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    self.CurrentSeasonResult = result
    self.wait_CurrentSeasonResult = false
    return true
  end
  return false  
end




------------------------------------创建玩家资料----------------------
function UTGMainPanelControl:GoToPanel(stringPanel,playerId)  --panel名称，是否销毁当前界面
  coroutine.start(self.WaitForCreatePanel,self,stringPanel,playerId)
end

function UTGMainPanelControl:WaitForCreatePanel(stringPanel,playerId)
  local async = GameManager.CreatePanelAsync (stringPanel)
  while async.Done == false do
    coroutine.step()
  end
  
  if(PlayerDataAPI~=nil and PlayerDataAPI.Instance~=nil)then
                  --PlayerDataAPI.Instance:Show()
                  PlayerDataAPI.Instance:Init(playerId);
  end
end
-----------------------------------------------------------------------
function UTGMainPanelControl:InitPlayerInfo()
  --**********初始化头像框信息
  self.playerVip.gameObject:SetActive(false)
  --self.playerInfoNotice.gameObject:SetActive(false)
  
  --**********显示玩家头像
  self.playerHeadIcon:GetComponent("Image").sprite = UITools.GetSprite("roleicon",Data.PlayerData.Avatar)
  
  --**********显示玩家vip等级信息
  if Data.PlayerData.Vip ~= 0 then
    self.playerVip.gameObject:SetActive(true)
    self.playerVip:GetComponent("Image").sprite = UITools.GetSprite("vipicon","v"..Data.PlayerData.Vip)
  end

  function UTGMainPanelControl:UpdatePlayerName()
    -- body
    self.playerName:GetComponent("Text").text = Data.PlayerData.Name
  end
  
  --**********显示玩家信息是否有更新提示
  function UTGMainPanelControl:InitAllNotice()
    -- body
    if Data.PlayerData.Level >= 1 then
      UTGDataOperator.Instance.ladderLockAllNotice = true
    end
    if Data.PlayerData.Level >= self.levelBountyMatch then 
      UTGDataOperator.Instance.bounitMatchLockAllNotice = true
    end
  end
  
  
  --**********显示玩家姓名
  self.playerName:GetComponent("Text").text = Data.PlayerData.Name
  
  --**********显示玩家等级进度条及等级信息
  local currentExp = Data.PlayerData.Exp
  local maxExpOnCurrentLevel = Data.PlayerLevelUpData[tostring(Data.PlayerData.Level)].NextExp
  local percent = (currentExp / maxExpOnCurrentLevel) * 0.55
  self.currentExp:GetComponent("Text").text = tostring(currentExp)
  self.maxExpOnCurrentLevel:GetComponent("Text").text = tostring(maxExpOnCurrentLevel)
  self.expSlider:GetComponent("Image").fillAmount = 0.13 + percent
  self.playerLevel:GetComponent("Text").text = tostring(Data.PlayerData.Level)

  if Data.PlayerLevelUpData[tostring(Data.PlayerData.Level)].NextExp == nil then
    self.currentExp.gameObject:SetActive(false)
    self.maxExpOnCurrentLevel.gameObject:SetActive(false)
    self.expSpacing.gameObject:SetActive(false)
    self.fullLevel.gameObject:SetActive(true)
  else
    self.currentExp.gameObject:SetActive(true)
    self.maxExpOnCurrentLevel.gameObject:SetActive(true)
    self.expSpacing.gameObject:SetActive(true)
    self.fullLevel.gameObject:SetActive(false)   
  end
  
  --*********是否现实玩家信息提示标志
  if UTGDataOperator.Instance.headIconNotice == true then
    --self.playerInfoNotice.gameObject:SetActive(true)
  end

end

function UTGMainPanelControl:UpdateExpBar()
  -- body
  local currentExp = Data.PlayerData.Exp
  local maxExpOnCurrentLevel = Data.PlayerLevelUpData[tostring(Data.PlayerData.Level)].NextExp
  local percent = (currentExp / maxExpOnCurrentLevel) * 0.55
  self.currentExp:GetComponent("Text").text = tostring(currentExp)
  self.maxExpOnCurrentLevel:GetComponent("Text").text = tostring(maxExpOnCurrentLevel)
  self.expSlider:GetComponent("Image").fillAmount = 0.13 + percent
  self.playerLevel:GetComponent("Text").text = tostring(Data.PlayerData.Level)  
end

function UTGMainPanelControl:InitPlayerResource()
  --**********初始化玩家资源
  self.coinNum:GetComponent("Text").text = 0
  self.jewelNum:GetComponent("Text").text = 0
  self.ticketNum:GetComponent("Text").text = 0
  
  --**********显示玩家资源数量
  self.coinNum:GetComponent(Text).text = tostring(Data.PlayerData.Coin)
  self.jewelNum:GetComponent(Text).text = tostring(Data.PlayerData.Gem)
  self.ticketNum:GetComponent(Text).text = tostring(Data.PlayerData.Voucher)
  
  --**********显示资源tips

  
end

function UTGMainPanelControl:UpdateResource()
  -- body
  self.coinNum:GetComponent(Text).text = tostring(Data.PlayerData.Coin)
  self.jewelNum:GetComponent(Text).text = tostring(Data.PlayerData.Gem)
  self.ticketNum:GetComponent(Text).text = tostring(Data.PlayerData.Voucher) 
end

function UTGMainPanelControl:InitTopOther()
  
  --**********初始化上半部分其他信息提示
  self.newFriendNotice.gameObject:SetActive(false)
  self.newEmailNotice.gameObject:SetActive(false)
  
  --**********有新的好友申请
  if UTGDataOperator.Instance.friendNotice == true then
    self.newFriendNotice.gameObject:SetActive(true)
  end
  
  --**********有新的邮件提示
  if UTGDataOperator.Instance.emailNotice == true then
    self.newEmailNotice.gameObject:SetActive(true)
  end
end

function UTGMainPanelControl:InitGameTypeButton()
  --**********初始化各模式按钮的提示消息
  self.playNowNewNotice.gameObject:SetActive(false)
  self.playNowActivityBeginNotice.gameObject:SetActive(false)
  
  --self.adventureNewNotice.gameObject:SetActive(false)
  --self.adventureActivityBeginNotice.gameObject:SetActive(false)
  
  self.ladderNewNotice.gameObject:SetActive(false)
  self.ladderActivityBeginNotice.gameObject:SetActive(false)
  self.ladderLock.gameObject:SetActive(true)
  
  self.bounitMatchNewNotice.gameObject:SetActive(false)
  self.bounitMatchActivityBeginNotice.gameObject:SetActive(false)
  self.bounitMatchLock.gameObject:SetActive(true)
  
  --**********是否显示对战模式提示
  if UTGDataOperator.Instance.playNowNotice == true then
    self.playNowNewNotice.gameObject:SetActive(true)
  end
  
  if UTGDataOperator.Instance.playNowActivityNotice == true then
    self.playNowActivityBeginNotice.gameObject:SetActive(true)
  end
  
  --**********是否显示冒险模式提示
  --if UTGDataOperator.Instance.adventureNotice == true then
    --self.adventureNewNotice.gameObject:SetActive(true)
  --end
  
  --if UTGDataOperator.Instance.adventureActivityNotice == true then
    --self.adventureActivityBeginNotice.gameObject:SetActive(true)
  --end
  
  --**********是否显示排位赛模式提示及锁
  if UTGDataOperator.Instance.ladderLockAllNotice == true then
    self.ladderLock.gameObject:SetActive(false)
    if UTGDataOperator.Instance.ladderNotice == true then
      self.ladderNewNotice.gameObject:SetActive(false)
    end
    
    if UTGDataOperator.Instance.ladderActivityNotice == true then
      self.ladderActivityBeginNotice.gameObject:SetActive(true)
    end
  end
  
  --**********是否显示赏金联赛模式提示及锁
  if UTGDataOperator.Instance.bounitMatchLockAllNotice == true then
    self.bounitMatchLock.gameObject:SetActive(false)
    if UTGDataOperator.Instance.bounitMatchNotice == true then
      self.bounitMatchNewNotice.gameObject:SetActive(false)
    end
  else
    self.bounitMatchLock.gameObject:SetActive(true)
    self.bounitMatchLockOpenLevel:GetComponent("UnityEngine.UI.Text").text = ""..self.levelBountyMatch
  end
  if UTGDataOperator.Instance.bounitMatchActivityNotice == true then
    self.bounitMatchActivityBeginNotice.gameObject:SetActive(true)
  end 
end

function UTGMainPanelControl:InitRank()
  -- body
  if ChartAPI ~= nil and ChartAPI.Instance ~= nil then
    ChartAPI.Instance:SetPos(self.rankFrame,"UTGMain")
  end
end



function UTGMainPanelControl:InitMidRightPanel()
  --**********初始化
  self.shopButtonNotice.gameObject:SetActive(false)
  self.activityButtonNotice.gameObject:SetActive("false")
  --self.activityButtonNoticeNum:GetComponent(Text).text = 0
  
  --**********商城提示是否显示
  if UTGDataOperator.Instance.shopNotice == true then
    self.shopButtonNotice.gameObject:SetActive(true)
  end
  
  --**********活动提示是否显示
  if UTGDataOperator.Instance.activityNotice == true then
    self.activityButtonNotice.gameObject:SetActive(true)
    --self.activityButtonNoticeNum:GetComponent(Text).text = self.activityNoticeCount
  end
end

function UTGMainPanelControl:InitBottomButtonZone()
  --**********初始化
  --实现添加按钮数量的功能
  self.runeButtonNotice.gameObject:SetActive(false)
  self.heroButtonNotice.gameObject:SetActive(false)
  self.skillButtonNotice.gameObject:SetActive(false)
  self.preparButtonNotice.gameObject:SetActive(false)
  self.achievementButtonNotice.gameObject:SetActive(false)
  self.packageButtonNotice.gameObject:SetActive(false)
  self.preparSubMenu.gameObject:SetActive(false)
  
  --**********是否显示提示
end

--大喇叭移动
function UTGMainPanelControl:AnnounsmentMove(text)
  --local count = 1
  local time = 0
  --local position = self.bigHorn:GetComponent("RectTransform").localPosition
  local color = self.bigHornLight:GetComponent("Image").color
  local alpha = 1
  local dic = 0
  local txt = self.bigHorn:FindChild("BigHornWord-label")
  txt:GetComponent("UnityEngine.UI.Text").text = text
  local startposX = 240
  local startpos = Vector3.New(startposX,self.bigHorn.localPosition.y,self.bigHorn.localPosition.z)
  self.bigHorn.localPosition = startpos
  self.bigHornBg.gameObject:SetActive(true)
  coroutine.wait(0.05)
  local temp = -(startposX+(self.bigHorn:GetComponent(NTGLuaScript.GetType("UnityEngine.UI.HorizontalLayoutGroup")).preferredWidth))
  --Debugger.LogError(temp.."  "..txt.localPosition.x.."  "..(self.bigHorn:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.x))
  while time<30 do 
    coroutine.step()
    self.bigHorn.localPosition = self.bigHorn.localPosition + Vector3.New(-0.5,0,0)
    if self.bigHorn.localPosition.x<= temp then 
      self.bigHorn.localPosition = startpos
    end
    if dic == 0 then
      alpha = alpha - 0.01
      if alpha < 0 then
        dic = 1
      end
    elseif dic == 1 then
      alpha = alpha + 0.01
      if alpha > 1 then
        dic = 0
      end
    end
    self.bigHornLight:GetComponent("Image").color = color.New(color.r,color.g,color.b,alpha)
    self.bigHornBg:GetComponent("Image").color = color.New(1,1,1,alpha + 0.5)
    time = time+Time.deltaTime
  end
  self.bigHornBg.gameObject:SetActive(false)
  self.bigHornMove = nil 
--[[
  while count > 0 do
    if count > 700 then
      self.bigHorn:GetComponent("RectTransform").localPosition = position
      count = 1
      time = time + 1
    end
    self.bigHorn:GetComponent("RectTransform").localPosition = Vector3.New(self.bigHorn:GetComponent("RectTransform").localPosition.x - 1,position.y,0)
    count = count + 1
    
    if dic == 0 then
      alpha = alpha - 0.01
      if alpha < 0 then
        dic = 1
      end
    elseif dic == 1 then
      alpha = alpha + 0.01
      if alpha > 1 then
        dic = 0
      end
    end
    
    
    coroutine.yield(WaitForSeconds.New(0.01))
    if time == 5 then
      self.this:StopCoroutine(self.bigHornMove)
    end
  end 
  ]]
end
--大喇叭移动实现
function UTGMainPanelControl:BigHornMove(text)
  if self.bigHornMove ~=nil then coroutine.stop(self.bigHornMove) end
  self.bigHornMove = coroutine.start(self.AnnounsmentMove,self,text)
end

--首胜倒计时
function UTGMainPanelControl:FirstWinCountDown(leftTime)
  self.firstWinIcon.gameObject:SetActive(false)
  self.firstWinIconGray.gameObject:SetActive(true)
  self.firstWinTitle.gameObject:SetActive(true)
  self.firstWinCountDownNum.gameObject:SetActive(true)
  self.firstWinAvaliable.gameObject:SetActive(false)
  local hour = math.floor(leftTime/3600)
  local min = math.floor((leftTime-hour*3600)/60)
  local sec = leftTime - (hour * 3600) - (min * 60)
  while hour > 0 do
    sec = sec - 1
    if sec == 0 then
      min = min - 1
      sec = 59
      if min == 0 then
        hour = hour - 1
        min = 59
      end
    end
    self.firstWinIcon.gameObject:SetActive(false)
    self.firstWinIconGray.gameObject:SetActive(true)
    self.firstWinCountDownNum:GetComponent("Text").text = string.format("%02d:%02d:%02d",hour,min,sec)
    coroutine.wait(1)
  end
  
  self.firstWinIcon.gameObject:SetActive(true)
  self.firstWinIconGray.gameObject:SetActive(false)
  self.firstWinTitle.gameObject:SetActive(false)
  self.firstWinCountDownNum.gameObject:SetActive(false)
  self.firstWinAvaliable.gameObject:SetActive(true)
  
end
--首胜倒计时实现
function UTGMainPanelControl:DoFirstWinCountDown(leftTime)
  table.insert(self.coroutines,coroutine.start(UTGMainPanelControl.FirstWinCountDown, self, leftTime))
end

--信号标志
function UTGMainPanelControl:OperatSignalDelay()
  local count = 1
  local ms = 0
  while count > 0 do
    ms = TGNetService.GetServerLatency()
    --ms = ms + 20
    if ms < 100 then
      self.signalImage.gameObject:SetActive(true)
      self.signalImageYellow.gameObject:SetActive(false)
      self.signalImageRed.gameObject:SetActive(false)
      --self.littleSignalImage:GetComponent(Image).sprite = UITools.GetSprite("UTGMain","UMainPanel-LittleSignalGreen")
      self.littleSignalImage.parent:Find("Signal-imageRed").gameObject:SetActive(false)
      self.littleSignalImage.parent:Find("Signal-imageYellow").gameObject:SetActive(false)
      self.littleSignalImage.gameObject:SetActive(true)
      self.littleSignallabel:GetComponent(Text).color = Color.New(121/255, 254/255, 99/255, 1)
    elseif ms > 100 and ms < 300 then
      self.signalImage.gameObject:SetActive(false)
      self.signalImageYellow.gameObject:SetActive(true)
      self.signalImageRed.gameObject:SetActive(false)
      --self.littleSignalImage:GetComponent(Image).sprite = UITools.GetSprite("UTGMain","UMainPanel-LittleSignalYellow")
      self.littleSignalImage.parent:Find("Signal-imageRed").gameObject:SetActive(false)
      self.littleSignalImage.parent:Find("Signal-imageYellow").gameObject:SetActive(true)
      self.littleSignalImage.gameObject:SetActive(false)
      self.littleSignallabel:GetComponent(Text).color = Color.New(255/255, 246/255, 97/255, 1)
    elseif ms > 300 then
      self.signalImage.gameObject:SetActive(false)
      self.signalImageYellow.gameObject:SetActive(false)
      self.signalImageRed.gameObject:SetActive(true)
      --self.littleSignalImage:GetComponent(Image).sprite = UITools.GetSprite("UTGMain","UMainPanel-LittleSignalRed")
      self.littleSignalImage.parent:Find("Signal-imageRed").gameObject:SetActive(true)
      self.littleSignalImage.parent:Find("Signal-imageYellow").gameObject:SetActive(false)
      self.littleSignalImage.gameObject:SetActive(false)
      self.littleSignallabel:GetComponent(Text).color = Color.New(214/255, 21/255, 21/255, 1)
    end
    
    self.littleSignallabel:GetComponent(Text).text = ms .. "ms"
    coroutine.wait(1)
  end
end
function UTGMainPanelControl:DoOperatSignalDelay()
  table.insert(self.coroutines,coroutine.start(UTGMainPanelControl.OperatSignalDelay,self))
end

function UTGMainPanelControl:ShowSignalFrame()
  if self.netDelayShowOrHide == false then
    self.signalTips.localPosition = Vector3.New(586.7,267.12,0)
    self.netDelayShowOrHide = true
  else 
    self.signalTips.localPosition = Vector3.New(694.6,267.12,0)
    self.netDelayShowOrHide = false
  end
end

--[[
function UTGMainPanelControl:SubMenuControl()
  if self.preparArrowToUpOrDown == false then
    self.preparSubMenuPanel.gameObject:SetActive(true)
    self.preparArrow.localEulerAngles = Vector3.New(0,0,0)
    self.preparArrowToUpOrDown = true
    self.preparButton:Find("Image").gameObject:SetActive(true)
  else
    self.preparSubMenuPanel.gameObject:SetActive(false)
    self.preparArrow.localEulerAngles = Vector3.New(0,0,180)
    self.preparArrowToUpOrDown = false
    self.preparButton:Find("Image").gameObject:SetActive(false)
  end
end


function UTGMainPanelControl:InitSubMenu()
  -- body
    self.preparSubMenuPanel.gameObject:SetActive(false)
    self.preparArrow.localEulerAngles = Vector3.New(0,0,180)
    self.preparArrowToUpOrDown = false
    self.preparButton:Find("Image").gameObject:SetActive(false) 
end
]]

function UTGMainPanelControl:SevenButtomButton()
  --战队玩法等级限制
  local UnlockLevel;
  for k,v in pairs(UTGData.Instance().LevelFunc) do  
    for k1,v1 in pairs(v) do 
      if(v1.Type==5)then
        UnlockLevel=v1.UnlockLevel
        break
      end
    end
  end
  if(UTGData.Instance().PlayerData.Level<UnlockLevel)then return end 

  --self.preparPreEquipButton:GetComponent(RectTrans).sizeDelta = Vector2.New(158.33,self.preparPreEquipButton:GetComponent(RectTrans).sizeDelta.y)
  --self.preparFastMsgButton:GetComponent(RectTrans).sizeDelta = Vector2.New(158.33,self.preparFastMsgButton:GetComponent(RectTrans).sizeDelta.y)
  --print(self.buttonZone:GetComponent("UnityEngine.UI.GridLayoutGroup").cellSize.x .. " " .. self.buttonZone:GetComponent("UnityEngine.UI.GridLayoutGroup").cellSize.y)
  self.buttonZone:GetComponent("UnityEngine.UI.GridLayoutGroup").cellSize = Vector2.New(158.33,58)
  --print(self.buttonZone:GetComponent("UnityEngine.UI.GridLayoutGroup").cellSize.x .. " " .. self.buttonZone:GetComponent("UnityEngine.UI.GridLayoutGroup").cellSize.y)
  --self.buttonZone:GetComponent("UnityEngine.UI.GridLayoutGroup").cellSize = Vector2.New(1,1)
  self.battleGroupButton.gameObject:SetActive(true)
  --进入战队界面
  local listener = NTGEventTriggerProxy.Get(self.battleGroupButton.gameObject)  
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function () 
        
        if(UTGData.Instance().PlayerData.GuildStatus==0)then      --未加入战队-->战队列表
          self:CreatePanelAsync("GuildNo") 
        elseif(UTGData.Instance().PlayerData.GuildStatus==1)then  --已加入战队
          self:CreatePanelAsync("GuildHave") 
        elseif(UTGData.Instance().PlayerData.GuildStatus==2)then  --筹备中
          self:CreatePanelAsync("GuildNo")   
        elseif(UTGData.Instance().PlayerData.GuildStatus==3)then  --申请中
        
        end

        
        --self:GoToOtherPanel("Guild",false)
        GameManager.CreatePanel("Waiting")
      end 
      , self)

  self.buttonZoneSpacing:GetComponent("UnityEngine.UI.GridLayoutGroup").padding.left = 155
  self.buttonZoneSpacing:GetComponent("UnityEngine.UI.GridLayoutGroup").spacing = Vector2.New(149.4,0)
  for i = 1,self.buttonZoneSpacing.childCount do
    self.buttonZoneSpacing:GetChild(i-1).gameObject:SetActive(true)
  end

  if UTGDataOperator.Instance.battleGroupButtonNotice == true then
    self.battleGroupButtonNotice.gameObject:SetActive(true)
  end 
  if UTGDataOperator.Instance.battleGroupButtonNoticeII == true then
    self.battleGroupButtonNoticeII.gameObject:SetActive(true)
  end

end

------------------------------------------------------------------------------
function UTGMainPanelControl:CreatePanelAsync(name)
  -- body
  coroutine.start(self.CreatePanelAsyncCo, self,name) 

end

function UTGMainPanelControl:CreatePanelAsyncCo(name)
  -- body
  local async = GameManager.CreatePanelAsync(name)
  while async.Done == false do
    coroutine.step()
  end
  --
end
------------------------------------------------------------------------------
function UTGMainPanelControl:GoToOtherPanel(panelname,show,fun,funself)
  if self.isMatching == true then

  else
    if fun ~= nil then
      coroutine.start(UTGMainPanelControl.GoToOtherPanelCoroutine,self,panelname,show,fun,funself)
    else 
      coroutine.start(UTGMainPanelControl.GoToOtherPanelCoroutine,self,panelname,show)
    end
  end
    
end

function UTGMainPanelControl:GoToOtherPanelCoroutine(panelname,show,fun,funself)
  local async = GameManager.CreatePanelAsync(panelname)
  while async.Done == false do
    coroutine.step()
  end
  if async.Done == true and fun ~= nil then
    fun(funself)
  end        
  
  if StoreCtrl ~= nil and StoreCtrl.Instance ~= nil then
    StoreCtrl.Instance:partActive(0)
  end
  
  if show == "true" then
    self.this.gameObject:SetActive(true)
  else 
    self:HideMainPanel()  
  end 

  if WaitingPanelAPI~=nil and WaitingPanelAPI.Instance~=nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end
end

function UTGMainPanelControl:DoGoToPreEquipPanel(name,show)

  coroutine.start(UTGMainPanelControl.GoToPreEquipPanel,self,name,show) 
end

function UTGMainPanelControl:GoToPreEquipPanel(name,show)
  local async = GameManager.CreatePanelAsync("PreviewEquip")
  while async.Done == false do
    coroutine.step()
  end
  
  if PreviewEquipAPI ~= nil and PreviewEquipAPI.Instance ~= nil then
    PreviewEquipAPI.Instance:Initialize()
  end
  
  if show == "true" then
    
  else 
    self:HideMainPanel()
  end
end

function UTGMainPanelControl:HideMainPanel()
  -- body
  --print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
  self.rootFrame.transform.localPosition = Vector3.New(0,1000,0) 
end

function UTGMainPanelControl:ShowMainPanel()
  -- body
  self.rootFrame.transform.localPosition = Vector3.New(0,0,0)
end


function UTGMainPanelControl:Test1()
  if NoticeAPI.Instance ~= nil then
    NoticeAPI.Instance:InitNoticeForNeedConfirmNotice("未探索区域","该地域还未侦查，容我先插个眼",true,"",2)
    NoticeAPI.Instance:TwoButtonEvent("Cancel",UTGMainPanelControl.Test2,self,"Enter",UTGMainPanelControl.Test3,self)
  end

end



function  UTGMainPanelControl:NRTest()
  -- body
  if NormalResourceAPI ~= nil and NormalResourceAPI.Instance ~= nil then
    NormalResourceAPI.Instance:GoToPosition("UTGMainPanel")
    NormalResourceAPI.Instance:ShowControl(1)
    NormalResourceAPI.Instance:InitTop(self,UTGMainPanelControl.Test4,nil,nil,"测试成功")
  end  
end

function UTGMainPanelControl:Test2()
  --实装时需添加解锁条件限定
  SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中")
  --NoticeAPI.Instance:DestroySelf()
end

function UTGMainPanelControl:Test3()
  MatchingAPI.Instance:CancelButtonControl(0)
end

function  UTGMainPanelControl:Test4()
  -- body
  --print(self.playerHeadIcon.name)
end

function  UTGMainPanelControl:Test5()
  -- body
  --print("HAHAHAHAHAHAHAHAHAHAHA")
end
--显示召唤师技能小红点
function UTGMainPanelControl:InitPlayerSkillRedPoint()
  if UTGDataOperator.Instance.skillNotice == true then
    self.skillButtonNotice.gameObject:SetActive(true)
  else
    self.skillButtonNotice.gameObject:SetActive(false)
  end
end
--显示成就领取小红点
function UTGMainPanelControl:InitAchieveRedPoint()
  local isRed = UTGDataOperator.Instance:isAchieveAwardCanGet()
  if (isRed == true) then
    print("UTGMainPanelControl:InitAchieveRedPoint true")
  elseif (isRed == false) then
    print("UTGMainPanelControl:InitAchieveRedPoint false")
  end
  local red = self.buttonZone:FindChild("Achievement-button/UpdateNotice-image")
  red.transform.gameObject:SetActive(isRed)

end
--显示商城小红点
function UTGMainPanelControl:InitStoreRedPoint()
  local leftTimeSeconds = UTGData.Instance():GetLeftTime(UTGData.Instance().PlayerShopsDeck.NextFreeRollRuneOnceByGemTime)
  UTGDataOperator.Instance.shopNotice = false
  if(leftTimeSeconds>0) then
    self.shopButtonNotice.gameObject:SetActive(false)
  else
    UTGDataOperator.Instance.shopNotice = true
    self.shopButtonNotice.gameObject:SetActive(true)
  end
end


--活动小红点
function UTGMainPanelControl:InitActiRed()
  local isRed = UTGDataOperator.Instance.actiRed
  --local red = self.buttonZone:FindChild("ActivityButton-button/ActivityNumNotice-image")
  self.activityButtonNotice.gameObject:SetActive(isRed)
  if (isRed == true) then
    print("UTGMainPanelControl:InitActiRed true")
  elseif (isRed == false) then
    print("UTGMainPanelControl:InitActiRed false")
  end
end

function  UTGMainPanelControl:InitGrowGuideTip()
  local growDeck = UTGData.Instance().PlayerGrowUpDeck
  local count = 0
  local tip = ""  
  self.tipGrowGuide.gameObject:SetActive(true)
  self.tipGrowGuide:FindChild("Red").gameObject:SetActive(false)
  self.tipGrowGuide:FindChild("Tip").gameObject:SetActive(false)
  for k,v in pairs(growDeck) do
    local growdata = UTGData.Instance().GrowUpsData[tostring(v.GrowUpId)]
    if growdata~=nil then 
      --print
      if v.Progress>=growdata.MaxProgress and v.IsDrew == false then 
        count = count+1
      end
    end
  end
  local levelAward = UTGDataOperator.Instance:LevelAwardCntGet()
  local questAward = UTGDataOperator.Instance:QuestAwardCntGet()
  count = count + levelAward
  count = count + questAward
  if count >0 then 
    self.tipGrowGuide:FindChild("Red").gameObject:SetActive(true)
    self.tipGrowGuide:FindChild("Red/Text"):GetComponent("UnityEngine.UI.Text").text = ""..count
    tip = "您有奖励可以领取呦~" 
  else
    local minId = 99999
    local isComplete = false
    for k,v in pairs(UTGData.Instance().GrowUpsData) do
      isComplete = false
      for k1,v1 in pairs(growDeck) do
        if tonumber(v1.GrowUpId) == tonumber(v.Id) and v1.Progress>=v.MaxProgress then
          isComplete = true
        end
      end
      if isComplete == false and v.Id<minId then
        minId = v.Id
        tip = v.Tips 
      end
    end
  end
  if tip == "" then
    --Debugger.LogError("tip == nil")
    return
  end
  
  if self.cor_growtip~=nil then 
    coroutine.stop(self.cor_growtip)
  end

  self.cor_growtip = coroutine.start(self.GrowGuideTipMov,self,tip)
end
function  UTGMainPanelControl:GrowGuideTipMov(text)
  self.time_growtip =self.time_growtip or 0
  self.tipGrowGuide:FindChild("Tip/Text"):GetComponent("UnityEngine.UI.Text").text = text
  while true do 
    coroutine.step()
    self.time_growtip = self.time_growtip+Time.deltaTime
    if self.time_growtip<10 then 
      self.tipGrowGuide:FindChild("Tip").gameObject:SetActive(true) 
    elseif self.time_growtip<30 then 
      self.tipGrowGuide:FindChild("Tip").gameObject:SetActive(false)
    else
      self.time_growtip = 0
    end
  end

end


function  UTGMainPanelControl:UpdateNotice()
  -- body
  self.newFriendNotice.gameObject:SetActive(false)
  self.newEmailNotice.gameObject:SetActive(false)
  self.playNowNewNotice.gameObject:SetActive(false)
  self.playNowActivityBeginNotice.gameObject:SetActive(false)  
  --self.adventureNewNotice.gameObject:SetActive(false)
  --self.adventureActivityBeginNotice.gameObject:SetActive(false)
  self.ladderNewNotice.gameObject:SetActive(false)
  self.ladderActivityBeginNotice.gameObject:SetActive(false)
  self.ladderLock.gameObject:SetActive(true) 
  self.bounitMatchNewNotice.gameObject:SetActive(false)
  self.bounitMatchActivityBeginNotice.gameObject:SetActive(false)
  self.bounitMatchLock.gameObject:SetActive(true)
  self.shopButtonNotice.gameObject:SetActive(false)
  self.activityButtonNotice.gameObject:SetActive(false)
  --self.activityButtonNoticeNum:GetComponent(Text).text = 0
  self.runeButtonNotice.gameObject:SetActive(false)
  self.heroButtonNotice.gameObject:SetActive(false)
  self.skillButtonNotice.gameObject:SetActive(false)
  self.preparButtonNotice.gameObject:SetActive(false)
  self.achievementButtonNotice.gameObject:SetActive(false)
  self.packageButtonNotice.gameObject:SetActive(false)
  --self.preparSubMenu.gameObject:SetActive(false)
  self.battleGroupButtonNotice.gameObject:SetActive(false)
  self.battleGroupButtonNoticeII.gameObject:SetActive(false)

  
  
 
  self.newFriendNotice.gameObject:SetActive( UTGDataOperator.Instance.friendNotice)
  
  if UTGDataOperator.Instance.emailNotice == true then
    self.newEmailNotice.gameObject:SetActive(true)
  end 

  if UTGDataOperator.Instance.playNowNotice == true then
    self.playNowNewNotice.gameObject:SetActive(true)
  end
  
  if UTGDataOperator.Instance.playNowActivityNotice == true then
    self.playNowActivityBeginNotice.gameObject:SetActive(true)
  end
  
  --**********是否显示冒险模式提示
  --if UTGDataOperator.Instance.adventureNotice == true then
    --self.adventureNewNotice.gameObject:SetActive(true)
  --end
  
  --if UTGDataOperator.Instance.adventureActivityNotice == true then
    --self.adventureActivityBeginNotice.gameObject:SetActive(true)
  --end
  
  --**********是否显示排位赛模式提示及锁
  if UTGDataOperator.Instance.ladderLockAllNotice == true then
    self.ladderLock.gameObject:SetActive(false)
    if UTGDataOperator.Instance.ladderNotice == true then
      self.ladderNewNotice.gameObject:SetActive(false)
    end
    
    if UTGDataOperator.Instance.ladderActivityNotice == true then
      self.ladderActivityBeginNotice.gameObject:SetActive(true)
    end
  end
  
  --**********是否显示赏金联赛模式提示及锁
  if UTGDataOperator.Instance.bounitMatchLockAllNotice == true then
    self.bounitMatchLock.gameObject:SetActive(false)
    if UTGDataOperator.Instance.bounitMatchNotice == true then
      self.bounitMatchNewNotice.gameObject:SetActive(false)
    end
    
    if UTGDataOperator.Instance.bounitMatchActivityNotice == true then
      self.bounitMatchActivityBeginNotice.gameObject:SetActive(true)
    end
  end

  if UTGDataOperator.Instance.shopNotice == true then
    self.shopButtonNotice.gameObject:SetActive(true)
  end
  
  --**********活动提示是否显示
--  if UTGDataOperator.Instance.actiRed == true then
--    self.activityButtonNotice.gameObject:SetActive(true)
--    self.activityButtonNoticeNum:GetComponent(Text).text = self.activityNoticeCount
--  end
  if (UTGDataOperator.Instance.actiRed == true) then
    print("UTGMainPanelControl:UpdateNotice = true")
  elseif (UTGDataOperator.Instance.actiRed == false) then
    print("UTGMainPanelControl:UpdateNotice = false")
  end
  self.activityButtonNotice.gameObject:SetActive(UTGDataOperator.Instance.actiRed)

  if UTGDataOperator.Instance.heroNotice == true then
    self.heroButtonNotice.gameObject:SetActive(true)
  end

  if UTGDataOperator.Instance.runeNotice == true then
    self.runeButtonNotice.gameObject:SetActive(true)
  end

  if UTGDataOperator.Instance.skillNotice == true then
    self.skillButtonNotice.gameObject:SetActive(true)
  end

  if UTGDataOperator.Instance.prepareNotice == true then
    self.preparButtonNotice.gameObject:SetActive(true)
  end

  --成就红点
  local redAchieve = UTGDataOperator.Instance:isAchieveAwardCanGet()
  self.achievementButtonNotice.gameObject:SetActive(redAchieve)
--  if UTGDataOperator.Instance.achievementNotice == true then
--    self.achievementButtonNotice.gameObject:SetActive(true)
--  end

  if UTGDataOperator.Instance.packageNotice == true then
    self.packageButtonNotice.gameObject:SetActive(true)
  end

  self.battleGroupButtonNotice.gameObject:SetActive(UTGDataOperator.Instance.battleGroupButtonNotice)
  self.battleGroupButtonNoticeII.gameObject:SetActive(UTGDataOperator.Instance.battleGroupButtonNoticeII)

end

--启动全局监听消息
function UTGMainPanelControl:AddEvent()
  self.invitationNotify = UTGDataOperator.Instance:AddEventHandler("NotifyInvitation",UTGDataOperator.Instance.Invitation)
  --UTGDataOperator.Instance:AddEventHandler("NotifyRoomChange",UTGDataOperator.Instance.OnRoomChangeHandler)
  --UTGDataOperator.Instance:AddEventHandler("NotifyPartyChange",UTGDataOperator.Instance.OnPartyChangeHandler)
  UTGDataOperator.Instance:AddEventHandler("NotifyFriendStatus",UTGDataOperator.Instance.UpdateFriendStatus)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerCurrencyChange",UTGDataOperator.Instance.NotifyPlayerCurrencyChange)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerRoleChange",UTGDataOperator.Instance.NotifyPlayerRoleChange)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerSkinChange",UTGDataOperator.Instance.NotifyPlayerSkinChange)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerRuneChange",UTGDataOperator.Instance.NotifyPlayerRuneChange)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerRunePageChange",UTGDataOperator.Instance.NotifyPlayerRunePageChange)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerRuneSlotChange",UTGDataOperator.Instance.NotifyPlayerRuneSlotChange)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerItemChange",UTGDataOperator.Instance.NotifyPlayerItemChange)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerFriendChange",UTGDataOperator.Instance.NotifyPlayerFriendChange)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerOffline",UTGDataOperator.Instance.NotifyPlayerOffline)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerGradeChange",UTGDataOperator.Instance.NotifyPlayerGradeChange)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerShopChange",UTGDataOperator.Instance.NotifyPlayerShopChange)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerMailChange",UTGDataOperator.Instance.NotifyPlayerMailChange)
  UTGDataOperator.Instance:AddEventHandler("NotifyRewards",UTGDataOperator.Instance.NotifyPlayerReward)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerNew",UTGDataOperator.Instance.NotifyPlayerNew)
  UTGDataOperator.Instance:AddEventHandler("NotifyTips",UTGDataOperator.Instance.NotifyTips)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerNewExperience",UTGDataOperator.Instance.NotifyPlayerNewExperience)
  UTGDataOperator.Instance:AddEventHandler("NotifyPlayerAvatarFrameChange",UTGDataOperator.Instance.NotifyPlayerAvatarFrameChange)
  
end

function UTGMainPanelControl:AudioControl(volume)
  -- body
  self.this.transform:GetComponent(NTGLuaScript.GetType("UnityEngine.AudioSource")).volume = volume
end

function UTGMainPanelControl:ValidLimitFreeRoleListRequest() --RequestValidLimitFreeRoleList

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestValidLimitFreeRoleList")
                         
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.ValidLimitFreeRoleListResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function UTGMainPanelControl:ValidLimitFreeRoleListResponseHandler(e)

  if e.Type == "RequestValidLimitFreeRoleList" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
     
    elseif(data.Result==1)then
      UTGDataTemporary.Instance().LimitedData = data.List 
    end

    return true;
  else
    return false;
  end

end





function UTGMainPanelControl:OnDestroy()

  if self.cor_growtip~=nil then 
    coroutine.stop(self.cor_growtip)
  end
  if self.bigHornMove~=nil then coroutine.stop(self.bigHornMove) end
  for i = 1,#self.coroutines do
    coroutine.stop(self.coroutines[i])
  end

  UTGDataOperator.Instance:RemoveEventHandler("NotifyInvitation")

  self.playNowButton:GetComponent(Image).sprite = nil
  --self.adventureButton:GetComponent(Image).sprite = nil
  self.topFrame:Find("TopFrameBase"):GetComponent(Image).sprite = nil
  self.ladderButton:GetComponent(Image).sprite = nil
  self.ladderButton:Find("Lock/Mask-image"):GetComponent(Image).sprite = nil
  self.bounitMatchButton:GetComponent(Image).sprite = nil
  self.bounitMatchButton:Find("Lock/Mask-image"):GetComponent(Image).sprite = nil
  self.topFrame:Find("TopFrameBase2"):GetComponent(Image).sprite = nil
  self.midFrame:Find("NoticeBar/BigHornBg/Light"):GetComponent(Image).sprite = nil
  self.playerName:GetComponent(Text).font = nil
  self.coinNum:GetComponent(Text).font = nil
  self.jewelNum:GetComponent(Text).font = nil
  self.ticketNum:GetComponent(Text).font = nil
  --self.ladderLockOpenLevel:GetComponent(Text).font = nil
  --self.bounitMatchLockOpenLevel:GetComponent(Text).font = nil
  self.currentExp:GetComponent(Text).font = nil
  self.maxExpOnCurrentLevel:GetComponent(Text).font = nil
  self.playerLevel:GetComponent(Text).font = nil
  --self.activityButtonNoticeNum:GetComponent(Text).font = nil
  self.firstWinCountDownNum:GetComponent(Text).font = nil
  self.littleSignallabel:GetComponent(Text).font = nil
  --self.activityButtonNoticeNum:GetComponent(Text).font = nil


  self.this = nil
  self = nil


end









