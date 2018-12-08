--Maintenance By WYL

require "Logic.UICommon.Static.UITools"

local json = require "cjson"
require "Logic.UTGData.UTGData"

class("CreatePlayerAPI")
----------------------------------------------------
function CreatePlayerAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  CreatePlayerAPI.Instance=self;
  -----------------引用--------------------
  self.inputField=self.this.transform:FindChild("Center/Pop/InputField");
  self.buttonRandom=self.this.transform:FindChild("Center/Pop/ButtonRandom").gameObject;
  self.buttonCreate=self.this.transform:FindChild("Center/Pop/ButtonCreate").gameObject;
  
  self.nicknames_firstword = {        
        "翎",
        "卡",
        "芷",
        "风",
        "水",
        "惊",
        "天",
        "零",
        "牵",
        "回",
        "思",
        "欲",
        "蓝",
        "夜",
        "萧",
        "风",
        "雨",
        "苦",
        "寒",
        "天",
        "醉",
        "伤",
        "洋",
        "犀",
        "蕉",
        "战",
        "为",
        "孟",
        "铁",
        "野",
        "律"}
      
  self.nicknames_secondword = {        
        "翎",
        "卡",
        "芷",
        "风",
        "水",
        "惊",
        "天",
        "零",
        "牵",
        "回",
        "思",
        "欲",
        "蓝",
        "夜",
        "萧",
        "风",
        "雨",
        "苦",
        "寒",
        "天",
        "醉",
        "伤",
        "洋",
        "犀",
        "蕉",
        "战",
        "为",
        "孟",
        "铁",
        "野",
        "律"}
      
  self.nicknames_thirdword = {        
        "翎",
        "卡",
        "芷",
        "风",
        "水",
        "惊",
        "天",
        "零",
        "牵",
        "回",
        "思",
        "欲",
        "蓝",
        "夜",
        "萧",
        "风",
        "雨",
        "苦",
        "寒",
        "天",
        "醉",
        "伤",
        "洋",
        "犀",
        "蕉",
        "战",
        "为",
        "孟",
        "铁",
        "野",
        "律"}
  
end
----------------------------------------------------
function CreatePlayerAPI:Start()
  --UnityEngine.Resources.UnloadUnusedAssets();
  --self.inputField.text="伊泽瑞尔";
  local listener = NTGEventTriggerProxy.Get( self.buttonCreate);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( CreatePlayerAPI.OnCreateButtonClick,self);
  
  listener = NTGEventTriggerProxy.Get(self.buttonRandom);
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( CreatePlayerAPI.OnRandomButtonClick,self);


  --self:WidthOfString("")


end
----------------------------------------------------
function CreatePlayerAPI:OnDestroy() 
  
  
  ------------------------------------
  CreatePlayerAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
----------------------------------------------------
function CreatePlayerAPI:OnRandomButtonClick()
  math.randomseed(os.time()) 
  self.inputField:GetComponent("UnityEngine.UI.InputField").text = self.nicknames_firstword[math.random(1,31)] .. self.nicknames_secondword[math.random(1,31)] .. self.nicknames_thirdword[math.random(1,31)]
end
----------------------------------------------------
function CreatePlayerAPI:OnCreateButtonClick()

  if(self.inputField:GetComponent("UnityEngine.UI.InputField").text == "" )then
    GameManager.CreatePanel("Hint");
    HintAPI.Instance:Hint( "请输入名字");
    return;
  end
  if( UITools.WidthOfString(self.inputField:GetComponent("UnityEngine.UI.InputField").text,0)>12 )then
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("名字最长为6个中文字或12个英文字");
    return;
  end
  
  --申请创建角色
  GameManager.CreatePanel("Waiting")
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestNewPlayer"),
                                  JProperty.New("Nickname",self.inputField:GetComponent("UnityEngine.UI.InputField").text),
                                  JProperty.New("AccountId",UTGData.Instance().AccountId)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( CreatePlayerAPI.ResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)

end
-------------------------------------------------------------------
function CreatePlayerAPI:ResponseHandler(e)
  --Debugger.LogError("进入回调");
  if e.Type == "RequestNewPlayer" then
    WaitingPanelAPI.Instance:DestroySelf()
    local data = json.decode(e.Content:ToString())
    
    if(data["Result"]==0)then
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("创建失败");
    end
    if(data["Result"]==1)then

      UTGData.Instance():UTGPlayerDetail(CreatePlayerAPI.GetPlayerDetailDataHandler,self) 
      --self:GetPlayerDetailDataHandler()
    elseif(data["Result"]==0x010a)then
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("角色名不合法");
    elseif(data["Result"]==0x0103 )then
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("角色名被占用");
    elseif(data["Result"]==0x0102 )then
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("名字最长为6个中文字或12个英文字");
    end

    return true;
  else
    return false;
  end

end
-------------------------------------------------------------------
 
--获取playerdetail数据成功
function CreatePlayerAPI:GetPlayerDetailDataHandler()
   coroutine.start( CreatePlayerAPI.DownLoadDataMov,self)
end
--下载静态数据
function CreatePlayerAPI:DownLoadDataMov()
  local result = StartGameAPI.Instance:DownLoadData()
  while result.Done~= true do
    coroutine.wait(0.05)
  end
  Object.Destroy(self.this.gameObject)
  NTGResourceController.Instance:UnloadAssetBundle("bg-CreatePlayer", true, false)
end


