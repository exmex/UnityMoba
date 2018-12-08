using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60120100 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pPAtkRateAmount;
    public float pMAtkRateAmount;
    public float pHPRecoverAmount;
    public float pMPRecoverAmount;

    public override void Respawn()
    {
        base.Respawn();

        ShootBase(owner);

        pDuration = duration;

        pPAtkRateAmount = this.param[0];
        owner.baseAttrs.pAtkRate += pPAtkRateAmount;
        pMAtkRateAmount = this.param[0];
        owner.baseAttrs.mAtkRate += pMAtkRateAmount;
        pHPRecoverAmount = owner.baseAttrs.Hp*0.05f;
        owner.baseAttrs.HpRecover += pHPRecoverAmount;
        pMPRecoverAmount = owner.baseAttrs.Mp*0.05f;
        owner.baseAttrs.MpRecover += pMPRecoverAmount;

        owner.ApplyBaseAttrs();

        FXEA();
        FXEB();

        StartCoroutine(doBoost());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour) param;
            shooter = p.shooter;
            pDuration = p.duration;

            owner.baseAttrs.pAtkRate -= pPAtkRateAmount;
            pPAtkRateAmount = p.param[0];
            owner.baseAttrs.pAtkRate += pPAtkRateAmount;

            owner.baseAttrs.mAtkRate -= pMAtkRateAmount;
            pMAtkRateAmount = p.param[0];
            owner.baseAttrs.mAtkRate += pMAtkRateAmount;

            owner.baseAttrs.HpRecover -= pHPRecoverAmount;
            pHPRecoverAmount = owner.baseAttrs.Hp*0.05f;
            owner.baseAttrs.HpRecover += pHPRecoverAmount;

            owner.baseAttrs.MpRecover -= pMPRecoverAmount;
            pMPRecoverAmount = owner.baseAttrs.Mp*0.05f;
            owner.baseAttrs.MpRecover += pMPRecoverAmount;

            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.pAtkRate -= pPAtkRateAmount;
            owner.baseAttrs.mAtkRate -= pMAtkRateAmount;
            owner.baseAttrs.HpRecover -= pHPRecoverAmount;
            owner.baseAttrs.MpRecover -= pMPRecoverAmount;

            owner.ApplyBaseAttrs();

            Release();
        }
    }

    private IEnumerator doBoost()
    {
        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }

        owner.baseAttrs.pAtkRate -= pPAtkRateAmount;
        owner.baseAttrs.mAtkRate -= pMAtkRateAmount;
        owner.baseAttrs.HpRecover -= pHPRecoverAmount;
        owner.baseAttrs.MpRecover -= pMPRecoverAmount;

        owner.ApplyBaseAttrs();

        Release();
    }
}