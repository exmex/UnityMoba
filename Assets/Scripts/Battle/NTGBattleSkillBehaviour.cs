using System;
using System.Collections;
using UnityEngine;

public class NTGBattleSkillBehaviour : MonoBehaviour
{
    public NTGBattleSkillType type;

    public enum Orientation
    {
        Anchor = 0,
        Owner = 1,
        Parent = 2,
    }

    public string skillFxABName;
    public Transform skillFX;
    public UTGBattleSkillAudioController audioController;
    public bool useOwnerVisibility;

    public int animationIndex;
    public int animationSubIndex;
    public float animationDuration;
    public float animationPretime;

    public int skillAnchor;
    public Orientation skillOrientation;
    public int fxAnchor;
    public Orientation fxOrientation;

    public CapsuleCollider collider;

    public NTGBattleUnitController lockedTarget;
    public NTGBattleMemberSkillBehaviour behaviour;

    public int id;
    public float[] param;

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

    public float speed;
    public float duration;
    public float pretime;
    public float stiff;

    public float baseValue;
    public float pAdd;
    public float mAdd;
    public float hpAdd;
    public float mpAdd;

    public enum EffectType
    {
        PhysicDamage = 0,
        MagicDamage = 1,
        HpRecover = 2,
        MpRecover = 3,
        RealDamage = 4,
    }

    public EffectType effectType; //0 physic dmg 1 magic dmg 2 hp recover 3 mp recover 4 real dmg

    public int mask;
    public string shock;

    public bool IsValidTarget(NTGBattleUnitController unit)
    {
        return (mask & unit.mask) != 0;
    }

    public float[] p;
    public string[] sp;

    public NTGBattleUnitController shooter;
    public NTGBattleUnitController owner;
    public NTGBattleSkillController skillController;

    public Vector3 startPos;

    public Transform e0;
    public Transform e1;
    public Transform ea;
    public Transform eb;
    public Transform ec;
    public Transform ed;
    public Transform ef;

    public Transform[] customFx;

    private ArrayList ecList;
    private ArrayList edList;
    private ArrayList ecPool;
    private ArrayList edPool;

    public void InitFXParts()
    {
        if (skillFX != null)
        {
            if (skillFX.parent != transform)
            {
                GameObject go = null;
                if (string.IsNullOrEmpty(skillFxABName))
                {
                    go = NTGResourceController.Instance.LoadAsset(gameObject.name.Replace("(Clone)", ""), skillFX.name);
                }
                else
                {
                    go = NTGResourceController.Instance.LoadAsset(skillFxABName, skillFX.name);
                }
                var fxgo = Instantiate(go);
                fxgo.name = skillFX.name;
                fxgo.transform.parent = transform;
                fxgo.transform.localPosition = Vector3.zero;
                fxgo.transform.localRotation = Quaternion.identity;

#if UNITY_EDITOR
                foreach (var r in fxgo.GetComponentsInChildren<Renderer>())
                {
                    r.material.shader = Shader.Find(r.material.shader.name);
                }
#endif
                skillFX = fxgo.transform;
            }

            for (int i = 0; i < skillFX.childCount; i++)
            {
                if (skillFX.GetChild(i).name.StartsWith("E0"))
                {
                    e0 = skillFX.GetChild(i);
                    e0.gameObject.SetActive(false);
                }
                else if (skillFX.GetChild(i).name.StartsWith("E1"))
                {
                    e1 = skillFX.GetChild(i);
                    e1.gameObject.SetActive(false);
                }
                else if (skillFX.GetChild(i).name.StartsWith("EA"))
                {
                    ea = skillFX.GetChild(i);
                    ea.gameObject.SetActive(false);
                }
                else if (skillFX.GetChild(i).name.StartsWith("EB"))
                {
                    eb = skillFX.GetChild(i);
                    eb.gameObject.SetActive(false);
                }
                else if (skillFX.GetChild(i).name.StartsWith("EC"))
                {
                    ec = skillFX.GetChild(i);
                    ec.gameObject.SetActive(false);
                }
                else if (skillFX.GetChild(i).name.StartsWith("ED"))
                {
                    ed = skillFX.GetChild(i);
                    ed.gameObject.SetActive(false);
                }
                else if (skillFX.GetChild(i).name.StartsWith("EF"))
                {
                    ef = skillFX.GetChild(i);
                    ef.gameObject.SetActive(false);
                }
            }
        }
    }

    public void Awake()
    {
        InitFXParts();

        var rigid = gameObject.GetComponent<Rigidbody>();
        if (rigid != null)
        {
            rigid.useGravity = false;
            rigid.isKinematic = true;
            rigid.constraints = RigidbodyConstraints.FreezeAll;
        }

        collider = GetComponent<CapsuleCollider>();
        if (collider != null)
        {
            collider.isTrigger = true;
        }

        ecList = new ArrayList();
        edList = new ArrayList();
        ecPool = new ArrayList();
        edPool = new ArrayList();
    }

