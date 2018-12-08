using UnityEngine;
using System.Collections;

public class UTGBattleSkillPassiveBehaviourR600600401 : NTGBattlePassiveSkillBehaviour
{
    private float pMoveSpeedAmount;
    private float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = this.duration;
        pMoveSpeedAmount = owner.baseAttrs.MoveSpeed * this.param[0];
        owner.baseAttrs.MoveSpeed += pMoveSpeedAmount;
        owner.ApplyBaseAttrs();

        FXEA();
        FXEB();

        StartCoroutine(doEffect());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            if (p.param[0] > this.param[0])
            {
                pDuration = p.duration;
                owner.baseAttrs.MoveSpeed -= pMoveSpeedAmount;
                pMoveSpeedAmount = owner.baseAttrs.MoveSpeed * p.param[0];
                owner.baseAttrs.MoveSpeed += pMoveSpeedAmount;
                owner.ApplyBaseAttrs();
            }
            else if (e == NTGBattlePassive.Event.PassiveRemove)
            {
                owner.baseAttrs.MoveSpeed -= pMoveSpeedAmount;
                owner.ApplyBaseAttrs();

                Release();
            }
        }
    }

    private IEnumerator doEffect()
    {
        while(pDuration > 0f)
        {
            pDuration -= 0.1f;
            yield return new WaitForSeconds(0.1f);
        }

        owner.baseAttrs.MoveSpeed -= pMoveSpeedAmount;
        owner.ApplyBaseAttrs();

        Release();


    }
}
