using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60120150 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pCDAmount;
    public float pMpAddAmount;

    public override void Respawn()
    {
        base.Respawn();

        ShootBase(owner);

        pDuration = duration;

        pCDAmount = this.param[0];
        owner.baseAttrs.CdReduce += pCDAmount;
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

            owner.baseAttrs.CdReduce -= pCDAmount;
            pCDAmount = p.param[0];
            owner.baseAttrs.CdReduce += pCDAmount;
            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.Death)
        {
            var p = (NTGBattlePassive.EventDeathParam) param;

            if (p.killer is NTGBattlePlayerController)
                p.killer.AddPassive(passiveName, owner);

            owner.baseAttrs.CdReduce -= pCDAmount;
            owner.ApplyBaseAttrs();

            Release();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.CdReduce -= pCDAmount;
            owner.ApplyBaseAttrs();

            Release();
        }
    }

    private IEnumerator doBoost()
    {
        while (pDuration > 0)
        {
            pMpAddAmount = owner.mpMax * this.param[2];
            effectType = EffectType.MpRecover;
            baseValue = pMpAddAmount;
            owner.Hit(shooter, this);
            FXHit(owner, keepEB: true);
            yield return new WaitForSeconds(this.param[1]);
            pDuration -= this.param[1];
        }

        owner.baseAttrs.CdReduce -= pCDAmount;
        owner.ApplyBaseAttrs();

        Release();
    }
}