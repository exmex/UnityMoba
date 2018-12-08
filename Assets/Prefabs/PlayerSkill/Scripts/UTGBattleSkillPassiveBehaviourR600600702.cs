using UnityEngine;
using System.Collections;

public class UTGBattleSkillPassiveBehaviourR600600702 : NTGBattlePassiveSkillBehaviour {

    public float pAmount;
    public float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        FXEA();
        FXEB();

        pDuration = this.duration;
        pAmount = owner.baseAttrs.MoveSpeed * this.param[0];
        owner.baseAttrs.MoveSpeed = owner.baseAttrs.MoveSpeed - pAmount;
        owner.ApplyBaseAttrs();

        StartCoroutine(doSlowDown());
    }

    private IEnumerator doSlowDown()
    {

        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }
        owner.baseAttrs.MoveSpeed = owner.baseAttrs.MoveSpeed + pAmount;

        owner.ApplyBaseAttrs();

        Release();
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            shooter = p.shooter;
            pDuration = p.duration;

            owner.baseAttrs.MoveSpeed -= pAmount;
            pAmount = p.param[0];
            owner.baseAttrs.MoveSpeed += pAmount;
            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed += pAmount;
            owner.ApplyBaseAttrs();

            Release();
        }
    }
}
