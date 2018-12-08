using UnityEngine;
using System.Collections;

public class NTGBattleMobTowerController : NTGBattleMobController
{
    public Transform deadFX;

    public int originMask;

    public Transform gun;

    public float trackTime;

    public float trackingSpeed;

    public Transform warningHint;
    public Renderer warningHintRenderer;
    public Transform warningDeadHint;
    public Renderer warningDeadHintRenderer;

    public int targetHitCount;
    public int maxTargetHitCount;

    private void Awake()
    {
        base.Awake();

        trackTime = 180.0f;
        trackingSpeed = 1000.0f;

        if (warningHint != null)
        {
            warningHint.localPosition = new Vector3(0, 0.05f, 0);
            warningHint.gameObject.SetActive(false);
            warningHintRenderer = warningHint.gameObject.GetComponent<Renderer>();

            warningDeadHint.localPosition = new Vector3(0, 0.05f, 0);
            warningDeadHint.gameObject.SetActive(false);
            warningDeadHintRenderer = warningDeadHint.gameObject.GetComponent<Renderer>();
        }
    }

    public override void Init(float[] p)
    {
        maxTargetHitCount = (int) p[0];
    }

    public override void Respawn()
    {
        base.Respawn();

        foreach (var fx in deadFX.GetComponentsInChildren<ParticleSystem>())
        {
            fx.Stop();
        }
        deadFX.gameObject.SetActive(false);

        gameObject.SetActive(true);

        foreach (var msc in GetComponentsInChildren<NTGBattleMobSkillController>())
        {
            msc.Respawn();
        }

        originMask = mask;
        mask = 0;
        for (int i = 0; i < NTGBattleMainController.GroupCount; i++)
        {
            if (group - 1 != i)
            {
                GroupLockableCount[i]++;
            }
        }


        StartCoroutine(doVulnerableCheck());
        StartCoroutine(doAim());

        if (warningHint != null)
        {
            warningHint.localScale = new Vector3((skills[0].range)*2, 1, (skills[0].range)*2);
            warningDeadHint.localScale = new Vector3((skills[0].range)*2, 1, (skills[0].range)*2);

            StartCoroutine(doUpdateRangeHint());
        }
    }

    public override void SkillShoot(int skillId, string targetId, float xOffset, float zOffset)
    {
        foreach (var skill in skills)
        {
            if (skill.id == skillId)
            {
                targetUnit = mainController.FindUnit(targetId);

                if (mp >= skill.mpCost)
                {
                    mp -= skill.mpCost;

                    if (targetUnit != null && skill.facingType == NTGBattleSkillFacingType.Target)
                    {
                        gun.LookAt(new Vector3(targetUnit.transform.position.x, transform.position.y, targetUnit.transform.position.z));
                    }

                    skill.Shoot(targetUnit);
                }
            }
        }
    }

    private IEnumerator doVulnerableCheck()
    {
        yield return new WaitForSeconds(10.0f);

        while (true)
        {
            if (mainController.battleTowers[group - 1][creatureInfo.RespawnLane[0]][creatureInfo.RespawnLane[1] + 1] == null ||
                mainController.battleTowers[group - 1][creatureInfo.RespawnLane[0]][creatureInfo.RespawnLane[1] + 1].alive == false)
            {
                mask = originMask;
                for (int i = 0; i < NTGBattleMainController.GroupCount; i++)
                {
                    if (group - 1 != i)
                    {
                        GroupLockableCount[i]--;
                    }
                }

                break;
            }

            yield return new WaitForSeconds(1.0f);
        }
    }

    private IEnumerator doUpdateRangeHint()
    {
        while (alive)
        {
            warningHint.gameObject.SetActive(false);
            warningDeadHint.gameObject.SetActive(false);

            if (targetUnit == mainController.uiController.localPlayerController && (transform.position - targetUnit.transform.position).sqrMagnitude < skills[0].sqrRange)
            {
                warningDeadHint.gameObject.SetActive(true);
                warningDeadHintRenderer.material.SetColor("_Color", Color.red);
            }
            else if (viewController.unitsInView.Contains(mainController.uiController.localPlayerController))
            {
                if (targetUnit != null && targetUnit != mainController.uiController.localPlayerController)
                {
                    warningHint.gameObject.SetActive(true);
                    warningHintRenderer.material.SetColor("_Color", Color.green);
                }
                else
                {
                    warningHint.gameObject.SetActive(true);
                    warningHintRenderer.material.SetColor("_Color", Color.yellow);
                }
            }

            yield return null;
        }
    }

    public bool playerHitLocked;

