using UnityEngine;
using System.Collections;

public class NTGBattleMobR61120020 : NTGBattleMobCommonController
{
    public float stopDistance;
    public float pursueDistance;

    private float sqrStopDistance;
    private float sqrPursueDistance;

    private Vector3 respawnPosition;
    private Quaternion respawnRotation;

    private ArrayList targetList;

    public override void Init(float[] p)
    {
        stopDistance = p[0];
        pursueDistance = p[1];
    }

    public override void Respawn()
    {
        base.Respawn();

        targetUnit = null;
        movingToWp = false;

        sqrStopDistance = stopDistance*stopDistance;
        sqrPursueDistance = pursueDistance*pursueDistance;

        respawnPosition = transform.position;
        respawnRotation = transform.rotation;

        targetList = new ArrayList();

        if (master)
        {
            StartCoroutine(doMove());
        }
    }


    public override void Hit(NTGBattleUnitController shooter, NTGBattleSkillBehaviour behav)
    {
        base.Hit(shooter, behav);

        if (shooter != null && !targetList.Contains(shooter))
        {
            targetList.Add(shooter);
        }
    }

    public bool movingToWp;

    private IEnumerator doMove()
    {
        float sqrDist = 0;
        float sqrResDist = 0;

        while (alive)
        {
            targetUnit = null;
            if (targetList.Count > 0)
            {
                foreach (NTGBattleUnitController target in targetList)
                {
                    if (target != null && target.Lockable(group) && (target.transform.position - transform.position).sqrMagnitude < sqrTargetRange)
                    {
                        targetUnit = target;
                        break;
                    }
                }
            }

            if (targetUnit == null)
            {
                if (!movingToWp)
                {
                    MoveTo(respawnPosition);
                    movingToWp = true;

                    AddPassive("PoolRecover");

                    while ((transform.position.x - respawnPosition.x)*(transform.position.x - respawnPosition.x) +
                           (transform.position.z - respawnPosition.z)*(transform.position.z - respawnPosition.z) > 0.1f)
                    {
                        yield return new WaitForSeconds(0.1f);
                    }

                    while (hp < hpMax)
                    {
                        yield return new WaitForSeconds(0.1f);
                    }

                    RemovePassive("PoolRecover");

                    yield return new WaitForSeconds(0.1f);

                    transform.rotation = respawnRotation;

                    targetList.Clear();
                }

                yield return new WaitForSeconds(0.1f);
                continue;
            }

            AddPassive("UnitSign", this);

            while (alive && targetUnit != null && targetUnit.Lockable(group))
            {
                sqrDist = (targetUnit.transform.position - transform.position).sqrMagnitude;
                sqrResDist = (respawnPosition - transform.position).sqrMagnitude;
                if (sqrDist > sqrTargetRange || sqrResDist > sqrPursueDistance)
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
                }

                yield return new WaitForSeconds(0.1f);
            }

            if (targetUnit != null)
                targetList.Remove(targetUnit);

            SetNavPriority(NavPriority.Default);
        }
    }
}