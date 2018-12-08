require "System.Global"

class("EmailController")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"

local json = require "cjson"

function EmailController:Awake(this)
	-- body
	self.this = this
	self.leftTab = self.this.transforms[0]
	self.rightMainPanel = self.this.transforms[1]
	self.receivePanel = self.this.transforms[2]



	self.tab1 = {}
	self.tab2 = {}
	self.tab3 = {}

	self.tab1 = {Click = self.leftTab:Find("Tab1/Click"),Notice = self.leftTab:Find("Tab1/Notice")}
	self.tab2 = {Click = self.leftTab:Find("Tab2/Click"),Notice = self.leftTab:Find("Tab2/Notice")}
	self.tab3 = {Click = self.leftTab:Find("Tab3/Click"),Notice = self.leftTab:Find("Tab3/Notice")}

	self.noEmail = self.rightMainPanel:Find("Panel/NoEmail")
	self.friendEmail = self.rightMainPanel:Find("Panel/FriendEmail")
	self.systemEmail = self.rightMainPanel:Find("Panel/SystemEmail")

	self.friendEmailTransformTemp = self.rightMainPanel:Find("Panel/FriendEmail/ScrollView/Grid/Image")
	self.systemEmailTransformTemp = self.rightMainPanel:Find("Panel/SystemEmail/ScrollView/Grid/Image")

	self.title = self.receivePanel:Find("Frame/Main/Text")
	self.reading = self.receivePanel:Find("Frame/Main/Image/Text")
	self.receiveList = {}
	for i = 1,self.receivePanel:Find("Frame/Main/Panel").childCount do
		table.insert(self.receiveList,self.receivePanel:Find("Frame/Main/Panel"):GetChild(i-1))
	end
	self.receiveButton = self.receivePanel:Find("Frame/Main/Button")
	self.closeReceivePanelButton = self.receivePanel:Find("Frame/CancelButton")

	self.selectEmail = ""

	self.coinReceive = 0
	self.skinReceive = {}

	self.finishFriendMailList = false
	self.finishSystemMailList = false

	self.currentPage = 0

	self.friendQuickGetButton = self.rightMainPanel:Find("Panel/FriendEmail/ButtonArea/QuickGet")
	self.systemDeleteButton = self.rightMainPanel:Find("Panel/SystemEmail/ButtonArea/Panel/Delete")
	self.systemQuickGetButton = self.rightMainPanel:Find("Panel/SystemEmail/ButtonArea/Panel/QuickGet")

	self.currentFriendListSize = 0
	self.currentSystemListSize = 0

	self.quickDrawMode = 1


	local listener
	listener = NTGEventTriggerProxy.Get(self.leftTab:Find("Tab1/Text").gameObject)
	local callbackTab1 = function(self, e)
		self:TabControl(1)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackTab1, self)

	listener = NTGEventTriggerProxy.Get(self.leftTab:Find("Tab2/Text").gameObject)
	local callbackTab2 = function(self, e)
		self:TabControl(2)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackTab2, self) 

	listener = NTGEventTriggerProxy.Get(self.leftTab:Find("Tab3/Text").gameObject)
	local callbackTab3 = function(self, e)
		self:TabControl(3)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackTab3, self)

	listener = NTGEventTriggerProxy.Get(self.closeReceivePanelButton.gameObject)
	local callbackCloseReceivePanel = function(self, e)
		self.receivePanel.gameObject:SetActive(false)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackCloseReceivePanel, self)

	listener = NTGEventTriggerProxy.Get(self.friendQuickGetButton.gameObject)
	local callbackFriendQuickGet = function(self, e)
		self.quickDrawMode = 1
		self:QuickDrawMail(1)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackFriendQuickGet, self)

	listener = NTGEventTriggerProxy.Get(self.systemDeleteButton.gameObject)
	local callbackSystemDelete = function(self, e)
		self:DeleteMail(self.fromSystemEmail[1].Id,"System")
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackSystemDelete, self)

	listener = NTGEventTriggerProxy.Get(self.systemQuickGetButton.gameObject)
	local callbackSystemQuickGet = function(self, e)
		self.quickDrawMode = 2
		self:QuickDrawMail(2)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackSystemQuickGet,self)

	self.receive = true

end

function EmailController:Start()
	-- body
	--初始化顶部条
	self:ResetPanel()


	--收到服务器发送的邮件结构
	self.friendReceive = {}
	self.systemReceive = {}

	self:InitReceiveData()
	self:GetOrderedList()
	self:UnReadMail()
	self:TabControl(1)
	self:DoGetNextPageMails()
	


end

function EmailController:ResetPanel()
	self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  UTGDataOperator.Instance:SetResourceList(topAPI)
  topAPI:GoToPosition("EmailPanel")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,EmailController.DestroySelf,nil,nil,"邮  件")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
end

function EmailController:InitReceiveData()
	-- body
	if UTGDataTemporary.Instance().FriendEmail ~= nil then
		for i = 1,#UTGDataTemporary.Instance().FriendEmail do
			if UTGDataTemporary.Instance().FriendEmail[i].Type == 1 then
				self.coinReceive = self.coinReceive + UTGDataTemporary.Instance().FriendEmail[i].Amount
			elseif UTGDataTemporary.Instance().FriendEmail[i].Type == 2 then
				table.insert(self.skinReceive,UTGDataTemporary.Instance().FriendEmail[i].ReceiveId)
			end
		end
	end
