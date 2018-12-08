using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030340 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pAtkSpeed;

    public override void Respawn()
    {
        base.Respawn();

        pAtkSpeed = this.param[0];
        pDuration = this.duration;

        owner.baseAttrs.AtkSpeed -= pAtkSpeed;
        owner.ApplyBaseAttrs();

        StartCoroutine(doContinue());

    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            if(p == this)
            {
                owner.baseAttrs.AtkSpeed += pAtkSpeed;
                pAtkSpeed = p.param[0];
                owner.baseAttrs.AtkSpeed -= pAtkSpeed;
                pDuration = p.duration;
                owner.ApplyBaseAttrs();
            }
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.AtkSpeed += pAtkSpeed;
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

        owner.baseAttrs.AtkSpeed += pAtkSpeed;
        owner.ApplyBaseAttrs();

        Release();
    }
}
