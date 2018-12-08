using UnityEngine;
using System.Collections;

public class NTGBattleEffectBlow : NTGBattlePassiveSkillBehaviour
{
    public float blowHeight;
    public float upRatio;
    public float downRatio;

    public float pFullDuration;
    public float pDuration;

    private void Awake()
    {
        base.Awake();

        passiveName = "Blow";
    }

    public override void Respawn()
    {
        base.Respawn();

        startPos = owner.transform.position;

        pDuration = p[0];
        pFullDuration = p[0];

        StartCoroutine(doBlow());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour) param;
            shooter = p.shooter;
            pDuration = p.p[0];
            pFullDuration = p.p[0];
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.transform.position = startPos;//
            owner.SetStatus(NTGBattleUnitController.UnitStatus.Blow, false);

            owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Blow, 0);

            Release();
        }
    }

    private IEnumerator doBlow()
    {
        FXEB();

        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, false);
        owner.interruptSource = NTGBattleUnitController.ShootInterruptSource.Blow;

        owner.SetStatus(NTGBattleUnitController.UnitStatus.Blow, true);

        skillFX.position = owner.unitUiAnchor.position;
        skillFX.rotation = owner.unitUiAnchor.rotation;

        owner.mainController.uiController.SetUnitState(owner, NTGBattleUIController.UnitStateType.Blow, pDuration);

        if (owner.alive && owner.navAgent != null)
            owner.navAgent.enabled = false;

        while (pDuration > 0)
        {
            yield return null;
            var upSpeed = blowHeight/(pFullDuration*upRatio);
            var downSpeed = blowHeight/(pFullDuration*downRatio);
            if (pDuration > pFullDuration*(1 - upRatio) && owner.transform.position.y - startPos.y < blowHeight)
            {
                owner.transform.Translate(0, upSpeed*Time.deltaTime, 0);
            }
            if (pDuration < pFullDuration*downRatio)
            {
                owner.transform.Translate(0, -downSpeed*Time.deltaTime, 0);
            }
            pDuration -= Time.deltaTime;
        }
        owner.transform.position = startPos;

        if (owner.alive && owner.navAgent != null)
            owner.navAgent.enabled = true;

        owner.SetStatus(NTGBattleUnitController.UnitStatus.Blow, false);

        Release();
    }
}