using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000080 : NTGBattlePassiveSkillBehaviour
{
    public UTGBattlePassiveSkillControllerR60100080 sc;

    private NTGBattleUnitController.UnitBuff unitBuff;

    public override void Respawn()
    {
        base.Respawn();

        sc = skillController as UTGBattlePassiveSkillControllerR60100080;

        transform.parent = owner.transform;
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.identity;

        unitBuff = new NTGBattleUnitController.UnitBuff {icon = skillController.icon, desc = NTGBattleDataController.GetSkillDesc(skillController.id), ratio = 0f};
        owner.unitBuffs.Add(unitBuff);

        FXEA();
        FXEB();
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Hit && sc.skillCount == 0)
        {
            var p = (NTGBattlePassive.EventHitParam) param;
            if (p.shooter == owner && (p.behaviour.type == NTGBattleSkillType.HostileSkill))
            {
                p.target.AddPassive("Stun", owner, p: new[] {this.p[0]});
            }
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            owner.unitBuffs.Remove(unitBuff);

            FXReset();

            StartCoroutine(doDelayRemove());
        }
    }

    private IEnumerator doDelayRemove()
    {
        yield return new WaitForSeconds(2.0f);

        Release();
    }
}