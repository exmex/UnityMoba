using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030040 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pAmount;
    public float pCount;

    public override void Respawn()
    {
        base.Respawn();

        pCount = 1;
        pDuration = duration;
        pAmount = -this.param[0];
        owner.baseAttrs.PDef += pAmount;
        owner.ApplyBaseAttrs();

        FXEA();
        FXEB();

        StartCoroutine(doBoost());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour) param;
            shooter = p.shooter;
            pDuration = p.duration;

            if (pCount < p.param[1])
            {
                owner.baseAttrs.PDef -= pAmount;
                pCount++;
                pAmount += -p.param[0];
                owner.baseAttrs.PDef += pAmount;
                owner.ApplyBaseAttrs();
            }
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.PDef -= pAmount;
            owner.ApplyBaseAttrs();

            Release();
        }
    }

    private IEnumerator doBoost()
    {
        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }
        owner.baseAttrs.PDef -= pAmount;
        owner.ApplyBaseAttrs();

        Release();
    }
}