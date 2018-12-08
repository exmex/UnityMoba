using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030240 : NTGBattlePassiveSkillController
{
    public ArrayList targets;

    public bool alreadyChooseTarget = false;

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if (p.target != owner && (p.behaviour.type == NTGBattleSkillType.HostilePassive || p.behaviour.type == NTGBattleSkillType.HostileSkill)
                && (p.target.mask & p.behaviour.mask) != 0 && inCd <= 0)
            {
                p.target.AddPassive(pBehaviours[0].passiveName, owner, this);
                StartCD();
            }
        }
    }

    public override void Release()
    {
        base.Release();

        owner.RemovePassive(pBehaviours[0].passiveName);
    }
}
