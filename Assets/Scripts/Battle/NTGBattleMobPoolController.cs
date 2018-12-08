using UnityEngine;
using System.Collections;

public class NTGBattleMobPoolController : NTGBattleMobController
{
    public void OnTriggerEnter(Collider other)
    {
        var unit = other.GetComponent<NTGBattleUnitController>();
        if (unit != null)
        {
            if (unit.group == group)
            {
                unit.AddPassive("PoolRecover", this);
            }
        }
    }

    public void OnTriggerExit(Collider other)
    {
        var unit = other.GetComponent<NTGBattleUnitController>();
        if (unit != null)
        {
            if (unit.group == group)
            {
                unit.RemovePassive("PoolRecover");
            }
        }
    }

    public void OnTriggerStay(Collider other)
    {
        var unit = other.GetComponent<NTGBattleUnitController>();
        if (unit != null)
        {
            if (unit.alive && unit.group != group && skills[0].inCd <= 0)
            {
                skills[0].Shoot(unit);
            }
        }
    }

    public override void SkillShoot(int skillId, string targetId, float xOffset, float zOffset)
    {
        foreach (var skill in skills)
        {
            if (skill.id == skillId)
            {
                var targetUnit = mainController.FindUnit(targetId);

                if (mp >= skill.mpCost)
                {
                    mp -= skill.mpCost;

                    skill.Shoot(targetUnit);
                }
            }
        }
    }
}