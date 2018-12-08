using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60100050 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Kill)
        {
            owner.AddPassive(pBehaviours[0].passiveName, owner, this);
        }
        else if (e == NTGBattlePassive.Event.Assist)
        {
            owner.AddPassive(pBehaviours[0].passiveName, owner, this);
        }
    }
}