local json = require "cjson"
class("GuildListAPI")
----------------------------------------------------
function GuildListAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  GuildListAPI.Instance=self;
  -------------------------------------
   
  
end
----------------------------------------------------
function GuildListAPI:Start()
  


  self:SetParam()
  self:AddListener()
  
  --[[
  local  guildName = "妹控战队"
  self:Init(guildName)
  --]]
  
  --self:OnButtonClick_I1()  --战队列表从0开始
  
  ----------------顶部资源条--
  
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
  self.topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  self.topAPI:GoToPosition("GuildListPanel")
  self.topAPI:ShowControl(3)
  self.topAPI:InitTop(self,function ()
                        UTGDataOperator.Instance:SetPreUIRight(self.this.transform)
                        Object.Destroy(self.this.gameObject)   
                      end,
     nil,nil,"战队")
  self.topAPI:InitResource(0)
  self.topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(self.topAPI)  
  ----------------------------

end
----------------------------------------------------
function GuildListAPI:OnDestroy() 
  
  
  ------------------------------------
  GuildListAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
------------------------------------------参数赋值--
function GuildListAPI:SetParam()  --引用及初始值
  
  ----------------------------------------------------------------------------------------------------参数默认值--
  self.canvasGroup=self.this:GetComponent("CanvasGroup"); 
   
  ----------------------------------------------------------------------------------------------------------------I1----战队列表
  --self.IB1=self.I:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Button1")
  self.I1=self.this.transform    
  
  self.I1_NoOne=self.I1:FindChild("L/Mask/ScrollRect/NoOne").gameObject  --预制体
  self.I1_GuildPrefab=self.I1:FindChild("L/Mask/ScrollRect/Guild").gameObject  --预制体
  self.I1_Content=self.I1:FindChild("L/Mask/ScrollRect/Content/Guilds")        --父节点
  self.I1_WannaMore=self.I1:FindChild("L/Mask/ScrollRect/Content/WannaMore")   --按钮:显示更多
  self.guildListBeginIndex=0  --战队列表自增索引
  self.guildListLength=20     --分页长度，索引每次增量
  
  self.I1_InputField=self.I1:FindChild("L/Search/InputField"):GetComponent("UnityEngine.UI.InputField")
  self.I1_ButtonSearch=self.I1:FindChild("L/Search/Button")

  self.I1_R=self.I1:FindChild("R").gameObject;  
  self.I1_SelectedIcon=self.I1:FindChild("R/Icon");  
  self.I1_SelectedFrame=self.I1:FindChild("R/Frame");  
  self.I1_SelectedCaptainName=self.I1:FindChild("R/CaptainName");  

  self.I1_SelectedManifesto=self.I1:FindChild("R/Manifesto");  
  self.I1_SelectedButton=self.I1:FindChild("R/Button"); 

   
end
function GuildListAPI:AddListener()

	--[[
    --战队列表 按钮事件
    local listener = NTGEventTriggerProxy.Get(self.IB1.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
      	self:OnButtonClick_I1()  --战队列表从0开始
      end ,self
      )
    --]]

    --查看更多战队
    local listener = NTGEventTriggerProxy.Get(self.I1_WannaMore.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
      	self:GuildListRequest( self.guildListBeginIndex , self.guildListLength )  --战队列表不从0开始
      end ,self
      )
    --查询战队
    local listener = NTGEventTriggerProxy.Get(self.I1_ButtonSearch.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
      	self.guildListBeginIndex=0
        self:SearchGuildRequest() 
      end ,self
      )

end
------------------------------------------------------------
function GuildListAPI:OnButtonClick_I1()  --战队列表
  self.canvasGroup.alpha=1; 
  self.canvasGroup.blocksRaycasts = true;  

  self.guildListBeginIndex = 0
  self:GuildListRequest( self.guildListBeginIndex , self.guildListLength )  
  
end

