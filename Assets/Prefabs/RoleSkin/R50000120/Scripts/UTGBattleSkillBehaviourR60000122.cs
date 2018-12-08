using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000122 : NTGBattleSkillSingleShoot
{
    public NTGBattlePassiveSkillBehaviour pBehaviour;

    public ArrayList hitTargets;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        lockedTarget = null;

        ShootBase(lockedTarget);

        startPos = owner.transform.position;

        hitTargets = new ArrayList();

        collider.radius = this.param[1];

        var angle = this.param[0]/6;

        for (int i = 1; i <= 3; i++)
        {
            var arrow = owner.mainController.NewSkillBehaviour(this).transform;
            arrow.position = transform.position;
            arrow.rotation = transform.rotation;
            arrow.Rotate(arrow.up, i*angle);

            var behav = arrow.GetComponent<UTGBattleSkillBehaviourR60000122>();
            behav.startPos = startPos;
            behav.StartFly(this);

            arrow = owner.mainController.NewSkillBehaviour(this).transform;
            arrow.position = transform.position;
            arrow.rotation = transform.rotation;
            arrow.Rotate(arrow.up, -i*angle);

            behav = arrow.GetComponent<UTGBattleSkillBehaviourR60000122>();
            behav.startPos = startPos;
            behav.StartFly(this);
        }

        StartFly(this);
    }


    public void StartFly(UTGBattleSkillBehaviourR60000122 baseArrow)
    {
        hitTargets = baseArrow.hitTargets;
        StartCoroutine(doFly());
    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            if (!hitTargets.Contains(otherUnit))
            {
                otherUnit.Hit(owner, this);
                otherUnit.AddPassive(pBehaviour.passiveName, shooter, skillController);

                hitTargets.Add(otherUnit);
            }

            FXHit(otherUnit);
            hitTarget = true;
            collider.enabled = false;
        }
    }
}