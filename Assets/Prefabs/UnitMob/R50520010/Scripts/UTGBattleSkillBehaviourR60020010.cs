using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60020010 : NTGBattleSkillBehaviour
{
    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        transform.parent = owner.transform;
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.identity;

        collider.radius = param[1];
        collider.enabled = false;

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();

        while (owner.alive)
        {
            collider.enabled = true;
            yield return new WaitForSeconds(0.1f);
            collider.enabled = false;

            yield return new WaitForSeconds(param[0]);
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
            otherUnit.Hit(shooter, this);

            FXHit(otherUnit);
        }
    }
}