----------------------------------------------------------------------------------------------------------------获取战队列表--
function GuildListAPI:GuildListRequest( beginIndex , length )   --索引，增量

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildList"),
                                  JProperty.New("BeginIndex", beginIndex ),
                                  JProperty.New("Length", length)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildListResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildListAPI:GuildListResponseHandler(e)

  

  if(self.this.gameObject==nil)then return end
  if e.Type == "RequestGuildList" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then  
      --Debugger.LogError("成功");
      -------------------------------------------------------------------------------------------->>
       

      if(#data.GuildList<=0)then
        self.I1_NoOne:SetActive(true)
        self.I1_R:SetActive(false)
      else
        self.I1_NoOne:SetActive(false)
        self.I1_R:SetActive(true)
      end

      if(self.guildListBeginIndex==0)then
      	for i = 1,self.I1_Content.childCount do 
          GameObject.Destroy(self.I1_Content:GetChild(i-1).gameObject)
        end
      end
      self:Instantiate(data.GuildList,self.I1_GuildPrefab,self.I1_Content,self,self.Assignment_GuildList,false)  -- []publiclogic.GuildListElement //战队列表
      self.guildListBeginIndex = self.guildListBeginIndex + 20;
      if(data.IsEnd==false)then
        self.I1_WannaMore.gameObject:SetActive(true)
      else
		self.I1_WannaMore.gameObject:SetActive(false)
      end
    end

    if WaitingPanelAPI~=nil and WaitingPanelAPI.Instance~=nil then 
      WaitingPanelAPI.Instance:DestroySelf()
    end

    return true;
  else
    return false;
  end
  
end

----------------------------------------------------------------------------------------------------------------搜索战队--
function GuildListAPI:SearchGuildRequest()  --RequestSearchGuild
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestSearchGuild"),
                                  JProperty.New("GuildName", self.I1_InputField.text )
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.SearchGuildResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildListAPI:SearchGuildResponseHandler(e)
  
  if e.Type == "RequestSearchGuild" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
        --Debugger.LogError("失败");
    elseif(data.Result==1)then   --GuildInfo 
        --Debugger.LogError("成功");
      	for i = 1,self.I1_Content.childCount do 
          GameObject.Destroy(self.I1_Content:GetChild(i-1).gameObject)
        end
      
	    self:Instantiate(data.GuildInfo,self.I1_GuildPrefab,self.I1_Content,self,self.Assignment_GuildList,true)  -- []publiclogic.GuildListElement //战队列表
	    
	    self.I1_WannaMore.gameObject:SetActive(false)
	  elseif(data.Result==0x0f05 )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队不存在或战队筹备期已结束")  
    end
    return true;
  else
    return false;
  end
  
end

------------------------------根据table元素数量，逐帧实例化的Prefab，设置父物体，并填充数据--------------------------------
function GuildListAPI:Instantiate(mTable,prefab,parent,obj,func,single)
  
  --local instantiateCo= coroutine.start( self.InstantiateCoro,self, mTable,prefab,parent,obj,func,single)
  --table.insert(self.tableInstantiateCoros,instantiateCo)

  self:InstantiateCoro(mTable,prefab,parent,obj,func,single)
  
end
function GuildListAPI:InstantiateCoro(mTable,prefab,parent,obj,func,single)

    local amount=0
    for k,v in pairs(mTable) do 
      amount=amount+1
    end

    if(single==false)then 
        local indexOfSort=0
		for k,v in pairs(mTable) do   
            indexOfSort=indexOfSort+1
		    local go=GameObject.Instantiate(prefab);
		    go.transform:SetParent(parent);
		    go.transform.localScale = Vector3.one; 
		    go.transform.localPosition = Vector3.zero;
		    go.gameObject:SetActive(true);
		    --return go;
		    local isEnd;
	        if(indexOfSort==amount)then
	          isEnd=true 
	        else
	          isEnd=false 
	        end 

		    func(obj,go,k,v,indexOfSort,isEnd);
      
	      --coroutine.step();

	        if(indexOfSort==amount)then 
	          self.IsSorting=false
	          --self.SortColliderShield:SetActive(false)
	        end
	    end
    else  --一条结果的结构处理
        local go=GameObject.Instantiate(prefab);
	    go.transform:SetParent(parent);
	    go.transform.localScale = Vector3.one; 
	    go.transform.localPosition = Vector3.zero;
	    go.gameObject:SetActive(true);
	    --return go;
	    local k=1
		func(obj,go,k,mTable);
    end
    
end

function GuildListAPI:Assignment_GuildList(go,key,v)  --赋值战队列表 --guildInfo
        
    local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
    self:ShowStarLevel(go.transform:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )

    go.transform:FindChild("Icon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
    go.transform:FindChild("GuildName"):GetComponent("Text").text=v.Name 
    go.transform:FindChild("CaptainName"):GetComponent("Text").text=v.Leader.Name              
    go.transform:FindChild("Vitality"):GetComponent("Text").text=v.SeasonActivePoint
    go.transform:FindChild("Amount"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit

    UITools.GetLuaScript(go,"Logic.UICommon.UIClick"):RegisterClickDelegate(
    	self,
    	function ()   
        
	      	self.I1_SelectedIcon:GetComponent("Image").sprite = UITools.GetSprite("roleicon",v.Leader.Avatar)
	    	self.I1_SelectedFrame:GetComponent("Image").sprite = UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.Leader.AvatarFrameId)].Icon);
	    	self.I1_SelectedCaptainName:GetComponent("Text").text = v.Leader.Name  
	        self.I1_SelectedManifesto:GetComponent("Text").text = v.Declaration      

    		local listener = NTGEventTriggerProxy.Get(self.I1_SelectedButton.gameObject)  
    		listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
	    		      function ()
	    		        self:AcceptGuildInvitationRequest(self.InviteGuildId)   --邮件跳进来，要给同意邀请的按钮事件
                   
	    		      end ,
	    		      self
    		      )
        end
    ) 

    --如果是第一次获取，需要初始第一个为选中状态，右侧显示相应的选中信息
    if(self.guildListBeginIndex==0 and key==1)then 
        go:GetComponent("UnityEngine.UI.Toggle").isOn=true  --设置高亮
        UITools.GetLuaScript(go,"Logic.UICommon.UIClick"):ExecuteClickDelegate()
        --在赋值完右侧之后跳转进来
        --self:ShowPanel("I","I1");  ----------------------------------------------------------------------------------------------->>
    end

