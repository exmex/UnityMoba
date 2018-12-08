using UnityEngine;
using System.Collections;

public class UTGBattleSkillControllerR60000031 : NTGBattleSkillController
{
    public override bool ShootCheck(NTGBattleUnitController targetUnit, float xOffset = 0, float zOffset = 0)
    {
        return true;
    }

    public override void Shoot(NTGBattleUnitController targetUnit, float xOffset = 0, float zOffset = 0)
    {
        owner.SyncShoot(id, targetUnit == null ? "" : targetUnit.id, xOffset, zOffset);

        owner.NotifyShoot(targetUnit, this);

        owner.AddPassive(pBehaviours[0].passiveName, owner, this);

        StartCD();
    }
}