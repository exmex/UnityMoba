--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("PVPPlayerSkillSelectCtrl")
local json = require "cjson"

function PVPPlayerSkillSelectCtrl:Awake(this)
  self.this = this
  --选定召唤师技能
  local listener = NTGEventTriggerProxy.Get(this.transforms[0].gameObject)--选定
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(PVPPlayerSkillSelectCtrl.ClickSelectSkillOK,self) 
  --关闭面板事件
  listener = NTGEventTriggerProxy.Get(this.transforms[4].gameObject)--英雄按钮
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(PVPPlayerSkillSelectCtrl.ClickClosePanel,self) 
  self.root = this.transforms[3]
  self.skilldes = this.transforms[1]:GetComponent("UnityEngine.UI.Text")
  self.root.gameObject:SetActive(false)
  self.playerSkillDeck = {}
end

function PVPPlayerSkillSelectCtrl:Start()

end

--初始化界面
function PVPPlayerSkillSelectCtrl:Init(currentId)
  self.currentId = currentId
  self.root.gameObject:SetActive(true)
  for k,v in pairs(UTGData.Instance().PlayerSkillDeckIds) do
    table.insert(self.playerSkillDeck,UTGData.Instance().PlayerSkillData[tostring(v)])
  end
  local function sortfunc(a,b)
    return a.Id < b.Id
  end 
  table.sort(self.playerSkillDeck, sortfunc )

  self.skilllisAPI = self.this.transforms[2]:GetComponent("NTGLuaScript").self
  self:FillSkillLis(self.playerSkillDeck)
end

--生成技能lis
function PVPPlayerSkillSelectCtrl:FillSkillLis(data)
  local api = self.skilllisAPI
  if data==nil then
    api:ResetItemsSimple(0)
    Debugger.LogError("没有召唤师数据")
    return
  end
  api:ResetItemsSimple(#data)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform
    tempo.name = tostring(i)
    local skilldata = UTGData.Instance().SkillsData[tostring(data[i].SkillId)] 
    tempo:FindChild("icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("playerskillicon",tostring(skilldata.Icon),"UnityEngine.Sprite")
    tempo:FindChild("name"):GetComponent("UnityEngine.UI.Text").text = tostring(skilldata.Name)
    
    local listener = NTGEventTriggerProxy.Get(tempo.gameObject)
    listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(PVPPlayerSkillSelectCtrl.ClickSelectSkill,self)
    
    if self.currentId == data[i].SkillId then
      tempo:FindChild("select").gameObject:SetActive(true)
      self.selectskill = UTGData.Instance().SkillsData[tostring(data[i].SkillId)]
      self.selectplayerskill = data[i]
    end
  end

  --选择当前技能
  self:ShowSelectSkillDes(self.selectskill)
end

--选择召唤师技能
function PVPPlayerSkillSelectCtrl:ClickSelectSkill(eventdata)
  if eventdata.pointerPress.transform:FindChild("select").gameObject.activeSelf then
    return
  end
  local temp = eventdata.pointerPress.transform.parent
  local index = tonumber(eventdata.pointerPress.name)
  for i=1 ,temp.childCount do
    temp:GetChild(i-1):FindChild("select").gameObject:SetActive(false)
  end
  temp:GetChild(index):FindChild("select").gameObject:SetActive(true)
  self.selectskill = UTGData.Instance().SkillsData[tostring(self.playerSkillDeck[index].SkillId)]
  self.selectplayerskill = self.playerSkillDeck[index]
  self:ShowSelectSkillDes(self.selectskill)

end
--显示技能信息
function PVPPlayerSkillSelectCtrl:ShowSelectSkillDes(data)
  if data ==nil then
    return
  end
  self.skilldes.text = data.Desc
end

--选定
function PVPPlayerSkillSelectCtrl:ClickSelectSkillOK()
  if self.selectplayerskill ==nil then
    Debugger.LogError("selectplayerskill 没有召唤师数据")
    return
  end
  local skilldata = UTGData.Instance().SkillsData[tostring(self.selectplayerskill.SkillId)]
  if PVPHeroSelectAPI~=nil and PVPHeroSelectAPI.Instance~=nil then 
    PVPHeroSelectAPI.Instance:SetPlayerSkillBy20(skilldata)
  end
  if DraftHeroSelectAPI~=nil and DraftHeroSelectAPI.Instance~=nil then 
    DraftHeroSelectAPI.Instance:SetPlayerSkillBy20(skilldata)
  end

  self:ClickClosePanel()
end
--关闭面板
function PVPPlayerSkillSelectCtrl:ClickClosePanel()
  Object.Destroy(self.this.transform.parent.gameObject)
end
function PVPPlayerSkillSelectCtrl:OnDestroy()
  self.this = nil
  self = nil
end