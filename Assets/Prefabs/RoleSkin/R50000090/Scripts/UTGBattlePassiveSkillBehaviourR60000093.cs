using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000093 : NTGBattlePassiveSkillBehaviour
{
    public override void Respawn()
    {
        base.Respawn();

        StartCoroutine(doDamage());
    }

    private IEnumerator doDamage()
    {
        owner.Hit(shooter, this);

        yield return new WaitForSeconds(2.0f);

        Release();
    }
}