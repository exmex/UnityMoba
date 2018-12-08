using UnityEngine;
using System.Collections;

public class NTGBattleEffectBroken : NTGBattlePassiveSkillBehaviour
{
    private void Awake()
    {
        base.Awake();

        passiveName = "Broken";
    }

    public override void Respawn()
    {
        base.Respawn();

        FXEA();

        //(owner as NTGBattlePlayerController).roleController.DisplayBra(true);
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            FXReset();

            //(owner as NTGBattlePlayerController).roleController.DisplayBra(false);

            Release();
        }
    }
}