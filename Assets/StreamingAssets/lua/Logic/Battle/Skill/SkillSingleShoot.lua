
class("SkillSingleShoot")


function SkillSingleShoot:Awake(this) 
  self.this = this  

  self.behaviour = self.this:GetComponent("NTGBattleSkillBehaviour")
  self.collider = self.this:GetComponent("CapsuleCollider")
  
end

function SkillSingleShoot:OnDestroy()
  self.this = nil
  self = nil
end

function SkillSingleShoot:Shoot(lockedTarget)  
  self.behaviour:ShootBase(lockedTarget)
  
  self.startPos = self.behaviour.transform.position
  
  self.this:StartCoroutine(NTGLuaCoroutine.New(self, SkillSingleShoot.doShoot))  
  
end

function SkillSingleShoot:doShoot()
  
  self.behaviour:FXShoot()
  self.behaviour:FXFlying()
  self.hitTarget = false
  self.collider.enabled = true
  self.owner = self.behaviour.owner
  self.lockedTarget = self.behaviour.lockedTarget
    
  if IsNil(self.lockedTarget) == false then            
      self.lockedTargetCollider = self.lockedTarget.gameObject:GetComponent("CapsuleCollider")     
  end
  
  while IsNil(self.owner) == false and self.hitTarget == false and Vector3.Distance(self.behaviour.transform.position, self.startPos) < self.behaviour.range do
  
    if IsNil(self.lockedTarget) == false and Vector3.Distance(self.lockedTarget.transform.position + self.lockedTargetCollider.center, self.behaviour.transform.position) < 0.1 then      
      break      
    end
    
    if IsNil(self.lockedTarget) == false and self.lockedTarget.alive then            
      self.behaviour.transform:LookAt(self.lockedTarget.transform.position + self.lockedTargetCollider.center)      
    end
    
    self.behaviour.transform:Translate(0, 0, self.behaviour.speed * Time.deltaTime)
    
    coroutine.yield(nil)    
  
  end

  if self.hitTarget then
    coroutine.yield(WaitForSeconds.New(2.0))
  end
  
  self.behaviour:Release()
  
end

function SkillSingleShoot:OnTriggerEnter(other)
  
  if IsNil(self.behaviour.owner) then
    return
  end
  
  local otherUnit = other:GetComponent("NTGBattleUnitController")
  if IsNil(otherUnit) == false and otherUnit.alive == true and otherUnit.group ~= self.behaviour.owner.group and self.behaviour:IsValidTarget(otherUnit) then

    otherUnit:Hit(self.behaviour.owner, self.behaviour)
  
    self.behaviour:FXHit(otherUnit)        
    self.hitTarget = true    
    self.collider.enabled = false    
  end  
  
  if other.tag == "Ground" then
  
    self.behaviour:FXHit(nil)  
    self.hitTarget = true
    self.collider.enabled = false  
  end

end
