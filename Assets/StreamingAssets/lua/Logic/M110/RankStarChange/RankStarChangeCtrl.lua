require "System.Global"
require "Logic.M002.NewLogin.LoginUtils"
local json = require "cjson"

class("RankStarChangeCtrl")

local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "UnityEngine.RectTransform"

local typeStarThree = 3
local typeStarFour = 4
local typeStarFive = 5

--如果有段位升级是什么类型
local typeNtoN = 1
local typeNtoK = 2
local typeKtoK = 3
local typeKtoB = 4

local TimeFrame = 0.05
local TimePre = 0.8 --老的持续时间
local TimeAwardStar =  0.8 --奖励一个星星的动画
local TimeBigChangePre = 6*TimeFrame
local TimeBigChangeCur = 4*TimeFrame
local TimeStar = 0.8 --增加一个星星时长


function RankStarChangeCtrl:Awake(this) 
  self.this = this
  RankStarChangeCtrl.Instance = self
  self.winStreak = this.transforms[0]
  self.star = this.transforms[1]
  self.rankBg = this.transforms[2] --段位背景
  self.rankNum = this.transforms[3] --背景上的数字
  self.rankLab = this.transforms[4] --段位名字
  self.btn = this.transforms[5] --按钮
  self.parent = this.transforms[6]
  self.effectOnce = this.transforms[7] --背景上出现
  self.winStreakParent = this.transforms[8] --连胜父节点，王者后不显示
  self.rankParent = this.transforms[9] 
  self.effectBigChange = this.transforms[10] --升级大段位
  self.effectAwardStar = this.transforms[11] --奖励一个星星特效
  self.rankKingNumParent = this.transforms[12] --
  self.labKingNum = this.transforms[13]
  self.sprKingStar = this.transforms[14] 
  self.labKingNumParent = this.transforms[15] 
  self.rankBgCom = self.rankBg:GetComponent("UnityEngine.UI.Image")
  self.rankLabCom = self.rankLab:GetComponent("UnityEngine.UI.Text")  --段位描述
  self.rankNumCom = self.rankNum:GetComponent("UnityEngine.UI.Image") --段位上小icon
  self.tabCo = {}
end

-----------------------------------------------外部需要的API---------------------------------------------------
--输赢
--之前前段位ID
--之前连胜星星数
function RankStarChangeCtrl:setInfo(isWim,preData,curData)
  self.effectOnce.gameObject:SetActive(true)
  self.isWin = isWim
  self.preData = preData --上一场段位信息
  self.curData = curData --当前要显示的段位
  
  if (self.isWin == true) then
    self:winDataDeal()
    self:winPreUiSet(self.preData)
  elseif (self.isWin == false) then
    self:loseDataDeal()
    self:losePreUiSet(self.curData)
  end

  local function uiShowCur()
    --coroutine.wait(WaitForSeconds.New(TimePre)) --延时显示老的
    coroutine.wait(TimePre)
    --self:uiInit()
    if (self.isWin == true ) then
      self:winChange()
    elseif (self.isWin == false) then
      self:loseChange()
    end
    
  end
  --coroutine.start(NTGLuaCoroutine.New(self, uiShowCur))
  local co = coroutine.start(uiShowCur,self)
  table.insert(self.tabCo,co)
end


