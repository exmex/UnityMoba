using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030370 : NTGBattlePassiveSkillController
{

    public override void Respawn()
    {
 	     base.Respawn();
         if (owner.hp / owner.hpMax < pBehaviours[0].param[0])
         {
             owner.AddPassive(pBehaviours[0].passiveName, owner, this);
         }
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if(e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;

            if (p.target == owner && p.shooter != owner && this.inCd <= 0)
            {
                owner.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }
}
