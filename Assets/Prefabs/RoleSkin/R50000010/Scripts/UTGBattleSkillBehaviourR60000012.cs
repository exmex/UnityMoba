using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000012 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour[] pBehaviour;

    public bool interrupted;

    public override bool Interrupt()
    {
        interrupted = true;

        return true;
    }

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        collider.radius = param[0];//技能半径

        transform.parent = owner.transform;
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.identity;

        interrupted = false;

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();

        var reachDest = false;

        collider.enabled = true;

        NavMeshHit hit;
        if (NavMesh.SamplePosition(transform.position + transform.forward * range, out hit, 0.5f, NavMesh.AllAreas))
        {
            if (owner.alive && owner.navAgent != null)
                owner.navAgent.enabled = false;

            reachDest = true;
        }

        float d = 0;
        //float t = 0;
    
        while (d < range && !interrupted)
        {
            owner.transform.Translate(0, 0, Time.deltaTime * speed);
            d += Time.deltaTime * speed;
            //t += Time.deltaTime;
         
            yield return null;
        }

        collider.enabled = false;

        if (reachDest && owner.alive && owner.navAgent != null)
            owner.navAgent.enabled = true;

        yield return new WaitForSeconds(1.0f);

        Release();
    }

    public IEnumerator OnTriggerEnter(Collider other)
    {
        if (owner == null)
            yield break;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && (mask & otherUnit.mask) != 0)
        {   //敌人
            if (otherUnit.group != owner.group )
            {
                otherUnit.Hit(shooter, this);
                FXHit(otherUnit, keepEB: true);
                otherUnit.AddPassive("Blow", shooter, p: new[] { param[1] });//击飞
                yield return new WaitForSeconds( param[1] );
                otherUnit.AddPassive(pBehaviour[0].passiveName, owner, skillController);//减速
            }
            //友方英雄
            else if (otherUnit != owner && otherUnit.group == owner.group  && otherUnit as NTGBattlePlayerController == true)
            {
                otherUnit.AddPassive(pBehaviour[1].passiveName, owner, skillController);//护盾，移速
            }
        }
        
    }

    
  

}
