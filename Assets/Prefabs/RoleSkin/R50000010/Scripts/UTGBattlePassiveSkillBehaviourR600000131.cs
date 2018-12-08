using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600000131 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;
    public float pDamage;
    public float pSpeedReduce;

    public override void Respawn()
    {
        pDuration = this.duration;
        pSpeedReduce = this.param[0];
        owner.baseAttrs.MoveSpeed -= pSpeedReduce;
        StartCoroutine(doDuration());
    }

    private IEnumerator doDuration()
    {
        while(pDuration > 0)
        {
            ShootBase(owner);
            effectType = EffectType.PhysicDamage;
            owner.Hit(shooter, this);
            FXHit(owner);
            yield return new WaitForSeconds(this.param[1]);
            pDuration -= this.param[1];
        }
        Release();
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if(e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            owner.baseAttrs.MoveSpeed += pSpeedReduce;
            pSpeedReduce = p.param[0];
            owner.baseAttrs.MoveSpeed -= pSpeedReduce;
            pDuration = p.duration;
            baseValue = p.baseValue;
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.baseAttrs.MoveSpeed += pSpeedReduce;
            Release();
        }
    }
}
