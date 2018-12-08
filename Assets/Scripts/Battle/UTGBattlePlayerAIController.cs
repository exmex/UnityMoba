using System;
using System.Collections.Generic;
using UnityEngine;
using System.Collections;
using Random = UnityEngine.Random;

public class UTGBattlePlayerAIController : MonoBehaviour
{
    public NTGBattlePlayerController pc;

    public float idleTime;
    public float stopDistance;

    public int currentWpIndex;
    public Transform currentWp;

    public float sqrStopDistance;

    public bool movingToWp;
    public bool doneWp;

    private bool initIdled;

    public Dictionary<int, int> gIndexToPosition = new Dictionary<int, int>
    {
        {10, 10},
        {11, 11},
        {12, 12},
        {13, 11},
        {14, 12},
        {20, 20},
        {21, 21},
        {22, 22},
        {23, 21},
        {24, 22},
    };

    public int position;

    public int[] skillPriority;
    public int[] skillChain;

    public float chainWeight;
    public float[] skillWeight;

    public virtual void Init(NTGBattlePlayerController pc, int gindex, float[] p)
    {
        this.pc = pc;
        this.position = gIndexToPosition[gindex];

        stopDistance = p[0];
        idleTime = p[1];

        skillPriority = new[] {(int) (p[2]/100%10), (int) (p[2]/10%10), (int) (p[2]%10)};

        var c = p[3];
        var cList = new ArrayList();
        while (((int) c) > 0)
        {
            cList.Add((int) (c%10));
            c /= 10;
        }
        skillChain = new int[cList.Count];
        for (int i = 0; i < skillChain.Length; i++)
        {
            skillChain[i] = (int) cList[cList.Count - 1 - i];
        }

        chainWeight = 0.1f;
        skillWeight = new[] {0.25f, 0.25f, 0.25f, 0.25f};
    }

    public virtual void Respawn()
    {
        currentWpIndex = 1;
        pc.targetUnit = null;
        movingToWp = false;
        doneWp = false;

        sqrStopDistance = stopDistance*stopDistance;

        chainSkill = false;

        if (pc.master)
        {
            StartCoroutine(doMove());
        }
    }

    public void SkillLevelUp()
    {
        if (pc.skillPoint > 0)
        {
            for (int i = 0; i < skillPriority.Length; i++)
            {
                var index = skillPriority[i];
                bool canUpgrade = pc.level >= pc.skills[index].requireUpgradeLevel && pc.skills[index].level < pc.skills[index].levelCap;
                if (canUpgrade)
                {
                    pc.SkillUpgrade(index);
                    break;
                }
            }
        }
    }

    public bool chainSkill;
    public bool chainSkillReady;
    public int chainSkillIndex;

    public int SkillDecisionChain(NTGBattleUnitController target, float sqrDist)
    {
        if (!chainSkillReady)
        {
            for (int i = 0; i < skillChain.Length; i++)
            {
                var skillIndex = skillChain[i];
                if (pc.skills[skillIndex].level <= 0)
                {
                    chainSkill = false;
                    return 0;
                }
                if (pc.skills[skillIndex].inCd > 0 || pc.mp < pc.skills[skillIndex].mpCost)
                {
                    return 0;
                }
            }
            chainSkillReady = true;
        }

        if (chainSkillIndex < skillChain.Length)
        {
            var skillIndex = skillChain[chainSkillIndex];
            if (pc.skills[skillIndex].inCd > 0 || pc.mp < pc.skills[skillIndex].mpCost || (target.mask & pc.skills[skillIndex].mask) == 0)
            {
                return 0;
            }
            chainSkillIndex++;
            if (chainSkillIndex == skillChain.Length)
            {
                chainSkill = false;
            }

            return skillIndex;
        }

        return 0;
    }

    public int SkillDecision(NTGBattleUnitController target, float sqrDist)
    {
        int skillIndex = 0;

        if (chainSkill)
            return SkillDecisionChain(target, sqrDist);

        var chainRoll = Random.Range(0.0f, 1.0f);
        //Debug.LogError(String.Format("Roll {0} of {1}", chainRoll, chainWeight));
        if (chainRoll < chainWeight)
        {
            chainWeight = 0.1f;
            chainSkill = true;
            chainSkillReady = false;
            chainSkillIndex = 0;
            return SkillDecisionChain(target, sqrDist);
        }

        float weight = 0;
        var skillRoll = Random.Range(0.0f, 1.0f);
        for (int i = 0; i < skillWeight.Length; i++)
        {
            if (skillRoll < weight + skillWeight[i])
            {
                skillIndex = i;
                break;
            }
            weight += skillWeight[i];
        }

        if (pc.skills[skillIndex].level > 0 && pc.skills[skillIndex].inCd <= 0 && pc.mp >= pc.skills[skillIndex].mpCost && (target.mask & pc.skills[skillIndex].mask) != 0 && sqrDist < pc.skills[skillIndex].sqrRange)
        {
            if (skillIndex > 0)
            {
                skillWeight[skillIndex] -= 0.05f;
                skillWeight[0] += 0.05f;
                if (skillWeight[skillIndex] <= 0)
                {
                    skillWeight[0] -= 0.25f;
                    skillWeight[skillIndex] += 0.25f;
                }

                chainWeight += 0.05f;
            }
            if (skillWeight[0] >= 0.75f)
            {
                skillWeight = new[] {0.25f, 0.25f, 0.25f, 0.25f};
            }

            return skillIndex;
        }

        skillIndex = 0;

        return skillIndex;
    }

