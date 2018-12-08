using UnityEngine;
using System.Collections;
using System;

public class UTGBattlePassiveSkillBehaviourR600001301 : NTGBattlePassiveSkillBehaviour
{
    public BoxCollider bc;

    public float pDuration;

    public float count;

    public ArrayList targetsInRange;

    public UTGBattleSkillControllerR60000134 sc; 

    public override void Respawn()
    {
        targetsInRange = new ArrayList();
        bc.center = new Vector3(0, 0, 2.89f);
        bc.size = new Vector3(this.param[0], 0, this.range);
        bc.enabled = true;
        pDuration = this.duration;

        FXEA();
        FXEB();
        StartCoroutine(doCheck(count));
    }

    private IEnumerator doCheck(float times = 0)
    {
        count = times;
        while(pDuration > 0)
        {
            bc.enabled = true;
            yield return new WaitForSeconds(0.1f);
            float tempFloat = (float)Math.Round((0.5f / (1 + owner.baseAttrs.AtkSpeed)), 1);
            //Debug.Log(tempFloat + " " + count % tempFloat + " " + pDuration);
            if ((count % tempFloat) == 0)
            {
 
                for (int i = 0;i < targetsInRange.Count;i++)
                {
                    NTGBattleUnitController temp = targetsInRange[i] as NTGBattleUnitController;
                    if (temp != null && temp.alive)
                    {
                        //Debug.Log("targetsInRange " + targetsInRange.Count);
                        ShootBase(temp);
                        effectType = EffectType.PhysicDamage;
                        temp.Hit(owner, this);
                        FXHit(temp);
                    }
                }
                count = 0;
            }
            
            count += 0.1f;
            pDuration -= 0.1f;
            bc.enabled = false;
        }
        bc.enabled = false;
        FXReset();
        targetsInRange.Clear();
        Release();
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);
        if(e == NTGBattlePassive.Event.Shoot)
        {
            var p = (NTGBattlePassive.EventShootParam)param;
            if(p.shooter == owner && (p.controller.type == NTGBattleSkillType.FriendlySkill || p.controller.type == NTGBattleSkillType.HostileSkill || p.controller.type == NTGBattleSkillType.PlayerSkill) && owner.alive)
            {
                bc.enabled = false;
                StopCoroutine(doCheck());
                //StartCoroutine(doDuration());
            }
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            targetsInRange.Clear();
            Release();   
        }
    }

    //private IEnumerator doDuration()
    //{
    //    yield return new WaitForSeconds(0.5f);
    //    StartCoroutine(doCheck(count));
    //}

    void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if(otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (otherUnit.mask & mask) != 0)
        {
            for (int i = 0; i < targetsInRange.Count; i++)
            {
                NTGBattleUnitController temp = targetsInRange[i] as NTGBattleUnitController;
                if (temp.name == otherUnit.name)
                {
                    targetsInRange.Remove(targetsInRange[i]);
                }
            }
            targetsInRange.Add(otherUnit);
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (owner == null)
        {
            return;
        }

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        for (int i = 0;i < targetsInRange.Count;i++)
        {
            NTGBattleUnitController temp = targetsInRange[i] as NTGBattleUnitController;
            if (temp.name == otherUnit.name)
            {
                targetsInRange.Remove(targetsInRange[i]);
            }
        }
    }

    public override bool Interrupt()
    {
        if (owner.interruptSource != NTGBattleUnitController.ShootInterruptSource.Skill)
        {
            foreach (NTGBattlePassiveSkillBehaviour passive in owner.passives)
            {
                if (passive.name == "PBehaviourR600001301")
                {
                    (passive as UTGBattlePassiveSkillBehaviourR600001301).FXReset();
                    (passive as UTGBattlePassiveSkillBehaviourR600001301).Release();
                    (passive as UTGBattlePassiveSkillBehaviourR600001301).targetsInRange.Clear();
                    break;
                }
            }
            return true;
        }

        return false;
    }

}
