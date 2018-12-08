using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030550 : NTGBattlePassiveSkillBehaviour
{
    public float pAddMatkAmount;
    public float pAddHpAmount;
    public float pAddAtkSpeedAmount;
    public float pCountMax;
    public float pCount;

    public override void Respawn()
    {
        base.Respawn();
        pAddMatkAmount = 0;
        pAddHpAmount = 0;
        pAddAtkSpeedAmount = 0;
        pCount = 0;
        pCountMax = this.param[1];
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if(e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if(p.target.group == 3 && p.shooter == owner && p.damage > p.target.hp && pCount < pCountMax)
            {
                owner.baseAttrs.MAtk -= pAddMatkAmount;
                pAddMatkAmount += this.param[0];
                owner.baseAttrs.MAtk += pAddMatkAmount;
                pCount++;
                owner.ApplyBaseAttrs();
            }
        }
    }

    public override void Release()
    {
        base.Release();

        owner.baseAttrs.MAtk -= pAddMatkAmount;
        pCount = 0;
        owner.ApplyBaseAttrs();

    }

}
