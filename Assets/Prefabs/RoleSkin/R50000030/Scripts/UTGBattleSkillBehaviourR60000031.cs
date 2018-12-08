using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000031 : NTGBattleSkillSingleShootDirect
{
    public override bool ShootCheck(NTGBattleUnitController target, float xOffset, float zOffset)
    {
        return target != null;
    }
}