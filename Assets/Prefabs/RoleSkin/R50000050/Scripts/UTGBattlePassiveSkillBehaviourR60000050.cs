using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000050 : NTGBattlePassiveSkillBehaviour
{
    public float pAmount;
    public float pCount;

    public override void Respawn()
    {
        base.Respawn();

        pCount = 1;
        pAmount = this.param[1];
        owner.baseAttrs.PAtk += pAmount;
        owner.ApplyBaseAttrs();

        FXEA();
        FXEB();
        var wFx = FXCustom(0);
        wFx.parent = owner.unitAnchors[4];
        wFx.localPosition = Vector3.zero;
        wFx.localRotation = Quaternion.identity;
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour) param;
            shooter = p.shooter;

            if (pCount < p.param[0])
            {
                owner.baseAttrs.PAtk -= pAmount;
                pCount++;
                pAmount += p.param[1];
                owner.baseAttrs.PAtk += pAmount;
                owner.ApplyBaseAttrs();
            }
        }
    }
}