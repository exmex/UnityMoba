
require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"
local json = require "cjson"
class("GuildAPI")
----------------------------------------------------
function GuildAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  GuildAPI.Instance=self;
  -------------------------------------
  self:SetParam() 

  ----------------------------
  
  
  

end
----------------------------------------------------
function GuildAPI:Start()
  self:AddListener() 
  self:Initialize() 
  ----------------顶部资源条--
  
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
  self.topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  self.topAPI:GoToPosition("GuildPanel")
  self.topAPI:ShowControl(3)
  self.topAPI:InitTop(self,function ()
                        UTGDataOperator.Instance:SetPreUIRight(self.this.transform)
                        Object.Destroy(self.this.gameObject)   
                      end,
     nil,nil,"战队")
  self.topAPI:InitResource(0)
  self.topAPI:HideSom("Button")
  UTGDataOperator.Instance:SetResourceList(self.topAPI)  

  self.this.transform:FindChild("ButtonRule"):SetAsLastSibling(); 

end
----------------------------------------------------
function GuildAPI:OnDestroy() 
  coroutine.stop(self.Co_CountDownRevive)
  
  ------------------------------------
  GuildAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil

end
------------------------------------------参数赋值--
function GuildAPI:SetParam()  --引用及初始值

  self.ValidationInformations={"交个朋友嘛o(*￣▽￣*)ブ","听说你从来不坑队友，约吗？","久仰大名，不如加个好友一起撸？"}

  --战队玩法等级限制
  for k,v in pairs(UTGData.Instance().LevelFunc) do  
    for k1,v1 in pairs(v) do 
      if(v1.Type==5)then
        self.UnlockLevel=v1.UnlockLevel
        break
      end
    end
  end

  self.tableInstantiateCoros={}
  ----------------------------------------------------------------------------------------------------参数默认值--
  self.canvasGroup=self.this:GetComponent("CanvasGroup"); 

  self.canRefreshGuildList=true                   --可以刷新战队列表
  self.canRefreshPreparingGuildList=true          --可以刷新筹备中战队列表
  self.canRefreshMyselfPreparingGuildDetail=true  --可以刷新自己筹备中战队信息

  self.canRefreshMyselfGuildInfo=true          --可以刷新筹备中战队列表
  self.canRefreshMyselfGuildMember=true  --可以刷新自己筹备中战队信息
  
  self.canRefresh_GuildLastWeekRank=true
  self.canRefresh_GuildWeekRank=true
  self.canRefresh_GuildLevelSeasonRank=true
  self.canRefresh_GuildSeasonRank=true

  self.canGuildConfig=true  --可以战队管理确认按钮
  ----------------------------------------------------------------------------------------------------------------
  --添加好友验证信息
  self.PopValidation= self.this.transform:FindChild("ValidationInformation").gameObject
  self.InputFieldValidation =self.PopValidation.transform:FindChild("Frame/InputField")
  self.ButtonConfirm = self.PopValidation.transform:FindChild("Frame/ButtonSerch").gameObject
  --self.AddPlayerId={} --当前准备添加的好友ID
  --self.wannaDestory={} --当前准备删除的go
  
  --事件提示框
  self.DelegateTip=self.this.transform:FindChild("DelegateTip");     
  self.DelegateTip_Title=self.DelegateTip:FindChild("Frame/Title"):GetComponent("Text")  
  self.DelegateTip_PromptContent=self.DelegateTip:FindChild("Frame/PromptContent"):GetComponent("Text") 
  self.DelegateTip_ButtonEnter=self.DelegateTip:FindChild("Frame/ButtonEnter"); 
  self.DelegateTip_ButtonCancel=self.DelegateTip:FindChild("Frame/ButtonCancel"); 
  
  --修改宣言
  self.DeclarationTip=self.this.transform:FindChild("DeclarationTip");     
  --self.DeclarationTip_Title=self.DelegateTip:FindChild("Frame/Title"):GetComponent("Text")  
  self.DeclarationTip_InputField=self.DeclarationTip:FindChild("Frame/InputField"):GetComponent("UnityEngine.UI.InputField")
  self.DeclarationTip_ButtonEnter=self.DeclarationTip:FindChild("Frame/ButtonEnter"); 
  self.DeclarationTip_ButtonCancel=self.DeclarationTip:FindChild("Frame/ButtonCancel"); 

  --任命副队长
  self.AppointViceLeaderTip=self.this.transform:FindChild("AppointViceLeaderTip");     
  self.AppointViceLeaderTip_Toggle1=self.AppointViceLeaderTip:FindChild("Frame/ToggleGroup/Toggle1"); 
  self.AppointViceLeaderTip_Toggle2=self.AppointViceLeaderTip:FindChild("Frame/ToggleGroup/Toggle2"); 
  self.AppointViceLeaderTip_ButtonEnter=self.AppointViceLeaderTip:FindChild("Frame/ButtonEnter"); 
  self.AppointViceLeaderTip_ButtonCancel=self.AppointViceLeaderTip:FindChild("Frame/ButtonCancel"); 
  
  self.I=self.this.transform:FindChild("NoGuild");       --没有队伍界面
  self.II=self.this.transform:FindChild("HaveGuild");    --拥有队伍界面
  self.III=self.this.transform:FindChild("GuildChart");  --战队排行界面
  ----------------------------------------------------------------------------------------------------------------I1----战队列表
  self.IB1=self.I:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Button1")
  self.I1=self.I:FindChild("Right/1")
  
  self.I1_NoOne=self.I1:FindChild("L/Mask/ScrollRect/NoOne").gameObject  --预制体
  self.I1_GuildPrefab=self.I1:FindChild("L/Mask/ScrollRect/I1_GuildPrefab").gameObject  --预制体
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
  self.I1_SelectedGrade=self.I1:FindChild("R/Grade");  
  self.I1_SelectedGradeIcon=self.I1:FindChild("R/GradeIcon"); 
  self.I1_SelectedBonus=self.I1:FindChild("R/Bonus");  
  self.I1_SelectedButton=self.I1:FindChild("R/Button");  
  ----------------------------------------------------------------------------------------------------------------I2----筹备战队
  self.IB2=self.I:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Button2")
  self.I2=self.I:FindChild("Right/2") 
  self.I2G=self.I2:FindChild("Guild")

  self.I2_NoOne=self.I2G:FindChild("L/Mask/ScrollRect/NoOne").gameObject  --预制体
  self.I2_GuildPrefab=self.I2G:FindChild("L/Mask/ScrollRect/I2_GuildPrefab").gameObject  --预制体
  self.I2_Content=self.I2G:FindChild("L/Mask/ScrollRect/Content/Guilds")        --父节点
  self.I2_WannaMore=self.I2G:FindChild("L/Mask/ScrollRect/Content/WannaMore")   --按钮:显示更多
  self.preparingGuildListBeginIndex=0  --战队列表自增索引
  self.preparingGuildListLength=20     --分页长度，索引每次增量
                  
  self.I2_InputField=self.I2G:FindChild("L/Search/InputField"):GetComponent("UnityEngine.UI.InputField")
  self.I2_ButtonSearch=self.I2G:FindChild("L/Search/Button")
  
  self.I2_R=self.I2G:FindChild("R").gameObject; 
  self.I2_SelectedIcon=self.I2G:FindChild("R/Icon");  
  self.I2_SelectedFrame=self.I2G:FindChild("R/Frame");  
  self.I2_SelectedCaptainName=self.I2G:FindChild("R/CaptainName");  
  self.I2_SelectedManifesto=self.I2G:FindChild("R/Manifesto");  
  self.I2_SelectedButton=self.I2G:FindChild("R/Button"); 
  ----------------------------------------------------------------------------------------------------------------I2C----筹备中
  self.I2M=self.I2:FindChild("Member")

  self.I2C_GuildPrefab=self.I2M:FindChild("L/Mask/ScrollRect/I2C_GuildPrefab").gameObject  --预制体
  self.I2C_Content=self.I2M:FindChild("L/Mask/ScrollRect/Content/Guilds")        --父节点

  self.I2C_SelectedIcon=self.I2M:FindChild("R/Icon"):GetComponent("Image");  
  self.I2C_SelectedGuildIcon=self.I2M:FindChild("R/GuildIcon"):GetComponent("Image"); 
  self.I2C_SelectedFrame=self.I2M:FindChild("R/Frame"):GetComponent("Image");  
  self.I2C_SelectedCaptainName=self.I2M:FindChild("R/CaptainName"):GetComponent("Text");  
  self.I2C_SelectedGuildName=self.I2M:FindChild("R/GuildName"):GetComponent("Text");  
  self.I2C_SelectedMember=self.I2M:FindChild("R/Member"):GetComponent("Text");  
  self.I2C_SelectedLimitTime=self.I2M:FindChild("R/LimitTime"):GetComponent("Text");  
  ----------------------------------------------------------------------------------------------------------------I3----创建战队
  self.IB3=self.I:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Button3")
  self.I3=self.I:FindChild("Right/3")

  self.I3_InputField1=self.I3:FindChild("L/InputField1"):GetComponent("UnityEngine.UI.InputField")
  self.I3_InputField2=self.I3:FindChild("L/InputField2"):GetComponent("UnityEngine.UI.InputField")
  self.I3_Cost=self.I3:FindChild("L/Cost"):GetComponent("Text")  --.text="<color=red>XXXX</color>"
  
  self.I3_Icon=self.I3:FindChild("R/Icon"):GetComponent("Image")
  self.I3_ButtonChange=self.I3:FindChild("R/ButtonChange")  --修改战队图标
  self.I3_ButtonCreate=self.I3:FindChild("R/ButtonCreate")  --创建战队

  self.I3_Pop=self.I3:FindChild("Pop")
  self.I3_Content=self.I3_Pop:FindChild("Mask/ScrollRect/Content")
  self.I3_GuildIcon=self.I3_Pop:FindChild("Mask/ScrollRect/I3_GuildIcon")

  --默认选择第一个图标   
  self.selectedGuildIconId=UTGData.Instance().GuildIconsDataArray[1].Id
  self.I3_Icon.sprite=UITools.GetSprite("guildicon", UTGData.Instance().GuildIconsDataArray[1].Icon); 

  --填充点券数量
  if(UTGData.Instance().PlayerData.Voucher>50)then
    self.I3_Cost.text="<color=green>" .. 50 .. "</color>/" .. UTGData.Instance().PlayerData.Voucher
  else
    self.I3_Cost.text="<color=red>" .. 50 .. "</color>/" .. UTGData.Instance().PlayerData.Voucher
  end
  ----------------------------------------------------------------------------------------------------------------II1---信息
  self.IIB1=self.II:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Button1")
  self.II1=self.II:FindChild("Right/1")

  self.II1_MemberPrefab=self.II1:FindChild("L/Mask/ScrollRect/II1_MemberPrefab").gameObject  --预制体
  self.II1_Content=self.II1:FindChild("L/Mask/ScrollRect/Content/Members")        --父节点

  --UTGData.Instance().CurrentSeasonInfo--当前赛季信息
  self.II1_StarLevel=self.II1:FindChild("R/StarLevel")
  self.II1_Icon=self.II1:FindChild("R/Icon"):GetComponent("Image")   
  self.II1_GuildName=self.II1:FindChild("R/GuildName"):GetComponent("Text") 
  self.II1_CaptainName=self.II1:FindChild("R/CaptainName"):GetComponent("Text") 
  self.II1_SeasonActivePoint=self.II1:FindChild("R/SeasonActivePointContent/SeasonActivePoint"):GetComponent("Text") 
  self.II1_LevelImage=self.II1:FindChild("R/LevelImage"):GetComponent("Image") 
  self.II1_Level=self.II1:FindChild("R/Level"):GetComponent("Text") 
  self.II1_CoinAdditionalRate=self.II1:FindChild("R/CoinAdditionalRate"):GetComponent("Text") 
  self.II1_WeeklyReward=self.II1:FindChild("R/WeeklyReward"):GetComponent("Text") 

  self.II1_SeasonDiiamond=self.II1:FindChild("R/SeasonDiiamond"):GetComponent("Text") 
  self.II1_DailyActivePoint=self.II1:FindChild("R/DailyActivePoint"):GetComponent("Text") 
  self.II1_Button=self.II1:FindChild("R/Button")
  self.II1_EndTime=self.II1:FindChild("R/EndTime"):GetComponent("Text")     
  --下
  self.II1_SelfInfo = self.II1:FindChild("L/Search")  --自身信息父节点
  --上
  self.II1_WeeklyRank=self.II1:FindChild("L/Top/Num") 
  self.II1_RankList = self.II1:FindChild("L/Top/Button1") 
  self.II1_GuildShop = self.II1:FindChild("L/Top/Button2") 
  self.II1_SignIn = self.II1:FindChild("L/Top/Button3") 
  self.II1_SignInBlack = self.II1:FindChild("L/Top/Button3Black") 
  --Pops
  self.II1_Pop_SignIn=self.II1:FindChild("Pops/HaveSignIn")  
  
  ----------------------------------------------------------------------------------------------------------------II2---成员
  self.IIB2=self.II:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Button2")
  self.II2=self.II:FindChild("Right/2")

  self.II2_MemberPrefab=self.II2:FindChild("L/Mask/ScrollRect/II2_MemberPrefab").gameObject  --预制体
  self.II2_Content=self.II2:FindChild("L/Mask/ScrollRect/Content/Members")        --父节点
  --右
  self.II2_Icon=self.II2:FindChild("R/Icon"):GetComponent("Image")   
  self.II2_GuildName=self.II2:FindChild("R/GuildName"):GetComponent("Text") 
  self.II2_CaptainName=self.II2:FindChild("R/CaptainName"):GetComponent("Text")
  self.II2_StarLevel=self.II2:FindChild("R/StarLevel")
  self.II2_Manifestos=self.II2:FindChild("R/Manifestos"):GetComponent("Text") 
  self.II2_ButtonChange=self.II2:FindChild("R/ButtonChange")
  self.II2_ButtonInvite=self.II2:FindChild("R/ButtonInvite")
  self.II2_ButtonGuild=self.II2:FindChild("R/ButtonGuild")

  

  --上
  self.II2_Amount=self.II2:FindChild("L/Top/Amount"):GetComponent("Text")
  self.II2_ButtonAddMember=self.II2:FindChild("L/Top/ButtonAddMember")
  self.II2_ButtonGuildLog=self.II2:FindChild("L/Top/ButtonGuildLog")
  self.II2_ButtonGuildEmail=self.II2:FindChild("L/Top/ButtonGuildEmail")

  
  self.II2_ButtonSort1=self.II2:FindChild("L/SortButtons/Button1")
  self.II2_ButtonSort2=self.II2:FindChild("L/SortButtons/Button2")
  self.II2_ButtonSort3=self.II2:FindChild("L/SortButtons/Button3")
  self.II2_ButtonSort4=self.II2:FindChild("L/SortButtons/Button4")
  self.SortColliderShield=self.II2:FindChild("L/SortButtons/ColliderShield").gameObject
  --下
  self.II2_ButtonQuit =self.II2:FindChild("L/Search/Button1")
  self.II2_ButtonRecruit  =self.II2:FindChild("L/Search/Button2")
  self.II2_ButtonManage =self.II2:FindChild("L/Search/Button3")
  self.II2_ButtonApplicationList =self.II2:FindChild("L/Search/Button4")
  self.II2_ApplicationPoint=self.II2:FindChild("L/Search/Button4/RedPoint")

  self.InviteCDCollider = self.II2:FindChild("L/Search/Button2/ButtonInviteCD")
  self.InviteCDTime=self.II2:FindChild("L/Search/Button2/ButtonInviteCD/Text"):GetComponent("Text") 


  --Pops
  self.II2_Pop_ApplicationList=self.II2:FindChild("Pops/ApplicationList")  
  self.II2_Pop_ApplicationList_Prefab=self.II2_Pop_ApplicationList:FindChild("Mask/ScrollRect/II2_Pop_ApplicationList_Prefab") 
  self.II2_Pop_ApplicationList_Content=self.II2_Pop_ApplicationList:FindChild("Mask/ScrollRect/Content/Members") 
  self.II2_Pop_ApplicationList_WannaMore=self.II2_Pop_ApplicationList:FindChild("Mask/ScrollRect/Content/WannaMore")
  self.ButtonToggle=self.II2_Pop_ApplicationList:FindChild("Toggle/Background")
  self.ApplicationListBeginIndex=0
  self.ApplicationListLength=20
  
  self.II2_Pop_GuildLog=self.II2:FindChild("Pops/GuildLogList")  
  self.II2_Pop_GuildLogPrefab=self.II2_Pop_GuildLog:FindChild("Mask/ScrollRect/II2_Pop_GuildLogPrefab")  
  self.II2_Pop_GuildLogContent=self.II2_Pop_GuildLog:FindChild("Mask/ScrollRect/Content") 
  
  self.II2_Pop_GuildConfig=self.II2:FindChild("Pops/ChangeGuildConfig")  
  self.II2_Pop_GuildConfig_GuildName=self.II2_Pop_GuildConfig:FindChild("GuildName"):GetComponent("Text")   
  self.II2_Pop_GuildConfig_GuildNameButton=self.II2_Pop_GuildConfig:FindChild("Button_GuildName")
  self.II2_Pop_GuildConfig_GuildIcon=self.II2_Pop_GuildConfig:FindChild("GuildIcon"):GetComponent("Image") 
  self.II2_Pop_GuildConfig_GuildIconButton=self.II2_Pop_GuildConfig:FindChild("Button_ChangeIcon")
  self.II2_Pop_GuildConfig_ToggleTrue=self.II2_Pop_GuildConfig:FindChild("Toggle1")
  self.II2_Pop_GuildConfig_ToggleFalse=self.II2_Pop_GuildConfig:FindChild("Toggle2")
  self.II2_Pop_GuildConfig_LevelLimit=self.II2_Pop_GuildConfig:FindChild("LevelLimit"):GetComponent("Text") 
  self.II2_Pop_GuildConfig_LevelLimitA=self.II2_Pop_GuildConfig:FindChild("Button_LevelIncrease")
  self.II2_Pop_GuildConfig_LevelLimitD=self.II2_Pop_GuildConfig:FindChild("Button_LevelDecrease") 
  self.II2_Pop_GuildConfig_GradeLimit=self.II2_Pop_GuildConfig:FindChild("GradeLimit"):GetComponent("Text") 
  self.II2_Pop_GuildConfig_GradeLimitA=self.II2_Pop_GuildConfig:FindChild("Button_GradeIncrease")
  self.II2_Pop_GuildConfig_GradeLimitD=self.II2_Pop_GuildConfig:FindChild("Button_GradeDecrease") 
  self.II2_Pop_GuildConfig_ButtonConfirm=self.II2_Pop_GuildConfig:FindChild("ButtonConfirm") 
  self.II2_Pop_GuildConfig_ButtonRefuse=self.II2_Pop_GuildConfig:FindChild("ButtonRefuse") 
  ----------------------------------------------------------------------------------------------------------------III1--本周排名
  self.IIIB1=self.III:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Button1")
  self.III1=self.III:FindChild("Right/1")

  self.III1_Prefab=self.III1:FindChild("L/Mask/ScrollRect/III1_Prefab").gameObject
  self.III1_Content=self.III1:FindChild("L/Mask/ScrollRect/Content/Guilds") 

  self.III1_Search=self.III1:FindChild("L/Search") 
  ----------------------------------------------------------------------------------------------------------------III2--上周排名
  self.IIIB2=self.III:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Button2")
  self.III2=self.III:FindChild("Right/2")

  self.III2_Prefab=self.III2:FindChild("L/Mask/ScrollRect/III2_Prefab").gameObject
  self.III2_Content=self.III2:FindChild("L/Mask/ScrollRect/Content/Guilds") 

  self.III2_Search=self.III2:FindChild("L/Search") 
  ----------------------------------------------------------------------------------------------------------------III3--赛季排名
  self.IIIB3=self.III:FindChild("Left/Middle/Mask/ScrollRect/ServerMenu/Button3")
  self.III3=self.III:FindChild("Right/3")

  self.III3I_Prefab=self.III3:FindChild("I/Mask/ScrollRect/III3I_Prefab").gameObject
  self.III3I_Content=self.III3:FindChild("I/Mask/ScrollRect/Content/Guilds") 
  self.III3II_Prefab=self.III3:FindChild("II/Mask/ScrollRect/III3II_Prefab").gameObject
  self.III3II_Content=self.III3:FindChild("II/Mask/ScrollRect/Content/Guilds") 

  self.III3I_Search=self.III3:FindChild("I/Search") 
  self.III3II_Search=self.III3:FindChild("II/Search") 
  --Top
  self.III3_BI=self.III3:FindChild("Top/Button1")
  self.III3_BII=self.III3:FindChild("Top/Button2")
  ----------------------------------------------------------------------------------------------------------------子窗体table
  self.tablePanel={}
  	self.tablePanel.I=self.I:GetComponent("CanvasGroup")
  	self.tablePanel.II=self.II:GetComponent("CanvasGroup")
  	self.tablePanel.III=self.III:GetComponent("CanvasGroup")
  self.tablePanelSon={}  --强制跳转到的界面并打开对应按钮的高亮，对于主动点击按钮响应:如果没有写TabControl，给按钮注册ShowPanel也是一样的
    self.tablePanelSon.I1={self.I1:GetComponent("CanvasGroup"),self.IB1}
    self.tablePanelSon.I2G={self.I2G:GetComponent("CanvasGroup"),self.IB2}  --筹备战队
    self.tablePanelSon.I2M={self.I2M:GetComponent("CanvasGroup"),self.IB2}  --筹备战队
  	self.tablePanelSon.I3={self.I3:GetComponent("CanvasGroup"),self.IB3}  --创建战队 
    
    self.tablePanelSon.II1={self.II1:GetComponent("CanvasGroup"),self.IIB1}  --战队信息
    self.tablePanelSon.II2={self.II2:GetComponent("CanvasGroup"),self.IIB2}  --战队成员

    self.tablePanelSon.III1={self.III1:GetComponent("CanvasGroup"),self.IIIB1}  --战队信息
    self.tablePanelSon.III2={self.III2:GetComponent("CanvasGroup"),self.IIIB2}  --战队成员
    self.tablePanelSon.III3={self.III3:GetComponent("CanvasGroup"),self.IIIB3}  --战队信息

