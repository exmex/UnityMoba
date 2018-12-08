using System;
using UnityEngine;
using System.Collections;

public enum NTGBattleSkillType
{
    Attack,
    HostileSkill,
    FriendlySkill,
    HostilePassive,
    FriendlyPassive,
    SystemPassive,
    PlayerSkill,
}

public enum NTGBattleSkillFacingType
{
    Target,
    Original,
}

public class NTGBattleSkillController : MonoBehaviour
{
    public NTGBattleSkillType type;
    public NTGBattleSkillFacingType facingType;
    public bool manualStartCD;
    public bool singleBehaviour;

    public bool pretimeMovable;
    public bool posttimeNotShootable;

    public int id;
    public int level;
    public int levelCap;
    public int reqLevel;
    public int reqTarget;
    public float cd;

    private float _range;
    public float sqrRange;

    public float range
    {
        get { return _range; }
        set
        {
            _range = value;
            sqrRange = value*value;
        }
    }

    public float mpCost;
    public string icon;
    public string name;

    public float[] param;

    public int mask;

    public float[] p;
    public string[] sp;

    public int nextLevel;

    public NTGBattleUnitController owner;
    public NTGBattleMemberSkill skill;
    public NTGBattleMemberSkillBehaviour[] behavs;

    public NTGBattleSkillBehaviour[] behaviours;
    public NTGBattlePassiveSkillBehaviour[] pBehaviours;

    public float inCd;

    public int requireUpgradeLevel
    {
        get
        {
            if (level == levelCap)
            {
                return int.MaxValue;
            }
            if (level > 0)
            {
                return NTGBattleDataController.GetSkillRequireLevel(nextLevel);
            }
            return reqLevel;
        }
    }

    protected void Awake()
    {
        owner = GetComponentInParent<NTGBattleUnitController>();
    }

    public virtual void Init(NTGBattleMemberSkill skill, float[] p, string[] sp)
    {
        this.p = p;
        this.sp = sp;

        if (skill != null)
            Load(skill);

        inCd = 0;

        foreach (var pb in pBehaviours)
        {
            owner.mainController.RegisterPassiveSkillBehaviour(pb.passiveName, pb);
        }

        var skillBase = owner.mainController.skillTemplates.Find(owner.gameObject.name);
        if (skillBase == null)
        {
            skillBase = (new GameObject(owner.gameObject.name)).transform;
            skillBase.parent = owner.mainController.skillTemplates;
            skillBase.localPosition = Vector3.zero;
            skillBase.localRotation = Quaternion.identity;
        }
        transform.parent = skillBase;
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.identity;
    }

    private void Load(NTGBattleMemberSkill skill)
    {
        this.skill = skill;

        id = skill.Id;
        level = skill.Level;
        levelCap = skill.LevelCap;
        reqLevel = skill.ReqLevel;

        reqTarget = skill.ReqTarget;

        cd = skill.Cd;
        range = skill.Range;
        mpCost = skill.MpCost;
        icon = skill.Icon;
        name = skill.Name;

        param = skill.Param;

        nextLevel = skill.NextLevel;
        mask = skill.Mask;

        behavs = skill.Behaviours;
        if (behavs.Length != behaviours.Length + pBehaviours.Length)
        {
            Debug.LogError(String.Format("Skill Behaviours Count not Match Owner {0} Skill {1}", owner.id, id));
        }
        for (int i = 0; i < behaviours.Length; i++)
        {
            behaviours[i].Init(owner, owner, this, behavs[i], p, sp);
            behaviours[i].gameObject.SetActive(false);
        }
        for (int i = 0; i < pBehaviours.Length; i++)
        {
            pBehaviours[i].Init(owner, owner, this, behavs[behaviours.Length + i], p, sp);
            pBehaviours[i].gameObject.SetActive(false);
        }
    }

