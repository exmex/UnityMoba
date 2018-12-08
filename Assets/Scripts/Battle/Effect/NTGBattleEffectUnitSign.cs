using UnityEngine;
using System.Collections;

public class NTGBattleEffectUnitSign : NTGBattlePassiveSkillBehaviour
{
    private void Awake()
    {
        base.Awake();

        passiveName = "UnitSign";
    }

    public override void Respawn()
    {
        base.Respawn();

        owner.mainController.uiController.ShowUnitSign(owner);

        Release();
    }
}