end
------------------------------------------------------------
function GuildAPI:ShowPanel(index1,index2)  --指定打开某节点，及其某子节点，关闭其他
  --Debugger.LogError(index1) Debugger.LogError(index2)
	for k,v in pairs(self.tablePanel) do  
		if(k==index1)then
	    v.alpha=1;v.blocksRaycasts = true;   
    else
		  v.alpha=0;v.blocksRaycasts = false;   
	 end
	end
	for k,v in pairs(self.tablePanelSon) do 
		if(k==index2)then
	      v[1].alpha=1;v[1].blocksRaycasts = true;   
	      v[2]:GetComponent("UnityEngine.UI.Toggle").isOn=true  --设置高亮
		else
		  v[1].alpha=0;v[1].blocksRaycasts = false;   
	  end
	end
   
  self.canvasGroup.alpha=1;  self.canvasGroup.blocksRaycasts = true;   --打开总面板
  
  if WaitingPanelAPI~=nil and WaitingPanelAPI.Instance~=nil then 
    WaitingPanelAPI.Instance:DestroySelf()
  end

end  
------------------------------------------------------------
function GuildAPI:Initialize() 
    --[[
    if(UTGData.Instance().PlayerData.GuildStatus==0)then      --未加入战队-->战队列表
	    self:OnButtonClick_I1()    --执行
    elseif(UTGData.Instance().PlayerData.GuildStatus==1)then  --已加入战队
      self:OnButtonClick_II1() 
    elseif(UTGData.Instance().PlayerData.GuildStatus==2)then  --筹备中
      self:OnButtonClick_I2()  
    elseif(UTGData.Instance().PlayerData.GuildStatus==3)then  --申请中
    
    end
    --]]
    
    
    self.II2_ApplicationPoint.gameObject:SetActive(UTGDataOperator.Instance.battleGroupButtonNotice)  --战队列表红点
  
end
------------------------------------------------------------
function GuildAPI:OnButtonClick_I1()  --战队列表
  --self:ShowPanel("I","I1"); 
  if(self.canRefreshGuildList)then  --如果可以，重新申请（搜索过可以）  
    self.guildListBeginIndex = 0
    
    self:GuildListRequest( self.guildListBeginIndex , self.guildListLength )  --此中有跳转------------------------------------>>
    self.canRefreshGuildList=false
  else  --为了表现效果，服务器返回之后赋值完毕，再切换面板
    self:ShowPanel("I","I1");  ----------------------------------------------------------------------------------------------->>
  end
  
end
function GuildAPI:OnButtonClick_I2()  --筹备战队列表
	if(UTGData.Instance().PlayerData.GuildStatus==2)then  --筹备中 
  
      --self:ShowPanel("I","I2M");     
      if(self.canRefreshMyselfPreparingGuildDetail)then             
        --if(UTGData.Instance().MyselfPreparingGuildData~=nil)then  --已有值，无须再取，直接赋值
          
          self:InitializeMyselfPreparingGuildDetailInfo(UTGData.Instance().MyselfPreparingGuildData)--此中有跳转 --------------->> 
          self:InitializeMyselfPreparingGuildDetailMembers(UTGData.Instance().MyselfPreparingGuildData)  
        --else  --先取再赋值
          --self:MyselfPreparingGuildDetailRequest()       --此中有跳转 -------------------------------------------------------->>    
        --end    
        self.canRefreshMyselfPreparingGuildDetail=false     
      else   
        self:ShowPanel("I","I2M"); ------------------------------------------------------------------------------------------->>                   
      end                                                                     
	else         
      --self:ShowPanel("I","I2G");                                        --查看筹备中的战队                                                           
      if(self.canRefreshPreparingGuildList)then 
        self.preparingGuildListBeginIndex = 0
        self:PreparingGuildListRequest( self.preparingGuildListBeginIndex , self.preparingGuildListLength )  --此中有跳转 ---->> 
        self.canRefreshPreparingGuildList=false 
      else
        self:ShowPanel("I","I2G"); ------------------------------------------------------------------------------------------->>
      end
	end

end
function GuildAPI:OnButtonClick_I3()  --筹备战队列表

  self:ShowPanel("I","I3");  ------------------------------------------------------------------------------------------------->>

end
function GuildAPI:OnButtonClick_II1()  --战队-信息-界面
  
  self.I3_Pop:SetParent(self.II2)
  --self:ShowPanel("II","II1");  ---------------------------------------------------------------------------------->>
  if(self.canRefreshMyselfGuildInfo==true)then

    self.needShow_MyselfGuildDetail=true
    self:InitializeMyselfGuildDetailInfo(UTGData.Instance().MyselfGuild)
    self:InitializeMyselfGuildDetailMembers(UTGData.Instance().MyselfGuild)
    
    self.canRefreshMyselfGuildInfo=false
  else
    self:ShowPanel("II","II1");
  end
  
end
function GuildAPI:OnButtonClick_II2()  --战队-成员-界面
  
  --self:ShowPanel("II","II2");  ----------------------------------------------------------------------------------------------->>
  if(self.canRefreshMyselfGuildMember==true)then 

    self.needShow_MyselfGuildMember=true
    self:InitializeMyselfGuildInfo(UTGData.Instance().MyselfGuild) 
    --self:InitializeMyselfGuildMembers(UTGData.Instance().MyselfGuild.Members)
    --默认职务排序------
    if(self.IsSorting==false)then
          self.IsSorting=true 
          self.SortColliderShield:SetActive(true)
          local tableTemp={}
          for k,v in pairs(UTGData.Instance().MyselfGuild.Members) do
            table.insert(tableTemp,v)
          end
          table.sort(tableTemp,
            function(a,b) 
              if(a.PositionLevel ~= b.PositionLevel )then
                return a.PositionLevel < b.PositionLevel 
              else
                if(UTGData.Instance():GetLeftTime(a.LastSignOutTime) ~= UTGData.Instance():GetLeftTime(b.LastSignOutTime))then
                  return UTGData.Instance():GetLeftTime(a.LastSignOutTime) > UTGData.Instance():GetLeftTime(b.LastSignOutTime)
                else
                  return a.SeasonActivePoint > b.SeasonActivePoint
                end
              end
              
            end )

          self:InitializeMyselfGuildMembers(tableTemp)
    end
    --------------------

    self.canRefreshMyselfGuildMember=false
  else
    self:ShowPanel("II","II2");  
  end
  
end
function GuildAPI:OnButtonClick_III1()  --战队-排行榜-本周

  self:ShowPanel("III","III1");  ----------------------------------------------------------------------------------------------->>
  

  if(self.canRefresh_GuildWeekRank==true)then 
    if(self.In_GuildWeekRank~=true)then
      self:InitSelf_GuildWeekRank(UTGData.Instance().MyselfGuild)
    end
    self:GuildWeekRankRequest()
    
    
    self.canRefresh_GuildWeekRank=false
  end

end
function GuildAPI:OnButtonClick_III2()  --战队-排行榜-上周
  
  self:ShowPanel("III","III2");  ----------------------------------------------------------------------------------------------->>
  

  if(self.canRefresh_GuildLastWeekRank==true)then 
    if(self.In_GuildLastWeekRank~=true)then
      self:InitSelf_GuildLastWeekRank(UTGData.Instance().MyselfGuild)
    end
    self:GuildLastWeekRankRequest()
    
    
    self.canRefresh_GuildLastWeekRank=false
  end

end
function GuildAPI:OnButtonClick_III3()  --战队-排行榜-赛季跳转
  
  self:ShowPanel("III","III3");  ----------------------------------------------------------------------------------------------->>
 

  if(self.canRefresh_GuildLevelSeasonRank==true)then 
    if(self.In_GuildLevelSeasonRank~=true)then
      self:InitSelf_GuildLevelSeasonRank(UTGData.Instance().MyselfGuild)
    end
    self:GuildLevelSeasonRankRequest() 
    
    
    self.canRefresh_GuildLevelSeasonRank=false
  end

end
function GuildAPI:OnButtonClick_III3I()  --战队-排行榜-同等级赛季
  

  if(self.canRefresh_GuildLevelSeasonRank==true)then 
    if(self.In_GuildLevelSeasonRank~=true)then
      self:InitSelf_GuildLevelSeasonRank(UTGData.Instance().MyselfGuild)
    end
    self:GuildLevelSeasonRankRequest() 
    
    
    self.canRefresh_GuildLevelSeasonRank=false
  end

end
function GuildAPI:OnButtonClick_III3II()  --战队-排行榜-赛季
  
  if(self.canRefresh_GuildSeasonRank==true)then 
    
    if(self.In_GuildSeasonRank~=true)then
      self:InitSelf_GuildSeasonRank(UTGData.Instance().MyselfGuild)
    end
    self:GuildSeasonRankRequest() 
    
    self.canRefresh_GuildSeasonRank=false
  end

