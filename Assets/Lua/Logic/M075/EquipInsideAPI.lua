require "System.Global"

class("EquipInsideAPI")

function EquipInsideAPI:Awake(this)
  self.this = this
  self.panel = self.this.transforms[0]
  for i = 1,2 do
    --print("^^^^^^^^^ " .. self.panel:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[i-1].luaScript)
    if self.panel:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[i-1].luaScript == "Logic.M075.EquipInsideController" then
      self.heroInfoController = self.panel:GetComponents(NTGLuaScript.GetType("NTGLuaScript"))[i-1]
    end
  end
  EquipInsideAPI.Instance = self
  
end

function EquipInsideAPI:Init(equipId)
  self.heroInfoController.self:ClearTree()
  self.heroInfoController.self:ConnectController(equipId)
  self.heroInfoController.self:GetEquipInfo(equipId)
end



function EquipInsideAPI:OnDestroy()
  self.this = nil
  self = nil
  EquipInsideAPI.Instance = nil
end


