using UnityEngine;
using System.Collections;

public class NTGBattleEffectEquipRepair : NTGBattlePassiveSkillBehaviour
{
    public int equipId;

    private void Awake()
    {
        base.Awake();

        passiveName = "EquipRepair";
    }

    public override void Respawn()
    {
        base.Respawn();

        equipId = int.Parse(sp[0]);

        StartCoroutine(doRepair());
    }

    private IEnumerator doRepair()
    {
        var player = owner as NTGBattlePlayerController;

        if (player != null)
        {
            //player.EquipRepair(equipId);
        }

        yield return new WaitForSeconds(2.0f);

        Release();
    }
}