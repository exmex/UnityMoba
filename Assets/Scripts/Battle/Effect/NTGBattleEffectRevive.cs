using UnityEngine;
using System.Collections;

public class NTGBattleEffectRevive : NTGBattlePassiveSkillBehaviour
{
    private void Awake()
    {
        base.Awake();

        passiveName = "Revive";
    }

    public override void Respawn()
    {
        base.Respawn();

        owner.Revive(owner);

        Release();
    }
}