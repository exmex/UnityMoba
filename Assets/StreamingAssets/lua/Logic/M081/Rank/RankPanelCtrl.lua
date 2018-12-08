require "System.Global"

local json = require "cjson"

class("RankPanelCtrl")

function RankPanelCtrl:Awake(this)
	-- body
	self.this = this

	--canvas
	--self.UICamera=GameObject.Find("GameLogic"):GetComponent("Camera")
  	--self.canvas= GameObject.Find("PanelRoot"):GetComponent("Canvas"); 
  	--self.y=self.canvas.transform:GetComponent("UnityEngine.UI.CanvasScaler").referenceResolution.y

    self.camera=GameObject.Find("GameLogic"):GetComponent("Camera");
    self.y=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.y
    self.x=GameObject.Find("PanelRoot"):GetComponent("RectTransform").sizeDelta.x
    self.wash= self.x /self.y;
	--rankInfo
	self.rankInfoShow=self.this.transforms[0]:FindChild("InfoShow")
	self.lock=self.this.transforms[0]:FindChild("Lock")
	self.rankImage=self.rankInfoShow:FindChild("RankImage"):GetComponent("UnityEngine.UI.Image")
	self.rankLevelImage=self.rankInfoShow:FindChild("RankImage/LevelImage"):GetComponent("UnityEngine.UI.Image")
	self.honorInfo=self.rankInfoShow:FindChild("RankImage/Honor")
	self.honorNum=self.honorInfo:FindChild("Num"):GetComponent("UnityEngine.UI.Text")
	self.rankText=self.rankInfoShow:FindChild("RankText/Text"):GetComponent("UnityEngine.UI.Text")

	--tips
	self.tips=self.this.transforms[8]:GetComponent("RectTransform")
	self.tipsText=self.tips:FindChild("Text"):GetComponent("UnityEngine.UI.Text")
	self.tipsTextTrans=self.tips:FindChild("Text"):GetComponent("RectTransform")
	--print(self.tipsTextTrans)

	--stars
	self.stars3Group=self.rankInfoShow:FindChild("Stars1")
	self.stars4Group=self.rankInfoShow:FindChild("Stars2")
	self.stars5Group=self.rankInfoShow:FindChild("Stars3")

	--winStreakInfo
	self.winStreakTextTrans=self.this.transforms[9]
	self.winStreakText=self.winStreakTextTrans:GetComponent("UnityEngine.UI.Text")
	self.winStreakInfo=self.this.transforms[1]
	self.winInfoImage=self.winStreakInfo:FindChild("BG/Image")
	self.HonorInfoImage=self.winStreakInfo:FindChild("BG/Image1")
	self.rewardImage=self.this.transforms[1]:FindChild("Reward"):GetComponent("UnityEngine.UI.Image")
	self.winGroup=self.this.transforms[1]:FindChild("BG/WinStreakGroup")
	self.win1=self.winGroup:FindChild("Win1")
	self.win1Show=self.winGroup:FindChild("Win1/Win")
	self.win2=self.winGroup:FindChild("Win2")
	self.win2Show=self.winGroup:FindChild("Win2/Win")
	self.win3=self.winGroup:FindChild("Win3")
	self.win3Show=self.winGroup:FindChild("Win3/Win")
	self.win4=self.winGroup:FindChild("Win4")
	self.win4Show=self.winGroup:FindChild("Win4/Win")

	---gradeOrderGroup
	self.gradeOrderGroup=self.this.transforms[1]:FindChild("BG/group")
	self.gradeOrderImage=self.this.transforms[1]:FindChild("BG/OrderImage"):GetComponent("UnityEngine.UI.Image")
	self.gradeOrderGroupImage1=self.gradeOrderGroup:FindChild("ImageNum1"):GetComponent("UnityEngine.UI.Image")
	self.gradeOrderGroupImage2=self.gradeOrderGroup:FindChild("ImageNum2"):GetComponent("UnityEngine.UI.Image")
	self.gradeOrderGroupImage3=self.gradeOrderGroup:FindChild("ImageNum3"):GetComponent("UnityEngine.UI.Image")
	self.Image1Layout=self.gradeOrderGroup:FindChild("ImageNum1"):GetComponent("UnityEngine.UI.LayoutElement")
	self.Image2Layout=self.gradeOrderGroup:FindChild("ImageNum2"):GetComponent("UnityEngine.UI.LayoutElement")
	self.Image3Layout=self.gradeOrderGroup:FindChild("ImageNum3"):GetComponent("UnityEngine.UI.LayoutElement")

	--bottomUI
	--left
	self.leftUI=self.this.transforms[4]
	self.leftButton=self.leftUI:FindChild("top/Button")

	self.letfText1=self.leftUI:FindChild("Bottom/LeftInfo/Num"):GetComponent("UnityEngine.UI.Text")
	self.letfText2=self.leftUI:FindChild("Bottom/MiddleInfo/Num"):GetComponent("UnityEngine.UI.Text")
	self.letfText3=self.leftUI:FindChild("Bottom/RightInfo/Num"):GetComponent("UnityEngine.UI.Text")
	--middle
	self.middleUI=self.this.transforms[5]
	self.middleIcon=self.middleUI:FindChild("Bottom/Icon/Mask/Image"):GetComponent("UnityEngine.UI.Image")
	self.middleResultWinText=self.middleUI:FindChild("Bottom/ResultText1")
	self.middleResultLostText=self.middleUI:FindChild("Bottom/ResultText")
	self.middleTimeText=self.middleUI:FindChild("Bottom/TimeText"):GetComponent("UnityEngine.UI.Text")
	self.middleButton=self.middleUI:FindChild("top/Button")
	--right
	self.rightText1=self.this.transforms[6]:FindChild("Top/Text"):GetComponent("UnityEngine.UI.Text")
	self.rightText2=self.this.transforms[6]:FindChild("Bottom/TimeText"):GetComponent("UnityEngine.UI.Text")

	--bottomLock
	self.bottomLock=self.this.transforms[7]
	self.LockRoleText=self.bottomLock:FindChild("LockNum"):GetComponent("UnityEngine.UI.Text")

	--button
	self.StartRankBtn=self.this.transforms[2]
	self.TwoRankBtn=self.this.transforms[3]

	self.StartRankBtn_Draft = self.this.transform:FindChild("PlayButton_Draft")
	self.TwoRankBtn_Draft = self.this.transform:FindChild("PlayButton2_Draft")
	self.Rule_Draft = self.this.transform:FindChild("RuleButton_Draft")


	local listener
	listener = NTGEventTriggerProxy.Get(self.StartRankBtn.gameObject)
	listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnStartRankBtnClick,self)
	listener = NTGEventTriggerProxy.Get(self.TwoRankBtn.gameObject)
	listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnTwoRankBtnClick,self)
	listener = NTGEventTriggerProxy.Get(self.rewardImage.gameObject)
	listener.onPointerDown = listener.onPointerDown + NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnRewardDown,self)
	listener.onPointerUp= listener.onPointerUp + NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnRewardUp,self)
	listener = NTGEventTriggerProxy.Get(self.middleButton.gameObject)
	listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnMiddleBtnClick,self)
	listener = NTGEventTriggerProxy.Get(self.leftButton.gameObject)
	listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnLeftBtnClick,self)

	--RankruleText

	self.txttitle = "排位规则"
    self.txtcontent ="<size=26><color=#D4D4D4>1、排位赛周期：每届排位赛的持续时间大概为<color=#ffff00>三个月</color>，当赛季结束时将对排位赛成绩进行结算，所有参与排位赛的玩家将根据被赛季所达到的最高段位获得对应的钻石奖励。\n2、参与规则：当<color=#ffff00>等级达到6级</color>时，即可开启排位赛，只有拥有<color=#ffff00>至少5个姬神</color>时，才可参加排位赛，所有参与排位赛的选手，系统将会根据大家的实力情况，匹配到合适的队友及对手进行对局。\n3、段位规则：排位赛一共分为6个段位，分别是：士兵、<color=#7a9644>士官</color>、<color=#00b1f1>尉官</color>、<color=#5d487a>校官</color>、<color=#e36c0a>将官</color>、<color=#ff0000>元帅</color>，其中前5个大段位均有<color=#ffff00>3个小段位</color>。而所有进入元帅的玩家，将会根据实力情况进行<color=#ffff00>全服排名</color>。\n4、结算奖励：每个赛季结束时，所有参与排位赛的玩家将根据本赛季的所达到的最高段位获得对应的钻石奖励。\n<color=#ff0000>元帅</color>：<color=#ffff00>3000钻</color>\n<color=#e36c0a>将官</color>：<color=#ffff00>2000钻</color>\n<color=#5d487a>校官</color>：<color=#ffff00>1500钻</color>\n<color=#00b1f1>尉官</color>：<color=#ffff00>1000钻</color>\n<color=#7a9644>士官</color>：<color=#ffff00>500钻</color>\n士兵：<color=#ffff00>300钻</color>\n5、关于晋级，降级，晋段，降段：满星状态下参与排位赛，胜利后晋级或者晋段且得到一星；零星状态下参与排位赛，失败后降级或者降段。升入元帅段位后如果在0星的情况下再输一场排位赛会降段到将官-上将；士兵段位不会掉星。\n6、双排：不能邀请超过自己2个段位的好友或者战队成功进行组队排位。\n7、连胜加星：除了元帅段位以外，各段位都有连胜加星的福利，达到指定的连胜次数后会额外获得一颗星且奖励连胜计数归零。\n8、玩家进入元帅段位后，系统会每隔7天进行一次检验，如果玩家在7天没有排位赛行为，系统会扣除玩家的1颗星。\n9、元帅的前50名玩家，我们会授予玩家“大元帅”这一荣誉称号，该称号和排名会在每天的零点进行一次更迭。</color></size>"
   	
    self.rankFrame= self.this.transforms[10]
    if(ChartAPI.Instance~=nil) then
    	ChartAPI.Instance:SetPos(self.rankFrame,"Rank")
    end
    self:SendNowSeason()
	--self:SendSeasonLog()
	if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
		WaitingPanelAPI.Instance:DestroySelf()
	end	
