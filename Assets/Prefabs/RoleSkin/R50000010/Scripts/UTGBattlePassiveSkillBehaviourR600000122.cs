using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600000122 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pShieldAmount;
    public float pSpeedAmount;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = this.duration;
        //护盾
        pShieldAmount = baseValue + pAdd * shooter.pAtk + mAdd * shooter.mAtk + hpAdd * shooter.hpMax + mpAdd * shooter.mpMax;
        owner.shield += pShieldAmount;
        //加速
        pSpeedAmount = owner.baseAttrs.MoveSpeed * param[0];
        owner.baseAttrs.MoveSpeed += pSpeedAmount;
        owner.ApplyBaseAttrs();

        FXEA();
        FXEB();

        StartCoroutine(doBoost());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            shooter = p.shooter;
            pDuration = this.duration;
            //护盾
            owner.shield -= pShieldAmount;
            pShieldAmount = baseValue + pAdd * shooter.pAtk + mAdd * shooter.mAtk + hpAdd * shooter.hpMax + mpAdd * shooter.mpMax;
            owner.shield += pShieldAmount;
            //加速
            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
            pSpeedAmount = -owner.baseAttrs.MoveSpeed * p.param[0];
            owner.baseAttrs.MoveSpeed += pSpeedAmount;
            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {   //护盾
            owner.shield -= pShieldAmount;
            //加速
            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
            owner.ApplyBaseAttrs();

            Release();
        }
    }

    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if (f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if (p.target == owner && (p.behaviour.type == NTGBattleSkillType.Attack || p.behaviour.type == NTGBattleSkillType.HostileSkill || p.behaviour.type == NTGBattleSkillType.HostilePassive))
            {
                if (value < pShieldAmount)
                {
                    owner.shield -= pShieldAmount;
                    pShieldAmount -= value;
                    owner.shield += pShieldAmount;

                    return 0;
                }
                else
                {
                    owner.shield -= pShieldAmount;
                    pShieldAmount = 0;
                    owner.shield += pShieldAmount;

                    return value - pShieldAmount;
                }
            }
        }

        return value;
    }

    private IEnumerator doBoost()
    {
        while (pDuration > 0 && pShieldAmount > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }
        //护盾
        owner.shield -= pShieldAmount;
        //加速
        owner.baseAttrs.MoveSpeed -= pSpeedAmount;
        owner.ApplyBaseAttrs();

        Release();
    }


}
