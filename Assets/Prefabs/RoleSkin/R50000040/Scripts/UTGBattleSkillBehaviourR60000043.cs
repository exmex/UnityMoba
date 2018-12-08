using System;
using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000043 : NTGBattleSkillBehaviour
{
    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        collider.radius = param[0];

        transform.parent = owner.transform;
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.identity;

        StartCoroutine(doFly(xOffset, zOffset));
    }

    private IEnumerator doFly(float xOffset, float zOffset)
    {
        FXEA();
        FXEB();

        if (owner.alive && owner.navAgent != null)
            owner.navAgent.enabled = false;

        var dist = (float) Math.Sqrt(xOffset*xOffset + zOffset*zOffset);
        if (dist > 0.4f)
        {
            var ratio = (dist - 0.4f)/dist;

            yield return null;

            owner.transform.position += new Vector3(xOffset*ratio, 0, zOffset*ratio);
        }

        if (owner.alive && owner.navAgent != null)
            owner.navAgent.enabled = true;

        transform.parent = owner.mainController.dynamics;
        FXExplode();

        yield return null;

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
            otherUnit.Hit(owner, this);

            otherUnit.AddPassive("Blow", shooter, p: new[] {this.param[1]});

            FXHit(otherUnit);
        }
    }
}