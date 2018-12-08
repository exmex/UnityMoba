using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030270 : NTGBattlePassiveSkillBehaviour
{
    public float pMatkAddAmount;
    public float pHpMaxAddAmount;
    public float pCountMax;
    public float pCount;
    public float pCd;

    public override void Respawn()
    {
        base.Respawn();

        pCd = this.param[0];
        //pCd = 5;
        pMatkAddAmount = this.param[1];
        pHpMaxAddAmount = this.param[2];
        pCountMax = this.param[3];
        pCount = 0;

        StartCoroutine(doEffect());
    }

    private IEnumerator doEffect()
    {
        while(pCount < pCountMax)
        {
            pCount++;
            owner.baseAttrs.MAtk += pMatkAddAmount;
            owner.baseAttrs.Hp += pHpMaxAddAmount;
            owner.ApplyBaseAttrs();
            yield return new WaitForSeconds(pCd);
        }
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            float reduceMatk = pMatkAddAmount * pCount;
            float reduceHp = pHpMaxAddAmount * pCount;
            pCount = 0;
            //Debug.Log(owner.baseAttrs.MAtk + " " + reduceMatk);
            owner.baseAttrs.MAtk -= reduceMatk;
            owner.baseAttrs.Hp -= reduceHp;
            //Debug.Log(owner.baseAttrs.MAtk);
            owner.ApplyBaseAttrs();
            Release();
        }
    }


}
