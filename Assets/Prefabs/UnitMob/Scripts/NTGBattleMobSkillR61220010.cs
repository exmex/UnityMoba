using UnityEngine;
using System.Collections;

public class NTGBattleMobSkillR61220010 : NTGBattleMobSkillController
{
    public float cd;
    public float rate;

    public bool inCd;
    public float lastUseTime;

    public override void Init(float[] p)
    {
        cd = 0;
        rate = 10000;
    }

    public override void Respawn()
    {
        base.Respawn();

        if (mobController.master)
        {
            StartCoroutine(doShoot());
        }
    }

    public bool standing;

    private IEnumerator doShoot()
    {
        standing = false;

        while (mobController.alive)
        {
            if (!standing && mobController.targetUnit != null && mobController.targetUnit.alive && (transform.position - mobController.targetUnit.transform.position).sqrMagnitude < skillController.sqrRange)
            {
                standing = true;
                mobController.SetNavPriority(NTGBattleUnitController.NavPriority.MobStanding);
            }
            else
            {
                standing = false;
                mobController.SetNavPriority(NTGBattleUnitController.NavPriority.Default);
            }

            if (!inCd && mobController.targetUnit != null && mobController.targetUnit.alive && skillController.inCd <= 0 && (transform.position - mobController.targetUnit.transform.position).sqrMagnitude < skillController.sqrRange)
            {
                if (mobController.Shootable && Random.Range(0, 10000) < rate)
                {
                    if (mobController.mp >= skillController.mpCost)
                    {
                        mobController.mp -= skillController.mpCost;

                        skillController.Shoot(mobController.targetUnit);

                        if (mobController is NTGBattleMobCommonController)
                            mobController.transform.LookAt(new Vector3(mobController.targetUnit.transform.position.x, transform.position.y, mobController.targetUnit.transform.position.z));

                        //inCd = true;
                        //lastUseTime = Time.time;
                        //StartCoroutine(doCD());
                        yield return new WaitForSeconds(skillController.cd);
                    }
                }
            }

            yield return null;
        }
    }

    private IEnumerator doCD()
    {
        while (Time.time - lastUseTime < cd)
        {
            yield return null;
        }
        inCd = false;
    }
}