end
function RankPanelCtrl:OnLeftBtnClick()
	--body
	--print("OnLeftBtnClick")
	coroutine.start(RankPanelCtrl.CreateGridHistoryPanelMov,self)
end
function RankPanelCtrl:OnMiddleBtnClick()
	-- body
	--print("OnMiddleBtnClick")
	coroutine.start(RankPanelCtrl.CreateRecentGamePanelMov,self)
end
function RankPanelCtrl:CreateGridHistoryPanelMov()
	-- body
	--print("GridHistory creating")
	local result = GameManager.CreatePanelAsync("GridHistory")
  	while result.Done~= true do
    ----print("deng")
    coroutine.step() 
  	end
end
function RankPanelCtrl:CreateRecentGamePanelMov()
	-- body
	--print("RecentGame creating")
	local result = GameManager.CreatePanelAsync("RecentGame")
  	while result.Done~= true do
    ----print("deng")
    	coroutine.step() 
  	end
  	RecentGameAPI.Instance:Init(self.BattleLog)
end
function RankPanelCtrl:OnRewardDown(eventData)
	-- body
	--print("clcik Reward")
	--print(Input.mousePosition)
	
	--self.tips.sizeDelta = self.tipsTextTrans.sizeDelta
	self.tips.localPosition=self:MouseToUIposition(Input.mousePosition)
	self.tips.gameObject:SetActive(true)

