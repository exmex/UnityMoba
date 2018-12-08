using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030530 : NTGBattlePassiveSkillBehaviour
{
    public float pExpAddAmount;

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);
        if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if (p.target.group == 3 && p.shooter == owner && p.damage > p.target.hp)
            {
                pExpAddAmount = (p.target as NTGBattleMobController).giveExp * (this.param[0]);
                (owner as NTGBattlePlayerController).AddExp(pExpAddAmount);
            }
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            Release();
        }
    }


}
