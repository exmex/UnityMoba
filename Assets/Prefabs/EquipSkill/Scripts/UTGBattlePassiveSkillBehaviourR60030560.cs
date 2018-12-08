using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030560 : NTGBattlePassiveSkillBehaviour
{
    public ArrayList targetsInRange;

    public override void Respawn()
    {
        base.Respawn();
        collider.radius = this.param[0];

        targetsInRange = new ArrayList();

        StartCoroutine(doCheck());
    }
    private IEnumerator doCheck()
    {
            collider.enabled = true;
            yield return new WaitForSeconds(0.1f);
            collider.enabled = false;

            yield return new WaitForSeconds(0.2f);

            foreach (NTGBattleUnitController u in targetsInRange)
            {
                if (u != null)
                {
                    u.AddPassive(skillController.pBehaviours[1].passiveName, owner, skillController);
                }
            }

            Release();
    }

    void OnTriggerEnter(Collider other)
    {
        if (owner == null)
        {
            return;
        }

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && (otherUnit.group == owner.group || otherUnit.group == 3) && otherUnit.alive && !(otherUnit is NTGBattleMobTowerController))
        {
            targetsInRange.Add(otherUnit);
        }
    }
}
