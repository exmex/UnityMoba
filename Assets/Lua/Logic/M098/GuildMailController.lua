require "System.Global"

class("GuildMailController")

function GuildMailController:Awake(this)
	-- body
	self.this = this
	self.inputTitle = self.this.transforms[0]
	self.inputArea = self.this.transforms[1]
	self.sended = self.this.transforms[2]
	self.maxNum = self.this.transforms[3]
	self.sendButton = self.this.transforms[4]
	self.panel = self.this.transforms[5]
	self.cancelButton = self.this.transforms[6]

	
	self.titleText = ""
	self.contentText = ""

	local listener
	listener = NTGEventTriggerProxy.Get(self.sendButton.gameObject)
	local callbackSend = function(self, e)
		self:GetInputContent()
		self:SendGuildMail(self.titleText,self.contentText)
		if self.isOpen == true then
			self:DestroySelf()
		end
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackSend, self)

	listener = NTGEventTriggerProxy.Get(self.cancelButton.gameObject)
	local callbackSend = function(self, e)
		self:DestroySelf()
	end
	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callbackSend, self)	
end

function GuildMailController:Start()
	-- body
	GameManager.CreatePanel("Waiting")
	self:SendMailCount()
	self.panel.gameObject:SetActive(false)
	self.isOpen = true
end

function GuildMailController:InitPanel(count)
	-- body
	self.panel.gameObject:SetActive(true)
	self.sended:GetComponent("UnityEngine.UI.Text").text = count
	self.maxNum:GetComponent("UnityEngine.UI.Text").text = UTGData.Instance().ConfigData["guild_send_mail_max_count"].Int
	if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
		WaitingPanelAPI.Instance:DestroySelf()
	end			
end

function GuildMailController:GetInputContent()
	-- body
	self.titleText = self.inputTitle:Find("InputField"):GetComponent("UnityEngine.UI.InputField").text
	self.contentText = self.inputArea:Find("InputField"):GetComponent("UnityEngine.UI.InputField").text
end

function GuildMailController:SendGuildMail(title,content)
	-- body
	if content == "" then
	    GameManager.CreatePanel("SelfHideNotice")
	    if SelfHideNoticeAPI ~= nil then
	      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("内容不能为空")
	    end
	    return		
	end

	local sendMailRequest = NetRequest.New()
	sendMailRequest.Content = JObject.New(JProperty.New("Type","RequestSendGuildMail"),
										JProperty.New("Title",title),
										JProperty.New("Content",content))
	sendMailRequest.Handler = TGNetService.NetEventHanlderSelf(GuildMailController.SendGuildMailHandler,self)
	TGNetService.GetInstance():SendRequest(sendMailRequest) 	
end
function GuildMailController:SendGuildMailHandler(e)
	-- body
	if e.Type == "RequestSendGuildMail" then
		local result = tonumber(e.Content:get_Item("Result"):ToString())
		if result == 1 then
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("发送成功")
		    end
		elseif result == 3847 then
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("发送失败，您的权限不足")
		    end			
		elseif result == 3848 then
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
		    end
		elseif result == 3854 then
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("发送战队邮件当日次数限制")
		    end
		else
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("发送失败")
		    end						
		end
		return true
	end
	return false
end

function GuildMailController:SendMailCount()
	-- body
	local sendMailCountRequest = NetRequest.New()
	sendMailCountRequest.Content = JObject.New(JProperty.New("Type","RequestGuildSendMailCount"))
	sendMailCountRequest.Handler = TGNetService.NetEventHanlderSelf(GuildMailController.SendMailCountHandler,self)
	TGNetService.GetInstance():SendRequest(sendMailCountRequest) 
end
function GuildMailController:SendMailCountHandler(e)
	-- body
	if e.Type == "RequestGuildSendMailCount" then
		local result = tonumber(e.Content:get_Item("Result"):ToString())
		if result == 1 then
			self.sendedCount = tonumber(e.Content:get_Item("Count"):ToString())
			self:InitPanel(self.sendedCount)
		elseif result == 0 then
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("获取邮件发送次数失败")
		    end

			if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
				WaitingPanelAPI.Instance:DestroySelf()
			end		    
		    self:DestroySelf()	
		elseif result == 3848 then
		    GameManager.CreatePanel("SelfHideNotice")
		    if SelfHideNoticeAPI ~= nil then
		      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
		    end	
		end
		return true
	end
	return false
end

function GuildMailController:DestroySelf()
	-- body
	self.isOpen = false
	GameObject.Destroy(self.this.transform.parent.gameObject)
end

function GuildMailController:OnDestroy()
	-- body
	self.this = nil
	self = nil
end