using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000052 : NTGBattleSkillBehaviour
{
    public ArrayList hittedUnits;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        collider.radius = param[0];

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        FXExplode();

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

            otherUnit.AddPassive("Slow", shooter, p: new[] {this.param[1], this.param[2]});

            FXHit(otherUnit);
        }
    }
}