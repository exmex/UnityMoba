using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030120 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        FXEA();
        FXEB();

        pDuration = this.duration;

        owner.baseAttrs.AtkSpeed += this.param[0];

        owner.ApplyBaseAttrs();

        StartCoroutine(doEffect());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            
            var p = (NTGBattlePassiveSkillBehaviour)param;
            pDuration = p.duration;
            owner.baseAttrs.AtkSpeed -= this.param[0];
            owner.baseAttrs.AtkSpeed += p.param[0];
            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            owner.baseAttrs.AtkSpeed -= this.param[0];
            owner.ApplyBaseAttrs();
            Release();
        }
    }

    private IEnumerator doEffect()
    {
        while(pDuration > 0)
        {
            pDuration -= 0.1f;
            yield return new WaitForSeconds(0.1f);
        }


        owner.baseAttrs.AtkSpeed -= this.param[0];
        owner.ApplyBaseAttrs();
        Release();
    }
}
