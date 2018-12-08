using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030420 : NTGBattlePassiveSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour subPassive;
    public ArrayList targetsInRange;
    public override void Respawn()
    {
        base.Respawn();

        FXEA();
        FXEB();
        collider.radius = this.param[0];

        targetsInRange = new ArrayList();

        StartCoroutine(doCheck());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            StopAllCoroutines();
            Release();
        }
    }

    private IEnumerator doCheck()
    {
        while (true)
        {
            targetsInRange.Clear();
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

            yield return new WaitForSeconds(0.9f);
        }

    }

    void OnTriggerEnter(Collider other)
    {
        if (owner == null)
        {
            return;
        }

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null &&  otherUnit != owner && otherUnit.group != owner.group && otherUnit.alive && (otherUnit.mask & this.mask) != 0 &&
            !(otherUnit is NTGBattleMobTowerController))
        {
            targetsInRange.Add(otherUnit);
        }
    }
}
