require "System.Global"
--lua标准模板
UIShopEquipData = {}
----------------------------------------------------
function UIShopEquipData:New(o)
  local o = o or {}
  setmetatable(o, UIShopEquipData)
  UIShopEquipData.__index = UIShopEquipData
  return o
end
----------------------------------------------------
function UIShopEquipData:Awake(this) 
  self.this = this  
  
  
  self.selfId=nil;
  self.lIds =nil; --{}  --List<string>
  self.rIds =nil;

end
----------------------------------------------------
function UIShopEquipData:Start()
  
 

end
----------------------------------------------------
function UIShopEquipData:OnDestroy()
  
  self.this = nil
  self = nil
end