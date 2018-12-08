using System.Runtime.Remoting.Messaging;
using UnityEngine;
using System.Collections;

public class NTGBattleEquipController : MonoBehaviour
{
    public NTGBattlePlayerController owner;
    public NTGBattleMemberEquip equip;
    public NTGBattleSkillController skill;
    //public Transform fxAnchor;

    //public bool active;

    //public float sp;
    //public float spCost;
    //public float spCapacity;

    //public float reloadTime;

    //public NTGBattleUnitController targetUnit;

    //public float trackingSpeed;

    //public float targetAngle;

    //public Animator[] animators;

    //protected void Awake()
    //{
    //}

    //// Use this for initialization
    //protected void Start()
    //{
    //}

    //// Update is called once per frame
    //protected void Update()
    //{
    //}

    //public virtual void Init(float[] p)
    //{
    //    owner = GetComponentInParent<NTGBattlePlayerController>();
    //    animators = GetComponentsInChildren<Animator>();
    //    foreach (var animator in animators)
    //    {
    //        animator.gameObject.AddComponent<NTGAnimatorController>().Init();
    //    }
    //}

    //public void TriggerShoot()
    //{
    //    foreach (var animator in animators)
    //    {
    //        animator.SetTrigger("shoot");
    //    }
    //}

    //public virtual void Respawn()
    //{
    //    active = true;

    //    Reload(spCapacity);

    //    foreach (var esc in GetComponents<NTGBattleEquipSkillController>())
    //    {
    //        esc.Respawn();
    //    }

    //    StartCoroutine(doAutoReload());
    //}

    //public virtual void Broke()
    //{
    //    active = false;
    //}

    //private IEnumerator doAutoReload()
    //{
    //    while (active)
    //    {
    //        if (sp < spCapacity && !owner.isEngage)
    //        {
    //            if (owner.GetStatus(NTGBattleUnitController.UnitStatus.PoolRecover))
    //            {
    //                Reload(spCapacity);
    //            }
    //            else
    //            {
    //                Reload(spCost);
    //            }
    //        }

    //        yield return new WaitForSeconds(1.0f);
    //    }
    //}

    //public bool GetBullet()
    //{
    //    bool bullet = false;
    //    if (inReload || owner.inEquipGCD)
    //        return false;
    //    if (sp >= spCost)
    //    {
    //        sp -= spCost;
    //        bullet = true;
    //        owner.EquipGCD();
    //    }
    //    if (sp < spCost)
    //    {
    //        Reload(spCost);
    //    }
    //    return bullet;
    //}


    //public float reloadStartTime;
    //public bool inReload;

    //public void Reload(float loadAmount)
    //{
    //    if (loadAmount > spCapacity - sp)
    //    {
    //        loadAmount = spCapacity - sp;
    //    }
    //    if (owner.sp < loadAmount)
    //    {
    //        loadAmount = owner.sp;
    //    }
    //    if (!inReload && loadAmount > 0)
    //    {
    //        owner.sp -= loadAmount;
    //        reloadStartTime = Time.time;
    //        inReload = true;
    //        StartCoroutine(doReload(loadAmount));
    //    }
    //}

    //private IEnumerator doReload(float loadAmount)
    //{
    //    while (Time.time - reloadStartTime < reloadTime)
    //    {
    //        yield return null;
    //    }
    //    sp += loadAmount;
    //    inReload = false;
    //}

    //public void Activate()
    //{
    //    foreach (var c in gameObject.GetComponents<NTGBattleSkillController>())
    //    {
    //        DestroyImmediate(c);
    //    }
    //    foreach (var c in gameObject.GetComponents<NTGBattleEquipSkillController>())
    //    {
    //        DestroyImmediate(c);
    //    }

    //    trackingSpeed = equip.TrackSpeed;
    //    spCost = equip.SpCost;
    //    spCapacity = equip.SpCap;
    //    reloadTime = equip.Reload;

    //    var sc = gameObject.AddComponent<NTGBattleSkillController>();
    //    sc.Init(fxAnchor, NTGBattleSkillController.SkillSource.Equip, new float[0], new string[0]);
    //    sc.Load(equip.Skill);

    //    var esc = gameObject.AddComponent(Types.GetType("NTGBattleEquipSkill" + equip.SkillAi, "Assembly-CSharp")) as NTGBattleEquipSkillController;
    //    esc.Init(this, sc, equip.SkillAiParam);

    //    skill = sc;

    //    Respawn();
    //}

    //public void SkillShoot(int skillId, string targetId)
    //{
    //    if (skill.id == skillId)
    //    {
    //        targetUnit = owner.mainController.FindUnit(targetId);

    //        if (GetBullet())
    //        {
    //            skill.Shoot(targetUnit);

    //            TriggerShoot();
    //        }
    //    }
    //}
}