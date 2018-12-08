using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60060080 : NTGBattleSkillBehaviour
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
        //FXExplode();

        skillController.StartCD();

        var hPassive = GetComponentsInChildren<NTGBattlePassiveSkillBehaviour>();

        for (int i = 1; i < hPassive.Length; i++)
        {
            if (hPassive[i].type == NTGBattleSkillType.HostilePassive)
            {
                hPassive[i].Release();
            }
        }



        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }

        Release();

    }
    
}