end
function RankPanelCtrl:MouseToUIposition(mousePosition) --Input.mousePosition
    
    --local y=self.y;--720要改的吧从canvas获取
    --local wash= Screen.width / Screen.height;
    --local screenPos = self.UICamera:ScreenToViewportPoint(mousePosition);
    --return Vector3.New((screenPos.x - 0.5) * y * wash-self.tips.sizeDelta.x/2, (screenPos.y - 0.5) * y, 0);

    local screenPos = self.camera:ScreenToViewportPoint(mousePosition);
    return Vector3.New((screenPos.x - 0.5) * self.y * self.wash-self.tips.sizeDelta.x/2, (screenPos.y - 0.5) * self.y, 0);

end
function RankPanelCtrl:OnRewardUp()
	-- body
	--print("Up Reward")
	self.tips.gameObject:SetActive(false)
end
function RankPanelCtrl:OnStartRankBtnClick()
	-- body
	--print("click 1")
	if(self.myRolesCount<5) then
		return
	end 
	self:CreateParty("", 1, 61)
end
function RankPanelCtrl:OnTwoRankBtnClick()
	-- body
	--print("click 2")
	if(self.myRolesCount<5) then
		return
	end 
	self:CreateParty("", 2, 62)
end
--征召模式
function RankPanelCtrl:OnStartRankBtnClick_Draft()
	--print("click 2")
	if(self.myRolesCount<5) then
		return
	end 
	local roleCount = #UTGData.Instance():GetOwnRoleData()
  --Debugger.LogError(roleCount)
  if roleCount<12 then 
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("无法加入房间：该模式需要可用姬神数量不少于12个")
    return
  end
	self:CreateParty("", 1, 61)
