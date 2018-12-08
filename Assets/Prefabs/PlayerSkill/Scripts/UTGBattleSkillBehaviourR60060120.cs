using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60060120 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour[] pBehaviour;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        FXEA();
        FXEB();
        FXExplode();

        owner.AddPassive(pBehaviour[0].passiveName, owner, skillController);
        owner.AddPassive(pBehaviour[1].passiveName, owner, skillController);

        StartCoroutine(doEffect());
    }

    private IEnumerator doEffect()
    {
        yield return new WaitForSeconds(2.0f);
        Release();
    }
}