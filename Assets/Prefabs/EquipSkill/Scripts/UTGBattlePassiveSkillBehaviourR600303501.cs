using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600303501 : NTGBattlePassiveSkillBehaviour
{
    public float pAddPdefBaseAmount;
    public float pAddMdefBaseAmount;
    public float pAddPdefAmount;
    public float pAddMdefAmount;
    public float pAddPdefTotal;
    public float pAddMdefTotal;
    private float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        //Debug.Log(this.param.Length);

        pAddPdefBaseAmount = this.param[0];
        pAddMdefBaseAmount = this.param[1];
        pAddPdefAmount = this.param[2];
        pAddMdefAmount = this.param[3];

        pAddPdefTotal = pAddPdefBaseAmount + shooter.level * pAddPdefAmount;
        pAddMdefTotal = pAddMdefBaseAmount + shooter.level * pAddMdefAmount;

        owner.baseAttrs.PDef += pAddPdefTotal;
        owner.baseAttrs.MDef += pAddMdefTotal;

        pDuration = 1;

        owner.ApplyBaseAttrs();

        StartCoroutine(doDuration());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
                owner.baseAttrs.PDef -= pAddPdefTotal;
                owner.baseAttrs.MDef -= pAddMdefTotal;
                pAddPdefBaseAmount = p.param[0];
                pAddMdefBaseAmount = p.param[1];
                pAddPdefAmount = p.param[2];
                pAddMdefAmount = p.param[3];

                pAddPdefTotal = pAddPdefBaseAmount + p.shooter.level * pAddPdefAmount;
                pAddMdefTotal = pAddMdefBaseAmount + p.shooter.level * pAddMdefAmount;

                owner.baseAttrs.PDef += pAddPdefTotal;
                owner.baseAttrs.MDef += pAddMdefTotal;

                pDuration = 1;

                owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.PDef -= pAddPdefTotal;
            owner.baseAttrs.MDef -= pAddMdefTotal;
            owner.ApplyBaseAttrs();
            Release();
        }
    }


    private IEnumerator doDuration()
    {
        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }
        owner.baseAttrs.PDef -= pAddPdefTotal;
        owner.baseAttrs.MDef -= pAddMdefTotal;
        owner.ApplyBaseAttrs();
        Release();

    }

}
