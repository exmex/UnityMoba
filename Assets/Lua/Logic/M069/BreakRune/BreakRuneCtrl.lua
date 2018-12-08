--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
require "Logic.UTGData.UTGDataTemporary"
require "Logic.UICommon.Static.UITools"

class("BreakRuneCtrl")
local json = require "cjson"

function BreakRuneCtrl:Awake(this)
  self.this = this
  local listener = {}
  --批量分解界面
  listener = NTGEventTriggerProxy.Get(this.transforms[0].gameObject)--关闭面板
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BreakRuneCtrl.ClickCloseRootPanel,self)
  listener = NTGEventTriggerProxy.Get(this.transforms[1].gameObject)--批量分解
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BreakRuneCtrl.ClickBreakRune,self)
  --分解详情界面
  listener = NTGEventTriggerProxy.Get(this.transforms[2].gameObject)--关闭面板
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BreakRuneCtrl.ClickCloseDetailPanel,self)
  listener = NTGEventTriggerProxy.Get(this.transforms[3].gameObject)--取消
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BreakRuneCtrl.ClickCloseDetailPanel,self)
  listener = NTGEventTriggerProxy.Get(this.transforms[4].gameObject)--确定
  listener.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BreakRuneCtrl.ClickBreakOk,self)

  self.detailPanel = this.transforms[5]
  self.detailPanel:FindChild("bg/tip"):GetComponent("UnityEngine.UI.Text").text = "默认分解以下所有芯片，需要<color=#EBC719FF>保留</color>的芯片请<color=#EBC719FF>取消勾选</color>"
  self.txtChipNum = this.transforms[6]:GetComponent("UnityEngine.UI.Text")
  self.rootgrid = this.transforms[7]
  self.detailgrid = this.transforms[8]
  self.detailwu = this.transforms[9]
  for i=1,self.rootgrid.childCount do
  	--分解详情按钮
  	local temp = NTGEventTriggerProxy.Get(self.rootgrid:GetChild(i-1):FindChild("select/"..i).gameObject) 
  	temp.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BreakRuneCtrl.ClickBreakRuneDetail,self)
  	--选择芯片等级
  	temp = NTGEventTriggerProxy.Get(self.rootgrid:GetChild(i-1).gameObject)  
  	temp.onPointerClick =  NTGEventTriggerProxy.PointerEventDelegateSelf(BreakRuneCtrl.ClickSelectBreakRune,self)
  end  

  self.runelis = {[1]={},[2]={},[3]={},[4]={}}
  self.runelisNow = {[1]={},[2]={},[3]={},[4]={}}
  self.chipNum = 0
 end

function BreakRuneCtrl:Start()

	
--[[
	for k,v in pairs(useData) do
		Debugger.LogError("k= "..k.." v.Id = "..v.Id)
	end
]]
	self:InitData()
  	self:Init()

end
----------------------批量分解界面--------------------------

--初始化
function BreakRuneCtrl:InitData()
	local data = UITools.CopyTab(UTGData.Instance().RunesDeck)
	local tempData = UITools.CopyTab(UTGData.Instance().RuneSlotsDeck)
	local isOneRune = false 
	while isOneRune == true do
		isOneRune = false
		local kkk = ""
		for k,v in pairs(tempData) do		
			for k1,v1 in pairs(tempData) do
				if v1.Id ~= v.Id and v1.RuneSlotId == v.RuneSlotId and v1.RuneId == v.RuneId then
					isOneRune = true 
					kkk = k1
					break
				end
			end
			if isOneRune then break end
		end
		if isOneRune and kkk ~="" then tempData[kkk] = nil end 
	end

	for k,v in pairs(tempData) do
		if v.RuneId>0 then 
			for k1,v1 in pairs(data) do
				if v.RuneId == v1.RuneId then v1.Amount = v1.Amount-1 end
			end
		end
	end
	local useData  = {}
	for k,v in pairs(data) do
		if v.Amount>0 then table.insert(useData,v) end
	end

	self.runelis = {[1]={},[2]={},[3]={},[4]={}}
	self.runelisNow = {[1]={},[2]={},[3]={},[4]={}}
	self.runeIds = {}
	for i=1,#useData do
		local runedata = UTGData.Instance().RunesData[tostring(useData[i].RuneId)]
		if runedata.Level ==1 then table.insert(self.runelis[1],useData[i]) end
		if runedata.Level ==2 then table.insert(self.runelis[2],useData[i]) end
		if runedata.Level ==3 then table.insert(self.runelis[3],useData[i]) end
		if runedata.Level ==4 then table.insert(self.runelis[4],useData[i]) end
	end

	--[[
	for k,v in pairs(self.runelis[1]) do
		Debugger.LogError("k= "..k.." v.Id = "..v.Id)
	end
	]]
