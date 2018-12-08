using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030010 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Shoot)
        {
            var p = (NTGBattlePassive.EventShootParam) param;
            if (p.shooter == owner && p.controller.type == NTGBattleSkillType.Attack)
            {
                owner.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }

    public override void Release()
    {
        owner.RemovePassive(pBehaviours[0].passiveName);
    }
}