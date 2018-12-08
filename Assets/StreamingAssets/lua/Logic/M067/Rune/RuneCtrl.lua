require "System.Global"
require "Logic.UICommon.Static.UITools"

class("RuneCtrl")

--self.selectSlot当前被选择的slot的data
--[[ShowCurrSetPanel()
self.runeSetPanels = {self.runeSet_RuneEmptyHint,self.runeSet_ShowInfo,self.runeSet_RuneChange,self.runeSet_RuneBag}]]
--RuneCtrl:SetAttr(target, rootName, hasDes, count, runeId)
local json = require "cjson"
function RuneCtrl:Awake(this)
  self.this = this
  self.rune_BackBtn = this.transforms[0]
  self.rune_SetCtrl = this.transforms[1]
  self.rune_CreateCtrl = this.transforms[2]
  self.rune_CreateSuccessfulCtrl = this.transforms[3]
  self.rune_SetBtn = this.transforms[4]
  self.rune_CreateBtn = this.transforms[5]
  self.runeCreate_LvBtns = this.transforms[6]
  self.runeCreate_TypeBtns = this.transforms[7]
  self.runeCreate_BarRoot = this.transforms[8]
  self.runeCreate_CreateAndResolveCtrl = this.transforms[9] 
  self.createAndResolveCtrl_CreateBtn = this.transforms[10] 
  self.createAndResolveCtrl_ResolveBtn = this.transforms[11] 
  self.createAndResolveCtrl_CloseBtn = this.transforms[12] 
  self.createSuccessfulCtrl_ConfirmBtn = this.transforms[13] 
  self.runeCreate_PiLiangBtn = this.transforms[14] 
  self.runeSet_ShowInfo = this.transforms[15] --显示符文的全部加成属性
  self.runeSet_RuneEmptyHint = this.transforms[16] 
  self.runeSet_RuneChange = this.transforms[17] 
  self.runeSet_RuneSlots= this.transforms[18] --符文框
  self.runeSet_RuneBag = this.transforms[19]
  self.fx = this.transforms[22]
  self.runeRecommendBtn = this.transforms[23]

  self.runeRecommendCtrl = self.this.transform:Find("RuneRecommendCtrl")
  self.runeRecommendCtrlHeroIcon = self.runeRecommendCtrl:Find("Top/UpFrameInfo/IconFrame/Mask/HeroIcon")
  self.runeRecommendCtrlHeroName = self.runeRecommendCtrl:Find("Top/UpFrameInfo/RoleName")
  self.runeRecommendCtrlChangeHeroButton = self.runeRecommendCtrl:Find("Top/UpFrameInfo/ChangeButton")
  self.runeRecommendCtrlTypePanel = self.runeRecommendCtrl:Find("Top/UpFrameInfo/Panel")
  self.runeRecommendCtrlType1Button = self.runeRecommendCtrl:Find("Top/UpFrameInfo/Panel/Level1Button")
  self.runeRecommendCtrlType2Button = self.runeRecommendCtrl:Find("Top/UpFrameInfo/Panel/Level2Button")
  self.runeRecommendCtrlType3Button = self.runeRecommendCtrl:Find("Top/UpFrameInfo/Panel/Level3Button")
  self.runeRecommendCtrlType4Button = self.runeRecommendCtrl:Find("Top/UpFrameInfo/Panel/Level4Button")
  self.runeRecommendCtrlType5Button = self.runeRecommendCtrl:Find("Top/UpFrameInfo/Panel/Level5Button")

  self.runeRecommendCtrlMidHeroName = self.runeRecommendCtrl:Find("MidFrameInfo/Panel/HeroName")
  self.runeRecommendCtrlMidRuneLevel = self.runeRecommendCtrl:Find("MidFrameInfo/Panel/RuneLevel")
  self.runeRecommendCtrlPartPanel = self.runeRecommendCtrl:Find("MidFrameInfo/RunePanel")



  self.runeTypeRed = {}
  self.runeTypeBlue = {}
  self.runeTypeGreen = {}
  self.currentSelectRunes = {}
  self.count = 0      --用于获取下一个可用空芯片槽的计数

  self.canSend = true

end

function RuneCtrl:Start()


  if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end
  local btn = self.fx:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))
  for i = 0,btn.Length-1 do
    self.fx:GetComponentsInChildren(NTGLuaScript.GetType("UnityEngine.Renderer"))[i].material.shader = UnityEngine.Shader.Find(btn[i].material.shader.name)
  end

  UTGDataOperator.Instance.runeNotice = false
  if UTGMainPanelAPI ~= nil and UTGMainPanelAPI.Instance ~= nil then
    UTGMainPanelAPI.Instance:UpdateNotice()
  end


  self:Init()
end

function RuneCtrl:Init()
  self.ShowLv = 1
  self.ShowType = 0
  self.pageListIsOpen = false
  --是否正在交换芯片中
  self.InRuneChangeing = false
  
  --当前选择的芯片的Id
  self.selectedRuneId = 0
  --当前芯片组的Id
  --self.currPageDeckId = -1
  self.currPageDeckId = UTGDataTemporary.Instance().RunePageID
  --这个函数初始化了当前芯片组所以要放在前面调用
  self:UpdateRuneSlots()
  
  self:UpdateShowInfo()

  --几个频繁显示隐藏的面板放一起方便设置激活状态
  self.runeSetPanels = {self.runeSet_RuneEmptyHint,self.runeSet_ShowInfo,self.runeSet_RuneChange,self.runeSet_RuneBag}
  
  local hasRune = false
  for k,v in pairs(UTGData.Instance().RunesDeck) do
    if v.Amount > 0 then hasRune = true break end
  end

  if hasRune then
    self:ShowCurrSetPanel(2)
    self:UpdateShowInfo()
  else
    self:ShowCurrSetPanel(1)
  end


  
  local btns = {self.rune_BackBtn,self.rune_SetBtn, self.rune_CreateBtn,self.createAndResolveCtrl_CreateBtn, 
                self.createAndResolveCtrl_ResolveBtn,self.createAndResolveCtrl_CloseBtn,self.createSuccessfulCtrl_ConfirmBtn,self.runeCreate_PiLiangBtn,
                self.runeSet_RuneChange:FindChild("CloseBtn"), self.runeSet_RuneBag:FindChild("CloseBtn"), self.runeSet_ShowInfo:FindChild("BagBtn"),
                self.rune_SetCtrl:FindChild("PageBtn"),self.runeSet_RuneChange:FindChild("RemoveBtn"),self.runeSet_RuneChange:FindChild("ChangeBtn"),
                self.rune_SetCtrl:FindChild("RenameBtn"),self.rune_SetCtrl:FindChild("BuyPageBtn"),self.runeSet_RuneChange:FindChild("ChangeBtn"),
                self.runeSet_ShowInfo:FindChild("RemoveAllBtn"), self.runeSet_RuneBag:FindChild("ConfirmBtn"),self.runeSet_RuneBag:FindChild("GetRuneBtn"),
                self.runeSet_RuneEmptyHint:Find("GetRuneBtn"), self.runeRecommendBtn}  
  self:AddBtnsClickEvent(btns)
  
  --符文框的bg增加点击事件
  local slotBtns = {}
  for i = 0, self.runeSet_RuneSlots.childCount - 1, 1 do
    table.insert(slotBtns,self.runeSet_RuneSlots:GetChild(i):FindChild("Bg"))
  end
  self:AddBtnsClickEvent(slotBtns)
  
  local lvBtns = 
    {self.runeCreate_LvBtns:GetChild(0),self.runeCreate_LvBtns:GetChild(1),self.runeCreate_LvBtns:GetChild(2),self.runeCreate_LvBtns:GetChild(3),self.runeCreate_LvBtns:GetChild(4)}
  self:AddBtnsClickEvent(lvBtns)
  
  local typeBtns = {self.runeCreate_TypeBtns:GetChild(0),self.runeCreate_TypeBtns:GetChild(1),self.runeCreate_TypeBtns:GetChild(2),self.runeCreate_TypeBtns:GetChild(3),                    self.runeCreate_TypeBtns:GetChild(4),self.runeCreate_TypeBtns:GetChild(5),self.runeCreate_TypeBtns:GetChild(6),
                    self.runeCreate_TypeBtns:GetChild(7),self.runeCreate_TypeBtns:GetChild(8)}
  self:AddBtnsClickEvent(typeBtns)

end

function RuneCtrl:OnBackBtnClick()
  self:DestroySelf()
end

function RuneCtrl:GetCurrentPageSlots(pageId)     --许诺写
  -- body
  local slots = {}
  for k,v in pairs(UTGData.Instance().RuneSlotsDeck) do
    if v.RunePageDeckId == pageId then
      table.insert(slots,v)
    end
  end
  return slots
end

--更新showinfo面板和当前芯片组信息
function RuneCtrl:UpdateShowInfo()
  --设置2个显示当前芯片组总等级的Text
  local totalLv = 0
  for k,v in pairs(self:GetCurrentPageSlots(self.currPageDeckId)) do
    local runeId = v.RuneId
    if runeId > 0 then
      totalLv = totalLv +  UTGData.Instance().RunesData[tostring(runeId)].Level
    end
  end
  self.rune_SetCtrl:FindChild("LvTxt1"):GetComponent("UnityEngine.UI.Text").text = tostring(totalLv)
  self.rune_SetCtrl:FindChild("ShowInfos/LvTxt2"):GetComponent("UnityEngine.UI.Text").text = tostring(totalLv)
  self.rune_SetCtrl:FindChild("CurrPageName"):GetComponent("UnityEngine.UI.Text").text = UTGData.Instance().RunePagesDeck[tostring(self.currPageDeckId)].Name

  if totalLv == 0 then 
    self.runeSet_ShowInfo:FindChild("EmptyHint").gameObject:SetActive(true)
  else
    self.runeSet_ShowInfo:FindChild("EmptyHint").gameObject:SetActive(false)
  end

  local tongYongRoot = self.runeSet_ShowInfo:FindChild("TongYongInfos/TongYongRoot")
  local tongYongAttrTemp = tongYongRoot:FindChild("AttrTemp")
  local maoXianRoot = self.runeSet_ShowInfo:FindChild("MaoXianInfos/MaoXianRoot")
  local maoXianAttrTemp = maoXianRoot:FindChild("AttrTemp")

  for i=1,tongYongRoot.childCount - 1 do
    if tongYongRoot.childCount > 1 then
      GameObject.Destroy(tongYongRoot:GetChild(i).gameObject)
    end
  end

  for i=1,maoXianRoot.childCount - 1 do
    if maoXianRoot.childCount > 1 then
      GameObject.Destroy(maoXianRoot:GetChild(i).gameObject)
    end
  end

  local tongYongAttrTab = {}
  local maoXianAttrTab = {}

  for k0,v0 in pairs(self:GetCurrentPageSlots(self.currPageDeckId)) do
    local runeId = v0.RuneId
    if runeId > 0 then 

      local tongYongAttr = UTGData.Instance().RunesData[tostring(runeId)].PVPAttr
      local maoXianAttr = UTGData.Instance().RunesData[tostring(runeId)].PVEAttr

      for k,v in pairs(tongYongAttr) do
        local hasAttr = false
        for k1,v1 in pairs(tongYongAttrTab) do
          if k == k1 then 
            tongYongAttrTab[k1] = v1 + v
            hasAttr = true
            break
          end
        end
        if hasAttr == false then 
          tongYongAttrTab[k] = v
        end
      end

      for k,v in pairs(maoXianAttr) do
        local hasAttr = false
        for k1,v1 in pairs(maoXianAttrTab) do
          if k == k1 then 
            maoXianAttrTab[k1] = v1 + v
            hasAttr = true
            break
          end
        end
        if hasAttr == false then 
          maoXianAttrTab[k] = v
        end
      end

    end
  end

  for k,v in pairs(tongYongAttrTab) do
    if v > 0 then
      local go = GameObject.Instantiate(tongYongAttrTemp.gameObject)
      go:SetActive(true)
      go.transform:SetParent(tongYongRoot)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.zero

      attrName = UTGDataOperator.Instance:GetTemplateAttrCHSNameByKey(k)[1]
      if self:NeedBaiFenHao(k) then
        if v > 0 and v <= 0.1 then
          v = tostring(v * 100).."%"
        else
          v = v
        end
      end

      v = "+"..v

      go.transform:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = attrName
      go.transform:FindChild("Value"):GetComponent("UnityEngine.UI.Text").text = v
    end
  end

  for k,v in pairs(maoXianAttrTab) do
    if v > 0 then
      local go = GameObject.Instantiate(maoXianAttrTemp.gameObject)
      go:SetActive(true)
      go.transform:SetParent(maoXianRoot)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.zero

      attrName = UTGDataOperator.Instance:GetTemplateAttrCHSNameByKey(k)[1]
      if self:NeedBaiFenHao(k) then
        v = tostring(v * 100).."%"
      end

      v = "+"..v

      go.transform:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = UTGDataOperator.Instance:GetTemplateAttrCHSNameByKey(k)[1]
      go.transform:FindChild("Value"):GetComponent("UnityEngine.UI.Text").text = v
    end
  end

