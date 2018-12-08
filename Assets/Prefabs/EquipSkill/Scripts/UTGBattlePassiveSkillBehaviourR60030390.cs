using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030390 : NTGBattlePassiveSkillBehaviour
{

    public float pDuration;
    public float pMoveAmount;
    public float pAtkSpeedAmount;

    public override void Respawn()
    {
        base.Respawn();

        pMoveAmount = owner.baseAttrs.MoveSpeed * this.param[1];
        pAtkSpeedAmount = this.param[0];
        pDuration = this.duration;

        owner.baseAttrs.AtkSpeed -= pAtkSpeedAmount;
        owner.baseAttrs.MoveSpeed -= pMoveAmount;
        owner.ApplyBaseAttrs();

        StartCoroutine(doContinue());

    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            if (p == this)
            {
                owner.baseAttrs.AtkSpeed += pAtkSpeedAmount;
                owner.baseAttrs.MoveSpeed += pMoveAmount;
                pAtkSpeedAmount = p.param[0];
                pMoveAmount = p.param[1];
                owner.baseAttrs.AtkSpeed -= pAtkSpeedAmount;
                owner.baseAttrs.MoveSpeed -= pMoveAmount;
                pDuration = p.duration;
                owner.ApplyBaseAttrs();
            }
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.AtkSpeed += pAtkSpeedAmount;
            owner.baseAttrs.MoveSpeed += pMoveAmount;
            owner.ApplyBaseAttrs();

            Release();
        }
    }


    private IEnumerator doContinue()
    {
        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }
        owner.baseAttrs.AtkSpeed += pAtkSpeedAmount;
        owner.baseAttrs.MoveSpeed += pMoveAmount;
        owner.ApplyBaseAttrs();

        Release();
    }
}
