using UnityEngine;
using System.Collections;

public class UTGBattleSkillPassvieBehaviourR60120010 : NTGBattlePassiveSkillBehaviour
{
    public override void Respawn()
    {
        base.Respawn();

        FXEA();
        FXEB();

        baseValue = this.param[0]*owner.hpMax;
        effectType = EffectType.HpRecover;
        owner.Hit(shooter, this);

        Release();
    }

    //public override void Notify(NTGBattlePassive.Event e, object param)
    //{
    //    if (e == NTGBattlePassive.Event.Hit)
    //    {
    //        var p = (NTGBattlePassive.EventHitParam) param;
    //        if (p.target == owner && (p.behaviour.type == NTGBattleSkillType.Attack || p.behaviour.type == NTGBattleSkillType.HostileSkill))
    //        {
    //            Release();
    //        }
    //    }
    //}
}