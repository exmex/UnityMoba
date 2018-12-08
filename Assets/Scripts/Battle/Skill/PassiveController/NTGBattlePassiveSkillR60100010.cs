using UnityEngine;
using System.Collections;

public class NTGBattlePassiveSkillR60100010 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Respawn)
        {
            StartCoroutine(doShoot());
        }
    }

    public override void Respawn()
    {
    }

    private IEnumerator doShoot()
    {
        while (owner.alive)
        {
            if (inCd <= 0)
            {
                var target = owner.FindTarget(range, condition: NTGBattleUnitController.TargetCondition.Random);
                if (target != null)
                {
                    Shoot(target);
                }
            }

            yield return new WaitForSeconds(0.1f);
        }
    }
}