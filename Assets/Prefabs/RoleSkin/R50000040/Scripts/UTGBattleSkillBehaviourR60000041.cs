using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000041 : NTGBattleSkillBehaviour
{
    public ArrayList hittedUnits;
    public bool interrupted;

    public override bool Interrupt()
    {
        interrupted = true;

        return true;
    }

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        collider.radius = param[0];

        transform.parent = owner.transform;
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.identity;

        interrupted = false;

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();

        var reachDest = false;

        collider.enabled = true;

        NavMeshHit hit;
        if (NavMesh.SamplePosition(transform.position + transform.forward*range*2, out hit, 0.5f, NavMesh.AllAreas))
        {
            if (owner.alive && owner.navAgent != null)
                owner.navAgent.enabled = false;

            reachDest = true;
        }

        float d = 0;
        while (d < range && !interrupted)
        {
            owner.transform.Translate(0, 0, Time.deltaTime*speed);
            d += Time.deltaTime*speed;
            yield return null;
        }

        collider.enabled = false;

        if (reachDest && owner.alive && owner.navAgent != null)
            owner.navAgent.enabled = true;

        yield return new WaitForSeconds(1.0f);

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

            FXHit(otherUnit, keepEB: true);
        }
    }
}