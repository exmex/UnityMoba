using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030190 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);
        
        if(e == NTGBattlePassive.Event.Kill)
        {
            var p = (NTGBattlePassive.EventKillParam)param;
            if (p.victim != owner && p.victim.group != owner.group)
            {
                owner.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }
        else if(e == NTGBattlePassive.Event.Assist)
        {
            var p = (NTGBattlePassive.EventAssistParam)param;
            if (p.victim != owner && p.victim.group != owner.group)
            {
                owner.AddPassive(pBehaviours[0].passiveName, owner, this);
            }
        }

    }

    public override void Release()
    {
        base.Release();

        owner.RemovePassive(pBehaviours[0].passiveName);
    }
}
