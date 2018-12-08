using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000052 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pAtkSpeedAmount;


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
        pAtkSpeedAmount = this.param[0];
        owner.baseAttrs.AtkSpeed += pAtkSpeedAmount;
        owner.ApplyBaseAttrs();

        rac = owner.unitAnimator.runtimeAnimatorController;
        aoc.runtimeAnimatorController = rac;
        aoc["R50000050-Walk"] = walkClip;

        FXEA();
        FXEB();
        //var wFx = FXCustom(0);
        //wFx.parent = owner.unitAnchors[4];
        //wFx.localPosition = Vector3.zero;
        //wFx.localRotation = Quaternion.identity;

        StartCoroutine(doBoost());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour) param;
            shooter = p.shooter;
            pDuration = p.duration;

            owner.baseAttrs.AtkSpeed -= pAtkSpeedAmount;
            pAtkSpeedAmount = p.param[0];
            owner.baseAttrs.AtkSpeed += pAtkSpeedAmount;
            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.AtkSpeed -= pAtkSpeedAmount;
            owner.ApplyBaseAttrs();

            owner.unitAnimator.runtimeAnimatorController = rac;
            owner.unitAnimator.SetBool("walk", (owner as NTGBattlePlayerController).walking);

            Release();
        }
    }

    private IEnumerator doBoost()
    {
        owner.unitAnimator.runtimeAnimatorController = aoc;

        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }
        owner.baseAttrs.AtkSpeed -= pAtkSpeedAmount;
        owner.ApplyBaseAttrs();

        owner.unitAnimator.runtimeAnimatorController = rac;
        owner.unitAnimator.SetBool("walk", (owner as NTGBattlePlayerController).walking);

        Release();
    }
}