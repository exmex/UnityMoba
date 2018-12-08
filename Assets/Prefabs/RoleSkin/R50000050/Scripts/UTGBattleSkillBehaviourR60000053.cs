using System;
using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000053 : NTGBattleSkillSingleShootDirect
{
    public NTGBattlePassiveSkillBehaviour pBehaviour;

    public override void PreShoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.PreShoot(lockedTarget, xOffset, zOffset);

        StartCoroutine(doPreMove(lockedTarget, xOffset, zOffset));
    }

    private IEnumerator doPreMove(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        //if (owner.alive && owner.navAgent != null)
        //    owner.navAgent.enabled = false;

        var time = pretime*0.95f;
        var dist = (float) Math.Sqrt(xOffset*xOffset + zOffset*zOffset);

        if (dist > 1.0f)
        {
            var zSpeed = (dist - 1.0f)/time;

            float d = 0;
            while (d < time)
            {
                yield return null;
                d += Time.deltaTime;

                owner.transform.Translate(0, 0, zSpeed*Time.deltaTime);
            }
        }

        //if (owner.alive && owner.navAgent != null)
        //    owner.navAgent.enabled = true;
    }

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        owner.AddPassive(pBehaviour.passiveName, shooter, skillController);
    }

    public override void PostHitTarget(NTGBattleUnitController target)
    {
        target.AddPassive("Slow", shooter, p: new[] {this.param[0], this.param[1]});
    }
}