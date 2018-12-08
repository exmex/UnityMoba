using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000123 : NTGBattlePassiveSkillBehaviour
{
    public override void Respawn()
    {
        base.Respawn();

        FXEA();
        FXEB();

        owner.Hit(shooter, this);
        FXHit(owner);
    }
}