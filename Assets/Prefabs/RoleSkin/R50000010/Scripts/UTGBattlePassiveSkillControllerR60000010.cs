using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class UTGBattlePassiveSkillControllerR60000010 : NTGBattlePassiveSkillController
{
    public override void Respawn()
    {
        base.Respawn();
        owner.AddPassive(pBehaviours[0].passiveName, owner,this);
    }
}
