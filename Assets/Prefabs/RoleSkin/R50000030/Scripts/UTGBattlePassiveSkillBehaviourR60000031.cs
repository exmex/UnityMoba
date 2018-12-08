using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000031 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pSpeedAmount;
    public float pShieldAmount;

    public RuntimeAnimatorController rac;
    public AnimatorOverrideController aoc;
    public AnimationClip walkClip;

    private void Awake()
    {
        base.Awake();

        aoc = new AnimatorOverrideController();
    }

    public override void Respawn()
    {
        base.Respawn();

        pDuration = duration;
        pSpeedAmount = owner.baseAttrs.MoveSpeed*this.param[0];
        owner.baseAttrs.MoveSpeed += pSpeedAmount;
        owner.ApplyBaseAttrs();

        pShieldAmount = baseValue + pAdd*shooter.pAtk + mAdd*shooter.mAtk + hpAdd*shooter.hpMax + mpAdd*shooter.mpMax;
        owner.shield += pShieldAmount;

        rac = owner.unitAnimator.runtimeAnimatorController;
        aoc.runtimeAnimatorController = rac;
        aoc["R50000030-Walk"] = walkClip;

        FXEA();
        FXEB();
        var wFx = FXCustom(0);
        wFx.parent = owner.unitAnchors[4];
        wFx.localPosition = Vector3.zero;
        wFx.localRotation = Quaternion.identity;

        StartCoroutine(doBoost());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour) param;
            shooter = p.shooter;
            pDuration = p.duration;
            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
            pSpeedAmount = owner.baseAttrs.MoveSpeed*p.param[0];
            owner.baseAttrs.MoveSpeed += pSpeedAmount;
            owner.ApplyBaseAttrs();

            owner.shield -= pShieldAmount;
            pShieldAmount = baseValue + pAdd*shooter.pAtk + mAdd*shooter.mAtk + hpAdd*shooter.hpMax + mpAdd*shooter.mpMax;
            owner.shield += pShieldAmount;
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
            owner.ApplyBaseAttrs();

            owner.shield -= pShieldAmount;

            owner.unitAnimator.runtimeAnimatorController = rac;
            owner.unitAnimator.SetBool("walk", (owner as NTGBattlePlayerController).walking);

            Release();
        }
    }

    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if (f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam) param;
            if (p.target == owner && (p.behaviour.type == NTGBattleSkillType.Attack || p.behaviour.type == NTGBattleSkillType.HostileSkill || p.behaviour.type == NTGBattleSkillType.HostilePassive))
            {
                if (value < pShieldAmount)
                {
                    owner.shield -= pShieldAmount;
                    pShieldAmount -= value;
                    owner.shield += pShieldAmount;

                    return 0;
                }
                else
                {
                    owner.shield -= pShieldAmount;
                    pShieldAmount = 0;
                    owner.shield += pShieldAmount;

                    return value - pShieldAmount;
                }
            }
        }

        return value;
    }


    private IEnumerator doBoost()
    {
        owner.unitAnimator.runtimeAnimatorController = aoc;

        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }
        owner.baseAttrs.MoveSpeed -= pSpeedAmount;
        owner.ApplyBaseAttrs();

        owner.shield -= pShieldAmount;

        owner.unitAnimator.runtimeAnimatorController = rac;
        owner.unitAnimator.SetBool("walk", (owner as NTGBattlePlayerController).walking);

        Release();
    }
}