end

function BreakRuneCtrl:Init()
	for i=1,self.rootgrid.childCount do
		local temp = self.rootgrid:GetChild(i-1)
		temp:FindChild("select").gameObject:SetActive(false)
		temp:FindChild("all").gameObject:SetActive(true)
		temp:FindChild("notall").gameObject:SetActive(false)
	end
	self.txtChipNum.text = "0"
end

--更新批量分解UI 当前选择的芯片
function BreakRuneCtrl:UpdateRootUI()
	local allNum = 0 --分解所得碎片
	for i=1,#self.runelisNow do
		if self.rootgrid:FindChild(i.."/select").gameObject.activeSelf then
			local isAll = true
			for j=1,#self.runelisNow[i] do
				if self.runelisNow[i][j].RuneId~=nil then
					local chipnum = UTGData.Instance().RunesData[tostring(self.runelisNow[i][j].RuneId)].DecomposePiece
					allNum = allNum + chipnum*self.runelisNow[i][j].Amount
				else isAll = false end
			end
			if isAll then
				self.rootgrid:FindChild(i.."/all").gameObject:SetActive(true)
				self.rootgrid:FindChild(i.."/notall").gameObject:SetActive(false)
			else
				self.rootgrid:FindChild(i.."/all").gameObject:SetActive(false)
				self.rootgrid:FindChild(i.."/notall").gameObject:SetActive(true)
			end
		else
			self.rootgrid:FindChild(i.."/all").gameObject:SetActive(true)
			self.rootgrid:FindChild(i.."/notall").gameObject:SetActive(false)
		end
	end
	
	self.chipNum = allNum
	self.txtChipNum.text = ""..allNum
end

--选择分解的芯片等级
function BreakRuneCtrl:ClickSelectBreakRune(eventdata)
	--print("选择分解的芯片等级 "..eventdata.pointerPress.name)
	local temp = eventdata.pointerPress.transform
	local runeType = tonumber(temp.name)
	if temp:FindChild("select").gameObject.activeSelf then
	  temp:FindChild("select").gameObject:SetActive(false)
	  self.runelisNow[runeType] = {}
	else 
	  temp:FindChild("select").gameObject:SetActive(true)
	  self.runelisNow[runeType] = UITools.CopyTab(self.runelis[runeType])
	end
	self:UpdateRootUI()
end

--分解详情
function BreakRuneCtrl:ClickBreakRuneDetail(eventdata)
	--print("分解详情 "..eventdata.pointerPress.name)
	local temp = eventdata.pointerPress.transform
	local runeType = tonumber(temp.name)
	self:Init_Detail(runeType)
end


--批量分解
function BreakRuneCtrl:ClickBreakRune()
	--print("批量分解")
	if self.netWait then return end
	local runeids = {}
	for i=1,#self.runelisNow do
		if self.runelisNow[i]~=nil then
			for j=1,#self.runelisNow[i] do
				table.insert(runeids,self.runelisNow[i][j].RuneId) 
			end
		end
	end
	if #runeids>0 then
		self:NetBreakRune(runeids)
	else
		--print("没有可以分解的芯片")
		GameManager.CreatePanel("SelfHideNotice")
		SelfHideNoticeAPI.Instance:InitNoticeForSelfHideNotice("没有可以分解的多余芯片")
	end
end
--网络 批量分解
function BreakRuneCtrl:NetBreakRune(runeids)
	self.runeIds = runeids
	self.canGetNum = self.chipNum
	local request = NetRequest.New()
    request.Content = JObject.New(JProperty.New("Type","RequestDecomposeBatchRune"),JProperty.New("RuneIds",json.encode(runeids)))
    request.Handler = TGNetService.NetEventHanlderSelf(BreakRuneCtrl.NetBreakRuneHandler,self)
    TGNetService.GetInstance():SendRequest(request)
    self.netWait = true
end

function BreakRuneCtrl:NetBreakRuneHandler(e)
  if e.Type == "RequestDecomposeBatchRune" then
    local result = tonumber(e.Content:get_Item("Result"):ToString())
    if result ==1 then
    	self:GetPieceMov()
    	--coroutine.start(BreakRuneCtrl.GetPieceMov,self)
    end
    self.netWait = false
    return true
  end
  return false
end

function BreakRuneCtrl:UpdateRuneData()
	self:InitData()
	self:UpdateRootUI()
end

