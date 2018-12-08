using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000090 : NTGBattlePassiveSkillBehaviour
{
    public float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = duration;

        FXEA();
        FXEB();

        eb.parent = owner.unitUiAnchor;
        eb.localPosition = new Vector3(0, -0.289f, 0);
        eb.localRotation = Quaternion.identity;

        StartCoroutine(doDamage());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour) param;
            shooter = p.shooter;
            pDuration = duration;
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            Release();
        }
    }

    private IEnumerator doDamage()
    {
        while (pDuration > 0)
        {
            baseValue = this.param[0]*owner.hpMax;
            var mc = owner as NTGBattleMobController;
            if (mc != null && mc.type == 2 && baseValue > this.param[1])
                baseValue = this.param[1];

            owner.Hit(shooter, this);
            yield return new WaitForSeconds(1.0f);
            pDuration -= 1.0f;
        }

        Release();
    }
}