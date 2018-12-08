using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600300502 : NTGBattlePassiveSkillBehaviour
{
    public float pMagicShiledAmount;
    public float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = this.duration;
        pMagicShiledAmount = this.param[0] + owner.level * this.param[1];
        owner.shield += pMagicShiledAmount;

        FXEA();
        FXEB();

        StartCoroutine(doBoost());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;

        }
    }

    private IEnumerator doBoost()
    {
        while (true)
        {

        }
    }
    
}
