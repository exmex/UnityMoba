using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030500 : NTGBattlePassiveSkillController
{

    public override void Respawn()
    {
 	     base.Respawn();
         if (!owner.isEngage)
         {
             owner.AddPassive(pBehaviours[0].passiveName, owner, this);
         }
    }


    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if(e == NTGBattlePassive.Event.Disengage)
        {
            owner.AddPassive(pBehaviours[0].passiveName, owner, this);
        }
        else if (e == NTGBattlePassive.Event.Engage)
        {
            owner.RemovePassive(pBehaviours[0].passiveName);
        }
    }

    public override void Release()
    {
        base.Release();

        owner.RemovePassive(pBehaviours[0].passiveName);
    }
}