end
function RankPanelCtrl:OnTwoRankBtnClick_Draft()
	--print("click 2")
	if(self.myRolesCount<5) then
		return
	end 
	local roleCount = #UTGData.Instance():GetOwnRoleData()
  --Debugger.LogError(roleCount)
  if roleCount<12 then 
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("无法加入房间：该模式需要可用姬神数量不少于12个")
    return
  end
	self:CreateParty("", 2, 62)
end
function RankPanelCtrl:OnRuleClick_Draft()
	GameManager.CreatePanel("DraftRule")
end

function RankPanelCtrl:CreateParty(mapName, playerCount, subTypeCode)
  local mainType = 5 -- 实时对战
  local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("NewBattle15")
          while async.Done == false do
            coroutine.step() 
          end
          if(playerCount==1) then
          	self:DestroySelf()
          end
        
          if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
            NewBattle15API.Instance:CreateParty(mapName, playerCount, subTypeCode,mainType)
          end
        end
  coroutine.start(CreatePanelAsync,self) 
end


function RankPanelCtrl:Start()
	-- body
	self:GetRoleData()
	if(self.myRolesCount<5) then
		self:ShowLock(self.myRolesCount)
		local dialog = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
		dialog:InitNoticeForNeedConfirmNotice("提示", "排位赛至少需要5名姬神才能参与，", true,"您可以去商城中获取新的姬神~", 1,false)
	    dialog:OneButtonEvent("确定",dialog.DestroySelf,dialog)
	    dialog:SetTextToCenter()
		dialog:HideCloseButton(false)
	else
		self:GetData()
		if(self.myGrade==0) then
			return
		end
		--[[
		if self.myCategory>=4 then --钻石以上
			self.StartRankBtn.gameObject:SetActive(false)
			self.TwoRankBtn.gameObject:SetActive(false)
			self.StartRankBtn_Draft.gameObject:SetActive(true)
			self.TwoRankBtn_Draft.gameObject:SetActive(true)
			self.Rule_Draft.gameObject:SetActive(true)
			listener = NTGEventTriggerProxy.Get(self.StartRankBtn_Draft.gameObject)
			listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnStartRankBtnClick_Draft,self)
			listener = NTGEventTriggerProxy.Get(self.TwoRankBtn_Draft.gameObject)
			listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnTwoRankBtnClick_Draft,self)
			listener = NTGEventTriggerProxy.Get(self.Rule_Draft:FindChild("But").gameObject)
			listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(self.OnRuleClick_Draft,self)
		end
		]]
		self:UpdateBattleLog()
		self:InitRankPanelInfo()
		self:UpdateBottomUIInfo(self.SeasonWinnerCount,self.SeasonBattleCount,self.SessonEverMaxWinning)
	end

end
function RankPanelCtrl:CreateMainPanelMov()
	-- body
	local result = GameManager.CreatePanelAsync("PageText")
  	while result.Done~= true do
    ----print("deng")
    coroutine.step() 
  	end
  	PageTextAPI.instance:Init(self.txttitle,self.txtcontent)
end
function RankPanelCtrl:UpdateBattleLog()
	-- body
	local battleLog = UTGData.Instance().BattleLogs
	self.BattleLog={}
	----print("battleLog Come")
	----print(table.getn(battleLog))
	if (table.getn(battleLog)==0) then
		self.middleUI:FindChild("Bottom").gameObject:SetActive(false)
		return true
	end
	if(battleLog~=nil) then
		self.BattleLog=battleLog
		self.middleTimeText.text=string.sub(self.BattleLog[1].Start,6,7).."月"..string.sub(self.BattleLog[1].Start,9,10).."日"..string.sub(self.BattleLog[1].Start,12,16)
		local winteam=self.BattleLog[1].Winner
		for k,v in pairs(self.BattleLog[1].TeamA) do
			if(v.PlayerId==self.playerId) then
				self.logRoleId=v.RoleId
				self.myTeam=1
			end
		end				
		for k,v in pairs(self.BattleLog[1].TeamB) do
			if(v.PlayerId==self.playerId) then
				self.logRoleId=v.RoleId
				self.myTeam=2
			end
		end
		if(winteam==self.myTeam) then
			self.middleResultWinText.gameObject:SetActive(true)
		else
			self.middleResultLostText.gameObject:SetActive(true)
		end
		----print("RoleId"..self.logRoleId)
		self.middleIcon.sprite=NTGResourceController.Instance:LoadAsset("roleicon","I"..UTGData.Instance().RolesData[tostring(self.logRoleId)].Skin,"UnityEngine.Sprite")
		return true
	end
