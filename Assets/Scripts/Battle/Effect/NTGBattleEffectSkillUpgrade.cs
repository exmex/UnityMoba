using System;
using UnityEngine;
using System.Collections;

public class NTGBattleEffectSkillUpgrade : NTGBattlePassiveSkillBehaviour
{
    private void Awake()
    {
        base.Awake();

        passiveName = "SkillUpgrade";
    }

    public override void Respawn()
    {
        base.Respawn();

        (owner as NTGBattlePlayerController).SkillUpgradeById(Convert.ToInt32(sp[0]));

        Release();
    }
}