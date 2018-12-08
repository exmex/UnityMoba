using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000013 : NTGBattleSkillBehaviour
{
    public BoxCollider bc;
    public float pDuration;
    public ArrayList targetsInRange;
    public bool isFly;

    public override void PreShoot(NTGBattleUnitController target, float xOffset, float zOffset)
    {
        isFly = false;
        owner.transform.LookAt(new Vector3(xOffset + owner.transform.position.x, owner.transform.position.y, zOffset + owner.transform.position.z));
        base.PreShoot(target, xOffset, zOffset);
        FXEA();
        FXEB();
    }

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);
        Debug.Log(xOffset + " " + zOffset);

        targetsInRange = new ArrayList();
        startPos = owner.transform.position;
        bc.center = new Vector3(0, 0, 2.89f);
        bc.size = new Vector3(this.param[0], 0, this.range);
        bc.enabled = true;
        pDuration = this.duration;
        StartCoroutine(doCheck());
    }

    private IEnumerator doCheck()
    {


        yield return new WaitForSeconds(0.1f);
        Debug.Log(targetsInRange.Count);
        for (int i = 0;i < targetsInRange.Count;i++)
        {
            NTGBattleUnitController temp = targetsInRange[i] as NTGBattleUnitController;
            if(temp != null && temp.alive)
            {
                ShootBase(temp);
                effectType = EffectType.PhysicDamage;
                temp.Hit(owner, this);
                temp.AddPassive(skillController.pBehaviours[0].passiveName, owner, skillController);
                temp.AddPassive("Blow", shooter, p: new[] { this.param[1] });
                FXHit(temp);
            }
        }
        isFly = true;
        targetsInRange.Clear();
        yield return new WaitForSeconds(pDuration);
        Debug.Log("asdbasd" + pDuration);

        Release();

    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
        {
            return;
        }

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (isFly)
        {
            if(otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (otherUnit.mask & mask) != 0)
            {
                otherUnit.AddPassive(skillController.pBehaviours[0].passiveName, owner, skillController);
            }
        }
        else
        {
            if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (otherUnit.mask & mask) != 0)
            {
                targetsInRange.Add(otherUnit);
            }
        }
    }

    public void OnTriggerExit(Collider other)
    {
        if(owner == null)
        {
            return;
        }

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (isFly)
        {
            if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (otherUnit.mask & mask) != 0)
            {
                otherUnit.RemovePassive(skillController.pBehaviours[0].passiveName);
            }
        }
        else
        {
            if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (otherUnit.mask & mask) != 0)
            {
                for (int i = 0;i < targetsInRange.Count;i++)
                {
                    NTGBattleUnitController temp = targetsInRange[i] as NTGBattleUnitController;
                    if(temp.name == otherUnit.name)
                    {
                        targetsInRange.Remove(targetsInRange[i]);
                    }
                }
            }
        }
    }
}
