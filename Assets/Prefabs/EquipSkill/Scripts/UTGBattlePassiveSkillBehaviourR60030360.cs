using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030360 : NTGBattlePassiveSkillBehaviour
{
    public float pDamage;

    public float pValue;

    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if (f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if(p.shooter != owner && 
                (p.behaviour.type == NTGBattleSkillType.Attack || ((p.behaviour.type == NTGBattleSkillType.HostileSkill) && p.behaviour.effectType == NTGBattleSkillBehaviour.EffectType.PhysicDamage))
                && p.shooter.alive && !(p.shooter is NTGBattleMobTowerController))
            {
                pDamage = (p.behaviour.baseValue + p.behaviour.pAdd * p.shooter.pAtk) * pValue;
                ShootBase(p.shooter);
                baseValue = pDamage;
                effectType = EffectType.MagicDamage;
                p.shooter.Hit(owner, this);
                FXHit(p.shooter);
            }
        }
        return value;
    }

    public override void Respawn()
    {
        base.Respawn();

        pValue = this.param[0];
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if(e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            pValue = p.param[0];
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            Release();
        }
    }
}

