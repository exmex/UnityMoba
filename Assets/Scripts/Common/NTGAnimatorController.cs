using System.Collections.Generic;
using UnityEngine;
using System.Collections;

public class NTGAnimatorController : MonoBehaviour
{
    public Animator animator;
    public RuntimeAnimatorController commonAC;
    public AnimatorOverrideController commonAoc;
    public string clipPrefix;

    private string[] AnimationStateNames = {"Idle", "Standby", "Hurt", "Reload", "Victory", "Dead", "Attack", "Forward"};

    private Dictionary<NTGBattleUnitController.UnitStatus, string> AnimationEffectNames = new Dictionary<NTGBattleUnitController.UnitStatus, string>
    {
        {NTGBattleUnitController.UnitStatus.Knock, "Knock"},
        {NTGBattleUnitController.UnitStatus.Stun, "Stun"},
        {NTGBattleUnitController.UnitStatus.Blow, "Blow"},
    };

    public Dictionary<NTGBattleUnitController.UnitStatus, AnimationClip> AnimationEffectClips = new Dictionary<NTGBattleUnitController.UnitStatus, AnimationClip>();

    private void Awake()
    {
        commonAC = Resources.Load<RuntimeAnimatorController>("NTGCommonAC");
    }

    private void Start()
    {
        if (animator == null)
        {
            Init();
        }
    }

    public void Init()
    {
        animator = GetComponent<Animator>();

        animator.applyRootMotion = false;
        animator.cullingMode = AnimatorCullingMode.CullUpdateTransforms;

        commonAoc = new AnimatorOverrideController();
        commonAoc.name = "OverrideAC";
        commonAoc.runtimeAnimatorController = commonAC;

        if (clipPrefix == "")
        {
            clipPrefix = animator.gameObject.name;
        }

        foreach (var s in AnimationStateNames)
        {
            var clip = Resources.Load<AnimationClip>(clipPrefix + "-" + s);
            if (clip != null)
            {
                commonAoc["Common-" + s] = clip;
            }
        }

        foreach (var name in AnimationEffectNames)
        {
            AnimationEffectClips[name.Key] = Resources.Load<AnimationClip>(clipPrefix + "-" + name.Value);
        }

        animator.runtimeAnimatorController = commonAoc;
    }

    public void SetBattleEffect(NTGBattleUnitController.UnitStatus effect, bool inEffect)
    {
        if (animator == null)
            return;

        if (AnimationEffectClips.ContainsKey(effect) && AnimationEffectClips[effect] != null)
        {
            commonAoc["Common-Effect"] = AnimationEffectClips[effect];

            animator.runtimeAnimatorController = null;
            animator.runtimeAnimatorController = commonAoc;

            animator.SetBool("effect", inEffect);
        }
    }

    public void SetIdle(bool idle)
    {
        if (animator == null)
            return;

        if (commonAoc["Common-Idle"].name != "Common-Idle")
        {
            animator.SetBool("idle", idle);
        }
        else
        {
            animator.SetBool("idle", false);
        }
    }

    public void SetWalking(bool walking)
    {
        if (animator == null)
            return;

        if (commonAoc["Common-Forward"].name != "Common-Forward")
            animator.SetBool("walking", walking);
    }

    public void TriggerShoot()
    {
        if (animator == null)
            return;

        if (commonAoc["Common-Attack"].name != "Common-Attack")
            animator.SetTrigger("shoot");
    }

    public void TriggerHurt()
    {
        if (animator == null)
            return;

        if (commonAoc["Common-Hurt"].name != "Common-Hurt")
            animator.SetTrigger("hurt");
    }

    public void SetReload(bool inReload)
    {
        if (animator == null)
            return;

        if (commonAoc["Common-Reload"].name != "Common-Reload")
            animator.SetBool("reload", inReload);
    }

    public void SetDead(bool dead)
    {
        if (animator == null)
            return;

        if (commonAoc["Common-Dead"].name != "Common-Dead")
            animator.SetBool("dead", dead);
    }

    public void TriggerVictory()
    {
        if (animator == null)
            return;

        if (commonAoc["Common-Victory"].name != "Common-Victory")
            animator.SetTrigger("victory");
    }

    public Dictionary<string, AnimationClip> SkillAnimationClips = new Dictionary<string, AnimationClip>();

    public void TriggerSkill(string skillAnimResource, float speed)
    {
        if (animator == null)
            return;

        if (!SkillAnimationClips.ContainsKey(skillAnimResource))
        {
            SkillAnimationClips[skillAnimResource] = Resources.Load<AnimationClip>(clipPrefix + "-Skill-" + skillAnimResource);
        }

        if (SkillAnimationClips[skillAnimResource] == null)
        {
            commonAoc["Common-Skill"] = commonAoc["Common-Attack"];
        }
        else
        {
            commonAoc["Common-Skill"] = SkillAnimationClips[skillAnimResource];
        }

        animator.runtimeAnimatorController = null;
        animator.runtimeAnimatorController = commonAoc;

        animator.SetFloat("skillspeed", speed);
        animator.SetTrigger("skill");
    }
}