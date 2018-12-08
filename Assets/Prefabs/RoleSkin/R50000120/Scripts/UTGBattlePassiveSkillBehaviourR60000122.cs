using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000122 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pAmount;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = duration;
        pAmount = -owner.baseAttrs.MoveSpeed*this.param[0];
        owner.baseAttrs.MoveSpeed += pAmount;
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

            owner.baseAttrs.MoveSpeed -= pAmount;
            pAmount += -owner.baseAttrs.MoveSpeed*p.param[0];
            owner.baseAttrs.MoveSpeed += pAmount;
            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed -= pAmount;
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
        owner.baseAttrs.MoveSpeed -= pAmount;
        owner.ApplyBaseAttrs();

        Release();
    }
}