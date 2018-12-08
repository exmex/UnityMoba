using UnityEngine;
using System.Collections;

public class NTGBattlePassiveEquipChange : NTGBattlePassiveSkillBehaviour
{
    private void Awake()
    {
        base.Awake();

        passiveName = "EquipChange";
    }

    public override void Respawn()
    {
        base.Respawn();

        if (sp[0] == "Add")
        {
            (owner as NTGBattlePlayerController).AddEquip(sp[1]);
        }
        else if (sp[0] == "Remove")
        {
            (owner as NTGBattlePlayerController).RemoveEquip(sp[1]);
        }

        Release();
    }
}