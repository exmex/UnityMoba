using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60120140 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Death)
        {
            var p = (NTGBattlePassive.EventDeathParam) param;

            if (p.killer is NTGBattlePlayerController)
                p.killer.AddPassive(pBehaviours[0].passiveName, owner, this);
        }
    }
}