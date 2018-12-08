using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60040010 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour[] pBehaviour;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        FXExplode();

        lockedTarget.AddPassive(pBehaviour[0].passiveName, owner, skillController);
        lockedTarget.AddPassive(pBehaviour[1].passiveName, owner, skillController);

        //Move to last Passive
        //owner.Kill(lockedTarget);

        yield return new WaitForSeconds(2.0f);

        Release();
    }
}