
class("SkillR60000001")

function SkillR60000001:Awake(this) 
  self.this = this  

  self.behaviour = self.this:GetComponent("NTGBattleSkillBehaviour")
  self.collider = self.this:GetComponent("CapsuleCollider")
  
  self.hitTime = this.floats[0]
end

function SkillR60000001:OnDestroy()
  self.this = nil
  self = nil
end

function SkillR60000001:Shoot(lockedTarget)  
  self.behaviour:ShootBase(lockedTarget)
  
  self.targetAngle = self.behaviour.param[0]
  
  self.collider.radius = self.behaviour.param[1]
  self.collider.enabled = false
  
  self.this:StartCoroutine(NTGLuaCoroutine.New(self, SkillR60000001.doShoot))  
end

function SkillR60000001:doShoot()
  
  self.behaviour:FXShoot()
  self.behaviour:FXFlying()
  
  coroutine.yield(WaitForSeconds.New(self.hitTime))
  self.collider.enabled = true
  coroutine.yield(WaitForSeconds.New(0.1))
  self.collider.enabled = false
  
  coroutine.yield(WaitForSeconds.New(10.0))
  
  self.behaviour:Release()
  
end

function SkillR60000001:OnTriggerEnter(other)
  
  if IsNil(self.behaviour.owner) then
    return
  end
  
  local otherUnit = other:GetComponent("NTGBattleUnitController")
  if IsNil(otherUnit) == false and otherUnit.alive == true and otherUnit.group ~= self.behaviour.owner.group and self.behaviour:IsValidTarget(otherUnit) then
    local angle = Vector3.Angle(self.this.transform.forward, other.transform.position - self.this.transform.position)
    
    if angle > self.targetAngle then
      return
    end
    
    otherUnit:Hit(self.behaviour.owner, self.behaviour)
    
    otherUnit:AddPassiveLua("Slow", {self.behaviour.param[2], self.behaviour.param[3]})
    
    self.behaviour:FXHit(otherUnit)    
    
  end  
end



