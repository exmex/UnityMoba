using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60060090 : NTGBattleSkillBehaviour
{

    public float pDuration;

    public override void Shoot(NTGBattleUnitController target, float xOffset, float zOffset)
    {
        base.Shoot(target, xOffset, zOffset);

        pDuration = this.duration;

        collider.radius = range;

        StartCoroutine(doEffect());
    }

    private IEnumerator doEffect()
    {
        FXEA();
        FXEB();
        FXExplode();

        var d = this.duration;
        var speedTemp = owner.MoveSpeed;
        owner.unitAnimator.enabled = false;
        var maskTemp = owner.mask;
        
        owner.MoveSpeed = 0; 
        owner.mask = 0;

        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);

            pDuration -= 0.1f;
        }

        owner.unitAnimator.enabled = true;
        owner.MoveSpeed = speedTemp;
        owner.mask = maskTemp;

        Release();

    }
    
}
