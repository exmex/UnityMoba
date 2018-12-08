using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030370 : NTGBattlePassiveSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour subPassive;

    public override void Respawn()
    {
        base.Respawn();

        StartCoroutine(doCheck());
    }

    private IEnumerator doCheck()
    {
        yield return null;
        if (owner.hp / owner.hpMax < this.param[0])
        {
            FXEA();
            FXEB();
            owner.AddPassive(subPassive.passiveName, owner, skillController);
            skillController.StartCD();
        }
        else
        {
            //owner.RemovePassive(subPassive.passiveName);
        }

        Release();
    }

}
