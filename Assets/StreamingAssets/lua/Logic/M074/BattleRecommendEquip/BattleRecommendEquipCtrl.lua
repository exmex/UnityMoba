--author zx
require "System.Global"
--require "Logic.UTGData.UTGData"
--require "Logic.UTGData.UTGDataTemporary"
class("BattleRecommendEquipCtrl")
local json = require "cjson"
function BattleRecommendEquipCtrl:Awake(this)--awake
  self.this = this
  self.root = self.this.transforms[0]
  --关闭面板事件
  local listener = NTGEventTriggerProxy.Get(self.this.transforms[1].gameObject)
  listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleRecommendEquipCtrl.ClickClosePanel,self)
  self.roleId = 0
  self.recommendlis = {}
end


function BattleRecommendEquipCtrl:Init(roleId)
  self.roleId = roleId
  self.recommendlisAPI = self.this.transforms[2]:GetComponent("NTGLuaScript").self
  --获取推荐装备数据
  for k,v in pairs(UTGData.Instance().GodEquipConfigsData) do
    if v.RoleId == self.roleId then
      table.insert(self.recommendlis,v)
    end
  end
  --[[
  for i=1,#self.recommendlis do
    local temp = self.recommendlis[i]
    print(" roleid "..temp.RoleId.."  ")
    for i=1,#temp.Equips do
      print("Equips  "..temp.Equips[i].."  ")
    end
  end
  ]]
  for j=1 ,#self.recommendlis do
    for i=#self.recommendlis-1,j,-1 do
      if self.recommendlis[i].Rank >self.recommendlis[i+1].Rank then
          local temp = self.recommendlis[i]
          self.recommendlis[i] = self.recommendlis[i+1]
          self.recommendlis[i+1] =temp
       end
    end
  end
  --生成列表
  self:FillEquipLis(self.recommendlis)
end

--生成推荐装备列表
function BattleRecommendEquipCtrl:FillEquipLis(data)
  local api = self.recommendlisAPI
  if data==nil then
    api:ResetItemsSimple(0)
    Debugger.LogError("没有推荐装备数据")
    return
  end
  api:ResetItemsSimple(#data)
  for i=1,#api.itemList do
    local tempo = api.itemList[i].transform
    tempo.name = tostring(i)
    --装备图标
    local equipgrid = tempo:FindChild("grid")
    for j=1,equipgrid.childCount do
      local temp = equipgrid:GetChild(j-1)
      local equip = UTGData.Instance().EquipsData[tostring(data[i].Equips[j])]
      if equip == nil then 
        temp:FindChild("icon").gameObject:SetActive(false)
      else
        --Debugger.LogError("equip.Icon "..equip.Id.."  " ..equip.Icon)
        temp:FindChild("icon").gameObject:SetActive(true)
        temp:FindChild("icon"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("equipicon",tostring(equip.Icon),"UnityEngine.Sprite")
      end
      
    end
    --数字
    local num = tempo:FindChild("num")
    if i<10 then
      num:FindChild("ge").gameObject:SetActive(true)
      num:FindChild("ge/0"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("BattleRecommendEquip",tostring(i),"UnityEngine.Sprite")
    elseif i>=10 and i<100 then
      num:FindChild("shi").gameObject:SetActive(true)
      num:FindChild("shi/0"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("BattleRecommendEquip",tostring(i%10),"UnityEngine.Sprite")
      num:FindChild("shi/1"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("BattleRecommendEquip",tostring(math.floor(i/10)),"UnityEngine.Sprite")
    elseif i>=100 then
      num:FindChild("bai").gameObject:SetActive(true)
      num:FindChild("bai/0"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("BattleRecommendEquip",tostring(i%10),"UnityEngine.Sprite")
      num:FindChild("bai/1"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("BattleRecommendEquip",tostring(math.floor(i/10)%10),"UnityEngine.Sprite")
      num:FindChild("bai/2"):GetComponent("UnityEngine.UI.Image").sprite = NTGResourceController.Instance:LoadAsset("BattleRecommendEquip",tostring(math.floor(i/100)),"UnityEngine.Sprite")
    end
    --点击
    local listener = NTGEventTriggerProxy.Get(tempo:FindChild("but_ok").gameObject)
    listener.onPointerClick = NTGEventTriggerProxy.PointerEventDelegateSelf(BattleRecommendEquipCtrl.ClickRecommend,self)
    
  end
  
end
--选择推荐
function BattleRecommendEquipCtrl:ClickRecommend(eventdata)
  local index = tonumber(eventdata.pointerPress.transform.parent.name)
  local equipIds = self.recommendlis[index].Equips
  PreviewEquipAPI.Instance:SetParamBy74(equipIds)
  self:ClickClosePanel()
end 
--关闭面板
function BattleRecommendEquipCtrl:ClickClosePanel()
  Object.Destroy(self.this.transform.parent.gameObject)
end


function BattleRecommendEquipCtrl:OnDestroy()
  self.this = nil
  self = nil
end