--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("BattleResult28Ctrl")
--local json = require "cjson"

function BattleResult28Ctrl:Awake(this)
  self.this = this
  self.root = this.transforms[0]
  self.playerRoot = this.transforms[1]
  self.coinRoot = this.transforms[2]
  self.roleRoot = this.transforms[3]
  self.levelRoot = this.transforms[4]
  self.topRoot = this.transforms[5]
  self.tip_exp = this.transforms[7]
  self.tip_coin = this.transforms[8]
  self.tip_exp_tip = self.tip_exp:FindChild("tip")
  self.tip_coin_tip = self.tip_coin:FindChild("tip")

  self.tip_exp.gameObject:SetActive(false)
  self.tip_coin.gameObject:SetActive(false)
  self.tip_exp_tip.gameObject:SetActive(false)
  self.tip_coin_tip.gameObject:SetActive(false)

  local listener = {}
  listener = NTGEventTriggerProxy.Get(this.transforms[6].gameObject)--继续
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult28Ctrl.ClickTo29Panel,self)
  self.root.gameObject:SetActive(false)
  self.roleRoot.gameObject:SetActive(false)
end

function BattleResult28Ctrl:Start()

end
--初始化
function BattleResult28Ctrl:Init(data)
    local isWin = false
    if data.isWin == 1 then isWin = true end

    self:Init_Top(data.isWin)
    if data.mianType == 5 then --排位赛
      local preGrade = UTGDataOperator.Instance.PrePlayerGrade
      local nowGrade = UTGData.Instance().PlayerGradeDeck
      local preGredeId = preGrade.Grade --之前段位id
      local preWinningCount = preGrade.GradeWinningCount or 0 --之前连胜
      
      local nowGradeName = nowGrade.Title --现在段位名称
      local nowGradeStar = nowGrade.Stars --现在段位星
      local isMaxGrade = false
      if nowGrade.MaxStars == 0 then isMaxGrade = true end
      --[[
      for k,v in pairs(preGrade) do
        Debugger.LogError(k.."  preGrade "..tostring(v))
      end

      for k,v in pairs(nowGrade) do
        Debugger.LogError(k.." "..tostring(v))
      end
]]
      self:Init_RankInfo(nowGradeName,nowGradeStar,isMaxGrade)
      self:Init_RankChangePanel(isWin,preGrade,nowGrade)

    else
      self:Init_Level(data.modeName,data.mapName)
    end

    self:Init_Player(data.playerName,data.playerIcon,data.player_nexLv,data.player_nexExp,data.player_addExp,data.player_firstAdd)
    self:Init_Coin(data.coin_add,data.coin_first)
    if data.roleId>0 then 
      self.roleRoot.gameObject:SetActive(true)
      self:Init_Role(data.roleId,data.role_addExp)
    end

    local playerData = UTGData.Instance().PlayerData
    --经验加成  
    for k,v in pairs(data.expAdd) do
      if v[1]==1 then --经验卡
        local alladd = tonumber(v[2])
        if alladd > 0 then
          local addCard = alladd
          local remainVic = tonumber(playerData.WinDoubleExpLeftChance)
          local remainDou = 0
          local tempLeft = UTGData.Instance():GetLeftTime(playerData.DoubleExpEndTime)
          if tempLeft > 0 then remainDou = os.date("%j",tempLeft) end
          self:Init_Tip_Exp(alladd,addCard,remainVic,remainDou)   
        end
      end
    end 
    --金币加成
    local addCard = 0
    local addGuild = 0
    local addAll = 0
    local remainVic = tonumber(playerData.WinDoubleCoinLeftChance)
    local remainDou = 0
    local tempLeft = UTGData.Instance():GetLeftTime(playerData.DoubleCoinEndTime)
    if tempLeft > 0 then remainDou = os.date("%j",tempLeft) end

    for k,v in pairs(data.coinAdd) do
      if v[1]==1 then 
        addCard = tonumber(v[2])
      elseif v[1] ==2 then 
      elseif v[1] ==3 then 
        addGuild = tonumber(v[2])
      end
    end 
    addAll = addCard+addGuild
    if addAll>0 then
      self:Init_Tip_Coin(addAll,addCard,addGuild,remainVic,remainDou)   
    end
    self.root.gameObject:SetActive(true)
end

--显示top
function BattleResult28Ctrl:Init_Top(isVic)
  if isVic == 1 then 
    self.topRoot:FindChild("1").gameObject:SetActive(true)
  else
    self.topRoot:FindChild("0").gameObject:SetActive(true)
  end
end

--显示关卡信息
function BattleResult28Ctrl:Init_Level(mode,name)
  self.levelRoot:FindChild("mode"):GetComponent("UnityEngine.UI.Text").text = tostring(mode)
  self.levelRoot:FindChild("name"):GetComponent("UnityEngine.UI.Text").text = tostring(name)
