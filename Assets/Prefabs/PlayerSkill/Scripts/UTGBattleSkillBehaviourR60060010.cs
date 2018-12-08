using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60060010 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour[] pBehaviour;

    public float targetAngle;

    public ArrayList targetsInRange;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        collider.radius = range;
        targetAngle = 45.0f;

        targetsInRange = new ArrayList();

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        FXExplode();

        //ef.parent = owner.unitUiAnchor;
        //ef.localPosition = new Vector3(0, -0.36f, 0);
        //ef.localRotation = Quaternion.identity;

        collider.enabled = true;
        yield return new WaitForSeconds(0.1f);
        collider.enabled = false;

        NTGBattleUnitController t = null;
        var sqrMinDist = float.MaxValue;
        foreach (NTGBattleUnitController unit in targetsInRange)
        {
            if (unit == lockedTarget)
            {
                t = lockedTarget;
                break;
            }

            var sqrDist = (unit.transform.position - transform.position).sqrMagnitude;
            if (sqrDist < sqrMinDist)
            {
                t = unit;
                sqrMinDist = sqrDist;
            }
        }
        if (t != null)
        {
            baseValue = this.param[0] + this.param[1]*owner.level;

            t.Hit(owner, this);

            t.AddPassive("Stun", owner, p: new[] {this.param[2]});

            FXHit(t, head: true);

            skillController.StartCD();
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
            var dir = other.transform.position - transform.position;
            var angle = Vector3.Angle(new Vector3(transform.forward.x, 0, transform.forward.z), new Vector3(dir.x, 0, dir.z));
            if (angle > targetAngle/2)
                return;

            targetsInRange.Add(otherUnit);
        }
    }
}