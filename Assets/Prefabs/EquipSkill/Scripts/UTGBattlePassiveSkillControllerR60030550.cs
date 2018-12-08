using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60030550 : NTGBattlePassiveSkillController
{
    void Awake()
    {
        owner.AddPassive(pBehaviours[0].passiveName, owner, this);
    }

    public override void Release()
    {
        base.Release();

        owner.RemovePassive(pBehaviours[0].passiveName);
    }
}
