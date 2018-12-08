using UnityEngine;
using System.Collections;

public class UTGBattleSkillPassvieBehaviourR600400101 : NTGBattlePassiveSkillBehaviour
{
    public override void Respawn()
    {
        base.Respawn();

        StartCoroutine(doRecover());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam) param;
            if (p.target == owner && (p.behaviour.type == NTGBattleSkillType.Attack || p.behaviour.type == NTGBattleSkillType.HostileSkill))
            {
                owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Recover, 0);

                Release();
            }
        }
    }

    private IEnumerator doRecover()
    {
        FXEB();

        owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Recover, duration);

        var d = duration;
        while (d > 0)
        {
            baseValue = this.param[0];
            effectType = EffectType.HpRecover;
            owner.Hit(shooter, this);

            yield return new WaitForSeconds(this.param[1]);
            d -= this.param[1];
        }

        Release();
    }
}