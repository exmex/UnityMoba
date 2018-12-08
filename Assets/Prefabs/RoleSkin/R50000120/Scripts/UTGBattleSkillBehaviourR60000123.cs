using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000123 : NTGBattleSkillSingleShoot
{
    public NTGBattlePassiveSkillBehaviour pBehaviour;

    public bool playerHit;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        lockedTarget = null;

        ShootBase(lockedTarget);

        startPos = owner.transform.position;

        collider.direction = 2;
        collider.height = 2.0f;
        collider.center = new Vector3(0, 0, -1.0f);
        collider.radius = this.param[0];

        playerHit = false;

        StartCoroutine(doFly());
    }


    public IEnumerator OnTriggerEnter(Collider other)
    {
        if (owner == null)
            yield break;

        if (playerHit)
        {
            var otherUnit = other.GetComponent<NTGBattleUnitController>();
            if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
            {
                otherUnit.Hit(owner, this);
            }
        }
        else
        {
            var playerUnit = other.GetComponent<NTGBattlePlayerController>();
            if (playerUnit != null && playerUnit.alive && playerUnit.group != owner.group)
            {
                hitTarget = true;
                collider.enabled = false;
                playerHit = true;

                FXHit(playerUnit);

                playerUnit.AddPassive(pBehaviour.passiveName, shooter, skillController);
                playerUnit.AddPassive("Stun", shooter, p: new[] {this.param[2]});

                collider.direction = 1;
                collider.height = 8.0f;
                collider.center = new Vector3(0, 0, 0);
                collider.radius = this.param[1];

                yield return new WaitForSeconds(0.1f);
                collider.enabled = true;
                yield return new WaitForSeconds(0.1f);
                collider.enabled = false;
            }
        }
    }
}