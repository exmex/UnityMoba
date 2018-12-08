require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
local json = require "cjson"

class("FriendAPI")
----------------------------------------------------
function FriendAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  FriendAPI.Instance=self;
  -------------------------------------
  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end
function FriendAPI:ResetPanel( )
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("FriendPanel")
  topAPI:ShowControl(3)
  topAPI:InitTop(self,function () UTGDataOperator.Instance:SetPreUIRight(self.this.transform)  Object.Destroy(self.this.gameObject) end                                       
  ,nil,nil,"好友")
  topAPI:InitResource(0)
  topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(topAPI)
end

----------------------------------------------------
function FriendAPI:Start()

  if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end
--[[
--Debugger.LogError( tostring(TGNetService.GetServerTime()) )
local from = os.time() --当前时间，单位秒
local to = os.time({year=2016,month=4,day=25,hour=21,min=30,sec=10}) --指定时间，单位秒
local sub = to-from --差  
--Debugger.LogError(sub);
--]]

--UnityEngine.Resources.UnloadUnusedAssets();
  self:ResetPanel()
      

 self:SetParam()
 self:AddListener()
 self:FriendListRequest()  
 self.ButtonToggle:GetComponent("UnityEngine.UI.Toggle").isOn=not UTGData.Instance().PlayerData.FriendApplicationSwitch
end
----------------------------------------------------
function FriendAPI:OnDestroy() 

  TGNetService.GetInstance():RemoveEventHander("NotifyPlayerFriendCandidateChange",self.playerFriendCandidateChangeNotify)
  TGNetService.GetInstance():RemoveEventHander("NotifyPlayerFriendChange", self.playerFriendChangeNotify)
  TGNetService.GetInstance():RemoveEventHander("NotifyPlayerForbidChange", self.playerForbidChangeNotify)

  
  ------------------------------------
  FriendAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
----------------------------------------------------
function FriendAPI:SetParam() 

  self.requestNummber=self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/ButtonListRequest/NumberBg/Text")
  self.ValidationInformations={"交个朋友嘛o(*￣▽￣*)ブ","听说你从来不坑队友，约吗？","久仰大名，不如加个好友一起撸？"}
  
  self.ButtonToggle=self.this.transform:FindChild("Bottom/Left/Toggle/Background").gameObject
  ----Debugger.LogError(self.ButtonToggle.name)
	self.ButtonListFriend =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/ButtonListFriend").gameObject
	self.ButtonListRequest =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/ButtonListRequest").gameObject
	self.ButtonListBlack =self.this.transform:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/ButtonListBlack").gameObject
  self.ButtonAddFriend =self.this.transform:FindChild("Bottom/Right/ButtonAddFriend").gameObject
    self.NoOne1=self.this.transform:FindChild("Right/Middle/Mask/ScrollRectListFriend/NoOne").gameObject
	self.ItemListFriend=UITools.GetLuaScript(self.this.transform:FindChild("Right/Middle/Mask/ScrollRectListFriend/Content").gameObject,"Logic.UICommon.UIItems")
	  self.NoOne2=self.this.transform:FindChild("Right/Middle/Mask/ScrollRectListRequest/NoOne").gameObject
  self.ItemListRequest=UITools.GetLuaScript(self.this.transform:FindChild("Right/Middle/Mask/ScrollRectListRequest/Content").gameObject,"Logic.UICommon.UIItems")
    self.NoOne3=self.this.transform:FindChild("Right/Middle/Mask/ScrollRectListBlack/NoOne").gameObject
	self.ItemListBlack=UITools.GetLuaScript(self.this.transform:FindChild("Right/Middle/Mask/ScrollRectListBlack/Content").gameObject,"Logic.UICommon.UIItems")
    
	self.Toggle=self.this.transform:FindChild("Bottom/Left/Toggle"):GetComponent("UnityEngine.UI.Toggle")
    --self.Toggle.isOn =true
    -----------------------------------------------------------------------------------------------------------------
    self.Pop = self.this.transform:FindChild("Pop").gameObject
    self.popCanvasGroup= self.Pop:GetComponent("CanvasGroup");    
    self.ButtonX = self.Pop.transform:FindChild("Frame/ButtonX").gameObject
    self.ButtonSerch = self.Pop.transform:FindChild("Frame/ButtonSerch").gameObject
    self.InputField = self.Pop.transform:FindChild("Frame/InputField")
    self.TextSearchResult = self.Pop.transform:FindChild("Frame/ScrollRect/Content/Text1").gameObject
    self.ItemSearchResult=UITools.GetLuaScript(self.Pop.transform:FindChild("Frame/ScrollRect/Content/SearchResult").gameObject , "Logic.UICommon.UIItems")
    self.ItemRecommendedResult=UITools.GetLuaScript(self.Pop.transform:FindChild("Frame/ScrollRect/Content/NominateResult").gameObject , "Logic.UICommon.UIItems")

    self.PopValidation= self.this.transform:FindChild("ValidationInformation").gameObject
    self.InputFieldValidation =self.PopValidation.transform:FindChild("Frame/InputField")
    self.ButtonConfirm = self.PopValidation.transform:FindChild("Frame/ButtonSerch").gameObject
    self.AddPlayerId={} --当前准备添加的好友ID
    self.wannaDestory={} --当前准备删除的go
    
