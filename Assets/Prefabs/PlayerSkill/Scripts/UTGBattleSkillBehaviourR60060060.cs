using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60060060 : NTGBattleSkillBehaviour
{
    public ArrayList targetsInRange;

    public override void Shoot(NTGBattleUnitController target, float xOffset, float zOffset)
    {
        base.Shoot(target, xOffset, zOffset);

        range = this.param[0];

        collider.radius = range;

        targetsInRange = new ArrayList();

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

        yield return new WaitForSeconds(0.1f);

        //NTGBattleMobTowerController t = null;
        foreach (NTGBattleMobTowerController tower in targetsInRange)
        {
            if (tower != null)
            {
                tower.Hit(owner, this);

                tower.AddPassive("Stun", owner, p: new[] {this.duration});

                FXHit(tower, head: false);

                skillController.StartCD();
            }
        }

        Release();

    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;
        var otherTower = other.GetComponent<NTGBattleMobTowerController>();
        if (otherTower != null && otherTower.alive && otherTower.group != owner.group && (mask & otherTower.mask) != 0)
        {
            targetsInRange.Add(otherTower);

            FXHit(otherTower);
        }
    }
}