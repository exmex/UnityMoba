require "System.Global"
require "Logic.M002.NewLogin.LoginUtils"

local json = require "cjson"

class("BattleAchieveCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"

local TypeMvp = 1
local TypeGod = 2
local TypeKill5 = 3
local TypeKill4 = 4
local TypeKill3 = 5

function BattleAchieveCtrl:Awake(this) 
  self.this = this
  self.btnLast = this.transforms[1]--上一个按钮
  self.btnNext = this.transforms[2]--下一个按钮
  self.objContent = this.transforms[3]--内容
  self.effect = this.transforms[4]--特效
  self.typeMvp = this.transforms[5]--mvp
  self.typeGod = this.transforms[6]--god
  self.typeKill5 = this.transforms[7]--kill5
  self.typeKill4 = this.transforms[8]--kill4
  self.typeKill3 = this.transforms[9]--kill3
  
end

function BattleAchieveCtrl:Start()
  self:EffectInit()
  self.idx = 1
  self.cnt = 5
  self.tabData = {}
  self:Init()
  self.moveTime = 0.18--移动一次总时间
  self.moveLen = 600--总像素
  self.moveOnceTime = 0.03--每次移动时间
  self.moveOnceLen = self.moveLen/(self.moveTime/self.moveOnceTime)
  Debugger.Log(self.moveOnceLen)
  self.bMoving = false --是否正在移动
  self.bLeft = false--是否向左移动
  self:ItemDataInit()
  self:ItemUIInit()
  self:cntBgSizeAdjust(self.typeMvp)
  self:cntBgSizeAdjust(self.typeGod)
  self:cntBgSizeAdjust(self.typeKill5)
  self:cntBgSizeAdjust(self.typeKill4)
  self:cntBgSizeAdjust(self.typeKill3)
end

function BattleAchieveCtrl:Init()
  local listenr
  listener = NTGEventTriggerProxy.Get(self.btnLast.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(BattleAchieveCtrl.OnBtnLast,self)

  listener = NTGEventTriggerProxy.Get(self.btnNext.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf( BattleAchieveCtrl.OnBtnNext,self)
end

function BattleAchieveCtrl:ItemUIInit()
  --动态创建
  --self.Content = UITools.GetLuaScript( self.objContent.gameObject , "Logic.UICommon.UIItems")  --内容grid
  --self.Content:ResetItemsSimple(self.cnt) 
  --self:Evaluation(self.tableCopy);
  
  --直接创建5个，然后设置true来激活
  for i=1, #self.tabData,1 do
    if (self.tabData[i].achieveType == TypeMvp) then
      self.typeMvp.gameObject:SetActive(true)
      self:CntNumSet(self.typeMvp,self.tabData[i].num)
    elseif self.tabData[i].achieveType == TypeGod then
      self.typeGod.gameObject:SetActive(true)
      self:CntNumSet(self.typeGod,self.tabData[i].num)
    elseif (self.tabData[i].achieveType == TypeKill5) then
      self.typeKill5.gameObject:SetActive(true)
      self:CntNumSet(self.typeKill5,self.tabData[i].num)
    elseif (self.tabData[i].achieveType == TypeKill4) then
      self.typeKill4.gameObject:SetActive(true)
      self:CntNumSet(self.typeKill4,self.tabData[i].num)
    elseif (self.tabData[i].achieveType == TypeKill3) then
      self.typeKill3.gameObject:SetActive(true)
      self:CntNumSet(self.typeKill3,self.tabData[i].num)
    end
  end
end

function BattleAchieveCtrl:CntNumSet(trans,num)
  local trans = trans:FindChild("CountBg/CountContent/AchieveCount")
  local luaCntParent = UITools.GetLuaScript( trans.gameObject , "Logic.UICommon.UIItems")  --内容grid
  local iDigit = self:DigitGet(num)
  luaCntParent:ResetItemsSimple(iDigit) 
  local sAllNum = tostring(num)
  for i=1,iDigit,1 do
    --每张图片上面显示数字
    local sOneNum = string.sub(sAllNum,i,i)
    Debugger.Log("sOneNum = "..sOneNum)
    luaCntParent.itemList[i].transform:GetComponent("UnityEngine.UI.Image").sprite=UITools.GetSprite("iconnum","IconNum_"..sOneNum);
  end
end

--判断一个数是几位数
function BattleAchieveCtrl:DigitGet(num)
  local digit = 1
  while(num>=10) do
    digit = digit + 1;
    num=num/10;
 end
 return digit
end

----获取战斗成就数据
--function BattleAchieveCtrl:DataGetFromServer()
--  local serverRequest = NetRequest.New()
--  serverRequest.Content = JObject.New(JProperty.New("Type","RequestBattleAchieveData"))
--  serverRequest.Handler = DelegateFactory.TGNetService_NetEventHanlder_Self(self,BattleAchieveCtrl.DataGetFromServerHandler)
--  TGNetService.GetInstance():SendRequest(serverRequest)
--end

----获取数据回调
--function BattleAchieveCtrl:DataGetFromServerHandler(e)
--  if e.Type == "RequestBattleAchieveData" then
--    local result = e.Content:ValueGeneric("System.Int32","Result")
--    if result == 1 then
--      local servers = json.decode(e.Content:get_Item("AchieveData"):ToString())
--      self.tabData = {}
--      for k,v in pairs(servers) do
--        self.Servers[tostring(servers[k].Id)] = servers[k]
--      end
--    end
--    return true
--  end
--  return false
--end

function BattleAchieveCtrl:ItemDataInit()

  self.tabData = {}
  

  local strOne2 = {}
  strOne2.achieveType = TypeMvp
  strOne2.num = 3111
  table.insert(self.tabData,strOne2)

  local strOne3 = {}
  strOne3.achieveType = TypeGod
  strOne3.num = 12
  table.insert(self.tabData,strOne3)

  local strOne1 = {}
  strOne1.achieveType = TypeKill5
  strOne1.num = 1255
  table.insert(self.tabData,strOne1)

  self.cnt = #self.tabData
end

--得到统计混排的size,调整cntBg的大小
function BattleAchieveCtrl:cntBgSizeAdjust(trans)
    local text1 = trans:FindChild("CountBg/CountContent/Text")
    local text2 = trans:FindChild("CountBg/CountContent/Text2")
    local numPart = trans:FindChild("CountBg/CountContent/AchieveCount")
    local numTotal = 0;
    for i = 1, numPart.childCount-1,1 do --第一个隐藏的不进入加载
      local child = numPart:GetChild(i)
      if (child ~= nil) then
        numTotal = numTotal + child:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.x
      end
    end
    local len = text1:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.x + text2:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.x + numTotal
    local bg = trans:FindChild("CountBg/Bg")
    local bgLenX = bg:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.x
    local bgLenY = bg:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.y
    local bgLenZ = bg:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta.z
    local bgLenXReduce = bgLenX - 50
    Debugger.Log("bgLenXReduce" .. bgLenXReduce)
    Debugger.Log("len"..len)
    --local bgLenY = bg:GetComponent ("UnityEngine.RectTransform").sizeDelta.x - 50
    if (len > bgLenXReduce) then
      bg:GetComponent(NTGLuaScript.GetType("UnityEngine.RectTransform")).sizeDelta = Vector3.New(bgLenX+100,bgLenY,bgLenZ)
    end
    --bg:GetComponent ("UnityEngine.RectTransform").sizeDelta = Vector3.New(400,109,0)


end

function BattleAchieveCtrl:EffectInit()
 local tabRender = self.effect:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
    for k = 0,tabRender.Length - 1 do
      self.effect:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(tabRender[k].material.shader.name)
    end
end


function BattleAchieveCtrl:OnBtnLast()
  Debugger.Log("Last")
  Debugger.Log(self.idx)
  if (self.bMoving == false) then
    if ( self.idx <= self.cnt and self.idx > 1 ) then 
      self.idx = self.idx  -1;
      
      self.bLeft = false
      self.co = coroutine.start(self.yieldMove,self)
--      self.co  =NTGLuaCoroutine.New(self, self.yieldMove)
--      self.this:StartCoroutine(  self.co  )  
    end
  end
end

function BattleAchieveCtrl:yieldMove()
  self.bMoving = true
  self.effect.gameObject:SetActive(false)
  if (self.bLeft == true) then
    local newPosX = self.objContent.localPosition.x - self.moveLen
    while (newPosX < self.objContent.localPosition.x) do
      local oldPos =  self.objContent.localPosition
      oldPos.x = oldPos.x - self.moveOnceLen
      self.objContent.localPosition = oldPos
      coroutine.wait(self.moveOnceTime)
      --coroutine.yield(WaitForSeconds.New(self.moveOnceTime))
    end
  else
    local newPosX = self.objContent.localPosition.x + self.moveLen
    while (newPosX > self.objContent.localPosition.x) do
      local oldPos =  self.objContent.localPosition
      oldPos.x = oldPos.x + self.moveOnceLen
      self.objContent.localPosition = oldPos
      coroutine.wait(self.moveOnceTime)
      --coroutine.yield(WaitForSeconds.New(self.moveOnceTime))
    end
  end
  self.effect.gameObject:SetActive(true)
  self.bMoving  = false
end

function BattleAchieveCtrl:OnBtnNext()
  Debugger.Log("Next")
  Debugger.Log(self.idx)
  if (self.bMoving == false) then
    if ( self.idx < self.cnt and self.idx >= 1 ) then 
      self.idx = self.idx + 1
      
      self.bLeft = true
      self.co = coroutine.start(self.yieldMove,self)
--      self.co  =NTGLuaCoroutine.New(self, self.yieldMove)
--      self.this:StartCoroutine(  self.co  )  
    end
  end
end

function BattleAchieveCtrl:OnDestroy()
  self.this = nil
  self = nil
end
