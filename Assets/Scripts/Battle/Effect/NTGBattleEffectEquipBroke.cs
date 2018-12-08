using UnityEngine;
using System.Collections;

public class NTGBattleEffectEquipBroke : NTGBattlePassiveSkillBehaviour
{
    private void Awake()
    {
        base.Awake();

        passiveName = "EquipBroke";
    }

    public override void Respawn()
    {
        base.Respawn();

        StartCoroutine(doEquipBroke());
    }

    private IEnumerator doEquipBroke()
    {
        var player = owner as NTGBattlePlayerController;

        if (player != null)
        {
            //player.EquipBroke(sp);
        }

        yield return new WaitForSeconds(2.0f);

        Release();
    }
}