using UnityEngine;
using System.Collections;

public class NTGBattlePassiveSkillR60100001 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Respawn)
        {
            //AddPassive(owner);
        }
        else if (e == NTGBattlePassive.Event.Disengage)
        {
            StartCoroutine(doCountDown());
        }
        else if (e == NTGBattlePassive.Event.Engage)
        {
            StopCoroutine(doCountDown());
        }
    }

    private IEnumerator doCountDown()
    {
        yield return new WaitForSeconds(8.0f);
        //AddPassive(owner);
    }

    public override void Respawn()
    {
    }
}