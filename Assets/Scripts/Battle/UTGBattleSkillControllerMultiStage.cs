using UnityEngine;
using System.Collections;

public class UTGBattleSkillControllerMultiStage : NTGBattleSkillController
{
    public int stageIndex;

    public override bool ShootCheck(NTGBattleUnitController targetUnit, float xOffset, float zOffset)
    {
        if (behaviours.Length > 0)
        {
            return behaviours[stageIndex].ShootCheck(targetUnit, xOffset, zOffset);
        }

        return true;
    }

    protected override IEnumerator doShoot(NTGBattleUnitController targetUnit, float xOffset, float zOffset)
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

        yield return StartCoroutine(ShootBehaviour(behaviours[stageIndex], targetUnit, targetPosition, xOffset == 0 && zOffset == 0 && targetUnit == null));

        stageIndex++;
        if (stageIndex == behaviours.Length)
            stageIndex = 0;

        owner.SetNavPriority(NTGBattleUnitController.NavPriority.Default);
        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, false);
        owner.interruptSource = NTGBattleUnitController.ShootInterruptSource.None;
    }
}