using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030070 : NTGBattlePassiveSkillController
{

    //void Start()
    //{
    //    owner.AddPassive(pBehaviours[0].passiveName, owner, this);
    //}

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.Hit)
        {
                var p = (NTGBattlePassive.EventHitParam)param;

                if (p.target == owner && this.inCd <= 0 && p.damage > owner.hp)
                {
                    owner.hp += p.damage;
                    owner.AddPassive(pBehaviours[0].passiveName, owner, this);
                }
        }
    }

    public override void Release()
    {
        base.Release();

        owner.RemovePassive(pBehaviours[0].passiveName);
    }
}
