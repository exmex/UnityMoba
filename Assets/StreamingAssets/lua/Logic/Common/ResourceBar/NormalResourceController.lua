require "System.Global"

class("NormalResourceController")

local Data = UTGData.Instance()
local Text = "Text"
local Image = "Image"
local Slider = "Slider"
local RectTrans = "RectTransform"

function NormalResourceController:Awake(this)
  self.this = this
  self.panel = self.this.transforms[0]
  self.top = self.this.transforms[1]

  self.signalBase = self.panel:Find("SignalBase-image")
  self.signalImage = self.panel:Find("SignalBase-image/SignalGreen-image")
  self.signalImageYellow = self.panel:Find("SignalBase-image/SignalYellow-image")
  self.signalImageRed = self.panel:Find("SignalBase-image/SignalRed-image")
  self.littleSignalImage = self.panel:Find("SignalTips/Signal-image")
  self.littleSignallabel = self.panel:Find("SignalTips/SignalDelay-label")
  self.signalTips = self.panel:Find("SignalTips")

  self.netDelayShowOrHide = false

  self.coroutines = {}

local listener
--返回按钮事件
listener = NTGEventTriggerProxy.Get(self.signalBase.gameObject)
local callback = function(self, e)
	self:ShowSignalFrame()
end	
listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)

end

function NormalResourceController:Start()
end

function NormalResourceController:GoToPosition(name)
	local parent = ""
	if GameManager.PanelRoot:FindChild(name) ~= nil then
		parent = GameManager.PanelRoot:FindChild(name)
		self.panel.parent.parent:SetParent(parent)
		self.panel.parent.parent.localPosition = Vector3.New(0,310,0)
	end  
  --self.panel.localPosition = Vector3.New((self.panel.parent:GetComponent(RectTrans).sizeDelta.x - self.panel:GetComponent(RectTrans).sizeDelta.x)/2,
  --                                          self.panel:GetComponent(RectTrans).sizeDelta.y,0)
  --self.top.localPosition = Vector3.New(0,(-self.top.parent:GetComponent(RectTrans).sizeDelta.y/2 + self.top:GetComponent(RectTrans).sizeDelta.y/2),0)
end

function  NormalResourceController:ShowControl(num)
	-- body
	self.num = num
	if num == 1 then
		self.top.gameObject:SetActive(true)
		self.panel.gameObject:SetActive(false)
	elseif num == 2 then
		self.top.gameObject:SetActive(false)
		self.panel.gameObject:SetActive(true)
	elseif num == 3 then
		self.top.gameObject:SetActive(true)
		self.top:Find("Right/ButtonRule").gameObject:SetActive(false)
		self.panel.gameObject:SetActive(true)
	end
end

function  NormalResourceController:TopPanelInfo(funself,fun,funself1,fun1,text)
	-- body
	if self.num == 1 or self.num == 3 then
		
		local listener
		--返回按钮事件
  		listener = NTGEventTriggerProxy.Get(self.top:Find("Left/ButtonReturn").gameObject)
  		local callback = function(self, e)
    		fun(funself)
  		end
  		listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self) 
  		--规则按钮事件
  		if funself1 ~= nil and fun1 ~= nil then
	  		listener = NTGEventTriggerProxy.Get(self.top:Find("Right/ButtonRule").gameObject)
	  		local callback = function(self, e)
	    		fun1(funself1)
	  		end
	  		listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)
  		end  
		self.top:Find("Left/Bg/TextBattleMode"):GetComponent(Text).text = text
	end
end

function NormalResourceController:UpdatePanelName()
	-- body
end

function NormalResourceController:ResourceInfo(showType)
	-- body
	self.panel:Find("RunePiece-image/RunePieceNum-text"):GetComponent(Text).text = Data.PlayerData.RunePiece
	self.panel:Find("Coin-image/CoinNum-text"):GetComponent(Text).text = Data.PlayerData.Coin
	self.panel:Find("Jewel-image/JewelNum-text"):GetComponent(Text).text = Data.PlayerData.Gem
	self.panel:Find("Ticket-image/TicketNum-text"):GetComponent(Text).text = Data.PlayerData.Voucher
	self.panel:Find("GuildCoin-image/CoinNum-text"):GetComponent(Text).text = Data.PlayerData.GuildCoin

	if showType == 1 then
		self.panel:Find("RunePiece-image").gameObject:SetActive(true)
	elseif showType == 0 then
		self.panel:Find("RunePiece-image").gameObject:SetActive(false)
	elseif showType == 2 then
		self.panel:Find("RunePiece-image").gameObject:SetActive(false)
		self.panel:Find("Coin-image").gameObject:SetActive(false)
		self.panel:Find("Jewel-image").gameObject:SetActive(false)
		self.panel:Find("Ticket-image").gameObject:SetActive(false)
		self.panel:Find("GuildCoin-image").gameObject:SetActive(true)
	end
	
	self:DoOperatSignalDelay()

	local listener
	--返回按钮事件
	listener = NTGEventTriggerProxy.Get(self.panel:Find("Ticket-image/TicketAddButton-button").gameObject)
	local callback = function(self, e)
		--coroutine.start(NormalResourceController.GoToOtherPanelCoroutine,self,"Shop")
        GameManager.CreatePanel("SelfHideNotice")
        if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能尚在建设中")
        end  		
	end	
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)
end

