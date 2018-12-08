using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030240 : NTGBattlePassiveSkillBehaviour
{
    public float pDamage;

    public ArrayList targetsInRange;

    public override void Respawn()
    {
        base.Respawn();

        collider.radius = this.param[0];

        targetsInRange = new ArrayList();

        //Debug.Log(this.baseValue + " " + this.mAdd + " " + shooter.baseAttrs.MAtk);
        pDamage = this.baseValue;
        FXHit(owner);

        StartCoroutine(doBoost());
    }

    private IEnumerator doBoost()
    {

        collider.enabled = true;
        yield return new WaitForSeconds(0.1f);
        collider.enabled = false;

        yield return new WaitForSeconds(0.2f);

        foreach(NTGBattleUnitController u in targetsInRange)
        {
            if (u != null)
            {
                ShootBase(u);
                baseValue = pDamage;
                effectType = EffectType.MagicDamage;
                u.Hit(shooter, this);
            }
        }
        yield return new WaitForSeconds(1f);

        Release();

        
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if(e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            StopAllCoroutines();
            FXHit(owner);
            targetsInRange.Clear();
            StartCoroutine(doBoost());
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if(owner == null)
        {
            return;
        }

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && otherUnit.group != shooter.group && !(otherUnit is NTGBattleMobTowerController))
        {
            targetsInRange.Add(otherUnit);
        }
    }
}
