require "System.Global"
require "Logic.UTGData.UTGData"

class("EquipInsideController")

local Data = UTGData.Instance()
local Text = "UnityEngine.UI.Text"
local Image = "UnityEngine.UI.Image"
local Slider = "UnityEngine.UI.Slider"
local RectTrans = "RectTransform"

function EquipInsideController:Awake(this)
  self.this = this
  
  self.leftPanel = self.this.transforms[0]
  self.rightPanel = self.this.transforms[1]
  self.itemAPI = self.this.transforms[2]:GetComponent("NTGLuaScript")
  self.cancelButton = self.this.transforms[3]
  self.rootIcon = self.leftPanel:Find("Panel/RootIcon")
  self.model1 = self.leftPanel:Find("Model1")
  self.model2 = self.leftPanel:Find("Model2")
  self.model3 = self.leftPanel:Find("Model3")
  self.model4 = self.leftPanel:Find("Model4")
  self.model5 = self.leftPanel:Find("Model5")
  self.element = self.leftPanel:Find("CanCompose/List/Panel/Border")
  self.button = self.rightPanel:Find("Button")
  self.equipName = self.rightPanel:Find("EquipName")
  self.equipPropertyPanel = self.rightPanel:Find("Mid/Panel")
  self.equipProperty = self.rightPanel:Find("Mid/Panel/Text")
  self.equipSkill = self.rightPanel:Find("Mid/Text")
  self.equipPrice = self.rightPanel:Find("Mid/Image/PayNum")
  
  --Data:UTGDataTemplate()
  --print("AAAAAAAAAAAA")
  
  listener = NTGEventTriggerProxy.Get(self.cancelButton.gameObject)
  local callback1 = function(self,e)
    self:DestroySelf()
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)
  self.count = 0
  
  self.forClear = {}
  
end

function EquipInsideController:Start()

  if WaitingPanelAPI ~= nil and WaitingPanelAPI.Instance ~= nil then
    WaitingPanelAPI.Instance:DestroySelf()
  end

end

