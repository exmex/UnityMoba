using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030470 : NTGBattlePassiveSkillBehaviour
{
    public float pDamage;
    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if(f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if(p.target == owner && p.behaviour.type == NTGBattleSkillType.Attack)
            {
                //Debug.Log(value);
                pDamage = value * (1 - this.param[0]);
                //Debug.Log(pDamage + " " + this.param[0] + " " + value);
                return pDamage;
            }
        }
        return value;
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            Release();
        }
    }

}