--领取动画
function BreakRuneCtrl:GetPieceMov()
	GameManager.CreatePanel("BreakRuneGetPiece")   	
	--coroutine.wait(0.5)
	BreakRuneGetPieceAPI.Instance:ShowUI(self.canGetNum)
end

--关闭面板
function BreakRuneCtrl:ClickCloseRootPanel()
	Object.Destroy(self.this.gameObject)
end
------------------------------------------------------------

----------------------分解详情界面--------------------------

--初始化
function BreakRuneCtrl:Init_Detail(typeid)
	self.detailPanel.gameObject:SetActive(true)
	self.selectRuneType = tonumber(typeid)
	--Debugger.LogError("typeid= "..typeid.."  "..#self.runelis[tonumber(typeid)])
	self:FillRuneLis(self.runelis[tonumber(typeid)])
end

--生成数据
function BreakRuneCtrl:FillRuneLis(data)
	local api =self.detailgrid:GetComponent("NTGLuaScript").self
    if data==nil then
    	Debugger.LogError("分解详情界面数据为nil")
    	api:ResetItemsSimple(0)
    return
  	end
  	--Debugger.LogError("#data= "..#data)
  	api:ResetItemsSimple(#data)
  	if #data ==0 then self.detailwu.gameObject:SetActive(true) else self.detailwu.gameObject:SetActive(false) end
  	for i=1,#api.itemList do
    	local tempo = api.itemList[i].transform
    	tempo.name = tostring(i)
    
    	local runedata = UTGData.Instance().RunesData[tostring(data[i].RuneId)]
    	--芯片图标
    	tempo:FindChild("icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("runeicon",tostring(runedata.Icon),"UnityEngine.Sprite")
    	--芯片数量
    	tempo:FindChild("num"):GetComponent("UnityEngine.UI.Text").text = "x"..data[i].Amount
    	--芯片名称
		tempo:FindChild("name"):GetComponent("UnityEngine.UI.Text").text = runedata.Level.."级芯片: "..runedata.Name
		--芯片属性
		local attrapi = tempo:FindChild("grid"):GetComponent("NTGLuaScript").self
		local attrlis = UTGDataOperator.Instance:GetSortedPropertiesByKey("RunePVP",runedata.Id)
		if attrlis ==nil then Debugger.LogError("芯片属性取不到 id= "..runedata.Id) end
		attrapi:ResetItemsSimple(#attrlis)
		for j=1,#attrapi.itemList do
			local attrtemp = attrapi.itemList[j].transform
			attrtemp:FindChild("des"):GetComponent("UnityEngine.UI.Text").text = ""..attrlis[j].Des
			attrtemp:FindChild("attr"):GetComponent("UnityEngine.UI.Text").text = "+"..attrlis[j].Attr
		end
		if self.runelisNow[self.selectRuneType][i] ==nil or self.runelisNow[self.selectRuneType][i].Id == nil then tempo:FindChild("select/ok").gameObject:SetActive(false) else tempo:FindChild("select/ok").gameObject:SetActive(true) end
    	local listener = NTGEventTriggerProxy.Get(tempo:FindChild("select").gameObject)
    	listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BreakRuneCtrl.ClickSelectRune,self)
    	
  	end
end

function BreakRuneCtrl:ClickSelectRune(eventdata)
	print("勾选芯片 "..eventdata.pointerPress.name)
	local temp = eventdata.pointerPress.transform
	if temp:FindChild("ok").gameObject.activeSelf then
	  temp:FindChild("ok").gameObject:SetActive(false)
	else 
	  temp:FindChild("ok").gameObject:SetActive(true)
	end
end
--确认
function BreakRuneCtrl:ClickBreakOk()
	self.runelisNow[self.selectRuneType] = UITools.CopyTab(self.runelis[self.selectRuneType])
	--Debugger.LogError("pppppp self.runelisNow[self.selectRuneType] "..#self.runelisNow[self.selectRuneType])
	local api =self.detailgrid:GetComponent("NTGLuaScript").self
	for i=1,#api.itemList do
		local tempo = api.itemList[i].transform
		if tempo:FindChild("select/ok").gameObject.activeSelf == false then
			--Debugger.LogError("tempo Del =  "..i)
			self.runelisNow[self.selectRuneType][i]= {}
		end
	end
	--Debugger.LogError("self.runelisNow[self.selectRuneType] "..#self.runelisNow[self.selectRuneType])
	self:ClickCloseDetailPanel()
	self:UpdateRootUI()
end

--关闭面板
function BreakRuneCtrl:ClickCloseDetailPanel()
	self.detailPanel.gameObject:SetActive(false)
end
------------------------------------------------------------


function BreakRuneCtrl:OnDestroy()
  self.this = nil
  self = nil
end