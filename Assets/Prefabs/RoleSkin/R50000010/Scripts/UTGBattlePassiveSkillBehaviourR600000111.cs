using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600000111 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    private float pPAmount;
    private float pMAmount;

    public override void Respawn()
    {
        base.Respawn();
        pDuration = this.duration;
        pPAmount = -owner.pAtk * this.param[0];
        pMAmount = -owner.mAtk * this.param[1];
        AddBuff();
        StartCoroutine(doPassive());
    }

    private void AddBuff()
    {
        owner.baseAttrs.PAtk += pPAmount;
        owner.baseAttrs.MAtk += pMAmount;
        owner.ApplyBaseAttrs();
        FXEA();
        FXEB();
    }
    private void RemoveBuff()
    {
        owner.baseAttrs.PAtk -= pPAmount;
        owner.baseAttrs.MAtk -= pMAmount;
        owner.ApplyBaseAttrs();
    }
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            /*
            var p = (NTGBattlePassiveSkillBehaviour)param;
            shooter = p.shooter;
            pDuration = this.duration;

            owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Slow, pDuration);

            owner.baseAttrs.MoveSpeed -= pSpeedAmount;
            pSpeedAmount = -owner.MoveSpeed * this.param[0];
            owner.baseAttrs.MoveSpeed += pSpeedAmount;


            owner.ApplyBaseAttrs();
             */
            AddBuff();
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            RemoveBuff();
            //owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Slow, 0);
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
        RemoveBuff();
        Release();
    }

}
