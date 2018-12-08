require "System.Global"

class("NewBattle14Ctrl")

function NewBattle14Ctrl:Awake(this) 
  self.this = this
  self.pvpPanelCtrl = this.transforms[0]:GetComponent("NTGLuaScript")
  self.computerPanelCtrl = this.transforms[1]:GetComponent("NTGLuaScript")
  self.roomPanelCtrl = this.transforms[2]:GetComponent("NTGLuaScript")
  self.entPanelCtrl = this.transforms[3]:GetComponent("NTGLuaScript")
end

function NewBattle14Ctrl:Start()
  self:Init()
end

function NewBattle14Ctrl:Init()
  ----------------排位入口测试--------------
  self.Grid1=self.this.transform:FindChild("TestButtons/Button1").gameObject;
  self.Grid2=self.this.transform:FindChild("TestButtons/Button2").gameObject;
  self.Grid5=self.this.transform:FindChild("TestButtons/Button5").gameObject;
  local listener = NTGEventTriggerProxy.Get(self.Grid1.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(
    function ()
      self:CreateParty("战争岛屿", 1, 61)
    end
    ,self 
    )
  listener = NTGEventTriggerProxy.Get(self.Grid2.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(
    function ()
      self:CreateParty("战争岛屿", 2, 62)
    end
    ,self 
    )
  listener = NTGEventTriggerProxy.Get(self.Grid5.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(
    function ()
      self:CreateParty("战争岛屿", 5, 65)
    end
    ,self 
    )
  -------------------------------------------
end

------------------排位入口测试-----------------------------------------------
--创建party
function NewBattle14Ctrl:CreateParty(mapName, playerCount, subTypeCode)
  local mainType = 5 -- 实时对战
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
--------------------------------------------------------------------------------
function NewBattle14Ctrl:DestroySelf()
  Object.Destroy(self.this.transform.parent.gameObject)
end

function NewBattle14Ctrl:ShowPVPPanel()
  self.pvpPanelCtrl.gameObject:SetActive(true)
  self.computerPanelCtrl.gameObject:SetActive(false)
  self.roomPanelCtrl.gameObject:SetActive(false)
  self.entPanelCtrl.gameObject:SetActive(false)
end

function NewBattle14Ctrl:ShowComputerPanel()
  self.pvpPanelCtrl.gameObject:SetActive(false)
  self.computerPanelCtrl.gameObject:SetActive(true)
  self.roomPanelCtrl.gameObject:SetActive(false)
  self.entPanelCtrl.gameObject:SetActive(false)
end

function NewBattle14Ctrl:ShowRoomPanel()
  self.pvpPanelCtrl.gameObject:SetActive(false)
  self.computerPanelCtrl.gameObject:SetActive(false)
  self.roomPanelCtrl.gameObject:SetActive(true)
  self.entPanelCtrl.gameObject:SetActive(false)
end

function NewBattle14Ctrl:ShowEntPanel()
  self.pvpPanelCtrl.gameObject:SetActive(false)
  self.computerPanelCtrl.gameObject:SetActive(false)
  self.roomPanelCtrl.gameObject:SetActive(false)
  self.entPanelCtrl.gameObject:SetActive(true)
  self.entPanelCtrl.self:Init()
end


function NewBattle14Ctrl:OnDestroy()
  self.this = nil
  self = nil
  --NTGResourceController.Instance:UnloadAssetBundle("newbattle14",true)
end