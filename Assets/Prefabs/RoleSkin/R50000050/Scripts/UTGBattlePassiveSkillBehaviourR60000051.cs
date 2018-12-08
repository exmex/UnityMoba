using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000051 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;

    public override void Respawn()
    {
        base.Respawn();

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
            pDuration = this.duration;
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