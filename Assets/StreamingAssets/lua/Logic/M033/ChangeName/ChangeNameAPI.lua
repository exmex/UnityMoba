require "Logic.UICommon.Static.UITools"
require "Logic.UTGData.UTGData"

class("ChangeNameAPI")
local json = require "cjson"
----------------------------------------------------
function ChangeNameAPI:Awake(this) 
  self.this = this  
  -------------------------------------
  ChangeNameAPI.Instance=self;
  -------------------------------------
  
  
end
----------------------------------------------------
function ChangeNameAPI:Start()
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

  self.buttonChangeNameAPIEnter = self.this.transform:FindChild("Center/Pop/Button").gameObject; 
  local listener = NTGEventTriggerProxy.Get(self.buttonChangeNameAPIEnter)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(
              function ()

                self:ChangePlayerNameRequest( ) 
              end,self
              )
-----------------------------------------
end
----------------------------------------------------
function ChangeNameAPI:OnDestroy() 
  
  
  ------------------------------------
  ChangeNameAPI.Instance=nil;
  ------------------------------------
  self.this = nil
  self = nil
end
------------------------------------------修改名字--
function ChangeNameAPI:ChangePlayerNameRequest( ) 
  
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
  
  local request = NetRequest.New()
  request.Content = JObject.New(
                                  JProperty.New("Type","RequestChangePlayerName"),
                                  JProperty.New("NewName",self.inputField:GetComponent("UnityEngine.UI.InputField").text)
                               )
  request.Handler = TGNetService.NetEventHanlderSelf( self.ChangePlayerNameResponseHandler,self)
  TGNetService.GetInstance():SendRequest(request)
  
end
----------------------------------------------------
function ChangeNameAPI:ChangePlayerNameResponseHandler(e)
 
  if e.Type == "RequestChangePlayerName" then
    
    local data = json.decode(e.Content:ToString())
    --Debugger.LogError(data.Result)
    if(data.Result==0)then
      ----Debugger.LogError("失败");
    elseif(data.Result==1)then 
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("修改成功");
    elseif(data.Result==1793)then 
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("缺少1个改名卡");
    elseif(data.Result==1794)then 
      GameManager.CreatePanel("Hint");
      HintAPI.Instance:Hint("缺少1个改名卡");  
    end

    return true;
  else
    return false;
  end
  
end