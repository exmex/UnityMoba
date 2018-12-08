using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600301501 : NTGBattlePassiveSkillBehaviour
{
    public float pMoveSpeedAmount;
    public float pDamage;
    public float pDuration;
    public override void Respawn()
    {
        base.Respawn();

        pDuration = this.duration;

        pMoveSpeedAmount = owner.baseAttrs.MoveSpeed * this.param[0];





        owner.baseAttrs.MoveSpeed -= pMoveSpeedAmount;
        owner.ApplyBaseAttrs();



        StartCoroutine(doCount());

    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            owner.baseAttrs.MoveSpeed += pMoveSpeedAmount;
            pMoveSpeedAmount = p.param[0] * owner.baseAttrs.MoveSpeed;
            owner.baseAttrs.MoveSpeed -= pMoveSpeedAmount;
            pDuration = p.duration;

            owner.ApplyBaseAttrs();
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed += pMoveSpeedAmount;
            owner.ApplyBaseAttrs();

            Release();
        }
    }

    private IEnumerator doCount()
    {
        while(pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }

        owner.baseAttrs.MoveSpeed += pMoveSpeedAmount;
        owner.ApplyBaseAttrs();

        Release();
    }
}
