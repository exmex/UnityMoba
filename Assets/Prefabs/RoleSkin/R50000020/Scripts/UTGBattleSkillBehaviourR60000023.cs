using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000023 : NTGBattleSkillBehaviour
{
    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        collider.radius = range;

        transform.parent = owner.transform;

        StartCoroutine(doFly());
    }

    public override bool Interrupt()
    {
        if (owner.interruptSource != NTGBattleUnitController.ShootInterruptSource.Move)
        {
            owner.unitAnimator.SetBool("skillkeep", false);

            Release();

            return true;
        }

        return false;
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();

        owner.unitAnimator.SetBool("skillkeep", true);
        var d = 0.0f;
        while (d < duration - pretime)
        {
            collider.enabled = true;
            yield return new WaitForSeconds(0.1f);
            collider.enabled = false;

            yield return new WaitForSeconds(param[0] - 0.1f);
            d += param[0];
        }
        owner.unitAnimator.SetBool("skillkeep", false);

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