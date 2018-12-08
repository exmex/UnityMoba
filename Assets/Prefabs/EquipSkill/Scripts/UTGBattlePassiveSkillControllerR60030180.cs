using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030180 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.LevelUp)
        {
            owner.AddPassive(pBehaviours[0].passiveName, owner, this);
            owner.AddPassive(pBehaviours[1].passiveName, owner, this);
        }
    }
}