end
function RankPanelCtrl:SendSeasonLog()
	-- body
	local seasonInfoRequest = NetRequest.New()
	seasonInfoRequest.Content=JObject.New(JProperty.New("Type","RequestRecentGradeBattleLog"))
	seasonInfoRequest.Handler=TGNetService.NetEventHanlderSelf(RankPanelCtrl.SeasonLogHandler,self)
	TGNetService.GetInstance():SendRequest(seasonInfoRequest)
end
function RankPanelCtrl:SeasonLogHandler(e)
	if e.Type == "RequestRecentGradeBattleLog" then
		local result = tonumber(e.Content:get_Item("Result"):ToString())
		if result ==1 and self~=nil and self.this~=nil then
			local battleLog = json.decode(e.Content:get_Item("BattleLogs"):ToString())
			self.BattleLog={}
			----print("battleLog Come")
			----print(table.getn(battleLog))
			if (table.getn(battleLog)==0) then
				self.middleUI:FindChild("Bottom").gameObject:SetActive(false)
			end
			if(battleLog~=nil) then
				
				self.BattleLog=battleLog
				self.middleTimeText.text=string.sub(self.BattleLog[1].Start,6,7).."月"..string.sub(self.BattleLog[1].Start,9,10).."日"..string.sub(self.BattleLog[1].Start,12,16)
				local winteam=self.BattleLog[1].Winner
				for k,v in pairs(self.BattleLog[1].TeamA) do
					if(v.PlayerId==self.playerId) then
						self.logRoleId=v.RoleId
						self.myTeam=1
					end
				end
				for k,v in pairs(self.BattleLog[1].TeamB) do
					if(v.PlayerId==self.playerId) then
						self.logRoleId=v.RoleId
						self.myTeam=2
					end
				end
				if(winteam==self.myTeam) then
					self.middleResultWinText.gameObject:SetActive(true)
				else
					self.middleResultLostText.gameObject:SetActive(true)
				end
				----print("RoleId"..self.logRoleId)
				self.middleIcon.sprite=NTGResourceController.Instance:LoadAsset("roleicon","I"..UTGData.Instance().RolesData[tostring(self.logRoleId)].Skin,"UnityEngine.Sprite")
			end
		end
		return true
	end
	return false	
end
function RankPanelCtrl:SendNowSeason()
	-- body
	local seasonInfoRequest = NetRequest.New()
	seasonInfoRequest.Content=JObject.New(JProperty.New("Type","RequestCurrentSeasonInfo"))
	seasonInfoRequest.Handler=TGNetService.NetEventHanlderSelf(RankPanelCtrl.SeasonInfoHandler,self)
	TGNetService.GetInstance():SendRequest(seasonInfoRequest)
end
function RankPanelCtrl:SeasonInfoHandler(e)
	-- body
	if e.Type == "RequestCurrentSeasonInfo" then
		local result = tonumber(e.Content:get_Item("Result"):ToString())
		if result ==1 then
			local seasonInfo = json.decode(e.Content:get_Item("Season"):ToString())
			self.NowSeasonInfo={}
			if seasonInfo~=nil and self~=nil and self.this~=nil then
				self.NowSeasonInfo["From"]=seasonInfo.From
				self.NowSeasonInfo["To"]=seasonInfo.To
				self.NowSeasonInfo["Name"]=seasonInfo.Name
				self.rightText1.text="本赛季时间("..self.NowSeasonInfo.Name..")"
				self.rightText2.text=self.NowSeasonInfo.From.."-----".."\n"..self.NowSeasonInfo.To
			end	
		else
			Debugger.Log("RequestCurrentSeasonInfo "..result)
		end
		return true
	end
	return false	