--------------------------------------------------------------------------------------------------------------
function RankStarChangeCtrl:losePreUiSet(data) --传入当前的数据
  self.winStreakParent.gameObject:SetActive(false)
  
  local maxStars = UTGData.Instance().GradesData[tostring(data.Grade)].MaxStars
  local curStars = 0
  if (self.isLoseBToB == true) then
    curStars = data.Stars
  else
    curStars = data.Stars + 1 
  end

  if (maxStars ~= 0) then --非王者显示头上星星
    self:starInit(maxStars,curStars)
  end

  --段位名字
  self.rankLabCom.text=UTGData.Instance().GradesData[tostring(data.Grade)].Title

  --大icon
  if(self.curData.IsHonor == true) then --之后是荣耀王者就直接显示荣耀王者
				self.rankBgCom.sprite=NTGResourceController.Instance:LoadAsset("rankicon-".."i18000007","i18000007","UnityEngine.Sprite")
        self.rankBgCom:SetNativeSize()
				self.rankLabCom.text="大元帅"
	else
		self.rankBgCom.sprite=NTGResourceController.Instance:LoadAsset("rankicon-"..UTGData.Instance().GradesData[tostring(data.Grade)].IconMain,UTGData.Instance().GradesData[tostring(data.Grade)].IconMain,"UnityEngine.Sprite")
	  self.rankBgCom:SetNativeSize()
  end


  if(maxStars~=0) then
		  self.rankNumCom.sprite =NTGResourceController.Instance:LoadAsset("Rankicon-"..UTGData.Instance().GradesData[tostring(data.Grade)].IconMain,UTGData.Instance().GradesData[tostring(data.Grade)].IconSub,"UnityEngine.Sprite")
      self.rankNumCom:SetNativeSize()
      self.rankNum.gameObject:SetActive(true)
      self.rankKingNumParent.gameObject:SetActive(false)
	else --如果是王者段位
    self.rankKingNumParent.gameObject:SetActive(true)
    self.rankNum.gameObject:SetActive(false) --隐藏背景上的数字
    self.labKingNum:GetComponent("UnityEngine.UI.Text").text = tonumber(data.Stars + 1)   
  end

end
--显示之前段位ui
function RankStarChangeCtrl:winPreUiSet(data) 
  --星星
  local maxStars = UTGData.Instance().GradesData[tostring(data.Grade)].MaxStars
  local curStars = data.Stars
  if (maxStars ~= 0) then --非王者显示头上星星
    self:starInit(maxStars,curStars)
  end

  --连胜
  if (self:isUseWinStreakUI() == true ) then --是否显示连胜ui
    self.winStreakParent.gameObject:SetActive(true)
    if (self.isWinStreak == true ) then --使用之前连胜数据
      maxWinStreak = UTGData.Instance().GradesData[tostring(self.preData.Grade)].WinningCheck
    else 
      maxWinStreak = UTGData.Instance().GradesData[tostring(self.curData.Grade)].WinningCheck
    end
    local curWinStreak = data.GradeWinningCount
    self:winStreakInit(maxWinStreak,curWinStreak)
  else
    self.winStreakParent.gameObject:SetActive(false)
  end

  --段位名字
  self.rankLabCom.text=UTGData.Instance().GradesData[tostring(data.Grade)].Title

  --大icon
  if(self.curData.IsHonor == true) then --之后是荣耀王者就直接显示荣耀王者
				self.rankBgCom.sprite=NTGResourceController.Instance:LoadAsset("rankicon-".."i18000007","i18000007","UnityEngine.Sprite")
        self.rankBgCom:SetNativeSize()
				self.rankLabCom.text="大元帅"
	else
		self.rankBgCom.sprite=NTGResourceController.Instance:LoadAsset("rankicon-"..UTGData.Instance().GradesData[tostring(data.Grade)].IconMain,UTGData.Instance().GradesData[tostring(data.Grade)].IconMain,"UnityEngine.Sprite")
	  self.rankBgCom:SetNativeSize()
  end


  if(maxStars~=0) then
		  self.rankNumCom.sprite =NTGResourceController.Instance:LoadAsset("Rankicon-"..UTGData.Instance().GradesData[tostring(data.Grade)].IconMain,UTGData.Instance().GradesData[tostring(data.Grade)].IconSub,"UnityEngine.Sprite")
      self.rankNumCom:SetNativeSize()
      self.rankNum.gameObject:SetActive(true)
      self.rankKingNumParent.gameObject:SetActive(false)
	else
    self.rankKingNumParent.gameObject:SetActive(true)
    self.rankNum.gameObject:SetActive(false) --隐藏背景上的数字
    self.labKingNum:GetComponent("UnityEngine.UI.Text").text = data.Stars    
  end
end

function RankStarChangeCtrl:winChange() --赢
  if (self.typeChange == typeNtoN) then --两个非王者段位变化
    self:winStreakAddOne()
    self:starAddOne()
  elseif (self.typeChange == typeNtoK) then --钻石至王者
    self:winStreakAddOne()
    self:starNtoKAdd()
  elseif (self.typeChange == typeKtoK or self.typeChange == typeKtoB) then 
    self:starKAdd()
  end
end