end

function FriendAPI:GetStringTime(t)

  local T= UTGData.Instance():GetLeftTime(t)  
  T=math.abs(T);
  local day = T / 86400; --以天数为单位取整 
  local hour= T % 86400 / 3600; --以小时为单位取整 
  local min = T % 86400 % 3600 / 60; --以分钟为单位取整 
  local seconds = T % 86400 % 3600 % 60 / 1; --以秒为单位取整 
  local str ;
  if(day>=7)then
    str = "最近上线  " .. "7天前"
    --str = (  math.floor(day) .. "天" .. math.floor(hour) .. "小时" .. math.floor(min) .. "分" .. math.floor(seconds) .. "秒" )
  elseif(day>=1 )then --day<7
    str = "最近上线  " .. math.floor(day) .. "天前"
  elseif(hour>=1)then --<24
    str = "最近上线  " .. math.floor(hour) .. "小时" .. math.floor(min) .. "分钟前"
  elseif(min>=1 )then --<60  
    str = "最近上线  " .. math.floor(min) .. "分钟前"
  else
    str = "最近上线  " .. math.floor(seconds) .. "秒钟前"
  end
  return str
end
----------------------------------------------------
function FriendAPI:AddListener()
    
    --监听2个 
    --self:AddPlayerFriendChangeNotify() 
    --self:AddPlayerFriendCandidateChangeNotify()
    --self:AddPlayerForbidChangeNotify()

    
    local listener = NTGEventTriggerProxy.Get(self.ButtonToggle)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
        
        FriendAPI:SetFriendConfigRequest(not (self.ButtonToggle:GetComponent("UnityEngine.UI.Toggle").isOn))
                                             
      end ,self
      )

    listener = NTGEventTriggerProxy.Get(self.ButtonConfirm)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
        
        if(UITools.WidthOfString(self.InputFieldValidation:GetComponent("UnityEngine.UI.InputField").text,0)<=30)then
          self:AddFriendRequest(self.AddPlayerId)
          self.PopValidation:SetActive(false);
        else
          local notice = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
          notice:InitNoticeForNeedConfirmNotice("提示","验证信息超过15个中文字！",false,"",1)
          notice:OneButtonEvent("确定",function () notice:DestroySelf(); end,self)
        end

      end ,self
      ) 
	  listener = NTGEventTriggerProxy.Get(self.ButtonListFriend)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    	function ()
    		self:FriendListRequest() 
    	--请求数据
    	--根据返回数据 数量生成GO 再赋值 添加委托
    	end	,self
    	) 
    listener = NTGEventTriggerProxy.Get(self.ButtonListRequest)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    	function ()
        self:FriendListRequest() 
    	--请求数据
    	--根据返回数据 数量生成GO 再赋值 添加委托
    	end	,self
    	) 
    listener = NTGEventTriggerProxy.Get(self.ButtonListBlack)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    	function ()
        
    	--请求数据
    	--根据返回数据 数量生成GO 再赋值 添加委托
    	end	,self
    	) 
    listener = NTGEventTriggerProxy.Get(self.ButtonAddFriend)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    	function ()
        self:RecommendedListRequest() 

        self.ItemSearchResult:ResetItemsSimple(0);
        self.TextSearchResult:SetActive(false);
    		
        self.popCanvasGroup.blocksRaycasts = true; self.popCanvasGroup.alpha = 1; 
        
    		--请求推荐列表 生成并填充

    	end	,self
    	) 
    ------------------------------------------------------------------------------------------------------
    listener = NTGEventTriggerProxy.Get(self.ButtonSerch)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    	function ()

        if(UITools.WidthOfString(self.InputField:GetComponent("UnityEngine.UI.InputField").text,0)<=0)then
          GameManager.CreatePanel("SelfHideNotice")
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("请输入好友名字!") 
        elseif(UITools.WidthOfString(self.InputField:GetComponent("UnityEngine.UI.InputField").text,0)>12)then 
          GameManager.CreatePanel("SelfHideNotice")
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("没有找到该名玩家!") 
        else
          self:SerchListRequest()
        end

    	end	,self
    	) 

    listener = NTGEventTriggerProxy.Get(self.ButtonX)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    	function ()
    		self.popCanvasGroup.blocksRaycasts = false; self.popCanvasGroup.alpha = 0; 
    	end	,self
    	) 
