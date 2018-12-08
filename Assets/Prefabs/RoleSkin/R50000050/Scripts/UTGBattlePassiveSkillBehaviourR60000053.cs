using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000053 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = duration;

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
        }
        else if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam) param;
            if (p.shooter == owner && (p.behaviour.type == NTGBattleSkillType.Attack || p.behaviour.type == NTGBattleSkillType.HostileSkill))
            {
                baseValue = p.target.hpMax*this.param[0];
                p.target.Hit(owner, this);
            }
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
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

        Release();
    }
}