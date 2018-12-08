using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000042 : NTGBattleSkillBehaviour
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

        targetAngle = param[0];

        collider.radius = range;

        transform.parent = owner.transform;
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.identity;

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();

        float d = 0;
        while (d < duration)
        {
            collider.enabled = true;
            yield return new WaitForSeconds(0.1f);
            collider.enabled = false;

            yield return new WaitForSeconds(param[1]);
            d += param[1];
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
            var dir = other.transform.position - transform.position;
            var angle = Vector3.Angle(new Vector3(transform.forward.x, 0, transform.forward.z), new Vector3(dir.x, 0, dir.z));
            if (angle > targetAngle/2)
                return;

            otherUnit.Hit(shooter, this);

            FXHit(otherUnit);
        }
    }
}