end
function RankPanelCtrl:GetRoleData()
	-- body

	--拥有姬神数量
	self.myRolesCount=0
	

	if(UTGData.Instance().RolesDeck~=nil) then
		for k,v in pairs(UTGData.Instance().RolesDeck) do
			if(v.IsOwn) then
				self.myRolesCount=self.myRolesCount+1
			end
		end
	end
end
function RankPanelCtrl:GetData()
	-- body
	
	--段位相关信息
	self.playerId=nil
	self.myGrade=nil
	self.maxStars=nil
	self.nowStars=nil
	self.gradeMainIcon=nil
	self.gradeSubIcon=nil
	self.maxWinStreak=nil
	self.nowWinStreak=nil
	self.gradeText=nil
	self.gradeReWardIcon=nil
	self.isHonor=nil
	self.gradeReWardText=nil
	self.gradeOrder=nil
	self.myCategory = nil
	--赛季信息
	self.SeasonBattleCount=nil
	self.SeasonWinnerCount=nil
	self.SessonEverMaxWinning=nil



	if(UTGData.Instance().PlayerGradeDeck~=nil) then
			--GradeDeck
			local v = UTGData.Instance().PlayerGradeDeck
			self.playerId=v.PlayerId
			--print("playerId"..self.playerId)
			self.myGrade=v.Grade
			--print("myGrade"..self.myGrade)
			self.nowStars=v.Stars
			--print("nowStars"..self.nowStars)
			self.nowWinStreak=v.GradeWinningCount
			--print("nowWin"..self.nowWinStreak)
			self.isHonor=v.IsHonor
			--print("honor"..tostring(self.isHonor))
			self.gradeOrder=v.Order
			self.myCategory = v.Category
			--print("gradeOrder"..self.gradeOrder)
			--seasonDeck
			self.SeasonWinnerCount=v.WinnerCount
			--print("SeasonWinnerCount"..self.SeasonWinnerCount)
			self.SeasonBattleCount=v.BattleCount
			--print("SeasonBattleCount"..self.SeasonBattleCount)		
			self.SessonEverMaxWinning=v.EverMaxWinning
			--print("SessonEverMaxWinning"..self.SessonEverMaxWinning)

			--template 
			--GradData
			if(self.myGrade==0) then
				return
			end
			self.maxStars=UTGData.Instance().GradesData[tostring(self.myGrade)].MaxStars
			print("maxStars"..self.maxStars)
			--self.gradeMainIcon=NTGResourceController.Instance:LoadAsset("rankicon-".."i18000001","i18000001","UnityEngine.Sprite")
			--print("IconMain"..UTGData.Instance().GradesData[tostring(self.myGrade)].IconMain)
			if(self.maxStars~=0) then
				self.gradeSubIcon =NTGResourceController.Instance:LoadAsset("Rankicon-"..UTGData.Instance().GradesData[tostring(self.myGrade)].IconMain,UTGData.Instance().GradesData[tostring(self.myGrade)].IconSub,"UnityEngine.Sprite")
			end
			--print("IconSub"..UTGData.Instance().GradesData[tostring(self.myGrade)].IconSub)
			self.maxWinStreak=UTGData.Instance().GradesData[tostring(self.myGrade)].WinningCheck
			--print("maxWin"..self.maxWinStreak)
			self.gradeText=UTGData.Instance().GradesData[tostring(self.myGrade)].Title
			--print("gradeText"..self.gradeText)
			--ItemData
			local tempItemID=UTGData.Instance().GradesData[tostring(self.myGrade)].Bonus
			print("宝物ID"..tempItemID)
			print("邮件"..UTGData.Instance().MailInfosData[tostring(tempItemID)].Rewards[1].AttachmentId)
			--print("tempItemID"..tempItemID)
			print("IconID"..UTGData.Instance().ItemsData[tostring(UTGData.Instance().MailInfosData[tostring(tempItemID)].Rewards[1].AttachmentId)].Icon)
			self.gradeReWardIcon=NTGResourceController.Instance:LoadAsset("itemicon",UTGData.Instance().ItemsData[tostring(UTGData.Instance().MailInfosData[tostring(tempItemID)].Rewards[1].AttachmentId)].Icon,"UnityEngine.Sprite")
			--print("IconID"..UTGData.Instance().ItemsData[tostring(tempItemID)].Icon)
			self.gradeReWardText=UTGData.Instance().ItemsData[tostring(UTGData.Instance().MailInfosData[tostring(tempItemID)].Rewards[1].AttachmentId)].Desc
			if(self.isHonor) then
				self.gradeMainIcon=NTGResourceController.Instance:LoadAsset("rankicon-".."i18000007","i18000007","UnityEngine.Sprite")
				self.maxStars=0
				self.gradeText="大元帅"
			else
				self.gradeMainIcon=NTGResourceController.Instance:LoadAsset("rankicon-"..UTGData.Instance().GradesData[tostring(self.myGrade)].IconMain,UTGData.Instance().GradesData[tostring(self.myGrade)].IconMain,"UnityEngine.Sprite")
			end
	end