    public void Upgrade()
    {
        if (level == 0)
        {
            level = 1;
        }
        else
        {
            Load(NTGBattleDataController.GetBattleMemberSkill(nextLevel));
        }
    }

    public virtual bool OverideShootable()
    {
        return false;
    }

    public virtual bool ShootCheck(NTGBattleUnitController targetUnit, float xOffset = 0, float zOffset = 0)
    {
        if (behaviours.Length > 0)
        {
            return behaviours[0].ShootCheck(targetUnit, xOffset, zOffset);
        }

        return true;
    }

    public virtual void Shoot(NTGBattleUnitController targetUnit, float xOffset = 0, float zOffset = 0)
    {
        owner.SyncShoot(id, targetUnit == null ? "" : targetUnit.id, xOffset, zOffset);

        owner.NotifyShoot(targetUnit, this);

        StartCoroutine(doShoot(targetUnit, xOffset, zOffset));

        if (!manualStartCD)
            StartCD();
    }

    private Coroutine cdRoutine;

    public void StartCD()
    {
        inCd = 0;
        if (cdRoutine != null)
            StopCoroutine(cdRoutine);

        inCd = cd;
        if (type == NTGBattleSkillType.Attack)
        {
            inCd = inCd/(1.0f + owner.atkSpeed);
        }
        else if (type == NTGBattleSkillType.FriendlySkill || type == NTGBattleSkillType.HostileSkill)
        {
            inCd = inCd/(1.0f + owner.cdReduce);
        }
        cdRoutine = StartCoroutine(doCD());
    }

    public void StopCD()
    {
        inCd = 0;
        if (cdRoutine != null)
            StopCoroutine(cdRoutine);
    }

    public bool interrupt;

    protected IEnumerator ShootBehaviour(NTGBattleSkillBehaviour template, NTGBattleUnitController targetUnit, Vector3 targetPosition, bool direct)
    {
        float ratio = 1.0f;
        if (type == NTGBattleSkillType.Attack)
            ratio = 1.0f/(1.0f + owner.atkSpeed);

        var behaviour = owner.mainController.NewSkillBehaviour(template);

        if (owner.unitAnimator != null && behaviour.animationIndex != -1)
        {
            owner.unitAnimator.SetBool("walk", false);
            owner.unitAnimator.SetInteger("skill", behaviour.animationIndex);
            owner.unitAnimator.SetInteger("subskill", behaviour.animationSubIndex);
            if (behaviour.pretime == 0)
            {
                owner.unitAnimator.SetFloat("skillspeed", 100.0f);
            }
            else
            {
                owner.unitAnimator.SetFloat("skillspeed", behaviour.animationPretime/(behaviour.pretime*ratio));
            }
            if (pretimeMovable)
                owner.unitAnimator.SetBool("skillkeep", true);
            owner.unitAnimator.SetTrigger("shoot");
        }

        behaviour.PreShoot(targetUnit, targetPosition.x - owner.transform.position.x, targetPosition.z - owner.transform.position.z);

        interrupt = false;

        owner.ShootableCount++;
        if (!pretimeMovable)
            owner.MoveableCount++;
        float d = 0;
        while (d < behaviour.pretime*ratio)
        {
            yield return null;
            if (owner.GetStatus(NTGBattleUnitController.UnitStatus.Shoot) == false)
            {
                if (pretimeMovable && owner.interruptSource == NTGBattleUnitController.ShootInterruptSource.Move)
                {
                    owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, true);
                }
                else
                {
                    interrupt = true;
                    break;
                }
            }
            d += Time.deltaTime;
        }
        if (owner.unitAnimator != null)
        {
            owner.unitAnimator.SetFloat("skillspeed", 1.0f/ratio);
            if (pretimeMovable)
                owner.unitAnimator.SetBool("skillkeep", false);
        }
        owner.ShootableCount--;
        if (!pretimeMovable)
            owner.MoveableCount--;
        if (interrupt)
        {
            behaviour.Release();
            yield break;
        }