function RankStarChangeCtrl:loseChange() --输
  if (self.isKing == true) then
    self.labKingNum:GetComponent("UnityEngine.UI.Text").text = tonumber(self.curStar)  
    self:rangKingAni(1)
  elseif (self.isKing == false) then
    if (self.isLoseBToB == false ) then
      self:starAni(self.curMaxStar,self.curStar+1,0)
    end
  end
end

--钻石到王者的升级
function RankStarChangeCtrl:starNtoKAdd(args)
    local function func(args)
      
      if (self.isWinNextOne == true ) then--差1星，差1连胜，先当前加1，在连胜奖励，在之后加在第一个
        --加最后一个星
        local starType = self.preMaxStar
        self:starAni(starType,starType,1)   
        --coroutine.wait(WaitForSeconds.New(TimeStar))
        coroutine.wait(TimeStar)
      end
      --显示老的转转特效
      self:rangBgAni(0)
      --coroutine.wait(WaitForSeconds.New(TimeBigChangePre))
      coroutine.wait(TimeBigChangePre)

      --显示新的空的星星
      self:starClear() --清空星星
      self:rankChangeSetInfo(self.curData)

      --由大变小
      self:rangBgAni(1)
      self.effectBigChange.gameObject:SetActive(true)
      --coroutine.wait(WaitForSeconds.New(TimeBigChangeCur))
      coroutine.wait(TimeBigChangeCur)

      --有连胜增加最后一颗星星
      if ( self.isWinNextOne == true or self.isWinNextTwo == true) then
        self:playWinStreak()
      end
      self.winStreakParent.gameObject:SetActive(false) --关闭连胜UI
    end
    --coroutine.start(NTGLuaCoroutine.New(self, func))
    local co = coroutine.start(func,self)
    table.insert(self.tabCo,co)
end

--王者的加星星固定动画
function RankStarChangeCtrl:starKAdd(args)
  self:rankChangeSetInfo(self.curData)
  self:rangKingAni(1)
end


--当前段位是王者，动画改变
function RankStarChangeCtrl:curKingChange(args)
  if (self.isBigChange == 0) then --没有大段位变化，上一段位也是王者
    --小段位变化 todo
    self:rankChangeSetInfo(self.curData)
  elseif (self.isBigChange ~= 0) then --大段位变化，上一段位是钻石要进行翻牌
    local function waitFor()
      --显示老的转转特效
      self:rangBgAni(0)
      --coroutine.wait(WaitForSeconds.New(TimeBigChangePre)) --
      coroutine.wait(TimeBigChangePre)
      self:starClear() --清空星星
      self:rankChangeSetInfo(self.curData)
      --新的大背景由大变小
      self:rangBgAni(1)
      self.effectBigChange.gameObject:SetActive(true) --特效

    end
    --coroutine.start(NTGLuaCoroutine.New(self, waitFor))
    local co = coroutine.start(waitFor,self)
    table.insert(self.tabCo,co)
  end
end

--延时奖励一星
function RankStarChangeCtrl:coStarAddOneForAward(func)
  local function waitFor()
      self.effectAwardStar.gameObject:SetActive(true) --连胜特效
      --coroutine.wait(WaitForSeconds.New(TimeAwardStar))
      coroutine.wait(TimeAwardStar)
      self.winStreakParent.gameObject:SetActive(false) --关闭连胜UI
      if (func ~= nil) then
        func()
      end
  end
  --coroutine.start(NTGLuaCoroutine.New(self, waitFor))
  local co = coroutine.start(waitFor,self)
  table.insert(self.tabCo,co)
end

