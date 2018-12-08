using UnityEngine;
using System.Collections;
using System;

public class UTGBattlePassiveSkillBehaviourR60030110 : NTGBattlePassiveSkillBehaviour
{
    public float pAddRange;
    public float pAddNum;
    public ArrayList targetsInRange;
    private int count = 0;
    public NTGBattleUnitController target;




    //public override void Respawn()
    //{
    //    base.Respawn();

    //    pAddRange = this.param[1];
    //    pAddNum = this.param[2];

    //    collider.radius = pAddRange;

    //    targetsInRange = new ArrayList();

    //    if (owner.transform.gameObject.activeInHierarchy)
    //    {
    //        StartCoroutine(doEffect());
    //    }
    //}

    //private IEnumerator doEffect()
    //{
    //    collider.enabled = true;
    //    yield return new WaitForSeconds(0.1f);
    //    collider.enabled = false;
    //    yield return new WaitForSeconds(0.2f);


    //    FXEA();
    //    FXEB();
        
    //    foreach(NTGBattleUnitController p in targetsInRange)
    //    {
    //        if(p != null)
    //        {
    //            ShootBase(p);
    //            baseValue = this.baseValue;
    //            effectType = EffectType.MagicDamage;
    //            p.Hit(skillController.owner, this);
    //            FXHit(p);
    //        }
    //    }
    //    count = 0;
    //    yield return new WaitForSeconds(0.5f);

    //    Release();

    //}

    //public override void Notify(NTGBattlePassive.Event e, object param)
    //{
    //    if(e == NTGBattlePassive.Event.PassiveAdd)
    //    {
    //        var p = (NTGBattlePassiveSkillBehaviour)param;
    //        count = 0;
    //        StopAllCoroutines();
    //        StartCoroutine(doEffect());
    //    }
    //}

    //public void OnTriggerEnter(Collider other)
    //{ 
    //    if (owner == null)
    //    {
    //        return;
    //    }

    //    var otherUnit = other.GetComponent<NTGBattleUnitController>();
    //    if (otherUnit != null && otherUnit.alive && ((otherUnit.group == owner.group) || (otherUnit.group == 3)) && (mask & otherUnit.mask) != 0 &&
    //            (!(otherUnit is NTGBattleMobTowerController) || (otherUnit == owner))  && count < pAddNum)
    //    {
    //        targetsInRange.Add(otherUnit);
    //        count++;
    //    }
    //}

    public override void Respawn()
    {
        base.Respawn();

        pAddRange = this.param[1];
        pAddNum = this.param[2];

        collider.radius = pAddRange;

        //targetsInRange = new ArrayList();

        target = null;

        if (owner.transform.gameObject.activeInHierarchy)
        {
            StartCoroutine(doTest());
        }        
    }

    private IEnumerator doTest()
    {
        collider.enabled = true;
        yield return new WaitForSeconds(0.1f);

        if(target != null && target.alive)
        {
            target.AddPassive(this.passiveName, shooter, skillController);
        }

        //Debug.Log(owner.name + " " + "have run this behaviour" + " " + owner.transform.localPosition.x);

        ShootBase(owner);
        baseValue = this.baseValue;
        effectType = EffectType.MagicDamage;
        owner.Hit(skillController.owner, this);
        FXHit(owner);

        collider.enabled = false;

        yield return new WaitForSeconds(0.3f);

        Release();
    }


    public void OnTriggerEnter(Collider other)
    {
        if (other == null)
        {
            return;
        }

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && (otherUnit.group == owner.group || otherUnit.group == 3) && otherUnit.alive && (skillController as UTGBattlePassiveSkillControllerR60030110).targets.Count < 3
            && !(otherUnit is NTGBattleMobTowerController))
        {
            bool haveThisPassive = false;

            foreach (NTGBattleUnitController u in (skillController as UTGBattlePassiveSkillControllerR60030110).targets)
            {
                if (u.id == otherUnit.id)
                {
                    haveThisPassive = true;
                }
            }

            if(!haveThisPassive)
            {
                target = otherUnit;
                (skillController as UTGBattlePassiveSkillControllerR60030110).targets.Add(otherUnit);
                collider.enabled = false;
            }
        }
    }

}
