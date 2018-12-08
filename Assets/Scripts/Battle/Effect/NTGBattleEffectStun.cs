using UnityEngine;
using System.Collections;

public class NTGBattleEffectStun : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;

    private void Awake()
    {
        base.Awake();

        passiveName = "Stun";
    }

    public override void Respawn()
    {
        base.Respawn();

        pDuration = p[0]*(1.0f - owner.tough);

        FXEA();
        FXEB();

        skillFX.position = owner.unitUiAnchor.position;
        skillFX.rotation = owner.unitUiAnchor.rotation;

        StartCoroutine(doStun());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour) param;
            shooter = p.shooter;
            pDuration = p.p[0]*(1.0f - owner.tough);
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.SetStatus(NTGBattleUnitController.UnitStatus.Stun, false);

            owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Stun, 0);

            Release();
        }
    }

    private IEnumerator doStun()
    {
        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, false);
        owner.interruptSource = NTGBattleUnitController.ShootInterruptSource.Stun;

        owner.SetStatus(NTGBattleUnitController.UnitStatus.Stun, true);
        owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Stun, pDuration);

        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }

        owner.SetStatus(NTGBattleUnitController.UnitStatus.Stun, false);

        Release();
    }
}