end

function RankPanelCtrl:InitRankPanelInfo()
	-- body
	--test

	--self.isHonor=true
	--self.gradeOrder=2

	---test
	--print("laile0000")
	self:UpdateRankInfo(self.maxStars,self.nowStars,self.gradeMainIcon,self.gradeText,self.gradeSubIcon)
	self:UpdateWinStreakInfo(self.gradeReWardIcon)
	if(self.maxStars ==0) then
		self.winInfoImage.gameObject:SetActive(false)
		self.HonorInfoImage.gameObject:SetActive(true)
		self:UpdateOrderInfo(self.gradeOrder)
	else
		self:UpdateWinStreak(self.maxWinStreak,self.nowWinStreak)
	end
end
function RankPanelCtrl:UpdateOrderInfo(tempOrder)
	-- body
	local str = tostring(tempOrder)
	local str1 =" "
	local str2 =" "
	local str3 =" "
	self.gradeOrderGroup.gameObject:SetActive(true)
	if(tempOrder==0 or tempOrder>899) then
		self.gradeOrderGroup:FindChild("Text3").gameObject:SetActive(true)
	elseif(tempOrder<4) then
		self.gradeOrderImage.sprite=NTGResourceController.Instance:LoadAsset("ranknum","Num"..tempOrder,"UnityEngine.Sprite")
		self.gradeOrderImage.gameObject:SetActive(true)
	elseif(tempOrder<100) then
		str1 = string.sub(str,1,1) 
		if(string.len(str)>1) then
			str2 = string.sub(str,2,2)
			self:UpdateOrderNum(str1,str2,-1)
			self.Image1Layout.preferredHeight = 40
			self.Image1Layout.preferredWidth = 40
			self.Image2Layout.preferredHeight = 40
			self.Image2Layout.preferredWidth = 40
		else
			self:UpdateOrderNum(str1,-1,-1)
			self.Image1Layout.preferredHeight = 50
			self.Image1Layout.preferredWidth = 50
		end

	elseif(tempOrder==100) then
		str1 = string.sub(str,1,1) 
		str2 = string.sub(str,2,2) 
		str3 = string.sub(str,3,3)
		self:UpdateOrderNum(str1,str2,str3) 
		self.Image1Layout.preferredHeight = 35
		self.Image1Layout.preferredWidth = 35
		self.Image2Layout.preferredHeight = 35
		self.Image2Layout.preferredWidth = 35
		self.Image3Layout.preferredHeight = 35
		self.Image3Layout.preferredWidth = 35
	elseif(tempOrder<899) then
		str1 = string.sub(str,1,1) 
		local tempNum = tonumber("str1")
		str1 =tostring(tempNum+1)
		self.gradeOrderGroup:FindChild("Text1").gameObject:SetActive(true)
		self:UpdateOrderNum(str1,"0","0")
		self.gradeOrderGroup:FindChild("Text2").gameObject:SetActive(true) 
	end
end
function RankPanelCtrl:UpdateOrderNum(num1,num2,num3)
	-- body
	self.gradeOrderGroupImage1.sprite=NTGResourceController.Instance:LoadAsset("ranknum",num1,"UnityEngine.Sprite")
	self.gradeOrderGroupImage1.gameObject:SetActive(true)
	if(num2~=-1) then
		self.gradeOrderGroupImage2.sprite=NTGResourceController.Instance:LoadAsset("ranknum",num2,"UnityEngine.Sprite")
		self.gradeOrderGroupImage2.gameObject:SetActive(true)
	end
	if(num3~=-1) then
		self.gradeOrderGroupImage3.sprite=NTGResourceController.Instance:LoadAsset("ranknum",num3,"UnityEngine.Sprite")
		self.gradeOrderGroupImage3.gameObject:SetActive(true)
	end

