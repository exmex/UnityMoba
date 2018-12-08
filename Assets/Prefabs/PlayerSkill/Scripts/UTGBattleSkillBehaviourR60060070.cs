using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60060070 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour[] pBehaviour;

    public ArrayList targetsInRange;

    public float pDuration;

    public override void Shoot(NTGBattleUnitController target, float xOffset, float zOffset)
    {
        base.Shoot(target, xOffset, zOffset);

        collider.radius = this.param[0];

        targetsInRange = new ArrayList();

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        //FXExplode();

        pDuration = pBehaviour[0].duration;

        collider.enabled = true;
        yield return new WaitForSeconds(0.1f);
        collider.enabled = false;

        skillController.StartCD();

        foreach (NTGBattleUnitController u in targetsInRange)
        {
            if (u != null)
            {
                u.Hit(owner, this);

                u.AddPassive(pBehaviour[0].passiveName, owner, skillController);
            }
        }

        while (pDuration > 0)
        {
            pDuration -= 0.1f;
            yield return new WaitForSeconds(0.1f);
        }

        foreach (NTGBattleUnitController u in targetsInRange)
        {
            if (u != null)
            {
                u.AddPassive(pBehaviour[1].passiveName, u, skillController);
            }
        }

        Release();
    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
        {
            return;
        }

        var otherMob = other.GetComponent<NTGBattleMobController>();
        if (otherMob != null && otherMob.alive && otherMob.group != owner.group && (mask & otherMob.mask) != 0)
        {
            targetsInRange.Add(otherMob);
        }

        var otherPlayer = other.GetComponent<NTGBattlePlayerController>();
        if (otherPlayer != null && otherPlayer.alive && otherPlayer.group != owner.group && (mask & otherPlayer.mask) != 0)
        {
            targetsInRange.Add(otherPlayer);
        }

    }
}