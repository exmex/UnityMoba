using UnityEngine;
using System.Collections;

public class NTGBattleMobR61120010 : NTGBattleMobCommonController
{
    public float stopDistance;

    public int currentWpIndex;
    public Transform currentWp;

    public float sqrStopDistance;
    public float pursueTime;

    //public bool playerHitLocked;
    public bool movingToWp;
    public bool doneWp;

    public override void Init(float[] p)
    {
        stopDistance = p[0];
        pursueTime = p[1];
    }

    public override void Respawn()
    {
        base.Respawn();

        currentWpIndex = 1;
        targetUnit = null;
        movingToWp = false;
        doneWp = false;

        sqrStopDistance = stopDistance*stopDistance;

        avoidingEnabled = false;

        if (master)
        {
            StartCoroutine(doMove());
        }
    }

    public bool avoidingMove;
    public bool avoidingEnabled;

    public IEnumerator OnTriggerEnter(Collider other)
    {
        if (!avoidingEnabled)
            yield break;

        var otherUnit = other.GetComponent<NTGBattleMobCommonController>();
        if (otherUnit != null)
        {
            var dir = (otherUnit.transform.position - transform.position).normalized;
            dir = Quaternion.Euler(0, 110.0f, 0)*dir*0.4f;

            MoveTo(otherUnit.transform.position + dir);
            movingToWp = false;

            avoidingMove = true;
            yield return new WaitForSeconds(0.5f);
            avoidingMove = false;
        }
    }


    private IEnumerator doMove()
    {
        yield return new WaitForSeconds(0.5f);

        float sqrDist = 0;
        var exList = new ArrayList();

        while (alive)
        {
            avoidingEnabled = false;

            //if (!playerHitLocked)
            //{
            //    //targetUnit = FindTarget(targetRange, type: TargetType.Mob, exNeutMob: true);
            //    //if (targetUnit == null)
            //    {
            targetUnit = FindTarget(targetRange, exNeutMob: true, excludes: exList);
            //    }
            //}

            if (targetUnit == null)
            {
                if (!doneWp)
                {
                    if (!movingToWp)
                    {
                        currentWp = mainController.respawn.Find("WayPoint/WP-" + position + "/" + currentWpIndex);

                        if (currentWp != null)
                        {
                            MoveTo(currentWp.position);
                            movingToWp = true;
                        }
                        else
                        {
                            doneWp = true;
                        }
                    }

                    if (movingToWp && (transform.position - currentWp.position).sqrMagnitude < 1.0f)
                    {
                        currentWpIndex++;
                        currentWp = mainController.respawn.Find("WayPoint/WP-" + position + "/" + currentWpIndex);

                        if (currentWp != null)
                        {
                            MoveTo(currentWp.position);
                            movingToWp = true;
                        }
                        else
                        {
                            doneWp = true;
                        }

                        exList.Clear();
                    }
                }

                yield return new WaitForSeconds(0.1f);
                continue;
            }

            avoidingEnabled = true;

            if (!exList.Contains(targetUnit))
                exList.Add(targetUnit);

            float shootTime = Time.time;
            while (alive && targetUnit != null && targetUnit.Lockable(group))
            {
                sqrDist = (targetUnit.transform.position - transform.position).sqrMagnitude - targetUnit.unitRadiusSqr;
                if (sqrDist > sqrTargetRange || Time.time - shootTime > pursueTime)
                    break;

                if (!avoidingMove)
                {
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
                }

                if (Shootable && skills[0].inCd <= 0 && mp >= skills[0].mpCost && sqrDist < skills[0].sqrRange)
                {
                    if (exList.Contains(targetUnit))
                        exList.Remove(targetUnit);

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