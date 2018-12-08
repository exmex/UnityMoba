using UnityEngine;
using System.Collections;

public class UTGBattleMobObjectController : NTGBattleMobController
{
    public override void Respawn()
    {
        base.Respawn();

        unitCollider.enabled = master;
    }

    public void OnTriggerEnter(Collider other)
    {
        var unit = other.GetComponent<NTGBattlePlayerController>();
        if (unit != null && (unit.hp < unit.hpMax || unit.mp < unit.mpMax))
        {
            skills[0].Shoot(unit);

            unitCollider.enabled = false;
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

    public override void Kill(NTGBattleUnitController killer)
    {
        if (alive)
        {
            base.Kill(killer);

            StartCoroutine(doDead());
        }
    }

    private IEnumerator doDead()
    {
        yield return null;
        viewController.Kill();

        mainController.ReleaseMob(this);
    }
}