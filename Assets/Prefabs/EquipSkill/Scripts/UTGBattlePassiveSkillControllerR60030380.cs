using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030380 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.Kill || e == NTGBattlePassive.Event.Assist)
        {
            owner.AddPassive(pBehaviours[0].passiveName, owner, this);
        }
    }
}