--添加星星
function RankStarChangeCtrl:starAddOne()
  
  local bigChange = self:isBigDanChange()
  if (bigChange == 0) then
    local smallChange = self:isSmallDanChange()
    if (smallChange == false)  then --没有大段位变化且没有小段位变化,就在原来的星星加1（不用cur的）
      local starIdx = self.preData.Stars + 1
      local starType = self.preMaxStar
      self:starAni(starType,starIdx,1)   
      if (self.isWinStreak == true) then --奖励一个星
        local function func(args)
          starIdx = starIdx + 1
          self:starAni(starType,starIdx,1)
        end
        self:coStarAddOneForAward(func)
      end
    elseif (smallChange == true) then --产生小段位变化
      if (self.isWinNextOne == true ) then  --差1星，差1连胜，先当前加1，在连胜奖励，在之后加在第一个
        --local starIdx = self.preData.Stars + 1
        local function func(args)
          local starType = self.preMaxStar
          self:starAni(starType,starType,1)   
          --coroutine.wait(WaitForSeconds.New(TimeStar))
          coroutine.wait(TimeStar)
          self.winStreakParent.gameObject:SetActive(false) --关闭连胜UI
          self.effectAwardStar.gameObject:SetActive(true) --连胜特效
          --coroutine.wait(WaitForSeconds.New(TimeAwardStar))
          coroutine.wait(TimeAwardStar)
          self.effectBigChange.gameObject:SetActive(true) --
          self:rankChangeSetInfo(self.curData) --设置最新的排位信息
          self:starClear() --清空星星
          self:starTypeSetActive(self.curMaxStar) --显示对应的type星星
          self:starAni(self.curMaxStar,1,1)
        end
        local co = coroutine.start(func,self)
        table.insert(self.tabCo,co)
      elseif (self.isWinNextTwo == true) then --不差星，差1连胜，在连胜新的段位，在之后加在第一个（加两个）
        local function func(args)
          self.winStreakParent.gameObject:SetActive(false) --关闭连胜UI
          self.effectAwardStar.gameObject:SetActive(true) --连胜特效
          --coroutine.wait(WaitForSeconds.New(TimeAwardStar))
          coroutine.wait(TimeAwardStar)
          self.effectBigChange.gameObject:SetActive(true) --
          self:rankChangeSetInfo(self.curData) --设置最新的排位信息
          self:starClear() --清空星星
          self:starTypeSetActive(self.curMaxStar) --显示对应的type星星
          local starType = self.preMaxStar
          self:starAni(self.curMaxStar,1,1)                 
          self:starAni(self.curMaxStar,2,1)
        end
        local co = coroutine.start(func,self)
        table.insert(self.tabCo,co)
      else
        --重新设置subicon和段位名字
        self:rankChangeSetInfo(self.curData) 
        self:starClear() --清空星星
        self:starTypeSetActive(self.curMaxStar) --显示对应的type星星
        self:starAni(self.curMaxStar,1,1)
      end
    end
  elseif (bigChange == 1) then --有大段位变化
    if (self.isWinNextOne == true ) then
       local function func(args)
          local starType = self.preMaxStar
          self:starAni(starType,starType,1)   
          coroutine.wait(TimeStar)

          --显示老的转转特效
          self:rangBgAni(0)
          coroutine.wait(TimeBigChangePre)

          --显示新的空的星星
          self:starClear() --清空星星
          self:starTypeSetActive(self.curMaxStar)
          self:rankChangeSetInfo(self.curData)

          --由大变小
          self:rangBgAni(1)
          self.effectBigChange.gameObject:SetActive(true)
          coroutine.wait(TimeBigChangeCur)

          self.winStreakParent.gameObject:SetActive(false) --关闭连胜UI
          self.effectAwardStar.gameObject:SetActive(true) --连胜特效
          coroutine.wait(TimeAwardStar)
          

          self:starAni(self.curMaxStar,1,1)
        end
        local co = coroutine.start(func,self)
        table.insert(self.tabCo,co)
    elseif (self.isWinNextTwo == true) then 
      local function func(args)
          --显示老的转转特效
          self:rangBgAni(0)
          coroutine.wait(TimeBigChangePre)

          --显示新的空的星星
          self:starClear() --清空星星
          self:starTypeSetActive(self.curMaxStar)
          self:rankChangeSetInfo(self.curData)

          --由大变小
          self:rangBgAni(1)
          self.effectBigChange.gameObject:SetActive(true)
          coroutine.wait(TimeBigChangeCur)
          self:starAni(self.curMaxStar,1,1)

          self.winStreakParent.gameObject:SetActive(false) --关闭连胜UI
          self.effectAwardStar.gameObject:SetActive(true) --连胜特效
          coroutine.wait(TimeAwardStar)
          

          self:starAni(self.curMaxStar,2,1)
        end
        local co = coroutine.start(func,self)
        table.insert(self.tabCo,co)
    else
      local function func(args)
          --显示老的转转特效
          self:rangBgAni(0)
          coroutine.wait(TimeBigChangePre)

          --显示新的空的星星
          self:starClear() --清空星星
          self:starTypeSetActive(self.curMaxStar)
          self:rankChangeSetInfo(self.curData)

          --由大变小
          self:rangBgAni(1)
          self.effectBigChange.gameObject:SetActive(true)
          coroutine.wait(TimeBigChangeCur)
          self:starAni(self.curMaxStar,1,1)
        end
        local co = coroutine.start(func,self)
        table.insert(self.tabCo,co)
    end
  end

