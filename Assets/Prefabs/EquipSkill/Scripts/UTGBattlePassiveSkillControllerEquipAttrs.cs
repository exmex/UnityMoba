using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerEquipAttrs : NTGBattlePassiveSkillController
{
    public override void Respawn()
    {
        foreach (var pBehav in pBehaviours)
        {
            owner.AddPassive(pBehav.passiveName, owner, this);
        }
    }

    public override void Release()
    {
        foreach (var pBehav in pBehaviours)
        {
            owner.RemovePassive(pBehav.passiveName, owner, this);
        }
    }
}