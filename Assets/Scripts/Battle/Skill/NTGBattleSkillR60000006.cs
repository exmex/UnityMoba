using UnityEngine;
using System.Collections;

public class NTGBattleSkillR60000006 : NTGBattleSkillBehaviour
{
    public Transform CustomFXAnchor;
    public float hitTime;

    public float flyRange;
    public float flySpeed;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        transform.parent = owner.transform;

        if (lockedTarget != null)
        {
            flyRange = Vector3.Distance(owner.transform.position, lockedTarget.transform.position) - 1.0f;
        }
        else
        {
            flyRange = range;
        }

        flySpeed = flyRange/duration;

        StartCoroutine(doFly());
    }

    private float flyDist;

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        flyDist = 0;

        while (owner != null && owner.GetStatus(NTGBattleUnitController.UnitStatus.Shoot) && flyDist < flyRange)
        {
            //if (lockedTarget != null && lockedTarget.alive)
            //{
            //    owner.transform.LookAt(new Vector3(lockedTarget.transform.position.x, owner.transform.position.y, lockedTarget.transform.position.z));
            //}

            owner.transform.Translate(0, 0, flySpeed*Time.deltaTime);

            flyDist += flySpeed*Time.deltaTime;
            yield return null;
        }


        eb.gameObject.SetActive(false);

        yield return new WaitForSeconds(5.0f);

        Release();
    }
}