using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60000133 : NTGBattleSkillSingleShoot
{
    public NTGBattlePassiveSkillBehaviour pBehaviour;

    public bool playerHit;

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {

        lockedTarget = null;
        ShootBase(lockedTarget);

        startPos = owner.transform.position;

        collider.height = 2.0f;
        //collider.direction = 2;
        collider.center = new Vector3(0, 0, -0.1f);
        collider.radius = this.param[0];

        playerHit = false;

        foreach (NTGBattlePassiveSkillBehaviour passive in owner.passives)
        {
            if (passive.name == "PBehaviourR60000130")
            {
                (passive as UTGBattlePassiveSkillBehaviourR60000130).DoSpecialShootCount(4);
            }
        }

        collider.enabled = true;
        FXEA();
        FXEB();
		//DoFXES();



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


                ShootBase(playerUnit);
                playerUnit.Hit(owner, this);
                FXHit(playerUnit);

                playerUnit.AddPassive(pBehaviour.passiveName, shooter, skillController);

                collider.direction = 1;
                collider.height = 8.0f;
                collider.center = new Vector3(0, 0, 0);
                collider.radius = this.param[0];

                yield return new WaitForSeconds(0.1f);
                collider.enabled = true;
                yield return new WaitForSeconds(0.1f);
                collider.enabled = false;
            }
        }
    }
    
}