end



function GuildListAPI:Init(guildName)
  self.I1_SelectedButton.gameObject:SetActive(true)
  self:SearchGuildRequestII(guildName)
end
----------------------------------------------------------------------------------------------------------------搜索战队II--
function GuildListAPI:SearchGuildRequestII(guildName)  --RequestSearchGuild

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestSearchGuild"),
                                  JProperty.New("GuildName",guildName )
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.SearchGuildResponseHandlerII,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildListAPI:SearchGuildResponseHandlerII(e)
  
  if e.Type == "RequestSearchGuild" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
        --Debugger.LogError("失败");
    elseif(data.Result==1)then 
        
        self.canvasGroup.alpha=1; 
        self.canvasGroup.blocksRaycasts = true; 

        self.I1_R:SetActive(true)
        --Debugger.LogError("成功");
        for i = 1,self.I1_Content.childCount do 
          GameObject.Destroy(self.I1_Content:GetChild(i-1).gameObject)
        end
      
      self:Instantiate(data.GuildInfo,self.I1_GuildPrefab,self.I1_Content,self,self.Assignment_GuildList,true)  -- []publiclogic.GuildListElement //战队列表
      
      self.InviteGuildId=data.GuildInfo.Id

      self.I1_WannaMore.gameObject:SetActive(false)
    elseif(data.Result==0x0f05 )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队不存在或战队筹备期已结束")  
    end
    return true;
  else
    return false;
  end
  
end


-----------------------------------------------------------------------------------------------------------------接受战队邀请
function GuildListAPI:AcceptGuildInvitationRequest(guildId)  

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestAcceptGuildInvitation"),
                                  JProperty.New("GuildId",guildId )
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.AcceptGuildInvitationResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildListAPI:AcceptGuildInvitationResponseHandler(e)
  
  if e.Type == "RequestAcceptGuildInvitation" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
        --Debugger.LogError("失败");
    elseif(data.Result==1)then 
        --Debugger.LogError("成功");
    elseif(data.Result==0x0f15   )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("并没有人想要邀请你，少年请你面对现实")  
    elseif(data.Result==0x0f01   )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经加入战队")  
    elseif(data.Result==0x0f02    )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经响应筹备战队")  
    elseif(data.Result==0x0f0b    )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队成员数量已满")  
    else
        Debugger.LogError(data.Result)
    end
    
    self.canvasGroup.alpha=0; 
    self.canvasGroup.blocksRaycasts = false; 
    GameManager.CreatePanel("GuildHave")
    Object.Destroy(self.this.gameObject) 

    return true;
  else
    return false;
  end
  
end
-------------------------------------战队星级赋值----------------------------------
function GuildListAPI:ShowStarLevel(t,sun,moon,star)
      
      local sunPrefab=t:FindChild("Sun").gameObject
      local moonPrefab=t:FindChild("Moon").gameObject
      local starPrefab=t:FindChild("Star").gameObject
      local content=t:FindChild("Content")
      --清空
      for i = 1,content.childCount do 
        GameObject.Destroy(content:GetChild(i-1).gameObject)
      end

      for i=1,sun,1 do
        local go=GameObject.Instantiate(sunPrefab);
        go.transform:SetParent(content);
        go.transform.localScale = Vector3.one; 
        go.transform.localPosition = Vector3.zero;
        go.gameObject:SetActive(true);
      end
      for i=1,moon,1 do
        local go=GameObject.Instantiate(moonPrefab);
        go.transform:SetParent(content);
        go.transform.localScale = Vector3.one; 
        go.transform.localPosition = Vector3.zero;
        go.gameObject:SetActive(true);
      end
      for i=1,star,1 do
        local go=GameObject.Instantiate(starPrefab);
        go.transform:SetParent(content);
        go.transform.localScale = Vector3.one; 
        go.transform.localPosition = Vector3.zero;
        go.gameObject:SetActive(true);
      end

end