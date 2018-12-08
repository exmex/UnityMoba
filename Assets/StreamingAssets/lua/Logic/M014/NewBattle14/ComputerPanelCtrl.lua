require "System.Global"

class("ComputerPanelCtrl")

function ComputerPanelCtrl:Awake(this) 
  self.this = this
  ComputerPanelCtrl.Instance = self;
  self.newBattle14Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")

  self.btn1V1 = self.this.transforms[1]
  self.btn3V3 = self.this.transforms[2]
  self.btn5V5 = self.this.transforms[3]
  self.btn5V5LuanDou = self.this.transforms[4]
  self.selectBtns = self.this.transforms[5]
  self.ruMenBtn = self.this.transforms[6]
  self.jianDanBtn = self.this.transforms[7]
  self.yiBanBtn = self.this.transforms[8]
end

function ComputerPanelCtrl:Start()


  self:Init()
end
function ComputerPanelCtrl:Reset()
  
  if( self.btns==nil)then return end 
            for k,v in pairs(self.btns) do
    v.gameObject:GetComponent("Image").raycastTarget=true;
  end
  
end
function ComputerPanelCtrl:Init()
  
  UITools.GetLuaScript(self.btn1V1.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn1V1Click) 
  UITools.GetLuaScript(self.btn3V3.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn3V3Click) 
  UITools.GetLuaScript(self.btn5V5.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn5V5Click) 
  UITools.GetLuaScript(self.btn5V5LuanDou.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn5V5LuanDouClick) 
  

  self.btns = {self.ruMenBtn,self.jianDanBtn,self.yiBanBtn}
  self:AddBtnsClickEvent(btns)

end

--创建party
function ComputerPanelCtrl:CreateParty(mapName, playerCount, subTypeCode,diff)
  local mainType = 3 --人机练习
  local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("NewBattle15")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
            NewBattle15API.Instance:CreateParty(mapName, playerCount, subTypeCode,mainType,diff)


          end
        end
  coroutine.start( CreatePanelAsync,self)
end

function ComputerPanelCtrl:BtnClick(eventdata)
  for k,v in pairs(self.btns) do
    v.gameObject:GetComponent("Image").raycastTarget=false;
  end
  local temp = UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject.transform
  local temp_diff = temp.name
  local temp_mode = temp.parent.parent.name
  local diff = 0
  local modeType = 0
  local playerCount = 0
  local mapName = ""
  if temp_mode =="1V1" then 
    modeType = 10
    playerCount = 1
    mapName = "红枫桥门"
  elseif temp_mode =="3V3"  then 
    modeType = 30
    playerCount = 3
    mapName = "拉法叶公路"
  elseif temp_mode =="5V5"  then 
    modeType = 50
    playerCount = 5
    mapName = "战争岛屿"
  elseif temp_mode =="5V5LuanDou"  then 
    modeType = 51 
    playerCount = 5
    mapName = "战争岛屿"
  end
  if temp_diff == "RuMen" then diff = 1
  elseif temp_diff == "JianDan" then diff = 2
  elseif temp_diff == "YiBan" then diff = 3 end
    
  self:CreateParty(mapName,playerCount,modeType,diff)
end


function ComputerPanelCtrl:AddBtnsClickEvent()
  local listener
  for k,v in pairs(self.btns) do
    self:AddPointerClickEvent(v.gameObject, ComputerPanelCtrl.BtnClick)
  end
end

function ComputerPanelCtrl:AddPointerClickEvent(go, func)
  local listener = NTGEventTriggerProxy.Get(go)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( func,self)
end

function ComputerPanelCtrl:OnBtn1V1Click()
  --self.btn1V1:GetComponent("Image").raycastTarget=false;
  UTGDataOperator.Instance.battleMode=2;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  self.selectBtns.transform:SetParent(self.btn1V1.transform.parent)
  self.selectBtns.transform.localPosition = Vector3.zero
  self.selectBtns.gameObject:SetActive(true)
end

function ComputerPanelCtrl:OnBtn3V3Click()
  --self.btn3V3:GetComponent("Image").raycastTarget=false;
  UTGDataOperator.Instance.battleMode=2;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  self.selectBtns.transform:SetParent(self.btn3V3.transform.parent)
  self.selectBtns.transform.localPosition = Vector3.zero
  self.selectBtns.gameObject:SetActive(true)
end

function ComputerPanelCtrl:OnBtn5V5Click()
  --self.btn5V5:GetComponent("Image").raycastTarget=false;
  UTGDataOperator.Instance.battleMode=2;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  self.selectBtns.transform:SetParent(self.btn5V5.transform.parent)
  self.selectBtns.transform.localPosition = Vector3.zero
  self.selectBtns.gameObject:SetActive(true)
end

function ComputerPanelCtrl:OnBtn5V5LuanDouClick()
  --self.btn5V5LuanDou:GetComponent("Image").raycastTarget=false;
  UTGDataOperator.Instance.battleMode=2;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  self.selectBtns.transform:SetParent(self.btn5V5LuanDou.transform.parent)
  self.selectBtns.transform.localPosition = Vector3.zero
  self.selectBtns.gameObject:SetActive(true)
end




function ComputerPanelCtrl:OnEnable()
  self.barCount = 0
  self.btn1V1.gameObject:SetActive(true)
end

function ComputerPanelCtrl:BarMoveOK()
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

function ComputerPanelCtrl:OnDestroy()
  ComputerPanelCtrl.Instance = nil;
  self.this = nil
  self = nil
end
  