function EquipInsideController:ConnectController(rootId,rootTrans)
  --前置装备为空时
  
  if rootTrans == nil then
    rootTrans = self.rootIcon
  end
  
  
  local listener = ""
  local preEquips = {}
  rootTrans:Find("Image"):GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(rootId)].Icon)
  listener = NTGEventTriggerProxy.Get(rootTrans.gameObject)
  local callback = function(self, e)
    self:GetEquipInfo(rootId)
  end
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self)
  --print(rootId)
  --print("Data.PVPMallsData[tostring(rootId)].PreEquips " .. type(Data.PVPMallsData[tostring(rootId)].PreEquips))
  local size = rootTrans:GetComponent(RectTrans).sizeDelta
  local position = rootTrans.localPosition + rootTrans.parent.localPosition
  
  if Data.PVPMallsData[tostring(rootId)].PreEquips == nil then
    self.rootIcon:GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(rootId)].Icon)
    --print("1")
    self.count = self.count + 1
  else
    self.rootIcon:GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(rootId)].Icon)
    if #Data.PVPMallsData[tostring(rootId)].PreEquips == 1 then
      local layer2 = Data.PVPMallsData[tostring(rootId)].PreEquips[1]
      --设置二层单节点位置
      local go = GameObject.Instantiate(self.model3.gameObject)
      go:SetActive(true)
      go.transform:SetParent(self.leftPanel)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.zero
      go.transform.localPosition = Vector3.New(position.x,(position.y - size.y / 2 - go:GetComponent(RectTrans).sizeDelta.y / 2),0)
      go.transform:Find("SonIcon/Image"):GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(Data.PVPMallsData[tostring(rootId)].PreEquips[1])].Icon)
      listener = NTGEventTriggerProxy.Get(go.transform:Find("SonIcon").gameObject)
      local callback = function(self, e)
        self:GetEquipInfo(layer2)
        self:ClearTree()
        self:ConnectController(layer2,self.rootIcon)
      end
      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback, self) 
      table.insert(self.forClear,go)
      --print("1_1-1")
      self.count = self.count + 1
      self:ConnectController(layer2,go.transform:Find("SonIcon"))
      
    elseif #Data.PVPMallsData[tostring(rootId)].PreEquips == 2 then
      local layerLeft = Data.PVPMallsData[tostring(rootId)].PreEquips[1]
      local layerRight = Data.PVPMallsData[tostring(rootId)].PreEquips[2]
      --print("1_1-1_1-2")
      --设置二层双节点位置
      local go = 0
      if self.count == 0 then
        go = GameObject.Instantiate(self.model5.gameObject)
      else 
        go = GameObject.Instantiate(self.model1.gameObject)
      end
      
      go:SetActive(true)
      go.transform:SetParent(self.leftPanel)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.zero
      go.transform.localPosition = Vector3.New(position.x,(position.y - size.y / 2 - go:GetComponent(RectTrans).sizeDelta.y / 2),0)
      go.transform:Find("LeftSonIcon/Image"):GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(Data.PVPMallsData[tostring(rootId)].PreEquips[1])].Icon)
      go.transform:Find("RightSonIcon/Image"):GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(Data.PVPMallsData[tostring(rootId)].PreEquips[2])].Icon)
      listener = NTGEventTriggerProxy.Get(go.transform:Find("LeftSonIcon").gameObject)
      local callback1 = function(self, e)
        self:GetEquipInfo(layerLeft)
        self:ClearTree()
        self:ConnectController(layerLeft,self.rootIcon)
      end
      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback1, self)
      
      listener = NTGEventTriggerProxy.Get(go.transform:Find("RightSonIcon").gameObject)
      local callback2 = function(self, e)
        self:GetEquipInfo(layerRight)
        self:ClearTree()
        self:ConnectController(layerRight,self.rootIcon)
      end
      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback2, self)
      
      table.insert(self.forClear,go)      
      self.count = self.count + 1
      self:ConnectController(layerLeft,go.transform:Find("LeftSonIcon"))
      self:ConnectController(layerRight,go.transform:Find("RightSonIcon"))
      
    elseif #Data.PVPMallsData[tostring(rootId)].PreEquips == 3 then
      local layer2Left = Data.PVPMallsData[tostring(rootId)].PreEquips[1]
      local layer2Mid = Data.PVPMallsData[tostring(rootId)].PreEquips[2]
      local layer2Right = Data.PVPMallsData[tostring(rootId)].PreEquips[3]
      --print("1_1-1_1-2_1-3")
      --设置二层三节点位置
      local go = GameObject.Instantiate(self.model4.gameObject)
      go:SetActive(true)
      go.transform:SetParent(self.leftPanel)
      go.transform.localScale = Vector3.one
      go.transform.localPosition = Vector3.zero
      go.transform.localPosition = Vector3.New(position.x,(position.y - size.y / 2 - go:GetComponent(RectTrans).sizeDelta.y / 2),0)
      go.transform:Find("LeftSonIcon/Image"):GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(Data.PVPMallsData[tostring(rootId)].PreEquips[1])].Icon)
      go.transform:Find("MidSonIcon/Image"):GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(Data.PVPMallsData[tostring(rootId)].PreEquips[2])].Icon)
      go.transform:Find("RightSonIcon/Image"):GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(Data.PVPMallsData[tostring(rootId)].PreEquips[3])].Icon)
      listener = NTGEventTriggerProxy.Get(go.transform:Find("LeftSonIcon").gameObject)
      local callback3 = function(self, e)
        self:GetEquipInfo(layer2Left)
        self:ClearTree()
        self:ConnectController(layer2Left,self.rootIcon)
      end
      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback3, self)
      
      listener = NTGEventTriggerProxy.Get(go.transform:Find("MidSonIcon").gameObject)
      local callback4 = function(self, e)
        self:GetEquipInfo(layer2Mid)
        self:ClearTree()
        self:ConnectController(layer2Mid,self.rootIcon)
      end
      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback4, self)
      
      listener = NTGEventTriggerProxy.Get(go.transform:Find("RightSonIcon").gameObject)
      local callback5 = function(self, e)
        self:GetEquipInfo(layer2Right)
        self:ClearTree()
        self:ConnectController(layer2Right,self.rootIcon)
      end
      listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback5, self)
    
      table.insert(self.forClear,go)    
      self.count = self.count + 1
      self:ConnectController(layer2Left,go.transform:Find("LeftSonIcon"))
      self:ConnectController(layer2Mid,go.transform:Find("MidSonIcon"))
      self:ConnectController(layer2Right,go.transform:Find("RightSonIcon"))
      
    end
  end
  
end

function EquipInsideController:ClearTree()
  if self.forClear ~= nil then
    for i = 1,#self.forClear do
      Object.Destroy(self.forClear[i])
    end
  end
  self.count = 0
end

