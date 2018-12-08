using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030440 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pCountMax;
    public float pCount;
    public float pMoveSpeedAmount;
    public float pAtkAmount;
    public float mAtkAmount;

    public override void Respawn()
    {
        base.Respawn();

        FXEA();
        FXEB();

        pDuration = this.duration;
        pCountMax = this.param[3];
        pCount = 0;
        pMoveSpeedAmount = owner.baseAttrs.MoveSpeed * this.param[2];
        pAtkAmount = owner.baseAttrs.PAtk * this.param[0];
        mAtkAmount = owner.baseAttrs.MAtk * this.param[1];

        owner.baseAttrs.MoveSpeed += pMoveSpeedAmount;
        owner.baseAttrs.PAtk += pAtkAmount;
        owner.baseAttrs.MAtk += mAtkAmount;
        owner.ApplyBaseAttrs();

        pCount = 1;

        StartCoroutine(doCount());

    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            if(pCount < pCountMax)
            {
                pDuration = p.duration;
                owner.baseAttrs.MoveSpeed -= pMoveSpeedAmount;
                owner.baseAttrs.PAtk -= pAtkAmount;
                owner.baseAttrs.MAtk -= mAtkAmount;
                pMoveSpeedAmount += owner.baseAttrs.MoveSpeed * p.param[0];
                pAtkAmount += owner.baseAttrs.PAtk * p.param[0];
                mAtkAmount += owner.baseAttrs.MAtk * p.param[1];
                owner.baseAttrs.MoveSpeed += pMoveSpeedAmount;
                owner.baseAttrs.PAtk += pAtkAmount;
                owner.baseAttrs.MAtk += mAtkAmount;
                owner.ApplyBaseAttrs();
                pCount++;
            }
            else
            {
                pDuration = p.duration;
            }
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed -= pMoveSpeedAmount;
            owner.baseAttrs.PAtk -= pAtkAmount;
            owner.baseAttrs.MAtk -= mAtkAmount;
            owner.ApplyBaseAttrs();
            Release();
        }

    }



    private IEnumerator doCount()
    {
        while(pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }

        owner.baseAttrs.MoveSpeed -= pMoveSpeedAmount;
        owner.baseAttrs.PAtk -= pAtkAmount;
        owner.baseAttrs.MAtk -= mAtkAmount;
        owner.ApplyBaseAttrs();

        Release();
    }
}
