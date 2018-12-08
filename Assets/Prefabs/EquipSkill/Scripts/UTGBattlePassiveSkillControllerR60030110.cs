using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030110 : NTGBattlePassiveSkillController
{
    public float pRate;

    public ArrayList targets = new ArrayList();

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;

            if (p.shooter == owner && p.behaviour.type == NTGBattleSkillType.Attack)
            {
                pRate = pBehaviours[0].param[0];
                bool isDo = IsFlushing(pRate);
                if (isDo)
                {
                    targets.Clear();
                    targets.Add(p.target);
                    p.target.AddPassive(pBehaviours[0].passiveName, owner, this);
                }
            }   
        }
    }

    private bool IsFlushing(float rate)
    {
        bool isDo = false;
        float flag = 0;

        flag = Random.Range(1, 100);
        if (flag <= 1 * rate * 100)
        {
            isDo = true;
        }
        return isDo;
    }

    public override void Release()
    {
        base.Release();

        owner.RemovePassive(pBehaviours[0].passiveName);
    }
}
