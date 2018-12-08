using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030570 : NTGBattlePassiveSkillBehaviour
{
    public float pDamage;
    public override void Respawn()
    {
        base.Respawn();
        ShootBase(owner);
        pDamage = this.param[0] + this.param[1] * shooter.level;

        baseValue = pDamage;
        effectType = EffectType.PhysicDamage;
        owner.Hit(shooter, this);
        FXHit(owner);
        Release();

    }
}
