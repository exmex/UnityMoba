using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600302001 : NTGBattlePassiveSkillBehaviour
{
    public NTGBattlePassiveSkillBehaviour pb2;

    public override void Respawn()
    {
        base.Respawn();

        StartCoroutine(doCheck());
    }
    
    private IEnumerator doCheck()
    {
        yield return new WaitForSeconds(0.1f);
        if (owner.hp / owner.hpMax < this.param[0] && skillController.inCd <= 0)
        {
            owner.AddPassive(pb2.passiveName, owner, skillController);

            skillController.StartCD();
        }

        Release();
    }
}
