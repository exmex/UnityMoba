using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030430 : NTGBattlePassiveSkillController
{
    public override void Respawn()
    {
 	     base.Respawn();
         owner.AddPassive(pBehaviours[0].passiveName, owner, this);
    }
        


    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Respawn)
        {
            owner.AddPassive(pBehaviours[0].passiveName, owner, this);
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
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
