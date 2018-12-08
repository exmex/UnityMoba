using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600000101 : NTGBattlePassiveSkillBehaviour {

    private float pMDef;
    private float pPDef;
    public override void Respawn()
    {
        base.Respawn();
        pPDef = this.param[0];
        pMDef = this.param[1];
        AddBuff();
    }

    private void AddBuff()
    {
        FXEB();
        owner.baseAttrs.MDef += pMDef;
        owner.baseAttrs.PDef += pPDef;
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
            //Debugger.LogError(owner.name+"PassiveRemove");
            owner.baseAttrs.MDef -= pMDef;
            owner.baseAttrs.PDef -= pPDef;
            owner.ApplyBaseAttrs();
            //owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Slow, 0);
            Release();
        }

    }

}
