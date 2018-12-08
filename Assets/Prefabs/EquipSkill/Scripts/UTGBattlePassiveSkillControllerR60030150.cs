using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030150 : NTGBattlePassiveSkillController
{
    //public override void Respawn()
    //{
    //    base.Respawn();

    //    foreach(NTGBattlePassiveSkillBehaviour p in owner.passives)
    //    {
    //        if (p.passiveName == pBehaviours[2].passiveName)
    //        {
    //            return;
    //        }
    //    }

    //    owner.AddPassive(pBehaviours[2].passiveName, owner, this);
    //}

    public override void Respawn()
    {
 	    base.Respawn();
        owner.AddPassive(pBehaviours[2].passiveName, owner, this);
    }
    

    public override void Release()
    {
        base.Release();

        owner.RemovePassive(pBehaviours[0].passiveName);

        owner.RemovePassive(pBehaviours[2].passiveName);

    }
}