end
------------------------------------------------------------
function GuildAPI:AddListener()
    
    --添加好友验证信息确定按钮
    local listener = NTGEventTriggerProxy.Get(self.ButtonConfirm)
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
    --战队商店
    local listener = NTGEventTriggerProxy.Get(self.II1_GuildShop.gameObject)   
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
        GameManager.CreatePanel("GuildShop")
      end ,self
      )
    --战队邮件
    local listener = NTGEventTriggerProxy.Get(self.II2_ButtonGuildEmail.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
        GameManager.CreatePanel("GuildMail")
      end ,self
      )
    
    self.buttonRule = self.this.transform:FindChild("ButtonRule").gameObject; 
    local listener = NTGEventTriggerProxy.Get(self.buttonRule)
            listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( 
              function ()
                GameManager.CreatePanel("PageText")
                PageTextAPI.instance:Init("战队规则","<color=#CCCDDF><color=#FFFFFF>一、创建战队</color>\n创建的战队将先进入筹备期，其他玩家可在筹备列表中查看处于筹备期的战队，在筹备期内征集到足够的响应者则创建成功。成功后，创建和响应者都成为该战队成员，创建者任队长，并从响应者中产生2名副队长。\n<color=#FFFFFF>二、添加队员</color>\n<color=#EF9B02>队长、副队长</color>可以邀请好友加入战队，只需好友同意方可加入成功。队员可推荐好友加入战队，推荐后若队长或副队长同意，便会向该好友发送入队邀请。\n<color=#FFFFFF>三、战队成员金币加成</color>\n战队成员在参加实战对抗、天梯赛时，可获得结算金币收益加成。<color=#EF9B02>战队人数上限</color>越高，加成比率越高，最高可达50%。\n<color=#FFFFFF>四、活跃点</color>\n战队活跃点需要战队成员参与游戏内活动来获得：\n1、胜场奖励：每场实战对抗胜利（人机对战3V3,5V5，酒吧大乱斗也计算在内）可获得40活跃点，每场排位赛胜利可获得60点活跃点，和战队成员组队获胜可获得双倍活跃点；每天最多通过胜场奖励获得<color=#EF9B02>200</color>活跃点\n2、每日签到：每天可在战队界面签到，排位赛段位越高签到获得的活跃点越高，最高可获得100点活跃点。\n3、钻石消费：每消耗10钻石或点券可获得1点活跃点，每日最高可通过消费获得<color=#EF9B02>200</color>活跃点。\n<color=#FFFFFF>五、活跃点与战队评级</color>\n1、战队活跃点决定了战队的评级 。\n2、战队评级与战队活跃的关系：\n步兵连：活跃点达到0\n工兵营：活跃点达到20万\n炮兵团：活跃点达到40万\n坦克旅：活跃点达到60万\n装甲师：活跃点达到80万\n航空军：活跃点达到100万\n3、每个新的战队赛季开启时，会清空战队活跃点。 \n<color=#FFFFFF>六、战队竞技奖励</color>\n1、<color=#EF9B02>周奖励</color>：每周根据当周各战队活跃点获得情况进行排名，并发放奖励，战队各成员奖励相等。周排名奖励如下：\n第1名  金币1500\n第2名  金币1250\n第3名  金币1000\n第4-10名  金币 750\n第11-50名  金币600\n第51-100名  金币400\n未上榜战队  金币150\n战队成员若退出战队或被移除战队，他今日贡献的活跃点将从战队中扣除。\n2、<color=#EF9B02>赛季奖励</color>：每个赛季结束时，根据战队评级发放奖励\n步兵连：100钻石\n工兵营：200钻石\n炮兵团：300钻石\n坦克旅：500钻石\n装甲师：750钻石\n航空军：1000钻石\n<color=#EF9B02>战队成员在当前战队的赛季活跃点超过2000，才有资格获取赛季奖励</color>\n<color=#FFFFFF>七、战队星级</color>\n1、战队星级体现战队历史实力，每当战队评级提升时，战队星级会提升一级。\n2、战队星级是累积等级，不会随赛季更新而清空。</color>")
              end,self
              )
  ----------------------------------------------------------------------------------------------------------------I1----战队列表
    --战队列表 按钮事件
    local listener = NTGEventTriggerProxy.Get(self.IB1.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
      	self:OnButtonClick_I1()  --战队列表从0开始
      end ,self
      )
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
    
  ----------------------------------------------------------------------------------------------------------------I2----筹备战队
    --筹备战队列表 按钮事件
    local listener = NTGEventTriggerProxy.Get(self.IB2.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
      	self:OnButtonClick_I2()  --战队列表从0开始
      end ,self
      )
    --查看更多筹备战队
    local listener = NTGEventTriggerProxy.Get(self.I2_WannaMore.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
      	self:PreparingGuildListRequest( self.preparingGuildListBeginIndex , self.preparingGuildListLength )  --筹备战队列表不从0开始
      end ,self
      )
    --查询筹备中的战队
    local listener = NTGEventTriggerProxy.Get(self.I2_ButtonSearch.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
        self.preparingGuildListBeginIndex=0
        self:SearchPreparingGuildRequest()
       
      end ,self
      )
  ----------------------------------------------------------------------------------------------------------------I3----创建战队
    --
    local listener = NTGEventTriggerProxy.Get(self.IB3.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
        self:OnButtonClick_I3() 
      end ,self
      )
    --修改战队图标
    local listener = NTGEventTriggerProxy.Get(self.I3_ButtonChange.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
        --先清空子物体
        
        while(self.I3_Content.childCount>0) do
          UIPool.Instance:Return(self.I3_Content:GetChild(0).gameObject)
        end
        --在弹出的窗口中生成图标列表的并赋值   
        self:Instantiate(UTGData.Instance().GuildIconsDataArray,"I3_GuildIcon",self.I3_Content,self,self.Assignment_GuildIcon,false) 
        self.I3_Pop.gameObject:SetActive(true)
      end ,self
      )
    
    --创建战队
    local listener = NTGEventTriggerProxy.Get(self.I3_ButtonCreate.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
        
        --不符合条件，提示，return
        if( UITools.WidthOfString(self.I3_InputField1.text,0)<=0 )then  --名字大于7个汉字
          GameManager.CreatePanel("SelfHideNotice")
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队名不能为空，请您输入战队名称")
          return;
        end
        if( UITools.WidthOfString(self.I3_InputField1.text,0)>14 )then  --名字大于7个汉字
		      GameManager.CreatePanel("SelfHideNotice")
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("名字最长为7个中文字")
		      return;
		    end
		    if( UITools.WidthOfString(self.I3_InputField2.text,0)>90 )then  --名字大于7个汉字
			    GameManager.CreatePanel("SelfHideNotice")
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队宣言最长为45个中文字")
		      return;
		    end
        
        --符合条件，弹窗
	  	  self.DelegateTip_Title.text="提示"   
		    self.DelegateTip_PromptContent.text="您创建的战队将进入48小时筹备期，期内征集到5个响应者即成为正式战队，否则创建失败。\n是否确定创建？"

        local listener = NTGEventTriggerProxy.Get(self.DelegateTip_ButtonEnter.gameObject)  --确认按钮事件
	      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    	      function ()
              
    	        self:CreateGuildRequest()
    	        self.DelegateTip.gameObject:SetActive(false)
    	      end ,self
    	      )
        self.DelegateTip.gameObject:SetActive(true)
        
      end ,self
      )
  ----------------------------------------------------------------------------------------------------------------II1---信息
    local listener = NTGEventTriggerProxy.Get(self.II1_Button.gameObject)  ----战队赛按钮
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
        GameManager.CreatePanel("SelfHideNotice")
        SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("该功能正在努力建设中，敬请期待")
      end ,self
      )

    local listener = NTGEventTriggerProxy.Get(self.IIB1.gameObject)  --信息按钮
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
        self:OnButtonClick_II1() 
      end ,self
      )
    
    local listener = NTGEventTriggerProxy.Get(self.II1_SignIn.gameObject)  --签到按钮
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
        self:GuildSignInRequest() 
      end ,self
      )

    local listener = NTGEventTriggerProxy.Get(self.II2_ButtonApplicationList.gameObject)  --申请列表按钮
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
        self.ApplicationListBeginIndex=0
        self:GuildApplicationListRequest(self.ApplicationListBeginIndex , self.ApplicationListLength ) 
      end ,self
      )

    local listener = NTGEventTriggerProxy.Get(self.II1_RankList.gameObject)  --战队排行按钮
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
        self:OnButtonClick_III1()

          self.topAPI:InitTop(self,function ()
                        self:ShowPanel("II","II1");
                        --初始化可请求状态
                        self.canRefresh_GuildWeekRank=true
                        self.canRefresh_GuildLastWeekRank=true
                        self.canRefresh_GuildLevelSeasonRank=true
                        self.canRefresh_GuildSeasonRank=true
                        --------------------------
                        self.topAPI:InitTop(self,function ()
                        UTGDataOperator.Instance:SetPreUIRight(self.this.transform)
                        Object.Destroy(self.this.gameObject)   
                        end,
                        nil,nil,"战队")
                        --------------------------
                      end,
          nil,nil,"战队")

      end ,self
      )
  ----------------------------------------------------------------------------------------------------------------II2---成员
  
  --战队招募
  local listener = NTGEventTriggerProxy.Get(self.II2_ButtonRecruit.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
        self:GuildInviteCD(120)
        self:SendGuildInvitationRequest()
                                             
      end ,self
      )

  local listener = NTGEventTriggerProxy.Get(self.ButtonToggle.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
        
        self:ChangeFlagShowNewApplicationRequest(not (self.ButtonToggle:GetComponent("UnityEngine.UI.Toggle").isOn))
                                             
      end ,self
      )

  local listener = NTGEventTriggerProxy.Get(self.IIB2.gameObject)  
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    function ()  
      self:OnButtonClick_II2() 
    end ,self
    )

  local listener = NTGEventTriggerProxy.Get(self.II2_ButtonInvite.gameObject)  
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    function ()  
      GameManager.CreatePanel("Friend")
      
    end ,self
    )
  
  local listener = NTGEventTriggerProxy.Get(self.II2_ButtonGuild.gameObject)  
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    function ()  
      
      self:DoGoToGuildListPanel()
      GameManager.CreatePanel("Waiting")
    end ,self
    )

  --修改宣言
  local listener = NTGEventTriggerProxy.Get(self.II2_ButtonChange.gameObject) 
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
                --弹窗        
        local listener = NTGEventTriggerProxy.Get(self.DeclarationTip_ButtonEnter.gameObject)  --确认按钮事件
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
            function () 
              
              --不符合条件，提示，return
             
              if( UITools.WidthOfString(self.DeclarationTip_InputField.text,0)>90 )then  --名字大于7个汉字
                GameManager.CreatePanel("SelfHideNotice")
                SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队宣言最长为45个中文字")
                return;
              end

              self:ChangeGuildDeclarationRequest(self.DeclarationTip_InputField.text) 
              self.DeclarationTip_InputField.text=""
              self.DeclarationTip.gameObject:SetActive(false)
            end ,self
            )
        self.DeclarationTip.gameObject:SetActive(true)
      end ,self
      )
  

  ----------------------------------退出战队-----------------------------------
  local listener = NTGEventTriggerProxy.Get(self.II2_ButtonQuit.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
              if(self.canFlagDisbandGuild==true)then  --有解散权限
                if(self.GuildMemberCount==1)then --成员个数不为1
                  --弹窗
                  self.DelegateTip_Title.text="提示"   
                  self.DelegateTip_PromptContent.text="队长退队后，这个战队将解散。\n确定退队吗？"
                  local listener = NTGEventTriggerProxy.Get(self.DelegateTip_ButtonEnter.gameObject)  --确认按钮事件
                  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                      function () 
                        self:LeaveGuildRequest() 
                        self.DelegateTip.gameObject:SetActive(false)
                      end ,self
                      )
                  self.DelegateTip.gameObject:SetActive(true)
                else
                  GameManager.CreatePanel("SelfHideNotice")
                  SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("您当前是队长，需要传位后才可以退出")
                end
              else
                --弹窗
                self.DelegateTip_Title.text="提示"   
                self.DelegateTip_PromptContent.text="退出战队后，1小时内无法加入其他战队。\n确定退出战队吗？"
                local listener = NTGEventTriggerProxy.Get(self.DelegateTip_ButtonEnter.gameObject)  --确认按钮事件
                listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                    function () 
                      self:LeaveGuildRequest() 
                      self.DelegateTip.gameObject:SetActive(false)
                    end ,self
                    )
                self.DelegateTip.gameObject:SetActive(true)
              end
      end ,self
      )
  ----------------------------------Sort按钮-----------------------------------
  local listener = NTGEventTriggerProxy.Get(self.II2_ButtonSort1.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
        
        if(self.IsSorting==false)then
          self.IsSorting=true 
          self.SortColliderShield:SetActive(true)
          local tableTemp={}
          for k,v in pairs(UTGData.Instance().MyselfGuild.Members) do
            table.insert(tableTemp,v)
          end
          table.sort(tableTemp,
            function(a,b) 
              if(a.PositionLevel ~= b.PositionLevel )then
                return a.PositionLevel < b.PositionLevel 
              else
                if(UTGData.Instance():GetLeftTime(a.LastSignOutTime) ~= UTGData.Instance():GetLeftTime(b.LastSignOutTime))then
                  return UTGData.Instance():GetLeftTime(a.LastSignOutTime) > UTGData.Instance():GetLeftTime(b.LastSignOutTime)
                else
                  return a.SeasonActivePoint > b.SeasonActivePoint
                end
              end
              
            end )

          self:InitializeMyselfGuildMembers(tableTemp)
        end

      end ,self
      )
  local listener = NTGEventTriggerProxy.Get(self.II2_ButtonSort2.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()     

        if(self.IsSorting==false)then
          self.IsSorting=true
          self.SortColliderShield:SetActive(true)
          local tableTemp={}
          for k,v in pairs(UTGData.Instance().MyselfGuild.Members) do
            table.insert(tableTemp,v)
          end
          table.sort(tableTemp, function(a,b) return a.WeeklyActivePoint > b.WeeklyActivePoint end )

          self:InitializeMyselfGuildMembers(tableTemp)
        end
      
      end ,self
      )
  local listener = NTGEventTriggerProxy.Get(self.II2_ButtonSort3.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()    
        
        if(self.IsSorting==false)then
          self.IsSorting=true
          self.SortColliderShield:SetActive(true)
          local tableTemp={}
          for k,v in pairs(UTGData.Instance().MyselfGuild.Members) do
            table.insert(tableTemp,v)
          end
          table.sort(tableTemp,  function(a,b) return a.SeasonActivePoint > b.SeasonActivePoint end )

          self:InitializeMyselfGuildMembers(tableTemp)
        end

      end ,self
      )
  local listener = NTGEventTriggerProxy.Get(self.II2_ButtonSort4.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  
        
        if(self.IsSorting==false)then
          self.IsSorting=true
          self.SortColliderShield:SetActive(true)
          local tableTemp={}
          for k,v in pairs(UTGData.Instance().MyselfGuild.Members) do
            table.insert(tableTemp,v)
          end
          table.sort(tableTemp, 
           function(a,b) 
                if(a.Status==1 or a.Status==2 or a.Status==3)then return true end
                if(b.Status==1 or b.Status==2 or b.Status==3)then return false end
                return UTGData.Instance():GetLeftTime(a.LastSignOutTime) > UTGData.Instance():GetLeftTime(b.LastSignOutTime)
              end
             )

          self:InitializeMyselfGuildMembers(tableTemp)
        end

      end ,self
      )
  ----------------------------------战队日志-----------------------------------
  
   local listener = NTGEventTriggerProxy.Get(self.II2_ButtonGuildLog.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()  

        self.II2_Pop_GuildLog.gameObject:SetActive(true)
        self:GuildLogListRequest()  

      end ,self
      )
  ----------------------------------战队日志-----------------------------------
  
    local listener = NTGEventTriggerProxy.Get(self.II2_ButtonAddMember.gameObject)   --确认按钮事件
          listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
              function ()


                        local sizeNext = UTGData.Instance().GuildMemberLimitsData[tostring(self.MemberLimit)].NextSize
                        
                        if(sizeNext==-1)then
                          GameManager.CreatePanel("SelfHideNotice")
                          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经达到成员上限，不能再提升了")  
                          return
                        end

                        local voucherPrice = UTGData.Instance().GuildMemberLimitsData[tostring(sizeNext)].VoucherPrice  
                        
                             
                        --弹窗
                        self.DelegateTip_Title.text="提示"   
                        self.DelegateTip_PromptContent.text="确定花费" .. voucherPrice ..  "点券，将战队人数上限扩充至" .. sizeNext .. "人？"
                        local listener = NTGEventTriggerProxy.Get(self.DelegateTip_ButtonEnter.gameObject)  --确认按钮事件
                        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                            function () 

                              ---------------------------------------------------------
                              if(UTGData.Instance().PlayerData.Voucher<voucherPrice)then
                                self.DelegateTip.gameObject:SetActive(false)

                                local dialogSelf = GameManager.CreateDialog("NeedConfirmNotice")
                                local dialog =   dialogSelf:GetComponent("NTGLuaScript").self
                                dialog:InitNoticeForNeedConfirmNotice("提示", "点券不足", false, "",2,false)
                                dialog:TwoButtonEvent("取消",dialog.DestroySelf, dialog,
                                                        "购买点券",
                                                      function () 
                                                      --self:JoinPreparingGuildRequest(v.Id) 
                                                      --self:DoGoToStorePanel(6)
                                                      GameManager.CreatePanel("SelfHideNotice")
                                                      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("快速获得点券功能正在制作中")  

                                                      dialog:DestroySelf()
                                                      end
                                                      , self
                                                      )
                                dialog:SetTextToCenter()
                                --弹窗
                                --[[
                                self.DelegateTip_Title.text="提示"   
                                self.DelegateTip_PromptContent.text="点券不足，是否购买点券？"
                                local listener = NTGEventTriggerProxy.Get(self.DelegateTip_ButtonEnter.gameObject)  --确认按钮事件
                                listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                                    function () 
                                      --self:JoinPreparingGuildRequest(v.Id) 
                                      --self:DoGoToStorePanel(6)
                                      
                                      GameManager.CreatePanel("SelfHideNotice")
                                      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("快速获得点券功能正在制作中")  

                                      self.DelegateTip.gameObject:SetActive(false)
                                    end ,self
                                    )
                                self.DelegateTip.gameObject:SetActive(true)
                                --]]
                                return
                              end
                              ---------------------------------------------------------
                              self:AddGuildMemberSizeRequest()
                              self.DelegateTip.gameObject:SetActive(false)
                            end ,self
                            )
                        self.DelegateTip.gameObject:SetActive(true)

                        

              end ,self
              )  



  -----------------------------------------------------------------------------  
  --打开战队管理面板
    local listener = NTGEventTriggerProxy.Get(self.II2_ButtonManage.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
    
        self.II2_Pop_GuildConfig.gameObject:SetActive(true)
        
      end ,self
      )  
  --修改战队图标
  
    local listener = NTGEventTriggerProxy.Get(self.II2_Pop_GuildConfig_GuildIconButton.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
        --先清空子物体
       
        while(self.I3_Content.childCount>0) do
          UIPool.Instance:Return(self.I3_Content:GetChild(0).gameObject)
        end
        --在弹出的窗口中生成图标列表的并赋值   
        self:Instantiate(UTGData.Instance().GuildIconsDataArray,"I3_GuildIcon",self.I3_Content,self,self.Assignment_GuildIconII,false) 
        self.I3_Pop.gameObject:SetActive(true)
      end ,self
      )

    
    --入队审批
    local listener = NTGEventTriggerProxy.Get(self.II2_Pop_GuildConfig_ToggleTrue.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
        self.selectedIsNeedAllow=true
      end ,self
      )
    local listener = NTGEventTriggerProxy.Get(self.II2_Pop_GuildConfig_ToggleFalse.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
        self.selectedIsNeedAllow=false
      end ,self
      )


    
    --入队等级
    local listener = NTGEventTriggerProxy.Get(self.II2_Pop_GuildConfig_LevelLimitA.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()

        self.selectedLevelLimit = self.selectedLevelLimit + 1;
        self.II2_Pop_GuildConfig_LevelLimit.text=self.selectedLevelLimit
        if(self.selectedLevelLimit>=30)then
          self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").color=Color.gray;
          self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").raycastTarget=false;
        else
          self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").color=Color.white;
          self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").raycastTarget=true;
        end
        if(self.selectedLevelLimit<=self.UnlockLevel)then  --7
          self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").color=Color.gray;
          self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").raycastTarget=false;
        else
          self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").color=Color.white;
          self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").raycastTarget=true;
        end
        
      end ,self
      )
    local listener = NTGEventTriggerProxy.Get(self.II2_Pop_GuildConfig_LevelLimitD.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()

        self.selectedLevelLimit = self.selectedLevelLimit - 1;
        self.II2_Pop_GuildConfig_LevelLimit.text=self.selectedLevelLimit
        if(self.selectedLevelLimit>=30)then
          self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").color=Color.gray;
          self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").raycastTarget=false;
        else
          self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").color=Color.white;
          self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").raycastTarget=true;
        end
        if(self.selectedLevelLimit<=self.UnlockLevel)then  --7
          self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").color=Color.gray;
          self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").raycastTarget=false;
        else
          self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").color=Color.white;
          self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").raycastTarget=true;
        end

      end ,self
      )
    
    --入队段位
    local listener = NTGEventTriggerProxy.Get(self.II2_Pop_GuildConfig_GradeLimitA.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
         

        if(self.selectedGradeLimit==-1)then 
          self.selectedGradeLimit=18000001
        
          self.II2_Pop_GuildConfig_GradeLimit.text=UTGData.Instance().GradesData[tostring(self.selectedGradeLimit)].Title
        else 
          self.selectedGradeLimit = self.selectedGradeLimit + 1;
         
          self.II2_Pop_GuildConfig_GradeLimit.text=UTGData.Instance().GradesData[tostring(self.selectedGradeLimit)].Title
          
        end
        
        if(self.selectedGradeLimit>=18000017)then
          self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").color=Color.gray;
          self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").raycastTarget=false;
        else
          self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").color=Color.white;
          self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").raycastTarget=true;
        end
        if(self.selectedGradeLimit<18000001)then
          self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").color=Color.gray;
          self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").raycastTarget=false;
        else
          self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").color=Color.white;
          self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").raycastTarget=true;
        end

      end ,self
      )
    local listener = NTGEventTriggerProxy.Get(self.II2_Pop_GuildConfig_GradeLimitD.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
         
        if(self.selectedGradeLimit==18000001)then
          self.selectedGradeLimit=-1
          self.II2_Pop_GuildConfig_GradeLimit.text="无段位限制"
        else
          self.selectedGradeLimit = self.selectedGradeLimit - 1;
          self.II2_Pop_GuildConfig_GradeLimit.text=UTGData.Instance().GradesData[tostring(self.selectedGradeLimit)].Title
        end

        if(self.selectedGradeLimit>=18000017)then
          self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").color=Color.gray;
          self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").raycastTarget=false;
        else
          self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").color=Color.white;
          self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").raycastTarget=true;
        end
        if(self.selectedGradeLimit<18000001)then
          self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").color=Color.gray;
          self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").raycastTarget=false;
        else
          self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").color=Color.white;
          self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").raycastTarget=true;
        end

      end ,self
      )
    --确定修改战队管理信息
    local listener = NTGEventTriggerProxy.Get(self.II2_Pop_GuildConfig_ButtonConfirm.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
      function ()
        if(self.canGuildConfig==true)then
          self.canGuildConfig=false
          self:ChangeGuildConfigRequest(self.selectedGuildIconId,self.selectedIsNeedAllow,self.selectedLevelLimit,self.selectedGradeLimit)  
        end
      end ,self
      )
    --战队改名
    local listener = NTGEventTriggerProxy.Get(self.II2_Pop_GuildConfig_GuildNameButton.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( 
                function ()
                   GameManager.CreatePanel("ChangeGuildName")
                   --PlayerDataAPI.Instance:InitNoticeForSelfHideNotice("发送好友请求成功")
                   --self.this.transform:FindChild("PopChangeName").gameObject:SetActive(true);
                end,self
                )
    
  ----------------------------------------------------------------------------------------------------------------III1--本周排名
    local listener = NTGEventTriggerProxy.Get(self.IIIB1.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( 
                function ()
                   self:OnButtonClick_III1()
                end,self
                )
  ----------------------------------------------------------------------------------------------------------------III2--上周排名
    local listener = NTGEventTriggerProxy.Get(self.IIIB2.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( 
                function ()
                   self:OnButtonClick_III2()
                end,self
                )
  ----------------------------------------------------------------------------------------------------------------III3--赛季排名
    local listener = NTGEventTriggerProxy.Get(self.IIIB3.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( 
                function ()
                   self:OnButtonClick_III3()
                end,self
                )
    local listener = NTGEventTriggerProxy.Get(self.III3_BI.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( 
                function ()
                 
                   self:OnButtonClick_III3I()
                end,self
                )
    local listener = NTGEventTriggerProxy.Get(self.III3_BII.gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( 
                function ()
                   self:OnButtonClick_III3II()
                end,self
                )
  ------------------------------------------------------------------------------------------------------------------------------
end
------------------------------根据table元素数量，逐帧实例化的Prefab，设置父物体，并填充数据--------------------------------
function GuildAPI:Instantiate(mTable,prefabName,parent,obj,func,single)
  
  

	local instantiateCo= coroutine.start( self.InstantiateCoro,self, mTable,prefabName,parent,obj,func,single)
  return instantiateCo
  --table.insert(self.tableInstantiateCoros,instantiateCo)

  --self:InstantiateCoro(mTable,prefab,parent,obj,func,single)
  
end
function GuildAPI:InstantiateCoro(mTable,prefabName,parent,obj,func,single)
    local amount=0
    for k,v in pairs(mTable) do 
      amount=amount+1
    end
    if(single==false)then 
        local indexOfSort=0
		  for k,v in pairs(mTable) do   
          indexOfSort=indexOfSort+1
        if(UIPool==nil)then return end
		    local go=UIPool.Instance:Get(prefabName)
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
        if(indexOfSort%10==0)then
	        coroutine.step();
        end

        if(indexOfSort==amount)then 
          self.IsSorting=false
          self.SortColliderShield:SetActive(false)
         end
	    end
    else  --一条结果的结构处理
      if(UIPool==nil)then return end
      local go=UIPool.Instance:Get(prefabName)
	    go.transform:SetParent(parent);
	    go.transform.localScale = Vector3.one; 
	    go.transform.localPosition = Vector3.zero;
	    go.gameObject:SetActive(true);
	    --return go;

    local k=1
		func(obj,go,k,mTable);
    end
    
end
-----------------------------------------------赋值回调--
function GuildAPI:Assignment_GuildIcon(go,key,guildIcon)  --赋值战队图标

    go.transform:FindChild("Icon"):GetComponent("Image").sprite=UITools.GetSprite("guildicon", guildIcon.Icon); 

    UITools.GetLuaScript(go,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,
    	function ()   
      	  self.selectedGuildIconId=guildIcon.Id
      	  self.I3_Icon.sprite=UITools.GetSprite("guildicon", guildIcon.Icon);  
      	  self.I3_Pop.gameObject:SetActive(false) 
        end
        ) 

end  
function GuildAPI:Assignment_GuildIconII(go,key,guildIcon)  --赋值战队图标II

    go.transform:FindChild("Icon"):GetComponent("Image").sprite=UITools.GetSprite("guildicon", guildIcon.Icon); 

    UITools.GetLuaScript(go,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,
      function ()   
          self.selectedGuildIconId=guildIcon.Id
          self.II2_Pop_GuildConfig_GuildIcon.sprite=UITools.GetSprite("guildicon", guildIcon.Icon);  
          self.I3_Pop.gameObject:SetActive(false) 
        end
        ) 

end  
function GuildAPI:Assignment_GuildList(go,key,v)  --赋值战队列表 --guildInfo
        
    go.transform:FindChild("Icon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
    go.transform:FindChild("GuildName"):GetComponent("Text").text=v.Name 
    go.transform:FindChild("CaptainName"):GetComponent("Text").text=v.Leader.Name              
    go.transform:FindChild("Vitality"):GetComponent("Text").text=v.SeasonActivePoint
    go.transform:FindChild("Amount"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit

    local limitGrade;
    if(v.LimitGrade==-1)then
      limitGrade="无段位限制"
    else
      limitGrade=UTGData.Instance().GradesData[tostring(v.LimitGrade)].Title
    end

    local limitIsCheck;   
    if(v.LimitIsCheck==true)then  --限制
      limitIsCheck="需要审核"
    else
      limitIsCheck="不需审核"
    end
    go.transform:FindChild("Limit"):GetComponent("Text").text=v.LimitLevel .. "级," .. limitGrade .. "\n" .. limitIsCheck
    
    for k1,v1 in pairs(UTGData.Instance().ApplyingGuilds) do  --已申请
      if(v.Id==v1)then    
        go.transform:FindChild("HadApplied").gameObject:SetActive(true);
        break    
      end     
    end

    go.name = v.Id  --以便于 后添加 已申请标签

    UITools.GetLuaScript(go,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,
    	function ()   
       
      	  self.I1_SelectedIcon:GetComponent("Image").sprite = UITools.GetSprite("roleicon",v.Leader.Avatar)
    		  self.I1_SelectedFrame:GetComponent("Image").sprite = UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.Leader.AvatarFrameId)].Icon);
    		  self.I1_SelectedCaptainName:GetComponent("Text").text = v.Leader.Name  
    		  self.I1_SelectedManifesto:GetComponent("Text").text = v.Declaration      
        
    		  self.I1_SelectedGrade:GetComponent("Text").text = UTGData.Instance().GuildLevelsData[tostring(v.Level)].Name
    		  self.I1_SelectedGradeIcon:GetComponent("Image").sprite = UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon);
    		                                                    
                                                            

          --Debugger.LogError(v.MailInfo);                   local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(3)].MailInfo  
          --self.I1_SelectedBonus:GetComponent("Text").text =UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards
          --奖励加成
          self.I1_SelectedBonus:GetComponent("Text").text=UTGData.Instance().GuildMemberLimitsData[tostring(v.MemberLimit)].CoinAdditionalRate .. "%"
    		  local listener = NTGEventTriggerProxy.Get(self.I1_SelectedButton.gameObject)  
    		  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
    		      function ()
    		        self:ApplyGuildRequest(v.Id)   --申请加入战队
    		      end ,self
    		      )
            end
        ) 

    --如果是第一次获取，需要初始第一个为选中状态，右侧显示相应的选中信息
    if(self.guildListBeginIndex==0 and key==1)then 
        go:GetComponent("UnityEngine.UI.Toggle").isOn=true  --设置高亮
        UITools.GetLuaScript(go,"Logic.UICommon.UIClick"):ExecuteClickDelegate()
        self.I1_R:SetActive(true)
        --在赋值完右侧之后跳转进来
        --self:ShowPanel("I","I1");  ----------------------------------------------------------------------------------------------->>
    end

end
function GuildAPI:Assignment_PreparingGuildList(go,key,v) --赋值筹备列表 


	  go.transform:FindChild("Icon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
    go.transform:FindChild("GuildName"):GetComponent("Text").text=v.Name  
    go.transform:FindChild("CaptainName"):GetComponent("Text").text=v.Leader.Name            
    go.transform:FindChild("Amount"):GetComponent("Text").text=v.MemberAmount .. "/" .. "5"   
    UITools.GetLuaScript(go,"Logic.UICommon.UICountDown"):StartCountDown(v.EndTime)     

    UITools.GetLuaScript(go,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,
    	function () 
    	  self.I2_SelectedIcon:GetComponent("Image").sprite= UITools.GetSprite("roleicon",v.Leader.Avatar)
		    self.I2_SelectedFrame:GetComponent("Image").sprite=UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.Leader.AvatarFrameId)].Icon);
		    self.I2_SelectedCaptainName:GetComponent("Text").text=v.Leader.Name  
		    self.I2_SelectedManifesto:GetComponent("Text").text=v.Declaration    
		    self.I2_SelectedButton=self.I2:FindChild("Guild/R/Button"); 

        local listener = NTGEventTriggerProxy.Get(self.I2_SelectedButton.gameObject)  --确认按钮事件
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
            function ()
                      --弹窗
                      self.DelegateTip_Title.text="提示"   
                      self.DelegateTip_PromptContent.text="响应后，该战队筹备期内不可加入其他战队。\n是否确定响应？"
                      local listener = NTGEventTriggerProxy.Get(self.DelegateTip_ButtonEnter.gameObject)  --确认按钮事件
                      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                          function () 
                            self:JoinPreparingGuildRequest(v.Id) 
                            self.DelegateTip.gameObject:SetActive(false)
                          end ,self
                          )
                      self.DelegateTip.gameObject:SetActive(true)
            end ,self
            )
      end
      )   

    --如果是第一次获取，需要初始第一个为选中状态，右侧显示相应的选中信息
    if(self.preparingGuildListBeginIndex==0 and key==1)then 
        go:GetComponent("UnityEngine.UI.Toggle").isOn=true  --设置高亮
        UITools.GetLuaScript(go,"Logic.UICommon.UIClick"):ExecuteClickDelegate()
        --右侧赋值完毕，跳转进入
        --self:ShowPanel("I","I2G"); ------------------------------------------------------------------------------------------->>
    end

