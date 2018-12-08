--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("BattleHeroDetailCtrl")
--local json = require "cjson"

function BattleHeroDetailCtrl:Awake(this)
  self.this = this
  --添加点击事件
  local listener = {}
  listener = NTGEventTriggerProxy.Get(this.transforms[0].gameObject)--关闭面板
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleHeroDetailCtrl.ClickClosePanel,self)
  listener = NTGEventTriggerProxy.Get(this.transforms[1].gameObject)--属性
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleHeroDetailCtrl.ClickAttrPanel,self)
  listener = NTGEventTriggerProxy.Get(this.transforms[2].gameObject)--技能
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleHeroDetailCtrl.ClickSkillPanel,self)

  self.butAttr = this.transforms[1]
  self.butSkill = this.transforms[2]
  self.panelAttr = this.transforms[3]
  self.panelSkill = this.transforms[4]
  self.gridSkill = self.panelSkill:FindChild("grid")
  self.gridAttr = self.panelAttr:FindChild("grid")
  --属性面板
  self.txtMAck = self.gridAttr:FindChild("matk/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtPAck = self.gridAttr:FindChild("patk/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtHp = self.gridAttr:FindChild("hp/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtMp = self.gridAttr:FindChild("mp/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtPDef = self.gridAttr:FindChild("pdef/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtMDef = self.gridAttr:FindChild("mdef/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtAtkSpeed = self.gridAttr:FindChild("atkspeed/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtCdReduce = self.gridAttr:FindChild("cdreduce/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtCritrate = self.gridAttr:FindChild("critrate/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtMoveSpeed = self.gridAttr:FindChild("movespeed/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtHpRecover = self.gridAttr:FindChild("hprecover/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtMpRecover = self.gridAttr:FindChild("mprecover/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtMAtkBreak = self.gridAttr:FindChild("matkbreak/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtPAtkBreak = self.gridAttr:FindChild("patkbreak/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtPHpSteal = self.gridAttr:FindChild("phpsteal/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtMHpSteal = self.gridAttr:FindChild("mhpsteal/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtAtkRange = self.gridAttr:FindChild("atkrange/attr"):GetComponent("UnityEngine.UI.Text")
  self.txtTough = self.gridAttr:FindChild("tough/attr"):GetComponent("UnityEngine.UI.Text")


  --技能面板
  self.isLoadSkillPanel = false
end

function BattleHeroDetailCtrl:Start()
	
end

function BattleHeroDetailCtrl:Init(roleData,baseAttr,nowAttr)
  self.panelSkill.gameObject:SetActive(false)
  self.panelAttr.gameObject:SetActive(true)
  self.butAttr:FindChild("select").gameObject:SetActive(true)
  self.butSkill:FindChild("select").gameObject:SetActive(false)

	self.roleData = roleData
  self.baseAttr = baseAttr
  self.nowAttr = nowAttr

  self:Init_Attr()
  if self.isLoadSkillPanel then return end
	local bdskilldata = UTGData.Instance().SkillsData[tostring(self.roleData.Skills[5])]
	local skillsdata = {}
	for i=2,4 do
		table.insert(skillsdata,UTGData.Instance().SkillsData[tostring(self.roleData.Skills[i])])
    --Debugger.LogError("id  "..skillsdata[i].Id)
	end
	self:Init_Skill(bdskilldata,skillsdata)
  self.isLoadSkillPanel = true
end

function BattleHeroDetailCtrl:Init_Attr()
  local roleData = self.roleData
  local attr = self.baseAttr
  local nowAttr = self.nowAttr
  self.panelAttr:FindChild("txtname"):GetComponent("UnityEngine.UI.Text").text = roleData.Name
  self.panelAttr:FindChild("txtherotip"):GetComponent("UnityEngine.UI.Text").text = roleData.Tip
  local roleIcon = UTGData.Instance().SkinsData[tostring(roleData.Skin)].Portrait
  self.panelAttr:FindChild("mask/icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("portrait",tostring(roleIcon),"UnityEngine.Sprite")
  --self.panelAttr:FindChild("txtherotip"):GetComponent("UnityEngine.UI.Text").text = ""
 --[[ HP              float64 //生命值
    MP              float64 //法力值
    PAtk            float64 //物理攻击
    MAtk            float64 //法术攻击
    PDef            float64 //物理防御
    MDef            float64 //法术防御
    MoveSpeed       float64 //移动速度
    PpenetrateValue float64 //物理护甲穿透
    PpenetrateRate  float64 //物理护甲穿透率
    MpenetrateValue float64 //法术护甲穿透值
    MpenetrateRate  float64 //法术护甲穿透率
    AtkSpeed        float64 //攻速加成
    CritRate        float64 //暴击几率
    CritEffect      float64 //暴击效果
    PHpSteal        float64 //物理吸血
    MHpSteal        float64 //法术吸血
    CdReduce        float64 //冷却缩减
    Tough           float64 //韧性
    HpRecover5s     float64 //每5s回血
    MpRecover5s     float64 //每5s回蓝
    ]]
    --[[
    public float Hp;
    public float Mp;

    public float HpRecover;
    public float MpRecover;

    public float PAtk;
    public float MAtk;
    public float PDef;
    public float MDef;

    public float PPenetrate;
    public float MPenetrate;
    public float PPenetrateRate;
    public float MPenetrateRate;

    public float Crit;
    public float CritEffect;

    public float PHpSteal;
    public float MHpSteal;

    public float Tough;
    public float AtkSpeed;
    public float CdReduce;
    public float MoveSpeed;
    ]]
  self.txtPAck.text = self:GetCommonAttr(attr.PAtk,nowAttr.PAtk)
  self.txtMAck.text = self:GetCommonAttr(attr.MAtk,nowAttr.MAtk)
  self.txtHp.text = self:GetCommonAttr(attr.HP,nowAttr.Hp)
  self.txtMp.text = self:GetCommonAttr(attr.MP,nowAttr.Mp)
  --  免伤比=1-1/(当前防御/600+1)
  local pDefPercent = 1 - 1/((nowAttr.PDef)/600 + 1)
  local pdpStr  = string.format("|%.1f%%",(pDefPercent*100))
  if (nowAttr.PDef-attr.PDef)>1 then 
    pdpStr = string.format("|<color=#2CFF2CFF>%.1f%%</color>",(pDefPercent*100)) 
  end
  self.txtPDef.text = self:GetCommonAttr(attr.PDef,nowAttr.PDef)..pdpStr

  local mDefPercent = 1 - 1/((nowAttr.MDef)/600 + 1)
  local mdpStr  = string.format("|%.1f%%",(mDefPercent*100))
  if (nowAttr.MDef-attr.MDef)>1 then 
    mdpStr = string.format("|<color=#2CFF2CFF>%.1f%%</color>",(mDefPercent*100))
  end
  self.txtMDef.text = self:GetCommonAttr(attr.MDef,nowAttr.MDef)..mdpStr
  
  self.txtAtkSpeed.text = self:GetCommonAttr(attr.AtkSpeed,nowAttr.AtkSpeed,"percent")
  self.txtCdReduce.text = self:GetCommonAttr(attr.CdReduce,nowAttr.CdReduce,"percent")
  self.txtCritrate.text = self:GetCommonAttr(attr.CritRate,nowAttr.Crit,"percent")

  self.txtMoveSpeed.text = self:GetCommonAttr(attr.MoveSpeed*121,nowAttr.MoveSpeed*121)

  self.txtHpRecover.text = self:GetCommonAttr(attr.HpRecover5s,nowAttr.HpRecover)
  self.txtMpRecover.text = self:GetCommonAttr(attr.MpRecover5s,nowAttr.MpRecover)

  local mrstr = "|0%"
  if attr.MpenetrateRate >0 then mrstr = string.format("|%.1f%%",(attr.MpenetrateRate*100)) end
  self.txtMAtkBreak.text = self:GetCommonAttr(attr.MpenetrateValue,nowAttr.MPenetrate)..mrstr
  local prstr = "|0%"
  if attr.PpenetrateRate >0 then prstr = string.format("|%.1f%%",(attr.PpenetrateRate*100)) end
  self.txtPAtkBreak.text = self:GetCommonAttr(attr.PpenetrateValue,nowAttr.PPenetrate)..prstr

  self.txtPHpSteal.text = self:GetCommonAttr(attr.PHpSteal,nowAttr.PHpSteal,"percent")
  self.txtMHpSteal.text = self:GetCommonAttr(attr.MHpSteal,nowAttr.MHpSteal,"percent")
  local strRange = ""
  if roleData.AtkType == 1 then strRange = "近程" elseif roleData.AtkType == 2 then strRange = "远程" end
  self.txtAtkRange.text = strRange
  self.txtTough.text = self:GetCommonAttr(attr.Tough,nowAttr.Tough,"percent")
end

function BattleHeroDetailCtrl:Init_Skill(bdskilldata,skillsdata)
 	self:ShowSkillUI(bdskilldata,0)
 	for i=1,3 do
 		self:ShowSkillUI(skillsdata[i],i)
 	end
end

function BattleHeroDetailCtrl:ShowSkillUI(data,index)
  local temp = self.gridSkill:GetChild(index)
  --名称
  temp:FindChild("name"):GetComponent("UnityEngine.UI.Text").text = data.Name
  local roleIcon = UTGData.Instance().SkinsData[tostring(self.roleData.Skin)].Portrait
  --图标
  temp:FindChild("icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("skillicon-"..self.roleData.Id,tostring(data.Icon),"UnityEngine.Sprite")
  if index~=0 then
  	--CD MPCost
  	temp:FindChild("cd"):GetComponent("UnityEngine.UI.Text").text = "CD:"..data.Cd.."秒"
  	temp:FindChild("mp"):GetComponent("UnityEngine.UI.Text").text = "法力消耗:"..data.MpCost
  end
  --tag
  local tag = temp:FindChild("tag")
  for i=1,tag.childCount do
    tag:GetChild(i-1).gameObject:SetActive(false)
  end
  for i=1,#data.Tags do
    --Debugger.LogError(" data.tag "..data.Tags[i])
    tag:FindChild(tostring(data.Tags[i])).gameObject:SetActive(true)
  end
  --描述
  local desstr = UTGData.Instance():GetSkillDescByParam(self.roleData.Id,data.Id)
  temp:FindChild("des"):GetComponent("UnityEngine.UI.Text").text = desstr
end

function BattleHeroDetailCtrl:GetCommonAttr(attr,nowattr,showtype)

  --Debugger.LogError("base = "..attr.." now = "..nowattr)
	showtype = showtype or "common"
	local str = ""
  local addattr = nowattr-attr
	if addattr>0.01 and showtype == "common" then
		str = string.format("<color=#2CFF2CFF>%d</color>(%d+<color=#2CFF2CFF>%d</color>)",attr+addattr,attr,addattr)
	elseif addattr>0 and showtype== "percent" then
		str = string.format("<color=#2CFF2CFF>%.1f%%</color>",(nowattr*100))
	elseif addattr<=0 and showtype== "percent" then
    if attr==0 then str = "0%" 
		else str =string.format("%.1f%%",(attr*100)) end
	elseif addattr<=0.01 and showtype== "common" then
		str = string.format("%d",attr)
	end
	return str
end

--属性面板
function BattleHeroDetailCtrl:ClickAttrPanel()
  if self.butAttr:FindChild("select").gameObject.activeSelf then 
  	return
  else 
  	self.butAttr:FindChild("select").gameObject:SetActive(true)
  	self.butSkill:FindChild("select").gameObject:SetActive(false)
  end
  self.panelAttr.gameObject:SetActive(true)
  self.panelSkill.gameObject:SetActive(false)
end
--技能面板
function BattleHeroDetailCtrl:ClickSkillPanel()
  if self.butSkill:FindChild("select").gameObject.activeSelf then 
  	return
  else 
  	self.butSkill:FindChild("select").gameObject:SetActive(true)
	self.butAttr:FindChild("select").gameObject:SetActive(false)
  end
  self.panelSkill.gameObject:SetActive(true)
  self.panelAttr.gameObject:SetActive(false)
end

--关闭面板
function BattleHeroDetailCtrl:ClickClosePanel()
  BattleHeroDetailAPI.Instance:HideUI() --Object.Destroy(self.this.gameObject)
end

function BattleHeroDetailCtrl:OnDestroy()
  self.this = nil
  self = nil
end