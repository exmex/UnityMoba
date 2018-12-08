using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000121 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour[] pBehaviours;

    public override void Shoot(NTGBattleUnitController target, float xOffset, float zOffset)
    {
        base.Shoot(target, xOffset, zOffset);

        owner.AddPassive(pBehaviours[0].passiveName, owner, skillController);
        owner.AddPassive(pBehaviours[1].passiveName, owner, skillController);

        Release();
    }
}