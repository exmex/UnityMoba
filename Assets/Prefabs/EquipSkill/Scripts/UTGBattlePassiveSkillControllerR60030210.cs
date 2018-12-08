using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030210 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if(e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if (p.target != owner && !(p.target is NTGBattleMobTowerController) && p.behaviour.type == NTGBattleSkillType.Attack)
            {
                p.target.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }
}
