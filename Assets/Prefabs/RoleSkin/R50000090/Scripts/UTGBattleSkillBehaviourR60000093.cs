using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000093 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour pBehaviour;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        transform.position += new Vector3(xOffset, 0, zOffset);

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

        yield return new WaitForSeconds(duration);

        Release();
    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            foreach (NTGBattlePassiveSkillBehaviour passive in otherUnit.passives)
            {
                if (passive.name == "PBehaviourR60000090")
                {
                    otherUnit.AddPassive(pBehaviour.passiveName, owner, skillController);
                    break;
                }
            }

            otherUnit.Hit(shooter, this);

            FXHit(otherUnit);
        }
    }
}