end
-------------------------获取好友列表&&申请列表-----------------------
function FriendAPI:FriendListRequest() 
  
  --self.RecoEquipsId= UITools.CopyTab(self.tempRecoEquipsId);    --Debugger.LogError("临时赋值给装备数组")
  --[[
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestFriendList")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.FriendListResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  --]]
  self:FriendListResponseHandler()

end
----------------------------------------------------------------------
function FriendAPI:FriendListResponseHandler()
  --[[
  if e.Type == "RequestFriendList"  then 
    if self.this==nil then return true end
    local data = json.decode(e.Content:ToString())
  
    if(data.Result==0)then
     
      --Debugger.LogError("获取好友列表失败");
    end
    if(data.Result==1)then
      --Debugger.LogError("获取好友列表成功");
    --]]  
      self.ItemListFriend:ResetItemsSimple(0); 
      self.NoOne1:SetActive(true)--先清空
     --if(json.decode(e.Content:get_Item("FriendList"):ToString())~=nil)then

     local amountFriendList=0
      for k,v in pairs(UTGData.Instance().FriendList ) do
        amountFriendList=amountFriendList+1
      end

     if(amountFriendList~=0)then
      self.NoOne1:SetActive(false)
      self.ItemListFriend:ResetItemsSimple(amountFriendList);
      local k=0
      for i,v in pairs(UTGData.Instance().FriendList) do 
        k=k+1
        self.ItemListFriend.itemList[k].transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("roleicon",v.Avatar) 
        self.ItemListFriend.itemList[k].transform:FindChild("Frame"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.AvatarFrameId)].Icon)         
        self.ItemListFriend.itemList[k].transform:FindChild("TextName"):GetComponent("UnityEngine.UI.Text").text=v.Name
        self.ItemListFriend.itemList[k].transform:FindChild("TextLevel"):GetComponent("UnityEngine.UI.Text").text="LV." .. v.Level  
        self.ItemListFriend.itemList[k].transform:FindChild("TextIntimacy"):GetComponent("UnityEngine.UI.Text").text=v.IntimacyValue
        if(v.Status==0)then --离线
          self.ItemListFriend.itemList[k].transform:FindChild("TextTime"):GetComponent("UnityEngine.UI.Text").text=
          self:GetStringTime(v.LastSignOutTime)
        elseif(v.Status==1)then --在线
        
        elseif(v.Status==2)then --游戏中
          self.ItemListFriend.itemList[k].transform:FindChild("TextTime"):GetComponent("UnityEngine.UI.Text").text=
          "游戏中"
        elseif(v.Status==3)then --游戏中
          self.ItemListFriend.itemList[k].transform:FindChild("TextTime"):GetComponent("UnityEngine.UI.Text").text=
          "组队中"
        end
        self.ItemListFriend.itemList[k].transform:FindChild("TextVip"):GetComponent("UnityEngine.UI.Text").text=v.Vip

        local listener = NTGEventTriggerProxy.Get(self.ItemListFriend.itemList[k].transform:FindChild("Buttons/Delete/Button").gameObject)
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    		function ()
          --self:DeleteFriendRequest(v.Id);
          local notice = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
          notice:InitNoticeForNeedConfirmNotice("提示","确定删除该好友",false,"",2)
          notice:TwoButtonEvent("取消",function () notice:DestroySelf(); end,self,
                                "确定",function () self:DeleteFriendRequest(v.Id); notice:DestroySelf(); end,self)
    			
    			--self.wannaDestory=self.ItemListFriend.itemList[k]
    		end	,self
        )

        local listener = NTGEventTriggerProxy.Get(self.ItemListFriend.itemList[k].transform:FindChild("Buttons/Chat/Button").gameObject)
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
        function ()
          self:ChatWithFriend(v.PlayerId,v.Status)
        end ,self
        )

        listener = NTGEventTriggerProxy.Get(self.ItemListFriend.itemList[k].transform:FindChild("Buttons/Coin/Button").gameObject)
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
        function ()
          self:RequestGiveFriendCoin(v.Id);
          self.ItemListFriend.itemList[k].transform:FindChild("Buttons/Coin/Button"):GetComponent("UnityEngine.UI.Image").raycastTarget=false;
          self.ItemListFriend.itemList[k].transform:FindChild("Buttons/Coin/Button"):GetComponent("UnityEngine.UI.Image").color= Color.gray;
        end ,self
    		)

        if(v.IsGivenCoin)then
          self.ItemListFriend.itemList[k].transform:FindChild("Buttons/Coin/Button"):GetComponent("UnityEngine.UI.Image").raycastTarget=false;
          self.ItemListFriend.itemList[k].transform:FindChild("Buttons/Coin/Button"):GetComponent("UnityEngine.UI.Image").color= Color.gray;
        end

        local ButtonInvite = self.ItemListFriend.itemList[k].transform:FindChild("Buttons/Invite/Button")
    
        if(v.Level>=1 and  v.GuildStatus==0 and UTGData.Instance().PlayerData.GuildStatus==1)then   --对方等级  对方无战队  自己有战队
          
          ButtonInvite.parent.gameObject:SetActive(true) 
          local listener = NTGEventTriggerProxy.Get(ButtonInvite.gameObject)
          listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
          function ()
            self:InviteFriendToGuildRequest(v.Id)  --Type：RequestInviteFriendToGuild
          end ,self
          )
        else
           
        end

        
        
        


      end
     end
      
      --------------------------------------------------------------------------------------------------
     
      self.ItemListRequest:ResetItemsSimple(0); --先清空
      self.requestNummber.parent.gameObject:SetActive(false)  self.NoOne2:SetActive(true)
      --if(json.decode(e.Content:get_Item("FriendCandidateList"):ToString())~=nil)then 

      local amountFriendCandidateList=0
      for k,v in pairs(UTGData.Instance().FriendCandidateList ) do
        amountFriendCandidateList=amountFriendCandidateList+1
      end

      if(amountFriendCandidateList~=0)then 
        self.requestNummber:GetComponent("UnityEngine.UI.Text").text=tostring(amountFriendCandidateList) 
        self.requestNummber.parent.gameObject:SetActive(true)  self.NoOne2:SetActive(false)
        self.ItemListRequest:ResetItemsSimple(amountFriendCandidateList);
        local k=0
        for i,v in pairs(UTGData.Instance().FriendCandidateList ) do
          k=k+1
          self.ItemListRequest.itemList[k].transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("roleicon",v.Avatar)
          self.ItemListRequest.itemList[k].transform:FindChild("Frame"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.AvatarFrameId)].Icon)
          self.ItemListRequest.itemList[k].transform:FindChild("TextName"):GetComponent("UnityEngine.UI.Text").text=v.Name
          self.ItemListRequest.itemList[k].transform:FindChild("TextLevel"):GetComponent("UnityEngine.UI.Text").text="LV." .. v.Level  
       
          self.ItemListRequest.itemList[k].transform:FindChild("TextIntimacy"):GetComponent("UnityEngine.UI.Text").text=v.Message     
          
          self.ItemListRequest.itemList[k].transform:FindChild("TextVip"):GetComponent("UnityEngine.UI.Text").text=v.Vip
          local listener = NTGEventTriggerProxy.Get(self.ItemListRequest.itemList[k].transform:FindChild("ButtonConfirm").gameObject)
          listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                                		function ()
                                			self:AgreeAddFriendRequest(v.Id);
                                			--Object.Destroy(self.ItemListRequest.itemList[k])
                                		end	,self
                                		)
          listener = NTGEventTriggerProxy.Get(self.ItemListRequest.itemList[k].transform:FindChild("ButtonRefuse").gameObject)
          listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                                		function ()
                                			self:RefuseAddFriendRequest(v.Id);
                                			--Object.Destroy(self.ItemListRequest.itemList[k])
                                		end	,self
                                		)
        end
      end
      --------------------------------------------------------------------------------------------------
      self.ItemListBlack:ResetItemsSimple(0); --先清空
      self.NoOne3:SetActive(true)
      --if(json.decode(e.Content:get_Item("ForbidList"):ToString())~=nil)then
      local amountForbidList=0
      for k,v in pairs(UTGData.Instance().ForbidList ) do
        amountForbidList=amountForbidList+1
      end

      if(amountForbidList~=0)then
        self.NoOne3:SetActive(false)
        self.ItemListBlack:ResetItemsSimple(amountForbidList );
        local k=0
        for i,v in pairs(UTGData.Instance().ForbidList ) do
          k=k+1
          self.ItemListBlack.itemList[k].transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("roleicon",v.Avatar)
          self.ItemListBlack.itemList[k].transform:FindChild("Frame"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.AvatarFrameId)].Icon)
          self.ItemListBlack.itemList[k].transform:FindChild("TextName"):GetComponent("UnityEngine.UI.Text").text=v.Name
          self.ItemListBlack.itemList[k].transform:FindChild("TextLevel"):GetComponent("UnityEngine.UI.Text").text="LV." .. v.Level  
          if(v.Status==0)then --离线
            self.ItemListBlack.itemList[k].transform:FindChild("TextTime"):GetComponent("UnityEngine.UI.Text").text=
            self:GetStringTime(v.LastSignOutTime)
          elseif(v.Status==1)then --在线
          
          elseif(v.Status==2)then --游戏中
            self.ItemListBlack.itemList[k].transform:FindChild("TextTime"):GetComponent("UnityEngine.UI.Text").text=
            "游戏中"
          elseif(v.Status==3)then --游戏中
            self.ItemListBlack.itemList[k].transform:FindChild("TextTime"):GetComponent("UnityEngine.UI.Text").text=
            "组队中"
          end
          --self.ItemListBlack.itemList[k].transform:FindChild("TextIntimacy"):GetComponent("UnityEngine.UI.Text").text=v.Message     
          
          --self.ItemListBlack.itemList[k].transform:FindChild("TextVip"):GetComponent("UnityEngine.UI.Text").text=v.Vip
          local listener = NTGEventTriggerProxy.Get(self.ItemListBlack.itemList[k].transform:FindChild("Button").gameObject)
          listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                                    function ()
                                      self:RemoveForbidRequest(v.PlayerId);
                                      --Object.Destroy(self.ItemListBlack.itemList[k])
                                    end ,self
                                    )
          
        end
      end
      --------------------------------------------------------------------------------------------------
    --end

  --[[

    return true;
  else
    return false;
  end
  --]]

