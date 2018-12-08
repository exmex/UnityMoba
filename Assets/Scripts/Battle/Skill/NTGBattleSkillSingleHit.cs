using System;
using UnityEngine;
using System.Collections;

public class NTGBattleSkillSingleHit : NTGBattleSkillBehaviour
{
    public float targetAngle;

    public override bool Interrupt()
    {
        Release();

        return true;
    }

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        startPos = owner.transform.position;

        targetAngle = param[0];

        collider.radius = range;

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();

        collider.enabled = true;
        yield return new WaitForSeconds(0.1f);
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
            var dir = other.transform.position - shooter.transform.position;
            dir = new Vector3(dir.x, 0, dir.z);
            if (dir.sqrMagnitude > 0.01f)
            {
                var angle = Vector3.Angle(new Vector3(shooter.transform.forward.x, 0, shooter.transform.forward.z), dir);
                if (angle > targetAngle/2)
                    return;
            }

            otherUnit.Hit(owner, this);

            FXHit(otherUnit);
        }
    }
}