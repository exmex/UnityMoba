using UnityEngine;
using System.Collections;

public class UTGBattleSkillControllerR60000051 : NTGBattleSkillController
{
    public override bool OverideShootable()
    {
        if (owner.Shootable == false && owner.alive && owner.ShootableCount == 0)
        {
            return true;
        }

        return false;
    }

    public override bool ShootCheck(NTGBattleUnitController targetUnit, float xOffset = 0, float zOffset = 0)
    {
        return true;
    }

    public override void Shoot(NTGBattleUnitController targetUnit, float xOffset = 0, float zOffset = 0)
    {
        owner.SyncShoot(id, targetUnit == null ? "" : targetUnit.id, xOffset, zOffset);

        owner.NotifyShoot(targetUnit, this);


        foreach (NTGBattlePassiveSkillBehaviour passive in owner.passives)
        {
            if (passive.name == "Stun")
            {
                passive.Notify(NTGBattlePassive.Event.PassiveRemove, null);
                break;
            }
        }

        owner.AddPassive(pBehaviours[0].passiveName, owner, this);

        owner.AddPassive(pBehaviours[1].passiveName, owner, this);

        owner.AddPassive("Fast", owner, this, new[] {this.param[0], this.param[1]});

        StartCD();
    }
}