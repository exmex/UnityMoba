using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030320 : NTGBattlePassiveSkillBehaviour
{
    public float pHpAddAmount;
    public float pCd;
    public float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        pCd = this.param[0];
        pDuration = this.duration;

        StartCoroutine(doRecover());
    }

    private IEnumerator doRecover()
    {
        while(pDuration > 0)
        {
            pHpAddAmount = owner.hpMax * this.hpAdd;
            ShootBase(owner);
            baseValue = pHpAddAmount;
            effectType = EffectType.HpRecover;
            owner.Hit(shooter, this);
            FXHit(owner);
            yield return new WaitForSeconds(pCd);
            pDuration -= pCd;
        }

        Release();
    }
}
