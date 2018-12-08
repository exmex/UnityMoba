using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000092 : NTGBattleSkillBehaviour
{
    public ArrayList hittedUnits;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        transform.position += new Vector3(xOffset, 0, zOffset);

        collider.radius = param[0];

        hittedUnits = new ArrayList();

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        FXExplode();

        var d = 0.0f;
        while (d < duration)
        {
            collider.enabled = true;
            yield return new WaitForSeconds(0.1f);
            collider.enabled = false;

            yield return new WaitForSeconds(param[1]);
            d += param[1];
        }

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
            if (!hittedUnits.Contains(otherUnit))
            {
                foreach (NTGBattlePassiveSkillBehaviour passive in otherUnit.passives)
                {
                    if (passive.name == "PBehaviourR60000090")
                    {
                        otherUnit.AddPassive("Stun", owner, p: new[] {this.param[2]});
                        break;
                    }
                }

                hittedUnits.Add(otherUnit);
            }

            otherUnit.Hit(shooter, this);

            FXHit(otherUnit);
        }
    }
}