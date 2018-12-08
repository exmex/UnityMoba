using UnityEngine;
using System.Collections;

public class UTGBattleSkillPassvieBehaviourR600400102 : NTGBattlePassiveSkillBehaviour
{
    public override void Respawn()
    {
        base.Respawn();

        StartCoroutine(doRecover());

        shooter.AddPassive("Kill", owner);
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam) param;
            if (p.target == owner && (p.behaviour.type == NTGBattleSkillType.Attack || p.behaviour.type == NTGBattleSkillType.HostileSkill))
            {
                Release();
            }
        }
    }

    private IEnumerator doRecover()
    {
        FXEB();

        var d = duration;
        while (d > 0)
        {
            baseValue = this.param[0];
            effectType = EffectType.MpRecover;
            owner.Hit(shooter, this);

            yield return new WaitForSeconds(this.param[1]);
            d -= this.param[1];
        }

        Release();
    }
}