using UnityEngine;
using System.Collections;

public class NTGBattleMobR61120030 : NTGBattleMobCommonController
{
    public float stopDistance;

    public NTGBattlePlayerController summoner;

    public float sqrStopDistance;
    public float pursueTime;
    public float sqrFollowRange;

    public override void Init(float[] p)
    {
        stopDistance = p[0];
        pursueTime = p[1];
        sqrFollowRange = p[2]*p[2];
    }

    public override void Respawn()
    {
        base.Respawn();

        targetUnit = null;

        sqrStopDistance = stopDistance*stopDistance;

        if (master)
        {
            StartCoroutine(doMove());
        }
    }

    //public bool playerHitLocked;
    public bool movingToWp;

    private IEnumerator doMove()
    {
        float sqrDist = 0;

        skills[1].Shoot(targetUnit);

        yield return new WaitForSeconds(1.0f);

        while (alive)
        {
            if (summoner == null)
            {
                yield return new WaitForSeconds(0.1f);
                continue;
            }

            //if (!playerHitLocked)
            //{
            targetUnit = FindTarget(targetRange, type: TargetType.Player);
            if (targetUnit == null)
            {
                targetUnit = FindTarget(targetRange);
            }
            //}

            if (targetUnit == null)
            {
                sqrDist = (summoner.transform.position - transform.position).sqrMagnitude;
                if (sqrDist > sqrFollowRange)
                {
                    var pos = summoner.transform.position + summoner.transform.right;
                    AddPassive("Teleport", this, p: new[] {pos.x, pos.y, pos.z});
                }
                else
                {
                    if (Moveable && sqrDist > sqrStopDistance)
                    {
                        MoveTo(summoner.transform.position);
                        SetNavPriority(NavPriority.Default);
                    }
                    else
                    {
                        StopMovement();
                        SetNavPriority(NavPriority.MobStanding);
                    }
                }

                yield return new WaitForSeconds(0.1f);
                continue;
            }

            float shootTime = Time.time;
            while (alive && targetUnit != null && targetUnit.Lockable(group))
            {
                sqrDist = (targetUnit.transform.position - transform.position).sqrMagnitude;
                if (sqrDist > sqrTargetRange || Time.time - shootTime > pursueTime)
                    break;

                if (Moveable && sqrDist > sqrStopDistance)
                {
                    MoveTo(targetUnit.transform.position);
                    SetNavPriority(NavPriority.Default);
                    movingToWp = false;
                }
                else
                {
                    StopMovement();
                    SetNavPriority(NavPriority.MobStanding);
                    movingToWp = false;
                }

                if (Shootable && skills[0].inCd <= 0 && mp >= skills[0].mpCost && sqrDist < skills[0].sqrRange)
                {
                    mp -= skills[0].mpCost;

                    if (skills[0].facingType == NTGBattleSkillFacingType.Target)
                        transform.LookAt(new Vector3(targetUnit.transform.position.x, transform.position.y, targetUnit.transform.position.z));

                    skills[0].Shoot(targetUnit);

                    shootTime = Time.time;
                }

                yield return new WaitForSeconds(0.1f);
            }

            //playerHitLocked = false;
            SetNavPriority(NavPriority.Default);
        }
    }

    //public override void PlayerHit(NTGBattlePlayerController player, NTGBattlePlayerController shooter)
    //{
    //    if (!playerHitLocked && player.group == group && (transform.position - shooter.transform.position).sqrMagnitude < sqrTargetRange)
    //    {
    //        playerHitLocked = true;
    //        targetUnit = shooter;
    //    }
    //}
}