end
function GuildAPI:Assignment_PreparingGuildMembers(go,key,v) --赋值成员列表  --data.PreparingGuild.PreparingGuildInfo  --data.PreparingGuild.Members 
  
  if(v.Id==self.LeaderId)then
    GameObject.Destroy(go.gameObject)
    return
  end
	go.transform:FindChild("Icon"):GetComponent("Image").sprite=UITools.GetSprite( "roleicon" , v.Avatar)
  go.transform:FindChild("Frame"):GetComponent("Image").sprite=UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.AvatarFrameId)].Icon)
  go.transform:FindChild("VIP"):GetComponent("Image").sprite=UITools.GetSprite( "vipicon" ,"v" .. v.Vip)
  go.transform:FindChild("Name"):GetComponent("Text").text=v.Name                       
  go.transform:FindChild("Level"):GetComponent("Text").text=v.Level
 
end
----------------------------------------
function GuildAPI:DoGoToPlayerDataPanel(v)
  -- body
  if(self.isLoading~=true)then
    self.isLoading=true
    coroutine.start(self.GoToPlayerDataPanel, self,v)
  end
end

function GuildAPI:GoToPlayerDataPanel(v)
  -- body
  local trans = GameManager.CreatePanelAsync("PlayerData")
  while trans.Done == false do
    coroutine.step()
  end
  self.isLoading=false
  if PlayerDataAPI ~= nil and PlayerDataAPI.Instance ~= nil then
          
          PlayerDataAPI.Instance:Init(v.PlayerId)
          
          
          --查看是否已经在好友列表中
          local isInFriendList=false
          for k1,v1 in pairs(UTGData.Instance().FriendList) do
            if(v1.PlayerId==v.PlayerId)then
              isInFriendList=true
              break
            end
          end
          --如果不是自己 且 不在好友列表中
          if(v.PlayerId~=UTGData.Instance().PlayerData.Id and isInFriendList==false)then  --添加好友
            
            PlayerDataAPI.Instance:ShowButton("ButtonAddFriend",
              function ()

                self.InputFieldValidation:GetComponent("UnityEngine.UI.InputField").text=self.ValidationInformations[math.random(1,3)]
                self.PopValidation:SetActive(true);
                self.AddPlayerId=v.PlayerId  

              end
            ,self)  --打开对应按钮，并注册事件
          end
          
          if(self.canFlagLeaderDemise==true and v.PositionLevel~=1)then  --队长让位
            
            PlayerDataAPI.Instance:ShowButton("ButtonLeaderDemise",
              function ()

                      --弹窗
                      self.DelegateTip_Title.text="提示"    
                      self.DelegateTip_PromptContent.text="确定将<color=#FDA400FF>队长职位</color>转让给<color=#2CA7EFFF>" .. v.Name .. "</color>吗？\n(传位后你将与他调换职位)"
                      local listener = NTGEventTriggerProxy.Get(self.DelegateTip_ButtonEnter.gameObject)  --确认按钮事件
                      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                          function () 
                            self:GuildLeaderDemiseRequest(v.Id) 
                            Object.Destroy(PlayerDataAPI.Instance.this.gameObject)
                            self.DelegateTip.gameObject:SetActive(false)
                          end ,self
                          )
                      self.DelegateTip.gameObject:SetActive(true)

              end
            ,self)  --打开对应按钮，并注册事件
          end

          if(self.canFlagAppointViceLeader==true and v.PositionLevel==3)then  --任命副队长
            
            PlayerDataAPI.Instance:ShowButton("ButtonAppointViceLeader",
              function ()

                      --弹窗
                      self.DelegateTip_Title.text="提示"   
                      self.DelegateTip_PromptContent.text="确定将<color=#2CA7EFFF>" .. v.Name .. "</color>任命为副队长吗？"
                      local listener = NTGEventTriggerProxy.Get(self.DelegateTip_ButtonEnter.gameObject)  --确认按钮事件
                      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                          function () 
                            self:GuildAppointViceLeader(v.Id) 
                            Object.Destroy(PlayerDataAPI.Instance.this.gameObject)
                            self.DelegateTip.gameObject:SetActive(false)
                          end ,self
                          )
                      self.DelegateTip.gameObject:SetActive(true)
                
              end
              ,self)  

          end

          if(self.canFlagAppointCommander==true)then  --任命指挥官
            --PlayerDataAPI.Instance:ShowButton("ButtonAppointCommander",self.,self) 
          end

          if(self.canFlagKickNormalMember==true and v.PositionLevel==3)then  --开除普通队员
            PlayerDataAPI.Instance:ShowButton("ButtonKickMember",function ()
              --弹窗
                      self.DelegateTip_Title.text="提示"   
                      self.DelegateTip_PromptContent.text="若开除" .. v.Name .. "，该成员今日贡献的战队活跃点将从战队总活跃点中扣除。确定将其开除吗？"
                      local listener = NTGEventTriggerProxy.Get(self.DelegateTip_ButtonEnter.gameObject)  --确认按钮事件
                      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                          function () 
                            self:GuildFireMemberRequest(v.Id) 
                            Object.Destroy(PlayerDataAPI.Instance.this.gameObject)
                            self.DelegateTip.gameObject:SetActive(false)
                          end ,self
                          )
                      self.DelegateTip.gameObject:SetActive(true)
              
            end,self)    
          end

          if(self.canFlagKickViceLeader==true and v.PositionLevel==2)then  --开除副队长
            PlayerDataAPI.Instance:ShowButton("ButtonKickMember",function ()
              --弹窗
                      self.DelegateTip_Title.text="提示"   
                      self.DelegateTip_PromptContent.text="若开除<color=#2CA7EFFF>" .. v.Name .. "</color>，该成员今日贡献的战队活跃点将从战队总活跃点中扣除。确定将其开除吗？"
                      local listener = NTGEventTriggerProxy.Get(self.DelegateTip_ButtonEnter.gameObject)  --确认按钮事件
                      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                          function () 
                            self:GuildFireMemberRequest(v.Id) 
                            Object.Destroy(PlayerDataAPI.Instance.this.gameObject)
                            self.DelegateTip.gameObject:SetActive(false)
                          end ,self
                          )
                      self.DelegateTip.gameObject:SetActive(true)
              
            end,self) 
          end

  end
end
----------------------------------------
function GuildAPI:DoGoToGuildListPanel()
  -- body
  coroutine.start(self.GoToGuildListPanel, self,v)
end

function GuildAPI:GoToGuildListPanel()
  -- body
  local trans = GameManager.CreatePanelAsync("GuildList")
  while trans.Done == false do
    coroutine.step()
  end
  coroutine.step()
  if GuildListAPI ~= nil and GuildListAPI.Instance ~= nil then
    GuildListAPI.Instance:OnButtonClick_I1()
  end
