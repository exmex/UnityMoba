using UnityEngine;
using System.Collections;

public class NTGBattleSkillR60000007 : NTGBattleSkillBehaviour
{
    public Transform CustomFXAnchor;
    public float hitTime;

    public float flySpeed;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        StartCoroutine(doFly());
    }

    private bool hitTarget;

    private IEnumerator doFly()
    {
        GetComponent<CapsuleCollider>().enabled = true;

        yield return new WaitForSeconds(duration);

        if (hitTarget)
        {
            yield return new WaitForSeconds(10.0f);
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

            otherUnit.AddPassive("Blow");

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