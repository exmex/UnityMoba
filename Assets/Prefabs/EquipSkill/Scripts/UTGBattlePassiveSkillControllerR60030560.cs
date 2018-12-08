using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030560 : NTGBattlePassiveSkillController
{
    public bool havePassive = false;
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if(e == NTGBattlePassive.Event.Shoot)
        {
            var p = (NTGBattlePassive.EventShootParam)param;
            if (p.shooter == owner && p.controller.type != NTGBattleSkillType.Attack && p.controller.type != NTGBattleSkillType.PlayerSkill)
            {
                havePassive = true;
            }
        }
        else if(e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if(p.shooter == owner && p.behaviour.type == NTGBattleSkillType.Attack && havePassive)
            {
                havePassive = false;
                p.target.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }
}
