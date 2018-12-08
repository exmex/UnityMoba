using System;
using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000033 : NTGBattleSkillSingleShootDirect
{
    public NTGBattlePassiveSkillBehaviour pBehaviour;

    public override void PostHitTarget(NTGBattleUnitController target)
    {
        target.AddPassive(pBehaviour.passiveName, owner, skillController);
    }
}