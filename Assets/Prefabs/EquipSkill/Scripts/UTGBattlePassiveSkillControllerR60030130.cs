using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030130 : NTGBattlePassiveSkillController
{

    public float pPercent;

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if(e == NTGBattlePassive.Event.Shoot)
        {
            var p = (NTGBattlePassive.EventShootParam)param;
            if(p.target != null && p.target != owner && p.shooter == owner && p.target.alive)
            {
                p.target.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }
}
