using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030150 : NTGBattlePassiveSkillBehaviour
{
    public float pAddNum;
    public float pDuration;
    public float count;
    public ArrayList targetsInRange;

    public override void Respawn()
    {
        base.Respawn();


        DoRespawn((int)this.param[0]);

    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);
        if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            Release();
        }
        else if(e == NTGBattlePassive.Event.PassiveAdd)
        {
            //Debug.Log("Load Skill Behaviour");
            return;
        }
    }

    public void DoRespawn(int skillType)
    {
        if(skillType == null)
        {
            return;
        }

        if (skillType == 0)
        {
            FXEA();
            FXEB();
            pAddNum = this.param[1] + shooter.level * this.param[2];
            ShootBase(owner);
            baseValue = pAddNum;
            effectType = EffectType.MagicDamage;
            owner.Hit(shooter, this);
            Release();
        }
        else if(skillType == 2)
        {
            FXEA();
            FXEB();
            ShootBase(owner);
            effectType = EffectType.MagicDamage;
            owner.Hit(shooter, this);
            Release();
        }
        else if(skillType == 1)
        {
            FXEA();
			FXEB();
			
            collider.radius = this.param[1];
            pAddNum = this.param[2] + shooter.level * this.param[3];
            FXHit(owner);

            targetsInRange = new ArrayList();

            StartCoroutine(doCheck());

        }

    }

    private IEnumerator doCheck()
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
                ShootBase(u);
                baseValue = pAddNum;
                effectType = EffectType.MagicDamage;
                u.Hit(shooter, this);
                //FXHit(u);
                u.AddPassive(skillController.pBehaviours[1].passiveName, owner, skillController);
            }
        }

        yield return new WaitForSeconds(1f);

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

    public override void Release()
    {
        base.Release();

        StopAllCoroutines();
    }

}
