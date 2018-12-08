using UnityEngine;
using System.Collections;

public class UTGBattleSkillControllerR50000124 : UTGBattleSkillControllerMultiStage
{
    public override void Shoot(NTGBattleUnitController targetUnit, float xOffset, float zOffset)
    {
        owner.SyncShoot(id, targetUnit == null ? "" : targetUnit.id, xOffset, zOffset);

        var specialAttack = false;
        foreach (NTGBattlePassiveSkillBehaviour passive in owner.passives)
        {
            if (passive.name == "PBehaviourR600001211")
            {
                specialAttack = true;
                break;
            }
        }

        owner.NotifyShoot(targetUnit, this);

        if (specialAttack)
        {
            StartCoroutine(doSpecialShoot(targetUnit, xOffset, zOffset));
        }
        else
        {
            StartCoroutine(doShoot(targetUnit, xOffset, zOffset));
        }

        StartCD();
    }

    private IEnumerator doSpecialShoot(NTGBattleUnitController targetUnit, float xOffset, float zOffset)
    {
        Vector3 targetPosition;
        if (xOffset == 0 && zOffset == 0 && targetUnit != null)
        {
            targetPosition = targetUnit.transform.position;
        }
        else
        {
            targetPosition = new Vector3(owner.transform.position.x + xOffset*range, owner.transform.position.y, owner.transform.position.z + zOffset*range);
        }

        yield return StartCoroutine(CancelPreviousSkill());

        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, true);
        if (type == NTGBattleSkillType.Attack)
        {
            owner.SetNavPriority(NTGBattleUnitController.NavPriority.Attack);
        }
        else if (type == NTGBattleSkillType.HostileSkill || type == NTGBattleSkillType.FriendlySkill)
        {
            owner.SetNavPriority(NTGBattleUnitController.NavPriority.Skill);
        }

        var d = cd/(1.0f + owner.atkSpeed)/behaviours[1].param[0]/3;

        for (int i = 0; i < 3; i++)
        {
            yield return StartCoroutine(ShootBehaviour(behaviours[1], targetUnit, targetPosition, xOffset == 0 && zOffset == 0 && targetUnit == null));
            if (interrupt)
            {
                break;
            }

            if (i < 2)
                yield return new WaitForSeconds(d);
        }

        owner.SetNavPriority(NTGBattleUnitController.NavPriority.Default);
        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, false);
    }

    private IEnumerator doShoot(NTGBattleUnitController targetUnit, float xOffset, float zOffset)
    {
        Vector3 targetPosition;
        if (xOffset == 0 && zOffset == 0 && targetUnit != null)
        {
            targetPosition = targetUnit.transform.position;
        }
        else
        {
            targetPosition = new Vector3(owner.transform.position.x + xOffset*range, owner.transform.position.y, owner.transform.position.z + zOffset*range);
        }

        yield return StartCoroutine(CancelPreviousSkill());

        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, true);
        if (type == NTGBattleSkillType.Attack)
        {
            owner.SetNavPriority(NTGBattleUnitController.NavPriority.Attack);
        }
        else if (type == NTGBattleSkillType.HostileSkill || type == NTGBattleSkillType.FriendlySkill)
        {
            owner.SetNavPriority(NTGBattleUnitController.NavPriority.Skill);
        }

        yield return StartCoroutine(ShootBehaviour(behaviours[0], targetUnit, targetPosition, xOffset == 0 && zOffset == 0 && targetUnit == null));

        owner.SetNavPriority(NTGBattleUnitController.NavPriority.Default);
        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, false);
    }
}