using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600304201 : NTGBattlePassiveSkillBehaviour
{
    private float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        owner.baseAttrs.AtkSpeed -= this.param[0];
        pDuration = 1;

        owner.ApplyBaseAttrs();

        StartCoroutine(doDuration());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            if (p == this)
            {
                owner.baseAttrs.AtkSpeed += this.param[0];
                owner.baseAttrs.AtkSpeed -= p.param[0];
                pDuration = 1;

                owner.ApplyBaseAttrs();
            }
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.AtkSpeed += this.param[0];
            owner.ApplyBaseAttrs();
            pDuration = 0;
            Release();
        }
    }


    private IEnumerator doDuration()
    {
        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }
        owner.baseAttrs.AtkSpeed += this.param[0];
        owner.ApplyBaseAttrs();
        pDuration = 0;


        Release();

    }
}
