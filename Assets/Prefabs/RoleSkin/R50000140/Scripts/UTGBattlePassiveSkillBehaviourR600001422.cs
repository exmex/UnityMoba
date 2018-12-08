using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600001422 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pShieldAmount;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = this.duration;

        pShieldAmount = baseValue + pAdd*shooter.pAtk + mAdd*shooter.mAtk + hpAdd*shooter.hpMax + mpAdd*shooter.mpMax;
        owner.shield += pShieldAmount;

        FXEA();
        FXEB();

        StartCoroutine(doBoost());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour) param;
            shooter = p.shooter;
            pDuration = this.duration;

            owner.shield -= pShieldAmount;
            pShieldAmount = baseValue + pAdd*shooter.pAtk + mAdd*shooter.mAtk + hpAdd*shooter.hpMax + mpAdd*shooter.mpMax;
            owner.shield += pShieldAmount;
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.shield -= pShieldAmount;

            Release();
        }
    }

    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if (f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam) param;
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

        owner.shield -= pShieldAmount;

        Release();
    }
}