end
---------------------------------删除好友-----------------------------
function FriendAPI:DeleteFriendRequest(friendId ) 
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestRemoveFriend"),
                                  JProperty.New("FriendId",friendId)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.DeleteFriendResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end


----------------------------------------------------------------------
function FriendAPI:DeleteFriendResponseHandler(e)
  
  if e.Type == "RequestRemoveFriend" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("删除好友失败");
    elseif(data.Result==1)then
      --Debugger.LogError("删除好友成功");
      --Object.Destroy(self.wannaDestory)
    elseif(data.Result==0x0605 )then
      --Debugger.LogError("并不是好友关系");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("并不是好友关系!") 
    end

    return true;
  else
    return false;
  end

end
---------------------------------邀请好友加入战队-----------------------------
function FriendAPI:InviteFriendToGuildRequest(friendId ) 
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestInviteFriendToGuild"),
                                  JProperty.New("FriendId",friendId)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.InviteFriendToGuildResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function FriendAPI:InviteFriendToGuildResponseHandler(e)
  
  if e.Type == "RequestInviteFriendToGuild" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("邀请成功") 
    elseif(data.Result==0x0f01  )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("好友已经加入战队") 
    elseif(data.Result==0x0f02  )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("好友已经响应筹备战队") 
    elseif(data.Result==0x0f08  )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中") 
    elseif(data.Result==0x060d  )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("好友已经被邀请过了")
    elseif(data.Result==0x060e  )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("好友正在邀请中")
    end

    return true;
  else
    return false;
  end

