using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030260 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pCd;
    public float pDamageAmount;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = this.duration;
        pCd = this.param[0];

        StartCoroutine(doBoost());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            if(p == this)
            {
                pDuration = this.duration;
            }
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            pDuration = 0;
            Release();
        }
    }


    private IEnumerator doBoost()
    {
        yield return new WaitForSeconds(0.1f);
        while(pDuration > 0)
        {
            pDamageAmount = owner.hp * this.param[1];
            if (pDamageAmount < 0)
                pDamageAmount = 0;
            ShootBase(owner);
            baseValue = pDamageAmount;
            effectType = EffectType.MagicDamage;
            owner.Hit(shooter, this);
            FXHit(owner);
            yield return new WaitForSeconds(pCd);
            pDuration -= pCd;
        }
        

        Release();
    }
}
