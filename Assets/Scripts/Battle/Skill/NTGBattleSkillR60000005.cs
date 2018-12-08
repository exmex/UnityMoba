using UnityEngine;
using System.Collections;

public class NTGBattleSkillR60000005 : NTGBattleSkillBehaviour
{
    public Transform CustomFXAnchor;
    public float hitTime;
    public float targetAngle;

    public NTGBattleMainCameraController.CameraShockType shockType;
    public float shockDelay;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);
        targetAngle = param[0];
        GetComponent<CapsuleCollider>().radius = param[1];

        GetComponent<CapsuleCollider>().enabled = false;

        StartCoroutine(doFly());

        if (owner == owner.mainController.uiController.localPlayerController)
        {
            StartCoroutine(doShock());
        }
    }

    private IEnumerator doShock()
    {
        yield return new WaitForSeconds(shockDelay);
        //owner.mainController.CameraShock(shockType);
    }

    private IEnumerator doFly()
    {
        //if (lockedTarget != null)
        //{
        //    owner.transform.LookAt(new Vector3(lockedTarget.transform.position.x, owner.transform.position.y, lockedTarget.transform.position.z));
        //}

        yield return new WaitForSeconds(hitTime);
        FXEA();
        GetComponent<CapsuleCollider>().enabled = true;
        yield return new WaitForSeconds(0.1f);
        GetComponent<CapsuleCollider>().enabled = false;

        yield return new WaitForSeconds(10.0f + animationDuration - hitTime - 0.1f);

        Release();
    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            var angle = Vector3.Angle(transform.forward, other.transform.position - transform.position);
            if (angle > targetAngle/2)
                return;

            otherUnit.Hit(owner, this);

            otherUnit.AddPassive("Blow");

            StartCoroutine(deferStun(otherUnit));

            FXHit(otherUnit);
        }
    }

    private IEnumerator deferStun(NTGBattleUnitController target)
    {
        yield return new WaitForSeconds(2.0f);

        if (target != null && target.alive)
        {
            target.AddPassive("Stun", p: new[] {param[2]});
        }
    }
}