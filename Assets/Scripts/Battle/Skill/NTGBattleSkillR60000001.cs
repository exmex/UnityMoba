using UnityEngine;
using System.Collections;

public class NTGBattleSkillR60000001 : NTGBattleSkillBehaviour
{
    public Transform CustomFXAnchor;
    public float hitTime;
    public float targetAngle;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        targetAngle = param[0];
        GetComponent<CapsuleCollider>().radius = param[1];

        GetComponent<CapsuleCollider>().enabled = false;

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        yield return new WaitForSeconds(hitTime);
        GetComponent<CapsuleCollider>().enabled = true;
        yield return new WaitForSeconds(0.1f);
        GetComponent<CapsuleCollider>().enabled = false;

        yield return new WaitForSeconds(10.0f);

        Release();
    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            var angle = Vector3.Angle(transform.forward, other.transform.position - transform.position);
            if (angle > targetAngle/2)
                return;

            otherUnit.Hit(owner, this);

            otherUnit.AddPassive("Slow", p: new[] {param[2], param[3]});

            FXHit(otherUnit);
        }
    }
}