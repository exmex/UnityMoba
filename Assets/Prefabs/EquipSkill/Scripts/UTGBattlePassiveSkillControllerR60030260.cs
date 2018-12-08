using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030260 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;

            if (p.target != owner && p.shooter == owner && (p.behaviour.type == NTGBattleSkillType.HostilePassive || 
                p.behaviour.type == NTGBattleSkillType.HostileSkill) && !(p.target is NTGBattleMobTowerController) && p.target.alive)
            {
                p.target.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }
}
