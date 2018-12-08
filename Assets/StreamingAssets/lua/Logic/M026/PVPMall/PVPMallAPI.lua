require "System.Global"

class("PVPMallAPI")

function  PVPMallAPI:Awake(this)
	-- body
	self.this = this
	self.pmControl = self.this.transforms[0]:GetComponent("NTGLuaScript")
	self.button = self.this.transforms[1]
	self.button1 = self.this.transforms[2]
	self.button2 = self.this.transforms[3]
	self.button3 = self.this.transforms[4]
	self.button4 = self.this.transforms[5]
	self.button5 = self.this.transforms[6]
	PVPMallAPI.Instance = self
	--print("PVPMallAPI已加载")

  local listener = NTGEventTriggerProxy.Get(self.button5.gameObject)
  local callback11 = function(self, e)
  	print("第一次打开商店界面需要调用一次")
    self:FirstTimeOpen(10000001)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback11, self)

  listener = NTGEventTriggerProxy.Get(self.button.gameObject)
  local callback12 = function(self, e)
  	print("当购买或出售完成后调用，更新已获得装备以及装备列表状态")
    self:UpdateEquipListInfo(12001206,"Buy")
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback12,self)

  listener = NTGEventTriggerProxy.Get(self.button1.gameObject)
  local callback13 = function(self, e)
  	print("购买装备接口")
    self:BuyEquip()
    --print("abc  " .. type(self:GetEquipInfo()))
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf( callback13, self)

  listener = NTGEventTriggerProxy.Get(self.button2.gameObject)
  local callback14 = function(self, e)
  	print("出售装备接口")
    self:SellEquip()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback14, self)

  listener = NTGEventTriggerProxy.Get(self.button3.gameObject)
  local callback15 = function(self, e)
  	print("需要固定时间调用一次，用于显示玩家当前金钱数，并根据金钱数更新列表装备显示状态")
    self:GetCurrentMoney(500)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback15, self)

  listener = NTGEventTriggerProxy.Get(self.button4.gameObject)
  local callback16 = function(self, e)
  	print("需要在外部调用该接口")
    self:OpenPanel()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback16, self)

end

function  PVPMallAPI:Start()
	-- body
end

--第一次打开商店界面需要调用一次
function PVPMallAPI:FirstTimeOpen(roleId)
	-- body
	self.pmControl.self:GetMallData(roleId)
	self.pmControl.self:TabControl(1)
	self.pmControl.self:InitList(self.pmControl.self.recommend)
	self.this.transform.gameObject:SetActive(false)
end

--需要在外部调用该接口
function  PVPMallAPI:OpenPanel(delegate)
	-- body
	--print("OpenOpenOpen")
	self.pmControl.self:OpenPanel(delegate)
end

--需要在第一次打开商店面板时调用一次
function  PVPMallAPI:ClosePanel(delegate)
	-- body
	--print("CloseClose")
	self.this.transform.gameObject:SetActive(false)
	self.pmControl.self.closePanelDelegate = delegate
	self.pmControl.self:ClosePanel(delegate)

end


--需要固定时间调用一次，用于显示玩家当前金钱数，并根据金钱数更新列表装备显示状态
function PVPMallAPI:GetCurrentMoney(num)
	-- body
	self.pmControl.self:GetPlayerMoney(num)
end

--用于获取当前选择装备的EquipId
function PVPMallAPI:GetEquipInfo()
	-- body
	local equip = self.pmControl.self:GetSelectedEquipInfo()
	for k,v in pairs(equip) do
		print(k .. " " .. type(v))
		if k == "Attr" then
			for m,n in pairs(v) do
				print(m .. " " .. n)
			end
		elseif k == "PassiveSkills" then
			print("Length " .. #v)
			for m,n in ipairs(v) do
				print(m .. " " .. n)
			end
		end
	end
	return equip
end

--购买装备接口
function  PVPMallAPI:BuyEquip(delegate)
	-- body
	self.pmControl.self:BuyEquip(delegate)
end


--出售装备接口
function  PVPMallAPI:SellEquip(delegate)
	-- body
	self.pmControl.self:SellEquip(delegate)
end

--当购买或出售完成后调用，更新已获得装备以及装备列表状态
function PVPMallAPI:UpdateEquipListInfo(equipId,actType)	--actType = "Buy" or "Sell"
	-- body
	self.pmControl.self:UpdateGetedEquip(equipId,actType)
end

function PVPMallAPI:BuyEquipOutside(equipId,buyCount,price)
	-- body
	self.pmControl.self:BuyEquipOutside(equipId,buyCount,price)
end




function PVPMallAPI:OnDestroy()
	self.this = nil
	self = nil
	PVPMallAPI.Instance = nil
end