using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030570 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);
        if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if (p.target.group != owner.group && p.behaviour.type == NTGBattleSkillType.Attack && p.target.alive)
            {
                p.target.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }
}