function NormalResourceController:UpdateResource()
	-- body
	self.panel:Find("RunePiece-image/RunePieceNum-text"):GetComponent(Text).text = Data.PlayerData.RunePiece
	self.panel:Find("Coin-image/CoinNum-text"):GetComponent(Text).text = Data.PlayerData.Coin
	self.panel:Find("Jewel-image/JewelNum-text"):GetComponent(Text).text = Data.PlayerData.Gem
	self.panel:Find("Ticket-image/TicketNum-text"):GetComponent(Text).text = Data.PlayerData.Voucher
	self.panel:Find("GuildCoin-image/CoinNum-text"):GetComponent(Text).text = Data.PlayerData.GuildCoin	
end

function NormalResourceController:HideSom(type1,type2,type3,type4)
	-- body
	if type1 == "Text" or type2 == "Text" or type3 == "Text"then
		self.top:Find("Left/Bg").gameObject:SetActive(false)
	end

	if type1 == "Button" or type2 == "Button" or type3 == "Button" then
		self.top:Find("Right").gameObject:SetActive(false)
	end

	if type1 == "Bar" or type2 == "Bar" or type3 == "Bar" then
		self.top:Find("Bg").gameObject:SetActive(false)
	end
end

function NormalResourceController:ShowSom(type1,type2,type3,type4)
	-- body
	if type1 == "Text" or type2 == "Text" or type3 == "Text"then
		self.top:Find("Left/Bg").gameObject:SetActive(true)
	end

	if type1 == "Button" or type2 == "Button" or type3 == "Button" then
		self.top:Find("Right").gameObject:SetActive(true)
	end

	if type1 == "Bar" or type2 == "Bar" or type3 == "Bar" then
		self.top:Find("Bg").gameObject:SetActive(true)
	end
end

--信号标志
function NormalResourceController:OperatSignalDelay()
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
function NormalResourceController:DoOperatSignalDelay()
  table.insert(self.coroutines,coroutine.start(NormalResourceController.OperatSignalDelay,self))
end
function NormalResourceController:ShowSignalFrame()
  if self.netDelayShowOrHide == false then
    self.signalTips.localPosition = Vector3.New(587.55,-40.4,0)
    self.netDelayShowOrHide = true
  else 
    self.signalTips.localPosition = Vector3.New(694,-40.4,0)
    self.netDelayShowOrHide = false
  end
end

function NormalResourceController:BuffControl()
	-- body
	if UTGDataOperator.Instance.TimesLimitDoubleEXP_Time ~= 0 then
		self.top:Find("EXPTips/PanelTimes").gameObject:SetActive(true)
		self.top:Find("EXP").gameObject:SetActive(true)
		local times = 0
		times = Data.PlayerData.DoubleExpLeftChange
		self.top:Find("EXPTips/PanelTimes/Text"):GetComponent(Text).text = times .. "场剩余【获胜可获得双倍经验】"
	end

	if UTGDataOperator.Instance.HoursLimitDoubleEXP_Time ~= 0 then
		self.top:Find("EXPTips/PanelHours").gameObject:SetActive(true)
		self.top:Find("EXP").gameObject:SetActive(true)
		local seconds = Data.PlayerData.DoubleExpLeftSecond
		local day = (seconds % (3600*24))
		local hours = 0
		if Day > 0 then
			hours = (seconds - (3600*24) * day) % 3600
		end
		self.top:Find("EXPTips/PanelHours/Text"):GetComponent(Text).text = "将在" .. day .. "天" .. hours .. "小时后过期"

	end

	if UTGDataOperator.Instance.HoursLimitDoubleMoney_Time ~= 0 then
		self.top:Find("CoinTips/PanelHours").gameObject:SetActive(true)
		self.top:Find("Coin").gameObject:SetActive(true)
		local seconds = Data.PlayerData.DoubleCoinLeftSecond
		local day = (seconds % (3600*24))
		local hours = 0
		if Day > 0 then
			hours = (seconds - (3600*24) * day) % 3600
		end
		self.top:Find("CoinTips/PanelHours/Text"):GetComponent(Text).text = "将在" .. day .. "天" .. hours .. "小时后过期"
	end

	if UTGDataOperator.Instance.TimesLimitDoubleMoney_Time ~= 0 then
		self.top:Find("CoinTips/PanelTimes").gameObject:SetActive(true)
		self.top:Find("Coin").gameObject:SetActive(true)
		local times = 0
		times = Data.PlayerData.DoubleCoinLeftChange
		self.top:Find("CoinTips/PanelTimes/Text"):GetComponent(Text).text = times .. "场剩余【获胜可获得双倍金币】"		
	end

end

function NormalResourceController:SetToHigh()
	-- body
	UTGDataOperator.Instance.TopBar.localPosition = Vector3.New(0,10000,0)
end

function NormalResourceController:GoToOtherPanelCoroutine(name)
  local async = GameManager.CreatePanelAsync(name)
  while async.Done == false do
    coroutine.wait(0.05)
  end
  
  if async.Done == true and fun ~= nil then
    fun(funself)
  end
end

function  NormalResourceController:OnDestroy()
	-- body
	for i = 1,#self.coroutines do
		coroutine.stop(self.coroutines[i])
	end
	self.this = nil
	self = nil
end