end
--显示排位信息
function BattleResult28Ctrl:Init_RankInfo(rankname,starcount,ismax)
  self.levelRoot:FindChild("mode"):GetComponent("UnityEngine.UI.Text").text = tostring(rankname)
  if ismax == true then 
    self.levelRoot:FindChild("star").gameObject:SetActive(true)
    self.levelRoot:FindChild("star/Text"):GetComponent("UnityEngine.UI.Text").text ="X "..starcount
  else
    for i=0,starcount-1 do
      self.levelRoot:FindChild("stargrid"):GetChild(i).gameObject:SetActive(true)
    end
  end

end
--创建 排位变换面板 
function BattleResult28Ctrl:Init_RankChangePanel(iswin,prerankkinfo,nowinfo)
  --print(type(iswin).." "..rankid.." "..wincount)
  GameManager.CreatePanel("RankStarChange")
  RankStarChangeCtrl.Instance:setInfo(iswin,prerankkinfo,nowinfo)
end
--显示玩家信息
function BattleResult28Ctrl:Init_Player(name,icon,nexLv,nexExp,addExp,firstAdd)
  self.playerRoot:FindChild("icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",tostring(icon),"UnityEngine.Sprite")
  self.playerRoot:FindChild("name"):GetComponent("UnityEngine.UI.Text").text = tostring(name)
  self.playerRoot:FindChild("lv"):GetComponent("UnityEngine.UI.Text").text = "Lv."..nexLv
  if firstAdd > 0 then 
    self.playerRoot:FindChild("tip").gameObject:SetActive(true)
    self.playerRoot:FindChild("tip"):GetComponent("UnityEngine.UI.Text").text = "首胜+"..firstAdd
  end

  self.playerRoot:FindChild("add"):GetComponent("UnityEngine.UI.Text").text = "+"..addExp
  local allExp = UTGData.Instance().PlayerLevelUpData[tostring(nexLv)].NextExp
  if allExp == 0 then
    self.playerRoot:FindChild("exp/max"):GetComponent("UnityEngine.UI.Text").text ="已达到最大等级"
  else
    self.coroutine_expmov = coroutine.start(BattleResult28Ctrl.ExpMov,self,nexExp,addExp,allExp,self.playerRoot:FindChild("exp"))
  end
end

--经验条增长动画2.0
function BattleResult28Ctrl:ExpMov(nowExp,addExp,allExp,temp)
  local prePer = 0
  local nowPer = nowExp/allExp
  if (nowExp-addExp)>0 then prePer = (nowExp-addExp)/allExp end
  temp:FindChild("txt"):GetComponent("UnityEngine.UI.Text").text = nowExp.."/"..allExp
  local img_change = temp:GetComponent("UnityEngine.UI.Image")
  img_change.fillAmount = prePer
  temp:FindChild("pre"):GetComponent("UnityEngine.UI.Image").fillAmount = prePer
  local percent = prePer
  while percent < nowPer do
    img_change.fillAmount = percent
    percent = percent+0.01
    coroutine.step()
  end
end


--数字增长动画
function BattleResult28Ctrl:TxtMov(num,temp)
  local txt_change = temp:GetComponent("UnityEngine.UI.Text")
  txt_change.text = "+0"
  local now = 1
  local add = math.floor(num/30)
  while now<(num) do
    txt_change.text = string.format("+%d",now)
    now = now+add
    coroutine.wait(0.04)
  end
  txt_change.text = "+"..num
end

--显示金币信息
function BattleResult28Ctrl:Init_Coin(num,firstAdd)
  if firstAdd>0 then 
    self.coinRoot:FindChild("tip").gameObject:SetActive(true) 
    self.coinRoot:FindChild("tip"):GetComponent("UnityEngine.UI.Text").text = "首胜+"..firstAdd
  end
  self.coroutine_txtmov = coroutine.start(BattleResult28Ctrl.TxtMov,self,num,self.coinRoot:FindChild("add"))

end

--显示role信息
function BattleResult28Ctrl:Init_Role(roleId,addExp)
  local roledata = UTGData.Instance().RolesData[tostring(roleId)]
  local icon = UTGData.Instance().SkinsData[tostring(roledata.Skin)].Icon
  --ProficiencyId       int       //熟练度Id
  --ProficiencyValue
  local roledeck = UTGData.Instance():GetRoleDeckByRoleId(roleId)
  if roledeck == nil then Debugger.LogError("roledeck == nil ") end
  local slddata = UTGData.Instance().RoleProficiencysData[tostring(roledeck.ProficiencyId)]
  local sldname = slddata.Name
  self.roleRoot:FindChild("mask/icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",tostring(icon),"UnityEngine.Sprite")
  self.roleRoot:FindChild("sld"):GetComponent("UnityEngine.UI.Text").text = tostring(sldname)
  self.roleRoot:FindChild("add"):GetComponent("UnityEngine.UI.Text").text = "+"..addExp
  local allExp = slddata.NextExp
  local nowExp = roledeck.ProficiencyValue
  local prePer = 0
  local nowPer = nowExp/allExp
  if (nowExp-addExp)>0 then prePer = (nowExp-addExp)/allExp end
  local temp = self.roleRoot:FindChild("exp")
  temp:FindChild("txt"):GetComponent("UnityEngine.UI.Text").text = nowExp.."/"..allExp
  temp:GetComponent("UnityEngine.UI.Image").fillAmount = nowPer
  temp:FindChild("pre"):GetComponent("UnityEngine.UI.Image").fillAmount = prePer

