using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600302002 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pShieldAmount;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = duration;

        pShieldAmount = param[0] + owner.level * param[1] + owner.baseAttrs.MAtk * param[2] ;
        owner.shield += pShieldAmount;

        FXEA();
        FXEB();

        StartCoroutine(doBoost());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if(e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;

            shooter = p.shooter;
            pDuration = p.duration;
            owner.shield -= pShieldAmount;
            if (p == this)
            {
                pShieldAmount = p.param[0] + shooter.level * p.param[1] + shooter.baseAttrs.MAtk * p.param[2];
            }
            else
            {
                pShieldAmount = baseValue + pAdd * shooter.pAtk + mAdd * shooter.mAtk + hpAdd * shooter.hpMax + mpAdd * shooter.mpMax;
            }
            owner.shield += pShieldAmount;
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            if (owner.shield >= pShieldAmount)
            {
                owner.shield -= pShieldAmount;
            }
            else
            {
                owner.shield = 0;
            }
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

                    FXExplode();

                    return value - pShieldAmount;
                }
            }
        }

        return value;        
    }

    private IEnumerator doBoost()
    {
        while(pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }

        owner.shield -= pShieldAmount;

        Release();
    }
}
