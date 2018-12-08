using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60100090 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam) param;
            if (p.shooter == owner && p.behaviour.skillController.type == NTGBattleSkillType.HostileSkill)
            {
                p.target.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }
}