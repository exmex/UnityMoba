using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR600000211 : NTGBattleSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour[] pBehaviours;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        owner.AddPassive("Fast", shooter, skillController, new[] {this.param[1], this.param[0]});

        owner.AddPassive(pBehaviours[0].passiveName, shooter, skillController);

        owner.AddPassive(pBehaviours[1].passiveName, shooter, skillController);

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();

        yield return new WaitForSeconds(1.0f);

        Release();
    }
}