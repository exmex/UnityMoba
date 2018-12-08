using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000033 : NTGBattlePassiveSkillBehaviour
{
    public override void Respawn()
    {
        base.Respawn();

        StartCoroutine(doDamage());
    }

    private IEnumerator doDamage()
    {
        baseValue = (owner.hpMax - owner.hp)*param[0];

        owner.Hit(shooter, this);

        yield return new WaitForSeconds(2.0f);

        Release();
    }
}