end
---------------------------------赠送金币-----------------------------
function FriendAPI:RequestGiveFriendCoin(friendid)
  local request = NetRequest.New()
  request.Content = JObject.New(JProperty.New("Type","RequestGiveFriendCoin"),
                                JProperty.New("FriendId",tonumber(friendid)))
  request.Handler = TGNetService.NetEventHanlderSelf( self.RequestGiveFriendCoinHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  self.friendType = tonumber(type)
end
----------------------------------------------------------------------
function FriendAPI:RequestGiveFriendCoinHandler(e)

  if e.Type =="RequestGiveFriendCoin" then
  
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result == 1 then
      --Debugger.LogError("金币赠送成功！")
    elseif result == 0   then
      --Debugger.LogError("金币赠送失败！")
    elseif result == 0x0605  then
      --Debugger.LogError("并不是好友关系！")
    elseif result == 0x060c   then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经赠送过金币了!") 
    end
    return true
  end
  return false
end
---------------------------------同意申请-----------------------------
function FriendAPI:AgreeAddFriendRequest(Id)
	
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestAgreeFriendApplication"),
                                  JProperty.New("CandidateId",Id)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.AgreeAddFriendResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)

end
----------------------------------------------------------------------
function FriendAPI:AgreeAddFriendResponseHandler(e)
  
  if e.Type == "RequestAgreeFriendApplication" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("添加好友失败");
    elseif(data.Result==1)then
      --Debugger.LogError("添加好友成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("和TA成为游戏好友!") 
    elseif(data.Result==0x0603 )then
      --Debugger.LogError("好友申请不存在");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("好友申请不存在!") 
    elseif(data.Result==0x0604 )then
      --Debugger.LogError("已经是好友关系");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经和对方是好友!") 
    elseif(data.Result==0x0609 )then
      --Debugger.LogError("好友列表已满");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("好友列表已满!") 
    elseif(data.Result==0x060b )then
      --Debugger.LogError("好友列表已满");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("对方已将您屏蔽!") 
    end

    return true;
  else
    return false;
  end

end
---------------------------------取消屏蔽-----------------------------
function FriendAPI:RemoveForbidRequest(Id)

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestRemoveForbid"),
                                  JProperty.New("TargetPlayerId",Id)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf(FriendAPI.RemoveForbidResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)

end
----------------------------------------------------------------------
function FriendAPI:RemoveForbidResponseHandler(e)
  
  if e.Type == "RequestRemoveForbid" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
    elseif(data.Result==0x0a02  )then
      --Debugger.LogError("并没有屏蔽对方");
      --GameManager.CreatePanel("SelfHideNotice")
      --SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("并没有屏蔽对方!") 
    end

    return true;
  else
    return false;
  end

end
---------------------------------拒绝申请-----------------------------
function FriendAPI:RefuseAddFriendRequest(Id)
	
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestRefuseFriendApplication"),
                                  JProperty.New("CandidateId",Id)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.RefuseAddFriendResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)

