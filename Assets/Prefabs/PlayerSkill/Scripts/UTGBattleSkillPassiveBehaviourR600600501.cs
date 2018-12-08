using UnityEngine;
using System.Collections;

public class UTGBattleSkillPassiveBehaviourR600600501 : NTGBattlePassiveSkillBehaviour
{

    public float pDuration;
    public float pAmount;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = this.duration;
        pAmount = owner.baseAttrs.MoveSpeed * this.param[0];

        StartCoroutine(doUpSpeed());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            shooter = p.shooter;
            pDuration = p.duration;

            owner.baseAttrs.MoveSpeed -= pAmount;
            pAmount = owner.baseAttrs.MoveSpeed * p.param[0];
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

    private IEnumerator doUpSpeed()
    {
        FXEA();
        FXEB();

        var d = duration;

        float moveSpeedUpTemp = owner.baseAttrs.MoveSpeed * this.param[0];

        owner.baseAttrs.MoveSpeed = owner.baseAttrs.MoveSpeed + moveSpeedUpTemp;

        owner.ApplyBaseAttrs();

        while (d > 0)
        {
            d -= 0.1f;
            yield return new WaitForSeconds(0.1f);
        }

        owner.baseAttrs.MoveSpeed = owner.baseAttrs.MoveSpeed - moveSpeedUpTemp;

        owner.ApplyBaseAttrs();

        Release();
    }

}
