using UnityEngine;
using System.Collections;

public class NTGBattleSkillR60000010 : NTGBattleSkillBehaviour
{
    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

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

        var v = lockedTarget.transform.position + lockedTargetCenter - startPos;
        var setpoint = v.normalized*v.magnitude/4;
        setpoint.y = 0.6f;
        setpoint = transform.TransformPoint(setpoint);

        var setpointReached = false;
        var targetpoint = setpoint;
        while (owner != null && hitTarget == false && (transform.position - startPos).sqrMagnitude < sqrRange)
        {
            if (lockedTarget != null && (lockedTarget.transform.position + lockedTargetCenter - transform.position).sqrMagnitude < 0.01f)
            {
                break;
            }

            if (!setpointReached && Vector3.Distance(setpoint, transform.position) < 0.1f)
            {
                setpointReached = true;
            }

            if (setpointReached)
            {
                targetpoint = lockedTarget.transform.position + lockedTargetCenter;
            }

            if (lockedTarget != null && lockedTarget.alive)
            {
                transform.LookAt(targetpoint);
            }

            transform.Translate(0, 0, speed*Time.deltaTime);
            yield return null;
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
        if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            otherUnit.Hit(owner, this);

            FXHit(otherUnit);
            hitTarget = true;
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