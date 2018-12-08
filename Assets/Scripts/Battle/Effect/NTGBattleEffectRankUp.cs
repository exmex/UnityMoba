using UnityEngine;
using System.Collections;

public class NTGBattleEffectRankUp : NTGBattlePassiveSkillBehaviour
{
    private void Awake()
    {
        base.Awake();

        passiveName = "RankUp";
    }

    public override void Respawn()
    {
        base.Respawn();

        StartCoroutine(doRankUp());
    }

    private IEnumerator doRankUp()
    {
        //owner.RankUp();

        //FXShoot();

        yield return new WaitForSeconds(2.0f);

        Release();
    }
}