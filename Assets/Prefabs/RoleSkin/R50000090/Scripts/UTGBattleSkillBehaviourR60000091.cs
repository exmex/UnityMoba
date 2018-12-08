using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000091 : NTGBattleSkillBehaviour
{
    public ArrayList hittedUnits;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        startPos = owner.transform.position;

        collider.radius = param[0];

        hittedUnits = new ArrayList();

        StartCoroutine(doFly());
    }

    private bool hitTarget;

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        FXCustom(0);
        customFx[0].parent = transform;
        customFx[0].localPosition = Vector3.zero;
        customFx[0].localRotation = Quaternion.identity;

        collider.enabled = true;

        while (owner != null && (transform.position.x - startPos.x)*(transform.position.x - startPos.x) + (transform.position.z - startPos.z)*(transform.position.z - startPos.z) < sqrRange)
        {
            transform.Translate(0, 0, speed*Time.deltaTime);
            yield return null;
        }

        collider.enabled = false;


        FXHit(null);
        customFx[0].gameObject.SetActive(false);

        //yield return new WaitForSeconds(2.0f);

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
                        otherUnit.AddPassive("Stun", owner, p: new[] {this.param[1]});
                        break;
                    }
                }

                otherUnit.Hit(owner, this);
                customFx[0].gameObject.SetActive(false);

                FXHit(otherUnit, true);

                hittedUnits.Add(otherUnit);
            }
        }
    }
}