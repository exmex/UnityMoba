using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030210 : NTGBattlePassiveSkillBehaviour
{
    public float pAddDamage;

    public override void Respawn()
    {
        base.Respawn();

        pAddDamage = shooter.baseAttrs.MAtk * this.param[0];

        StartCoroutine(doAddDamage());
    }

    private IEnumerator doAddDamage()
    {
        yield return new WaitForSeconds(0.1f);

        ShootBase(owner);
        baseValue = pAddDamage;
        effectType = EffectType.MagicDamage;
        owner.Hit(shooter, this);
        FXHit(owner);
        Release();
    }
}
