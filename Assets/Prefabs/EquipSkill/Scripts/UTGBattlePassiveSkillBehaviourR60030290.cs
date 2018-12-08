using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030290 : NTGBattlePassiveSkillBehaviour
{
    public ArrayList targets;
    public NTGBattlePassiveSkillBehaviour subPassive;
    public override void Respawn()
    {
        base.Respawn();

        targets = new ArrayList();

        collider.radius = this.param[0];

        FXEA();
        FXEB();

        StartCoroutine(doCheck());
    }

    private IEnumerator doCheck()
    {
        while(true)
        {
            collider.enabled = true;
            yield return new WaitForSeconds(0.1f);
            collider.enabled = false;

            foreach(NTGBattleUnitController u in targets)
            {
                if (u != null && u.alive)
                {
                    u.AddPassive(skillController.pBehaviours[1].passiveName, owner, skillController);
                }
            }

            yield return new WaitForSeconds(0.9f);

            targets.Clear();
        }
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            Release();
        }
        else if(e == NTGBattlePassive.Event.PassiveAdd)
        {
            //Respawn();
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if(owner == null)
        {
            return;
        }

        
        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && !(otherUnit is NTGBattleMobTowerController) && otherUnit.group != owner.group && (otherUnit.mask & mask) != 0)
        {
            targets.Add(otherUnit);
        }

    }
}
