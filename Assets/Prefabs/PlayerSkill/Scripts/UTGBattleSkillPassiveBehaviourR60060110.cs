using UnityEngine;
using System.Collections;

public class UTGBattleSkillPassiveBehaviourR60060110 : NTGBattlePassiveSkillBehaviour
{
    public override void Respawn()
    {
        StartCoroutine(doPassive());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Recall, 0);

            Release();
        }
        else if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam) param;
            if (p.target == owner && (p.behaviour.type == NTGBattleSkillType.Attack || p.behaviour.type == NTGBattleSkillType.HostileSkill || p.behaviour.type == NTGBattleSkillType.HostilePassive))
            {
                owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Recall, 0);

                Release();
            }
        }
    }

    private IEnumerator doPassive()
    {
        FXEA();
        FXEB();

        owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Recall, duration);

        yield return new WaitForSeconds(duration);

        owner.navAgent.enabled = false;
        var respawnPoint = owner.mainController.respawn.Find("Start/Start-" + owner.position);
        owner.transform.position = respawnPoint.position;
        owner.transform.rotation = respawnPoint.rotation;
        owner.navAgent.enabled = true;

        skillController.StartCD();

        Release();
    }
}