using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600302901 : NTGBattlePassiveSkillBehaviour
{
    public float pDamage;

    public override void Respawn()
    {
        base.Respawn();
        ShootBase(owner);

        pDamage = this.param[1] + shooter.level * this.param[2];
        baseValue = pDamage;
        effectType = EffectType.MagicDamage;
        owner.Hit(shooter, this);
        FXHit(owner);
        Release();

    }

}
