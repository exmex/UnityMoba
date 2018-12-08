
class("SkillSingleShootAB", "SkillSingleShoot", "Logic.Battle.Skill.SkillSingleShoot")

function SkillSingleShootAB:Awake(this) 
  SkillSingleShoot.Awake(self, this)
  
  self.this = this

  self.behaviour = self.this:GetComponent("NTGBattleSkillBehaviour")
  self.collider = self.this:GetComponent("CapsuleCollider")
  
  self.allyFX = this.transforms[0]
  self.enemyFX = this.transforms[1]
  
end

function SkillSingleShootAB:OnDestroy()
  SkillSingleShoot.OnDestroy(self)
  
  self.this = nil
  self = nil
end

function SkillSingleShootAB:Shoot(lockedTarget)  
  
  if self.behaviour.owner.group == self.behaviour.owner.mainController.uiController.localPlayerController.group then
    self.allyFX.gameObject:SetActive(true)
    self.enemyFX.gameObject:SetActive(false)
    
    self.behaviour.skillFX = self.allyFX
  else
    self.allyFX.gameObject:SetActive(false)
    self.enemyFX.gameObject:SetActive(true)
    
    self.behaviour.skillFX = self.enemyFX
  end
  
  self.behaviour:InitFXParts()
  
  SkillSingleShoot.Shoot(self, lockedTarget)
  
end

function SkillSingleShootAB:OnTriggerEnter(other)
  SkillSingleShoot.OnTriggerEnter(self, other)
end