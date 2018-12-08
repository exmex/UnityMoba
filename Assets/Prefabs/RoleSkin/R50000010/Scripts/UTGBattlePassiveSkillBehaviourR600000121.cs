using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600000121 : NTGBattlePassiveSkillBehaviour
{

    public float pDuration;
    public float pSpeedAmount;

    public override void Respawn()
    {
        base.Respawn();

  

        pDuration = this.duration;
        pSpeedAmount = -owner.baseAttrs.MoveSpeed * this.param[0];
        owner.baseAttrs.MoveSpeed += pSpeedAmount;
        owner.ApplyBaseAttrs();

        FXEA();
        FXEB();

        //skillFX.position = owner.unitUiAnchor.position;
        //skillFX.rotation = owner.unitUiAnchor.rotation;

        skillFX.position = owner.transform.position;
        skillFX.rotation = owner.transform.rotation;

        StartCoroutine(doBoost());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            shooter = p.shooter;
            pDuration = p.duration;

            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
            pSpeedAmount = -owner.baseAttrs.MoveSpeed * p.param[0];
            owner.baseAttrs.MoveSpeed += pSpeedAmount;
            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
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
        owner.baseAttrs.MoveSpeed -= pSpeedAmount;
        owner.ApplyBaseAttrs();

        Release();
    }

}
