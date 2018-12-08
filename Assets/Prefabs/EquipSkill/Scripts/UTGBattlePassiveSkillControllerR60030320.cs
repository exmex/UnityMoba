using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030320 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;

            if (p.shooter != owner && (p.behaviour.type == NTGBattleSkillType.Attack || p.behaviour.type == NTGBattleSkillType.HostilePassive
                    || p.behaviour.type == NTGBattleSkillType.HostileSkill) && inCd <= 0)
            {
                owner.AddPassive(pBehaviours[0].passiveName, owner, this);

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
