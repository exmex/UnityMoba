using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600001331 : NTGBattlePassiveSkillBehaviour {

    public override void Respawn()
    {
        base.Respawn();

        ShootBase(owner);
        baseValue = this.param[0] * (owner.hpMax - owner.hp);
        effectType = EffectType.MagicDamage;
        owner.Hit(shooter, this);
        FXHit(owner);
        Release();
    }
}