end
----------------------------------------------------------------------
function FriendAPI:RefuseAddFriendResponseHandler(e)
  
  if e.Type == "RequestRefuseFriendApplication" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("拒绝好友失败");
    elseif(data.Result==1)then
      --Debugger.LogError("拒绝好友成功");
    elseif(data.Result==0x0603 )then
      --Debugger.LogError("好友申请不存在");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("好友申请不存在!") 
    end

    return true;
  else
    return false;
  end

end
---------------------------------获取推荐好友-----------------------------
function FriendAPI:RecommendedListRequest() 
  
  --self.RecoEquipsId= UITools.CopyTab(self.tempRecoEquipsId);    --Debugger.LogError("临时赋值给装备数组")
   
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestRecommendedFriends")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.RecommendedListResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function FriendAPI:RecommendedListResponseHandler(e)

  if e.Type == "RequestRecommendedFriends" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
     
      --Debugger.LogError("获取推荐列表失败");
    end
    if(data.Result==1)then
      --Debugger.LogError("获取推荐列表成功");
     if(json.decode(e.Content:get_Item("RecommendedFriends"):ToString())~=nil)then
      self.ItemRecommendedResult:ResetItemsSimple(#data.RecommendedFriends);

      for k,v in pairs(data.RecommendedFriends ) do
        self.ItemRecommendedResult.itemList[k].transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("roleicon",v.Avatar)
        --self.ItemRecommendedResult.itemList[k].transform:FindChild("Frame"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.AvatarFrameId)].Icon)
        self.ItemRecommendedResult.itemList[k].transform:FindChild("TextName"):GetComponent("UnityEngine.UI.Text").text=v.Name
        self.ItemRecommendedResult.itemList[k].transform:FindChild("TextLevel"):GetComponent("UnityEngine.UI.Text").text="LV." .. v.Level  
        
        self.ItemRecommendedResult.itemList[k].transform:FindChild("TextVip"):GetComponent("UnityEngine.UI.Text").text=v.Vip
       local listener = NTGEventTriggerProxy.Get(self.ItemRecommendedResult.itemList[k].transform:FindChild("ButtonConfirm").gameObject)--加好友
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
        function ()
          self.InputFieldValidation:GetComponent("UnityEngine.UI.InputField").text=self.ValidationInformations[math.random(1,3)]
          self.PopValidation:SetActive(true);
          self.AddPlayerId=v.PlayerId 
          
          self.wannaDestory=self.ItemRecommendedResult.itemList[k]
        end ,self
        )
        listener = NTGEventTriggerProxy.Get(self.ItemRecommendedResult.itemList[k].transform:FindChild("ButtonRefuse").gameObject)--访问
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
        function ()
          --self:RefuseAddFriendRequest(v.Id);
          --Object.Destroy(self.ItemRecommendedResult.itemList[k])
        end ,self
        )
      end
     end
    end

    return true;
  else
    return false;
  end

