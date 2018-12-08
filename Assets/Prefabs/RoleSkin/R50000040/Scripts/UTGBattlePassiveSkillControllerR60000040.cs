using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60000040 : NTGBattlePassiveSkillController
{
    public override void Respawn()
    {
        owner.AddPassive(pBehaviours[0].passiveName, owner, this);
    }
}