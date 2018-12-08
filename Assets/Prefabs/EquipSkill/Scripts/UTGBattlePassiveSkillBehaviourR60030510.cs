using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60030510 : NTGBattlePassiveSkillBehaviour
{

    public float pDamage;

    public override float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        if(f == NTGBattlePassive.Filter.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if(owner.group == 3 && p.target == owner && p.shooter == shooter)
            {
                pDamage = value * (1 + this.param[0]);
                StartCoroutine(doCount());
                return pDamage;
            }
        }
        return value;
    }

    private IEnumerator doCount()
    {
        yield return null;
        Release();
    }
}
