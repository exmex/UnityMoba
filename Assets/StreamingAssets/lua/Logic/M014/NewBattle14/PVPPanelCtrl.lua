require "System.Global"

class("PVPPanelCtrl")

function PVPPanelCtrl:Awake(this) 
  self.this = this
  PVPPanelCtrl.Instance = self;
  self.newBattle14Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
  self.btn1V1 = self.this.transforms[1]
  self.btn3V3 = self.this.transforms[2]
  self.btn5V5 = self.this.transforms[3]
  self.btn5V5LuanDou = self.this.transforms[4]
end

function PVPPanelCtrl:Start()


  self:Init()
end

function PVPPanelCtrl:Reset()
  
            self.btn1V1:GetComponent("Image").raycastTarget=true;
            self.btn3V3:GetComponent("Image").raycastTarget=true;
            self.btn3V3:GetComponent("Image").raycastTarget=true;
            self.btn5V5LuanDou:GetComponent("Image").raycastTarget=true;
end

function PVPPanelCtrl:Init()
  
  UITools.GetLuaScript(self.btn1V1.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn1V1Click) 
  UITools.GetLuaScript(self.btn3V3.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn3V3Click) 
  UITools.GetLuaScript(self.btn5V5.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn5V5Click) 
  UITools.GetLuaScript(self.btn5V5LuanDou.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn5V5LuanDouClick) 

end

--创建party
function PVPPanelCtrl:CreateParty(mapName, playerCount, subTypeCode)
  local mainType = 1 -- 实时对战
  local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("NewBattle15")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
            NewBattle15API.Instance:CreateParty(mapName, playerCount, subTypeCode,mainType)

            

          end
        end
  coroutine.start( CreatePanelAsync,self)
end

function PVPPanelCtrl:OnBtn1V1Click()
  self.btn1V1:GetComponent("Image").raycastTarget=false;
  UTGDataOperator.Instance.battleMode=0;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  self:CreateParty("红枫桥门", 1, 10)
end

function PVPPanelCtrl:OnBtn3V3Click()
  self.btn3V3:GetComponent("Image").raycastTarget=false;
  UTGDataOperator.Instance.battleMode=0;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  self:CreateParty("长平攻防战", 3, 30)
end

function PVPPanelCtrl:OnBtn5V5Click()
  self.btn3V3:GetComponent("Image").raycastTarget=false;
  UTGDataOperator.Instance.battleMode=0;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  self:CreateParty("战争岛屿", 5, 50)
end

function PVPPanelCtrl:OnBtn5V5LuanDouClick()
  self.btn5V5LuanDou:GetComponent("Image").raycastTarget=false;
  UTGDataOperator.Instance.battleMode=0;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  self:CreateParty("长平攻防战", 5, 51)
end

function PVPPanelCtrl:OnEnable()
  self.barCount = 0
  self.btn1V1.gameObject:SetActive(true)
end

function PVPPanelCtrl:BarMoveOK()
  self.barCount = self.barCount + 1
  if self.barCount == 1 then
    self.btn3V3.gameObject:SetActive(true)
    return
  end
  if self.barCount == 2 then
    self.btn5V5.gameObject:SetActive(true)
    return
  end
  if self.barCount == 3 then
    self.btn5V5LuanDou.gameObject:SetActive(true)
    self.barCount = -1
    return
  end
end

function PVPPanelCtrl:OnDestroy()
  PVPPanelCtrl.Instance = nil;
  self.this = nil
  self = nil
end
  