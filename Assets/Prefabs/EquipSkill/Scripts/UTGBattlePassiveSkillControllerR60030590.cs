using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030590 : NTGBattlePassiveSkillController
{
    public override void Respawn()
    {
 	     base.Respawn();
         owner.AddPassive(pBehaviours[0].passiveName, owner, this);
    }
        


    public override void Release()
    {
        base.Release();

        owner.RemovePassive(pBehaviours[0].passiveName);
    }

}
