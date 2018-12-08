using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030500 : NTGBattlePassiveSkillBehaviour
{
    public float pAddMoveSpeedAmount;

    public override void Respawn()
    {
        base.Respawn();

        FXEA();
        FXEB();
        pAddMoveSpeedAmount = this.param[0];
        owner.baseAttrs.MoveSpeed += pAddMoveSpeedAmount;
        owner.ApplyBaseAttrs();
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            owner.baseAttrs.MoveSpeed -= pAddMoveSpeedAmount;
            pAddMoveSpeedAmount = p.param[0];
            owner.baseAttrs.MoveSpeed += pAddMoveSpeedAmount;
            owner.ApplyBaseAttrs();
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed -= pAddMoveSpeedAmount;
            owner.ApplyBaseAttrs();
            Release();
        }
    }
}