end

--播放连胜奖励
function RankStarChangeCtrl:playWinStreak(args)
  self.winStreakParent.gameObject:SetActive(false) --关闭连胜UI
  self.effectAwardStar.gameObject:SetActive(true) --连胜特效
  coroutine.wait(TimeAwardStar)
end

function RankStarChangeCtrl:winStreakAddOne()
  --确定使用上一个段位连胜格子还是当前
  local streakIdx = self.preData.GradeWinningCount + 1
  self:winStreakShowAni(streakIdx)
end

--数据处理
function RankStarChangeCtrl:winDataDeal()
  self.preMaxStar = UTGData.Instance().GradesData[tostring(self.preData.Grade)].MaxStars
  self.curMaxStar = UTGData.Instance().GradesData[tostring(self.curData.Grade)].MaxStars
  self.isWinStreak = self:isWinStreakOK()
  self.isPreKing = self:isKing(self.preData)
  self.isCurKing = self:isKing(self.curData)
  self.isBigChange = self:isBigDanChange()
  self.isWinNextOne = self:isWinNextOne()
  self.isWinNextTwo = self:isWinNextTwo()
  self.typeChange = self:winChangeTypeGet()
end

--失败时处理
function RankStarChangeCtrl:loseDataDeal()
  self.isKing = self:isKing(self.curData) --最后是否是王者
  --self.preMaxStar = UTGData.Instance().GradesData[tostring(self.preData.Grade)].MaxStars
  self.curMaxStar = UTGData.Instance().GradesData[tostring(self.curData.Grade)].MaxStars
  self.curStar = self.curData.Stars
  self.isLoseBToB = self:isLoseBronzeToBronze()
end

function RankStarChangeCtrl:aniDeal()
  local isBigDanChange = self:isBigDanChange() --大段位是否变化了
  if (self.isWin == true) then
    
  elseif (self.isWin == false) then 
    if (isBigDanChange == 0) then
      --if ( )
    end
  end
end

--小段位变化更新subicon和段位描述
function RankStarChangeCtrl:rankChangeSetInfo(data)
  self.rankLabCom.text=UTGData.Instance().GradesData[tostring(data.Grade)].Title

  --大icon
  if(data.IsHonor == true) then
				self.rankBgCom.sprite=NTGResourceController.Instance:LoadAsset("rankicon-".."i18000007","i18000007","UnityEngine.Sprite")
        self.rankBgCom:SetNativeSize()
				self.rankLabCom.text="大元帅"
	else
		self.rankBgCom.sprite=NTGResourceController.Instance:LoadAsset("rankicon-"..UTGData.Instance().GradesData[tostring(data.Grade)].IconMain,UTGData.Instance().GradesData[tostring(data.Grade)].IconMain,"UnityEngine.Sprite")
	  self.rankBgCom:SetNativeSize()
  end

  local maxStars = UTGData.Instance().GradesData[tostring(data.Grade)].MaxStars
  if(maxStars~=0) then
    self.rankKingNumParent.gameObject:SetActive(false)
    self.rankNum.gameObject:SetActive(true)
		self.rankNumCom.sprite =NTGResourceController.Instance:LoadAsset("Rankicon-"..UTGData.Instance().GradesData[tostring(data.Grade)].IconMain,UTGData.Instance().GradesData[tostring(data.Grade)].IconSub,"UnityEngine.Sprite")
    self.rankNumCom:SetNativeSize()
	else
    self.rankKingNumParent.gameObject:SetActive(true)
    self.rankNum.gameObject:SetActive(false) --隐藏背景上的数字
    self.labKingNum:GetComponent("UnityEngine.UI.Text").text = data.Stars             
  end
end

