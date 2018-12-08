using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000143 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pSpeedAmount;
    public float pMDefAmount;

    public override void Respawn()
    {
        base.Respawn();

        ShootBase(owner);

        pDuration = this.duration;

        owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Slow, pDuration);

        pSpeedAmount = -owner.MoveSpeed*this.param[0];
        owner.baseAttrs.MoveSpeed += pSpeedAmount;

        pMDefAmount = -owner.mDef*this.param[1];
        owner.baseAttrs.MDef += pMDefAmount;

        owner.ApplyBaseAttrs();

        FXEA();

        StartCoroutine(doPassive());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour) param;
            shooter = p.shooter;
            pDuration = this.duration;

            owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Slow, pDuration);

            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
            pSpeedAmount = -owner.MoveSpeed*this.param[0];
            owner.baseAttrs.MoveSpeed += pSpeedAmount;

            owner.baseAttrs.MDef -= pMDefAmount;
            pMDefAmount = -owner.mDef*this.param[1];
            owner.baseAttrs.MDef += pMDefAmount;

            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
            owner.baseAttrs.MDef -= pMDefAmount;

            owner.ApplyBaseAttrs();

            owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Slow, 0);

            Release();
        }
    }

    private IEnumerator doPassive()
    {
        while (pDuration > 0)
        {
            baseValue = this.param[2]*owner.hpMax;
            owner.Hit(shooter, this);
            FXHit(owner);
            yield return new WaitForSeconds(this.param[3]);
            pDuration -= this.param[3];
        }

        owner.baseAttrs.MoveSpeed -= pSpeedAmount;
        owner.baseAttrs.MDef -= pMDefAmount;

        owner.ApplyBaseAttrs();

        Release();
    }
}