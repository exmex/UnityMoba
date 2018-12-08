using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030430 : NTGBattlePassiveSkillBehaviour
{
    public float pCd;
    public int pMaskAmount;
    public NTGBattleUnitViewController viewController;
    public bool flag = true;

    public override void Respawn()
    {
        base.Respawn();
        viewController = owner.viewController;
        StartCoroutine(doCd());
        pCd = this.param[0];
        
    }

    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if (f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if (value > owner.hp && p.target == owner && p.shooter.group != owner.group && skillController.inCd <= 0)
            {
                owner.hp = 1;
                StartCoroutine(doCount());
                skillController.StartCD();
                StartCoroutine(doCd());
                return 0;
            }
        }
        return value;
    }

    private IEnumerator doCount()
    {
        flag = false;
        FXExplode();
        owner.GetComponent<NTGBattlePlayerController>().unitAnimator.SetBool("dead", true);
        pMaskAmount = owner.mask;
        //Debug.Log(owner.mask + " + " + pCd);
        owner.mask = 0;
        owner.MoveableCount++;
        for (int i = 1; i < owner.GroupLockableCount.Length;i++)
        {
            owner.GroupLockableCount[i]++;
        }
        yield return new WaitForSeconds(pCd);
        owner.GetComponent<NTGBattlePlayerController>().unitAnimator.SetBool("dead", false);
        owner.mask = pMaskAmount;
        owner.hp = owner.hpMax * this.param[1];
        owner.mp = owner.mpMax * this.param[2];
        owner.MoveableCount--;
        for (int i = 1; i < owner.GroupLockableCount.Length; i++)
        {
            owner.GroupLockableCount[i]--;
        }
        FXHit(owner);
        flag = true;
    }

    private IEnumerator doCd()
    {
        while(skillController.inCd > 0)
        {
            yield return new WaitForSeconds(1f);
        }
        FXEA();
        FXEB();
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            if (!flag)
            {
                owner.GetComponent<NTGBattlePlayerController>().unitAnimator.SetBool("dead", false);
                owner.mask = pMaskAmount;
                owner.hp = owner.hpMax * this.param[1];
                owner.mp = owner.mpMax * this.param[2];
                owner.MoveableCount--;
                for (int i = 1; i < owner.GroupLockableCount.Length; i++)
                {
                    owner.GroupLockableCount[i]--;
                }
            }
            FXExplode();
            Release();
        }
    }
}
