using UnityEngine;
using System.Collections;

public class UTGBattleSKillBehaviourR60060050 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour[] pBehaviour;

    public ArrayList targetsInRange;

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

        collider.enabled = true;
        yield return new WaitForSeconds(0.1f);

        collider.enabled = false;
        yield return new WaitForSeconds(0.2f);

        foreach (NTGBattlePlayerController p in targetsInRange)
        {
            if (p != null && p.alive && p.group == owner.group)
            {
                p.AddPassive(pBehaviour[0].name, owner, skillController);

                float hpRecoverTemp = p.hpMax * 0.15f;

                p.hp += hpRecoverTemp;

                FXHit(p, head: true);

                skillController.StartCD();
            }
        }

        Release();
    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && otherUnit.group == owner.group && (mask & otherUnit.mask) != 0)
        {
            targetsInRange.Add(otherUnit);
        }
    }
}