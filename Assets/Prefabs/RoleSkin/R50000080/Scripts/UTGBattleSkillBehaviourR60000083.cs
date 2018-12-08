using System;
using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000083 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour respawnPassive;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        transform.position += new Vector3(xOffset, 0, zOffset);

        collider.radius = param[1];
        collider.enabled = false;

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        FXExplode();

        owner.mainController.SummonRespawn(10000 + owner.position, transform.position, owner.transform.rotation, Convert.ToInt32(this.param[0]), respawnPassive.passiveName, owner.id);

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
            otherUnit.Hit(shooter, this);

            FXHit(otherUnit);
        }
    }
}