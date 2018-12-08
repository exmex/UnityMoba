using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030190 : NTGBattlePassiveSkillBehaviour
{
    public float pAddMp;

    public override void Respawn()
    {
        base.Respawn();

        pAddMp = owner.mpMax * this.param[0];

        StartCoroutine(doRecover());
    }

    private IEnumerator doRecover()
    {
        FXEA();
        FXEB();

        yield return new WaitForSeconds(0.1f);

        ShootBase(owner);
        baseValue = pAddMp;
        effectType = EffectType.MpRecover;
        owner.Hit(shooter, this);

        yield return new WaitForSeconds(0.1f);
        Release();
    }
}