end
-------------------------------------------------------------------------------------------------------------加入战队后--
function GuildAPI:Assignment_GuildMembers(go,key,v,index,isEnd) --战队信息 
    
    go.transform:FindChild("Icon"):GetComponent("Image").sprite=UITools.GetSprite( "roleicon" , v.Avatar )
    go.transform:FindChild("Frame"):GetComponent("Image").sprite=UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.AvatarFrameId)].Icon)
    go.transform:FindChild("Name"):GetComponent("Text").text=v.Name  
    go.transform:FindChild("Vitality"):GetComponent("Text").text=v.SeasonActivePoint 
    go.transform:FindChild("Vitality2"):GetComponent("Text").text=v.WeeklyActivePoint
     
    self:ShowNum( index , go.transform:FindChild("Num") )

    UITools.GetLuaScript(go,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,
      function () 

        self:DoGoToPlayerDataPanel(v)

      end
      )   

    
    
    --------------------------如果是自己的Id，就额外将信息填充到界面底部-----------------------
    if(v.PlayerId==UTGData.Instance().PlayerData.Id)then

      self.II1_DailyActivePoint.text = v.DailyActivePoint   --这个竟然在右侧，奇葩的界面

      self.II1_SelfInfo:FindChild("Icon"):GetComponent("Image").sprite=UITools.GetSprite( "roleicon" , v.Avatar )
      self.II1_SelfInfo:FindChild("Frame"):GetComponent("Image").sprite=UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.AvatarFrameId)].Icon)
      self.II1_SelfInfo:FindChild("Name"):GetComponent("Text").text=v.Name  
      self.II1_SelfInfo:FindChild("Vitality"):GetComponent("Text").text=v.SeasonActivePoint 
      self.II1_SelfInfo:FindChild("Vitality2"):GetComponent("Text").text=v.WeeklyActivePoint
      self:ShowNum( index , self.II1_SelfInfo:FindChild("Num") )
      --判断是否已签到
      if(v.FlagSignIn==true)then 
        --self.HaveSignIn=true
        self.II1_SignIn.gameObject:SetActive(false)
        self.II1_SignInBlack.gameObject:SetActive(true)
      else  
        --self.HaveSignIn=false
        self.II1_SignIn.gameObject:SetActive(true)
        self.II1_SignInBlack.gameObject:SetActive(false)
      end
      --是否提示新的申请
      self.ButtonToggle:GetComponent("UnityEngine.UI.Toggle").isOn=not v.FlagShowNewApplication 
      --将权限等级赋值给全局变量
      self.PositionLevel=v.PositionLevel;

      

      --[[
        /*战队职务权限*/
        type TemplateGuildPermission struct {
          Level                      int    //职位等级
          Name                       string //职位名称
          FlagLeaderDemise           bool   //队长让位      >>>
          FlagAppointViceLeader      bool   //任命副队长
          FlagAppointCommander       bool   //任命指挥官
          FlagKickNormalMember       bool   //开除普通队员
          FlagKickViceLeader         bool   //开除副队长
          FlagSendGuildMail          bool   //发送战队邮件  >>>
          FlagChangeGuildConfig      bool   //修改战队设置  >>>
          FlagRecruitMember          bool   //招募队员      >>>
          FlagChangeGuildDeclaration bool   //修改战队宣言  >>>
          FlagCheckApplication       bool   //审核申请      >>>
          FlagAddMemberSize          bool   //增加成员上限  ---
          FlagDisbandGuild           bool   //解散战队      >>>
          FlagLeaveGuild             bool   //退出战队      >>>
        }
      --]]
      --人员调度权限
      --自己是队长，界面显示按钮  。显示在除自己之外的队员上
      if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagLeaderDemise==true)then  --队长让位
        self.canFlagLeaderDemise=true 
      else
        self.canFlagLeaderDemise=false
      end
      if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagAppointViceLeader==true)then  --任命副队长
        self.canFlagAppointViceLeader=true 
      else
        self.canFlagAppointViceLeader=false
      end
      if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagAppointCommander==true)then  --任命指挥官
        self.canFlagAppointCommander=true 
      else
        self.canFlagAppointCommander=false
      end
      if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagKickNormalMember==true)then  --开除普通队员
        self.canFlagKickNormalMember=true 
      else
        self.canFlagKickNormalMember=false
      end
      if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagKickViceLeader==true)then  --开除副队长
        self.canFlagKickViceLeader=true 
      else
        self.canFlagKickViceLeader=false
      end

      --权限
      if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagChangeGuildConfig==true)then  --战队管理
        self.II2_ButtonManage.gameObject:SetActive(true)
      else
        self.II2_ButtonManage.gameObject:SetActive(false)
      end 
      if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagRecruitMember==true)then  --招募队员
        self.II2_ButtonRecruit.gameObject:SetActive(true)
      else
        self.II2_ButtonRecruit.gameObject:SetActive(false)
      end
      if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagLeaveGuild==true)then  --退出战队
        self.canFlagLeaveGuild=true 
      else
        self.canFlagLeaveGuild=false
      end
      if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagDisbandGuild==true)then  --解散战队
        self.canFlagDisbandGuild=true
      else
        self.canFlagDisbandGuild=false
      end
      if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagChangeGuildDeclaration==true)then  --修改战队宣言
        self.II2_ButtonChange.gameObject:SetActive(true)
      else
        self.II2_ButtonChange.gameObject:SetActive(false)
      end
      if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagSendGuildMail==true)then  --发送战队邮件
        self.II2_ButtonGuildEmail.gameObject:SetActive(true)
      else
        self.II2_ButtonGuildEmail.gameObject:SetActive(false)
      end

      --self.II2_ButtonQuit =self.II2:FindChild("L/Search/Button1")
     
    end

    --self:ShowPanel("II","II1"); 
    if(self.needShow_MyselfGuildDetail==true)then
      self:DoInNextFrame(self.ShowPanel,self,"II","II1") 
      self.needShow_MyselfGuildDetail=false
    end

end
--下一帧执行某方法--

function GuildAPI:DoInNextFrame(func,obj,param1,param2) 
  coroutine.start(self.DoInNextFrame_Co,self,func,obj,param1,param2)
end
function GuildAPI:DoInNextFrame_Co(func,obj,param1,param2) 
  --coroutine.step()
  while(true)do
    coroutine.step()
    if( (self.II1_SignIn.gameObject.activeSelf==false and self.II1_SignInBlack.gameObject.activeSelf ==false) ==false )then
      func(obj,param1,param2)
      break
    end
  
  end

end
function GuildAPI:Assignment_GuildLogList(go,key,v,index)  

  local pattern_go = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"--"2016-04-27T20:32:22+08:00",
  local year_go, month_go, day_go, hour_go, minute_go, seconds_go = tostring(v.Time):match(pattern_go)
  local stringTime="<color=#707A92FF>[" .. year_go .. "." .. month_go .. "." .. day_go .. "]</color>"
  go.transform:GetComponent("Text").text=stringTime .. v.Content
 
end
-------------------------------------------------------------------------------------------------------------加入战队后--
function GuildAPI:ShowNumII(num,tempo) --排行数字 

    local n_Loser=tempo:FindChild("Loser").gameObject
    local n_1=tempo:FindChild("1").gameObject
    local n_2=tempo:FindChild("2").gameObject
    local n_3=tempo:FindChild("3").gameObject
    local n_Ge=tempo:FindChild("Grid/Ge").gameObject 
    local n_Shi=tempo:FindChild("Grid/Shi").gameObject 
    local n_Bai=tempo:FindChild("Grid/Bai").gameObject 
    
    n_Loser:SetActive(false)
    n_1:SetActive(false)
    n_2:SetActive(false)
    n_3:SetActive(false)
    n_Ge:SetActive(false)
    n_Shi:SetActive(false) 
    n_Bai:SetActive(false) 

    num=tonumber(num)
    if(num==-1)then  
      n_Loser:SetActive(true)
    end
    if num<10 then
      n_Ge:SetActive(true)
      n_Ge:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..num,"UnityEngine.Sprite")
    elseif num<100 then 
      n_Ge:SetActive(true)
      n_Ge:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..num%10,"UnityEngine.Sprite")
      n_Shi:SetActive(true)
      n_Shi:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..math.floor(num/10),"UnityEngine.Sprite")
    elseif num<1000 then 
      n_Ge:SetActive(true)
      n_Ge:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..(num%10),"UnityEngine.Sprite")
      n_Shi:SetActive(true)
      n_Shi:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..(math.floor(num/10)%10),"UnityEngine.Sprite")
      n_Bai.gameObject:SetActive(true)
      n_Bai.gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..(math.floor(num/100)),"UnityEngine.Sprite")
    end 

end
function GuildAPI:ShowNum(num,tempo) --排行数字 

    local n_Loser=tempo:FindChild("Loser").gameObject
    local n_1=tempo:FindChild("1").gameObject
    local n_2=tempo:FindChild("2").gameObject
    local n_3=tempo:FindChild("3").gameObject
    local n_Ge=tempo:FindChild("Grid/Ge").gameObject 
    local n_Shi=tempo:FindChild("Grid/Shi").gameObject 
    local n_Bai=tempo:FindChild("Grid/Bai").gameObject 
    
    n_Loser:SetActive(false)
    n_1:SetActive(false)
    n_2:SetActive(false)
    n_3:SetActive(false)
    n_Ge:SetActive(false)
    n_Shi:SetActive(false) 
    n_Bai:SetActive(false) 

    num=tonumber(num)
    if(num==-1)then
      n_Loser:SetActive(true)
    end
    if num ==1 then 
      --tempo:FindChild("Bg").gameObject:SetActive(false)
      --tempo:FindChild("Liang").gameObject:SetActive(true)
      n_1:SetActive(true)
    elseif num ==2 then 
      n_2:SetActive(true)
    elseif num ==3 then 
      n_3:SetActive(true)
    elseif num<10 then
      n_Ge:SetActive(true)
      n_Ge:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..num,"UnityEngine.Sprite")
    elseif num<100 then 
      n_Ge:SetActive(true)
      n_Ge:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..num%10,"UnityEngine.Sprite")
      n_Shi:SetActive(true)
      n_Shi:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..math.floor(num/10),"UnityEngine.Sprite")
    elseif num<1000 then 
      n_Ge:SetActive(true)
      n_Ge:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..(num%10),"UnityEngine.Sprite")
      n_Shi:SetActive(true)
      n_Shi:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..(math.floor(num/10)%10),"UnityEngine.Sprite")
      n_Bai.gameObject:SetActive(true)
      n_Bai.gameObject:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("ranknum",""..(math.floor(num/100)),"UnityEngine.Sprite")
    end 

end
-------------------------------------------------------------------------------------------------------------加入战队后--
function GuildAPI:Assignment_GuildMembersII(go,key,v,index) --战队成员 

    go.transform:FindChild("Icon"):GetComponent("Image").sprite=UITools.GetSprite( "roleicon" , v.Avatar )
    go.transform:FindChild("Frame"):GetComponent("Image").sprite=UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.AvatarFrameId)].Icon)
    go.transform:FindChild("Name"):GetComponent("Text").text=v.Name  
    go.transform:FindChild("Vitality"):GetComponent("Text").text=v.SeasonActivePoint 
    go.transform:FindChild("Vitality2"):GetComponent("Text").text=v.WeeklyActivePoint
    if(v.Status~=0)then 
      go.transform:FindChild("State"):GetComponent("Text").text= "在线"
    else
      go.transform:FindChild("State"):GetComponent("Text").text=self:GetStringTime(v.LastSignOutTime)        
    end
                   
    if(UTGData.Instance().GuildPermissionsData[tostring(v.PositionLevel)].Name=="队长")then              
      go.transform:FindChild("Tags"):FindChild("Tag1").gameObject:SetActive(true);
      go.transform:FindChild("Tags"):FindChild("Tag2").gameObject:SetActive(false);
      go.transform:FindChild("Tags"):FindChild("Tag3").gameObject:SetActive(false);
    elseif(UTGData.Instance().GuildPermissionsData[tostring(v.PositionLevel)].Name=="副队长")then          
      go.transform:FindChild("Tags"):FindChild("Tag1").gameObject:SetActive(false);
      go.transform:FindChild("Tags"):FindChild("Tag2").gameObject:SetActive(true);
      go.transform:FindChild("Tags"):FindChild("Tag3").gameObject:SetActive(false);
    elseif(UTGData.Instance().GuildPermissionsData[tostring(v.PositionLevel)].Name=="普通成员")then          
      go.transform:FindChild("Tags"):FindChild("Tag1").gameObject:SetActive(false);
      go.transform:FindChild("Tags"):FindChild("Tag2").gameObject:SetActive(false);
      go.transform:FindChild("Tags"):FindChild("Tag3").gameObject:SetActive(true);
    end
    
    UITools.GetLuaScript(go,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,
      function () 

           self:DoGoToPlayerDataPanel(v)

      end
      )   
         
 
end
function GuildAPI:GetStringTime(t)

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
--------------------------------------------------------------------------------获取战队申请列表--
function GuildAPI:Assignment_ApplicationList(go,key,v,index) --战队成员

    go.transform:FindChild("Icon"):GetComponent("Image").sprite=UITools.GetSprite( "roleicon" , v.Avatar )
    go.transform:FindChild("Frame"):GetComponent("Image").sprite=UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.AvatarFrameId)].Icon)
    go.transform:FindChild("Name"):GetComponent("Text").text=v.Name  
    go.transform:FindChild("Level"):GetComponent("Text").text=v.Level 
    if(v.Vip>=1)then
      go.transform:FindChild("VIP").gameObject:SetActive(true)
      go.transform:FindChild("VIP"):GetComponent("Image").sprite=UITools.GetSprite( "vipicon" , "v" .. v.Vip)
    end
    if(v.Grade==0)then
      go.transform:FindChild("Grade"):GetComponent("Text").text="尚未参加排位赛"
    else
      go.transform:FindChild("Grade"):GetComponent("Text").text=UTGData.Instance().GradesData[tostring(v.Grade)].Title
    end
    
    go.transform:FindChild("Recommender"):GetComponent("Text").text=v.RecommendPlayerName
    
    --回来找我
    if(UTGData.Instance().GuildPermissionsData[tostring(self.PositionLevel)].FlagCheckApplication==true)then
      go.transform:FindChild("ButtonAgree").gameObject:SetActive(true)
      local listener = NTGEventTriggerProxy.Get(go.transform:FindChild("ButtonAgree").gameObject)  --确认按钮事件
      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
            function ()
                      self.WannaDestory=go;
                      self:AgreeGuildApplicationRequest( v.Id  )
            end ,self
            )
      go.transform:FindChild("ButtonRefuse").gameObject:SetActive(true)
      local listener = NTGEventTriggerProxy.Get(go.transform:FindChild("ButtonRefuse").gameObject)  --确认按钮事件
      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
            function ()
                      self.WannaDestory=go;
                      self:RefuseGuildApplicationRequest( v.Id  )
            end ,self
            )

    end 

end



function GuildAPI:Assignment_GuildLastWeekRank(go,key,v,index) --获取上周战队排行
    
    self:ShowNum( index , go.transform:FindChild("Num") )
    go.transform:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
    go.transform:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
    go.transform:FindChild("GuildName"):GetComponent("Text").text=v.Name  
    go.transform:FindChild("Vitality"):GetComponent("Text").text=v.ActivePoint   
    go.transform:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
    --周金币奖励
      local reward;
      if(index<=1)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(1)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(index<=2)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(2)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(index<=3)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(3)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(index<=10)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(10)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(index<=50)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(50)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(index<=100)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(100)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      else
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(-1)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      end
      go.transform:FindChild("Reward"):GetComponent("Text").text = reward
      --


    local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
    self:ShowStarLevel(go.transform:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )
    --[[--------------------------如果是自己的战队Id，就额外将信息填充到界面底部-----------------------
    if(v.GuildId == self.GuildId)then
      --------------------------------------------------------
      self:ShowNum( index ,self.III1_Search:FindChild("Num") )
      self.III1_Search:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
      self.III1_Search:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
      self.III1_Search:FindChild("GuildName"):GetComponent("Text").text=v.Name  
      self.III1_Search:FindChild("Vitality"):GetComponent("Text").text=v.ActivePoint   
      self.III1_Search:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
      local reward ;
      if(v.Level==1)then
        reward=100
      elseif(v.Level==2)then
        reward=200
      elseif(v.Level==3)then
        reward=300
      elseif(v.Level==4)then
        reward=500
      elseif(v.Level==5)then
        reward=750
      elseif(v.Level==6)then
        reward=1000
      end
      self.III1_Search:FindChild("Reward"):GetComponent("Text").text = reward

      local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
      self:ShowStarLevel(self.III1_Search:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )
      --------------------------------------------------------
      self.In_GuildLastWeekRank=true
    end
    --]]

end
function GuildAPI:Assignment_GuildWeekRank(go,key,v,index) --获取上周战队排行
    
    self:ShowNum( index , go.transform:FindChild("Num") )
    go.transform:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
    go.transform:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
    go.transform:FindChild("GuildName"):GetComponent("Text").text=v.Name  
    go.transform:FindChild("Vitality"):GetComponent("Text").text=v.ActivePoint   
    go.transform:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
    --周金币奖励
      local reward;
      if(index<=1)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(1)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(index<=2)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(2)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(index<=3)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(3)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(index<=10)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(10)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(index<=50)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(50)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(index<=100)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(100)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      else
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(-1)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      end
      go.transform:FindChild("Reward"):GetComponent("Text").text = reward
      --

    local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
    self:ShowStarLevel(go.transform:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )
    --[[--------------------------如果是自己的战队Id，就额外将信息填充到界面底部-----------------------
    if(v.GuildId == self.GuildId)then
      --------------------------------------------------------
      self:ShowNum( index , self.III2_Search:FindChild("Num") )
      self.III2_Search:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
      self.III2_Search:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
      self.III2_Search:FindChild("GuildName"):GetComponent("Text").text=v.Name  
      self.III2_Search:FindChild("Vitality"):GetComponent("Text").text=v.ActivePoint   
      self.III2_Search:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
      local reward ;
      if(v.Level==1)then
        reward=100
      elseif(v.Level==2)then
        reward=200
      elseif(v.Level==3)then
        reward=300
      elseif(v.Level==4)then
        reward=500
      elseif(v.Level==5)then
        reward=750
      elseif(v.Level==6)then
        reward=1000
      end
      self.III2_Search:FindChild("Reward"):GetComponent("Text").text = reward

      local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
      self:ShowStarLevel(self.III2_Search:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )
      --------------------------------------------------------
      self.In_GuildWeekRank=true
    end
    --]]

end
function GuildAPI:Assignment_GuildLevelSeasonRank(go,key,v,index) --获取上周战队排行
    
    self:ShowNum( index , go.transform:FindChild("Num") )
    go.transform:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
    go.transform:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
    go.transform:FindChild("GuildName"):GetComponent("Text").text=v.Name  
    go.transform:FindChild("Vitality"):GetComponent("Text").text=v.ActivePoint   
    go.transform:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
    local reward ;
    if(v.Level==1)then
      reward=100
    elseif(v.Level==2)then
      reward=200
    elseif(v.Level==3)then
      reward=300
    elseif(v.Level==4)then
      reward=500
    elseif(v.Level==5)then
      reward=750
    elseif(v.Level==6)then
      reward=1000
    end
    go.transform:FindChild("Reward"):GetComponent("Text").text = reward

    local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
    self:ShowStarLevel(go.transform:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )
    --[[--------------------------如果是自己的战队Id，就额外将信息填充到界面底部-----------------------
    if(v.GuildId == self.GuildId)then
      --------------------------------------------------------
      self:ShowNum( index ,self.III3I_Search:FindChild("Num") )
      self.III3I_Search:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
      self.III3I_Search:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
      self.III3I_Search:FindChild("GuildName"):GetComponent("Text").text=v.Name  
      self.III3I_Search:FindChild("Vitality"):GetComponent("Text").text=v.ActivePoint   
      self.III3I_Search:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
      local reward ;
      if(v.Level==1)then
        reward=100
      elseif(v.Level==2)then
        reward=200
      elseif(v.Level==3)then
        reward=300
      elseif(v.Level==4)then
        reward=500
      elseif(v.Level==5)then
        reward=750
      elseif(v.Level==6)then
        reward=1000
      end
      self.III3I_Search:FindChild("Reward"):GetComponent("Text").text = reward

      local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
      self:ShowStarLevel(self.III3I_Search:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )
      --------------------------------------------------------
      self.In_GuildLevelSeasonRank=true
    end
    -]]

end