    public void OnEnable()
    {
        if (collider != null)
        {
            collider.enabled = false;
        }
    }

    private void Load(NTGBattleMemberSkillBehaviour behav)
    {
        behaviour = behav;

        id = behav.Id;
        param = behav.Param;

        range = behav.Range;
        speed = behav.Speed;
        duration = behav.Duration;
        pretime = behav.Pretime;
        stiff = behav.Stiff;

        baseValue = behav.BaseValue;
        pAdd = behav.PAdd;
        mAdd = behav.MAdd;
        hpAdd = behav.HPAdd;
        mpAdd = behav.MPAdd;

        effectType = (EffectType) behav.EffectType;

        mask = behav.Mask;
        shock = behav.Shock;
    }

    public void Init(NTGBattleSkillBehaviour template)
    {
        Init(template.owner, template.shooter, template.skillController, template.behaviour, template.p, template.sp);
    }

    public virtual void Init(NTGBattleUnitController owner, NTGBattleUnitController shooter = null, NTGBattleSkillController skillController = null, NTGBattleMemberSkillBehaviour behav = null, float[] p = null, string[] sp = null)
    {
        this.owner = owner;
        this.shooter = shooter;
        this.skillController = skillController;

        if (behav != null)
            Load(behav);

        this.p = p;
        this.sp = sp;

        FXReset();

        if (audioController != null)
            audioController.Init();

        foreach (var ls in GetComponents<NTGLuaScript>())
        {
            if (ls.luaScript.Substring(0, ls.luaScript.LastIndexOf(".")) == "Logic.Battle.Skill")
            {
                //ls.LuaCall("Init", fxAnchor, owner, p, sp);
            }
        }
    }

    public virtual void Release()
    {
        foreach (GameObject o in ecList)
        {
            o.gameObject.SetActive(false);
            o.transform.parent = transform;
            o.transform.localPosition = Vector3.zero;
            ecPool.Add(o);
        }
        ecList.Clear();

        foreach (GameObject o in edList)
        {
            o.gameObject.SetActive(false);
            o.transform.parent = transform;
            o.transform.localPosition = Vector3.zero;
            edPool.Add(o);
        }
        edList.Clear();

        FXReset();

        if (audioController != null)
            audioController.Reset();

        StopAllCoroutines();

        owner.mainController.ReleaseSkillBehaviour(this);
    }

    public void ShootBase(NTGBattleUnitController target)
    {
        transform.position = owner.unitAnchors[skillAnchor].position;
        if (skillOrientation == Orientation.Anchor)
        {
            transform.rotation = owner.unitAnchors[skillAnchor].rotation;
        }
        if (skillOrientation == Orientation.Owner)
        {
            transform.rotation = owner.transform.rotation;
        }

        lockedTarget = null;
        if (target != null && (mask & target.mask) != 0)
        {
            lockedTarget = target;
        }
    }

    public virtual bool ShootCheck(NTGBattleUnitController target, float xOffset, float zOffset)
    {
        return true;
    }

    public virtual void PreShoot(NTGBattleUnitController target, float xOffset, float zOffset)
    {
        FXE0(target, xOffset, zOffset);
    }

    public virtual void Shoot(NTGBattleUnitController target, float xOffset, float zOffset)
    {
        var luaScripts = GetComponents<NTGLuaScript>();
        if (luaScripts != null && luaScripts.Length > 0)
        {
            foreach (var ls in luaScripts)
            {
                if (ls.luaScript.Substring(0, ls.luaScript.LastIndexOf(".")) == "Logic.Battle.Skill")
                {
                    ls.LuaCall("Shoot", target);
                }
            }
        }
        else
        {
            ShootBase(target);
        }
    }

    public virtual bool Interrupt()
    {
        return true;
    }

    public Transform FXCustom(int index)
    {
        if (index >= 0 && index < customFx.Length)
        {
            customFx[index].parent = owner.transform;
            customFx[index].localPosition = Vector3.zero;
            customFx[index].localRotation = Quaternion.identity;

            if (useOwnerVisibility)
            {
                if (owner.visibility)
                {
                    customFx[index].gameObject.SetActive(true);
                    foreach (var fx in customFx[index].GetComponentsInChildren<ParticleSystem>())
                    {
                        fx.Stop();
                        fx.Play();
                    }
                    //foreach (var fx in customFx[index].GetComponentsInChildren<Animator>())
                    //{
                    //    fx.SetTrigger("play");
                    //}
                }

                owner.unitActiveFX.Add(customFx[index]);
            }

            return customFx[index];
        }

        return null;
    }

