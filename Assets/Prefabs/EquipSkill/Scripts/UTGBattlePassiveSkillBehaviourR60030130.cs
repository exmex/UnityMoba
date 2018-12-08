using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030130 : NTGBattlePassiveSkillBehaviour
{

    public bool isAdd = false;

    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if(f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if(p.target == owner && p.shooter == this.shooter && owner.hp / owner.hpMax <= this.param[0])
            {
                value = value * (1 + this.param[1]);
            }
            isAdd = true;
        }

        return value;
    }

    public override void Respawn()
    {
        StartCoroutine(doReset());
    }

    private IEnumerator doReset()
    {
        while (!isAdd)
        {
            yield return new WaitForSeconds(0.1f);
        }
        isAdd = false;

        Release();
    }
}
