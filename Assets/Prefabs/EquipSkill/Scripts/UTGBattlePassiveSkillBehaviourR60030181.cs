using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030181 : NTGBattlePassiveSkillBehaviour
{
    public float pRecoverAmount;
    public float pCd;
    public float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        pCd = this.param[1];
        pDuration = this.duration;

        StartCoroutine(doRecover());
    }

    private IEnumerator doRecover()
    {
        FXEA();
        FXEB();

        while (pDuration > 0)
        {
            ShootBase(owner);
            baseValue = owner.mpMax * this.param[0];
            effectType = EffectType.MpRecover;
            owner.Hit(shooter, this);

            yield return new WaitForSeconds(pCd);
            pDuration -= pCd;
        }

        Release();
    }


}