    public void FXE1(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        if (e1 == null)
            return;

        if (!owner.visibility || !owner.rendererVisible)
            return;

        e1.gameObject.SetActive(true);

        e1.parent = owner.mainController.dynamics;
        e1.position = owner.transform.position + new Vector3(xOffset, 0, zOffset);
        e1.rotation = owner.transform.rotation;

        foreach (var fx in e1.GetComponentsInChildren<ParticleSystem>())
        {
            fx.Stop();
            fx.Play();
        }
        //foreach (var fx in e1.GetComponentsInChildren<Animator>())
        //{
        //    fx.SetTrigger("play");
        //}
    }

    public virtual void FXE0(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        FXE1(lockedTarget, xOffset, zOffset);

        if (audioController != null)
            audioController.FXE0(owner.transform);

        if (e0 == null)
            return;

        if (!owner.visibility || !owner.rendererVisible)
            return;

        e0.gameObject.SetActive(true);

        e0.parent = owner.transform;
        e0.localPosition = Vector3.zero;
        e0.localRotation = Quaternion.identity;

        foreach (var fx in e0.GetComponentsInChildren<ParticleSystem>())
        {
            fx.Stop();
            fx.Play();
        }
        //foreach (var fx in e0.GetComponentsInChildren<Animator>())
        //{
        //    fx.SetTrigger("play");
        //}
    }

    public void FXEA()
    {
        if (ea == null)
            return;

        if (!owner.visibility || !owner.rendererVisible)
            return;

        ea.gameObject.SetActive(true);
        if (fxOrientation != Orientation.Parent)
        {
            ea.parent = owner.mainController.dynamics;
        }

        if (fxOrientation == Orientation.Anchor)
        {
            ea.position = owner.unitAnchors[fxAnchor].position;
            ea.rotation = owner.unitAnchors[fxAnchor].rotation;
        }
        if (fxOrientation == Orientation.Owner)
        {
            ea.position = owner.unitAnchors[fxAnchor].position;
            ea.rotation = owner.transform.rotation;
        }

        foreach (var fx in ea.GetComponentsInChildren<ParticleSystem>())
        {
            fx.Stop();
            fx.Play();
        }
        //foreach (var fx in ea.GetComponentsInChildren<Animator>())
        //{
        //    fx.SetTrigger("play");
        //}

        if (audioController != null)
            audioController.FXEA(ea);
    }

    public void FXEB()
    {
        if (eb == null)
            return;

        var bs = eb.name.Split('-');
        if (bs.Length > 2 && bs[0] == "EB" && bs[1] == "Bone")
        {
            Transform anchor = null;
            foreach (var unitAnchor in owner.unitAnchors)
            {
                if (unitAnchor.name == bs[2])
                {
                    anchor = unitAnchor;
                    break;
                }
            }
            eb.parent = anchor;
            eb.localPosition = Vector3.zero;
            eb.localRotation = Quaternion.identity;
        }

        if (useOwnerVisibility)
        {
            if (owner.visibility)
            {
                eb.gameObject.SetActive(true);
                foreach (var fx in eb.GetComponentsInChildren<ParticleSystem>())
                {
                    fx.Stop();
                    fx.Play();
                }
                //foreach (var fx in eb.GetComponentsInChildren<Animator>())
                //{
                //    fx.SetTrigger("play");
                //}

                if (audioController != null)
                    audioController.FXEB(eb);
            }

            owner.unitActiveFX.Add(eb);
        }
        else
        {
            eb.gameObject.SetActive(true);
            foreach (var fx in eb.GetComponentsInChildren<ParticleSystem>())
            {
                fx.Stop();
                fx.Play();
            }
            //foreach (var fx in eb.GetComponentsInChildren<Animator>())
            //{
            //    fx.SetTrigger("play");
            //}

            if (audioController != null)
                audioController.FXEB(eb);
        }
    }

    public void FXExplode()
    {
        if (eb != null)
        {
            eb.gameObject.SetActive(false);

            if (audioController != null)
                audioController.FXEBStop();
        }

        if (ef != null)
        {
            ef.gameObject.SetActive(true);
            ef.transform.position = new Vector3(ef.transform.position.x, 0.1f, ef.transform.position.z);
            ef.transform.rotation = Quaternion.identity;

            foreach (var fx in ef.GetComponentsInChildren<ParticleSystem>())
            {
                fx.Stop();
                fx.Play();
            }
            //foreach (var fx in ef.GetComponentsInChildren<Animator>())
            //{
            //    fx.SetTrigger("play");
            //}
        }

        if (audioController != null)
            audioController.FXExplode(ef);
    }


