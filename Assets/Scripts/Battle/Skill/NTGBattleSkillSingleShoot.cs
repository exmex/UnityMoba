using System;
using UnityEngine;
using System.Collections;

public class NTGBattleSkillSingleShoot : NTGBattleSkillBehaviour
{
    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        startPos = owner.transform.position;

        StartCoroutine(doFly());
    }

    protected bool hitTarget;

    protected IEnumerator doFly()
    {
        FXEA();
        FXEB();
        hitTarget = false;
        collider.enabled = true;

        var lockedTargetCenter = Vector3.zero;
        if (lockedTarget != null)
            lockedTargetCenter = lockedTarget.GetComponent<CapsuleCollider>().center;

        var rangeCheck = 0;
        while (owner != null && hitTarget == false)
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
                    if ((lockedTarget.transform.position + lockedTargetCenter - transform.position).sqrMagnitude < 0.01f)
                        break;

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

        FXHit(null);
        collider.enabled = false;

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

            FXHit(otherUnit);
            hitTarget = true;
            collider.enabled = false;
        }

        if (other.tag == "Ground")
        {
            FXHit(null);
            hitTarget = false;
            collider.enabled = false;
        }
    }
}