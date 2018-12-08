using UnityEngine;
using System.Collections;

public class UTGBattleSkillPassiveBehaviourR600600301 : NTGBattlePassiveSkillBehaviour
{
    private float pAtkSpeedAmount;

    private float pAtkAmount;

    private float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = this.duration;

        pAtkAmount = owner.baseAttrs.PAtk * this.param[1];

        owner.baseAttrs.AtkSpeed = owner.baseAttrs.AtkSpeed + this.param[0];
        owner.baseAttrs.PAtk = owner.baseAttrs.PAtk + pAtkAmount;
        owner.ApplyBaseAttrs();

        FXEA();
        FXEB();

        StartCoroutine(doEffect());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            shooter = p.shooter;
            pDuration = p.duration;
            owner.baseAttrs.AtkSpeed -= this.param[0];
            owner.baseAttrs.AtkSpeed += p.param[0];
            owner.baseAttrs.PAtk -= pAtkAmount;
            pAtkAmount = p.param[1] * owner.baseAttrs.PAtk;
            owner.baseAttrs.PAtk += pAtkAmount;
            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.AtkSpeed -= this.param[0];
            owner.baseAttrs.PAtk = owner.baseAttrs.PAtk - pAtkAmount;
            owner.ApplyBaseAttrs();
            Release();
        }
    }

    private IEnumerator doEffect()
    {
        while (pDuration > 0) 
        {
            pDuration -= 0.1f;

            yield return new WaitForSeconds(0.1f);
        }

        owner.baseAttrs.AtkSpeed = owner.baseAttrs.AtkSpeed - this.param[0];
        owner.baseAttrs.PAtk = owner.baseAttrs.PAtk - pAtkAmount;
        owner.ApplyBaseAttrs();

        Release();

    }
}
