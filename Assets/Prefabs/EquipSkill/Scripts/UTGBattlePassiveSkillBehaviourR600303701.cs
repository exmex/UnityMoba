using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600303701 : NTGBattlePassiveSkillBehaviour
{
    public float pAddPatkAmount;
    public float pShiledBase;
    public float pShiledAddAmount;
    public float pDuration;
    public float pShiled;


    public override void Respawn()
    {
        base.Respawn();
        pAddPatkAmount = this.param[0];
        pShiledBase = this.param[1];
        pShiledAddAmount = this.param[2];
        pDuration = this.duration;

        owner.baseAttrs.PAtk += pAddPatkAmount;
        pShiled = owner.level * pShiledAddAmount + pShiledBase;
        owner.shield += pShiled;
        owner.ApplyBaseAttrs();

        FXEA();
        FXEB();

        StartCoroutine(doCount());
    }

    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if (f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if (p.target == owner && (p.behaviour.type == NTGBattleSkillType.Attack || p.behaviour.type == NTGBattleSkillType.HostileSkill || p.behaviour.type == NTGBattleSkillType.HostilePassive))
            {
                if (value < pShiled)
                {
                    owner.shield -= pShiled;
                    pShiled -= value;
                    owner.shield += pShiled;

                    return 0;
                }
                else
                {
                    owner.shield -= pShiled;
                    pShiled = 0;
                    owner.shield += pShiled;

                    FXExplode();

                    return value - pShiled;
                }
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

            owner.shield -= pShiled;
            if (p == this)
            {
                return;
            }
            else
            {
                pShiled = baseValue + pAdd * shooter.pAtk + mAdd * shooter.mAtk + hpAdd * shooter.hpMax + mpAdd * shooter.mpMax;
            }
            owner.shield += pShiled;
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            if (owner.shield >= pShiled)
            {
                owner.shield -= pShiled;
            }
            else
            {
                owner.shield = 0;
            }
            owner.baseAttrs.PAtk -= pAddPatkAmount;
            owner.ApplyBaseAttrs();
            Release();
        }
    }


    private IEnumerator doCount()
    {
        while(pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }

        owner.baseAttrs.PAtk -= pAddPatkAmount;
        owner.shield -= pShiled;
        owner.ApplyBaseAttrs();

        Release();
    }
}
