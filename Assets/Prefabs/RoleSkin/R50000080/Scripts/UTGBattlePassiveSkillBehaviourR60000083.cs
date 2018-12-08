using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000083 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;

    public override void Respawn()
    {
        owner.baseAttrs.Hp += shooter.mAtk*this.param[0];
        owner.baseAttrs.PAtk += shooter.mAtk*this.param[1];
        owner.baseAttrs.MAtk += shooter.mAtk*this.param[2];
        owner.ApplyBaseAttrs();

        pDuration = this.param[3];

        var unit = owner as NTGBattleMobR61120030;
        if (unit != null)
        {
            unit.summoner = shooter as NTGBattlePlayerController;
        }

        StartCoroutine(doAlive());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            Release();
        }
    }

    private IEnumerator doAlive()
    {
        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
            if (shooter == null || !shooter.alive)
                break;
        }

        owner.AddPassive("Kill", owner);

        Release();
    }
}