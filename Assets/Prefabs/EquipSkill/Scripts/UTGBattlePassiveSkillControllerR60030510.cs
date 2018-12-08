using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030510 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if(e == NTGBattlePassive.Event.Shoot)
        {
            var p = (NTGBattlePassive.EventShootParam)param;
            if(p.target != null && p.target.group == 3 && p.shooter == owner)
            {
                p.target.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }

    public override void Release()
    {
        base.Release();

        owner.RemovePassive(pBehaviours[0].passiveName);
    }
    
}
