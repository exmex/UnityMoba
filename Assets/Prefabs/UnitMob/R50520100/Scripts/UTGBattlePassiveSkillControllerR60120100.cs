using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillControllerR60120100 : NTGBattlePassiveSkillController
{
    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Death)
        {
            var p = (NTGBattlePassive.EventDeathParam) param;

            for (int i = 0; i < owner.mainController.battleUnits.Count; i++)
            {
                var unit = owner.mainController.battleUnits[i] as NTGBattlePlayerController;
                if (unit != null && unit.group == p.killer.group)
                {
                    unit.AddPassive(pBehaviours[0].passiveName, owner, this);
                }
            }

            for (int i = 0; i < owner.mainController.battleUnitsInActive.Count; i++)
            {
                var unit = owner.mainController.battleUnitsInActive[i] as NTGBattlePlayerController;
                if (unit != null && unit.group == p.killer.group)
                {
                    unit.AddPassive(pBehaviours[0].passiveName, owner, this);
                }
            }
        }
    }
}