using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60060110 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour pBehaviour;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        StartCoroutine(doFly());
    }

    public override bool Interrupt()
    {
        owner.RemovePassive(pBehaviour.passiveName);

        Release();

        return true;
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();

        owner.AddPassive(pBehaviour.passiveName, shooter, skillController);

        yield return new WaitForSeconds(duration);

        Release();
    }
}