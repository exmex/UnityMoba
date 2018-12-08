require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"

class("ChangeGuildNameAPI")
local json = require "cjson"
----------------------------------------------------
function ChangeGuildNameAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  ChangeGuildNameAPI.Instance=self;
  -------------------------------------
  
  
end
----------------------------------------------------
function ChangeGuildNameAPI:Start()
----------------修改名字按钮--
  self.buttonClose=self.this.transform:FindChild("Center/ButtonClose").gameObject;

  local listener = NTGEventTriggerProxy.Get(self.buttonClose)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
              function ()
                Object.Destroy(self.this.gameObject);
              end,self
              )
-----------------------------------------
----------------修改名字按钮--
  self.inputField=self.this.transform:FindChild("Center/Pop/InputField");

  self.buttonChangeGuildNameAPIEnter = self.this.transform:FindChild("Center/Pop/Button").gameObject; 
  local listener = NTGEventTriggerProxy.Get(self.buttonChangeGuildNameAPIEnter)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
              function ()

                self:ChangeGuildNameRequest( ) 
              end,self
              )
-----------------------------------------
end
----------------------------------------------------
function ChangeGuildNameAPI:OnDestroy() 
  
  
  ------------------------------------
  ChangeGuildNameAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
------------------------------------------修改名字--
function ChangeGuildNameAPI:ChangeGuildNameRequest( )   
  
  if(self.inputField:GetComponent("UnityEngine.UI.InputField").text == "" )then
    GameManager.CreatePanel("Hint");
    HintAPI.Instance:Hint( "请输入战队名字");
    return;
  end
  if( UITools.WidthOfString(self.inputField:GetComponent("UnityEngine.UI.InputField").text,0)>14 )then
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("战队名字最长为7个中文字或14个英文字");
    return;
  end
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestChangeGuildName"),
                                  JProperty.New("GuildName",self.inputField:GetComponent("UnityEngine.UI.InputField").text)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.ChangeGuildNameResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------
function ChangeGuildNameAPI:ChangeGuildNameResponseHandler(e)
  
  if e.Type == "RequestChangeGuildName" then
    
    local data = json.decode(e.Content:ToString()) Debugger.LogError(data.Result)
    --Debugger.LogError(data.Result)
    if(data.Result==0)then
      ----Debugger.LogError("失败");
    elseif(data.Result==1)then 
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("修改成功");
    elseif(data.Result==1793)then 
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("缺少1个战队改名卡");
    elseif(data.Result==1794)then 
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("缺少1个战队改名卡");
    end

    return true;
  else
    return false;
  end
  
end