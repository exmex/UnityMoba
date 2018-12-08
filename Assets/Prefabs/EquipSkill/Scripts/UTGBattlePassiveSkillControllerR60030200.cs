using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030200 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;

            if(p.shooter != owner && p.target == owner)
            {
                owner.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
    }
}
