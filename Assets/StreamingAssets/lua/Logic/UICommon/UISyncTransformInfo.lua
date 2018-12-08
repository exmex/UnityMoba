require "System.Global"

UISyncTransformInfo = {}
----------------------------------------------------
function UISyncTransformInfo:New(o)
  local o = o or {}
  setmetatable(o, UISyncTransformInfo)
  UISyncTransformInfo.__index = UISyncTransformInfo
  return o
end
----------------------------------------------------
function UISyncTransformInfo:Awake(this) 
  self.this = this  
  --------------------字段--------------------
  self.syncType=self.this.ints[0]; --枚举   0：同步Position   1：同步Rotation
  self.transform=self.this.transform;
  self.target=self.this.transforms[0];
  --------------------------------------------
end
----------------------------------------------------
function UISyncTransformInfo:Start()

end
----------------------------------------------------
function UISyncTransformInfo:LateUpdate()
  
  if(self.syncType==0)then
    self.transform.position= self.target.position;
  elseif(self.syncType==1)then
    self.transform.rotation= self.target.rotation;
  end
  
end
----------------------------------------------------
function UISyncTransformInfo:OnDestroy()
  
  self.this = nil
  self = nil
end