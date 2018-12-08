using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000030 : NTGBattlePassiveSkillBehaviour
{
    public override void Respawn()
    {
        base.Respawn();

        FXEA();
        FXEB();

        StartCoroutine(doBoost());
    }

    private IEnumerator doBoost()
    {
        yield return new WaitForSeconds(this.param[0]);

        while (owner.alive)
        {
            if (owner.hp < owner.hpMax)
            {
                baseValue = owner.hpMax*this.param[1];
                owner.Hit(shooter, this);
            }

            yield return new WaitForSeconds(this.param[0]);
        }

        Release();
    }
}