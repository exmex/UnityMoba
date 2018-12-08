using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030360 : NTGBattlePassiveSkillController
{

    public override void Respawn()
    {
        base.Respawn();
        owner.AddPassive(pBehaviours[0].passiveName, owner, this);
    }

    //public override void Notify(NTGBattlePassive.Event e, object param)
    //{
    //    base.Notify(e, param);

    //    if(e == NTGBattlePassive.Event.Hit)
    //    {
    //        var p = (NTGBattlePassive.EventHitParam)param;
    //        if (p.shooter != owner && 
    //            (p.behaviour.type == NTGBattleSkillType.Attack || ((p.behaviour.type == NTGBattleSkillType.HostileSkill || p.behaviour.type == NTGBattleSkillType.HostilePassive) && p.behaviour.effectType == NTGBattleSkillBehaviour.EffectType.PhysicDamage))
    //            && p.shooter.alive && !(p.shooter is NTGBattleMobTowerController))
    //        {
    //            p.shooter.AddPassive(pBehaviours[0].passiveName, owner, this);
    //        }
    //    }
    //}

    public override void Release()
    {
        base.Release();

        owner.RemovePassive(pBehaviours[0].passiveName);
    }
}