end
---------------------------------添加好友-----------------------------
function FriendAPI:AddFriendRequest(Id)
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestSendFriendApplication"),
                                  JProperty.New("TargetPlayerId",Id),
                                  JProperty.New("Message",self.InputFieldValidation:GetComponent("UnityEngine.UI.InputField").text)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.AddFriendResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)

end
----------------------------------------------------------------------
function FriendAPI:AddFriendResponseHandler(e)
  
  if e.Type == "RequestSendFriendApplication" then
 --Debugger.LogError(e.Type)  
    local data = json.decode(e.Content:ToString())
    --Debugger.LogError(data.Result)
    
    if(data.Result==0)then
      --Debugger.LogError("申请添加好友失败");
    elseif(data.Result==1)then
      --Debugger.LogError("申请添加好友成功");
      Object.Destroy(self.wannaDestory) self.TextSearchResult:SetActive(false)
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("成功向对方发送好友请求!")
    elseif(data.Result==0x0601 )then
      --Debugger.LogError("已经发送过好友申请");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("重复向对方发送好友请求!")
    elseif(data.Result==0x0602 )then
      --Debugger.LogError("好友申请信息过长");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("申请信息最长为15个中文字!")
    elseif(data.Result==0x0604 )then
      --Debugger.LogError("已经和对方是好友");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经和对方是好友!")
    elseif(data.Result==0x0606 )then
      --Debugger.LogError("对方拒绝接受申请");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("玩家拒绝加好友!")
    elseif(data.Result==0x0609 )then
      --Debugger.LogError("对方好友已满");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("对方好友已满!") 
    elseif(data.Result==0x060a )then
      --Debugger.LogError("不能向自己申请好友");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不能向自己申请好友!") 
    end

    return true;
  else
    return false;
  end

end
---------------------------------获取搜索好友-----------------------------
function FriendAPI:SerchListRequest() 
   
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestSearchPlayer"),
                                  JProperty.New("PlayerName",self.InputField:GetComponent("UnityEngine.UI.InputField").text)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.SerchListResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function FriendAPI:SerchListResponseHandler(e)

  if e.Type == "RequestSearchPlayer" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("获取搜索列表失败");
    elseif(data.Result==0x0607 )then
      --Debugger.LogError("查不到该玩家");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("没有找到该名玩家!") 
    elseif(data.Result==0x0608 )then
      --Debugger.LogError("搜索玩家时玩家名过长");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("名字最长为6个中文字或12个英文字!") 
    elseif(data.Result==1)then
      --Debugger.LogError("获取搜索列表成功");
       self.TextSearchResult:SetActive(false);
     if(json.decode(e.Content:get_Item("Player"):ToString())~=nil)then
       self.ItemSearchResult:ResetItemsSimple(1);
       self.TextSearchResult:SetActive(true);
 
      --for k,v in pairs(data.Player  ) do
        self.ItemSearchResult.itemList[1].transform:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("roleicon",data.Player.Avatar)
        --self.ItemSearchResult.itemList[1].transform:FindChild("Frame"):GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.AvatarFrameId)].Icon)
        self.ItemSearchResult.itemList[1].transform:FindChild("TextName"):GetComponent("UnityEngine.UI.Text").text=data.Player.Name
        self.ItemSearchResult.itemList[1].transform:FindChild("TextLevel"):GetComponent("UnityEngine.UI.Text").text="LV." .. data.Player.Level  
        --self.ItemSearchResult.itemList[1].transform:FindChild("TextIntimacy"):GetComponent("UnityEngine.UI.Text").text=v.IntimacyValue
        self.ItemSearchResult.itemList[1].transform:FindChild("TextTime"):GetComponent("UnityEngine.UI.Text").text=
        self:GetStringTime(data.Player.LastSignOutTime)
        self.ItemSearchResult.itemList[1].transform:FindChild("TextVip"):GetComponent("UnityEngine.UI.Text").text=data.Player.Vip
       local listener = NTGEventTriggerProxy.Get(self.ItemSearchResult.itemList[1].transform:FindChild("ButtonConfirm").gameObject)--加好友
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
        function ()                                                                      
          self.InputFieldValidation:GetComponent("UnityEngine.UI.InputField").text=self.ValidationInformations[math.random(1,3)]
          self.PopValidation:SetActive(true);
          self.AddPlayerId=data.Player.PlayerId  
          
          self.wannaDestory=self.ItemSearchResult.itemList[1]
          
        end ,self
        )
        listener = NTGEventTriggerProxy.Get(self.ItemSearchResult.itemList[1].transform:FindChild("ButtonRefuse").gameObject)--访问
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
        function ()
          --self:RefuseAddFriendRequest(v.Id);
          --Object.Destroy(self.ItemSearchResult.itemList[k])
        end ,self
        )
      --end
     end
    end

    return true;
  else
    return false;
  end

