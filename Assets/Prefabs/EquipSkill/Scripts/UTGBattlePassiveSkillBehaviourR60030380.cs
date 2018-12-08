using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030380 : NTGBattlePassiveSkillBehaviour
{
    public float pCd;
    public float pDuration;
    public float hpAddAmount;

    public override void Respawn()
    {
        base.Respawn();

        pCd = this.param[0];
        pDuration = this.duration;

        StartCoroutine(doRecover());
    }

    private IEnumerator doRecover()
    {
        owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Recover, duration);

        while(pDuration > 0)
        {
            pDuration -= pCd;
            effectType = EffectType.HpRecover;
            owner.Hit(shooter, this);
            yield return new WaitForSeconds(pCd);
        }

        Release();
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if(e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            pDuration = p.duration;
            pCd = p.param[0];
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            Release();
        }
    }
}
