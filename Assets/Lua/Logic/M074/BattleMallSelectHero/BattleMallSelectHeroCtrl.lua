--author zx
require "System.Global"
require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("BattleMallSelectHeroCtrl")

function BattleMallSelectHeroCtrl:Awake(this)--awake
  self.this = this
  self.root = self.this.transforms[0]
  --关闭面板事件
  local listener = {}
  listener = NTGEventTriggerProxy.Get(self.this.transforms[1].gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleMallSelectHeroCtrl.ClickClosePanel,self) 
  self.classbuts = self.this.transforms[3]
  for i=1,self.classbuts.childCount do
    listener = NTGEventTriggerProxy.Get(self.classbuts:GetChild(i-1).gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleMallSelectHeroCtrl.ClickClassBut,self) 
  end
  listener = NTGEventTriggerProxy.Get(self.this.transforms[4].gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleMallSelectHeroCtrl.ClickOwn,self) 

  self.grid = self.this.transforms[2]

  self.roleData = {}
end



function BattleMallSelectHeroCtrl:Start()

end

function BattleMallSelectHeroCtrl:Init()
  self.showOwn = true
  self.clickClassIndex = -1
  self:GetRoleDataByClass(-1)
end

--选择出不同职业的role数据
function BattleMallSelectHeroCtrl:GetRoleDataByClass(classType)

  self.roleData = {}
  if classType == -1 then
    if self.showOwn then
      for k,v in pairs(UTGData.Instance().RolesDeck) do
        if v.IsOwn then table.insert(self.roleData,UTGData.Instance().RolesData[tostring(v.RoleId)]) end
      end
    else
      for k,v in pairs(UTGData.Instance().RolesData) do
        table.insert(self.roleData,v)
      end
    end
  else
    if self.showOwn then
      for k,v in pairs(UTGData.Instance().RolesDeck) do
        if v.IsOwn and UTGData.Instance().RolesData[tostring(v.RoleId)].Class == classType then table.insert(self.roleData,UTGData.Instance().RolesData[tostring(v.RoleId)]) end
      end
    else
      for k,v in pairs(UTGData.Instance().RolesData) do
        if v.Class == classType then
          table.insert(self.roleData,v)
        end   
      end
    end 
  end
  --按Id排序
  local isF = true
  for j=1 ,#self.roleData do
    isF = true
    for i=#self.roleData-1,j,-1 do
      if self.roleData[i].Id >self.roleData[i+1].Id then
          local temp = self.roleData[i]
          self.roleData[i] = self.roleData[i+1]
          self.roleData[i+1] =temp
         isF = false
       end
    end
    if isF then break end
  end
    self:FillRoleIconLis(self.roleData)
end

--生成人物头像列表
function BattleMallSelectHeroCtrl:FillRoleIconLis(data)

  local api = self.grid:GetComponent("NTGLuaScript").self
  if data==nil then
    api:ResetItemsSimple(0)
    return
  end
  api:ResetItemsSimple(#data)
  self.tranRole = {}
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform
    local roleId = data[i].Id
    tempo.name = tostring(roleId)
    self.tranRole[tostring(roleId)] = tempo 

    local roleicon = UTGData.Instance().SkinsData[tostring(data[i].Skin)].Icon 
    tempo:FindChild("root/mask/icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",tostring(roleicon),"UnityEngine.Sprite")
    tempo:FindChild("root/wu/icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("roleicon",tostring(roleicon),"UnityEngine.Sprite")
    --tempo:FindChild("name"):GetComponent("UnityEngine.UI.Text").text = tostring(data[i].Name)
    if UTGData.Instance():IsLimitFreeDataById(data[i].Id) == true then--是限免英雄
      tempo:FindChild("root/free").gameObject:SetActive(true)
      tempo:FindChild("root/wu").gameObject:SetActive(true)
    end
    local role = UTGData.Instance():GetRoleDeckByRoleId(data[i].Id)    
    if role ==nil or (role~=nil and role.IsOwn ==false) then
      tempo:FindChild("root/wu").gameObject:SetActive(true)
    end
    if role~=nil and role.IsOwn ==true then
      tempo:FindChild("root/wu").gameObject:SetActive(false)
    end
    if BattleMallSelectHeroAPI.Instance.isRune == true then
    else
      --装备预设--
      if role ~=nil then
        local defaultEquipIds = data[i].BattleEquips
        local nowEquipIds = role.BattleEquips
        local result = 0 --1：自定义完成 2:自定义未完成 
        local nowcount = 0 
        for i=1,#nowEquipIds do
          if nowEquipIds[i]<0 then
            nowcount = 1+nowcount
          end
          if nowEquipIds[i] ~= defaultEquipIds[i] then result = 1 end
        end
        if result ==1 and nowcount==0 then
          tempo:FindChild("root/txt").gameObject:SetActive(true)
          tempo:FindChild("root/diyok"):GetComponent("UnityEngine.UI.Text").text = "自定义完成"
        end
        if nowcount>0 then
          tempo:FindChild("root/txt").gameObject:SetActive(true)
          tempo:FindChild("root/diynotok"):GetComponent("UnityEngine.UI.Text").text = "自定义 <color=#FF0000FF>"..(6-nowcount).."/6".."</color>"
        end
      end
    end
    --点击
    UITools.GetLuaScript(tempo.gameObject,"Logic.UICommon.UIClick"):RegisterClickDelegate(self,self.ClickRoleIcon,roleId) 
  end
  
end

--选择不同职业
function BattleMallSelectHeroCtrl:ClickClassBut(eventdata)
  local index = eventdata.pointerPress.name
  for i=1,self.classbuts.childCount do
    self.classbuts:GetChild(i-1):FindChild("select").gameObject:SetActive(false)
  end
  self.classbuts:FindChild(index.."/select").gameObject:SetActive(true)
  self.clickClassIndex = tonumber(index)
  self:GetRoleDataByClass(tonumber(index))
  
end 
--选择英雄
function BattleMallSelectHeroCtrl:ClickRoleIcon(roleId)
  roleId = tonumber(roleId)
  --print("选择的RoleId = "..roleId)
  if BattleMallSelectHeroAPI.Instance.isRune == true then
    --RuneAPI.Instance:SetRoleIdBySelectHero(roleId)
    RuneAPI.Instance:InitRuneRecommend(roleId,1)
  else
    PreviewEquipAPI.Instance:SetRoleIdBySelectHero(roleId)
  end
  self:ClickClosePanel()
  
end 
--选择是否已拥有
function BattleMallSelectHeroCtrl:ClickOwn(eventdata)
  local temp = eventdata.pointerPress.transform
  if temp:FindChild("ok").gameObject.activeSelf then
    temp:FindChild("ok").gameObject:SetActive(false)
    self.showOwn = false
    self:GetRoleDataByClass(self.clickClassIndex)
  else
    temp:FindChild("ok").gameObject:SetActive(true)
    self.showOwn = true
    self:GetRoleDataByClass(self.clickClassIndex)
  end
end 
--关闭面板
function BattleMallSelectHeroCtrl:ClickClosePanel()
  Object.Destroy(self.this.transform.parent.gameObject)
end


function BattleMallSelectHeroCtrl:OnDestroy()
  self.this = nil
  self = nil
end