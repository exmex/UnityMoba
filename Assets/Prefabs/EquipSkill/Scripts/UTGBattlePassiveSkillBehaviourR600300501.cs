using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600300501 : NTGBattlePassiveSkillBehaviour
{
    public float pHpLimited;
    public NTGBattlePassiveSkillBehaviour[] pBehaviours;

    private void Awake()
    {
        base.Awake();

        StartCoroutine(doCalHpPercent());
    }

    private IEnumerator doCalHpPercent()
    {
        pHpLimited = this.param[0];

        while(true)
        {
            if (skillController.inCd <= 0)
            {
                if ((owner.hp / owner.hpMax) < pHpLimited)
                {
                    for (int i = 1; i < pBehaviours.Length; i++)
                    {
                        owner.AddPassive(pBehaviours[i].passiveName, owner, skillController);
                    }

                }
            }
            skillController.StartCD();
            yield return new WaitForSeconds(0.1f);
        }
    }
}
