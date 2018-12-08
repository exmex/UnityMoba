using UnityEngine;
using System.Collections;

public class UTGBattleSkillControllerR50000054 : UTGBattleSkillControllerMultiStage
{
    public NTGBattleSkillBehaviour specialSkillBehaviour;

    public override void Shoot(NTGBattleUnitController targetUnit, float xOffset, float zOffset)
    {
        owner.SyncShoot(id, targetUnit == null ? "" : targetUnit.id, xOffset, zOffset);

        owner.NotifyShoot(targetUnit, this);

        var specialAttack = false;
        foreach (NTGBattlePassiveSkillBehaviour passive in owner.passives)
        {
            if (passive.name == "PBehaviourR60000051")
            {
                specialAttack = true;
                break;
            }
        }

        if (specialAttack)
        {
            owner.RemovePassive("PBehaviourR60000051");
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

        yield return StartCoroutine(ShootBehaviour(specialSkillBehaviour, targetUnit, targetPosition, xOffset == 0 && zOffset == 0 && targetUnit == null));

        owner.SetNavPriority(NTGBattleUnitController.NavPriority.Default);
        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, false);
    }
}