--清空所有星星
function RankStarChangeCtrl:starClearTest(starType)
  local starPart = self.star:FindChild(tostring(typeStar))
  starPart.gameObject:SetActive(true)

  if (isPre == true) then
    for i = 1,starNum,1 do --如果是0星不显示
      local star = starPart:FindChild(tostring(i).."/Star");
      star.gameObject:SetActive(true)
    end
  end
end

--段位背景图改变动画
--0:老的翻牌   1：新的从大变小
function RankStarChangeCtrl:rangBgAni(state)
  local rankAni = self.rankParent:GetComponent("Animator")
  rankAni:SetInteger( "State" ,state );
end

function RankStarChangeCtrl:rangKingAni(show)
  local rankAni = self.sprKingStar:GetComponent("Animator")
  rankAni:SetInteger( "Show" ,show );

  local rankAniLab = self.labKingNumParent:GetComponent("Animator")
  rankAniLab:SetInteger( "Show" ,show );
end

--星星显示或隐藏动画
function RankStarChangeCtrl:starAni(maxStar,curStar,isShow)
  local typeStar = self.star:FindChild(tostring(maxStar))
  local star = typeStar:FindChild(tostring(curStar).."/Star")
  star.gameObject:SetActive(true)
  local starAni = star:GetComponent("Animator")
  starAni:SetInteger( "Show" ,isShow );
end

--连胜出现动画
function RankStarChangeCtrl:winStreakShowAni(idx)
  local win = self.winStreak:FindChild(tostring(idx).."/WinStreak")
  win.gameObject:SetActive(true)
  local winAni = win:GetComponent("Animator")
  winAni:SetInteger( "Show" ,1 );
end


function  RankStarChangeCtrl:Start()
  local listener = NTGEventTriggerProxy.Get(self.btn.gameObject)
  listener.onPointerClick = listener.onPointerClick + NTGEventTriggerProxy.PointerEventDelegateSelf(RankStarChangeCtrl.onBtn,self)

  self:EffectInit(self.effectOnce)
  self:EffectInit(self.effectBigChange)
  self:EffectInit(self.effectAwardStar)
end

--初始化连胜
--isFourWinStreak：是否是第四中连胜方式
--winStreakNum：一共有多少连胜
function RankStarChangeCtrl:winStreakInit(maxWinStreak,winStreakNum)
--  if (isFourWinStreak == false) then
--    local fourWin = self.winStreak:FindChild("4")
--    fourWin.gameObject:SetActive(false)
--  end

  for i = 0,self.winStreak.childCount-1,1 do
    local item = self.winStreak:GetChild(i)
    local bi = i +1
    if bi > maxWinStreak then
      item.gameObject:SetActive(false)
    end
  end

  for i = 1, winStreakNum,1 do
    local win = self.winStreak:FindChild(tostring(i).."/WinStreak")
    win.gameObject:SetActive(true)
  end
end

--星星初始化,用来显示之前是多少星星
--typeStar：第几种星星方式（3，4，5）
--starNum：有多少星星
function RankStarChangeCtrl:starInit(typeStar,starNum)
  local starPart = self.star:FindChild(tostring(typeStar))
  starPart.gameObject:SetActive(true)

  for i = 1,starNum,1 do --如果是0星不显示
    local star = starPart:FindChild(tostring(i).."/Star");
    star.gameObject:SetActive(true)
  end
end

function RankStarChangeCtrl:starClear()
  self.star:FindChild("3").gameObject:SetActive(false)
  self.star:FindChild("4").gameObject:SetActive(false)
  self.star:FindChild("5").gameObject:SetActive(false)
  for i = 1, self.star.childCount,1 do 
    local starType = self.star:GetChild(i-1)
    for j = 1,starType.childCount,1 do
      local star = starType:GetChild(j-1):FindChild("Star")
      star.gameObject:SetActive(false)
    end
  end
end

function RankStarChangeCtrl:starTypeSetActive(starType)
  self.star:FindChild(tonumber(starType)).gameObject:SetActive(true)
end

function RankStarChangeCtrl:onBtn(args)
  Object.Destroy(self.parent.gameObject)
end

function RankStarChangeCtrl:OnDestroy()
  RankStarChangeCtrl.Instance = nil
  for i,v in ipairs(self.tabCo) do
    if (v ~= nil) then
      coroutine.stop(v)
    end
  end
  self.this = nil
  self = nil
