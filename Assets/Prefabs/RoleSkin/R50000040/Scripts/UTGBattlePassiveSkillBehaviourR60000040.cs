using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000040 : NTGBattlePassiveSkillBehaviour
{
    public override void Respawn()
    {
        base.Respawn();

        FXEA();
        FXEB();
    }

    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if (f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam) param;
            if (p.target == owner && (p.behaviour.type == NTGBattleSkillType.Attack || p.behaviour.type == NTGBattleSkillType.HostileSkill || p.behaviour.type == NTGBattleSkillType.HostilePassive) && p.behaviour.effectType != EffectType.RealDamage)
            {
                return value*(1.0f - (1.0f - owner.hp/owner.hpMax)/0.03f*0.01f);
            }
        }

        return value;
    }
}