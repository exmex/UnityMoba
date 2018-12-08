using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030280 : NTGBattlePassiveSkillBehaviour
{
    public float pHpAddAmount;

    public override void Respawn()
    {
        base.Respawn();

        pHpAddAmount = this.param[0];

        owner.baseAttrs.Hp += pHpAddAmount;
        owner.ApplyBaseAttrs();
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.Hp -= pHpAddAmount;
            owner.ApplyBaseAttrs();
            Release();
        }
    }
}