end

--更新芯片背包显示
--0:ALl 1:蓝 2：绿 3：红
function RuneCtrl:UpdateRuneBag(slotType)
  if self.rune_SetCtrl:FindChild("RuneBag").gameObject.activeInHierarchy == false then return end

  if slotType == 0 then
    self.runeSet_RuneBag:FindChild("Hint").gameObject:SetActive(false)
    self.runeSet_RuneBag:FindChild("GetRuneBtn").gameObject:SetActive(true)   
  else
    self.runeSet_RuneBag:FindChild("Hint").gameObject:SetActive(true)
    self.runeSet_RuneBag:FindChild("GetRuneBtn").gameObject:SetActive(false)  
  end

  if slotType == nil then 
    if  (self.selectSlotLv ~= nil and self.selectSlotLv >= 0) then
      slotType = self:GetSlotTypeByLv(self.selectSlotLv) 
    else 
      slotType = 0
    end
  end
  local barRoot = self.runeSet_RuneBag:FindChild("RuneInfos/Root")
  local barTemp = barRoot:FindChild("RuneInfoTemp")
  local needShowRunesDeck = UTGData.Instance().RunesDeck
  local needShowRunesDeckList = {}

  for i=1, barRoot.childCount - 1 do
    GameObject.Destroy(barRoot:GetChild(i).gameObject)
  end

  for k,v in pairs(needShowRunesDeck) do
    table.insert(needShowRunesDeckList, v)
  end

  local function allRuneSort(a,b)
    local aRune = UTGData.Instance().RunesData[tostring(a.RuneId )]
    local bRune = UTGData.Instance().RunesData[tostring(b.RuneId )]

    if aRune.Level == bRune.Level then
      if aRune.SlotType == bRune.SlotType then
        return aRune.Id < bRune.Id
      elseif aRune.SlotType == 3 then
        return true
      elseif aRune.SlotType == 1 then
        if bRune.SlotType == 2 then
          return true
        elseif bRune.SlotType == 3 then
          return false
        end
      elseif aRune.SlotType == 2 then
        return false
      end
    else
      return aRune.Level > bRune.Level
    end
  end

  local function runeSortByLvAndId(a,b)
    local aRune = UTGData.Instance().RunesData[tostring(a.RuneId)]
    local bRune = UTGData.Instance().RunesData[tostring(b.RuneId)]
    if aRune.Level == bRune.Level then
      return aRune.Id < bRune.Id
    else 
      return aRune.Level > bRune.Level
    end
  end

  if slotType == 0 then
   table.sort( needShowRunesDeckList, allRuneSort )
   --table.sort(needShowRunesDeckList,function (a,b) return a.RuneId > b.RuneId end)
  else
    local colorRunes = {}
    for k,v in pairs(needShowRunesDeckList) do
      if UTGData.Instance().RunesData[tostring(v.RuneId)].SlotType == slotType then
        table.insert(colorRunes, v)
      end

      if UTGData.Instance().RunesData[tostring(v.RuneId)].SlotType == 1 then
        table.insert(self.runeTypeRed,v)
      elseif UTGData.Instance().RunesData[tostring(v.RuneId)].SlotType == 2 then
        table.insert(self.runeTypeBlue,v)
      elseif UTGData.Instance().RunesData[tostring(v.RuneId)].SlotType == 3 then
        table.insert(self.runeTypeGreen,v)
      end

    end
    table.sort(colorRunes, runeSortByLvAndId)
    needShowRunesDeckList = colorRunes
    self.currentSelectRunes = colorRunes
  end


  local  showRunesIsEmpty = true

  for k,v in pairs(needShowRunesDeckList) do
    local count = v.Amount
    local runeId = v.RuneId
    local countTemp = 0--需要减去的数量

    --减去当前芯片组正在装备中的芯片的数量
    for k1,v1 in pairs(self:GetCurrentPageSlots(self.currPageDeckId)) do
      if v.RuneId == v1.RuneId then
       countTemp = countTemp + 1
      end
    end
    count = count - countTemp
    if count > 0 then  --当前这种符文还有剩余
      local barGo = GameObject.Instantiate(barTemp.gameObject)
      barGo.transform:SetParent(barRoot)
      barGo.transform.localScale = Vector3.one
      barGo.transform.localPosition = Vector3.zero
      barGo.gameObject:SetActive(true)
      barGo.name = tostring(runeId)
      
      local callback = function()
        --print("abcde")
        self:AddPointerClickEvent(barGo, RuneCtrl.BarClick)
      end
      UITools.GetLuaScript(barGo.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)

      local attrRoot = barGo.transform:FindChild("RuneInfoTemp/TongYongRoot")
    
      self:SetAttr(barGo.transform, "TongYongRoot", false, count, runeId)

      if showRunesIsEmpty then showRunesIsEmpty = false end

    end
  end

  barTemp.gameObject:SetActive(false)

  if showRunesIsEmpty then
    Debugger.Log("showRunesIsEmpty = true")
    self.runeSet_RuneBag:FindChild("Empty").gameObject:SetActive(true)
    --print(self.runeSet_RuneBag:FindChild("GetRuneBtn").name .. " " .. self.runeSet_RuneBag:FindChild("GetRuneBtn").parent.name)
    self.runeSet_RuneBag:FindChild("GetRuneBtn").gameObject:SetActive(true) 
    self.runeSet_RuneBag:FindChild("Hint").gameObject:SetActive(false)
  else
    Debugger.Log("showRunesIsEmpty = false")
    self.runeSet_RuneBag:FindChild("Empty").gameObject:SetActive(false)
    self.runeSet_RuneBag:FindChild("GetRuneBtn").gameObject:SetActive(false)
  end
end

function RuneCtrl:UpdateRuneSlots()
  --得出默认状态下应该显示的page
  if self.currPageDeckId == -1 then
    local pagesTemp = {}
    for k,v in pairs(UTGData.Instance().RunePagesDeck) do
      table.insert(pagesTemp, v)
    end
    self:SortById(pagesTemp)
    self.currPageDeckId = pagesTemp[1].Id
  end

  local currPage = UTGData.Instance().RunePagesDeck[tostring(self.currPageDeckId)]

  --luo保存当前符文选择页的id
  UTGDataTemporary.Instance().RunePageID = self.currPageDeckId

  --设置每个芯片槽的显示
  
  local slotState = -1
  local runeId = -1
  local slotType = -1
  
  for i = 0, self.runeSet_RuneSlots.childCount - 1, 1 do
    local slotGoLv = tonumber(self.runeSet_RuneSlots:GetChild(i).gameObject.name)
    
    for k,v in pairs(UTGData.Instance().RuneSlotsData) do
      if slotGoLv == v.ReqLevel then
        slotType = v.Type
      end
    end

    --第一次判断状态

    --许诺改,获取当前所有芯片页包含的芯片槽
    local slotsTemp = {}

    for k,v in pairs(UTGData.Instance().RuneSlotsDeck) do
      if v.RunePageDeckId == self.currPageDeckId then
        table.insert(slotsTemp,v)
      end
    end


    for k,v in pairs(slotsTemp) do
      local runeD = v
      local needLv = UTGData.Instance().RuneSlotsData[tostring(v.RuneSlotId)].ReqLevel
      runeId = runeD.RuneId

      if needLv == slotGoLv then
        if runeId > 0 then  
          slotState = 5
        else 
          slotState = 1
        end
        break
      else 
        slotState = 2
      end 
    end
    --第二次判断状态
    local needLvsTab = {}

    if type(currPage.NextSlotIds) ~= "userdata" then
      if #currPage.NextSlotIds > 0 then
        for k,v in pairs(currPage.NextSlotIds) do

          table.insert(needLvsTab, UTGData.Instance().RuneSlotsData[tostring(v)].ReqLevel)
        end
      end
    end

    local function lvSort(a, b)
      return a < b
    end  
    table.sort(needLvsTab, lvSort) 
  
    local minlv = needLvsTab[1]  --三种颜色芯片未开启最低等级的slot中最小的等级

    if self:IsContains(needLvsTab, slotGoLv) then
      if slotGoLv == minlv then
        slotState = 4
      else
        slotState = 3
      end
    end
    self:SetSlotState(self.runeSet_RuneSlots:GetChild(i), slotState , minlv, runeId, slotType)
  end
  
end

