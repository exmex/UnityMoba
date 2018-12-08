using UnityEngine;
using System.Collections;

public class NTGBattleSkillBehaviourR50550020 : NTGBattleSkillSingleShootDirect
{
    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        pAdd += this.param[0]*(shooter as NTGBattleMobTowerController).targetHitCount;
        base.Shoot(lockedTarget, xOffset, zOffset);
    }
}