        if (!direct && facingType == NTGBattleSkillFacingType.Target)
            owner.transform.LookAt(new Vector3(targetPosition.x, owner.transform.position.y, targetPosition.z));

        behaviour.Shoot(targetUnit, targetPosition.x - owner.transform.position.x, targetPosition.z - owner.transform.position.z);
        owner.ShootableCount++;
        owner.MoveableCount++;
        d = 0;
        while (d < behaviour.stiff*ratio)
        {
            yield return null;
            if (owner.GetStatus(NTGBattleUnitController.UnitStatus.Shoot) == false)
            {
                interrupt = behaviour.Interrupt();
                if (interrupt)
                    break;
                owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, true);
            }
            d += Time.deltaTime;
        }
        owner.ShootableCount--;
        owner.MoveableCount--;
        if (interrupt)
        {
            yield break;
        }

        if (posttimeNotShootable)
            owner.ShootableCount++;
        d = 0;
        while (d < (behaviour.duration - behaviour.pretime - behaviour.stiff)*ratio)
        {
            yield return null;
            if (owner.GetStatus(NTGBattleUnitController.UnitStatus.Shoot) == false)
            {
                interrupt = behaviour.Interrupt();
                if (interrupt)
                    break;
            }
            d += Time.deltaTime;
        }
        if (posttimeNotShootable)
            owner.ShootableCount--;
        if (interrupt)
        {
            yield break;
        }
    }

    protected IEnumerator CancelPreviousSkill()
    {
        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, false);
        owner.interruptSource = NTGBattleUnitController.ShootInterruptSource.Skill;
        owner.ShootableCount++;
        yield return null;
        owner.ShootableCount--;
    }

    protected virtual IEnumerator doShoot(NTGBattleUnitController targetUnit, float xOffset, float zOffset)
    {
        Vector3 targetPosition;
        if (xOffset == 0 && zOffset == 0 && targetUnit != null)
        {
            targetPosition = targetUnit.transform.position;
        }
        else
        {
            targetPosition = new Vector3(owner.transform.position.x + xOffset*range, owner.transform.position.y, owner.transform.position.z + zOffset*range);
        }

        yield return StartCoroutine(CancelPreviousSkill());

        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, true);
        if (type == NTGBattleSkillType.Attack)
        {
            owner.SetNavPriority(NTGBattleUnitController.NavPriority.Attack);
        }
        else if (type == NTGBattleSkillType.HostileSkill || type == NTGBattleSkillType.FriendlySkill)
        {
            owner.SetNavPriority(NTGBattleUnitController.NavPriority.Skill);
        }

        if (singleBehaviour && behaviours.Length > 0)
        {
            yield return StartCoroutine(ShootBehaviour(behaviours[0], targetUnit, targetPosition, xOffset == 0 && zOffset == 0 && targetUnit == null));
        }
        else
        {
            for (int i = 0; i < behaviours.Length; i++)
            {
                yield return StartCoroutine(ShootBehaviour(behaviours[i], targetUnit, targetPosition, xOffset == 0 && zOffset == 0 && targetUnit == null));
                if (interrupt)
                {
                    break;
                }
            }
        }

        owner.SetNavPriority(NTGBattleUnitController.NavPriority.Default);
        owner.SetStatus(NTGBattleUnitController.UnitStatus.Shoot, false);
        owner.interruptSource = NTGBattleUnitController.ShootInterruptSource.None;
    }

    protected IEnumerator doCD()
    {
        while (inCd > 0)
        {
            yield return null;
            inCd -= Time.deltaTime;
        }
    }

    public NTGBattlePassiveSkillBehaviour FindPassiveSkillBehaviour(string passiveName)
    {
        for (int i = 0; i < pBehaviours.Length; i++)
        {
            if (pBehaviours[i].passiveName == passiveName)
            {
                return pBehaviours[i];
            }
        }

        return null;
    }
}