end
function RankPanelCtrl:ShowLock(nowRoleCount)
	-- body
	self.rankInfoShow.gameObject:SetActive(false)
	self.lock.gameObject:SetActive(true)
	self.leftUI.parent.gameObject:SetActive(false)
	self.winStreakInfo.gameObject:SetActive(false)
	self.bottomLock.gameObject:SetActive(true)
	self.LockRoleText.text=nowRoleCount.."/5"
	self.StartRankBtn:GetComponent("UnityEngine.UI.Image").color=Color.New(0.25,0.25,0.25,1)
	self.TwoRankBtn:GetComponent("UnityEngine.UI.Image").color=Color.New(0.25,0.25,0.25,1)

end

function RankPanelCtrl:UpdateRankInfo(myStarsMAX,myLightStarsNum,myRankImage,myRankText,myRankLevelImage)
	-- body
	--stars
	local finalStars
	if(myStarsMAX==3) 
	then
		self.stars3Group.gameObject:SetActive(true)
		finalStars=self.stars3Group
	elseif(myStarsMAX==4)
	then
		self.stars4Group.gameObject:SetActive(true)
		finalStars=self.stars4Group
	elseif(myStarsMAX==5)
	then
		self.stars5Group.gameObject:SetActive(true)
		finalStars=self.stars5Group
	end

	

	--myRankImage
	print("final"..myStarsMAX)
	print("finalImage"..myRankImage.name)
	self.rankImage.sprite=myRankImage
	self.rankImage:SetNativeSize()
	if(myStarsMAX==0) then
		self.rankLevelImage.gameObject:SetActive(false)
		self.honorInfo.gameObject:SetActive(true)
		self.honorNum.text=myLightStarsNum
	else
		self:UpdateStars(finalStars,myLightStarsNum)
		self.rankLevelImage.sprite=myRankLevelImage
		self.rankLevelImage:SetNativeSize()
	end
	--print("laile"..myStarsMAX)
	--text
	self.rankText.text=myRankText

end
function RankPanelCtrl:UpdateStars(fStarsGroup,starsNum)
	-- body
	for i=1,starsNum,1 do
		local tempStr ="Star"..i.."/Image"
		fStarsGroup:FindChild(tempStr).gameObject:SetActive(true)
	end
end

function RankPanelCtrl:UpdateBottomUIInfo(seasonWinNum,seasonbattleNum,seasonWinStreakNum)
	-- body
	--letf
	self.letfText1.text=seasonWinNum
	self.letfText2.text=seasonbattleNum
	self.letfText3.text=seasonWinStreakNum
end

function RankPanelCtrl:UpdateWinStreakInfo(myRewardImage)
	-- body
	self.rewardImage.sprite=myRewardImage
	self.tipsText.text=self.gradeReWardText
	--self.tips.sizeDelta = Vector2.New(self.tipsTextTrans.sizeDelta.x+20,self.tipsTextTrans.sizeDelta.y+20);
end

function RankPanelCtrl:UpdateWinStreak(winsMax,winsNum)
	-- body
	self.winGroup.gameObject:SetActive(true)
	for i=1,winsMax,1 do
		local Str1 ="Win"..i
		local Str2 =Str1.."/Win"
		self.winGroup:FindChild(Str1).gameObject:SetActive(true)
		if i<winsNum or i==winsNum then
			self.winGroup:FindChild(Str2).gameObject:SetActive(true)
		end
	end
	self.winStreakText.text="再连胜"..winsMax-winsNum.."次可获得额外一颗星"
	self.winStreakTextTrans.gameObject:SetActive(true)
end

function RankPanelCtrl:OnBackBtnClick()
  	self:DestroySelf()
end
function RankPanelCtrl:OnRuleBtnClick()
	coroutine.start(RankPanelCtrl.CreateMainPanelMov,self)
end
function RankPanelCtrl:DestroySelf()
	-- body
	UTGMainPanelAPI.Instance:ShowSelf()
  	GameObject.Destroy(self.this.transform.parent.gameObject)
end

function RankPanelCtrl:OnDestroy()
	-- body
	self.this = nil
	self =nil
end