function GuildAPI:Assignment_GuildSeasonRank(go,key,v,index) --获取上周战队排行
   
    self:ShowNum( index , go.transform:FindChild("Num") )
    go.transform:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
    go.transform:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
    go.transform:FindChild("GuildName"):GetComponent("Text").text=v.Name  
    go.transform:FindChild("Vitality"):GetComponent("Text").text=v.ActivePoint   
    go.transform:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
    local reward ;
    if(v.Level==1)then
      reward=100
    elseif(v.Level==2)then
      reward=200
    elseif(v.Level==3)then
      reward=300
    elseif(v.Level==4)then
      reward=500
    elseif(v.Level==5)then
      reward=750
    elseif(v.Level==6)then
      reward=1000
    end
    go.transform:FindChild("Reward"):GetComponent("Text").text = reward

    local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
    self:ShowStarLevel(go.transform:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )
    --[[--------------------------如果是自己的战队Id，就额外将信息填充到界面底部-----------------------
    if(v.GuildId == self.GuildId)then
      --------------------------------------------------------
      self:ShowNum( index , self.III3II_Search:FindChild("Num") )
      self.III3II_Search:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
      self.III3II_Search:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
      self.III3II_Search:FindChild("GuildName"):GetComponent("Text").text=v.Name  
      self.III3II_Search:FindChild("Vitality"):GetComponent("Text").text=v.ActivePoint   
      self.III3II_Search:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
      local reward ;
      if(v.Level==1)then
        reward=100
      elseif(v.Level==2)then
        reward=200
      elseif(v.Level==3)then
        reward=300
      elseif(v.Level==4)then
        reward=500
      elseif(v.Level==5)then
        reward=750
      elseif(v.Level==6)then
        reward=1000
      end
      self.III3II_Search:FindChild("Reward"):GetComponent("Text").text = reward

      local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
      self:ShowStarLevel(self.III3II_Search:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )
      --------------------------------------------------------
      self.In_GuildSeasonRank=true
    end
    --]]

end


function GuildAPI:InitSelf_GuildLastWeekRank(v)
  --------------------------将自己战队信息填充到界面底部-----------------------
    --self.rankIndex=self.WeekRank
    
    

    self.III2_Search:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
    self.III2_Search:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
    self.III2_Search:FindChild("GuildName"):GetComponent("Text").text=v.Name  
    self.III2_Search:FindChild("Vitality"):GetComponent("Text").text=v.WeekActivePoint      --周活跃度
    self.III2_Search:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
    --周金币奖励
      local reward;
      if(self.rankIndex<=1)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(1)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(self.rankIndex<=2)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(2)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(self.rankIndex<=3)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(3)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(self.rankIndex<=10)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(10)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(self.rankIndex<=50)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(50)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(self.rankIndex<=100)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(100)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      else
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(-1)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      end
      self.III2_Search:FindChild("Reward"):GetComponent("Text").text = reward
      --
 
    
    local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
    self:ShowStarLevel(self.III2_Search:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )
  

    
end


function GuildAPI:InitSelf_GuildWeekRank(v)
  
    
  --------------------------将自己战队信息填充到界面底部-----------------------
    
    self.rankIndex=self.WeekRank
    
    
    self.III1_Search:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
    self.III1_Search:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
    self.III1_Search:FindChild("GuildName"):GetComponent("Text").text=v.Name  
    self.III1_Search:FindChild("Vitality"):GetComponent("Text").text=v.WeekActivePoint      --周活跃度
    self.III1_Search:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
    --周金币奖励
      local reward;
      if(self.rankIndex<=1)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(1)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(self.rankIndex<=2)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(2)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(self.rankIndex<=3)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(3)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(self.rankIndex<=10)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(10)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(self.rankIndex<=50)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(50)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(self.rankIndex<=100)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(100)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      else
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(-1)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      end
      self.III1_Search:FindChild("Reward"):GetComponent("Text").text = reward
      --
    
    
    local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
    self:ShowStarLevel(self.III1_Search:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )
    
end


function GuildAPI:InitSelf_GuildLevelSeasonRank(v)
  
  --------------------------将自己战队信息填充到界面底部-----------------------
    --self.rankIndex=self.WeekRank
    
    
   
    self.III3I_Search:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
    self.III3I_Search:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
    self.III3I_Search:FindChild("GuildName"):GetComponent("Text").text=v.Name  
    self.III3I_Search:FindChild("Vitality"):GetComponent("Text").text=v.SeasonActivePoint       --赛季活跃度
    self.III3I_Search:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
    local reward;
    if(v.Level==1)then
      reward=100
    elseif(v.Level==2)then
      reward=200
    elseif(v.Level==3)then
      reward=300
    elseif(v.Level==4)then
      reward=500
    elseif(v.Level==5)then
      reward=750
    elseif(v.Level==6)then
      reward=1000
    end
    self.III3I_Search:FindChild("Reward"):GetComponent("Text").text = reward
    
    local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
    self:ShowStarLevel(self.III3I_Search:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )

    
end


function GuildAPI:InitSelf_GuildSeasonRank(v)
  
  --------------------------将自己战队信息填充到界面底部-----------------------
    --self.rankIndex=self.WeekRank
    
    
  
    self.III3II_Search:FindChild("GuildIcon"):GetComponent("Image").sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
    self.III3II_Search:FindChild("Level"):GetComponent("Image").sprite=UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
    self.III3II_Search:FindChild("GuildName"):GetComponent("Text").text=v.Name  
    self.III3II_Search:FindChild("Vitality"):GetComponent("Text").text=v.SeasonActivePoint       --赛季活跃度
    self.III3II_Search:FindChild("Member"):GetComponent("Text").text=v.MemberAmount .. "/" .. v.MemberLimit 
    local reward;
    if(v.Level==1)then
      reward=100
    elseif(v.Level==2)then
      reward=200
    elseif(v.Level==3)then
      reward=300
    elseif(v.Level==4)then
      reward=500
    elseif(v.Level==5)then
      reward=750
    elseif(v.Level==6)then
      reward=1000
    end
    self.III3II_Search:FindChild("Reward"):GetComponent("Text").text = reward
    
    local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
    self:ShowStarLevel(self.III3II_Search:FindChild("StarLevel"),starLevel.Sun,starLevel.Moon ,starLevel.Star )

    
end
----------------------------------------------------------------------------------------------------------------创建战队--
function GuildAPI:CreateGuildRequest()  

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestCreateGuild"),
                                  JProperty.New("GuildName", self.I3_InputField1.text),
                                  JProperty.New("GuildDeclaration", self.I3_InputField2.text),
                                  JProperty.New("GuildIconId", self.selectedGuildIconId)  
                               )
  
  request.Handler = TGNetService.NetEventHanlderSelf( self.CreateGuildResponseHandler,self) 
  TGNetService.GetInstance():SendRequest(request)
  
end
function GuildAPI:RefreshI3()  --刷新创建战队界面  
  
  self.I3_InputField1.text=""
  self.I3_InputField2.text=""
  --填充点券数量
  if(UTGData.Instance().PlayerData.Voucher>50)then
    self.I3_Cost.text="<color=green>" .. 50 .. "</color>/" .. UTGData.Instance().PlayerData.Voucher
  else
    self.I3_Cost.text="<color=red>" .. 50 .. "</color>/" .. UTGData.Instance().PlayerData.Voucher
  end
end
----------------------------------------------------------------------
function GuildAPI:CreateGuildResponseHandler(e)

  if e.Type == "RequestCreateGuild" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("创建战队失败");
    elseif(data.Result==1)then 

      --Debugger.LogError("创建战队成功");
      --跳转到个人筹备列表，Operator监听的推送会刷新列表
      --self:ShowPanel("I","I2M");  -------------------------------------------------------------------------------------------->>
      self:RefreshI3()

      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已向所有无战队好友发送相应邀请\n战队已进入筹备期")
    elseif(data.Result==0x0f01 )then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经加入战队")
    elseif(data.Result==0x0f02 )then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("你正在战队筹备期，无法创建新战队")
    elseif(data.Result==0x0f03 )then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队名字中带有屏蔽字，请您换个战队名称")
    elseif(data.Result==0x0f04 )then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("筹备战队不存在")
    elseif(data.Result==0x0b05 )then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("点券不足")
    elseif(data.Result==0x0f16 )then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队名称为空")
    elseif(data.Result==0x0f17 )then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队名称重复")
    elseif(data.Result==0x0f18 )then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队名称过长")
    end
    return true;
  else
    return false;
  end

end
----------------------------------------------------------------------------------------------------------------获取战队列表--
function GuildAPI:GuildListRequest( beginIndex , length )   --索引，增量

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
function GuildAPI:GuildListResponseHandler(e)
 
  if e.Type == "RequestGuildList" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then  
      self:ShowPanel("I","I1");  ----------------------------------------------------------------------------------------------->>
      --Debugger.LogError("成功");
      --生成列表并赋值   

      --右侧每次初始化先设置不显示，赋值第一个之后显示
      if(#data.GuildList<=0)then
        self.I1_NoOne:SetActive(true)
        self.I1_R:SetActive(false)
      else
        self.I1_NoOne:SetActive(false)
        --self.I1_R:SetActive(true)
      end

      if(self.guildListBeginIndex==0)then  --从0开始取，先清空子物体
      	
        while(self.I1_Content.childCount>0) do
          UIPool.Instance:Return(self.I1_Content:GetChild(0).gameObject)
        end
      end
      self:Instantiate(data.GuildList,"I1_GuildPrefab",self.I1_Content,self,self.Assignment_GuildList,false)  -- []publiclogic.GuildListElement //战队列表
      self.guildListBeginIndex = self.guildListBeginIndex + 20;
      if(data.IsEnd==false)then
        self.I1_WannaMore.gameObject:SetActive(true)
      else
		    self.I1_WannaMore.gameObject:SetActive(false)
      end
    end
    return true;
  else
    return false;
  end
  
end
--------------------------------------------------------------------------------------------------------------申请加入战队--
function GuildAPI:ApplyGuildRequest(guildId)   

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestApplyGuild"),
                                  JProperty.New("GuildId", guildId )
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.ApplyGuildResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:ApplyGuildResponseHandler(e)

  if e.Type == "RequestApplyGuild" then
    local data = json.decode(e.Content:ToString())

    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      self:MyselfApplyingGuildsRequest()  
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已发送申请")  --，请等待管理员审核
    elseif(data.Result==0x0f01 )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经加入战队")
    elseif(data.Result==0x0f02 )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经响应筹备战队")
    elseif(data.Result==0x0f06 )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经申请了该战队")  
    elseif(data.Result==0x0f12 )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不符合申请条件")  
    end  

    return true;
  else
    return false;
  end
  
end
----------------------------------------------------------------------------------------------------------------搜索战队--
function GuildAPI:SearchGuildRequest()  --RequestSearchGuild

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestSearchGuild"),
                                  JProperty.New("GuildName", self.I1_InputField.text )
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.SearchGuildResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:SearchGuildResponseHandler(e)

  if e.Type == "RequestSearchGuild" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then   --GuildInfo 
      --Debugger.LogError("成功");
   
        self.canRefreshGuildList=true
        --先清空子物体
      	
        while(self.I1_Content.childCount>0) do
          UIPool.Instance:Return(self.I1_Content:GetChild(0).gameObject)
        end
      
	    self:Instantiate(data.GuildInfo,"I1_GuildPrefab",self.I1_Content,self,self.Assignment_GuildList,true)  -- []publiclogic.GuildListElement //战队列表
	    
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
----------------------------------------------------------------------------------------------------------------获取筹备列表--
function GuildAPI:PreparingGuildListRequest( beginIndex , length )   --索引，增量  RequestPreparingGuildList

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestPreparingGuildList"),
                                  JProperty.New("BeginIndex", beginIndex ),
                                  JProperty.New("Length", length)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.PreparingGuildListResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:PreparingGuildListResponseHandler(e)
  
  if e.Type == "RequestPreparingGuildList" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      self:ShowPanel("I","I2G"); ------------------------------------------------------------------------------------------->>
      --Debugger.LogError("成功");
      --生成列表并赋值   
      if(#data.PreparingGuildList<=0)then
        self.I2_NoOne:SetActive(true)
        self.I2_R:SetActive(false)
      else
        self.I2_NoOne:SetActive(false)
        self.I2_R:SetActive(true)
      end

      if(self.preparingGuildListBeginIndex==0)then  --从0开始取，先清空子物体
      	
        while(self.I2_Content.childCount>0) do
          UIPool.Instance:Return(self.I2_Content:GetChild(0).gameObject)
        end
      end
      
      self:Instantiate(data.PreparingGuildList ,"I2_GuildPrefab",self.I2_Content,self,self.Assignment_PreparingGuildList,false)  -- []publiclogic.GuildListElement //战队列表
      self.preparingGuildListBeginIndex = self.preparingGuildListBeginIndex + 20;
      if(data.IsEnd==false)then
        self.I2_WannaMore.gameObject:SetActive(true)
      else
		    self.I2_WannaMore.gameObject:SetActive(false)
      end  
    end
    return true;
  else
    return false;
  end
  
end
--------------------------------------------------------------------------------------------------------------响应筹备战队--
function GuildAPI:JoinPreparingGuildRequest(guildId)   

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestJoinPreparingGuild"),
                                  JProperty.New("PreparingGuildId", guildId )
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.JoinPreparingGuildResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:JoinPreparingGuildResponseHandler(e)
 
  if e.Type == "RequestJoinPreparingGuild" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
    end
    return true;
  else
    return false;
  end
  
end
----------------------------------------------------------------------------------------------------------------搜索筹备战队--
function GuildAPI:SearchPreparingGuildRequest()  --RequestSearchGuild

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestSearchPreparingGuild"),
                                  JProperty.New("PreparingGuildName", self.I2_InputField.text )
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.SearchPreparingGuildResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:SearchPreparingGuildResponseHandler(e)
  
  if e.Type == "RequestSearchPreparingGuild" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then   --GuildInfo 
        --Debugger.LogError("成功");
        self.canRefreshPreparingGuildList=true 
        --先清空子物体
      	
        while(self.I2_Content.childCount>0) do
          UIPool.Instance:Return(self.I2_Content:GetChild(0).gameObject)
        end
      
	    self:Instantiate(data.PreparingGuild ,"I2_GuildPrefab",self.I2_Content,self,self.Assignment_PreparingGuildList,true)  -- []publiclogic.GuildListElement //战队列表
	    
	    self.I2_WannaMore.gameObject:SetActive(false)
	  elseif(data.Result==0x0f04 )then 
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("筹备战队不存在")
    end
    return true;
  else
    return false;
  end
  
end
--[[
----------------------------------------------------------------------------------------------------------------筹备中--
function GuildAPI:MyselfPreparingGuildDetailRequest()  --由于调用及回调赋值时机需要高契合度所以写在本脚本中，随后的Notify更新也写在本脚本中

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestMyselfPreparingGuildDetail")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.MyselfPreparingGuildDetailResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:MyselfPreparingGuildDetailResponseHandler(e)
  
  if e.Type == "RequestMyselfPreparingGuildDetail" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
        --Debugger.LogError("失败");
    elseif(data.Result==1)then   --data.PreparingGuild.PreparingGuildInfo  --data.PreparingGuild.Members 
        --Debugger.LogError("成功");
      --if(UTGData.Instance().MyselfPreparingGuildData==nil)then
        UTGData.Instance().MyselfPreparingGuildData=data.PreparingGuild  --自己筹备中战队--数据存储
        local members={}
        for k,v in pairs(UTGData.Instance().MyselfPreparingGuildData.Members) do
          members[tostring(v.Id)]=v;
        end
        UTGData.Instance().MyselfPreparingGuildData.Members=members

        self:InitializeMyselfPreparingGuildDetailMembers(UTGData.Instance().MyselfPreparingGuildData)  --初始化自己战队成员
        self:InitializeMyselfPreparingGuildDetailInfo(UTGData.Instance().MyselfPreparingGuildData)  --初始化自己战队信息 --此中有跳转 --------------->> 
      --end
    end
    return true;
  else
    return false;
  end
  
end
--]]
------------------------------------------------增加战队成员人数上限--
function GuildAPI:AddGuildMemberSizeRequest()  

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestAddGuildMemberSize")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.AddGuildMemberSizeResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:AddGuildMemberSizeResponseHandler(e)
  
  if e.Type == "RequestAddGuildMemberSize" then
    local data = json.decode(e.Content:ToString())  
    if(data.Result==0)then
        --Debugger.LogError("失败");
    elseif(data.Result==1)then   
        --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队扩建成功")
    elseif(data.Result==0x0f08  )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
    elseif(data.Result==0x0f10  )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("已经达到成员上限，不能再提升了")
    elseif(data.Result==0x0b05  )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("点券不足")  
    end
    return true;
  else
    return false;
  end
  
end
function GuildAPI:InitializeMyselfPreparingGuildDetailMembers(PreparingGuild)  --初始化自己战队筹备成员
      --先清空子物体
      
      while(self.I2C_Content.childCount>0) do
        UIPool.Instance:Return(self.I2C_Content:GetChild(0).gameObject)
      end

      self.LeaderId=PreparingGuild.Leader.Id  --存储队长成员Id，以便剔除
      if(self.MyselfPreparingGuildDetailMembers_Co~=nil)then
        coroutine.stop(self.MyselfPreparingGuildDetailMembers_Co);
      end
      self.MyselfPreparingGuildDetailMembers_Co=self:Instantiate(PreparingGuild.Members ,"I2C_GuildPrefab",self.I2C_Content,self,self.Assignment_PreparingGuildMembers,false)  -- []publiclogic.GuildListElement //战队列表
           
end
function GuildAPI:InitializeMyselfPreparingGuildDetailInfo(PreparingGuild)  --初始化自己战队筹备信息
     
      --右侧赋值
      local v = PreparingGuild
      self.I2C_SelectedIcon.sprite = UITools.GetSprite("roleicon",v.Leader.Avatar)
      self.I2C_SelectedFrame.sprite =UITools.GetSprite("frameicon",UTGData.Instance().AvatarFramesData[tostring(v.Leader.AvatarFrameId)].Icon);
      self.I2C_SelectedGuildIcon.sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
      self.I2C_SelectedCaptainName.text =v.Leader.Name  
      self.I2C_SelectedGuildName.text =v.Name  
      self.I2C_SelectedMember.text =v.MemberAmount .. "/" .. "5"
 
      UITools.GetLuaScript(self.I2C_SelectedLimitTime.gameObject,"Logic.UICommon.UICountDownHMS"):StartCountDown(v.EndTime) 
     
      --赋值右侧完毕，跳转进入
      GuildAPI.Instance:ShowPanel("I","I2M");  -------------------------------------------------------->>
      
end
-------------------------------------------------------------------------------------------------
function GuildAPI:InitializeMyselfGuildDetailMembers(Guild)
  if(self.Co_InitializeMyselfGuildDetailMembers~=nil)then
    
    coroutine.stop(self.Co_InitializeMyselfGuildDetailMembers)
    --[[
    for k,v in pairs(self.tableInstantiateCoros) do
      coroutine.stop(v)
    end
    --]]

  end
  self.Co_InitializeMyselfGuildDetailMembers=coroutine.start(self.InitializeMyselfGuildDetailMembers_Co, self, Guild)

end
-------------------------------------------------------------------------------------------------
function GuildAPI:InitializeMyselfGuildDetailMembers_Co(Guild)  --战队--信息--成员

      --Debugger.LogError("1--战队--信息--成员")
      --按赛季活跃点，从大到小排序
      --UITools.CopyTab(Guild);
      local tableTemp={}
      for k,v in pairs(Guild.Members) do
        table.insert(tableTemp,v)
      end
        table.sort(tableTemp, function(a,b) return a.SeasonActivePoint  > b.SeasonActivePoint  end )
      
      --先清空子物体
      --[[
      for i = 1,self.II1_Content.childCount do 
        UIPool.Instance:Return(self.II1_Content:GetChild(i-1).gameObject)
      end
      --]]
      while(self.II1_Content.childCount>0) do
        UIPool.Instance:Return(self.II1_Content:GetChild(0).gameObject)
      end
      --赋值
      if(self.InitializeMyselfGuildDetailMembers_Co_Co~=nil)then
        coroutine.stop(self.InitializeMyselfGuildDetailMembers_Co_Co);
      end
      self.InitializeMyselfGuildDetailMembers_Co_Co =self:Instantiate(tableTemp ,"II1_MemberPrefab",self.II1_Content,self,self.Assignment_GuildMembers,false)  -- []publiclogic.GuildListElement //战队列表
      
end
-------------------------------------------------------------------------------------------------
--这是件比较尴尬的事情，这个界面需要的信息当时没有值，等有了外部调用
function GuildAPI:InitializeMyselfGuildDetailInfoCoin()
  
    local weekRankIndex=self.WeekRank  
    --[[
    for k,v in pairs(UTGData.Instance().GuildLastWeekRank) do
      if(v.GuildId == self.GuildId)then
        weekRankIndex=k;
      end
    end
    --]]
    
    self:ShowNumII( weekRankIndex , self.II1_WeeklyRank)

    --周金币奖励
    local reward;
    if(weekRankIndex<=1)then
      local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(1)].MailInfo
      reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
    elseif(weekRankIndex<=2)then
      local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(2)].MailInfo
      reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
    elseif(weekRankIndex<=3)then
      local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(3)].MailInfo
      reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
    elseif(weekRankIndex<=10)then
      local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(10)].MailInfo
      reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
    elseif(weekRankIndex<=50)then
      local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(50)].MailInfo
      reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
    elseif(weekRankIndex<=100)then
      local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(100)].MailInfo
      reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
    else
      local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(-1)].MailInfo
      reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum
    end
    self.II1_WeeklyReward.text =reward
      
