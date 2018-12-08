using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030580 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public override void Respawn()
    {
        base.Respawn();
        FXEA();
        FXEB();
        pDuration = this.duration;
        StartCoroutine(doCount());
    }
    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if (f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if (p.behaviour.effectType == EffectType.HpRecover)
            {
                return value * (1 - this.param[0]);
            }
        }
        return value;
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if(e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            pDuration = p.duration;
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            pDuration = 0;
            Release();
        }
    }

    private IEnumerator doCount()
    {
        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }
        Release();
    }


}
