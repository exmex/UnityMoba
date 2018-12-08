using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60100080 : NTGBattlePassiveSkillController
{
    public int skillCount;

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Shoot)
        {
            var p = (NTGBattlePassive.EventShootParam) param;
            if (p.shooter == owner && (p.controller.type == NTGBattleSkillType.HostileSkill || p.controller.type == NTGBattleSkillType.FriendlySkill))
            {
                if (skillCount == (int) this.param[0])
                {
                    skillCount = 0;

                    owner.RemovePassive(pBehaviours[0].passiveName);
                }
                else
                {
                    skillCount++;

                    if (skillCount == (int) this.param[0])
                    {
                        owner.AddPassive(pBehaviours[0].passiveName, owner, this, new[] {this.param[1]});
                    }
                }
            }
        }
        else if (e == NTGBattlePassive.Event.Death)
        {
            skillCount = 0;

            owner.RemovePassive(pBehaviours[0].passiveName);
        }
    }
}