using Newtonsoft.Json.Linq;
using UnityEngine;
using System.Collections;

public class NTGBattleMobBaseController : NTGBattleMobController
{
    public Transform deadFX;

    public int originMask;

    public Transform warningHint;
    public Renderer warningHintRenderer;
    public Transform warningDeadHint;
    public Renderer warningDeadHintRenderer;


    private void Awake()
    {
        base.Awake();

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
        if (master)
        {
            StartCoroutine(doAim());
        }

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
            bool laneDestroied = false;

            for (int i = 0; i < mainController.battleTowers[group - 1].Length; i++)
            {
                if (mainController.battleTowers[group - 1][i][0] != null &&
                    mainController.battleTowers[group - 1][i][0].alive == false)
                {
                    laneDestroied = true;
                    break;
                }
            }

            if (laneDestroied)
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

    private IEnumerator doAim()
    {
        float sqrDist = 0;

        while (alive)
        {
            targetUnit = FindTarget(targetRange);

            if (targetUnit == null)
            {
                yield return new WaitForSeconds(0.1f);
                continue;
            }

            while (alive && targetUnit != null && targetUnit.Lockable(group))
            {
                sqrDist = (targetUnit.transform.position - transform.position).sqrMagnitude;
                if (sqrDist > sqrTargetRange)
                    break;

                if (Shootable && skills[0].inCd <= 0 && mp >= skills[0].mpCost && sqrDist < skills[0].sqrRange)
                {
                    mp -= skills[0].mpCost;

                    skills[0].Shoot(targetUnit);
                }

                yield return new WaitForSeconds(0.1f);
            }
        }
    }

    public override void Kill(NTGBattleUnitController killer)
    {
        if (alive)
        {
            base.Kill(killer);

            unitAnimator.SetBool("dead", true);
            PlayDeadFX();

            GetComponent<CapsuleCollider>().enabled = false;

            mainController.ReleaseUnitUI(this);

            if (master)
            {
                BaseDestroyed();
            }
        }
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

    public void BaseDestroyed()
    {
        netService.SendRequest(
            new TGNetService.NetRequest
            {
                Content =
                    new JObject(new JProperty("Type", "BaseDestroyed"),
                        new JProperty("G", group)),
                FlowOpt = true
            });
    }
}