end
-------------------------------------------------------------------------------------------------
function GuildAPI:InitializeMyselfGuildDetailInfo(Guild)     --战队--信息--信息
      
      
      --Debugger.LogError("2--战队--信息--信息")
      local v = Guild
      --全局赋值
      self.selectedGuildIconId=v.IconId
      self.MemberLimit = v.MemberLimit
      self.GuildId=v.Id
      self.GuildMemberCount= #Guild.Members
      
      
      if(UTGData.Instance().selfWeekRank==nil)then
        self.WeekRank=v.WeekRank
      else
        self.WeekRank=UTGData.Instance().selfWeekRank

      end
    
      --给尴尬的金币赋值
      --if(UTGData.Instance().GuildLastWeekRank~=nil)then
        self:InitializeMyselfGuildDetailInfoCoin()
      --end
      
      --战队管理赋值
      self.selectedLevelLimit=v.LimitLevel       
      self.selectedGradeLimit=v.LimitGrade        
      self.selectedIsNeedAllow=v.LimitIsCheck
      
      self.II2_Pop_GuildConfig_GuildName.text=v.Name  
      self.II2_Pop_GuildConfig_GuildIcon.sprite=UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
      self.II2_Pop_GuildConfig_ToggleTrue:GetComponent("Toggle").isOn=self.selectedIsNeedAllow
      self.II2_Pop_GuildConfig_ToggleFalse:GetComponent("Toggle").isOn=(self.selectedIsNeedAllow~=true)
      self.II2_Pop_GuildConfig_LevelLimit.text=v.LimitLevel
      if(self.selectedGradeLimit==-1)then
        self.II2_Pop_GuildConfig_GradeLimit.text="无段位限制"
      else
        self.II2_Pop_GuildConfig_GradeLimit.text=UTGData.Instance().GradesData[tostring(self.selectedGradeLimit)].Title
      end

      if(self.selectedLevelLimit>=30)then
        self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").color=Color.gray;
        self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").raycastTarget=false;
      else
        self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").color=Color.white;
        self.II2_Pop_GuildConfig_LevelLimitA:GetComponent("Image").raycastTarget=true;
      end
      if(self.selectedLevelLimit<=self.UnlockLevel)then --=7
        self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").color=Color.gray;
        self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").raycastTarget=false;
      else
        self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").color=Color.white;
        self.II2_Pop_GuildConfig_LevelLimitD:GetComponent("Image").raycastTarget=true;
      end

      if(self.selectedGradeLimit>=18000017)then
        self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").color=Color.gray;
        self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").raycastTarget=false;
      else
        self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").color=Color.white;
        self.II2_Pop_GuildConfig_GradeLimitA:GetComponent("Image").raycastTarget=true;
      end
      if(self.selectedGradeLimit<18000001)then
        self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").color=Color.gray;
        self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").raycastTarget=false;
      else
        self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").color=Color.white;
        self.II2_Pop_GuildConfig_GradeLimitD:GetComponent("Image").raycastTarget=true;
      end

      --右侧赋值
      --------------------  
      local t=self.II1_StarLevel
      local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
      self:ShowStarLevel(t,starLevel.Sun,starLevel.Moon ,starLevel.Star )

      self.II1_Icon.sprite = UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
      self.II1_GuildName.text =v.Name  
      self.II1_CaptainName.text =v.Leader.Name  
      self.II1_SeasonActivePoint.text =v.SeasonActivePoint 
      self.II1_LevelImage.sprite =UITools.GetSprite("guildlevelicon",UTGData.Instance().GuildLevelsData[tostring(v.Level)].Icon)
      self.II1_Level.text =UTGData.Instance().GuildLevelsData[tostring(v.Level)].Name
      self.II1_CoinAdditionalRate.text =UTGData.Instance().GuildMemberLimitsData[tostring(v.MemberLimit)].CoinAdditionalRate .. "%"
      
      --[[
      --周金币奖励
      local reward;
      if(weekRankIndex<=1)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(1)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(weekRankIndex<=2)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(2)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(weekRankIndex<=3)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(3)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(weekRankIndex<=10)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(10)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(weekRankIndex<=50)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(50)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      elseif(weekRankIndex<=100)then
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(100)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum 
      else
        local mailInfo= UTGData.Instance().GuildWeeklyRankData[tostring(-1)].MailInfo
        reward=UTGData.Instance().MailInfosData[tostring(mailInfo)].Rewards[1].AttachmentNum
      end
      self.II1_WeeklyReward.text =reward
      --]]

      local reward ;
      if(v.Level==1)then
        reward=100
      elseif(v.Level==2)then
        reward=200
      elseif(v.Level==3)then
        reward=300
      elseif(v.Level==4)then
        reward=500
      elseif(v.Level==5)then
        reward=750
      elseif(v.Level==6)then
        reward=1000
      end
      self.II1_SeasonDiiamond.text = reward

      --[[
      local dailyActivePoint
      for k1,v1 in pairs(v.Members) do
        if(v1.PlayerId==UTGData.Instance().PlayerData.Id)then
          dailyActivePoint=v1.DailyActivePoint       
        end
      end
      self.II1_DailyActivePoint.text = dailyActivePoint
      --]]

      --self.II1_Button.gameObject
      
      if(UTGData.Instance().CurrentSeasonInfo~=nil)then
        local pattern_go = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"--"2016-04-27T20:32:22+08:00",
        local year_go, month_go, day_go, hour_go, minute_go, seconds_go = tostring(UTGData.Instance().CurrentSeasonInfo.End):match(pattern_go)
        self.II1_EndTime.text =month_go .. "月" .. day_go .. "日  " .. hour_go .. ":" .. minute_go;
      else
        self.II1_EndTime.text ="";
      end
      
      --赋值右侧完毕，跳转进入
      --GuildAPI.Instance:ShowPanel("II","II1");  另外一处更慢一点，在那里打开  -------------------------------------------------------->>

end
-------------------------------------------------------------------------------------------------
function GuildAPI:InitializeMyselfGuildMembers(Members)
  if(self.Co_InitializeMyselfGuildMembers~=nil)then
    coroutine.stop(self.Co_InitializeMyselfGuildMembers)
    --[[
     for k,v in pairs(self.tableInstantiateCoros) do
      coroutine.stop(v)
    end
    --]]
  end
  self.Co_InitializeMyselfGuildMembers=coroutine.start(self.InitializeMyselfGuildMembers_Co, self, Members)

end
-------------------------------------------------------------------------------------------------
function GuildAPI:InitializeMyselfGuildMembers_Co(Members)      --战队--成员--成员
      --Debugger.LogError("3--战队--成员--成员")
      --先清空子物体
      
      while(self.II2_Content.childCount>0) do
        UIPool.Instance:Return(self.II2_Content:GetChild(0).gameObject)
      end
      --赋值
      if(self.InitializeMyselfGuildMembers_Co_Co~=nil)then
        coroutine.stop(self.InitializeMyselfGuildMembers_Co_Co);
      end
      self.InitializeMyselfGuildMembers_Co_Co=self:Instantiate(Members ,"II2_MemberPrefab",self.II2_Content,self,self.Assignment_GuildMembersII,false)  -- []publiclogic.GuildListElement //战队列表
      
end
-------------------------------------------------------------------------------------------------
function GuildAPI:InitializeMyselfGuildInfo(Guild)           --战队--成员--信息
      --Debugger.LogError("4--战队--成员--信息")
      --右侧赋值
      local v = Guild
      --------------------
      self.II2_Icon.sprite = UITools.GetSprite( "guildicon" ,UTGData.Instance().GuildIconsData[tostring(v.IconId)].Icon )
      self.II2_GuildName.text = v.Name 
      self.II2_CaptainName.text = v.Leader.Name 
   
      self.II2_Amount.text= v.MemberAmount .. "/" .. v.MemberLimit             
      local t=self.II2_StarLevel
    
      local starLevel= UTGData.Instance().GuildStarLevelsData[tostring(v.Star)]
      self:ShowStarLevel(t,starLevel.Sun,starLevel.Moon ,starLevel.Star )
     
      self.II2_Manifestos.text = v.Declaration
      --self.II2_ButtonChange
      --self.II2_ButtonInvite
      --self.II2_ButtonGuild

      if(self.needShow_MyselfGuildMember==true)then
        self:ShowPanel("II","II2");------------------------------------------>>
        self.needShow_MyselfGuildMember=false
      end

end
-------------------------------------战队星级赋值----------------------------------
function GuildAPI:ShowStarLevel(t,sun,moon,star)
      
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
-------------------------------------------------------------------------战队签到--
function GuildAPI:GuildSignInRequest()    

  local request = NetRequest.New()  
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildSignIn")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildSignInResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:GuildSignInResponseHandler(e)
  
  if e.Type == "RequestGuildSignIn" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then   --data.PreparingGuild.PreparingGuildInfo  --data.PreparingGuild.Members 
      --Debugger.LogError("成功");
      self.II1_Pop_SignIn:FindChild("Text"):GetComponent("Text").text="签到成功，获得了<color=yellow>" .. data.ActivePoint .. "</color>点活跃"
      self.II1_Pop_SignIn.gameObject:SetActive(true)

      self.II1_SignIn.gameObject:SetActive(false)
      self.II1_SignInBlack.gameObject:SetActive(true)
      --消除红点
      UTGDataOperator.Instance.battleGroupButtonNoticeII =false 
      if(UTGMainPanelAPI~=nil and UTGMainPanelAPI.Instance~=nil )then
        UTGMainPanelAPI.Instance:UpdateNotice()
      end

    end
    return true;
  else
    return false;
  end
  
end
----------------------------------------------------------------------------------------------------------------申请列表--
function GuildAPI:GuildApplicationListRequest( beginIndex , length )   --索引，增量  Type：RequestGuildApplicationList

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildApplicationList"),
                                  JProperty.New("BeginIndex", beginIndex ),
                                  JProperty.New("Length", length)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildApplicationListResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:GuildApplicationListResponseHandler(e)
 
  if e.Type == "RequestGuildApplicationList" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then  
      --Debugger.LogError("成功");  
      --生成列表并赋值   

      if(self.ApplicationListBeginIndex==0)then  --从0开始取，先清空子物体
        
        while(self.II2_Pop_ApplicationList_Content.childCount>0) do
        UIPool.Instance:Return(self.II2_Pop_ApplicationList_Content:GetChild(0).gameObject)
        end
      end

      self.II2_Pop_ApplicationList.gameObject:SetActive(true)  --Response后显示界面，没有右侧赋值，所以清空列表之后打开就可以了

      self:Instantiate(data.ApplicationList ,"II2_Pop_ApplicationList_Prefab",self.II2_Pop_ApplicationList_Content,self,self.Assignment_ApplicationList,false)  
      self.ApplicationListBeginIndex = self.ApplicationListBeginIndex + 20;
      if(data.IsEnd==false)then
        self.II2_Pop_ApplicationList_WannaMore.gameObject:SetActive(true)
      else
        self.II2_Pop_ApplicationList_WannaMore.gameObject:SetActive(false)
      end

      --消除红点
      UTGDataOperator.Instance.battleGroupButtonNotice =false 
   
      if(UTGMainPanelAPI~=nil and UTGMainPanelAPI.Instance~=nil )then
        UTGMainPanelAPI.Instance:UpdateNotice()
      end
      if(GuildAPI~=nil and GuildAPI.Instance~=nil )then
        GuildAPI.Instance.II2_ApplicationPoint.gameObject:SetActive(false)  --此界面的红点
      end



    end
    return true;
  else
    return false;
  end
  
end

----------------------------------------------------------------------------------------------------------------同意申请--
function GuildAPI:AgreeGuildApplicationRequest( applicationId  )   --Type：RequestAgreeGuildApplication

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestAgreeGuildApplication"),
                                  JProperty.New("ApplicationId", applicationId )
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.AgreeGuildApplicationResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:AgreeGuildApplicationResponseHandler(e)    
 
  if e.Type == "RequestAgreeGuildApplication" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then  
      --Debugger.LogError("成功");
      Object.Destroy(self.WannaDestory.gameObject)
    elseif(data.Result==0x0f07 )then  
      --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("权限不足")
    elseif(data.Result==0x0f08  )then  
      --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
    elseif(data.Result==0x0f0a   )then  
      --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队申请不存在")
    elseif(data.Result==0x0f0c    )then  
      --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("申请者已经加入其它战队")
      Object.Destroy(self.WannaDestory.gameObject)
    elseif(data.Result==0x0f0b     )then  
      --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队成员数量已满")
    end
    return true;
  else
    return false;
  end
  
end
----------------------------------------------------------------------------------------------------------------拒绝申请--
function GuildAPI:RefuseGuildApplicationRequest( applicationId  )   --Type：RequestRefuseGuildApplication

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestRefuseGuildApplication"),
                                  JProperty.New("ApplicationId", applicationId )
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.RefuseGuildApplicationResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:RefuseGuildApplicationResponseHandler(e)
 
  if e.Type == "RequestRefuseGuildApplication" then
    local data = json.decode(e.Content:ToString())
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then  
      --Debugger.LogError("成功");
      Object.Destroy(self.WannaDestory.gameObject)
    elseif(data.Result==0x0f07 )then  
      --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("权限不足")
    elseif(data.Result==0x0f08  )then  
      --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
    elseif(data.Result==0x0f0a   )then  
      --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("战队申请不存在")
    end
    return true;
  else
    return false;
  end
  
end
----------------------------------------------------------------------------------------------------------------战队日志--
function GuildAPI:GuildLogListRequest()    --RequestGuildLogList
 
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildLogList")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildLogListResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:GuildLogListResponseHandler(e)
 
  if e.Type == "RequestGuildLogList" then
    local data = json.decode(e.Content:ToString())  
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
      --生成列表并赋值   
      

      
      while(self.II2_Pop_GuildLogContent.childCount>0) do
        UIPool.Instance:Return(self.II2_Pop_GuildLogContent:GetChild(0).gameObject)
      end
      
      local tableTemp={};
      for k,v in pairs(data.LogList) do
        table.insert(tableTemp,1,v)
      end
      self:Instantiate(tableTemp  ,"II2_Pop_GuildLogPrefab",self.II2_Pop_GuildLogContent,self,self.Assignment_GuildLogList,false)  -- []publiclogic.GuildListElement //战队列表
    elseif(data.Result==0x0f07 )then  
      --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("权限不足")
    elseif(data.Result==0x0f08  )then  
      --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
    end

    return true;
  else
    return false;
  end
  
end
function GuildAPI:ChangeGuildConfigRequest(guildIconId,guildIsCheck,guildLimitLevel,guildLimitGrade)    --RequestChangeGuildConfig

  local request = NetRequest.New()  
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestChangeGuildConfig"),
                                  JProperty.New("GuildIconId",guildIconId),
                                  JProperty.New("GuildIsCheck",guildIsCheck),
                                  JProperty.New("GuildLimitLevel",guildLimitLevel),
                                  JProperty.New("GuildLimitGrade",guildLimitGrade)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.ChangeGuildConfigResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:ChangeGuildConfigResponseHandler(e)
  self.canGuildConfig=true
 
  if e.Type == "RequestChangeGuildConfig" then
    local data = json.decode(e.Content:ToString()) 
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("修改成功")
    elseif(data.Result==0x0f08 )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
    elseif(data.Result==0x0f07  )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("权限不足")
    end
    return true;
  else
    return false;
  end
  
