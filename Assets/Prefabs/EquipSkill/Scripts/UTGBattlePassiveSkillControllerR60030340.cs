using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030340 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if(e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if(p.target == owner && p.shooter.group != owner.group && p.shooter.alive)
            {
                p.shooter.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }
}
