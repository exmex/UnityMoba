--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("PlayerSkillAPI")
--local json = require "cjson"

function PlayerSkillAPI:Awake(this)
  self.this = this

  self.root = this.transforms[0]
  self.topinfo = this.transforms[1]
  self.txtLv = self.topinfo:FindChild("lv"):GetComponent("UnityEngine.UI.Text")
  self.grid = self.root:FindChild("left/grid")
  self.info = self.root:FindChild("right")
  self.playerSkillData = {}
  self.playerSkillDeck = {}
  
  --上方资源条
  self.NormalResourcePanel = GameManager.CreatePanel("NormalResource")
end

function PlayerSkillAPI:Start()
  
  --临时添加等待
  if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end  

  if UTGDataOperator.Instance.skillNotice then 
    UTGDataOperator.Instance:WriteFile("PlayerSkillNotice.ini",{RedPoint = false})
    UTGDataOperator.Instance.skillNotice = false
    --Debugger.LogError("1111111111")
  end
  self:ResetPanel()

  self:Init()
end

function PlayerSkillAPI:ResetPanel( )
  local topAPI = self.NormalResourcePanel.gameObject:GetComponent("NTGLuaScript").self
  topAPI:GoToPosition("PlayerSkillPanel")
  topAPI:ShowControl(3)--全要
  topAPI:InitResource(0)
  topAPI:InitTop(self,PlayerSkillAPI.ClickClosePanel,nil,nil,"技能")
  topAPI:HideSom("Text")
  UTGDataOperator.Instance:SetResourceList(topAPI)
  
  self.topinfo:SetParent(self.this.transform)
end

function PlayerSkillAPI:Init()
	self.playerLv = UTGData.Instance().PlayerData.Level
	self.txtLv.text = "当前等级Lv."..self.playerLv
	for k,v in pairs(UTGData.Instance().PlayerSkillDeckIds) do
		table.insert(self.playerSkillDeck,UTGData.Instance().PlayerSkillData[tostring(v)])
	end
	for k,v in pairs(UTGData.Instance().PlayerSkillData) do
		table.insert(self.playerSkillData,v)
	end
	local function sortfunc(a,b)
		return a.Id < b.Id
	end 
	table.sort(self.playerSkillData, sortfunc )
	--Debugger.LogError("xxxxxxxxxxxx  "..#self.playerSkillData)
	--table.remove(self.playerSkillDeck,10)

	self.skilllisAPI = self.grid:GetComponent("NTGLuaScript").self
	self:FillSkillLis(self.playerSkillData)
end
--[[
Id           int
    SkillId      int    //技能ID
    OpenLevel    int    //开启等级
    Icon         string //技能图标
    Illustration string //技能说明图
]]
--生成技能列表
function PlayerSkillAPI:FillSkillLis(data)
  local api = self.skilllisAPI
  if data==nil then
    api:ResetItemsSimple(0)
    Debugger.LogError("没有技能数据")
    return
  end
  api:ResetItemsSimple(#data)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform
    tempo.name = tostring(i)
    local skilldata = UTGData.Instance().SkillsData[tostring(data[i].SkillId)] 
    if self:IsOwnSkill(data[i]) then --已经拥有
   	    tempo:FindChild("icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",tostring(skilldata.Icon),"UnityEngine.Sprite")
    	tempo:FindChild("name"):GetComponent("UnityEngine.UI.Text").text = tostring(skilldata.Name)
   	else 
   		tempo:FindChild("lock").gameObject:SetActive(true)
      tempo:FindChild("icon").gameObject:SetActive(false)
   		tempo:FindChild("icon_lock").gameObject:SetActive(true)
   		tempo:FindChild("icon_lock"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",tostring(skilldata.Icon),"UnityEngine.Sprite")
    	tempo:FindChild("lock/name"):GetComponent("UnityEngine.UI.Text").text = tostring(skilldata.Name)
    	tempo:FindChild("lock/openlevel"):GetComponent("UnityEngine.UI.Text").text = string.format("<size=27>%d</size>级解锁",data[i].OpenLevel)
   	end
	 
    local listener = NTGEventTriggerProxy.Get(tempo:FindChild("click").gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(PlayerSkillAPI.ClickSelectSkill,self)
    if i==1 then tempo:FindChild("select").gameObject:SetActive(true) end
  end
  --默认选择第一个技能
  self:ShowSelectSkillDes(self.playerSkillData[1])
end

--判断技能是否已拥有
function PlayerSkillAPI:IsOwnSkill(data)
	for k,v in pairs(self.playerSkillDeck) do
		if v.Id == data.Id then return true end
	end
	return false
end

--选择技能icon查看详情
function PlayerSkillAPI:ClickSelectSkill(eventdata)
  local current = eventdata.pointerPress.transform.parent
  if current:FindChild("select").gameObject.activeSelf then
    return
  end
  local temp = self.grid
  local index = tonumber(current.name)
  for i=1 ,temp.childCount do
    temp:GetChild(i-1):FindChild("select").gameObject:SetActive(false)
  end
  temp:GetChild(index):FindChild("select").gameObject:SetActive(true)

  self:ShowSelectSkillDes(self.playerSkillData[index])

end
--显示技能详情
function PlayerSkillAPI:ShowSelectSkillDes(data)
  --print(data.Illustration)
	local tempo = self.info
	local skilldata = UTGData.Instance().SkillsData[tostring(data.SkillId)] 
	tempo:FindChild("icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",tostring(skilldata.Icon),"UnityEngine.Sprite")	
	tempo:FindChild("desimg"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("PlayerSkillIllustration",tostring(data.Illustration),"UnityEngine.Sprite")
	tempo:FindChild("name_big"):GetComponent("UnityEngine.UI.Text").text = tostring(skilldata.Name)
	tempo:FindChild("des"):GetComponent("UnityEngine.UI.Text").text = tostring(skilldata.Desc)
	tempo:FindChild("name_small_lock").gameObject:SetActive(false)
	tempo:FindChild("name_small").gameObject:SetActive(false)
	if self:IsOwnSkill(data) then --拥有
		tempo:FindChild("name_small").gameObject:SetActive(true)
		tempo:FindChild("name_small"):GetComponent("UnityEngine.UI.Text").text = tostring(skilldata.Name)
		tempo:FindChild("status"):GetComponent("UnityEngine.UI.Text").text = "已解锁"
	else
		tempo:FindChild("name_small_lock").gameObject:SetActive(true)
		tempo:FindChild("name_small_lock"):GetComponent("UnityEngine.UI.Text").text = tostring(skilldata.Name)
		tempo:FindChild("status"):GetComponent("UnityEngine.UI.Text").text = string.format("<size=27>%d</size>级解锁",data.OpenLevel)
	end
end

function PlayerSkillAPI:ClickClosePanel( )

  UTGDataOperator.Instance:SetPreUIRight(self.this.transform)
	Object.Destroy(self.this.gameObject)
--	if(UTGMainPanelAPI~=nil)then
--        UTGMainPanelAPI.Instance:ShowSelf()
--    end
end

function PlayerSkillAPI:OnDestroy()

  self.this = nil
  self = nil
end