    private IEnumerator doMove()
    {
        float sqrDist = 0;
        var exList = new ArrayList();
        var skillIndex = -1;

        if (!initIdled)
        {
            yield return new WaitForSeconds(idleTime);
            initIdled = true;
        }
        else
        {
            yield return new WaitForSeconds(1.0f);
        }

        while (pc.alive)
        {
            SkillLevelUp();

            if (Time.time - towerHitTime > 2.0f)
            {
                pc.targetUnit = pc.FindTarget(pc.targetRange, exNeutMob: true);
            }

            if (pc.targetUnit == null)
            {
                if (!doneWp)
                {
                    if (!movingToWp)
                    {
                        currentWp = pc.mainController.respawn.Find("WayPoint/WP-" + position + "/" + currentWpIndex);

                        if (currentWp != null)
                        {
                            MoveTo(currentWp.position);
                            movingToWp = true;
                        }
                        else
                        {
                            doneWp = true;
                        }
                    }

                    if (movingToWp && (transform.position - currentWp.position).sqrMagnitude < 1.0f)
                    {
                        currentWpIndex++;
                        currentWp = pc.mainController.respawn.Find("WayPoint/WP-" + position + "/" + currentWpIndex);

                        if (currentWp != null)
                        {
                            MoveTo(currentWp.position);
                            movingToWp = true;
                        }
                        else
                        {
                            doneWp = true;
                        }

                        exList.Clear();
                    }
                }

                yield return new WaitForSeconds(0.1f);
                continue;
            }

            while (pc.alive && pc.targetUnit != null && pc.targetUnit.Lockable(pc.group))
            {
                sqrDist = (pc.targetUnit.transform.position - transform.position).sqrMagnitude;
                if (sqrDist > pc.sqrTargetRange)
                    break;


                if (pc.Moveable && sqrDist > sqrStopDistance)
                {
                    MoveTo(pc.targetUnit.transform.position);
                    pc.SetNavPriority(NTGBattleUnitController.NavPriority.Default);
                    movingToWp = false;
                }
                else
                {
                    StopMovement();
                    pc.SetNavPriority(NTGBattleUnitController.NavPriority.MobStanding);
                    movingToWp = false;
                }

                if (skillIndex == -1)
                    skillIndex = SkillDecision(pc.targetUnit, sqrDist);

                if (pc.Shootable && pc.skills[skillIndex].inCd <= 0 && pc.mp >= pc.skills[skillIndex].mpCost && sqrDist < pc.skills[skillIndex].sqrRange)
                {
                    pc.mp -= pc.skills[skillIndex].mpCost;

                    if (pc.skills[skillIndex].facingType == NTGBattleSkillFacingType.Target)
                        pc.transform.LookAt(new Vector3(pc.targetUnit.transform.position.x, transform.position.y, pc.targetUnit.transform.position.z));

                    pc.skills[skillIndex].Shoot(pc.targetUnit);

                    //yield return new WaitForSeconds(pc.skills[skillIndex].cd);

                    skillIndex = -1;
                }

                yield return new WaitForSeconds(0.1f);
            }

            pc.SetNavPriority(NTGBattleUnitController.NavPriority.Default);
        }
    }

    public float towerHitTime;

    public void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.Hit)
        {
            var p = param as NTGBattlePassive.EventHitParam;
            if (!(pc.targetUnit is NTGBattlePlayerController) && p.shooter is NTGBattlePlayerController && (p.behaviour.type == NTGBattleSkillType.Attack || p.behaviour.type == NTGBattleSkillType.HostileSkill || p.behaviour.type == NTGBattleSkillType.HostilePassive))
            {
                pc.targetUnit = p.shooter;
            }

            if (p.shooter is NTGBattleMobTowerController)
            {
                pc.targetUnit = null;

                towerHitTime = Time.time;

                if (currentWpIndex > 1)
                    currentWpIndex--;
            }
        }
    }

    public Vector3 MovingDestination;
    public bool stopMovement;

    public void MoveTo(Vector3 dest)
    {
        RawMoveTo(dest);
        stopMovement = false;
    }

    public void StopMovement()
    {
        if (!stopMovement)
        {
            RawMoveTo(transform.position);
            stopMovement = true;
        }
    }

    private void RawMoveTo(Vector3 dest)
    {
        if (pc.alive && pc.navAgent.enabled && pc.navAgent.SetDestination(dest))
        {
            if (dest != MovingDestination)
            {
                pc.SyncDest(dest);
            }

            MovingDestination = dest;
        }
    }
}