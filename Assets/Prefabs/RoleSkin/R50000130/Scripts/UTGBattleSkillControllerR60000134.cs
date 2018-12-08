using UnityEngine;
using System.Collections;

public class UTGBattleSkillControllerR60000134 : UTGBattleSkillControllerMultiStage {

    public NTGBattleSkillBehaviour specialSkillBehaviour;
    public UTGBattlePassiveSkillBehaviourR60000130 sbForCount = null;
    public UTGBattlePassiveSkillControllerR60000130 psc;

    public override bool ShootCheck(NTGBattleUnitController targetUnit, float xOffset, float zOffset)
    {
        var specialAttack = false;
        if (sbForCount.count == sbForCount.param[0]+1)
        {
            specialAttack = true;
        }

        if (specialAttack)
        {
            return specialSkillBehaviour.ShootCheck(targetUnit, xOffset, zOffset);
        }

        return behaviours[stageIndex].ShootCheck(targetUnit, xOffset, zOffset);
    }

    public override void Shoot(NTGBattleUnitController targetUnit, float xOffset, float zOffset)
    {
        owner.SyncShoot(id, targetUnit == null ? "" : targetUnit.id, xOffset, zOffset);

        owner.NotifyShoot(targetUnit, this);

        var specialAttack = false;
        if (sbForCount.count == sbForCount.param[0]+1)
        {
            specialAttack = true;
        }

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
            targetPosition = new Vector3(owner.transform.position.x + xOffset * range, owner.transform.position.y, owner.transform.position.z + zOffset * range);
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

        owner.AddPassive((specialSkillBehaviour as NTGBattlePassiveSkillBehaviour).passiveName, owner, psc);
        yield return StartCoroutine(ShootBehaviour(specialSkillBehaviour, targetUnit, targetPosition, xOffset == 0 && zOffset == 0 && targetUnit == null));

        owner.SetNavPriority(NTGBattleUnitController.NavPriority.Default);
        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, false);
    }
}
