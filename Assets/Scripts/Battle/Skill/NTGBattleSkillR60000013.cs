using System;
using UnityEngine;
using System.Collections;

public class NTGBattleSkillR60000013 : NTGBattleSkillBehaviour
{
    public float reShootCount;
    public float reShootCap;
    public float reShootRange;

    public NTGBattleUnitController lastHitTarget;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        reShootCount = 0;
        reShootCap = param[0];
        reShootRange = param[1];

        lastHitTarget = null;

        startPos = transform.position;

        StartCoroutine(doFly());
    }

    private bool hitTarget;

    private IEnumerator doFly()
    {
        FXEA();

        FXEB();
        hitTarget = false;
        GetComponent<CapsuleCollider>().enabled = true;
        var lockedTargetCenter = lockedTarget.GetComponent<CapsuleCollider>().center;

        while (owner != null && reShootCount < reShootCap && (transform.position - startPos).sqrMagnitude < sqrRange)
        {
            while (hitTarget == false)
            {
                if (lockedTarget != null && (lockedTarget.transform.position + lockedTargetCenter - transform.position).sqrMagnitude < 0.01f)
                {
                    break;
                }

                if (lockedTarget != null && lockedTarget.alive)
                {
                    transform.LookAt(lockedTarget.transform.position + lockedTargetCenter);
                }

                transform.Translate(0, 0, speed*Time.deltaTime);
                yield return null;
            }

            if (hitTarget)
            {
                var ex = new ArrayList();
                ex.Add(lastHitTarget);
                lockedTarget = owner.FindTarget(transform.position, reShootRange, excludes: ex);
                if (lockedTarget != null)
                {
                    reShootCount++;

                    FXEB();
                    hitTarget = false;
                    GetComponent<CapsuleCollider>().enabled = true;
                    lockedTargetCenter = lockedTarget.GetComponent<CapsuleCollider>().center;
                }
                else
                {
                    reShootCount = reShootCap;
                }
            }
        }

        if (hitTarget)
        {
            yield return new WaitForSeconds(2.0f);
        }

        Release();
    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit != lastHitTarget && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            otherUnit.Hit(owner, this);

            FXHit(otherUnit);
            hitTarget = true;
            lastHitTarget = otherUnit;
            GetComponent<CapsuleCollider>().enabled = false;
        }

        if (other.tag == "Ground")
        {
            FXHit(null);
            hitTarget = false;
            GetComponent<CapsuleCollider>().enabled = false;
        }
    }
}