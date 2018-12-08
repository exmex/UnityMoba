using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60060030 : NTGBattleSkillBehaviour {

    public float pDuration;

    public NTGBattlePassiveSkillBehaviour[] pBehaviour;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        pDuration = this.duration;

        FXEA();
        FXEB();
        FXExplode();

        //owner.Hit(owner, this);
        owner.AddPassive(pBehaviour[0].passiveName, owner, skillController);
        

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        
        yield return null;
        Release();

    }
}
