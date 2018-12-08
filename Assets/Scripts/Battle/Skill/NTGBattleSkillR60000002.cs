using System;
using UnityEngine;
using System.Collections;

public class NTGBattleSkillR60000002 : NTGBattleSkillBehaviour
{
    public Transform CustomFXAnchor;
    public float hitTime;

    public float flySpeed;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEB();

        yield return new WaitForSeconds(duration);

        Release();
    }
}