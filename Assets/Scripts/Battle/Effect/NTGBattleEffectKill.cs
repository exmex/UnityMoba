using UnityEngine;
using System.Collections;

public class NTGBattleEffectKill : NTGBattlePassiveSkillBehaviour
{
    public NTGBattleUnitController killer;

    private void Awake()
    {
        base.Awake();

        passiveName = "Kill";
    }

    public override void Respawn()
    {
        base.Respawn();

        killer = shooter;

        owner.Kill(killer);

        Release();
    }
}