using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030070 : NTGBattlePassiveSkillBehaviour
{

    public float pMoveAmount;

    public float pDuration;

    private int atkType;

    public override void Respawn()
    {
        base.Respawn();

        pMoveAmount = owner.baseAttrs.MoveSpeed * this.param[0];

        pDuration = 0;

        owner.baseAttrs.MoveSpeed += pMoveAmount;

        owner.ApplyBaseAttrs();

        if ((owner as NTGBattlePlayerController).atkType == 1)
        {
            pDuration = this.param[1];

            atkType = 1;
        }
        else
        {
            pDuration = this.param[2];

            atkType = 2;
        }

        skillController.StartCD();

        StartCoroutine(doEffect());

    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            owner.baseAttrs.MoveSpeed -= pMoveAmount;
            if (atkType == 1)
            {
                pMoveAmount = p.param[1];
            }
            else
            {
                pMoveAmount = p.param[2];
            }
            owner.baseAttrs.MoveSpeed += pMoveAmount;
            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed -= pMoveAmount;
            owner.ApplyBaseAttrs();
            Release();
        }
    }

    private IEnumerator doEffect()
    {
        FXEA();
        FXEB();

        while (pDuration > 0 && owner.alive)
        {
            pDuration -= 0.1f;
            yield return new WaitForSeconds(0.1f);
        }

        owner.baseAttrs.MoveSpeed -= pMoveAmount;
        owner.ApplyBaseAttrs();

        Release();
    }


}
