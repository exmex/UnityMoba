require "System.Global"
require "Logic.UTGData.UTGData"
--local json = require "cjson"

class("NewAchieveCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"
local Toggle = "UnityEngine.UI.Toggle"

local Data = UTGData.Instance()
local GMaxLen = 234
function NewAchieveCtrl:Awake(this) 
  self.this = this
  self.cupPart = this.transforms[0]
  self.name = this.transforms[1]
  self.tip = this.transforms[2]
  self.des = this.transforms[3]
  self.iconPart = this.transforms[4]
  self.labRank = this.transforms[5]
  self.sprProgress = this.transforms[6]
  self.labProgress = this.transforms[7]
  self.labProgressAdd = this.transforms[8]
  self.btnOK = this.transforms[9]
  self.effectSilver =  this.transforms[10]
  self.effectGold =  this.transforms[11]
  local effectAll = this.transforms[12]
  UTGDataOperator.Instance:EffectInit(self.effectSilver)
  UTGDataOperator.Instance:EffectInit(self.effectGold)
  UTGDataOperator.Instance:EffectInit(effectAll)
end

function NewAchieveCtrl:Start()
  self:btnInit()
end

function NewAchieveCtrl:Init()

end


function NewAchieveCtrl:OnDestroy()
  NTGResourceController.Instance:UnloadAssetBundle("newachieve", true, false)
  self.this = nil
  self = nil
end

--这里的info是栈中的
function NewAchieveCtrl:uiSet(info)
  local old = info.old
  local new = info.new

  self:cupUiSet(info.id)
  self:levelUiSet(old,new,info.id)

end

function NewAchieveCtrl:cupUiSet(id)
  local info = Data.AchievementsById[tostring(id)]
   --cup上面的特效
  if (info.Level == 2) then
    self.effectSilver.gameObject:SetActive(true)
  elseif (info.Level == 3) then
    self.effectGold.gameObject:SetActive(true)
  end

  --cup底座设置
  local level = info.Level
  local cupBg = self.cupPart:FindChild(tostring(level))
  cupBg.gameObject:SetActive(true)

  --icon设置
  local icon = cupBg:FindChild("Icon")
  icon:GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("achieveicon",tostring(info.Icon),"UnityEngine.Sprite")

  --名字
  self.name:GetComponent(Text).text = info.Name

  self.tip:GetComponent(Text).text = info.Tip

  self.des:GetComponent(Text).text = info.Desc

 

end

function NewAchieveCtrl:levelUiSet(old,new,id)
  local labLevel = self.iconPart:FindChild("level")
  labLevel:GetComponent(Text).text = new.Level
  --Debugger.Log("new.Level"..new.Level)
  local sprIcon = self.iconPart:FindChild("IconMask/Icon")
  sprIcon:GetComponent(Image).sprite = NTGResourceController.Instance:LoadAsset("equipicon",tostring(Data.AchievementLevelUps[tostring(new.Level)].Icon),"UnityEngine.Sprite")
  --排名
  self:onRequestRank()
  local newExp = new.Exp
  local maxExp = Data.AchievementLevelUps[tostring(new.Level)].NextExp
  self.labProgress:GetComponent(Text).text = tostring(newExp).."/"..tostring(maxExp)
  --递增动画
  --数字
  local addNum = Data.AchievementsById[tostring(id)].Point
  --Debugger.Log("addNum"..addNum)
  self.coNum = coroutine.start(NewAchieveCtrl.yieldNumAdd,self,addNum)

  --进度条
  local startPro = 0
  local endPro = 0
  local totalPro = 0
  if (old.Level == new.Level) then
    startPro = old.Exp
    endPro = new.Exp
  elseif (new.Level > old.Level) then
    startPro = 0
    endPro = new.Exp
  end
  self.coPro = coroutine.start(NewAchieveCtrl.yieldProgressAdd,self,startPro,endPro,maxExp)
end

function NewAchieveCtrl:yieldProgressAdd(startPro,endPro,maxExp)
  local xLen = startPro * GMaxLen/maxExp
  local oldSize = self.sprProgress:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta
  oldSize.x = xLen
  self.sprProgress:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = oldSize
  local now = startPro
  local add = math.floor(endPro/30)
  while now<(endPro) do
    --txt_change.text = string.format("+%d",now)
    now = now+add
    xLen = now * GMaxLen/maxExp
    oldSize = self.sprProgress:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta
    oldSize.x = xLen
    self.sprProgress:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = oldSize
    coroutine.wait(0.04)
  end
   xLen = endPro * GMaxLen/maxExp
   oldSize = self.sprProgress:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta
   oldSize.x = xLen
   self.sprProgress:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = oldSize
   coroutine.stop(self.coPro)
   self.coPro= nil
end

function NewAchieveCtrl:yieldNumAdd(num)
  local txt_change = self.labProgressAdd:GetComponent("UnityEngine.UI.Text")
  txt_change.text = "+0"
  local now = 1
  local add = math.floor(num/30)
  while now<(num) do
    txt_change.text = string.format("+%d",now)
    now = now+add
    coroutine.wait(0.04)
  end
  txt_change.text = "+"..num
  coroutine.stop(self.coNum)
  self.coNum= nil
end

function NewAchieveCtrl:btnInit()
  local listener = NTGEventTriggerProxy.Get(self.btnOK.gameObject)
  local callBack = function (self,e)
    if (self.coNum ~= nil) then
      coroutine.stop(self.coNum)
    end
    if (self.coPro ~= nil) then
      coroutine.stop(self.coPro)
    end
    Object.Destroy(self.this.transform.parent.gameObject)
    local function anonyFunc(args)
      --Object.Destroy(self.this.transform.parent.gameObject)
    end
    UTGDataOperator.Instance:NewAchievePanelOpen()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callBack,self)
end

function NewAchieveCtrl:onRequestRank(args)
  local serverRequest = NetRequest.New()
  serverRequest.Content = JObject.New(JProperty.New("Type","RequestPlayerAchievementRank"))
  serverRequest.Handler = TGNetService.NetEventHanlderSelf(NewAchieveCtrl.onServerRank,self)
  TGNetService.GetInstance():SendRequest(serverRequest)
end

function NewAchieveCtrl:onServerRank(e)
--achievement_critical_rank
  if (NewAchieveApi ~= nil and NewAchieveApi.Instance ~= nil ) then
    --Debugger.Log("RequestPlayerAchievementRank")
    if e.Type == "RequestPlayerAchievementRank" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then
        local rank = tonumber(e.Content:get_Item("Rank"):ToString())
        --Debugger.Log("RequestPlayerAchievementRank rank = "..rank)
        local limitRank =  UTGData.Instance().ConfigData["achievement_critical_rank"].Int
        if (rank <= limitRank) then
          if ( self ~= nil and self.labRank ~= nil) then
            self.labRank:GetComponent(Text).text = tostring(rank)
          end
        elseif (rank > limitRank) then
          if ( self ~= nil and self.labRank ~= nil) then
            self.labRank:GetComponent(Text).text = "未上榜"
          end
        end
      end
      return true
    end
  end
  return false
end



