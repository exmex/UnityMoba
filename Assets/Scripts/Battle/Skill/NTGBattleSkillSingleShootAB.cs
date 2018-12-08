using System;
using UnityEngine;
using System.Collections;

public class NTGBattleSkillSingleShootAB : NTGBattleSkillSingleShoot
{
    public Transform allyFX;
    public Transform enemyFX;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        if (owner.group == owner.mainController.uiController.localPlayerController.group)
        {
            allyFX.gameObject.SetActive(true);
            enemyFX.gameObject.SetActive(false);

            skillFX = allyFX;
        }
        else
        {
            allyFX.gameObject.SetActive(false);
            enemyFX.gameObject.SetActive(true);

            skillFX = enemyFX;
        }

        if (skillFX != null)
        {
            ea = skillFX.Find("EA");
            eb = skillFX.Find("EB");
            ec = skillFX.Find("EC");
            ed = skillFX.Find("ED");
        }

        FXReset();

        base.Shoot(lockedTarget, xOffset, zOffset);
    }
}