function EquipInsideController:FindAllComposedEquip(equipId)
  local composedEquip = {}
  for k,v in pairs(Data.PVPMallsData) do
    if Data.PVPMallsData[k].PreEquips ~= nil then
      for i = 1,#Data.PVPMallsData[k].PreEquips do
        if Data.PVPMallsData[k].PreEquips[i] == equipId then
          table.insert(composedEquip,Data.PVPMallsData[k].EquipId)
        end
      end
    end
  end
  for i = 1,#composedEquip do
    if composedEquip[i+1] == composedEquip[i] then
      table.remove(composedEquip,i+1)
    end
  end


  return composedEquip
end

function EquipInsideController:ShowAllComposedEquip(list)
  --[[
  if self.leftPanel:Find("CanCompose/List/Panel").childCount > 1 then
    local sonNum = self.leftPanel:Find("CanCompose/List/Panel").childCount
    for i = 2,sonNum do
      Object.Destroy(self.leftPanel:Find("CanCompose/List/Panel"):GetChild(i - 1).gameObject)
    end
  end  
  
  for i = 1,#list do
    local go = GameObject.Instantiate(self.element.gameObject)
    go:SetActive(true)
    go.transform.parent = self.leftPanel:Find("CanCompose/List/Panel")
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
    go.transform:Find("Image"):GetComponent(Image).sprite = UITools.GetSprite("EquipInside","UEquipInside-BaseIcon")
    local listener = NTGEventTriggerProxy.Get(go)
    local callback5 = function(self, e)
      self:GetEquipInfo(list[i])
      self:ClearTree()
      self:ConnectController(list[i],self.rootIcon)
    end
    listener.onPointerClick = listener.onPointerClick + DelegateFactory.NTGEventTriggerProxy_PointerEventDelegate_Self(self, callback5)
  end
  ]]
  local abc = self.itemAPI.self
  abc:ResetItemsSimple(#list)
  for i = 1,#abc.itemList do
    abc.itemList[i].transform:Find("Image"):GetComponent(Image).sprite = UITools.GetSprite("equipicon",Data.EquipsData[tostring(list[i])].Icon)
    local listener = NTGEventTriggerProxy.Get(abc.itemList[i].transform.gameObject)
    local callback5 = function(self, e)
      self:GetEquipInfo(list[i])
      self:ClearTree()
      self:ConnectController(list[i],self.rootIcon)
    end
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(callback5, self)    
  end
  
  
  
  
end




function EquipInsideController:GetEquipInfo(equipId)
  local list = self:FindAllComposedEquip(equipId)
  self:ShowAllComposedEquip(list)
  
  
  --清除上一次生成的属性列表
  local length = self.equipPropertyPanel.childCount
  if length > 1 then
    for i = 2,length do
      Object.Destroy(self.equipPropertyPanel:GetChild(i-1).gameObject)
    end
  end

  
  
  local properties = UTGDataOperator.Instance:GetSortedPropertiesByKey("Equip",equipId)
  local skill = Data.EquipsData[tostring(equipId)].PassiveSkills
  local skillDesc = {}
  local desc = ""
  if skill ~= nil then
    for i = 1,#skill do
      --table.insert(skillDesc,Data.SkillsData[tostring(skill[i])].Desc)
      desc = desc .. "\n" .. Data.SkillsData[tostring(skill[i])].Desc
    end
  end
  
  
  for i = 1,#properties do
    local go = GameObject.Instantiate(self.equipProperty.gameObject)
    go:SetActive(true)
    go.transform:SetParent(self.equipPropertyPanel)
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
    go.transform:GetComponent(Text).text = "+" .. properties[i].Attr .. "  " .. properties[i].Des
  end
  self.equipName:GetComponent(Text).text = Data.EquipsData[tostring(equipId)].Name
  --设置被动技能框位置
  local py = self.equipPropertyPanel.localPosition.y - (25 * (#properties + 1)) - self.equipSkill:GetComponent(RectTrans).sizeDelta.y / 2
  self.equipSkill.localPosition = Vector3.New(self.equipSkill.localPosition.x,py,0 )
  self.equipSkill:GetComponent(Text).text = desc
  self.equipPrice:GetComponent(Text).text = Data.PVPMallsData[tostring(equipId)].Price
end





function EquipInsideController:DestroySelf()
  Object.Destroy(self.this.gameObject)
end


function EquipInsideController:OnDestroy()
  self.this = nil
  self = nil
end







