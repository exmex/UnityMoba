using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600305901 : NTGBattlePassiveSkillBehaviour
{
    public float pAmount;
    public float pDuration;
    public override void Respawn()
    {
        base.Respawn();

        pAmount = this.param[0];
        owner.baseAttrs.MDef -= pAmount;
        owner.ApplyBaseAttrs();
        pDuration = 1;
        if (this.gameObject.activeInHierarchy)
        {
            StartCoroutine(doCount());
        }
        else
        {
            Release();
        }
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            owner.baseAttrs.MDef += pAmount;
            pAmount = p.param[0];
            owner.baseAttrs.MDef -= pAmount;
            pDuration = 1;
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MDef += pAmount;
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
        owner.baseAttrs.MDef += pAmount;
        owner.ApplyBaseAttrs();
        Release();
    }
}