end
----------------------------------------------------------------------------------------------------------------修改战队宣言--
function GuildAPI:ChangeGuildDeclarationRequest(guildDeclaration )    --RequestChangeGuildDeclaration
  
  local request = NetRequest.New()  
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestChangeGuildDeclaration"),
                                  JProperty.New("GuildDeclaration",guildDeclaration)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.ChangeGuildDeclarationResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------------------------
function GuildAPI:ChangeGuildDeclarationResponseHandler(e)
  
  if e.Type == "RequestChangeGuildDeclaration" then  
    local data = json.decode(e.Content:ToString()) 
    if(data.Result==0)then 
      --Debugger.LogError("失败");
    elseif(data.Result==1)then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("修改成功")
    elseif(data.Result==0x0f08 )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
    elseif(data.Result==0x0f07  )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("权限不足")
    end
    return true;
  else
    return false;
  end
  
end
----------------------------------------------------------------------------------------------------------------退出战队--
function GuildAPI:LeaveGuildRequest()   --Type：RequestLeaveGuild

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestLeaveGuild")
                                 
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.LeaveGuildResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end


----------------------------------------------------------------------
function GuildAPI:LeaveGuildResponseHandler(e)    
  
  if e.Type == "RequestLeaveGuild" then
    local data = json.decode(e.Content:ToString()) 
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then  
      --Debugger.LogError("成功");
    elseif(data.Result==0x0f14  )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("申请正在CD中，目前还不能申请")
    else
      Debugger.LogError(data.Result)
    end
    return true;
  else
    return false;
  end
  
end
----------------------------------------------------------------------------------------------------------------战队招募CD--
function GuildAPI:GuildInviteCD(second)
  self.Co_CountDownRevive= coroutine.start(self.GuildInviteCD_Co ,self , second) 
end
function GuildAPI:GuildInviteCD_Co(second)

  --开始死亡打开Collider
  self.InviteCDCollider.gameObject:SetActive(true)

  while(second>0.1) do   
    second=second-Time.deltaTime
    --local hS=""
    local mS=""
    local sS=""

    --local h= math.floor(second/3600)
    local m= math.floor(second%3600/60)
    local s= math.floor(second%60)

    --if(h<10)then
    --  hS= "0" .. h;
    --else
    --  hS= h;
    --end
    
    if(m<10)then
      mS= "0" .. m;
    else
      mS= m;
    end

    if(s<10)then
      sS= "0" .. s;
    else
      sS= s;
    end

    self.InviteCDTime.text=mS .. ":" ..  sS;

    coroutine.step();

  end

  self.InviteCDCollider.gameObject:SetActive(false)
  


end
----------------------------------------------------------------------------------------------------------------战队招募--
function GuildAPI:SendGuildInvitationRequest()   

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestSendGuildInvitation")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.SendGuildInvitationResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function GuildAPI:SendGuildInvitationResponseHandler(e)    
  
  if e.Type == "RequestSendGuildInvitation" then
    local data = json.decode(e.Content:ToString()) 
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then  
      --Debugger.LogError("成功");
    elseif(data.Result==0x0f08   )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
    elseif(data.Result==0x0f07  )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("权限不足")
    else
      Debugger.LogError(data.Result)
    end
    return true;
  else
    return false;
  end
  
end
---------------------------------------
function GuildAPI:DoGoToStorePanel(page)
  -- body
  coroutine.start(self.GoToStorePanel, self,page) 

end

function GuildAPI:GoToStorePanel(page)
  -- body
  local async = GameManager.CreatePanelAsync("Store")
  while async.Done == false do
    coroutine.wait(0.05)
  end
  if StoreCtrl ~= nil and StoreCtrl.Instance ~= nil then
    StoreCtrl.Instance:GoToUI(page)
  end

end
---------------------------------------
function GuildAPI:InitializeGuildLastWeekRank(guildRanks)     --获取上周战队排行  self.GuildLastWeekRank
      --先清空子物体
     
      while(self.III2_Content.childCount>0) do
        UIPool.Instance:Return(self.III2_Content:GetChild(0).gameObject)
      end
      --赋值
      self:Instantiate(guildRanks ,"III2_Prefab",self.III2_Content,self,self.Assignment_GuildWeekRank,false) 

end
---------------------------------------
function GuildAPI:InitializeGuildWeekRank(guildRanks)         --获取本周战队排行  self.GuildWeekRank
  
      --先清空子物体
      
      while(self.III1_Content.childCount>0) do
        UIPool.Instance:Return(self.III1_Content:GetChild(0).gameObject)
      end
      --赋值
      self:Instantiate(guildRanks ,"III1_Prefab",self.III1_Content,self,self.Assignment_GuildLastWeekRank,false) 
      
end
---------------------------------------
function GuildAPI:InitializeGuildLevelSeasonRank(guildRanks)  --获取战队当前等级的赛季排行榜  self.GuildLevelSeasonRank
  
      --先清空子物体
      
      while(self.III3I_Content.childCount>0) do
        UIPool.Instance:Return(self.III3I_Content:GetChild(0).gameObject)
      end
      --赋值
      self:Instantiate(guildRanks ,"III3I_Prefab",self.III3I_Content,self,self.Assignment_GuildLevelSeasonRank,false) 
      
end
---------------------------------------
function GuildAPI:InitializeGuildSeasonRank(guildRanks)       --获取战队赛季排行榜  self.GuildSeasonRank
  
      --先清空子物体

      while(self.III3II_Content.childCount>0) do
        UIPool.Instance:Return(self.III3II_Content:GetChild(0).gameObject)
      end
      --赋值
      self:Instantiate(guildRanks ,"III3II_Prefab",self.III3II_Content,self,self.Assignment_GuildSeasonRank,false) 
      
end
 
--***************************
--获取自己申请过的战队Id : WYL
--***************************

function GuildAPI:MyselfApplyingGuildsRequest()    

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestMyselfApplyingGuilds")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.MyselfApplyingGuildsResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end

function GuildAPI:MyselfApplyingGuildsResponseHandler(e)

  if e.Type == "RequestMyselfApplyingGuilds" then
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
    
      UTGData.Instance().ApplyingGuilds ={}  --[]int --申请了哪些战队的ID列表
      for k,v in pairs(data.ApplyingGuilds) do
      UTGData.Instance().ApplyingGuilds[tostring(v)]=v
      end

      --添加已申请标签
      for i=1,self.I1_Content.childCount do
        for k1,v1 in pairs(UTGData.Instance().ApplyingGuilds) do  --已申请
          if(self.I1_Content:GetChild(i-1).name==tostring(v1))then  
            self.I1_Content:GetChild(i-1):FindChild("HadApplied").gameObject:SetActive(true);
            break    
          end  
        end
      end

    end

    return true;
  else
    return false;
  end

end
-----------------------------------------------------开除队员---------------------------------------------------
function GuildAPI:GuildFireMemberRequest(targetMemberId )    
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildFireMember"),
                                  JProperty.New("TargetMemberId",targetMemberId)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildFireMemberResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function GuildAPI:GuildFireMemberResponseHandler(e)
  
  if e.Type == "RequestGuildFireMember" then
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("开除成功")
    elseif(data.Result==0x0f08   )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
    elseif(data.Result==0x0f07     )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("权限不足")
    else
      Debugger.LogError(data.Result)
    end

    

    return true;
  else
    return false;
  end

end
-----------------------------------------------------队长传位---------------------------------------------------
function GuildAPI:GuildLeaderDemiseRequest(targetMemberId )    --Type：RequestGuildLeaderDemise
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildLeaderDemise"),
                                  JProperty.New("TargetMemberId",targetMemberId)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildLeaderDemiseResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function GuildAPI:GuildLeaderDemiseResponseHandler(e)

  if e.Type == "RequestGuildLeaderDemise" then  
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("传位成功")
    elseif(data.Result==0x0f08   )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
    elseif(data.Result==0x0f07     )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("权限不足")
    else
      Debugger.LogError(data.Result)
    end

    

    return true;
  else
    return false;
  end

end
-----------------------------------------------------任命副队长------------------------------------------
function GuildAPI:GuildAppointViceLeader(targetMemberId)
  
  local ViceCaptainTable={};
  for k,v in pairs(UTGData.Instance().MyselfGuild.Members) do
    if(v.PositionLevel==2)then
      table.insert(ViceCaptainTable,v)
    end
  end
  
  if(#ViceCaptainTable<2)then  --如果<2个，直接任命 
    self:GuildAppointViceLeaderRequest(targetMemberId,-1)
  else  --如果>=2个，替换
    self.AppointViceLeaderTip_Toggle1:FindChild("Label"):GetComponent("Text").text=ViceCaptainTable[1].Name 
    self.AppointViceLeaderTip_Toggle2:FindChild("Label"):GetComponent("Text").text=ViceCaptainTable[2].Name   

    local ReplaceMemberId=ViceCaptainTable[1].Id ;  
    local listener = NTGEventTriggerProxy.Get(self.AppointViceLeaderTip_Toggle1.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                                                                            function ()  
                                                                              ReplaceMemberId=ViceCaptainTable[1].Id
                                                                            end 
                                                                            ,self
                                                                            )
    local listener = NTGEventTriggerProxy.Get(self.AppointViceLeaderTip_Toggle2.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                                                                            function ()  
                                                                              ReplaceMemberId=ViceCaptainTable[2].Id
                                                                            end 
                                                                            ,self
                                                                            )
    local listener = NTGEventTriggerProxy.Get(self.AppointViceLeaderTip_ButtonEnter.gameObject)  
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                                                                            function ()  
                                                                              
                                                                              self:GuildAppointViceLeaderRequest(targetMemberId,ReplaceMemberId)
                                                                              self.AppointViceLeaderTip.gameObject:SetActive(false);
                                                                            end 
                                                                            ,self
                                                                            )
    self.AppointViceLeaderTip.gameObject:SetActive(true);

  end
  --[[
  --任命副队长
  self.AppointViceLeaderTip=self.this.transform:FindChild("AppointViceLeaderTip");     
  self.AppointViceLeaderTip_Toggle1=self.AppointViceLeaderTip:FindChild("Frame/ToggleGroup/Toggle1"); 
  self.AppointViceLeaderTip_Toggle2=self.AppointViceLeaderTip:FindChild("Frame/ToggleGroup/Toggle2"); 
  self.AppointViceLeaderTip_ButtonEnter=self.AppointViceLeaderTip:FindChild("Frame/ButtonEnter"); 
  self.AppointViceLeaderTip_ButtonCancel=self.AppointViceLeaderTip:FindChild("Frame/ButtonCancel"); 
  ]] 
end
-----------------------------------------------------任命副队长请求---------------------------------------------------
function GuildAPI:GuildAppointViceLeaderRequest(targetMemberId,replaceMemberId )    --Type：RequestGuildAppointViceLeader
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildAppointViceLeader"),
                                  JProperty.New("TargetMemberId",targetMemberId),
                                  JProperty.New("ReplaceMemberId",replaceMemberId)

                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildAppointViceLeaderResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function GuildAPI:GuildAppointViceLeaderResponseHandler(e)

  if e.Type == "RequestGuildAppointViceLeader" then  
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("任命成功")
    elseif(data.Result==0x0f08   )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
    elseif(data.Result==0x0f07     )then   
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("权限不足")
    else
      
      Debugger.LogError(data.Result)
      
    end

    

    return true;
  else
    return false;
  end

end


--[[
        local listener = NTGEventTriggerProxy.Get(self.I2_SelectedButton.gameObject)  --确认按钮事件
        listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
            function ()
                      --弹窗
                      self.DelegateTip_Title.text="提示"   
                      self.DelegateTip_PromptContent.text="响应后，该战队筹备期内不可加入其他战队。\n是否确定响应？"
                      local listener = NTGEventTriggerProxy.Get(self.DelegateTip_ButtonEnter.gameObject)  --确认按钮事件
                      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
                          function () 
                            self:JoinPreparingGuildRequest(v.Id) 
                            self.DelegateTip.gameObject:SetActive(false)
                          end ,self
                          )
                      self.DelegateTip.gameObject:SetActive(true)
            end ,self
            )
--]]

--***************************
--获取上周战队排行 : WYL
--***************************
function GuildAPI:GuildLastWeekRankRequest()   --RequestGuildLastWeekRank
  if(UTGData.Instance().PlayerData.GuildStatus~=1)then return end  --如果没有加入战队，退出
  --Debugger.LogError("S I")
  

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildLastWeekRank")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildLastWeekRankResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function GuildAPI:GuildLastWeekRankResponseHandler(e)
  --Debugger.LogError("S I B")
  if e.Type == "RequestGuildLastWeekRank" then
    local data = json.decode(e.Content:ToString())
       
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
      UTGData.Instance().GuildLastWeekRank=data.Rank   --[]publiclogic.GuildRank
    end
    --先填充自己的排名数字
    for k,v in pairs(UTGData.Instance().GuildLastWeekRank) do
      if(v.GuildId == self.GuildId)then
        self.rankIndex=k;
      end
    end
    self:ShowNum( self.rankIndex , self.III2_Search:FindChild("Num") )
    
    self:InitializeGuildLastWeekRank(UTGData.Instance().GuildLastWeekRank)

    return true;
  else
    return false;
  end

end
--***************************
--获取本周战队排行 : WYL
--***************************
function GuildAPI:GuildWeekRankRequest()   --Type：RequestGuildWeekRank
  if(UTGData.Instance().PlayerData.GuildStatus~=1)then return end  --如果没有加入战队，退出
  --Debugger.LogError("S II")
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildWeekRank")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildWeekRankResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function GuildAPI:GuildWeekRankResponseHandler(e)
  --Debugger.LogError("S II B")
  if e.Type == "RequestGuildWeekRank" then
    local data = json.decode(e.Content:ToString())
       
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
      UTGData.Instance().GuildWeekRank=data.Rank   --[]publiclogic.GuildRank
    end
    
    if GuildAPI ~= nil and GuildAPI.Instance ~= nil then
      GuildAPI.Instance:InitializeMyselfGuildDetailInfoCoin()
    end
    --填充自己战队的排名
    for k,v in pairs(UTGData.Instance().GuildWeekRank) do
      if(v.GuildId == self.GuildId)then
        self.rankIndex=k;
        UTGData.Instance().selfWeekRank=k
        self:ShowNumII( k , self.II1_WeeklyRank)
      end
    end
    self:ShowNum( self.rankIndex , self.III1_Search:FindChild("Num") )

    self:InitializeGuildWeekRank(UTGData.Instance().GuildWeekRank )  

    return true;
  else
    return false;
  end

end
--***************************
--获取战队当前等级的赛季排行榜 : WYL
--***************************
function GuildAPI:GuildLevelSeasonRankRequest()   --RequestGuildLevelSeasonRank
  if(UTGData.Instance().PlayerData.GuildStatus~=1)then return end  --如果没有加入战队，退出
  --Debugger.LogError("S III")
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildLevelSeasonRank")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildLevelSeasonRankResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function GuildAPI:GuildLevelSeasonRankResponseHandler(e)
  --Debugger.LogError("S III B")
  if e.Type == "RequestGuildLevelSeasonRank" then
    local data = json.decode(e.Content:ToString())
       
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
      UTGData.Instance().GuildLevelSeasonRank=data.Rank   --[]publiclogic.GuildRank
    end
    --赋值自己战队排名
    for k,v in pairs(UTGData.Instance().GuildLevelSeasonRank) do
      if(v.GuildId == self.GuildId)then
        self.rankIndex=k;
      end
    end
    self:ShowNum( self.rankIndex , self.III3I_Search:FindChild("Num") )

    self:InitializeGuildLevelSeasonRank(UTGData.Instance().GuildLevelSeasonRank)

    return true;
  else
    return false;
  end

end
--***************************
--获取战队赛季排行榜 : WYL
--***************************
function GuildAPI:GuildSeasonRankRequest()   --RequestGuildSeasonRank
 
  if(UTGData.Instance().PlayerData.GuildStatus~=1)then return end  --如果没有加入战队，退出
  --Debugger.LogError("S IV")

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestGuildSeasonRank")
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.GuildSeasonRankResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
function GuildAPI:GuildSeasonRankResponseHandler(e)
  --Debugger.LogError("S IV B")
  if e.Type == "RequestGuildSeasonRank" then
    local data = json.decode(e.Content:ToString())
   
    if(data.Result==0)then
      --Debugger.LogError("失败");
    elseif(data.Result==1)then
      --Debugger.LogError("成功");
      UTGData.Instance().GuildSeasonRank=data.Rank   --[]publiclogic.GuildRank
    end
    --赋值自己战队排名
    for k,v in pairs(UTGData.Instance().GuildSeasonRank) do
      if(v.GuildId == self.GuildId)then
        self.rankIndex=k;
      end
    end
    self:ShowNum( self.rankIndex ,  self.III3II_Search:FindChild("Num") )

    self:InitializeGuildSeasonRank(UTGData.Instance().GuildSeasonRank)

    return true;
  else
    return false;
  end

end

--------------------改变推送新申请状态-------------------Type：RequestChangeFlagShowNewApplication
function GuildAPI:ChangeFlagShowNewApplicationRequest(bool)

  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestChangeFlagShowNewApplication"),
                                  JProperty.New("Flag",bool)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.ChangeFlagShowNewApplicationResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)

end
----------------------------------------------------------------------
function GuildAPI:ChangeFlagShowNewApplicationResponseHandler(e)
  
  if e.Type == "RequestChangeFlagShowNewApplication" then
    
    local data = json.decode(e.Content:ToString())
    
    if(data.Result==0)then
      --Debugger.LogError("设置失败");
    elseif(data.Result==1)then
      --Debugger.LogError("设置成功");
    elseif(data.Result==0x0f08  )then
      GameManager.CreatePanel("SelfHideNotice")
      SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("不在战队中")
    end

    return true;
  else
    return false;
  end

end
---------------------------------添加好友-----------------------------
function GuildAPI:AddFriendRequest(Id)
  
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
function GuildAPI:AddFriendResponseHandler(e)
  
  if e.Type == "RequestSendFriendApplication" then
 --Debugger.LogError(e.Type)  
    local data = json.decode(e.Content:ToString())
    --Debugger.LogError(data.Result)
    
    if(data.Result==0)then
      --Debugger.LogError("申请添加好友失败");
    elseif(data.Result==1)then
      --Debugger.LogError("申请添加好友成功");
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