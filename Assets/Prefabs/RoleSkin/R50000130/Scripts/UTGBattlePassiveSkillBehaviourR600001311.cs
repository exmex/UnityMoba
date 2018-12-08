using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600001311 : NTGBattlePassiveSkillBehaviour {

    public float pDuration;
    public float pSpeedAmount;

    public override void Respawn()
    {
        base.Respawn();

        ShootBase(owner);

        pDuration = this.duration;

        owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Slow, pDuration);

        //Debugger.LogError(this.param[0]);
        pSpeedAmount = -owner.MoveSpeed * this.param[0];
        owner.baseAttrs.MoveSpeed += pSpeedAmount;

        owner.ApplyBaseAttrs();

        FXEA();

        StartCoroutine(doPassive());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            shooter = p.shooter;
            pDuration = this.duration;

            owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Slow, pDuration);

            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
            pSpeedAmount = -owner.MoveSpeed * this.param[0];
            owner.baseAttrs.MoveSpeed += pSpeedAmount;


            owner.ApplyBaseAttrs();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed -= pSpeedAmount;

            owner.ApplyBaseAttrs();

            owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Slow, 0);

            Release();
        }
    }

    private IEnumerator doPassive()
    {
        while (pDuration > 0)
        {
            //baseValue = this.param[2] * owner.hpMax;
            //owner.Hit(shooter, this);
            //FXHit(owner);

            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }

        owner.baseAttrs.MoveSpeed -= pSpeedAmount;

        owner.ApplyBaseAttrs();

        Release();
    }
}
