using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60060020 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour[] pBehaviour;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        collider.radius = range;

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

        var otherUnit = other.GetComponent<NTGBattlePlayerController>();
        if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            baseValue = (otherUnit.hpMax - otherUnit.hp)*this.param[0];

            //  Debug.Log("斩杀 "+ otherUnit.hpMax + " " + otherUnit.hp + " " + baseValue);

            if (baseValue >= 0)
            {
                otherUnit.Hit(owner, this);
            }

            FXHit(otherUnit);
        }
    }
}