end

function EmailController:GetOrderedList()
	-- body
	self.fromFriendEmail = self:InitFriendShow()
	self.fromSystemEmail = self:InitSystemShow()	
end

function EmailController:InitFriendShow()
	-- body
	--print("UTGDataTemporary.Instance().FriendEmail " .. #UTGDataTemporary.Instance().FriendEmail)
	local friendEmailListTemp = UITools.CopyTab(UTGDataTemporary.Instance().FriendEmail)
	local friendEmailListTempOpened = {}
	for i = #friendEmailListTemp,1,-1 do
		--print("bbbbbbbbbbbb " .. friendEmailListTemp[i].Id .. " " .. tostring(friendEmailListTemp[i].IsRead))
		if friendEmailListTemp[i].IsRead == true then
			--print("bbbbbbbbbbbb")
			table.insert(friendEmailListTempOpened,friendEmailListTemp[i])
			table.remove(friendEmailListTemp,i)
		end
	end
	table.sort(friendEmailListTempOpened,function(a,b) return a.Id > b.Id end)
	table.sort(friendEmailListTemp,function(a,b) return a.Id > b.Id end)

	for i = 1,#friendEmailListTempOpened do
		table.insert(friendEmailListTemp,friendEmailListTempOpened[i])
	end

	return friendEmailListTemp
end

function EmailController:InitSystemShow()
	-- body
	local systemEmailListTemp = UITools.CopyTab(UTGDataTemporary.Instance().SystemEmail)
	local systemEmailListTempOpened = {}
	--print("systemEmailListTemp " .. #systemEmailListTemp)
	for i = #systemEmailListTemp,1,-1 do
		if systemEmailListTemp[i].IsRead == true then
			table.insert(systemEmailListTempOpened,systemEmailListTemp[i])
			table.remove(systemEmailListTemp,i)
		end
	end
	table.sort(systemEmailListTempOpened,function(a,b) return a.Id > b.Id end)
	table.sort(systemEmailListTemp,function(a,b) return a.Id > b.Id end)
	--print("systemEmailListTempOpened " .. #systemEmailListTempOpened)
	for i = 1,#systemEmailListTempOpened do
		table.insert(systemEmailListTemp,systemEmailListTempOpened[i])
	end
	return systemEmailListTemp
end

function EmailController:TabControl(pageNum)
	-- body
	self.currentPage = pageNum
	if pageNum == 1 then
		self.tab1.Click.gameObject:SetActive(true)
		self.tab2.Click.gameObject:SetActive(false)
		self.tab3.Click.gameObject:SetActive(false)
		if self.finishFriendMailList == true then
			self:MailPanelControl(1)
		else
			self:InitFriendList()
		end
	elseif pageNum == 2 then
		self.tab1.Click.gameObject:SetActive(false)
		self.tab2.Click.gameObject:SetActive(true)
		self.tab3.Click.gameObject:SetActive(false)
		if self.finishSystemMailList == true then
			self:MailPanelControl(2)
		else
			self:InitSystemList()
		end
	elseif pageNum == 3 then
		self.tab1.Click.gameObject:SetActive(false)
		self.tab2.Click.gameObject:SetActive(false)
		self.tab3.Click.gameObject:SetActive(true)
		self:MailPanelControl(3)		
	end
end

function EmailController:TabNoticeControl()
	-- body
	if self.friendNoticeCount > 0 then
		self.tab1.Notice.gameObject:SetActive(true)
		self.tab1.Notice:Find("Text"):GetComponent(Text).text = self.friendNoticeCount
	else
		self.tab1.Notice.gameObject:SetActive(false)
	end

	if self.systemNoticeCount > 0 then
		self.tab2.Notice.gameObject:SetActive(true)
		self.tab2.Notice:Find("Text"):GetComponent(Text).text = self.systemNoticeCount
	else
		self.tab2.Notice.gameObject:SetActive(false)
	end	

	self.tab3.Notice.gameObject:SetActive(false)
end

function EmailController:UpdateNoticeCount(friendCount,systemCount)
	-- body
	self.friendNoticeCount = friendCount
	self.systemNoticeCount = systemCount
end

function EmailController:InitFriendList()
	-- body
	local go = ""
	for i = 2,self.friendEmailTransformTemp.parent.childCount do
		GameObject.Destroy(self.friendEmailTransformTemp.parent:GetChild(i-1).gameObject)
	end

	if #self.fromFriendEmail ~= 0 then
	--print("aaaaaaa " .. #UTGDataTemporary.Instance().FriendEmail)
		self.friendEmail:Find("ButtonArea").gameObject:SetActive(true)
		self.noEmail.gameObject:SetActive(false)
		self.friendEmail.gameObject:SetActive(true)
		self.systemEmail.gameObject:SetActive(false)
		local friendEmailList = self.fromFriendEmail
		for i = 1,#friendEmailList do
			go = GameObject.Instantiate(self.friendEmailTransformTemp.gameObject)
			go:SetActive(true)
			go.transform:SetParent(self.friendEmailTransformTemp.parent)
			go.transform.localScale = Vector3.one
			go.transform.localPosition = Vector3.zero
			local emailType = ""
			--print("friendEmailList[i].SenderAvatar " .. friendEmailList[i].SenderAvatar)
			if friendEmailList[i].Type == 4 or friendEmailList[i].Type == 5 then
				go.transform:Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("guildicon",friendEmailList[i].SenderAvatar)
				emailType = "Guild"
				go.transform:Find("Icon/AvatarFrame").gameObject:SetActive(false)
			elseif friendEmailList[i].Type == 6 then
				go.transform:Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("guildicon",friendEmailList[i].SenderAvatar)
				emailType = "MakeGuild"
				go.transform:Find("Icon/AvatarFrame").gameObject:SetActive(false)
			else
				go.transform:Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",friendEmailList[i].SenderAvatar)
				emailType = "Friend"
				go.transform:Find("Icon/AvatarFrame"):GetComponent(Image).sprite = UITools.GetSprite("frameicon",Data.AvatarFramesData[tostring(friendEmailList[i].SenderAvatarFrameId)].Icon)
			end
			

			if friendEmailList[i].Type == 2 then
				go.transform:Find("Image").gameObject:SetActive(true)
			else 
				go.transform:Find("Image").gameObject:SetActive(false)
			end
			go.transform:Find("Text"):GetComponent(Text).text = friendEmailList[i].Title
			go.transform:Find("FriendName"):GetComponent(Text).text = friendEmailList[i].SenderName
			go.transform:Find("ReceiveTime"):GetComponent(Text).text = self:GetStringTime(friendEmailList[i].SendTime)
			if friendEmailList[i].IsRead==false then
				go.transform:Find("Notice").gameObject:SetActive(true)
			else
				go.transform:Find("Notice").gameObject:SetActive(false)
			end

			local callbackFriend = function(self, e)
				self.receivePanel.gameObject:SetActive(true)
				self.selectEmail = friendEmailList[i]
				if friendEmailList[i].IsRead == false then
					self:TabNoticeControl()
					friendEmailList[i].IsRead = true
					--print("friendEmailList[i].Id " .. friendEmailList[i].Id)
					self:ReadMail(friendEmailList[i].Id)
				end
			  	self:ShowReceiveFrame(emailType)
			end
			UITools.GetLuaScript(go.transform,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callbackFriend)
		end
	else
		self.noEmail.gameObject:SetActive(true)
		self.friendEmail.gameObject:SetActive(false)
		self.systemEmail.gameObject:SetActive(false)
		self.friendEmail:Find("ButtonArea").gameObject:SetActive(false)
	end
	self.currentFriendListSize = self.rightMainPanel:Find("Panel/ScrollbarFriend"):GetComponent("UnityEngine.UI.Scrollbar").size
	self.currentSystemListSize = self.rightMainPanel:Find("Panel/ScrollbarSystem"):GetComponent("UnityEngine.UI.Scrollbar").size

	if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
		--print("111111111111")
		WaitingPanelAPI.Instance:DestroySelf()
	end	
end

function EmailController:InitSystemList()		--from:来源，分为"Friend"/"System"
	-- body
	for i = 2,self.systemEmailTransformTemp.parent.childCount do
		GameObject.Destroy(self.systemEmailTransformTemp.parent:GetChild(i-1).gameObject)
	end

	local go = ""
	if #self.fromSystemEmail ~= 0 then
		--print("bbbbb " .. #UTGDataTemporary.Instance().SystemEmail)
		self.systemEmail:Find("ButtonArea").gameObject:SetActive(true)
		self.noEmail.gameObject:SetActive(false)
		self.friendEmail.gameObject:SetActive(false)
		self.systemEmail.gameObject:SetActive(true)
		local systemEmailList = self.fromSystemEmail
		for i = 1,#systemEmailList do
			--print(systemEmailList[i].Id .. tostring(systemEmailList[i].IsRead))
			go = GameObject.Instantiate(self.systemEmailTransformTemp.gameObject)
			go:SetActive(true)
			go.transform:SetParent(self.systemEmailTransformTemp.parent)
			go.transform.localScale = Vector3.one
			go.transform.localPosition = Vector3.zero
			--print("asdf " .. systemEmailList[i].SenderAvatar .. " " .. i)
			go.transform:Find("Text"):GetComponent(Text).text = systemEmailList[i].Title
			go.transform:Find("ReceiveTime"):GetComponent(Text).text = self:GetStringTime(systemEmailList[i].SendTime)
			if systemEmailList[i].IsRead==false then
				go.transform:Find("Notice").gameObject:SetActive(true)
				go.transform:Find("IconFull").gameObject:SetActive(true)
				go.transform:Find("IconEmpty").gameObject:SetActive(false)
			else
				go.transform:Find("Notice").gameObject:SetActive(false)
				go.transform:Find("IconFull").gameObject:SetActive(false)
				go.transform:Find("IconEmpty").gameObject:SetActive(true)
			end
			local callbackSystem = function(self, e)
				self.receivePanel.gameObject:SetActive(true)
				systemEmailList[i].IsOpen = true
				self.selectEmail = systemEmailList[i]
				if systemEmailList[i].IsRead == false then
					self:TabNoticeControl()
					systemEmailList[i].IsRead = true
					self:ReadMail(systemEmailList[i].Id)
				end
			  	self:ShowReceiveFrame("System")
			end
			UITools.GetLuaScript(go.transform,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callbackSystem)
		end
	else
		self.systemEmail:Find("ButtonArea").gameObject:SetActive(false)
		self.noEmail.gameObject:SetActive(true)
		self.friendEmail.gameObject:SetActive(false)
		self.systemEmail.gameObject:SetActive(false)
	end

	self.currentFriendListSize = self.rightMainPanel:Find("Panel/ScrollbarFriend"):GetComponent("UnityEngine.UI.Scrollbar").size
	self.currentSystemListSize = self.rightMainPanel:Find("Panel/ScrollbarSystem"):GetComponent("UnityEngine.UI.Scrollbar").size

	if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
		--print("2222222222")
		WaitingPanelAPI.Instance:DestroySelf()
	end	
end

function EmailController:MailPanelControl(numType)	--1:Friend   2:System
	-- body
	if numType == 1 then
		if #UTGDataTemporary.Instance().FriendEmail ~= 0 then
			self.friendEmail:Find("ButtonArea").gameObject:SetActive(true)
			self.noEmail.gameObject:SetActive(false)
			self.friendEmail.gameObject:SetActive(true)
			self.systemEmail.gameObject:SetActive(false)
		else
			self.noEmail.gameObject:SetActive(true)
			self.friendEmail.gameObject:SetActive(false)
			self.systemEmail.gameObject:SetActive(false)
			self.friendEmail:Find("ButtonArea").gameObject:SetActive(false)				
		end
	elseif	numType == 2 then
		if #UTGDataTemporary.Instance().SystemEmail ~= 0 then
			self.systemEmail:Find("ButtonArea").gameObject:SetActive(true)
			self.noEmail.gameObject:SetActive(false)
			self.friendEmail.gameObject:SetActive(false)
			self.systemEmail.gameObject:SetActive(true)
		else
			self.noEmail.gameObject:SetActive(true)
			self.friendEmail.gameObject:SetActive(false)
			self.systemEmail.gameObject:SetActive(false)
			self.systemEmail:Find("ButtonArea").gameObject:SetActive(false)				
		end
	elseif numType == 3 then
		self.noEmail.gameObject:SetActive(true)
		self.friendEmail.gameObject:SetActive(false)
		self.systemEmail.gameObject:SetActive(false)		
	end

end

function EmailController:ShowReceiveFrame(emailType)
	-- body
	self.receivePanel:Find("Frame/Main/DeleteButton").gameObject:SetActive(false)
	self.receivePanel:Find("Frame/Main/MakeGuildButton").gameObject:SetActive(false)


	self.receivePanel.gameObject:SetActive(true)
	if emailType == "Friend" then
		self.title:GetComponent(Text).text = self.selectEmail.Title
		self.reading:GetComponent(Text).text = self.selectEmail.Content
		self.receivePanel:Find("Frame/Title/Text"):GetComponent(Text).text = "好友邮件"
	elseif emailType == "System" then
		self.title:GetComponent(Text).text = self.selectEmail.Title
		self.reading:GetComponent(Text).text = self.selectEmail.Content
		self.receivePanel:Find("Frame/Title/Text"):GetComponent(Text).text = "系统邮件"
	elseif emailType == "Guild" or emailType == "MakeGuild" then
		self.title:GetComponent(Text).text = self.selectEmail.Title
		self.reading:GetComponent(Text).text = self.selectEmail.Content
		self.receivePanel:Find("Frame/Title/Text"):GetComponent(Text).text = "战队邮件"		
	end


	print("tostring " .. tostring(self.selectEmail.IsDrew))

	if self.selectEmail.IsDrew == true and (self.selectEmail.Type == 4 or self.selectEmail.Type == 5) then
		self.receivePanel:Find("Frame/Main/DeleteButton").gameObject:SetActive(true)
		local listener
		listener = NTGEventTriggerProxy.Get(self.receivePanel:Find("Frame/Main/DeleteButton").gameObject)
		local callbackReceive = function(self, e)
			--print("领取邮件 " .. self.selectEmail.Id)
			self.receivePanel.gameObject:SetActive(false)
			self:DeleteMail(self.selectEmail.Id,emailType)
		end
		listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackReceive, self)
	elseif self.selectEmail.IsDrew == true and self.selectEmail.Type == 6 then
		self.receivePanel:Find("Frame/Main/MakeGuildButton").gameObject:SetActive(true)
		local listener
		listener = NTGEventTriggerProxy.Get(self.receivePanel:Find("Frame/Main/MakeGuildButton").gameObject)
		local callbackMakeGuild = function(self, e)
			--print("领取邮件 " .. self.selectEmail.Id)
			self:DoGoToGuild(self.selectEmail.SenderName)
		end
		listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackMakeGuild, self)		
	end

	if self.selectEmail.IsDrew == true then
		self.receivePanel:Find("Frame/Main/Panel").gameObject:SetActive(false)
		self.receivePanel:Find("Frame/Main/Button").gameObject:SetActive(false)
		return
	else
		self.receivePanel:Find("Frame/Main/Panel").gameObject:SetActive(true)
		self.receivePanel:Find("Frame/Main/Button").gameObject:SetActive(true)
		self.receivePanel:Find("Frame/Main/DeleteButton").gameObject:SetActive(false)
		self.receivePanel:Find("Frame/Main/MakeGuildButton").gameObject:SetActive(false)		
	end

	for i = 1,#self.receiveList do
		self.receiveList[i]:Find("Skin").gameObject:SetActive(false)
		self.receiveList[i]:Find("Hero").gameObject:SetActive(false)
		self.receiveList[i].gameObject:SetActive(false)
	end

	for i = 1,#self.selectEmail.Attachments do
		self.receiveList[i].gameObject:SetActive(true)
		--print(self.selectEmail.Attachments[i].AttachmentType .. " " .. self.selectEmail.Attachments[i].AttachmentId)
		if self.selectEmail.Attachments[i].AttachmentType == 4 then
			if Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Type == 7 then
				self.receiveList[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Icon)
				self.receiveList[i]:Find("Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(95,95)
				self.receiveList[i]:Find("Skin").gameObject:SetActive(true)
			elseif  Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Type == 8 then
				--print("8 " .. self.selectEmail.Attachments[i].AttachmentId)
				--print(Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Icon)
				self.receiveList[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Icon)
				self.receiveList[i]:Find("Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(95,95)
				self.receiveList[i]:Find("Hero").gameObject:SetActive(true)
			elseif 	Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Type == 12 then
				--print("12 " .. self.selectEmail.Attachments[i].AttachmentId)
				--print(Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Icon)
				self.receiveList[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("runeicon",Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Icon)
				self.receiveList[i]:Find("Mask/Icon"):GetComponent(RectTrans).sizeDelta = Vector2.New(72.6,83.9)
			elseif	Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Type == 13 or Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Type == 14 or Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Type == 15 then
				--print("131415 " .. self.selectEmail.Attachments[i].AttachmentId)
				--print(Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Icon)
				self.receiveList[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("resourceicon",Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Icon)
			else
				--print("else " .. self.selectEmail.Attachments[i].AttachmentId)
				--print(Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Icon)
				self.receiveList[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("itemicon",Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Icon)
			end
			self.receiveList[i]:Find("Name"):GetComponent(Text).text = Data.ItemsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Name




		elseif self.selectEmail.Attachments[i].AttachmentType == 1 then
			local skinIcon = Data.SkinsData[tostring(Data.RolesData[tostring(self.selectEmail.Attachments[i].AttachmentId)])].Icon
			self.receiveList[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",skinIcon)
			self.receiveList[i]:Find("Name"):GetComponent(Text).text = Data.RolesData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Name
		elseif self.selectEmail.Attachments[i].AttachmentType == 2 then
			--print("啊手动阀手动阀 " .. self.selectEmail.Attachments[i].AttachmentId)
			local skinIcon = Data.SkinsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Icon
			self.receiveList[i]:Find("Mask/Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",skinIcon)
			self.receiveList[i]:Find("Name"):GetComponent(Text).text = Data.SkinsData[tostring(self.selectEmail.Attachments[i].AttachmentId)].Name		
		end
		self.receiveList[i]:Find("Text"):GetComponent(Text).text = self.selectEmail.Attachments[i].AttachmentNum	
	end

	local listener
	listener = NTGEventTriggerProxy.Get(self.receiveButton.gameObject)
	local callbackReceive = function(self, e)
		--print("领取邮件 " .. self.selectEmail.Id)
		self:Receive(self.selectEmail.Id)
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackReceive, self)

end

function EmailController:HideReceiveFrame()
	-- body
	for i = 1,5 do
		self.receiveList[i].gameObject:SetActive(false)
	end
	self.receivePanel.gameObject:SetActive(true)
end

function EmailController:UpdateFriendMailList()
	-- body
	local friendEmailList = self.nextPageFriendMails
	--print("sdfsdfsdf " .. #friendEmailList)
	for i = 1,#friendEmailList do
		go = GameObject.Instantiate(self.friendEmailTransformTemp.gameObject)
		go:SetActive(true)
		go.transform:SetParent(self.friendEmailTransformTemp.parent)
		go.transform.localScale = Vector3.one
		go.transform.localPosition = Vector3.zero

		--print("friendEmailList[i].SenderAvatar " .. friendEmailList[i].SenderAvatar)
		go.transform:Find("Icon"):GetComponent(Image).sprite = UITools.GetSprite("roleicon",friendEmailList[i].SenderAvatar)
		go.transform:Find("FriendName"):GetComponent(Text).text = friendEmailList[i].SenderName
		go.transform:Find("ReceiveTime"):GetComponent(Text).text = self:GetStringTime(friendEmailList[i].SendTime)
		if friendEmailList[i].IsRead==false then
			go.transform:Find("Notice").gameObject:SetActive(true)
		else
			go.transform:Find("Notice").gameObject:SetActive(false)
		end

		local callbackFriend = function(self, e)
			self.receivePanel.gameObject:SetActive(true)
			self.selectEmail = friendEmailList[i]
			if friendEmailList[i].IsRead == false then
				self:TabNoticeControl()
				friendEmailList[i].IsRead = true
				--print("friendEmailList[i].Id " .. friendEmailList[i].Id)
				self:ReadMail(friendEmailList[i].Id)
			end
		  	self:ShowReceiveFrame("Friend")
		end
		UITools.GetLuaScript(go.transform,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callbackFriend)
	end
	if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
		--print("333333333333")
		WaitingPanelAPI.Instance:DestroySelf()
	end		
end

function EmailController:UpdateSystemMailList()
	-- body
	local systemEmailList = self.nextPageSystemMails
	for i = 1,#systemEmailList do
		--print(systemEmailList[i].Id .. tostring(systemEmailList[i].IsReceive))
		go = GameObject.Instantiate(self.systemEmailTransformTemp.gameObject)
		go:SetActive(true)
		go.transform:SetParent(self.systemEmailTransformTemp.parent)
		go.transform.localScale = Vector3.one
		go.transform.localPosition = Vector3.zero
		--print("asdf " .. systemEmailList[i].SenderAvatar .. " " .. i)
		go.transform:Find("Text"):GetComponent(Text).text = systemEmailList[i].Title
		go.transform:Find("ReceiveTime"):GetComponent(Text).text = self:GetStringTime(systemEmailList[i].SendTime)
		if systemEmailList[i].IsRead==false then
			go.transform:Find("Notice").gameObject:SetActive(true)
			go.transform:Find("IconFull").gameObject:SetActive(true)
			go.transform:Find("IconEmpty").gameObject:SetActive(false)
		else
			go.transform:Find("Notice").gameObject:SetActive(false)
			go.transform:Find("IconFull").gameObject:SetActive(false)
			go.transform:Find("IconEmpty").gameObject:SetActive(true)
		end
		local callbackSystem = function(self, e)
			self.receivePanel.gameObject:SetActive(true)
			systemEmailList[i].IsOpen = true
			self.selectEmail = systemEmailList[i]
			if systemEmailList[i].IsRead == false then
				self:TabNoticeControl()
				systemEmailList[i].IsRead = true
				self:ReadMail(systemEmailList[i].Id)
			end
		  	self:ShowReceiveFrame("System")
		end
		UITools.GetLuaScript(go.transform,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callbackSystem)
	end
	if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
		--print("44444444444")
		WaitingPanelAPI.Instance:DestroySelf()
	end	
end

function EmailController:DoGetNextPageMails()
	-- body
	self.coroutine = coroutine.start(EmailController.GetNextPageMails, self)
end

function EmailController:GetNextPageMails()		--1friend 2system
	-- body
	local friendSb = self.rightMainPanel:Find("Panel/ScrollbarFriend"):GetComponent("UnityEngine.UI.Scrollbar")
	local systemSb = self.rightMainPanel:Find("Panel/ScrollbarSystem"):GetComponent("UnityEngine.UI.Scrollbar")
	local friendSizeRaw = 0
	local systemSizeRaw = 0

	while true do
		if (friendSizeRaw - friendSb.size)/friendSizeRaw > 0.3 then
			if friendSb.value == 0 then
				GameManager.CreatePanel("Waiting")
				self:UTGDataGetFriendMailList()			
			end
		end

		if (systemSizeRaw - systemSb.size)/systemSizeRaw > 0.3 then
			if systemSb.value == 0 then
				GameManager.CreatePanel("Waiting")
				self:UTGDataGetSystemMailList()				
			end
		end

		friendSizeRaw = friendSb.size
		systemSizeRaw = systemSb.size
		coroutine.wait(0.5)
	end
end

function EmailController:UTGDataGetFriendMailList()
  -- body

  --print("UTGDataTemporary.Instance().FriendEmailCount " .. UTGDataTemporary.Instance().FriendEmailCount)
  local mailListRequest = NetRequest.New()
  mailListRequest.Content = JObject.New(JProperty.New("Type","RequestMailList"),
                                        JProperty.New("Category",1),
                                        JProperty.New("BeginIndex",UTGDataTemporary.Instance().FriendEmailCount),
                                        JProperty.New("Length",5))
  mailListRequest.Handler = TGNetService.NetEventHanlderSelf(EmailController.UTGDataGetFriendMailListHandler, self)
  TGNetService.GetInstance():SendRequest(mailListRequest)    
end

function EmailController:UTGDataGetFriendMailListHandler(e)
  -- body
  if e.Type == "RequestMailList" then
    local result = tonumber(json.decode(e.Content:get_Item("Result"):ToString()))
    --print("result " .. result)
    if result == 1 then
      self.FriendMailList = {}
      local mails = json.decode(e.Content:get_Item("MailList"):ToString())
      if mails ~= nil then
        --print("aaa " .. #mails)
        self.nextPageFriendMails = mails
        for i = 1,#mails do
        	UTGDataTemporary.Instance().FriendEmailCount = UTGDataTemporary.Instance().FriendEmailCount + 1
        	table.insert(UTGDataTemporary.Instance().FriendEmail,mails[i])
        end
        self.fromFriendEmail = self:InitFriendShow()
        self:InitFriendList()	
      end
  	elseif result == 3077 then
		GameManager.CreatePanel("SelfHideNotice")
		SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已获取所有邮件")
		self.FriendMailList = {}
		local mails = json.decode(e.Content:get_Item("MailList"):ToString())
		if mails ~= nil then
		--print("aaa " .. #mails)
			self.nextPageFriendMails = mails
		for i = 1,#mails do
			UTGDataTemporary.Instance().FriendEmailCount = UTGDataTemporary.Instance().FriendEmailCount + 1
			table.insert(UTGDataTemporary.Instance().FriendEmail,mails[i])
		end
		self.fromFriendEmail = self:InitFriendShow()
		self:InitFriendList()
		end 
    end
    return true 
  end
  return false
end

function EmailController:UTGDataGetSystemMailList()
  -- body
  --print("UTGDataTemporary.Instance().FriendEmailCount " .. UTGDataTemporary.Instance().SystemEmailCount)
  local mailListRequest = NetRequest.New()
  mailListRequest.Content = JObject.New(JProperty.New("Type","RequestMailList"),
                                        JProperty.New("Category",2),
                                        JProperty.New("BeginIndex",UTGDataTemporary.Instance().SystemEmailCount),
                                        JProperty.New("Length",5))
  mailListRequest.Handler = TGNetService.NetEventHanlderSelf(EmailController.UTGDataGetSystemMailListHandler, self)
  TGNetService.GetInstance():SendRequest(mailListRequest)    
end

function EmailController:UTGDataGetSystemMailListHandler(e)
  -- body
  if e.Type == "RequestMailList" then
    local result = tonumber(json.decode(e.Content:get_Item("Result"):ToString()))
    if result == 1 then
      self.SystemMailList = {}
      local mails = json.decode(e.Content:get_Item("MailList"):ToString())
      if mails ~= nil then
        --print("aaaSystem " .. #mails)
        self.nextPageSystemMails = mails
        for i = 1,#mails do
        	UTGDataTemporary.Instance().SystemEmailCount = UTGDataTemporary.Instance().SystemEmailCount + 1
        	table.insert(UTGDataTemporary.Instance().SystemEmail,mails[i])
        end
        self.fromSystemEmail = self:InitSystemShow()
        self:InitSystemList()

      end
  	elseif result == 3077 then
		GameManager.CreatePanel("SelfHideNotice")
		SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已获取所有邮件")
		self.SystemMailList = {}
		local mails = json.decode(e.Content:get_Item("MailList"):ToString())
		if mails ~= nil then
			--print("aaaSystem " .. #mails)
			self.nextPageSystemMails = mails
			for i = 1,#mails do
				UTGDataTemporary.Instance().SystemEmailCount = UTGDataTemporary.Instance().SystemEmailCount + 1
				table.insert(UTGDataTemporary.Instance().SystemEmail,mails[i])
			end
			self.fromSystemEmail = self:InitSystemShow()
			self:InitSystemList()
		end      
    end
    return true
  end
  return false
end

function EmailController:Receive(emailId,networkDelegateDelegate,networkDelegateSelf)
	-- body
	self.isQuickDraw = false
	if self.receive == true then
		self.receive = false
	else
		return
	end


	self.receiveDelegate = networkDelegate
	self.receiveDelegateSelf = networkDelegateSelf
	local receiveRequest = NetRequest.New()
	receiveRequest.Content = JObject.New(JProperty.New("Type", "RequestDrawMail"),
											JProperty.New("MailId",emailId))
	receiveRequest.Handler = TGNetService.NetEventHanlderSelf(EmailController.ReceiveHandler, self)
	TGNetService.GetInstance():SendRequest(receiveRequest)	
end

function EmailController:ReceiveHandler(e)
	-- body
	if e.Type == "RequestDrawMail" then
		self.receive = true
		local result = json.decode(e.Content:get_Item("Result"):ToString())
		if result == 1 then
			self.receivePanel.gameObject:SetActive(false)
		else
			GameManager.CreatePanel("SelfHideNotice")
			SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("获取附件失败")
		end
		return true
	end
	return false
end

function EmailController:QuickDrawMail(drawType,networkDelegateDelegate,networkDelegateSelf)
	-- body
	self.isQuickDraw = true
	self.drawType = drawType
	self.quickDrawDelegate = networkDelegate
	self.quickDrawDelegateSelf = networkDelegateSelf
	local quickDrawRequest = NetRequest.New()
	quickDrawRequest.Content = JObject.New(JProperty.New("Type", "RequestQuickDrawMail"),
											JProperty.New("Category",drawType))
	quickDrawRequest.Handler = TGNetService.NetEventHanlderSelf(EmailController.QuickDrawMailHandler, self)
	TGNetService.GetInstance():SendRequest(quickDrawRequest)		
end

function EmailController:QuickDrawMailHandler(e)
	-- body
	if e.Type == "RequestQuickDrawMail" then
		local result = json.decode(e.Content:get_Item("Result"):ToString())
		if result == 1 then
			if quickDrawMode == 1 then
				self.fromFriendEmail = self:InitFriendShow()
				self:InitFriendList()
			elseif quickDrawMode == 2 then
				self.fromSystemEmail = self:InitSystemShow()
				self:InitSystemList()	
			end
			self:UnReadMail()
		elseif result == 3073 then
			GameManager.CreatePanel("SelfHideNotice")
			SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("附件领取完毕")			
		else
			GameManager.CreatePanel("SelfHideNotice")
			SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("获取附件失败")
		end
		return true
	end
	return false
end

function EmailController:ReadMail(mailId,networkDelegate,networkDelegateSelf)
	-- body
	self.readDelegate = networkDelegate
	self.readDelegateSelf = networkDelegateSelf
	local readRequest = NetRequest.New()
	readRequest.Content = JObject.New(JProperty.New("Type", "RequestReadMail"),
										JProperty.New("MailId",mailId))
	readRequest.Handler = TGNetService.NetEventHanlderSelf(EmailController.ReadMailHandler,self)
	TGNetService.GetInstance():SendRequest(readRequest)		
end

function EmailController:ReadMailHandler(e)
	-- body
	if e.Type == "RequestReadMail" then
		local result = json.decode(e.Content:get_Item("Result"):ToString())
		if result == 1 then
			--print("阅读邮件成功")
		else
			GameManager.CreatePanel("SelfHideNotice")
			SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("阅读邮件失败")
		end
		return true
	end
	return false
end

function EmailController:DeleteMail(mailId,mailType,networkDelegate,networkDelegateSelf)
	-- body
	--print("mailId " .. mailId)
	self.deleteDelegate = networkDelegate
	self.deleteDelegateSelf = networkDelegateSelf
	self.mailType2 = mailType
	local deleteRequest = NetRequest.New()
	deleteRequest.Content = JObject.New(JProperty.New("Type", "RequestDeleteMail"),
										JProperty.New("MailId",mailId))
	deleteRequest.Handler = TGNetService.NetEventHanlderSelf(EmailController.DeleteMailHandler, self)
	TGNetService.GetInstance():SendRequest(deleteRequest)		
end

function EmailController:DeleteMailHandler(e)
	-- body
	if e.Type == "RequestDeleteMail" then
		local result = json.decode(e.Content:get_Item("Result"):ToString())
		if result == 1 then
			if mailType == "System" then
				UTGDataTemporary.Instance().SystemEmailCount = 0
				UTGDataTemporary.Instance().SystemEmail = {}
				self:UTGDataGetSystemMailList()
			elseif mailType == "Friend" or mailType == "Guild" then
				UTGDataTemporary.Instance().FriendEmailCount = 0
				UTGDataTemporary.Instance().FriendEmail = {}
				self:UTGDataGetFriendMailList()				
			end
		elseif result == 2 then
			GameManager.CreatePanel("SelfHideNotice")
			SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("删除邮件失败")
		elseif result == 3075 then 
			GameManager.CreatePanel("SelfHideNotice")
			SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("邮件尚未领取")
		elseif result == 3076 then
			GameManager.CreatePanel("SelfHideNotice")
			SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("邮件尚未阅读")			 
		end
		return true
	end
	return false
end

function EmailController:UnReadMail(networkDelegate,networkDelegateSelf)
	-- body
	self.unReadDelegate = networkDelegate
	self.unReadDelegateSelf = networkDelegateSelf
	local unReadRequest = NetRequest.New()
	unReadRequest.Content = JObject.New(JProperty.New("Type", "RequestUnreadMailCount"))
	unReadRequest.Handler = TGNetService.NetEventHanlderSelf(EmailController.UnReadMailHandler, self)
	TGNetService.GetInstance():SendRequest(unReadRequest)		
end

function EmailController:UnReadMailHandler(e)
	-- body
	if e.Type == "RequestUnreadMailCount" then
		local result = json.decode(e.Content:get_Item("Result"):ToString())
		if result == 1 then
			local friendCount = tonumber(json.decode(e.Content:get_Item("UnreadFriendMailCount"):ToString()))
			local systemCount = tonumber(json.decode(e.Content:get_Item("UnreadSystemMailCount"):ToString()))

			if EmailAPI ~= nil and EmailAPI.Instance ~= nil then
				self:UpdateNoticeCount(friendCount,systemCount)
				self:TabNoticeControl()
			end

			if friendCount == 0 and systemCount == 0 then
				UTGDataOperator.Instance.emailNotice = false
			else
				UTGDataOperator.Instance.emailNotice = true
			end
			if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
				UTGMainPanelAPI.Instance:UpdateNotice()
			end
		elseif result == 2 then
			GameManager.CreatePanel("SelfHideNotice")
			SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("获取未阅读邮件失败")
		end
		return true
	end
	return false
end

function EmailController:GetNextReward()
	-- body
	if self.quickDrawMode == 1 then
		self:QuickDrawMail(1)
	elseif self.quickDrawMode == 2 then
		self:QuickDrawMail(2)
	end
end

function EmailController:GetStringTime(t)
  local T= UTGData.Instance():GetLeftTime(t)  
  T=math.abs(T);
  local day = math.floor(T / 86400); --以天数为单位取整 
  local str ;
  if(day == 0)then
    str = "今天"
  else
  	str = day .. "天前"
  end
  return str
end

--跳转
function EmailController:DoGoToGuild(guildName)
	-- body
	coroutine.start(EmailController.GoToGuild, self, guildName)
end
function EmailController:GoToGuild(guildName)
	-- body
	GameManager.CreatePanel("GuildList")
	coroutine.step()
	
	self.receivePanel.gameObject:SetActive(false)
	if GuildListAPI ~= nil and GuildListAPI.Instance ~= nil then
		GuildListAPI.Instance:Init(guildName)
	end

end

function EmailController:DestroySelf()
	-- body
	coroutine.stop(self.coroutine)
	if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
		UTGMainPanelAPI.Instance:ShowSelf()
	end 
	GameObject.Destroy(self.this.transform.parent.gameObject)
end

function EmailController:OnDestroy()
	-- body
	self.this = nil
	self = nil
end