using UnityEngine;
using System.Collections;

public class UTGBattleEffectFast : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pSpeedAmount;

    private void Awake()
    {
        base.Awake();

        passiveName = "Fast";
    }

    public override void Respawn()
    {
        base.Respawn();

        pDuration = this.p[0];
        pSpeedAmount = owner.baseAttrs.MoveSpeed*this.p[1];
        owner.baseAttrs.MoveSpeed += pSpeedAmount;
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
            pDuration = p.p[0];

            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
            pSpeedAmount = owner.baseAttrs.MoveSpeed*p.p[1];
            owner.baseAttrs.MoveSpeed += pSpeedAmount;
            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
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
        owner.baseAttrs.MoveSpeed -= pSpeedAmount;
        owner.ApplyBaseAttrs();

        Release();
    }
}