using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030400 : NTGBattlePassiveSkillBehaviour
{
    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if (f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;

            if (p.target == owner && p.behaviour.effectType == EffectType.HpRecover)
            {
                value = value * (1 + this.param[0]);
            }
        }
        return value;
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            Release();
        }
    }
}
