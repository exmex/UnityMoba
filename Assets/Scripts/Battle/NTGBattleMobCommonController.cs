using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class NTGBattleMobCommonController : NTGBattleMobController
{
    private Vector3 samplePosition;
    private float sampleTime;

    private void Awake()
    {
        base.Awake();
    }

    // Use this for initialization
    private void Start()
    {
        base.Start();

        sampleTime = Time.time;
        samplePosition = transform.position;
    }

    // Update is called once per frame
    private void Update()
    {
        if (Time.time - sampleTime > 0.05)
        {
            if (unitAnimator != null)
            {
                if (Moveable && Vector3.Distance(transform.position, samplePosition) > 0.01)
                {
                    unitAnimator.SetBool("walk", true);
                }
                else
                {
                    unitAnimator.SetBool("walk", false);
                }
            }

            sampleTime = Time.time;
            samplePosition = transform.position;
        }

        //if (mainController.connected && this is NTGBattleMobR61120010 && !master && alive && Time.time - NetEventTime > 10.0f)
        //    Kill(this);
    }

    public override void SkillShoot(int skillId, string targetId, float xOffset, float zOffset)
    {
        foreach (var skill in skills)
        {
            if (skill.id == skillId)
            {
                targetUnit = mainController.FindUnit(targetId);

                if (targetUnit != null && skill.facingType == NTGBattleSkillFacingType.Target)
                {
                    transform.LookAt(new Vector3(targetUnit.transform.position.x, transform.position.y, targetUnit.transform.position.z));
                }

                if (mp >= skill.mpCost)
                {
                    mp -= skill.mpCost;

                    skill.Shoot(targetUnit);
                }
            }
        }
    }

    public override void Respawn()
    {
        base.Respawn();

        gameObject.SetActive(true);
        if (navAgent != null)
            navAgent.enabled = true;

        unitAnimator.SetBool("dead", false);

        unitAnimator.SetTrigger("respawn");
    }

    public override void Kill(NTGBattleUnitController killer)
    {
        if (alive)
        {
            base.Kill(killer);

            unitAnimator.SetBool("dead", true);

            if (navAgent != null)
            {
                navAgent.ResetPath();
                navAgent.enabled = false;
            }

            StartCoroutine(doDead());
        }
    }

    private IEnumerator doDead()
    {
        mainController.uiController.HideUnitUI(this, false);
        yield return new WaitForSeconds(1.5f);
        viewController.Kill();
        mainController.ReleaseUnitUI(this);
        transform.position -= new Vector3(0, 10000.0f, 0);
        yield return new WaitForSeconds(0.15f);

        if (unitCollider != null)
            unitCollider.enabled = false;

        mainController.ReleaseMob(this);
    }
}