end

--显示经验加成  param：总加成 100，经验卡加成 100，胜利卡剩余次数 0/1，双倍卡剩余天数 0/1，
function BattleResult28Ctrl:Init_Tip_Exp(addAll,addCard,remainVic,remainDou)
  self.tip_exp.gameObject:SetActive(true)
  self.tip_exp:FindChild("add"):GetComponent("UnityEngine.UI.Text").text = string.format("+%d%%",addAll)

  listener = NTGEventTriggerProxy.Get(self.tip_exp:FindChild("icon").gameObject)
  listener.onPointerDown =  NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult28Ctrl.ShowTip_Exp,self)
  listener.onPointerUp =  NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult28Ctrl.HideTip_Exp,self)

  local tip = self.tip_exp_tip
  tip:FindChild("txtall"):GetComponent("UnityEngine.UI.Text").text = string.format("<color=grey>本局经验加成倍率：</color>+%d%%",addAll)
  tip:FindChild("txtcard"):GetComponent("UnityEngine.UI.Text").text = string.format("<color=grey>经验卡加成：</color>+%d%%",addAll)
  tip:FindChild("txtdes"):GetComponent("UnityEngine.UI.Text").text = string.format("<color=grey>胜利经验卡：剩余</color>%d<color=grey>次；双倍经验卡：剩余</color>%d<color=grey>天</color>",remainVic,remainDou)

end

function BattleResult28Ctrl:ShowTip_Exp( )
  self.tip_exp_tip.gameObject:SetActive(true)
end
function BattleResult28Ctrl:HideTip_Exp( )
  self.tip_exp_tip.gameObject:SetActive(false)
end


--显示金币加成  param：总加成 100，金币卡加成 100，胜利卡剩余次数 0/1，双倍卡剩余天数 0/1，
function BattleResult28Ctrl:Init_Tip_Coin(addAll,addCard,addGuild,remainVic,remainDou)
  self.tip_coin.gameObject:SetActive(true)
  self.tip_coin:FindChild("add"):GetComponent("UnityEngine.UI.Text").text = string.format("+%d%%",addAll)

  listener = NTGEventTriggerProxy.Get(self.tip_coin:FindChild("icon").gameObject)
  listener.onPointerDown =  NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult28Ctrl.ShowTip_Coin,self)
  listener.onPointerUp =  NTGEventTriggerProxy.PointerEventDelegateSelf(BattleResult28Ctrl.HideTip_Coin,self)

  local tip = self.tip_coin_tip
  tip:FindChild("txtall"):GetComponent("UnityEngine.UI.Text").text = string.format("<color=grey>本局金币加成倍率：</color>+%d%%",addAll)
  tip:FindChild("txtcard"):GetComponent("UnityEngine.UI.Text").text = string.format("<color=grey>金币卡加成：</color>+%d%%",addCard)
  tip:FindChild("txtguild"):GetComponent("UnityEngine.UI.Text").text = string.format("<color=grey>战队加成：</color>+%d%%",addGuild)
  tip:FindChild("txtdes"):GetComponent("UnityEngine.UI.Text").text = string.format("<color=grey>胜利金币卡：剩余</color>%d<color=grey>次；双倍金币卡：剩余</color>%d<color=grey>天</color>",remainVic,remainDou)

end

function BattleResult28Ctrl:ShowTip_Coin( )
  self.tip_coin_tip.gameObject:SetActive(true)
end
function BattleResult28Ctrl:HideTip_Coin( )
 self.tip_coin_tip.gameObject:SetActive(false)
end


--前往29panel
function BattleResult28Ctrl:ClickTo29Panel()
  self.root.gameObject:SetActive(false) 
  BattleResult28API.Instance:InitPanel29()
end


function BattleResult28Ctrl:OnDestroy()
  if self.coroutine_txtmov~=nil then coroutine.stop(self.coroutine_txtmov) end
  if self.coroutine_expmov~=nil then coroutine.stop(self.coroutine_expmov) end
  self.this = nil
  self = nil
end





