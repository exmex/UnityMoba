--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
--require "Logic.UICommon.Static.UITools"
class("BattleHeroDetailAPI")
--local json = require "cjson"

function BattleHeroDetailAPI:Awake(this)
  self.this = this
  BattleHeroDetailAPI.Instance = self
  self.rootPanel = this.transforms[0].parent

  self.level = -1
 end

function BattleHeroDetailAPI:Start()
  self.ctrl = self.this.gameObject:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[1]
  self.rootPanel.gameObject:SetActive(false)
end


--更新数据 param： roleId，基础属性，加成属性
function BattleHeroDetailAPI:UpdateData(roleId,level,nowAttr)
  if self.roleData ==nil then
    self.roleData = UTGData.Instance().RolesData[tostring(roleId)]
    self.baseGrowAttr = UTGData.Instance().PVPRoleGrowsData[tostring(roleId)]
  end
  if self.level ~=tonumber(level) then  
    self.baseAttr = {}
    --Debugger.LogError(" level = "..level)
    for k,v in pairs(self.baseGrowAttr) do
      self.baseAttr[k] = v*tonumber(level-1)
    end
    self.baseAttr.RoleId = nil
    self.baseAttr.Id = nil
    for k,v in pairs(self.baseAttr) do
      -- Debugger.LogError(" baseAttr k = "..k.." v = "..v)
      if self.roleData[k]~=nil then
       -- Debugger.LogError("self.roleData[k]= "..self.roleData[k])
        self.baseAttr[k] = self.baseAttr[k]+ self.roleData[k]
      end
    end  
  end
  self.level = level
  self.nowAttr = nowAttr
end

--显示UI
function BattleHeroDetailAPI:ShowUI()
	self.rootPanel.gameObject:SetActive(true)
	if self.roleData==nil or self.baseAttr==nil or self.nowAttr==nil then
		Debugger.LogError("数据有nil 有问题呀~~~~~~~~~~~~")
	end

	self.ctrl.self:Init(self.roleData,self.baseAttr,self.nowAttr)
end

--隐藏UI
function BattleHeroDetailAPI:HideUI( )
	self.rootPanel.gameObject:SetActive(false)
end

function BattleHeroDetailAPI:OnDestroy()
  self.this = nil
  self = nil
  BattleHeroDetailAPI.Instance = nil
end