using System;
using UnityEngine;
using System.Collections;

public class NTGBattleSkillSingleShootDirect : NTGBattleSkillBehaviour
{
    public virtual void PostHitTarget(NTGBattleUnitController target)
    {
        
    }

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        startPos = owner.transform.position;

        StartCoroutine(doFly());
    }

    protected bool hitTarget;

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        hitTarget = false;

        var lockedTargetCenter = Vector3.zero;
        if (lockedTarget != null)
        {
            lockedTargetCenter = lockedTarget.GetComponent<CapsuleCollider>().center;
        }
        else
        {
            collider.enabled = true;
        }

        var rangeCheck = 0;
        while (owner != null && hitTarget != true)
        {
            if (lockedTarget == null)
            {
                if ((transform.position.x - startPos.x)*(transform.position.x - startPos.x) + (transform.position.z - startPos.z)*(transform.position.z - startPos.z) > sqrRange)
                    break;

                //if (rangeCheck == 3)
                //{
                //    if ((transform.position.x - startPos.x)*(transform.position.x - startPos.x) + (transform.position.z - startPos.z)*(transform.position.z - startPos.z) > sqrRange)
                //        break;
                //    rangeCheck = 0;
                //}
                //else
                //    rangeCheck++;
            }
            else
            {
                if (lockedTarget.alive)
                {
                    if ((lockedTarget.transform.position + lockedTargetCenter - transform.position).sqrMagnitude < 0.2f)
                    {
                        hitTarget = true;
                        break;
                    }
                    transform.LookAt(lockedTarget.transform.position + lockedTargetCenter);
                }
                else
                {
                    break;
                }
            }

            transform.Translate(0, 0, speed*Time.deltaTime);

            yield return null;
        }

        if (lockedTarget != null && hitTarget)
        {
            lockedTarget.Hit(owner, this);

            PostHitTarget(lockedTarget);

            FXHit(lockedTarget);
        }
        else
        {
            FXHit(null);
        }

        yield return new WaitForSeconds(2.0f);

        Release();
    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            otherUnit.Hit(owner, this);

            PostHitTarget(otherUnit);

            FXHit(otherUnit);
            hitTarget = true;
            collider.enabled = false;
        }
    }
}