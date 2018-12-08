using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600001212 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pAmount;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = duration;
        pAmount = this.param[0];
        owner.baseAttrs.AtkSpeed += pAmount;
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

            owner.baseAttrs.AtkSpeed -= pAmount;
            pAmount = p.param[0];
            owner.baseAttrs.AtkSpeed += pAmount;
            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.AtkSpeed -= pAmount;
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
        owner.baseAttrs.AtkSpeed -= pAmount;
        owner.ApplyBaseAttrs();

        Release();
    }
}