    public void FXHit(NTGBattleUnitController target, bool keepEB = false, bool head = false)
    {
        if (eb != null && keepEB == false)
        {
            eb.gameObject.SetActive(false);

            if (audioController != null)
                audioController.FXEBStop();
        }

        if (target == null || !target.visibility || !target.rendererVisible)
            return;

        if (ec != null)
        {
            GameObject oec = null;
            if (ecPool.Count > 0)
            {
                oec = ecPool[0] as GameObject;
                ecPool.RemoveAt(0);
            }
            else
            {
                oec = Instantiate(ec.gameObject);
            }
            ecList.Add(oec);
            oec.gameObject.SetActive(true);
            oec.transform.parent = owner.mainController.dynamics;

            if (target != null)
            {
                if (head)
                {
                    oec.transform.parent = target.unitUiAnchor;
                    oec.transform.localPosition = new Vector3(0, -0.36f, 0);
                    oec.transform.localRotation = Quaternion.identity;
                }
                else
                {
                    oec.transform.position = target.transform.position + target.GetComponent<CapsuleCollider>().center;
                    //oec.transform.rotation = target.transform.rotation;
                    oec.transform.rotation = Quaternion.Euler(0, transform.rotation.eulerAngles.y, 0);
                    oec.transform.localScale = new Vector3(1, 1, 1)*target.GetComponent<CapsuleCollider>().height/1.8f;
                }
            }

            foreach (var fx in oec.GetComponentsInChildren<ParticleSystem>())
            {
                fx.Stop();
                fx.Play();
            }
            //foreach (var fx in oec.GetComponentsInChildren<Animator>())
            //{
            //    fx.SetTrigger("play");
            //}

            if (audioController != null)
                audioController.FXEC(oec.transform);
        }

        if (ed != null && target != null)
        {
            GameObject oed = null;
            if (edPool.Count > 0)
            {
                oed = edPool[0] as GameObject;
                edPool.RemoveAt(0);
            }
            else
            {
                oed = Instantiate(ed.gameObject);
            }
            edList.Add(oed);
            oed.gameObject.SetActive(true);
            oed.transform.parent = owner.mainController.dynamics;
            oed.transform.position = target.transform.position;
            //oed.transform.rotation = target.transform.rotation;
            oed.transform.rotation = Quaternion.Euler(0, transform.rotation.eulerAngles.y, 0);
            oed.transform.localScale = new Vector3(1, 1, 1)*target.GetComponent<CapsuleCollider>().height/1.8f;

            foreach (var fx in oed.GetComponentsInChildren<ParticleSystem>())
            {
                fx.Stop();
                fx.Play();
            }
            //foreach (var fx in oed.GetComponentsInChildren<Animator>())
            //{
            //    fx.SetTrigger("play");
            //}

            if (audioController != null)
                audioController.FXED(oed.transform);
        }
    }

    public void FXReset()
    {
        if (e0 != null)
        {
            e0.parent = skillFX;
            e0.localPosition = Vector3.zero;
            e0.localRotation = Quaternion.Euler(0, 0, 0);
            e0.gameObject.SetActive(false);
        }

        if (e1 != null)
        {
            e1.parent = skillFX;
            e1.localPosition = Vector3.zero;
            e1.localRotation = Quaternion.Euler(0, 0, 0);
            e1.gameObject.SetActive(false);
        }

        if (ea != null)
        {
            ea.parent = skillFX;
            ea.localPosition = Vector3.zero;
            ea.localRotation = Quaternion.Euler(0, 0, 0);
            ea.gameObject.SetActive(false);
        }

        if (eb != null)
        {
            eb.parent = skillFX;
            eb.localPosition = Vector3.zero;
            eb.localRotation = Quaternion.Euler(0, 0, 0);
            eb.gameObject.SetActive(false);

            if (useOwnerVisibility && owner != null && owner.unitActiveFX.Contains(eb))
            {
                owner.unitActiveFX.Remove(eb);
            }
        }

        if (ec != null)
        {
            ec.parent = skillFX;
            ec.localPosition = Vector3.zero;
            ec.localRotation = Quaternion.Euler(0, 0, 0);
            ec.gameObject.SetActive(false);
        }

        if (ed != null)
        {
            ed.parent = skillFX;
            ed.localPosition = Vector3.zero;
            ed.localRotation = Quaternion.Euler(0, 0, 0);
            ed.gameObject.SetActive(false);
        }

        if (ef != null)
        {
            ef.parent = skillFX;
            ef.localPosition = Vector3.zero;
            ef.localRotation = Quaternion.Euler(0, 0, 0);
            ef.gameObject.SetActive(false);
        }

        foreach (var cusFx in customFx)
        {
            cusFx.parent = skillFX;
            cusFx.localPosition = Vector3.zero;
            cusFx.localRotation = Quaternion.Euler(0, 0, 0);
            cusFx.gameObject.SetActive(false);

            if (useOwnerVisibility && owner != null && owner.unitActiveFX.Contains(cusFx))
            {
                owner.unitActiveFX.Remove(cusFx);
            }
        }
    }
}