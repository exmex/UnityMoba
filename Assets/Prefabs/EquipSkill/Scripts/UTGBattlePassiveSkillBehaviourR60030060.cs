using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030060 : NTGBattlePassiveSkillBehaviour
{
    public float mDamage;

    public override void Respawn()
    {
        base.Respawn();
        mDamage = 0;

        if (owner != null)
        {
            mDamage = owner.hp * this.param[0];

            //Debug.Log("破败 " + owner.hp + " " + mDamage);
            if (mDamage < 0)
            {
                mDamage = 0;
            }
        }

        if (owner.group == 3)
        {
            if (mDamage > 80)
            {
                mDamage = 80;
            }
        }

        ShootBase(owner);
        baseValue = mDamage;
        effectType = EffectType.PhysicDamage;
        owner.Hit(shooter, this);
        FXHit(owner);


        Release();
    }
}
