using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR601201402 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pSpeedAmount;

    public override void Respawn()
    {
        base.Respawn();

        ShootBase(owner);

        pDuration = this.duration;

        pSpeedAmount = -owner.MoveSpeed*this.param[0];
        owner.baseAttrs.MoveSpeed += pSpeedAmount;
        owner.ApplyBaseAttrs();
        owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Slow, pDuration);

        FXEA();
        FXEB();

        StartCoroutine(doPassive());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour) param;
            shooter = p.shooter;
            pDuration = this.duration;

            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
            pSpeedAmount = -owner.MoveSpeed*p.param[0];
            owner.baseAttrs.MoveSpeed += pSpeedAmount;
            owner.ApplyBaseAttrs();
            owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Slow, pDuration);
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
            baseValue = Random.Range(this.param[1], this.param[2]);
            owner.Hit(shooter, this);
            //FXHit(owner);
            yield return new WaitForSeconds(this.param[3]);
            pDuration -= this.param[3];
        }

        owner.baseAttrs.MoveSpeed -= pSpeedAmount;
        owner.ApplyBaseAttrs();

        Release();
    }
}