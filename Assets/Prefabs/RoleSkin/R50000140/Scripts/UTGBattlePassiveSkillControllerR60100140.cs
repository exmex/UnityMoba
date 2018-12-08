using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60100140 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Shoot)
        {
            var p = (NTGBattlePassive.EventShootParam) param;
            if (p.shooter == owner && (p.controller.type == NTGBattleSkillType.HostileSkill || p.controller.type == NTGBattleSkillType.FriendlySkill))
            {
                owner.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }
}