end

function RankStarChangeCtrl:EffectInit(trans)
 local tabRender = trans:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for k = 0,tabRender.Length - 1 do
    trans:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[k].material.shader = UnityEngine.Shader.Find(tabRender[k].material.shader.name)
  end

end

--大段位变化   1：升级   0：不变   -1：降级
function RankStarChangeCtrl:isBigDanChange(args)
  local pre = UTGData.Instance().GradesData[tostring(self.preData.Grade)].Category     
  local cur = UTGData.Instance().GradesData[tostring(self.curData.Grade)].Category   
  if pre > cur then
    return -1  
  elseif pre == cur then
    return 0
  elseif pre < cur then
    return 1
  end
end

--是否用之前的连胜总场数,连胜差1使用之前
function RankStarChangeCtrl:isWinStreakOK(args)
  local preMaxWinStreak = UTGData.Instance().GradesData[tostring(self.preData.Grade)].WinningCheck
  if self.preData.GradeWinningCount + 1 == preMaxWinStreak and self.isWin == true then
    return true
  end
  return false
end

--是否使用连胜UI
function RankStarChangeCtrl:isUseWinStreakUI(args)
  local ret = true
  if self:isKing(self.preData) then
    ret = false
  end
  if self.isWin == false then
    ret = false
  end
  return ret
end

--王者不显示星
function RankStarChangeCtrl:isKing(grade)
  local beyond = UTGData.Instance().GradesData[tostring(grade.Grade)].Category 
  if beyond == 5 then
    return true
  end
  return false
end

--是否小段位变化
function RankStarChangeCtrl:isSmallDanChange()
  local ret = false
  local pre = self.preData.Grade          
  local cur = self.curData.Grade         
  if pre ~= cur then
    ret = true
  end
  return ret
end

--临界奖1：当前段位差1星，差1连胜，再赢1场，变为下段位1星
function RankStarChangeCtrl:isWinNextOne()
  local ret = false
  if self.isWin == true then
    local preStar = self.preData.Stars
    local preMaxStar =  UTGData.Instance().GradesData[tostring(self.preData.Grade)].MaxStars
    if ( preStar + 1 == preMaxStar) then
      local preWin = self.preData.GradeWinningCount 
      local preWinMax = UTGData.Instance().GradesData[tostring(self.preData.Grade)].WinningCheck 
      if ( preWin + 1 == preWinMax ) then
        ret = true
      end
    end 
  end
  return ret
end

--临界奖2：当前段位满星，差1连胜，再赢1场，变为下段位2星
function RankStarChangeCtrl:isWinNextTwo()
  local ret = false
  if self.isWin == true then
    local preStar = self.preData.Stars
    local preMaxStar =  UTGData.Instance().GradesData[tostring(self.preData.Grade)].MaxStars
    if ( preStar  == preMaxStar) then
      local preWin = self.preData.GradeWinningCount 
      local preWinMax = UTGData.Instance().GradesData[tostring(self.preData.Grade)].WinningCheck 
      if ( preWin + 1 == preWinMax ) then
        ret = true
      end
    end 
  end
  return ret
end

--当前翻牌升级状态
--1：非王者to非王者
--2：非王者to王者
--3：王者to荣耀王者
function RankStarChangeCtrl:winChangeTypeGet()
  local ret = -1
  local pre = self:isKing(self.preData)
  local cur = self:isKing(self.curData)
  if (pre == false and cur == false) then 
    ret = typeNtoN
  elseif (pre == false and cur == true) then 
    ret = typeNtoK
  elseif (pre == true and cur == true) then
    ret = typeKtoK
  elseif (self.preData.Grade == 18000016 and self.curData.Grade == 18000016 and self.preData.IsHonor == false and self.curData.IsHonor == true) then
    ret = typeKtoB
  end
  return ret
end

--青铜掉到青铜
function RankStarChangeCtrl:isLoseBronzeToBronze()
  local ret = false
  local pre = UTGData.Instance().GradesData[tostring(self.preData.Grade)].Category
  local cur = UTGData.Instance().GradesData[tostring(self.curData.Grade)].Category
  if (pre == 0 and cur == 0) then
    ret = true
  end
  return ret
end



