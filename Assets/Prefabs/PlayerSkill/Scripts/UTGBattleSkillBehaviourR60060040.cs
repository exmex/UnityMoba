using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60060040 : NTGBattleSkillBehaviour
{

    public NTGBattlePassiveSkillBehaviour[] pBehaviour;

    public override void Shoot(NTGBattleUnitController target, float xOffset, float zOffset)
    {
        base.Shoot(target, xOffset, zOffset);

        collider.radius = range;

        //owner.Hit(owner, this);

        owner.AddPassive(pBehaviour[0].passiveName, owner, skillController);

        //StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        //FXExplode();

        skillController.StartCD();

        float moveSpeedTemp = owner.baseAttrs.MoveSpeed * this.param[0];

        owner.baseAttrs.MoveSpeed = owner.baseAttrs.MoveSpeed + moveSpeedTemp;

        yield return new WaitForSeconds(this.duration);

        owner.baseAttrs.MoveSpeed = owner.baseAttrs.MoveSpeed - moveSpeedTemp;


        Release();

    }
}
