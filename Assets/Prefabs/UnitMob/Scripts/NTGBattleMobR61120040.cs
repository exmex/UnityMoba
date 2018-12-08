using UnityEngine;
using System.Collections;

public class NTGBattleMobR61120040 : NTGBattleMobCommonController
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

        float skillWeight = 0.4f;

        int skillRollIndex = 1;
        if (Random.Range(0.0f, 1.0f) < 0.5f)
            skillRollIndex = 2;

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
                        targetList.Remove(target);
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

                    targetList.Clear();

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

                    skillWeight = 0.4f;
                }

                yield return new WaitForSeconds(0.1f);
                continue;
            }

            mainController.uiController.ShowUnitSign(this);

            while (alive && targetUnit != null && targetUnit.Lockable(group))
            {
                sqrDist = (targetUnit.transform.position - transform.position).sqrMagnitude;
                sqrResDist = (respawnPosition - transform.position).sqrMagnitude;
                if (sqrDist > sqrTargetRange || sqrResDist > sqrPursueDistance)
                    break;

                while (!Moveable)
                    yield return new WaitForSeconds(0.1f);

                if (sqrDist > sqrStopDistance)
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

                int skillIndex = 0;
                var skillRoll = Random.Range(0.0f, 1.0f);
                if (skillRoll < skillWeight)
                {
                    skillIndex = skillRollIndex;
                    if (skillRollIndex == 1)
                        skillRollIndex = 2;
                    else
                        skillRollIndex = 1;

                    skillWeight = 0.4f;
                }
                skillWeight += 0.04f;

                while (!Shootable || skills[skillIndex].inCd > 0)
                    yield return new WaitForSeconds(0.1f);

                if (mp >= skills[skillIndex].mpCost && sqrDist < skills[skillIndex].sqrRange)
                {
                    mp -= skills[skillIndex].mpCost;

                    if (skills[skillIndex].facingType == NTGBattleSkillFacingType.Target)
                        transform.LookAt(new Vector3(targetUnit.transform.position.x, transform.position.y, targetUnit.transform.position.z));

                    skills[skillIndex].Shoot(targetUnit);

                    //yield return new WaitForSeconds(skills[skillIndex].inCd);
                }

                yield return new WaitForSeconds(0.1f);
            }

            SetNavPriority(NavPriority.Default);
        }
    }
}