--1:空 2未解锁 3可购买 4可购买中最低等级 5:有芯片
function RuneCtrl:SetSlotState(slot, state, minLv, runeId, type)

  if state == -1 then return end
  slot:FindChild("Lock").gameObject:SetActive(false)
  slot:FindChild("Empty").gameObject:SetActive(false)
  slot:FindChild("NeedBuy").gameObject:SetActive(false)
  slot:FindChild("NeedLvTxt").gameObject:SetActive(false)
  slot:FindChild("Icon").gameObject:SetActive(false)
  
  if state == 1 then slot:FindChild("Empty").gameObject:SetActive(true) end
  if state == 2 then slot:FindChild("Lock").gameObject:SetActive(true) end
  if state == 3 then slot:FindChild("NeedBuy").gameObject:SetActive(true) end
  if state == 4 then
    slot:FindChild("NeedLvTxt").gameObject:SetActive(true) 
    slot:FindChild("NeedLvTxt"):GetComponent("UnityEngine.UI.Text").text = "Lv"..tostring(minLv)
  end
  if state == 5 then slot:FindChild("Icon").gameObject:SetActive(true)
                  --print("aaaaaaa " .. UTGData.Instance().RunesData[tostring(runeId)].Icon) 
                  slot:FindChild("Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("runeicon",UTGData.Instance().RunesData[tostring(runeId)].Icon)   end
  end

--获得芯片组所有装备芯片的总等级
--[[
function RuneCtrl:GetPageRunesLv(runePageDeck)
  local lv = 0
  for k,v in pairs(runePageDeck.Slots) do
    local runeId = UTGData.Instance().RuneSlotsDeck[tostring(v)].RuneId
    if runeId > 0 then
      lv = lv + UTGData.Instance().RunesData[tostring(runeId)].Level
    end
  end
  return lv
end
]]

function RuneCtrl:ShowCurrSetPanel(i)
  for k,v in pairs(self.runeSetPanels) do 
    if k == i then 
      v.gameObject:SetActive(true)
    else
      v.gameObject:SetActive(false)
    end
  end
end

function RuneCtrl:AddBtnsClickEvent(btns)
  local listener
  for k,v in pairs(btns) do
    self:AddPointerClickEvent(v.gameObject, RuneCtrl.BtnClick)
  end
end

function RuneCtrl:AddPointerClickEvent(go, func)
  local listener = NTGEventTriggerProxy.Get(go)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(func, self)
end

function RuneCtrl:DestroySelf()
  UTGDataOperator.Instance:SetPreUIRight(self.this.transform.parent)
  GameObject.Destroy(self.this.transform.parent.gameObject)
end

function RuneCtrl:BtnClick()
  if UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject == nil then return end
  local btnName = tostring(UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject.name)
  local btnGo = UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject
  if btnName == "Rune_SetBtn" then
    self.rune_SetBtn:FindChild("Select").gameObject:SetActive(true)
    self.rune_CreateBtn:FindChild("Select").gameObject:SetActive(false)
    self.runeRecommendBtn:Find("Select").gameObject:SetActive(false)
    self.rune_SetCtrl:FindChild("PageList").gameObject:SetActive(false)
    self.rune_CreateCtrl.gameObject:SetActive(false)
    self.rune_SetCtrl.gameObject:SetActive(true)
    self.runeRecommendCtrl.gameObject:SetActive(false)
    self.selectedRuneId = -1

    NormalResourceAPI.Instance:InitResource(0)

    self:ShowCurrSetPanel(2)
    self.selectSlotLv = -1
    self:SetSlotSelectByLv(-1)
    if self.InRuneChangeing then 
      self.rune_SetCtrl:FindChild("Change").gameObject:SetActive(false)
      self.rune_SetCtrl:FindChild("Selected").gameObject:SetActive(false)
      self.rune_SetCtrl:FindChild("JianTou").gameObject:SetActive(false)
      self.rune_SetCtrl:FindChild("RuneSlots").gameObject:SetActive(true)
      self.InRuneChangeing = false
    end 

    return
  end


  if btnGo.transform.parent.name == "RuneChange" then 
    if btnName == "RemoveBtn" then 
      if self.selectSlotLv ~= nil and self.selectSlotLv >= 0 then
        self:SendUnLoadRuneReq()
      end
    end
    if btnName == "ChangeBtn" then 
      self:ShowCurrSetPanel(4)
      self.InRuneChangeing = true
      self.runeSet_RuneSlots.gameObject:SetActive(false)
      local selected = self.rune_SetCtrl:FindChild("Selected")
      selected.gameObject:SetActive(true)
      self.rune_SetCtrl:FindChild("JianTou").gameObject:SetActive(true)
      local change = self.rune_SetCtrl:FindChild("Change")
      change.gameObject:SetActive(false)
      local selectedRuneId = self:GetRuneInfoBySlotLv(self.selectSlotLv).Id

      self:SetAttr(selected, "TongYongRoot", true, -1, selectedRuneId)

      self:SetAttr(selected, "MaoXianRoot", true, -1, selectedRuneId)

      self.rune_SetCtrl:FindChild("JianTou").gameObject:SetActive(true)

      local slotType = self:GetSlotTypeByLv(self.selectSlotLv)
      self:UpdateRuneBag(slotType)

      self.runeSet_RuneBag:FindChild("GetRuneBtn").gameObject:SetActive(false)
      self.runeSet_RuneBag:FindChild("Hint").gameObject:SetActive(true)
      self.runeSet_RuneBag:FindChild("ConfirmBtn").gameObject:SetActive(false)

    end
    if btnName == "CloseBtn" then
      self:ShowCurrSetPanel(2)
      self.selectSlotLv = -1
      self:SetSlotSelectByLv(-1)
    end
  end 

  if btnName == "Rune_BackBtn" then 
    self:DestroySelf()
    UTGMainPanelAPI.Instance:ShowSelf()
    return
  end 
  
  if btnName == "Rune_CreateBtn" then 
    self.rune_SetBtn:FindChild("Select").gameObject:SetActive(false)
    self.rune_CreateBtn:FindChild("Select").gameObject:SetActive(true)
    self.runeRecommendBtn:Find("Select").gameObject:SetActive(false)
    self.rune_SetCtrl.gameObject:SetActive(false)
    self.rune_CreateCtrl.gameObject:SetActive(true)
    self.runeRecommendCtrl.gameObject:SetActive(false)
    self:UpdateCreateRune()

    NormalResourceAPI.Instance:InitResource(1)
    return
  end

  if btnName == "GetRuneBtn" then
    local function CreatePanelAsync()
      local async = GameManager.CreatePanelAsync("Store")
      while async.Done == false do
        coroutine.step()
      end
      if StoreCtrl ~= nil and StoreCtrl.Instance ~= nil then
        StoreCtrl.Instance:GoToUI(5)
      end      
    end
    coroutine.start(CreatePanelAsync,self)    
  end

  if btnName == "Rune_RecommendBtn" then 
    self.rune_SetBtn:FindChild("Select").gameObject:SetActive(false)
    self.rune_CreateBtn:FindChild("Select").gameObject:SetActive(false)
    self.runeRecommendBtn:Find("Select").gameObject:SetActive(true)
    self.rune_SetCtrl.gameObject:SetActive(false)
    self.rune_CreateCtrl.gameObject:SetActive(false)
    self.runeRecommendCtrl.gameObject:SetActive(true)

    if self.selectRole ~= nil then
      self:InitRuneRecommend(self.selectRole)
    else
      self:InitRuneRecommend(10000001)
    end    
  end 
  
  if btnGo.transform.parent.name == "LvBtns" then
    self.ShowLv = tonumber(btnName)
    self:UpdateCreateRune()
    for i = 0, 4, 1 do
      btnGo.transform.parent:GetChild(i):GetComponent("UnityEngine.UI.Image").color = Color.gray
      if self.ShowLv == (i + 1) then btnGo.transform.parent:GetChild(i):GetComponent("UnityEngine.UI.Image").color = Color.white end
    end
    return
  end
  
  if btnGo.transform.parent.name == "TypeBtns" then
    self.ShowType = tonumber(btnName)
    self:UpdateCreateRune()
    for i = 0, 8, 1 do
      btnGo.transform.parent:GetChild(i):FindChild("Select").gameObject:SetActive(false)
      btnGo.transform.parent:GetChild(i):FindChild("Name").gameObject:SetActive(true)     
    end
    btnGo.transform:FindChild("Select").gameObject:SetActive(true)
    btnGo.transform:FindChild("Name").gameObject:SetActive(false)     
    return
  end
  
  if btnGo.transform.parent.name == "CreateSuccessfulCtrl" then
    if btnName == "ConfirmBtn" then
      local function anonyFunc(args)
        self.rune_CreateSuccessfulCtrl.gameObject:SetActive(false)
      end
      UTGDataOperator.Instance:NewAchievePanelOpen(anonyFunc)
    end
  end

  if btnGo.transform.parent.name == "ShowInfos" then
    --print("555555555555")
    if btnName == "BagBtn" then
      self:ShowCurrSetPanel(4)
      self:UpdateRuneBag(0)
    end
    if btnName == "RemoveAllBtn" then
      local instance = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
      self.dialogInstance = instance
      instance:InitNoticeForNeedConfirmNotice("提示", "确定一键拆卸当前芯片组所有芯片吗？", false, "", 2)
      instance:TwoButtonEvent("取消", instance.DestroySelf, instance, "确认", RuneCtrl.SendUnLoadAllRuneReq, self)
    end
  end

  if btnGo.transform.parent.name == "RuneBag" then
    if btnName == "CloseBtn" then
      self:ShowCurrSetPanel(2)
      self.selectSlotLv = -1
      self:SetSlotSelectByLv(-1)
      if self.InRuneChangeing then 
        self.rune_SetCtrl:FindChild("Change").gameObject:SetActive(false)
        self.rune_SetCtrl:FindChild("Selected").gameObject:SetActive(false)
        self.rune_SetCtrl:FindChild("JianTou").gameObject:SetActive(false)
        self.rune_SetCtrl:FindChild("RuneSlots").gameObject:SetActive(true)
        self.InRuneChangeing = false
      end 
    end
    if btnName == "ConfirmBtn" then
      self:SendLoadRuneReq(self.changeRuneId, self.selectRuneGo)
    end
  end

  if btnGo.transform.parent.name == "RuneSetCtrl" then
    if btnName == "PageBtn" then
      local pageList = self.rune_SetCtrl:FindChild("PageList")
      pageList.gameObject:SetActive(not self.pageListIsOpen)
      self.pageListIsOpen = not self.pageListIsOpen
      if self.pageListIsOpen then
        self:UpdatePageList()
      end
    end

    if btnName == "RenameBtn" then 
      local function CreatePanelAsync()
        local async = GameManager.CreatePanelAsync("RunePageChangeName")
        while async.Done == false do
          coroutine.wait(0.05)
        end
        if RunePageChangeNameAPI ~= nil and RunePageChangeNameAPI.Instance ~= nil then
          local pageName = UTGData.Instance().RunePagesDeck[tostring(self.currPageDeckId)].Name
          RunePageChangeNameAPI.Instance:SetParamBy69(self.currPageDeckId, pageName)
        end
      end
      coroutine.start(CreatePanelAsync,self)
    end

    if btnName == "BuyPageBtn" then 
      local instance = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
      self.dialogInstance = instance
      local price = UTGData.Instance().ConfigData["rune_page_price"].Int
      instance:InitNoticeForNeedConfirmNotice("提示", "确认花费<color=#FFC125>"..tostring(price).."</color>钻石购买芯片组吗？", false, "", 2)
      instance:TwoButtonEvent("取消", instance.DestroySelf, instance, "确认", function()
                  self:SendBuyRunePageReq()
                  instance:DestroySelf()
                end, self)
      instance:SetTextToCenter()
      -- local function CreatePanelAsync()
      --   local async = GameManager.CreatePanelAsync("NeedConfirmNotice")
      --   while async.Done == false do
      --     coroutine.yield(WaitForSeconds.New(0.05))
      --   end
      --   if NoticeAPI ~= nil and NoticeAPI.Instance ~= nil then
      --     NoticeAPI.Instance:InitNoticeForNeedConfirmNotice("提示", "确定购买芯片组吗", false, "", 2)
      --     NoticeAPI.Instance:TwoButtonEvent("取消", NoticeAPI.DestroySelf, NoticeAPI.Instance, "确认", RuneCtrl.SendBuyRunePageReq, self)
      --   end
      -- end

      -- self.this:StartCoroutine(NTGLuaCoroutine.New(self, CreatePanelAsync))
    end 

  end
  
  if btnGo.transform.parent.name == "CreateAndResolveCtrl" then
    if btnName == "CloseBtn" then
      self.runeCreate_CreateAndResolveCtrl.gameObject:SetActive(false)
    end
    
    if btnName == "CreateBtn" then
      local content = JObject.New(JProperty.New("Type","RequestComposeRune"),
                                  JProperty.New("RuneId", self.selectedRuneId))
      function  RuneCtrl:RequestComposeRuneHandler(e)
        --Debugger.LogError("收到芯片制作响应")
        if e.Type == "RequestComposeRune" then
          local result = tonumber(e.Content:get_Item("Result"):ToString())
          if result == 1 then      
            --Debugger.LogError("芯片制作成功")
            self.rune_CreateSuccessfulCtrl.gameObject:SetActive(true)
            self:SetAttr(self.rune_CreateSuccessfulCtrl, "TongYongRoot", true, -1, self.selectedRuneId)
            if self.runeRecommendFlag == true then
              self:UpdateRunesOnCurrentLevel(self.partNum,self.selectedRuneId)
            end
            return true
          elseif result == 264 then
            local function CreatePanelAsync()
              local async = GameManager.CreatePanelAsync("SelfHideNotice")
              while async.Done == false do
                coroutine.wait(0.05)
              end
              if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
                SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("芯片碎片不足") 
              end
            end
            coroutine.start(CreatePanelAsync, self)
            return true
          elseif result == 1291 then
            local function CreatePanelAsync()
              local async = GameManager.CreatePanelAsync("SelfHideNotice")
              while async.Done == false do
                coroutine.wait(0.05)
              end
              if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
                SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("芯片数量已达上限") 
              end
            end
            coroutine.start(CreatePanelAsync,self)
            return true
          end
        end
        return false
      end
      self:SendRequest(content, RuneCtrl.RequestComposeRuneHandler)
    end
    
    if  btnName == "ResolveBtn" then
      local instance = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
      self.dialogInstance = instance
      local msg = "确认要分解该芯片吗？"
      local hasPage = false
      --已被的芯片组的数量
      local pageCount = 0
      local pageEquipInfo = ""
      local tempRuneDeck = {}
      for k,v in pairs(UTGData.Instance().RunePagesDeck) do
        table.insert(tempRuneDeck,v)
      end

      table.sort(tempRuneDeck,function(a,b) return a.Id < b.Id end)

      for k,v in pairs(tempRuneDeck) do
        local equipCount = 0
        for k1,v1 in pairs(self:GetCurrentPageSlots(v.RunePageId)) do
          local runeId = v1.RuneId
          if self.selectedRuneId == runeId then
            equipCount = equipCount + 1
          end
        end

        local runeCount = 0
        for k2,v2 in pairs(UTGData.Instance().RunesDeck) do
          if v2.RuneId == self.selectedRuneId then
            runeCount = self:GetRuneCountByDeckId(v2.RuneId)
          end
        end

        if equipCount > 0 and equipCount == runeCount then
          pageCount = pageCount + 1          
          if pageCount < 4 then
            pageEquipInfo = pageEquipInfo..v.Name..";"
          elseif pageCount == 4 then
            pageEquipInfo = pageEquipInfo.."..."
          end
        end
      end
      if pageCount > 0 then msg = "是否确定分解？该芯片已装配于以下芯片组：" end
      instance:InitNoticeForNeedConfirmNotice("提示", msg, true, pageEquipInfo, 2)
      instance:TwoButtonEvent("取消", instance.DestroySelf, instance, "确认", RuneCtrl.SendDecomposeRuneReq, self)
      instance:SetTextToCenter()
    end
  end
  
  if btnName == "PiLiangBtn" then 
    local function CreatePanelAsync()
            local async = GameManager.CreatePanelAsync("BreakRune")
            while async.Done == false do
              coroutine.wait(0.05)
            end
            if BreakRuneAPI ~= nil and BreakRuneAPI.Instance ~= nil then
              --Debugger.LogError("批量面板创建成功")
            end
          end
    coroutine.start(CreatePanelAsync, self)
  end

  if btnGo.transform.parent.parent.name == "RuneSlots" then
    local slotLv = tonumber(btnGo.transform.parent.name)
    self:OnSlotSelect(slotLv)
    
  end
  
end

function RuneCtrl:SendDecomposeRuneReq()
  self.dialogInstance:DestroySelf()
  local content = JObject.New(JProperty.New("Type","RequestDecomposeRune"),
                                    JProperty.New("RuneId", self.selectedRuneId))
  function  RuneCtrl:RequestDecomposeRuneHandler(e)
    --Debugger.LogError("收到芯片分解响应")
    if e.Type == "RequestDecomposeRune" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then      
        --Debugger.LogError("芯片分解成功")
        local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("BreakRuneGetPiece")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if BreakRuneGetPieceAPI ~= nil and BreakRuneGetPieceAPI.Instance ~= nil then
            local runeInfo = UTGData.Instance().RunesData[tostring(self.selectedRuneId)]
            --Debugger.LogError("分解获得"..tostring(runeInfo.DecomposePiece))
            BreakRuneGetPieceAPI.Instance:ShowUI(tonumber(runeInfo.DecomposePiece))
          end

          if self.runeRecommendFlag == true then
            self:UpdateRunesOnCurrentLevel(self.partNum,self.selectedRuneId)
          end
        end
        coroutine.start(CreatePanelAsync, self)
        return true
      end
    end
    return false
  end
  self:SendRequest(content, RuneCtrl.RequestDecomposeRuneHandler)
end

function RuneCtrl:SendBuyRunePageReq()

  local price = UTGData.Instance().ConfigData["rune_page_price"].Int
  if price > UTGData.Instance().PlayerData.Gem and UTGDataOperator.Instance.canBuy == false then
    UTGDataOperator.Instance:VoucherToGemNotice(price,4,self.SendBuyRunePageReq,self)
    return    
  end

  local content = JObject.New(JProperty.New("Type","RequestBuyRunePage"))

  function RuneCtrl:BuyRunePageHandler(e)
    --self.dialogInstance:DestroySelf()
    --Debugger.LogError("收到芯片组购买响应")
    if e.Type == "RequestBuyRunePage" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then   
        --Debugger.LogError("芯片组购买成功")
        local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("SelfHideNotice")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("芯片组购买成功") 
          end
        end
        coroutine.start(CreatePanelAsync, self)
        return true
      elseif result == 1292 then
        GameManager.CreatePanel("SelfHideNotice")
        if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("当前已达到最大购买上限") 
        end
        return true        
      else
        local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("SelfHideNotice")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("芯片组购买失败") 
          end
        end
        coroutine.start(CreatePanelAsync, self)
        return true
      end
    end
    return false
  end

  self:SendRequest(content, RuneCtrl.BuyRunePageHandler)
end


--更新pageList显示
function RuneCtrl:UpdatePageList()
  if self.rune_SetCtrl:FindChild("PageList").gameObject.activeInHierarchy == false then return end

  if self.pageListIsOpen == false then return end
  local pageRoot = self.rune_SetCtrl:FindChild("PageList/Root")
  --因为不移动root他的图片就不显示出来所以在这里移动
  pageRoot.localPosition = Vector3.New(109.7, 100, 0)

  local pageTemp = pageRoot:FindChild("PageTemp")
  local pageHint = pageRoot:FindChild("Hint")

  for i=2,pageRoot.childCount - 1 do
    if pageRoot.childCount > 2 then GameObject.Destroy(pageRoot:GetChild(i).gameObject) end
  end

  local pagesTemp = {}
  for k,v in pairs(UTGData.Instance().RunePagesDeck) do

    table.insert(pagesTemp, v)
  end
  self:SortById(pagesTemp)

  for k,v in ipairs(pagesTemp) do
    local pageGo = GameObject.Instantiate(pageTemp.gameObject)
    pageGo.transform:SetParent(pageRoot)
    pageGo.transform.localScale = Vector3.one
    pageGo.transform.localPosition = Vector3.zero
    pageGo.gameObject:SetActive(true)

    local callback = function()
      self:AddPointerClickEvent(pageGo, RuneCtrl.BarClick)
    end
    UITools.GetLuaScript(pageGo.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)

    pageGo.name = v.Id

    local  totalLv = 0
    for k1,v1 in pairs(self:GetCurrentPageSlots(v.Id)) do
      local runeId = v1.RuneId
      if runeId > 0 then
        totalLv = totalLv +  UTGData.Instance().RunesData[tostring(runeId)].Level
      end
    end
    pageGo.transform:FindChild("LvTxt"):GetComponent("UnityEngine.UI.Text").text = tostring(totalLv)
    pageGo.transform:FindChild("PageName"):GetComponent("UnityEngine.UI.Text").text = v.Name
  end

  if UTGData.Instance().PlayerData.Level < 10 then
    local hintGo = GameObject.Instantiate(pageHint)
    hintGo.transform:SetParent(pageRoot)
    hintGo.transform.localScale = Vector3.one
    hintGo.transform.localPosition = Vector3.zero
    hintGo.gameObject:SetActive(true)
  end
end

function RuneCtrl:GetSlotTypeByLv(slotLv)
  local slotType = -1
  for k,v in pairs(UTGData.Instance().RuneSlotsData) do
      if slotLv == v.ReqLevel then
        slotType = v.Type
        return slotType
      end
  end
end

function RuneCtrl:GetSlotCostBySlotLv(slotLv)
  for k,v in pairs(UTGData.Instance().RuneSlotsData) do
    if slotLv == v.ReqLevel then
      return v.Cost
    end
  end
end

function RuneCtrl:GetSlotStateByLv(slotLv)
  local slotState = -1
  
  local slotId = -1
  local runeID = -1

  for k,v in pairs(UTGData.Instance().RuneSlotsData) do
    if slotLv == v.ReqLevel then 
      slotId = v.Id
    end
  end

  for k,v in pairs(UTGData.Instance().RuneSlotsDeck) do
    if slotId == v.RuneSlotId and v.RunePageDeckId == self.currPageDeckId then 
      runeID = v.RuneId
      if runeID > 0 then
        slotState = 5
      else
        slotState = 1
      end
      return slotState
    end
  end

  local currPage = UTGData.Instance().RunePagesDeck[tostring(self.currPageDeckId)]

  local needLvsTab = {}
  if #currPage.NextSlotIds > 0 then
    for k,v in pairs(currPage.NextSlotIds) do
      table.insert(needLvsTab, UTGData.Instance().RuneSlotsData[tostring(v)].ReqLevel)
    end
  end

  local function lvSort(a, b)
    return a < b
  end  
  table.sort(needLvsTab, lvSort)
  
  local minlv = needLvsTab[1]  --三种颜色芯片未开启最低等级的slot中最小的等级                                                                                       

  if self:IsContains(needLvsTab, slotLv) then
    if slotLv == minlv then
      slotState = 4
    else
      slotState = 3
    end
  else
    slotState = 2
  end

  return slotState

end

--选中的槽 slotLv：槽的标号
function RuneCtrl:OnSlotSelect(slotLv)
  local state = self:GetSlotStateByLv(slotLv)

  if state == 1 or state == 5 then
    --当前选择的slot
    self.selectSlotLv = slotLv
  end

  if state == 1 then 
    self:ShowCurrSetPanel(4)
    self.GetSlotTypeByLv(slotLv)
    self:UpdateRuneBag(self:GetSlotTypeByLv(slotLv))
    Debugger.Log("Click empty slot")--luo点击到空槽
    --self.runeSet_RuneBag:FindChild("GetRuneBtn").gameObject:SetActive(false)
  end
  if state == 2 then  
    local function CreatePanelAsync()
      local async = GameManager.CreatePanelAsync("SelfHideNotice")
      while async.Done == false do
        coroutine.wait(0.05)
      end
      if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
        SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("玩家等级达到"..tostring(slotLv).."级时会解锁此芯片槽") 
      end
    end
    coroutine.start(CreatePanelAsync, self)
  end
  if state == 3 or state == 4 then 
    self.selectSlotLv = slotLv
    local cost = self:GetSlotCostBySlotLv(slotLv)
    local slotType = self:GetSlotTypeByLv(slotLv)
    local runeColor
    if slotType == 1 then runeColor = "蓝色" end
    if slotType == 2 then runeColor = "绿色" end
    if slotType == 3 then runeColor = "红色" end
    local instance = UTGDataOperator.Instance:CreateDialog("NeedConfirmNotice")
    self.dialogInstance = instance
    instance:InitNoticeForNeedConfirmNotice("提示", "确定花费<color=#FFC125>"..tostring(cost[1][2]).."</color>钻石提前开启一个"..runeColor.."芯片槽吗?", false, "", 2)
    instance:TwoButtonEvent("取消", instance.DestroySelf, instance, "确认", RuneCtrl.SendBuyRuneSlotReq, self)
    instance:SetTextToCenter() 
  end
  if state == 5 then  
    self:ShowCurrSetPanel(3)
    self:SetRuneInfo()
  end

  --设置被选择图片
  if state == 1 or state == 5 then
    for i=0,self.runeSet_RuneSlots.childCount - 1 do
      local slot = self.runeSet_RuneSlots:GetChild(i)
      if self.selectSlotLv == tonumber(slot.name) then
        slot:FindChild("Select").gameObject:SetActive(true)
      else
        slot:FindChild("Select").gameObject:SetActive(false)
      end
    end
  end
  
end

--Todo
function RuneCtrl:SendBuyRuneSlotReq()
  --print(tostring(self.alreadyDelete) .. "self.alreadyDelete")
  if self.alreadyDelete ~= true then
    self.dialogInstance:DestroySelf()
  end
  local slotId = self:GetSlotIdByLv(self.selectSlotLv)
  if UTGData.Instance().RuneSlotsData[tostring(slotId)].Cost[1][2] > UTGData.Instance().PlayerData.Gem and UTGDataOperator.Instance.canBuy == false then
    UTGDataOperator.Instance:VoucherToGemNotice(UTGData.Instance().RuneSlotsData[tostring(slotId)].Cost[1][2],4,self.SendBuyRuneSlotReq,self)
    self.alreadyDelete = true
    return
  end



  local content = JObject.New(JProperty.New("Type","RequestBuyRuneSlot"),
                              JProperty.New("RunePageDeckId", self.currPageDeckId),
                              JProperty.New("RuneSlotId", slotId))

  function  RuneCtrl:RequestBuyRuneSlotHandler(e)
    --Debugger.LogError("收到购买芯片槽响应")
    if e.Type == "RequestBuyRuneSlot" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then      
        --Debugger.LogError("购买芯片组成功")
        local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("SelfHideNotice")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("购买芯片槽成功") 
          end
        end
        self.alreadyDelete = false
        coroutine.start(CreatePanelAsync,self)

        --self:UpdateRuneSlots()
        --self:ShowCurrSetPanel(2)
        --self:UpdateShowInfo()

        --把被选择的芯片槽重置
        --self:SetSlotSelectByLv(-1)
        return true
      else
        local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("SelfHideNotice")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("指挥官只能拥有20个芯片组哦~") 
          end
        end
        self.alreadyDelete = false
        coroutine.start(CreatePanelAsync, self)
        return true
      end
    end
    return false
  end

  self:SendRequest(content, RuneCtrl.RequestBuyRuneSlotHandler)
end

--选中芯片槽中芯片时展示的信息
function RuneCtrl:SetRuneInfo()
  local window = self.runeSet_RuneChange
  local rune = self:GetRuneInfoBySlotLv(self.selectSlotLv)
  local runeId = rune.Id
  self:SetAttrToSelectedRunedInSlot(window:FindChild("TongYongInfos"),"TongYongRoot", false, -1, runeId)
  self:SetAttrToSelectedRunedInSlot(window:FindChild("MaoXianInfos"),"MaoXianRoot", false, -1, runeId)
  window:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = rune.Name
  window:FindChild("Lv"):GetComponent("UnityEngine.UI.Text").text = rune.Level
end

function RuneCtrl:BarClick()
  if UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject == nil then return end
  local barName = tostring(UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject.name)
  local barGo = UnityEngine.EventSystems.EventSystem.current.currentSelectedGameObject
  self.selectRuneGo = barGo
  
  if barGo.transform.parent.parent.name == "RuneCreate_BarList" then
    self.selectedRuneId = tonumber(barName)
    self:ShowCreateAndResolveWindow()
    --print("111111111")
    return
  end

  if barGo.transform.parent.parent.name == "PageList" then
    self.currPageDeckId = tonumber(barName)
    self:ShowCurrSetPanel(2)
    --self:UpdateRuneBag()
    self:UpdateRuneSlots()
    --self:UpdatePageList()
    self:UpdateShowInfo()

    local pageList = self.rune_SetCtrl:FindChild("PageList")
    pageList.gameObject:SetActive(false)
    self.pageListIsOpen = false

    self.selectSlotLv = -1
    self:SetSlotSelectByLv(-1)
    return
  end

  if barGo.transform.parent.parent.name == "RuneInfos" then
    --print("dddddddddddddddddd")
    local runeId = tonumber(barGo.name)
    Debugger.Log("runeId = "..runeId)

    --当前没有选中符文槽
    if self.selectSlotLv == nil or self.selectSlotLv == -1 then
      local emptySloctID = self:EmptySlotGet(runeId) --根据我当前选中的符文，寻找对应的一个type的插槽
      if (emptySloctID == -1) then 
        GameManager.CreatePanel("SelfHideNotice")
        if SelfHideNoticeAPI~= nil and SelfHideNoticeAPI.Instance~= nil then
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("无可用芯片槽")
        end
      elseif (emptySloctID >= 0) then
        --self.selectSlotLv = emptySloctID
        self:SendLoadRuneWithNoSelectSlot(runeId, barGo,emptySloctID)
      end
    end

    --当前有选中符文槽
    if self.selectSlotLv ~= nil and self.selectSlotLv >= 0 then
      --print("self.selectSlotLv " .. self.selectSlotLv)
      if self:GetSlotStateByLv(self.selectSlotLv) == 1 then self:SendLoadRuneReq(runeId, barGo)
      elseif self:GetSlotStateByLv(self.selectSlotLv) == 2 then
        GameManager.CreatePanel("SelfHideNotice")
        if SelfHideNoticeAPI~= nil and SelfHideNoticeAPI.Instance~= nil then
          SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("槽位未开启")
        end
      end
    end
    if self.InRuneChangeing then
      local change = self.rune_SetCtrl:FindChild("Change")
      --要更换的芯片的Id
      self.changeRuneId = runeId
      change.gameObject:SetActive(true)
      self:SetAttr(change, "TongYongRoot", true, -1, runeId)
      self:SetAttr(change, "MaoXianRoot", true, -1, runeId)

      self.runeSet_RuneBag:FindChild("Hint").gameObject:SetActive(false)
      self.runeSet_RuneBag:FindChild("GetRuneBtn").gameObject:SetActive(false)
      self.runeSet_RuneBag:FindChild("ConfirmBtn").gameObject:SetActive(true)
    end
    -- else
    --   self.runeSet_RuneBag:FindChild("Hint").gameObject:SetActive(true)
    --   self.runeSet_RuneBag:FindChild("GetRuneBtn").gameObject:SetActive(false)
    --   self.runeSet_RuneBag:FindChild("ConfirmBtn").gameObject:SetActive(false)
    -- end
    return
  end
end

function RuneCtrl:SendLoadRuneReq(runeId,runeGo)
  --非法判断
  --if self:GetSlotStateByLv(self.selectSlotLv) ~= 1 then return end
  if self.canSend == true then
    self.canSend = false
  else
    return 
  end

  local slotDeckId = self:GetSlotDeckIdByLv(self.selectSlotLv)

  local runeName,runeLv = self:GetRuneNameAndLvByRuneId(runeId)
  local runeInfo = "<color=#00FF00>".."穿戴"..runeLv.."级芯片:"..runeName.."</color>\n"
  local attrRoot = runeGo.transform:FindChild("TongYongRoot")
  local attrInfos = ""
  for i=1,attrRoot.childCount -1 do
    attr = attrRoot:GetChild(i)
    attrInfos = attrInfos..attr:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text
    attrInfos = attrInfos..attr:FindChild("Value"):GetComponent("UnityEngine.UI.Text").text
  end

  local content = JObject.New(JProperty.New("Type","RequestLoadRune"),
                              JProperty.New("RuneSlotDeckId", slotDeckId),
                              JProperty.New("RuneId", runeId))

  function  RuneCtrl:RequestLoadRuneHandler(e)
    --Debugger.LogError("收到芯片装载响应")
    self.InRuneChangeing = false
    if e.Type == "RequestLoadRune" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then      
        --Debugger.LogError("芯片装载成功")
        local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("SelfHideNotice")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice(runeInfo..attrInfos) 
          end
        end
        coroutine.start(CreatePanelAsync,self)

        self.rune_SetCtrl:FindChild("Selected").gameObject:SetActive(false)
        self.rune_SetCtrl:FindChild("JianTou").gameObject:SetActive(false)
        self.rune_SetCtrl:FindChild("Change").gameObject:SetActive(false)
        self.rune_SetCtrl:FindChild("RuneSlots").gameObject:SetActive(true)
        self.runeSet_RuneBag:FindChild("ConfirmBtn").gameObject:SetActive(false)

        --self:ShowCurrSetPanel(2)

        --把被选择的芯片槽重置
        --self:SetSlotSelectByLv(-1)

        --自动选择下一个空芯片槽如果没有则显示当前芯片组总属性页
        local slotsDataTemp = UTGData.Instance().RuneSlotsDeck

        local blueSlots = {}
        local greenSlots = {}
        local redSlots = {}

        for k,v in pairs(slotsDataTemp) do
          local slotType = UTGData.Instance().RuneSlotsData[tostring(v.RuneSlotId)].Type
          local runeId = v.RuneId
          if v.RunePageDeckId == self.currPageDeckId and runeId < 0 then
            if slotType == 1 then
              table.insert(blueSlots, v) 
            elseif slotType == 2 then
              table.insert(greenSlots, v)
            elseif slotType == 3 then
              table.insert(redSlots, v)
            end
          end
        end

        local function sortByLv(a,b)
          return UTGData.Instance().RuneSlotsData[tostring(a.RuneSlotId)].ReqLevel < UTGData.Instance().RuneSlotsData[tostring(b.RuneSlotId)].ReqLevel
        end 

        table.sort(blueSlots, sortByLv)
        table.sort(greenSlots, sortByLv)
        table.sort(redSlots, sortByLv)

        local slotTypeTemp = self:GetSlotTypeByLv(self.selectSlotLv)
        --print("slotTypeTemp " .. slotTypeTemp)
        slotTypeTemp = self:GetNextAvaliableRuneSlotType(slotTypeTemp)
        --print("slotTypeTemp " .. slotTypeTemp)

        local function getNextSlotLv( slotTypeTemp )
          for i=1,3 do
            if slotTypeTemp == 1 then
              for k,v in ipairs(blueSlots) do
                if v.RuneId < 0 then 
                  return UTGData.Instance().RuneSlotsData[tostring(v.RuneSlotId)].ReqLevel
                end
              end
            elseif slotTypeTemp == 2 then
              for k,v in ipairs(greenSlots) do
                if v.RuneId < 0 then 
                  return UTGData.Instance().RuneSlotsData[tostring(v.RuneSlotId)].ReqLevel
                end
              end
            elseif slotTypeTemp == 3 then
              for k,v in ipairs(redSlots) do
                if v.RuneId < 0 then 
                  return UTGData.Instance().RuneSlotsData[tostring(v.RuneSlotId)].ReqLevel
                end
              end
            end

            slotTypeTemp = slotTypeTemp + 1
            if slotTypeTemp == 4 then slotTypeTemp = 1 end
          end

          return -1
        end

        local nextSlotLv = getNextSlotLv(slotTypeTemp)

        self:SetSlotSelectByLv(nextSlotLv)

        self.selectSlotLv = nextSlotLv
        --当前选择种类的芯片为0，改种类芯片槽有空槽的情况，自动选择其他种类有空槽有芯片的对象





        if nextSlotLv > 0 then
          local tempType = self:GetSlotTypeByLv(nextSlotLv)
          self:UpdateRuneBag(tempType)
        end

        if nextSlotLv < 0 or (#self.runeTypeRed == 0 and #self.runeTypeBlue == 0 and #self.runeTypeGreen == 0) then 
          self:ShowCurrSetPanel(2) 
        end

        self.canSend = true
      end
      return true
    else
      return false
    end
  end

  self:SendRequest(content, RuneCtrl.RequestLoadRuneHandler)
end

--许诺写，用于获取下一个既拥有芯片又拥有空芯片槽的芯片种类     0:None   1:Red   2:Blue   3:Green
function RuneCtrl:GetNextAvaliableRuneSlotType(slotType)
  -- body
  local avaliableRuneSlotType = 0
  local haveCurrentSelectTypeRunes = false
  local runesDeckTemp = UITools.CopyTab(UTGData.Instance().RunesDeck)
  local runesSlotsDeckTemp = UITools.CopyTab(UTGData.Instance().RuneSlotsDeck)



  for k,v in pairs(runesSlotsDeckTemp) do
    for m,n in pairs(runesDeckTemp) do
      if v.RuneId == n.RuneId then
        if n.Amount ~= 0 then
          n.Amount = n.Amount - 1
          if n.Amount == 0 then
            runesDeckTemp[m] = nil
          end
        end
      end
    end
  end

  for k,v in pairs(runesDeckTemp) do
    if UTGData.Instance().RunesData[tostring(v.RuneId)].SlotType == slotType then
      haveCurrentSelectTypeRunes = true
    end
  end

  if haveCurrentSelectTypeRunes == false then
    self.count = self.count + 1
    slotType = slotType + 1
    if slotType == 4 then
      slotType = 1
    end
    if self.count < 3 then
      avaliableRuneSlotType = self:GetNextAvaliableRuneSlotType(slotType)
    else
      self.count = 0
      return -1
    end
    return avaliableRuneSlotType
  else
    return slotType
  end
end

--luo 得打一个空槽，根据选择选择的符文类型
function RuneCtrl:EmptySlotGet(selectRuneID)
  local runeInfo = UTGData.Instance().RunesData[tostring(selectRuneID)]
  
  local slotsDataTemp = UTGData.Instance().RuneSlotsDeck
        
  local blueSlots = {}
  local greenSlots = {}
  local redSlots = {}
        
  for k,v in pairs(slotsDataTemp) do
    local slotType = UTGData.Instance().RuneSlotsData[tostring(v.RuneSlotId)].Type
    local runeId = v.RuneId
    if v.RunePageDeckId == self.currPageDeckId and runeId < 0 then
      if slotType == 1 then
        table.insert(blueSlots, v) 
      elseif slotType == 2 then
        table.insert(greenSlots, v)
      elseif slotType == 3 then
        table.insert(redSlots, v)
      end
    end
  end
        
  local function sortByLv(a,b)
    return UTGData.Instance().RuneSlotsData[tostring(a.RuneSlotId)].ReqLevel < UTGData.Instance().RuneSlotsData[tostring(b.RuneSlotId)].ReqLevel
  end 

  table.sort(blueSlots, sortByLv)
  table.sort(greenSlots, sortByLv)
  table.sort(redSlots, sortByLv)

  local slotTypeTempTmp = runeInfo.SlotType

  local function getNextSlotLv( slotTypeTemp )
      if slotTypeTemp == 1 then
        for k,v in ipairs(blueSlots) do
          if v.RuneId < 0 then
            local confirmSlotID = UTGData.Instance().RuneSlotsData[tostring(v.RuneSlotId)].ReqLevel
            local state = self:GetSlotStateByLv(confirmSlotID)
            if (state == 1) then
              return confirmSlotID
            end
          end
        end
      elseif slotTypeTemp == 2 then
        for k,v in ipairs(greenSlots) do
          if v.RuneId < 0 then
            local confirmSlotID = UTGData.Instance().RuneSlotsData[tostring(v.RuneSlotId)].ReqLevel
            local state = self:GetSlotStateByLv(confirmSlotID)
            if (state == 1) then
              return confirmSlotID
            end
          end
        end
      elseif slotTypeTemp == 3 then
        for k,v in ipairs(redSlots) do
          if v.RuneId < 0 then
            local confirmSlotID = UTGData.Instance().RuneSlotsData[tostring(v.RuneSlotId)].ReqLevel
            local state = self:GetSlotStateByLv(confirmSlotID)
            if (state == 1) then
              return confirmSlotID
            end
          end
        end
      end
    return -1
  end

  local nextSlotLv = getNextSlotLv(slotTypeTempTmp)
  --self:SetSlotSelectByLv(nextSlotLv)

  return nextSlotLv
end

--当没有选择符文槽，点击符文时自动装载空槽的服务器交互
function RuneCtrl:SendLoadRuneWithNoSelectSlot(runeId,runeGo,selectSlotLv)
  local slotDeckId = self:GetSlotDeckIdByLv(selectSlotLv)

  local runeName,runeLv = self:GetRuneNameAndLvByRuneId(runeId)
  local runeInfo = "<color=#00FF00>".."穿戴"..runeLv.."级芯片:"..runeName.."</color>\n"
  local attrRoot = runeGo.transform:FindChild("TongYongRoot")
  local attrInfos = ""
  for i=1,attrRoot.childCount -1 do
    attr = attrRoot:GetChild(i)
    attrInfos = attrInfos..attr:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text
    attrInfos = attrInfos..attr:FindChild("Value"):GetComponent("UnityEngine.UI.Text").text
  end

  local content = JObject.New(JProperty.New("Type","RequestLoadRune"),
                              JProperty.New("RuneSlotDeckId", slotDeckId),
                              JProperty.New("RuneId", runeId))

  function  RuneCtrl:RequestLoadRuneHandler(e)
    --Debugger.LogError("收到芯片装载响应")
    self.InRuneChangeing = false
    if e.Type == "RequestLoadRune" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then      
        --Debugger.LogError("芯片装载成功")
        local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("SelfHideNotice")
          while async.Done == false do
            coroutine.wait(0.05)
          end
          if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice(runeInfo..attrInfos) 
          end
        end
        coroutine.start(CreatePanelAsync,self)

        self.rune_SetCtrl:FindChild("Selected").gameObject:SetActive(false)
        self.rune_SetCtrl:FindChild("JianTou").gameObject:SetActive(false)
        self.rune_SetCtrl:FindChild("Change").gameObject:SetActive(false)
        self.rune_SetCtrl:FindChild("RuneSlots").gameObject:SetActive(true)

        self:UpdateRuneBag(0)
      end
      return true
    else
      return false
    end
  end

  self:SendRequest(content, RuneCtrl.RequestLoadRuneHandler)
end



function RuneCtrl:NeedBaiFenHao(attrKey)
  if attrKey == "CritRate" or attrKey == "CritEffect" or attrKey == "PHpSteal" or 
        attrKey == "MHpSteal" or attrKey == "CdReduce"  or attrKey == "MoveSpeed" 
        or attrKey == "PpenetrateRate" or attrKey == "MpenetrateRate" or attrKey == "AtkSpeed" 
  then 
    return true
  else 
    return false
  end
end

function RuneCtrl:SendUnLoadAllRuneReq()
  self.dialogInstance:DestroySelf()
  local content = JObject.New(JProperty.New("Type","RequestUnloadAllRune"),
                              JProperty.New("RunePageDeckId",self.currPageDeckId))
  function  RuneCtrl:RequestUnloadAllRuneHandler(e)
    --Debugger.LogError("收到芯片全卸载响应")
    if e.Type == "RequestUnloadAllRune" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then      
        --Debugger.LogError("芯片全卸载成功")
        return true
      end 
    end
    return false
  end
  self:SendRequest(content, RuneCtrl.RequestUnloadAllRuneHandler)
end

function RuneCtrl:SendUnLoadRuneReq()
  --非法判断
  if self:GetSlotStateByLv(self.selectSlotLv) == 1 then return end

  local slotDeckId = self:GetSlotDeckIdByLv(self.selectSlotLv)
  local runeId = UTGData.Instance().RuneSlotsDeck[tostring(slotDeckId)].RuneId
  local runeName,runeLv = self:GetRuneNameAndLvByRuneId(runeId)
  local runeInfo = "<color=#FF0000>".."卸下"..runeLv.."级芯片:"..runeName.."</color>\n"
  local attrInfos = ""

  for k,v in pairs(UTGData.Instance().RunesData[tostring(runeId)].PVPAttr) do
    local attrName = UTGDataOperator.Instance:GetTemplateAttrCHSNameByKey(k)[1]
    local attrValue = v
    if v > 0 then
      if self:NeedBaiFenHao(k) then
        attrValue = tostring(v * 100).."%"
      end
      attrInfos = attrInfos..attrName.."-"..tostring(attrValue)
    end
  end

  local content = JObject.New(JProperty.New("Type","RequestUnloadRune"),
                              JProperty.New("RuneSlotDeckId", slotDeckId))

  function  RuneCtrl:RequestUnloadRuneHandler(e)
    --Debugger.LogError("收到芯片卸载响应")
    if e.Type == "RequestUnloadRune" then
      local result = tonumber(e.Content:get_Item("Result"):ToString())
      if result == 1 then      
        --Debugger.LogError("芯片卸载成功")
        local function CreatePanelAsync()
          local async = GameManager.CreatePanelAsync("SelfHideNotice")
          while async.Done == false do
            coroutine.step()
          end
          if SelfHideNoticeAPI ~= nil and SelfHideNoticeAPI.Instance ~= nil then
            SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice(runeInfo..attrInfos) 

          end
        end
        coroutine.start(CreatePanelAsync,self)
        --self:UpdateRuneSlots()
        self:ShowCurrSetPanel(4)
        local slotType = self:GetSlotTypeByLv(self.selectSlotLv)
        self:OnSlotSelect(self.selectSlotLv)
        --self:UpdateRuneBag(slotType)

        return true
      end
    end
    return false
  end

  self:SendRequest(content, RuneCtrl.RequestUnloadRuneHandler)
end

function RuneCtrl:GetSlotDeckIdByLv(slotLv)
  for k,v in pairs(UTGData.Instance().RuneSlotsDeck) do
    local runeSlot = UTGData.Instance().RuneSlotsData[tostring(v.RuneSlotId)]
    if slotLv - runeSlot.ReqLevel == 0 and v.RunePageDeckId == self.currPageDeckId then
      return v.Id  
    end
  end
end

function RuneCtrl:GetSlotIdByLv(slotLv)
  for k,v in pairs(UTGData.Instance().RunePagesDeck[tostring(self.currPageDeckId)].NextSlotIds) do
    local runeSlot = UTGData.Instance().RuneSlotsData[tostring(v)]
    if slotLv  == runeSlot.ReqLevel then
      return v 
    end
  end
end

function RuneCtrl:GetRuneInfoBySlotLv(slotLv)
  local runeId =  UTGData.Instance().RuneSlotsDeck[tostring(self:GetSlotDeckIdByLv(slotLv))].RuneId
  return UTGData.Instance().RunesData[tostring(runeId)]
end

function RuneCtrl:GetRuneNameAndLvByRuneId( id )
  for k,v in pairs(UTGData.Instance().RunesData) do
    if id == v.Id then return v.Name,v.Level end
  end
end

function RuneCtrl:SetSlotSelectByLv( slotLv )
  for i=0,self.runeSet_RuneSlots.childCount - 1 do
    local slot = self.runeSet_RuneSlots:GetChild(i)
    if slotLv == tonumber(slot.name) then
      slot:FindChild("Select").gameObject:SetActive(true)
    else
      slot:FindChild("Select").gameObject:SetActive(false)
    end
  end
  if slotLv == -1 then
    self:ShowCurrSetPanel(2)
    --self:UpdateShowInfo()
  end
end

--通用显示属性方法
function RuneCtrl:SetAttr(target, rootName, hasDes, count, runeId, combineNV)
  combineNV = combineNV or false

  local runeInfo = UTGData.Instance().RunesData[tostring(runeId)]
  target:Find("Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("runeicon",runeInfo.Icon)
  if hasDes then target:FindChild("Des"):GetComponent("UnityEngine.UI.Text").text  = tostring(runeInfo.Level).."级芯片:"..tostring(runeInfo.Name) end
  if count ~= nil then
    if count >= 0 then target:FindChild("Count"):GetComponent("UnityEngine.UI.Text").text  = count end
  else
    target:FindChild("Count"):GetComponent("UnityEngine.UI.Text").text  = 0
  end

  local attrTemp = target:FindChild(rootName.."/AttrTemp")
  local attrRoot = target:FindChild(rootName)
  
  for i = 1, attrRoot.childCount - 1, 1 do
    GameObject.Destroy(attrRoot:GetChild(i).gameObject)
  end
  
  local attrs
  if rootName == "TongYongRoot" then attrs = runeInfo.PVPAttr end
  if rootName == "MaoXianRoot" then attrs = runeInfo.PVEAttr end

  for k,v in pairs(attrs) do
    if v > 0 then
      local attrName = UTGDataOperator.Instance:GetTemplateAttrCHSNameByKey(k)[1]
      local attrValue 
      if self:NeedBaiFenHao(k) then
        attrValue = "+"..tostring(v * 100).."%"
      else
        attrValue = "+"..tostring(v)
      end
      local attrGo = GameObject.Instantiate(attrTemp.gameObject)
      attrGo.transform:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = attrName
      attrGo.transform:FindChild("Value"):GetComponent("UnityEngine.UI.Text").text = attrValue

      if combineNV then 
        attrValue = "<color=#00FF00>"..attrValue.."</color>"
        attrGo.transform:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = tostring(attrName)..tostring(attrValue)
        attrGo.transform:FindChild("Value"):GetComponent("UnityEngine.UI.Text").text = ""
      end

      attrGo.transform:SetParent(attrRoot)
      attrGo.transform.localScale = Vector3.one
      attrGo.transform.localPosition = Vector3.zero
      attrGo:SetActive(true)
    end
  end
  attrTemp.gameObject:SetActive(false)
end

function RuneCtrl:SetAttrToSelectedRunedInSlot(target, rootName, hasDes, count, runeId, combineNV)
  combineNV = combineNV or false

  local runeInfo = UTGData.Instance().RunesData[tostring(runeId)]
  target.parent:Find("Icon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("runeicon",runeInfo.Icon)
  if hasDes then target.parent:FindChild("Des"):GetComponent("UnityEngine.UI.Text").text  = tostring(runeInfo.Level).."级芯片:"..tostring(runeInfo.Name) end
  if count ~= nil then
    if count >= 0 then target.parent:FindChild("Count"):GetComponent("UnityEngine.UI.Text").text  = count end
  else
    target.parent:FindChild("Count"):GetComponent("UnityEngine.UI.Text").text  = 0
  end

  local attrTemp = target:FindChild(rootName.."/AttrTemp")
  local attrRoot = target:FindChild(rootName)
  
  for i = 1, attrRoot.childCount - 1, 1 do
    GameObject.Destroy(attrRoot:GetChild(i).gameObject)
  end
  
  local attrs
  if rootName == "TongYongRoot" then attrs = runeInfo.PVPAttr end
  if rootName == "MaoXianRoot" then attrs = runeInfo.PVEAttr end

  for k,v in pairs(attrs) do
    if v > 0 then
      local attrName = UTGDataOperator.Instance:GetTemplateAttrCHSNameByKey(k)[1]
      local attrValue 
      if self:NeedBaiFenHao(k) then
        attrValue = "+"..tostring(v * 100).."%"
      else
        attrValue = "+"..tostring(v)
      end
      local attrGo = GameObject.Instantiate(attrTemp.gameObject)
      attrGo.transform:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = attrName
      attrGo.transform:FindChild("Value"):GetComponent("UnityEngine.UI.Text").text = attrValue

      if combineNV then 
        attrValue = "<color=#00FF00>"..attrValue.."</color>"
        attrGo.transform:FindChild("Name"):GetComponent("UnityEngine.UI.Text").text = tostring(attrName)..tostring(attrValue)
        attrGo.transform:FindChild("Value"):GetComponent("UnityEngine.UI.Text").text = ""
      end

      attrGo.transform:SetParent(attrRoot)
      attrGo.transform.localScale = Vector3.one
      attrGo.transform.localPosition = Vector3.zero
      attrGo:SetActive(true)
    end
  end
  attrTemp.gameObject:SetActive(false)
end

function RuneCtrl:SendRequest(content, func)
  local request = NetRequest.New()
  request.Content = content
  request.Handler = TGNetService.NetEventHanlderSelf(func, self)
  TGNetService.GetInstance():SendRequest(request)
end 

--显示并更新芯片分解和制作窗口
function RuneCtrl:ShowCreateAndResolveWindow()
  --print("进入了 " .. self.selectedRuneId)
   local runeInfo = UTGData.Instance().RunesData[tostring(self.selectedRuneId)]
   if runeInfo == nil then return end
  --print("进入了 " .. self.selectedRuneId)  
  self.runeCreate_CreateAndResolveCtrl.gameObject:SetActive(true)
  --print("22222222222222")
  local runeCount = 0
  for k,v in pairs(UTGData.Instance().RunesDeck) do
    if v.RuneId == self.selectedRuneId then
      runeCount = self:GetRuneCountByDeckId(v.RuneId)
    end
  end
  if runeCount == 0 then 
    self.createAndResolveCtrl_ResolveBtn:GetComponent("UnityEngine.UI.Button").interactable = false
  else
    self.createAndResolveCtrl_ResolveBtn:GetComponent("UnityEngine.UI.Button").interactable = true
  end
  local runeInfo = UTGData.Instance().RunesData[tostring(self.selectedRuneId)]
  local window = self.runeCreate_CreateAndResolveCtrl
  window:FindChild("Need"):GetComponent("UnityEngine.UI.Text").text = runeInfo.ComposePiece
  window:FindChild("Get"):GetComponent("UnityEngine.UI.Text").text = runeInfo.DecomposePiece
  
  self:SetAttr(window, "TongYongRoot", true, runeCount, self.selectedRuneId)
  self:SetAttr(window, "MaoXianRoot", true, runeCount, self.selectedRuneId)
end

--许诺改，为了将芯片制作分解窗口的显示与更新分离
function RuneCtrl:UpdateCreateAndResolveWindow()
   local runeInfo = UTGData.Instance().RunesData[tostring(self.selectedRuneId)]
   if runeInfo == nil then return end 
  --self.runeCreate_CreateAndResolveCtrl.gameObject:SetActive(true)
  --print("22222222222222")
  local runeCount = 0
  for k,v in pairs(UTGData.Instance().RunesDeck) do
    if v.RuneId == self.selectedRuneId then
      runeCount = self:GetRuneCountByDeckId(v.RuneId)
    end
  end
  if runeCount == 0 then 
    self.createAndResolveCtrl_ResolveBtn:GetComponent("UnityEngine.UI.Button").interactable = false
  else
    self.createAndResolveCtrl_ResolveBtn:GetComponent("UnityEngine.UI.Button").interactable = true
  end
  local runeInfo = UTGData.Instance().RunesData[tostring(self.selectedRuneId)]
  local window = self.runeCreate_CreateAndResolveCtrl
  window:FindChild("Need"):GetComponent("UnityEngine.UI.Text").text = runeInfo.ComposePiece
  window:FindChild("Get"):GetComponent("UnityEngine.UI.Text").text = runeInfo.DecomposePiece
  
  self:SetAttr(window, "TongYongRoot", true, runeCount, self.selectedRuneId)
  self:SetAttr(window, "MaoXianRoot", true, runeCount, self.selectedRuneId)
end


--按照顺序显示经过删选的芯片
function RuneCtrl:UpdateCreateRune()

  for i = 1, self.runeCreate_BarRoot.childCount - 1, 1 do
    GameObject.Destroy(self.runeCreate_BarRoot:GetChild(i).gameObject)
  end
  
  local runesData = UTGData.Instance().RunesData
  
  local blueRunes = {}
  local greenRunes = {}
  local redRunes = {}
  
  for k,v in pairs(runesData) do
    if self.ShowType ~= 0 then
      for m = 1,#v.Type do
        if (v.Type[m] == self.ShowType)and v.Level == self.ShowLv then
           if v.SlotType == 1 then table.insert(blueRunes, v) end
           if v.SlotType == 2 then table.insert(greenRunes, v) end
           if v.SlotType == 3 then table.insert(redRunes, v) end
        end
      end
    else
      if v.Level == self.ShowLv then
       if v.SlotType == 1 then table.insert(blueRunes, v) end
       if v.SlotType == 2 then table.insert(greenRunes, v) end
       if v.SlotType == 3 then table.insert(redRunes, v) end        
      end
    end
  end
  
  self:SortById(blueRunes)
  self:SortById(greenRunes)
  self:SortById(redRunes)
  
  self:AddCreateRuneBars(redRunes)
  self:AddCreateRuneBars(blueRunes)
  self:AddCreateRuneBars(greenRunes)
  self.runeCreate_BarRoot:FindChild("RuneBarTemp").gameObject:SetActive(false)

  if #redRunes == 0 and #blueRunes == 0 and #greenRunes == 0 then 
    self.runeCreate_BarRoot.parent:FindChild("Empty").gameObject:SetActive(true)
  else
    self.runeCreate_BarRoot.parent:FindChild("Empty").gameObject:SetActive(false)
  end
     
end

--在芯片制作界面里特定根路径下生成芯片
function RuneCtrl:AddCreateRuneBars(bars)
  local barTemp = self.runeCreate_BarRoot:FindChild("RuneBarTemp")
  barTemp.gameObject:SetActive(true)
  for i,v in pairs(bars) do
    local runeTemp = v
    local barGo = GameObject.Instantiate(barTemp.gameObject)

    barGo.transform:SetParent(self.runeCreate_BarRoot)
    barGo.transform.localScale = Vector3.one
    barGo.transform.localPosition = Vector3.zero
    barGo:SetActive(true)

    local callback = function()
      self:AddPointerClickEvent(barGo, RuneCtrl.BarClick)
    end
    UITools.GetLuaScript(barGo.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,callback)

    barGo.name = v.Id

    local runeDeckId = -1
    for k1,v1 in pairs(UTGData.Instance().RunesDeck) do
      if v1.RuneId == v.Id then
        runeDeckId = v1.RuneId
      end
    end

    barGo.transform:FindChild("Des"):GetComponent("UnityEngine.UI.Text").text = tostring(v.Level).."级芯片:"..tostring(v.Name)
    local count = self:GetRuneCountByDeckId(runeDeckId)

    if count ~= 0 then 
      barGo.transform:FindChild("Count"):GetComponent("UnityEngine.UI.Text").text = count
      barGo.transform:FindChild("Show").gameObject:SetActive(true)
      barGo.transform:FindChild("Empty").gameObject:SetActive(false)
    else
      barGo.transform:FindChild("Count"):GetComponent("UnityEngine.UI.Text").text = "0"
      barGo.transform:FindChild("Show").gameObject:SetActive(false)
      barGo.transform:FindChild("Empty").gameObject:SetActive(true)
    end

    self:SetAttr(barGo.transform, "TongYongRoot", true, count, v.Id, true)
      
  end
end

function RuneCtrl:GetRuneCountByDeckId(id)
  if UTGData.Instance().RunesDeck[tostring(id)] == nil then return 0 end
  --print("UTGData.Instance().RunesDeck[tostring(id)] " .. UTGData.Instance().RunesDeck[tostring(id)].Amount)
  return UTGData.Instance().RunesDeck[tostring(id)].Amount
end

function RuneCtrl:SortById(tab) 
  local function idSort(a, b)
          return a.Id < b.Id
        end  
  table.sort(tab, idSort)
end

function RuneCtrl:InitRuneRecommend(roleId)
  -- body
  self.selectRole = roleId
  local roleData = UTGData.Instance().RolesData[tostring(roleId)]
  local icon = ""
  if UTGData.Instance().RolesDeckData[tostring(roleId)] ~= nil then
    icon = UTGData.Instance().SkinsData[tostring(UTGData.Instance().RolesDeckData[tostring(roleId)].Skin)].Icon
  else
    icon = UTGData.Instance().SkinsData[tostring(UTGData.Instance().RolesData[tostring(roleId)].Skin)].Icon
  end
  self.runeRecommendCtrlHeroIcon:GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("roleicon",icon)
  self.runeRecommendCtrlHeroName:GetComponent("UnityEngine.UI.Text").text = roleData.Name





  local listener = NTGEventTriggerProxy.Get(self.runeRecommendCtrlChangeHeroButton.gameObject)
  local callback = function(self, e)
    self:DoOpenSelectRolePanel()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)

  for i = 1,5 do
    local listener = NTGEventTriggerProxy.Get(self.runeRecommendCtrl:Find("Top/UpFrameInfo/Panel/Level" .. i .. "Button").gameObject)
    local callback = function(self, e)
      self:ShowRunesByLevel(roleId,i)
    end
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self) 
  end

  self:ShowRunesByLevel(roleId,1)

end

function RuneCtrl:ShowRunesByLevel(roleId,level)
  -- body
  local roleData = UTGData.Instance().RolesData[tostring(roleId)]
  self.runeRecommendCtrlMidHeroName:GetComponent("UnityEngine.UI.Text").text = roleData.Name
  self.runeRecommendCtrlMidRuneLevel:GetComponent("UnityEngine.UI.Text").text = level

  for i = 1,self.runeRecommendCtrlTypePanel.childCount do
    self.runeRecommendCtrlTypePanel:GetChild(i-1):GetComponent("UnityEngine.UI.Image").color = Color.New(128/255,128/255,128/255,1)
  end
  self.runeRecommendCtrlTypePanel:GetChild(level-1):GetComponent("UnityEngine.UI.Image").color = Color.New(1,1,1,1)

  for i = 1,3 do
    --print("UTGData.Instance().RolesData[tostring(roleId)].RecommendRunes[level-1][i-1] " .. UTGData.Instance().RolesData[tostring(roleId)].RecommendRunes[level][i])
    self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("RuneIcon"):GetComponent("UnityEngine.UI.Image").sprite = UITools.GetSprite("runeicon",
                                        UTGData.Instance().RunesData[tostring(UTGData.Instance().RolesData[tostring(roleId)].RecommendRunes[level][i])].Icon)
    self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("RuneName"):GetComponent("UnityEngine.UI.Text").text = 
                                        UTGData.Instance().RunesData[tostring(UTGData.Instance().RolesData[tostring(roleId)].RecommendRunes[level][i])].Name
    local attrs = UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",UTGData.Instance().RolesData[tostring(roleId)].RecommendRunes[level][i])
    
    self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("Panel"):GetChild(0).gameObject:SetActive(false)
    self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("Panel"):GetChild(1).gameObject:SetActive(false)
    self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("Panel"):GetChild(2).gameObject:SetActive(false)

    --print("#attrs " .. #attrs)
    for k = 1,#attrs do
      --print(attrs[k].Des .. " " .. attrs[k].Attr)
      self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("Panel"):GetChild(k-1).gameObject:SetActive(true)
      self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("Panel"):GetChild(k-1):Find("Desc"):GetComponent("UnityEngine.UI.Text").text = attrs[k].Des
      self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("Panel"):GetChild(k-1):Find("Value"):GetComponent("UnityEngine.UI.Text").text = "+" .. attrs[k].Attr
    end

    if UTGData.Instance().RunesDeck[tostring(UTGData.Instance().RolesData[tostring(roleId)].RecommendRunes[level][i])] ~= nil then
      self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("OwnBg").gameObject:SetActive(true)
      self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("NotHaveBg").gameObject:SetActive(false)
      self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("OwnFrame/OwnNum"):GetComponent("UnityEngine.UI.Text").text = 
                        UTGData.Instance().RunesDeck[tostring(UTGData.Instance().RolesData[tostring(roleId)].RecommendRunes[level][i])].Amount
    else
      self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("OwnBg").gameObject:SetActive(false)
      self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("NotHaveBg").gameObject:SetActive(true)
      self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("OwnFrame/OwnNum"):GetComponent("UnityEngine.UI.Text").text = 0     
    end

    local listener = NTGEventTriggerProxy.Get(self.runeRecommendCtrlPartPanel:GetChild(i-1):Find("ClickArea").gameObject)
    local callback = function(self, e)
      --print("selectedID " .. UTGData.Instance().RolesData[tostring(roleId)].RecommendRunes[level][i])
      self.selectedRuneId = UTGData.Instance().RolesData[tostring(roleId)].RecommendRunes[level][i]
      self.partNum = i
      self.runeRecommendFlag = true
      self:ShowCreateAndResolveWindow()     
    end
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)

  end
end

function RuneCtrl:UpdateRunesOnCurrentLevel(partNum,Id)
  -- body

  --print("partNum and Id " .. partNum .. " " .. Id)
  if UTGData.Instance().RunesDeck[tostring(Id)] ~= nil then
    self.runeRecommendCtrlPartPanel:GetChild(partNum-1):Find("OwnBg").gameObject:SetActive(true)
    self.runeRecommendCtrlPartPanel:GetChild(partNum-1):Find("NotHaveBg").gameObject:SetActive(false)
    self.runeRecommendCtrlPartPanel:GetChild(partNum-1):Find("OwnFrame/OwnNum"):GetComponent("UnityEngine.UI.Text").text = 
                      UTGData.Instance().RunesDeck[tostring(Id)].Amount
  else
    self.runeRecommendCtrlPartPanel:GetChild(partNum-1):Find("OwnBg").gameObject:SetActive(false)
    self.runeRecommendCtrlPartPanel:GetChild(partNum-1):Find("NotHaveBg").gameObject:SetActive(true)
    self.runeRecommendCtrlPartPanel:GetChild(partNum-1):Find("OwnFrame/OwnNum"):GetComponent("UnityEngine.UI.Text").text = 0     
  end    
  self.runeRecommendFlag = false
end

function RuneCtrl:DoOpenSelectRolePanel()
  -- body
  coroutine.start(RuneCtrl.OpenSelectRolePanel, self)
end

function RuneCtrl:OpenSelectRolePanel()
  -- body
  local async = GameManager.CreatePanelAsync("BattleMallSelectHero")
  while async.Done == false do
    coroutine.wait(0.05)
  end
  if BattleMallSelectHeroAPI~=nil and BattleMallSelectHeroAPI.Instance~=nil then 
    BattleMallSelectHeroAPI.Instance:GetRune()
  end
end

function RuneCtrl:IsContains(needCheck,element)
  -- body
  for k,v in pairs(needCheck) do
    if v == element then
      return true
    end
  end
  return false
end

function RuneCtrl:GoToTab3()
  -- body
    self.rune_SetBtn:FindChild("Select").gameObject:SetActive(false)
    self.rune_CreateBtn:FindChild("Select").gameObject:SetActive(true)
    self.runeRecommendBtn:Find("Select").gameObject:SetActive(false)
    self.rune_SetCtrl.gameObject:SetActive(false)
    self.rune_CreateCtrl.gameObject:SetActive(true)
    self.runeRecommendCtrl.gameObject:SetActive(false)
    self:UpdateCreateRune()

    NormalResourceAPI.Instance:InitResource(1)
end













function RuneCtrl:OnDestroy()
  self.this = nil
  self = nil
end

