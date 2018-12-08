require "System.Global"

class("RoomPanelCtrl")

function RoomPanelCtrl:Awake(this) 
  self.this = this
  self.newBattle14Ctrl = this.transforms[0]:GetComponent("NTGLuaScript")
  self.btn1V1 = self.this.transforms[1]
  self.btn3V3 = self.this.transforms[2]
  self.btn5V5ZhengZhao = self.this.transforms[3]
  self.btn5V5 = self.this.transforms[4]
  self.btn5V5LuanDou = self.this.transforms[5]
end

function RoomPanelCtrl:Start()


  self:Init()
end

function RoomPanelCtrl:Init()
  
  UITools.GetLuaScript(self.btn1V1.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn1V1Click) 
  UITools.GetLuaScript(self.btn3V3.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn3V3Click) 
  UITools.GetLuaScript(self.btn5V5ZhengZhao.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn5V5ZhengZhaoClick) 
  UITools.GetLuaScript(self.btn5V5.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn5V5Click) 
  UITools.GetLuaScript(self.btn5V5LuanDou.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.OnBtn5V5LuanDouClick) 
  

end

function RoomPanelCtrl:OnBtn1V1Click()
  UTGDataOperator.Instance.battleMode=3;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("NewBattle15")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
            NewBattle15API.Instance:CreateRoom("红枫桥门", 1, 10)
          end
        end
  coroutine.start( CreatePanelAsync,self)
end

function RoomPanelCtrl:OnBtn3V3Click()
  UTGDataOperator.Instance.battleMode=3;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("NewBattle15")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
            NewBattle15API.Instance:CreateRoom("长平攻防战", 3, 30)
          end
        end
  coroutine.start( CreatePanelAsync,self)
end

function RoomPanelCtrl:OnBtn5V5ZhengZhaoClick()
  GameManager.CreatePanel("SelfHideNotice")
  SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("功能正在开发中，敬请期待~")
  return
  --[[
  local roleCount = #UTGData.Instance():GetOwnRoleData()
  --Debugger.LogError(roleCount)
  if roleCount<12 then 
    GameManager.CreatePanel("SelfHideNotice")
    SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("无法加入房间：该模式需要可用姬神数量不少于12个")
    return
  end
  UTGDataOperator.Instance.battleMode=3;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("NewBattle15")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
            NewBattle15API.Instance:CreateRoom("战争岛屿", 5, 52)
          end
        end
  coroutine.start( CreatePanelAsync,self)
  ]]
end

function RoomPanelCtrl:OnBtn5V5Click()
  UTGDataOperator.Instance.battleMode=3;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  --self.newBattle14Ctrl.self:DestroySelf()
  local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("NewBattle15")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
             NewBattle15API.Instance:CreateRoom("战争岛屿", 5, 50)
          end
        end
  coroutine.start( CreatePanelAsync,self)
end

function RoomPanelCtrl:OnBtn5V5LuanDouClick()
  UTGDataOperator.Instance.battleMode=3;  --0：实时对战  1：娱乐模式  2：人机练习  3：开房间
  --self.newBattle14Ctrl.self:DestroySelf()
  local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("NewBattle15")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if NewBattle15API ~= nil and NewBattle15API.Instance ~= nil then
            NewBattle15API.Instance:CreateRoom("长平攻防战", 5, 51)
          end
        end
  coroutine.start( CreatePanelAsync,self)
end

function RoomPanelCtrl:OnEnable()
  self.barCount = 0
  self.btn1V1.gameObject:SetActive(true)
end

function RoomPanelCtrl:BarMoveOK()
  self.barCount = self.barCount + 1
  if self.barCount == 1 then
    self.btn3V3.gameObject:SetActive(true)
    return
  end
  if self.barCount == 2 then
    self.btn5V5ZhengZhao.gameObject:SetActive(true)
    return
  end
  if self.barCount == 3 then
    self.btn5V5.gameObject:SetActive(true)
    return
  end
  if self.barCount == 4 then
    self.btn5V5LuanDou.gameObject:SetActive(true)
    self.barCount = -1
    return
  end
end

function RoomPanelCtrl:OnDestroy()
  self.this = nil
  self = nil
end
  