end
----------------------------------------------------------------------
---------------------------------设置是否可以被加-----------------------------
function FriendAPI:SetFriendConfigRequest(bool)

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestSetFriendConfig"),
                                  JProperty.New("ApplicationSwitch",bool)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.SetFriendConfigResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)

end
----------------------------------------------------------------------
function FriendAPI:SetFriendConfigResponseHandler(e)
  
  if e.Type == "RequestSetFriendConfig" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("设置失败");
    elseif(data.Result==1)then
      --Debugger.LogError("设置成功");
    end

    return true;
  else
    return false;
  end

end

---------------------------------监听好友数据变化-----------------------------
function FriendAPI:AddPlayerFriendChangeNotify() 

  self.playerFriendChangeNotify = TGNetService.NetEventHanlderSelf( self.PlayerFriendChangeNotify,self)
  TGNetService.GetInstance():AddEventHandler("NotifyPlayerFriendChange",self.playerFriendChangeNotify, 1)--回调

end
------------------------------------------------------------------------------
function FriendAPI:PlayerFriendChangeNotify(e)
  
  if e.Type == "NotifyPlayerFriendChange" then
    
    local data = json.decode(e.Content:ToString())

    --Debugger.LogError(data.PlayerId)
    --Debugger.LogError(data.Action)
    --Debugger.LogError(data.Friend) --结构

    self:FriendListRequest() --临时刷新

    return false;
  else
    return false;
  end

end
---------------------------------监听好友申请变化-----------------------------
function FriendAPI:AddPlayerFriendCandidateChangeNotify()

  self.playerFriendCandidateChangeNotify = TGNetService.NetEventHanlderSelf( self.PlayerFriendCandidateChangeNotify,self)
  TGNetService.GetInstance():AddEventHandler("NotifyPlayerFriendCandidateChange",self.playerFriendCandidateChangeNotify, 0)--回调

end
-----------------------------------------------------------------------------
function FriendAPI:PlayerFriendCandidateChangeNotify(e)
  
  if e.Type == "NotifyPlayerFriendCandidateChange" then
    
    local data = json.decode(e.Content:ToString())

    --Debugger.LogError(data.PlayerId)
    --Debugger.LogError(data.Action)
    --Debugger.LogError(data.FriendCandidate) --结构
    
    self:FriendListRequest() --临时刷新

    return true;
  else
    return false;
  end

end

---------------------------------监听取消屏蔽变化-----------------------------
function FriendAPI:AddPlayerForbidChangeNotify()

  self.playerForbidChangeNotify = TGNetService.NetEventHanlderSelf( self.PlayerForbidChangeNotify,self)
  TGNetService.GetInstance():AddEventHandler("NotifyPlayerForbidChange",self.playerForbidChangeNotify, 1)--回调

end
-----------------------------------------------------------------------------
function FriendAPI:PlayerForbidChangeNotify(e)
  
  if e.Type == "NotifyPlayerForbidChange" then
    
    local data = json.decode(e.Content:ToString())

    --Debugger.LogError(data.PlayerId)
    --Debugger.LogError(data.Action)
    --Debugger.LogError(data.FriendCandidate) --结构
    
    self:FriendListRequest() --临时刷新

    return true;
  else
    return false;
  end

end
-----------------------------------------------------------------------------
function FriendAPI:ChatWithFriend(playerId,state)
  if tonumber(state) == 0 then 
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("好友已离线")
    return
  end

  local chat_self = UTGDataOperator.Instance.ChatList[1]
  if chat_self ~=nil then 
    chat_self:ClickOpenMainPanel()
    chat_self:ClickOpenFriendChatPanel(playerId)
    self:HideSelf()
  end

end

function FriendAPI:ShowSelf()
  self.this.transform.localPosition = Vector3.zero
end
function FriendAPI:HideSelf()
  self.this.transform.localPosition = Vector3.New(0,1000,0)
end



