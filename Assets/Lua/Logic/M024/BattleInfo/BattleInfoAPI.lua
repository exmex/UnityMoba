require "System.Global"

class("BattleInfoAPI")


local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"


--[[
data结构
string		SkinId
string 		PlayerName
number		ZSkillId
number		Level
number		DeadCount
number		CDCount
number		Kill
number      Dead
number		Assistant
number		Money
number		Hp
number		PAtk
number		MAtk
number		PDef
number		MDef
int[]		Equips
]]


function  BattleInfoAPI:Awake(this)
	-- body
	self.this = this
	self.battleInfoControl = self.this.transforms[0]:GetComponent("NTGLuaScript")
	self.button = self.this.transforms[1]
	BattleInfoAPI.Instance = self

  local listener = NTGEventTriggerProxy.Get(self.button.gameObject)
  local callback1 = function(self, e)
    self:OpenControl()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)

end

function BattleInfoAPI:UpdateData(dataSelf,dataEnemy)
	-- body
	self.battleInfoControl.self:CurrentData(dataSelf,dataEnemy)
end

function BattleInfoAPI:OpenControl()
	-- body
	self.battleInfoControl.self:DoOpenControl()
end

function BattleInfoAPI:OpenPanelReceiveData(delegate)
	-- body
	self.battleInfoControl.self:OpenPanelReceiveData(delegate)
end

function BattleInfoAPI:ClosePanelDontReceive(delegate)
	-- body
	self.battleInfoControl.self:ClosePanelDontReceive(delegate)
	self.this.transform.gameObject:SetActive(false)
end



function BattleInfoAPI:OnDestroy()
	-- body
	self.this = nil
	self = nil
	BattleInfoAPI.Instance = nil
end