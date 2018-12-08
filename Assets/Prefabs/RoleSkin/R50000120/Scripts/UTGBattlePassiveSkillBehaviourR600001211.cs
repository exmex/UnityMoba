using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600001211 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public int pCount;

    public override void Respawn()
    {
        base.Respawn();

        pCount = (int) this.param[0];
        pDuration = duration;

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
            pCount = (int) p.param[0];
            pDuration = p.duration;
        }
        else if (e == NTGBattlePassive.Event.Shoot)
        {
            var p = (NTGBattlePassive.EventShootParam) param;
            if (p.shooter == owner && p.controller.type == NTGBattleSkillType.Attack)
            {
                pCount--;
                if (pCount == 0)
                {
                    Release();
                }
            }
        }
        else if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam) param;
            if (p.shooter == owner && p.behaviour.type == NTGBattleSkillType.Attack)
            {
                p.target.Hit(owner, this);
            }
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            Release();
        }
    }

    private IEnumerator doBoost()
    {
        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }

        Release();
    }
}