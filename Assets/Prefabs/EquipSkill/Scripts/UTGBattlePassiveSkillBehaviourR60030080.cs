using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030080 : NTGBattlePassiveSkillBehaviour
{

    public float pDuration;

    public float moveAmount;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = this.duration;
        moveAmount = -owner.baseAttrs.MoveSpeed * this.param[0];

        owner.baseAttrs.MoveSpeed += moveAmount;

        owner.ApplyBaseAttrs();
        FXEA();
        FXEB();
        StartCoroutine(doBoost());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            shooter = p.shooter;
            pDuration = p.duration;
            owner.baseAttrs.MoveSpeed -= moveAmount;
            moveAmount = -owner.baseAttrs.MoveSpeed * p.param[0];
            owner.baseAttrs.MoveSpeed += moveAmount;
            owner.ApplyBaseAttrs();
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed -= moveAmount;
            owner.ApplyBaseAttrs();

            Release();
        }
    }

    private IEnumerator doBoost()
    {
        while (pDuration > 0)
        {
            pDuration -= 0.1f;
            yield return new WaitForSeconds(0.1f);
        }

        owner.baseAttrs.MoveSpeed -= moveAmount;

        owner.ApplyBaseAttrs();

        Release();
    }
}