    private IEnumerator doAim()
    {
        float sqrDist = 0;

        while (alive)
        {
            if (!playerHitLocked)
            {
                targetUnit = FindTarget(targetRange, type: TargetType.Mob);
                if (targetUnit == null)
                    targetUnit = FindTarget(targetRange);
            }

            if (targetUnit == null)
            {
                yield return new WaitForSeconds(0.1f);
                continue;
            }

            targetHitCount = 0;

            float time = 0;
            while (alive && time < trackTime && targetUnit != null && targetUnit.Lockable(group))
            {
                sqrDist = (targetUnit.transform.position - transform.position).sqrMagnitude;
                if (sqrDist > sqrTargetRange)
                    break;

                //var targetVector = new Vector3(targetUnit.transform.position.x, 0, targetUnit.transform.position.z) - new Vector3(gun.position.x, 0, gun.position.z);

                //var targetAngle = Vector3.Angle(transform.forward, targetVector);

                //float rotate = trackingSpeed*Time.deltaTime;

                //if (Math.Abs(targetAngle) < rotate)
                //{
                //    rotate = Math.Abs(targetAngle);
                //}

                //gun.forward = Vector3.RotateTowards(gun.forward, targetVector, rotate/180*(float) Math.PI, 0);

                //var p = targetUnit.transform.position - gun.position;
                //var a = Vector3.Angle(p, new Vector3(p.x, 0, p.z));
                //if (a > 30.0f)
                //    a = 30.0f;
                //gun.localRotation = Quaternion.Euler(a, gun.localRotation.eulerAngles.y, gun.localRotation.eulerAngles.z);

                gun.LookAt(new Vector3(targetUnit.transform.position.x, transform.position.y, targetUnit.transform.position.z));

                if (master)
                {
                    if (Shootable && skills[0].inCd <= 0 && mp >= skills[0].mpCost && sqrDist < skills[0].sqrRange)
                    {
                        mp -= skills[0].mpCost;

                        skills[0].Shoot(targetUnit);

                        if (targetHitCount < maxTargetHitCount && targetUnit is NTGBattlePlayerController)
                            targetHitCount++;
                    }
                }

                yield return new WaitForSeconds(0.1f);
                time += Time.deltaTime;
            }

            playerHitLocked = false;
        }
    }

    public override void PlayerHit(NTGBattlePlayerController player, NTGBattlePlayerController shooter)
    {
        if (!playerHitLocked && player.group == group && (transform.position - shooter.transform.position).sqrMagnitude < sqrTargetRange)
        {
            playerHitLocked = true;
            targetUnit = shooter;
        }
    }

    public override void Kill(NTGBattleUnitController killer)
    {
        if (alive)
        {
            base.Kill(killer);

            unitAnimator.SetBool("dead", true);

            HitRecord lastPlayerHit = null;
            while (hitRecords.Count > 0)
            {
                var hitRecord = hitRecords.Dequeue() as HitRecord;
                var p = hitRecord.shooter as NTGBattlePlayerController;
                if (p != null)
                {
                    lastPlayerHit = hitRecord;
                }
            }
            if (lastPlayerHit != null && Time.time - lastPlayerHit.time < mainController.configX)
            {
                var k = lastPlayerHit.shooter as NTGBattlePlayerController;
                k.statistic.towerKill++;
            }

            GetComponent<CapsuleCollider>().enabled = false;
            gun.gameObject.SetActive(false);

            if (warningHint != null)
            {
                warningHint.gameObject.SetActive(false);
                warningDeadHint.gameObject.SetActive(false);
            }

            foreach (var fx in transform.GetComponentsInChildren<ParticleSystem>())
            {
                fx.Stop();
            }
            PlayDeadFX();

            mainController.uiController.ShowUnitKillMessage(killer, this);

            StartCoroutine(doDead());
        }
    }

    private IEnumerator doDead()
    {
        mainController.uiController.HideUnitUI(this, false);
        yield return new WaitForSeconds(1.5f);
        viewController.Kill();
        mainController.ReleaseUnitUI(this);
        SetVisibility(true);
    }

    private void PlayDeadFX()
    {
        StartCoroutine(doPlayDeadFX());
    }

    private IEnumerator doPlayDeadFX()
    {
        deadFX.gameObject.SetActive(true);
        foreach (var fx in deadFX.GetComponentsInChildren<ParticleSystem>())
        {
            fx.Stop();
            fx.Play();
        }
        //foreach (var fx in deadFX.GetComponentsInChildren<Animator>())
        //{
        //    fx.SetTrigger("play");
        //}

        yield return new WaitForSeconds(2.0f);

        foreach (var fx in deadFX.GetComponentsInChildren<ParticleSystem>())
        {
            fx.Stop();
        }
    }
}