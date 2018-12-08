using System;
using LuaInterface;
using Newtonsoft.Json.Linq;
using UnityEngine;
using System.Collections;

public class NTGBattleUnitStatistic
{
    public int kill;
    public int death;
    public int assist;

    public int towerKill;

    public float damagePlayer;
    public float damageMob;
    public float damageNeut;
    public float damageBuilding;

    public float damageReceive;

    public float coin;
    public int maxKillSteak;
}

public class NTGBattleUnitController : MonoBehaviour
{
    protected TGNetService netService;

    public bool master;
    public bool rendererVisible;
    public bool visibility;
    public float unitRadiusSqr;
    public Animator unitAnimator;
    public Transform[] unitAnchors;
    public Renderer[] unitRenderers;
    public Transform unitUi;
    public Transform unitMinimap;

    public enum UnitFX
    {
        Invisible,
        Coin,

        Count,
    }

    public static string[] UnitFXResource =
    {
        "UnitFXInvisible",
        "UnitFXCoin",
    };

    public Transform[] unitFX;
    public Transform[] unitPersistFX;

    public ArrayList unitActiveFX;
    public CapsuleCollider unitCollider;

    public void PlayFXOnce(UnitFX fx)
    {
        if ((int) fx < unitFX.Length && unitFX[(int) fx] == null)
        {
            var i = (int) fx;
            unitFX[i] = Instantiate(mainController.prefabs.Find(UnitFXResource[i]).gameObject).transform;
            unitFX[i].gameObject.name = UnitFXResource[i];
            unitFX[i].parent = transform;
            unitFX[i].localPosition = Vector3.zero;
            unitFX[i].localRotation = Quaternion.identity;
            unitFX[i].gameObject.SetActive(false);
        }

        if ((int) fx < unitFX.Length && unitFX[(int) fx] != null)
        {
            StartCoroutine(doPlayFXOnce(fx));
        }
    }

    public void PlayFX(UnitFX fx, int anchor = 0, bool head = false)
    {
        if ((int) fx < unitFX.Length && unitFX[(int) fx] == null)
        {
            var i = (int) fx;
            unitFX[i] = Instantiate(mainController.prefabs.Find(UnitFXResource[i]).gameObject).transform;
            unitFX[i].gameObject.name = UnitFXResource[i];
            unitFX[i].parent = transform;
            unitFX[i].localPosition = Vector3.zero;
            unitFX[i].localRotation = Quaternion.identity;
            unitFX[i].gameObject.SetActive(false);
        }

        if ((int) fx < unitFX.Length && unitFX[(int) fx] != null)
        {
            if (head)
            {
                unitFX[(int) fx].parent = unitUiAnchor;
                unitFX[(int) fx].localPosition = new Vector3(0, -0.36f, 0);
                unitFX[(int) fx].localRotation = Quaternion.identity;
            }
            else
            {
                unitFX[(int) fx].parent = unitAnchors[anchor];
                unitFX[(int) fx].localPosition = Vector3.zero;
                unitFX[(int) fx].localRotation = Quaternion.identity;
            }

            if (visibility)
            {
                unitFX[(int) fx].gameObject.SetActive(true);
                foreach (var ps in unitFX[(int) fx].GetComponentsInChildren<ParticleSystem>())
                {
                    ps.Stop();
                    ps.Play();
                }
            }

            unitActiveFX.Add(unitFX[(int) fx]);
        }
    }

    public void StopFX(UnitFX fx)
    {
        if ((int) fx < unitFX.Length && unitFX[(int) fx] != null)
        {
            unitFX[(int) fx].gameObject.SetActive(false);

            unitActiveFX.Remove(unitFX[(int) fx]);
        }
    }

    private IEnumerator doPlayFXOnce(UnitFX fx)
    {
        unitActiveFX.Add(unitFX[(int) fx]);
        if (visibility)
        {
            unitFX[(int) fx].gameObject.SetActive(true);
            foreach (var ps in unitFX[(int) fx].GetComponentsInChildren<ParticleSystem>())
            {
                ps.Stop();
                ps.Play();
            }
        }

        yield return new WaitForSeconds(3.0f);
        unitFX[(int) fx].gameObject.SetActive(false);
        unitActiveFX.Remove(unitFX[(int) fx]);
    }

    public string id;
    public int position;
    public int group;

    public string name;
    public int level;
    public string icon;
    public bool alive;

    public float shield;

    public float hp;
    public float hpMax;
    public float mp;
    public float mpMax;

    public float hpRecover;
    public float mpRecover;

    public float pAtk;
    public float mAtk;
    public float pDef;
    public float mDef;

    public float pAtkRate;
    public float mAtkRate;

    public float pPenetrate;
    public float mPenetrate;
    public float pPenetrateRate;
    public float mPenetrateRate;

    public float crit;
    public float critEffect;

    public float pHpSteal;
    public float mHpSteal;

    public float tough;
    public float atkSpeed;
    public float cdReduce;
    [SerializeField] private float moveSpeed;

    public float MoveSpeed
    {
        get { return moveSpeed; }
        set
        {
            moveSpeed = value;
            if (navAgent != null)
            {
                navAgent.speed = moveSpeed;
            }
        }
    }

    public int mask; //0x1 player 0x2 mob 0x4 boss 0x8 building

    public NTGBattleMemberAttrs baseAttrs;

    public float sqrTargetRange;
    private float _targetRange;

    public float targetRange
    {
        get { return _targetRange; }
        set
        {
            _targetRange = value;
            sqrTargetRange = value*value;
        }
    }

    public float rewardRange;

    public NTGBattleUnitStatistic statistic = new NTGBattleUnitStatistic();

    public enum UnitStatus
    {
        Approach,
        Shoot,

        Stun,
        Knock,
        Blow,
        Slow,

        Count,
    }

    public enum ShootInterruptSource
    {
        None,
        Move,
        Kill,
        Skill,

        Stun,
        Blow,
    }

    public ShootInterruptSource interruptSource;

    public int MoveableCount;
    public int ShootableCount;
    public int[] GroupVisibleCount = new int[NTGBattleMainController.GroupCount];
    public int[] GroupLockableCount = new int[NTGBattleMainController.GroupCount];

    public bool Moveable
    {
        get { return alive && MoveableCount == 0 && !GetStatus(UnitStatus.Stun) && !GetStatus(UnitStatus.Blow); }
    }

    public bool Shootable
    {
        get { return alive && ShootableCount == 0 && !GetStatus(UnitStatus.Stun) && !GetStatus(UnitStatus.Blow); }
    }

    public bool Lockable(int group)
    {
        return alive && GroupVisibleCount[group - 1] <= 0 && GroupLockableCount[group - 1] <= 0;
    }

    public bool[] _status;

    [SerializeField] private int stealth;
    [SerializeField] private int antiStealth;

    public int Stealth
    {
        get { return stealth; }
        set
        {
            stealth = value;
            mainController.NotifyStealthChange();
        }
    }

    public int AntiStealth
    {
        get { return antiStealth; }
        set
        {
            antiStealth = value;
            mainController.NotifyStealthChange();
        }
    }

    public NTGBattleMainController mainController;
    public NavMeshAgent navAgent;

    public NTGBattleSkillController[] skills;
    public NTGBattlePassiveSkillController[] pSkills;
    public Transform passivesTransform;
    public ArrayList passives;

    public class UnitBuff
    {
        public string icon;
        public string desc;
        public float ratio;
    }

    public ArrayList unitBuffs;

    public Transform unitUiAnchor;

    public int[] randMap;
    public int randIndex;

    public int defaultNavPriority;

    public NTGBattleUnitViewController viewController;

    //public CullingGroup cullingGroup;
    //public BoundingSphere[] boundingSpheres;

    protected class HitRecord
    {
        public float time;
        public float hitValue;
        public NTGBattleSkillBehaviour.EffectType hitType;
        public NTGBattleUnitController shooter;
    }

    protected Queue hitRecords;

    //public void CullingStateChanged(CullingGroupEvent sphere)
    //{
    //    rendererVisible = sphere.isVisible;
    //    if (unitUiAnchor != null)
    //    {
    //        if (rendererVisible)
    //        {
    //            mainController.NewUnitUI(this);
    //        }
    //        else
    //        {
    //            mainController.ReleaseUnitUI(this);
    //        }
    //    }
    //}

    private NavMeshPath currentPath;
    private Vector3[] currentPathCorners = new Vector3[100];
    public bool currentPathValid;
    public int currentPathCornersCount;
    public int currentPathCornerIndex;
    public float currentCornerMoved;
    public float currentCornerDist;

    private Coroutine doUnitMoveCo;

    public bool UnitMove(Vector3 dest)
    {
        if (dest == transform.position)
        {
            currentPathValid = false;
            return true;
        }

        var valid = NavMesh.CalculatePath(transform.position, dest, NavMesh.AllAreas, currentPath);
        if (!valid)
        {
            NavMeshHit hit;
            if (NavMesh.SamplePosition(dest, out hit, 1.0f, NavMesh.AllAreas))
            {
                valid = NavMesh.CalculatePath(transform.position, hit.position, NavMesh.AllAreas, currentPath);
            }
        }

        if (valid)
        {
            currentPathCornersCount = currentPath.GetCornersNonAlloc(currentPathCorners);
            currentPathCornerIndex = 0;
            if (currentPathCornerIndex + 1 < currentPathCornersCount)
            {
                currentCornerMoved = 0;
                currentCornerDist = Vector3.Distance(currentPathCorners[currentPathCornerIndex], currentPathCorners[currentPathCornerIndex + 1]);

                if (doUnitMoveCo != null)
                    StopCoroutine(doUnitMoveCo);

                currentPathValid = true;
                doUnitMoveCo = StartCoroutine(doUnitMove());
            }
            else
            {
                currentPathValid = false;
            }
        }
        else
        {
            currentPathValid = false;
        }

        return currentPathValid;
    }

    private IEnumerator doUnitMove()
    {
        while (currentPathValid)
        {
            //boundingSpheres[0].position = transform.position;

            if (Moveable)
            {
                currentCornerMoved += MoveSpeed*Time.deltaTime;

                transform.position = Vector3.Lerp(currentPathCorners[currentPathCornerIndex], currentPathCorners[currentPathCornerIndex + 1], currentCornerMoved/currentCornerDist);
                transform.forward = Vector3.RotateTowards(transform.forward, currentPathCorners[currentPathCornerIndex + 1] - currentPathCorners[currentPathCornerIndex], 15.0f*Time.deltaTime, 0);

                if (currentCornerMoved >= currentCornerDist)
                {
                    currentPathCornerIndex++;
                    if (currentPathCornerIndex + 1 < currentPathCornersCount)
                    {
                        currentCornerMoved = 0;
                        currentCornerDist = Vector3.Distance(currentPathCorners[currentPathCornerIndex], currentPathCorners[currentPathCornerIndex + 1]);
                    }
                    else
                    {
                        currentPathValid = false;
                        yield break;
                    }
                }
            }

            yield return null;
        }
    }

    protected void Awake()
    {
        netService = TGNetService.GetInstance();

        netService.AddEventHandler("Hit", NetEventHanlder);
        netService.AddEventHandler("AddPassive", NetEventHanlder);
        netService.AddEventHandler("RemovePassive", NetEventHanlder);
        netService.AddEventHandler("Sync", NetEventHanlder);
        netService.AddEventHandler("Dest", NetEventHanlder);
        netService.AddEventHandler("Shoot", NetEventHanlder);

        randMap = new[] {10000, 9000, 8000, 7000, 6000, 5000, 4000, 3000, 2000, 1000, 0};
        randIndex = 0;

        _status = new bool[(int) UnitStatus.Count];

        unitUiAnchor = transform.Find("UnitUIAnchor");
        mainController = GameObject.Find("MainController").GetComponent<NTGBattleMainController>();
        navAgent = GetComponent<NavMeshAgent>();
        if (navAgent != null)
        {
            navAgent.enabled = false;
            navAgent.acceleration = 1000;
            navAgent.angularSpeed = 1000;

            //var navGo = new GameObject("NavAgent");
            //navGo.transform.parent = transform;
            //navGo.transform.localPosition = Vector3.zero;
            //navGo.transform.localRotation = Quaternion.identity;
            //var agent = navGo.AddComponent<NavMeshAgent>();
            //agent.radius = navAgent.radius;
            //agent.height = navAgent.height;
            //agent.acceleration = navAgent.acceleration;
            //agent.angularSpeed = navAgent.angularSpeed;
            //agent.avoidancePriority = navAgent.avoidancePriority;
            //Destroy(navAgent);
            //navAgent = agent;
            //navAgent.enabled = false;
        }
        currentPath = new NavMeshPath();

        passivesTransform = transform.Find("Passives");
        if (passivesTransform == null)
        {
            passivesTransform = (new GameObject("Passives")).transform;
            passivesTransform.parent = transform;
            passivesTransform.localPosition = Vector3.zero;
            passivesTransform.localRotation = Quaternion.Euler(Vector3.zero);
        }
        passives = new ArrayList();

        unitBuffs = new ArrayList();

        hitRecords = new Queue();

        if (GetComponent<Rigidbody>() == null)
        {
            var rigid = gameObject.AddComponent<Rigidbody>();
            rigid.useGravity = false;
            rigid.isKinematic = true;
        }

        unitCollider = GetComponent<CapsuleCollider>();
        if (unitCollider != null)
            unitCollider.enabled = false;

        if (navAgent != null)
        {
            defaultNavPriority = navAgent.avoidancePriority;
        }

        if (viewController == null)
        {
            var unitView = Instantiate(mainController.prefabs.Find("UnitView").gameObject).transform;
            unitView.name = "UnitView";
            unitView.parent = transform;
            unitView.localPosition = Vector3.zero;
            unitView.localRotation = Quaternion.identity;

            viewController = unitView.GetComponent<NTGBattleUnitViewController>();
        }

        //cullingGroup = new CullingGroup();
        //cullingGroup.targetCamera = Camera.main;
        //boundingSpheres = new BoundingSphere[1];
        //boundingSpheres[0] = new BoundingSphere(transform.position, 1.0f);

        //cullingGroup.SetBoundingSpheres(boundingSpheres);
        //cullingGroup.SetBoundingSphereCount(1);
        //cullingGroup.onStateChanged += CullingStateChanged;

        if (unitAnimator != null)
        {
            var rList = new ArrayList();
            foreach (var r in unitAnimator.GetComponentsInChildren<Renderer>())
            {
                rList.Add(r);
            }

            unitRenderers = new Renderer[rList.Count];
            rList.CopyTo(unitRenderers);

            foreach (var r in unitRenderers)
            {
                if (r.transform.parent == unitAnimator.transform)
                {
                    var vc = r.gameObject.GetComponent<NTGBattleVisibilityChecker>();
                    if (vc == null)
                        r.gameObject.AddComponent<NTGBattleVisibilityChecker>();
                    break;
                }
            }

#if UNITY_EDITOR
            foreach (Renderer r in unitRenderers)
            {
                foreach (var m in r.materials)
                {
                    if (m.shader.name == "NTG/Battle/Role")
                        m.shader = Shader.Find("NTG/Battle/Role");
                }
            }
#endif
        }

        if (unitFX == null || unitFX.Length == 0)
        {
            unitFX = new Transform[(int) UnitFX.Count];

            //for (int i = 0; i < (int) UnitFX.Count; i++)
            //{
            //    unitFX[i] = Instantiate(mainController.prefabs.Find(UnitFXResource[i]).gameObject).transform;
            //    unitFX[i].gameObject.name = UnitFXResource[i];
            //    unitFX[i].parent = transform;
            //    unitFX[i].localPosition = Vector3.zero;
            //    unitFX[i].localRotation = Quaternion.identity;
            //    unitFX[i].gameObject.SetActive(false);
            //}
        }

        unitActiveFX = new ArrayList();
    }

    public void OnEnable()
    {
        //if (unitFX != null)
        //{
        //    foreach (var fx in unitFX)
        //    {
        //        fx.gameObject.SetActive(false);
        //    }
        //}
    }

    public void Start()
    {
    }

    public void OnDestroy()
    {
        if (netService != null)
        {
            netService.RemoveEventHander("Hit", NetEventHanlder);
            netService.RemoveEventHander("AddPassive", NetEventHanlder);
            netService.RemoveEventHander("RemovePassive", NetEventHanlder);

            netService.RemoveEventHander("Sync", NetEventHanlder);
            netService.RemoveEventHander("Dest", NetEventHanlder);
            netService.RemoveEventHander("Shoot", NetEventHanlder);
        }

        //cullingGroup.Dispose();
        //cullingGroup = null;

        if (mainController.battleUnitsInActive.Contains(this))
            mainController.battleUnitsInActive.Remove(this);

        foreach (var skill in skills)
        {
            if (skill != null)
                Destroy(skill.gameObject);
        }
        foreach (var skill in pSkills)
        {
            if (skill != null)
                Destroy(skill.gameObject);
        }
    }

    public float NetEventTime;

    private bool NetEventHanlder(TGNetService.NetEvent e)
    {
        if (id != e.Content["Id"].ToObject<string>())
            return false;

        NetEventTime = Time.time;

        if (e.Type == "Hit")
        {
            ServerHit(e.Content["V"].ToObject<float>(), (NTGBattleSkillBehaviour.EffectType) e.Content["T"].ToObject<int>(), e.Content["S"].ToObject<string>(), e.Content["I"].ToObject<int>());

            return true;
        }

        if (e.Type == "AddPassive")
        {
            NotifyAddPassive(e.Content["N"].ToObject<string>(), e.Content["SId"].ToObject<string>(), e.Content["S"].ToObject<int>(), e.Content["P"].ToObject<float[]>(), e.Content["SP"].ToObject<string[]>());

            return true;
        }

        if (e.Type == "RemovePassive")
        {
            NotifyRemovePassive(e.Content["N"].ToObject<string>(), e.Content["SId"].ToObject<string>(), e.Content["S"].ToObject<int>());

            return true;
        }

        if (e.Type == "Sync")
        {
            syncTime = 0;

            var d = TGNetService.GetServerPassedTime(new DateTime(e.Content["T"].ToObject<long>()));
            if (d < 0)
            {
                Debug.LogError("Sync Delta Time Less than Zero");
            }

            serverPosition = new Vector3(e.Content["X"].ToObject<float>(), 0, e.Content["Z"].ToObject<float>());
            serverVelocity = new Vector3(e.Content["VX"].ToObject<float>(), 0, e.Content["VZ"].ToObject<float>());

            serverPosition += serverVelocity*d;

            return true;
        }

        if (e.Type == "Dest")
        {
            var dest = new Vector3(e.Content["X"].ToObject<float>(), 0, e.Content["Z"].ToObject<float>());
            var curr = new Vector3(e.Content["CX"].ToObject<float>(), 0, e.Content["CZ"].ToObject<float>());

            var currPos = new Vector3(curr.x, transform.position.y, curr.z);
            if ((transform.position - currPos).sqrMagnitude > 5.0f)
            {
                transform.position = currPos;
            }

            if (navAgent != null)
            {
                if (Moveable)
                {
                    navAgent.destination = new Vector3(dest.x, transform.position.y, dest.z);
                }
                else
                {
                    if (alive && navAgent.enabled)
                        navAgent.ResetPath();
                }
            }
            else
            {
                UnitMove(new Vector3(dest.x, transform.position.y, dest.z));
            }

            return true;
        }

        if (e.Type == "Shoot")
        {
            SkillShoot(e.Content["S"].ToObject<int>(), e.Content["T"].ToObject<string>(), e.Content["X"].ToObject<float>(), e.Content["Z"].ToObject<float>());

            return true;
        }

        return false;
    }

    public void Flash()
    {
        StartCoroutine(doFlash());
    }

    private Color normalColor = new Color(0, 0, 0, 0);

    private IEnumerator doFlash()
    {
        SetUnitColor(Color.white);
        yield return new WaitForSeconds(0.1f);
        SetUnitColor(Color.red);
        yield return new WaitForSeconds(0.1f);
        SetUnitColor(normalColor);
    }

    private void SetUnitColor(Color color)
    {
        foreach (Renderer r in unitRenderers)
        {
            foreach (var m in r.materials)
            {
                m.SetColor("_Color", color);
            }
        }
    }

    public Shader unitShader;

    public void SetTransparent(bool transparent)
    {
        foreach (Renderer r in unitRenderers)
        {
            if (transparent)
            {
                foreach (var m in r.materials)
                {
                    if (m.shader.name == "NTG/Battle/RoleDiffuse" || m.shader.name == "NTG/Battle/Role")
                    {
                        unitShader = m.shader;
                        m.shader = Shader.Find("NTG/Battle/RoleAlpha");
                    }
                    m.SetInt("_Hidden", 1);
                }
                PlayFX(UnitFX.Invisible, head: true);
            }
            else
            {
                StopFX(UnitFX.Invisible);
                foreach (var m in r.materials)
                {
                    if (m.shader.name == "NTG/Battle/RoleAlpha")
                    {
                        m.shader = unitShader;
                    }
                    m.SetInt("_Hidden", 0);
                }
            }
        }
    }

    public void SetVisibility(bool visibility)
    {
        this.visibility = visibility;

        if (visibility)
        {
            foreach (Renderer r in unitRenderers)
            {
                r.enabled = true;
            }

            if (alive)
                mainController.uiController.HideUnitUI(this, visibility);

            foreach (Transform activeFX in unitActiveFX)
            {
                activeFX.gameObject.SetActive(true);
                foreach (var fx in activeFX.GetComponentsInChildren<ParticleSystem>())
                {
                    fx.Stop();
                    fx.Play();
                }
            }
        }
        else
        {
            foreach (Renderer r in unitRenderers)
            {
                r.enabled = false;
            }

            mainController.uiController.HideUnitUI(this, visibility);

            foreach (Transform activeFX in unitActiveFX)
            {
                if (activeFX == null || activeFX.gameObject == null)
                {
                    Debug.LogError("active fx null" + activeFX.transform.name);
                }

                activeFX.gameObject.SetActive(false);
            }
        }
    }

    public virtual void Respawn()
    {
        alive = true;
        isEngage = false;
        //SetIdle(true);
        NetEventTime = Time.time;

        for (int i = 0; i < _status.Length; i++)
            _status[i] = false;

        for (int i = 0; i < GroupVisibleCount.Length; i++)
            GroupVisibleCount[i] = 0;

        for (int i = 0; i < unitFX.Length; i++)
        {
            if (unitFX[i] != null)
            {
                unitFX[i].gameObject.SetActive(false);
            }
        }

        foreach (var fx in unitPersistFX)
        {
            unitActiveFX.Add(fx);
        }

        if (unitCollider != null)
            unitCollider.enabled = true;

        foreach (var pSkill in pSkills)
        {
            pSkill.Respawn();
            pSkill.Notify(NTGBattlePassive.Event.Respawn, this);
        }

        SetVisibility(false);
        SetTransparent(false);
        viewController.Respawn(this);

        if (mainController.battleUnitsInActive.Contains(this))
            mainController.battleUnitsInActive.Remove(this);

        if (!mainController.battleUnits.Contains(this))
            mainController.battleUnits.Add(this);

        StartCoroutine(doRecover());
        //StartCoroutine(doUpdatePassive());
        //StartCoroutine(doUnitMove());

        //rendererVisible = cullingGroup.IsVisible(0);
        //if (unitUiAnchor != null)
        //{
        //    if (rendererVisible)
        //    {
        //        mainController.NewUnitUI(this);
        //    }
        //    else
        //    {
        //        mainController.ReleaseUnitUI(this);
        //    }
        //}
    }

    public virtual void LevelUp(int levels)
    {
        Debug.LogError("Unit LevelUp Function Not Implemented!");
    }

    public virtual void SkillShoot(int skillId, string targetId, float xOffset, float zOffset)
    {
        Debug.LogError("Unit SkillShoot Function Not Implemented!");
    }

    public virtual void Revive(NTGBattleUnitController healer)
    {
        Debug.LogError("Unit Revive Function Not Implemented!");
    }

    public virtual void Kill(NTGBattleUnitController killer)
    {
        SetStatus(UnitStatus.Shoot, false);
        interruptSource = ShootInterruptSource.Kill;

        alive = false;
        statistic.death++;

        currentPathValid = false;

        hp = 0;

        for (int i = passives.Count - 1; i >= 0; i--)
        {
            var pBehaviour = (NTGBattlePassiveSkillBehaviour) passives[i];
            pBehaviour.Notify(NTGBattlePassive.Event.Death, new NTGBattlePassive.EventDeathParam {killer = killer});
        }

        foreach (var pSkill in pSkills)
        {
            pSkill.Notify(NTGBattlePassive.Event.Death, new NTGBattlePassive.EventDeathParam {killer = killer});
        }

        for (int i = passives.Count - 1; i >= 0; i--)
        {
            var pBehaviour = (NTGBattlePassiveSkillBehaviour) passives[i];
            pBehaviour.Notify(NTGBattlePassive.Event.PassiveRemove, null);
        }

        mainController.battleUnits.Remove(this);

        if (mainController.battleUnitsInActive.Contains(this))
            Debug.LogError("battleUnitsInActive duplicate unit");
        mainController.battleUnitsInActive.Add(this);

        mainController.NotifyKill(id);

        foreach (Transform activeFX in unitActiveFX)
        {
            if (activeFX == null || activeFX.gameObject == null)
            {
                Debug.LogError("active fx null " + activeFX.name);
            }
            else
            {
                activeFX.gameObject.SetActive(false);
            }            
        }
        unitActiveFX.Clear();
    }

    public virtual void SetStatus(UnitStatus status, bool inState)
    {
        _status[(int) status] = inState;

        if (status == UnitStatus.Stun)
        {
            unitAnimator.SetBool("stun", inState);
        }
    }

    public bool GetStatus(UnitStatus status)
    {
        return _status[(int) status];
    }


    public enum NavPriority
    {
        Default = 9999,
        Mob = 75,
        MobStanding = 80,
        Player = 50,
        Attack = 25,
        Skill = 0,
    }

    public void SetNavPriority(NavPriority priority)
    {
        if (navAgent != null)
        {
            switch (priority)
            {
                case NavPriority.Default:
                    navAgent.avoidancePriority = defaultNavPriority;
                    break;
                case NavPriority.Mob:
                    navAgent.avoidancePriority = 75;
                    break;
                case NavPriority.Player:
                    navAgent.avoidancePriority = 50;
                    break;
                case NavPriority.Attack:
                    navAgent.avoidancePriority = 25;
                    break;
                case NavPriority.Skill:
                    navAgent.avoidancePriority = 0;
                    break;
            }
        }
    }

    private IEnumerator doRecover()
    {
        while (alive)
        {
            hp += hpRecover/5.0f;
            mp += mpRecover/5.0f;

            if (hp > hpMax)
                hp = hpMax;
            if (mp > mpMax)
                mp = mpMax;

            while (hitRecords.Count > 0 && Time.time - (hitRecords.Peek() as HitRecord).time > 15.0f)
            {
                hitRecords.Dequeue();
            }

            yield return new WaitForSeconds(1.0f);
        }
    }

    public void NotifyAddPassive(string passiveName, string shooterId, int skillId, float[] p, string[] sp)
    {
        NTGBattleUnitController shooter = null;
        if (shooterId != "")
            shooter = mainController.FindUnit(shooterId);
        NTGBattlePassiveSkillBehaviour pBehaviour = null;
        if (shooter != null)
        {
            var skill = shooter.FindSkill(skillId);
            if (skill != null)
            {
                pBehaviour = skill.FindPassiveSkillBehaviour(passiveName);
            }
        }

        addPassive(passiveName, shooter, pBehaviour, p, sp);
    }

    public void AddPassive(string passiveName, NTGBattleUnitController shooter = null, NTGBattleSkillController skillController = null, float[] p = null, string[] sp = null)
    {
        if (p == null)
            p = new float[0];
        if (sp == null)
            sp = new string[0];

        if (mainController.serverSimulation)
        {
            if (mainController.serverSimulator)
            {
                SyncAddPassive(passiveName, shooter, skillController, p, sp);
                addPassive(passiveName, shooter, skillController == null ? null : skillController.FindPassiveSkillBehaviour(passiveName), p, sp);
            }
        }
        else
        {
            if (master)
            {
                SyncAddPassive(passiveName, shooter, skillController, p, sp);
                addPassive(passiveName, shooter, skillController == null ? null : skillController.FindPassiveSkillBehaviour(passiveName), p, sp);
            }
        }
    }

    private void addPassive(string name, NTGBattleUnitController shooter, NTGBattlePassiveSkillBehaviour skillBehaviour, float[] p, string[] sp)
    {
        NTGBattlePassiveSkillBehaviour pBehaviour;

        if (skillBehaviour == null)
        {
            pBehaviour = mainController.NewPassiveSkillBehaviour(name);
        }
        else
        {
            pBehaviour = mainController.NewSkillBehaviour(skillBehaviour) as NTGBattlePassiveSkillBehaviour;
        }

        pBehaviour.Init(this, shooter, pBehaviour.skillController, p: p, sp: sp);

        addPassive(pBehaviour);
    }

    private void addPassive(NTGBattlePassiveSkillBehaviour pBehav)
    {
        bool isNew = true;

        for (int i = passives.Count - 1; i >= 0; i--)
        {
            var pBehaviour = (NTGBattlePassiveSkillBehaviour) passives[i];
            if (pBehaviour.passiveName == pBehav.passiveName)
            {
                pBehaviour.Notify(NTGBattlePassive.Event.PassiveAdd, pBehav);
                pBehav.Release();
                isNew = false;
                break;
            }
        }

        if (isNew)
        {
            pBehav.transform.parent = passivesTransform;
            pBehav.transform.localPosition = Vector3.zero;
            pBehav.transform.localRotation = Quaternion.Euler(Vector3.zero);

            passives.Add(pBehav);

            pBehav.Respawn();
        }
    }

    public void NotifyRemovePassive(string passiveName, string shooterId, int skillId)
    {
        NTGBattleUnitController shooter = null;
        if (shooterId != "")
            shooter = mainController.FindUnit(shooterId);
        NTGBattlePassiveSkillBehaviour pBehaviour = null;
        if (shooter != null)
        {
            var skill = shooter.FindSkill(skillId);
            if (skill != null)
            {
                pBehaviour = skill.FindPassiveSkillBehaviour(passiveName);
            }
        }

        removePassive(passiveName, pBehaviour);
    }

    public void RemovePassive(string passiveName, NTGBattleUnitController shooter = null, NTGBattleSkillController skillController = null)
    {
        if (mainController.serverSimulation)
        {
            if (mainController.serverSimulator)
            {
                SyncRemovePassive(passiveName, shooter, skillController);
                removePassive(passiveName, skillController == null ? null : skillController.FindPassiveSkillBehaviour(passiveName));
            }
        }
        else
        {
            if (master)
            {
                SyncRemovePassive(passiveName, shooter, skillController);
                removePassive(passiveName, skillController == null ? null : skillController.FindPassiveSkillBehaviour(passiveName));
            }
        }
    }

    private void removePassive(string passiveName, NTGBattlePassiveSkillBehaviour pBehav)
    {
        for (int i = passives.Count - 1; i >= 0; i--)
        {
            var pBehaviour = (NTGBattlePassiveSkillBehaviour) passives[i];
            if (pBehaviour.passiveName == passiveName)
            {
                pBehaviour.Notify(NTGBattlePassive.Event.PassiveRemove, pBehav);
                break;
            }
        }


        //var pBehaviour = mainController.NewPassiveSkillBehaviour(name);
        //if (pBehaviour == null)
        //    return;

        //RemovePassive(pBehaviour);
    }

    //private void RemovePassive(NTGBattlePassiveSkillBehaviour pBehav)
    //{
    //    for (int i = passives.Count - 1; i >= 0; i--)
    //    {
    //        var pBehaviour = (NTGBattlePassiveSkillBehaviour) passives[i];
    //        if (pBehaviour.passiveName == pBehav.passiveName)
    //        {
    //            pBehaviour.Notify(NTGBattlePassive.Event.PassiveRemove, pBehav);
    //            break;
    //        }
    //    }

    //    Destroy(pBehav.gameObject);
    //}

    private IEnumerator doUpdatePassive()
    {
        while (alive)
        {
            for (int i = passives.Count - 1; i >= 0; i--)
            {
                var pBehaviour = (NTGBattlePassiveSkillBehaviour) passives[i];
                pBehaviour.Notify(NTGBattlePassive.Event.PassiveUpdate, this);
            }

            yield return null;
        }
    }

    private int Rand()
    {
        int result = randMap[randIndex++];
        if (randIndex == randMap.Length)
            randIndex = 0;
        return result;
    }

    public void NotifyShoot(NTGBattleUnitController target, NTGBattleSkillController controller)
    {
        for (int i = passives.Count - 1; i >= 0; i--)
        {
            var pBehaviour = (NTGBattlePassiveSkillBehaviour) passives[i];
            pBehaviour.Notify(NTGBattlePassive.Event.Shoot, new NTGBattlePassive.EventShootParam {target = target, shooter = this, controller = controller});
        }

        foreach (var pSkill in pSkills)
        {
            pSkill.Notify(NTGBattlePassive.Event.Shoot, new NTGBattlePassive.EventShootParam {target = target, shooter = this, controller = controller});
        }

        Engage();
    }

    public void ShootVisible(int group)
    {
        StartCoroutine(doShootVisible(group));
    }

    private IEnumerator doShootVisible(int group)
    {
        var unitId = id;
        if (group == mainController.localGroup)
            viewController.UnitShow();
        GroupVisibleCount[group - 1]--;
        var d = 2.0f;
        while (alive && d > 0)
        {
            yield return null;
            d -= Time.deltaTime;
        }
        GroupVisibleCount[group - 1]++;
        if (unitId == id && group == mainController.localGroup && GroupVisibleCount[group - 1] > 0)
            viewController.UnitHide();
    }

    public bool isEngage;
    public float engageStartTime;

    public void Engage()
    {
        if (!isEngage)
        {
            isEngage = true;
            engageStartTime = Time.time;
            StartCoroutine(doEngage());

            for (int i = passives.Count - 1; i >= 0; i--)
            {
                var pBehaviour = (NTGBattlePassiveSkillBehaviour) passives[i];
                pBehaviour.Notify(NTGBattlePassive.Event.Engage, null);
            }

            foreach (var pSkill in pSkills)
            {
                pSkill.Notify(NTGBattlePassive.Event.Engage, null);
            }
        }
        else
        {
            engageStartTime = Time.time;
        }
    }

    private IEnumerator doEngage()
    {
        while (isEngage)
        {
            if (Time.time - engageStartTime > 10.0f)
            {
                isEngage = false;

                for (int i = passives.Count - 1; i >= 0; i--)
                {
                    var pBehaviour = (NTGBattlePassiveSkillBehaviour) passives[i];
                    pBehaviour.Notify(NTGBattlePassive.Event.Disengage, null);
                }

                foreach (var pSkill in pSkills)
                {
                    pSkill.Notify(NTGBattlePassive.Event.Disengage, null);
                }

                break;
            }
            yield return new WaitForSeconds(1.0f);
        }
    }

    public virtual void Hit(NTGBattleUnitController shooter, NTGBattleSkillBehaviour behav)
    {
        float a = mainController.configA;
        float b = mainController.configB;

        float effectValue = behav.baseValue + behav.pAdd*shooter.pAtk*(1.0f + shooter.pAtkRate) + behav.mAdd*shooter.mAtk*(1.0f + shooter.mAtkRate) + behav.hpAdd*shooter.hpMax + behav.mpAdd*shooter.mpMax;
        bool critical = false;

        if (behav.effectType == NTGBattleSkillBehaviour.EffectType.PhysicDamage)
        {
            float pdef = (this.pDef - shooter.pPenetrate)*(1 - shooter.pPenetrateRate);
            if (pdef < 0)
            {
                pdef = 0;
            }
            effectValue = effectValue*(1/(pdef/a + 1));
        }
        else if (behav.effectType == NTGBattleSkillBehaviour.EffectType.MagicDamage)
        {
            float mdef = (this.mDef - shooter.mPenetrate)*(1 - shooter.mPenetrateRate);
            if (mdef < 0)
            {
                mdef = 0;
            }
            effectValue = effectValue*(1/(mdef/b + 1));
        }

        if (behav.type == NTGBattleSkillType.Attack && behav.effectType != NTGBattleSkillBehaviour.EffectType.RealDamage)
        {
            if (Rand() < shooter.crit*10000)
            {
                effectValue = effectValue*shooter.critEffect;
                critical = true;
            }
        }

        for (int i = shooter.passives.Count - 1; i >= 0; i--)
        {
            var pBehaviour = (NTGBattlePassiveSkillBehaviour) shooter.passives[i];

            pBehaviour.Notify(NTGBattlePassive.Event.Hit, new NTGBattlePassive.EventHitParam {target = this, shooter = shooter, behaviour = behav, damage = effectValue, critical = critical});
        }
        for (int i = passives.Count - 1; i >= 0; i--)
        {
            var pBehaviour = (NTGBattlePassiveSkillBehaviour) passives[i];

            pBehaviour.Notify(NTGBattlePassive.Event.Hit, new NTGBattlePassive.EventHitParam { target = this, shooter = shooter, behaviour = behav, damage = effectValue, critical = critical });
        }


        for (int i = passives.Count - 1; i >= 0; i--)
        {
            var pBehaviour = (NTGBattlePassiveSkillBehaviour) passives[i];

            effectValue = pBehaviour.Filter(NTGBattlePassive.Filter.Hit, new NTGBattlePassive.EventHitParam {target = this, shooter = shooter, behaviour = behav, damage = effectValue}, effectValue);
        }

        foreach (var pSkill in shooter.pSkills)
        {
            pSkill.Notify(NTGBattlePassive.Event.Hit, new NTGBattlePassive.EventHitParam { target = this, shooter = shooter, behaviour = behav, damage = effectValue, critical = critical });
        }
        foreach (var pSkill in pSkills)
        {
            pSkill.Notify(NTGBattlePassive.Event.Hit, new NTGBattlePassive.EventHitParam { target = this, shooter = shooter, behaviour = behav, damage = effectValue, critical = critical });
        }

        if (this is NTGBattlePlayerController)
        {
            var pc = this as NTGBattlePlayerController;
            if (pc.isAI)
            {                
                pc.aic.Notify(NTGBattlePassive.Event.Hit, new NTGBattlePassive.EventHitParam { target = this, shooter = shooter, behaviour = behav, damage = effectValue, critical = critical });
            }
        }

        Engage();

        ClientHit(effectValue, behav.effectType, critical, shooter, behav);

        if (mainController.serverSimulation)
        {
            if (mainController.serverSimulator)
            {
                //SyncHit(id, shooter.id, behav.id);
                SyncHitDirect(id, shooter.id, effectValue, (int) behav.effectType, randIndex);
                ServerHit(effectValue, behav.effectType, shooter.id, randIndex);
            }
        }
        else
        {
            if (shooter.master)
            {
                //SyncHit(id, shooter.id, behav.id);
                SyncHitDirect(id, shooter.id, effectValue, (int) behav.effectType, randIndex);
                ServerHit(effectValue, behav.effectType, shooter.id, randIndex);
            }
        }
    }

    public virtual void ClientHit(float effectValue, NTGBattleSkillBehaviour.EffectType effectType, bool critical, NTGBattleUnitController shooter, NTGBattleSkillBehaviour behav)
    {
        mainController.uiController.ShowUnitDamage(this, effectValue, effectType, critical, shooter, behav);

        if (shooter == mainController.uiController.localPlayerController)
            mainController.mainCameraController.Shock(behav.shock);

        var mob = this as NTGBattleMobController;
        if (shooter == mainController.uiController.localPlayerController &&
            (this is NTGBattlePlayerController || (mob != null && mob.type == 2)) &&
            (behav.type == NTGBattleSkillType.Attack || behav.type == NTGBattleSkillType.HostileSkill || behav.type == NTGBattleSkillType.HostilePassive))
        {
            Flash();
        }

        var hitter = shooter as NTGBattlePlayerController;
        if (!mainController.voiceSource.isPlaying && hitter != null && hitter.voiceController != null && behav.skillController != null && behav.skillController.type == NTGBattleSkillType.HostileSkill)
        {
            hitter.voiceController.SkillHit(behav.skillController.id, this);
        }

        if (shooter.alive && shooter.GroupVisibleCount[group - 1] > 0)
            shooter.ShootVisible(group);
    }

    public void ServerHit(float effectValue, NTGBattleSkillBehaviour.EffectType effectType, string shooter, int randIndex)
    {
        if (!alive)
            return;

        this.randIndex = randIndex;

        var s = mainController.FindUnit(shooter);
        if (s != null)
        {
            if (effectType == NTGBattleSkillBehaviour.EffectType.PhysicDamage || effectType == NTGBattleSkillBehaviour.EffectType.MagicDamage || effectType == NTGBattleSkillBehaviour.EffectType.RealDamage)
            {
                if (this is NTGBattlePlayerController)
                {
                    s.statistic.damagePlayer += effectValue;
                }
                else if (this is NTGBattleMobController)
                {
                    var mc = this as NTGBattleMobController;
                    if (mc.type == 1)
                    {
                        s.statistic.damageMob += effectValue;
                    }
                    else if (mc.type == 2)
                    {
                        s.statistic.damageNeut += effectValue;
                    }
                    else if (mc.type == 3)
                    {
                        s.statistic.damageBuilding += effectValue;
                    }
                    else if (mc.type == 4)
                    {
                        s.statistic.damagePlayer += effectValue;
                    }
                }
            }

            if (s.pHpSteal > 0 && effectType == NTGBattleSkillBehaviour.EffectType.PhysicDamage)
            {
                s.hp += s.pHpSteal*effectValue;
            }
            if (s.mHpSteal > 0 && effectType == NTGBattleSkillBehaviour.EffectType.MagicDamage)
            {
                s.hp += s.mHpSteal*effectValue;
            }

            hitRecords.Enqueue(new HitRecord() {hitValue = effectValue, hitType = effectType, time = Time.time, shooter = s});
        }

        if (effectType == NTGBattleSkillBehaviour.EffectType.PhysicDamage || effectType == NTGBattleSkillBehaviour.EffectType.MagicDamage || effectType == NTGBattleSkillBehaviour.EffectType.RealDamage)
        {
            hp -= effectValue;
            statistic.damageReceive += effectValue;
        }
        if (effectType == NTGBattleSkillBehaviour.EffectType.HpRecover)
        {
            hp += effectValue;
            if (hp > hpMax)
                hp = hpMax;
        }
        if (effectType == NTGBattleSkillBehaviour.EffectType.MpRecover)
        {
            mp += effectValue;
            if (mp > mpMax)
                mp = mpMax;
        }

        if (hp <= 0)
        {
            AddPassive("Kill", s);
        }
    }

    public enum TargetType
    {
        All,
        Player,
        Mob,
        Base,
    }

    public enum TargetCondition
    {
        Closest,
        Lowest,
        Highest,
        Random,
    }

    public NTGBattleUnitController FindTarget(float range, bool ally = false, TargetCondition condition = TargetCondition.Closest, TargetType type = TargetType.All, ArrayList excludes = null, bool exNeutMob = false)
    {
        return FindTarget(transform.position, range, ally, condition, type, excludes, exNeutMob);
    }

    public NTGBattleUnitController FindTarget(Vector3 origin, float range, bool ally = false, TargetCondition condition = TargetCondition.Closest, TargetType type = TargetType.All, ArrayList excludes = null, bool exNeutMob = false)
    {
        NTGBattleUnitController target = null;
        float targetDist = float.MaxValue;

        if (type == TargetType.Base)
        {
            foreach (var mobbase in mainController.unitsBase.GetComponentsInChildren<NTGBattleMobBaseController>())
            {
                if ((ally == false && mobbase.group != group) || (ally == true && mobbase.group == group))
                {
                    target = mobbase;
                    break;
                }
            }
            return target;
        }

        ArrayList units;
        if (origin == transform.position && range <= targetRange)
        {
            units = viewController.unitsInView;
        }
        else
        {
            units = mainController.battleUnits;
        }

        var sqrRange = range*range;

        for (int u = 0; u < units.Count; u++)
        {
            var unit = units[u] as NTGBattleUnitController;

            if (unit.group == 0)
                continue;

            if (excludes != null)
            {
                var ex = false;
                foreach (NTGBattleUnitController exUnit in excludes)
                {
                    if (exUnit == unit)
                    {
                        ex = true;
                        break;
                    }
                }
                if (ex)
                    continue;
            }

            if (exNeutMob)
            {
                var mob = unit as NTGBattleMobController;
                if (mob != null && mob.type == 2)
                    continue;
            }

            if (!unit.Lockable(group) || (ally == false && unit.group == group) || (ally == true && (unit.group != group || unit == this)))
                continue;

            if ((type == TargetType.Mob && !(unit is NTGBattleMobController)) || (type == TargetType.Player && !(unit is NTGBattlePlayerController)))
                continue;

            var dist = (unit.transform.position - origin).sqrMagnitude;
            if (dist > sqrRange)
                continue;

            if (target == null || (condition == TargetCondition.Closest && dist < targetDist) || (condition == TargetCondition.Lowest && unit.hp < target.hp) || (condition == TargetCondition.Highest && unit.hp > target.hp))
            {
                target = unit;
                targetDist = dist;
            }
        }

        return target;
    }

    public NTGBattleSkillController FindSkill(int skillId)
    {
        for (int i = 0; i < skills.Length; i++)
        {
            if (skills[i].id == skillId)
            {
                return skills[i];
            }
        }

        for (int i = 0; i < pSkills.Length; i++)
        {
            if (pSkills[i].id == skillId)
            {
                return pSkills[i];
            }
        }

        return null;
    }

    public void InitAttrs(NTGBattleMemberAttrs attrs)
    {
        baseAttrs = new NTGBattleMemberAttrs();
        baseAttrs.Hp = attrs.Hp;
        baseAttrs.Mp = attrs.Mp;

        baseAttrs.HpRecover = attrs.HpRecover;
        baseAttrs.MpRecover = attrs.MpRecover;

        baseAttrs.PAtk = attrs.PAtk;
        baseAttrs.MAtk = attrs.MAtk;
        baseAttrs.PDef = attrs.PDef;
        baseAttrs.MDef = attrs.MDef;

        baseAttrs.PPenetrate = attrs.PPenetrate;
        baseAttrs.PPenetrate = attrs.MPenetrate;
        baseAttrs.PPenetrateRate = attrs.PPenetrateRate;
        baseAttrs.MPenetrateRate = attrs.MPenetrateRate;

        baseAttrs.Crit = attrs.Crit;
        baseAttrs.CritEffect = attrs.CritEffect;

        baseAttrs.PHpSteal = attrs.PHpSteal;
        baseAttrs.MHpSteal = attrs.MHpSteal;

        baseAttrs.Tough = attrs.Tough;
        baseAttrs.AtkSpeed = attrs.AtkSpeed;
        baseAttrs.CdReduce = attrs.CdReduce;
        baseAttrs.MoveSpeed = attrs.MoveSpeed;

        LoadBaseAttrs();
    }

    public void LoadBaseAttrs()
    {
        hp = baseAttrs.Hp;
        hpMax = baseAttrs.Hp;
        mp = baseAttrs.Mp;
        mpMax = baseAttrs.Mp;

        hpRecover = baseAttrs.HpRecover;
        mpRecover = baseAttrs.MpRecover;

        pAtk = baseAttrs.PAtk;
        mAtk = baseAttrs.MAtk;
        pDef = baseAttrs.PDef;
        mDef = baseAttrs.MDef;

        pAtkRate = baseAttrs.pAtkRate;
        mAtkRate = baseAttrs.mAtkRate;

        pPenetrate = baseAttrs.PPenetrate;
        mPenetrate = baseAttrs.MPenetrate;
        pPenetrateRate = baseAttrs.PPenetrateRate;
        mPenetrateRate = baseAttrs.MPenetrateRate;

        crit = baseAttrs.Crit;
        critEffect = baseAttrs.CritEffect;

        pHpSteal = baseAttrs.PHpSteal;
        mHpSteal = baseAttrs.MHpSteal;

        tough = baseAttrs.Tough;
        atkSpeed = baseAttrs.AtkSpeed;
        cdReduce = baseAttrs.CdReduce;

        MoveSpeed = baseAttrs.MoveSpeed;
    }

    public void ApplyBaseAttrs()
    {
        var ohp = hp;
        var omp = mp;
        var oHpMax = hpMax;
        var oMpMax = mpMax;

        LoadBaseAttrs();

        hp = ohp;
        mp = omp;

        if (alive)
        {
            if (hpMax > oHpMax)
                hp += hpMax - oHpMax;
            if (mpMax > oMpMax)
                mp += mpMax - oMpMax;
        }

        ValidateAttrs();
    }

    public void ValidateAttrs()
    {
        if (hpMax < 0)
            hpMax = 0;

        if (hp > hpMax)
            hp = hpMax;
        if (hp < 0)
            hp = 0;

        if (mpMax < 0)
            mpMax = 0;

        if (mp > mpMax)
            mp = mpMax;
        if (mp < 0)
            mp = 0;

        if (hpRecover < 0)
            hpRecover = 0;
        if (mpRecover < 0)
            mpRecover = 0;

        if (pAtk < 0)
            pAtk = 0;
        if (mAtk < 0)
            mAtk = 0;

        if (pAtkRate < 0)
            pAtkRate = 0;
        if (mAtkRate < 0)
            mAtkRate = 0;

        if (pPenetrate < 0)
            pPenetrate = 0;
        if (mPenetrate < 0)
            mPenetrate = 0;
        if (pPenetrateRate < 0)
            pPenetrateRate = 0;
        if (mPenetrateRate < 0)
            mPenetrateRate = 0;

        if (crit < 0)
            crit = 0;
        if (critEffect < 0)
            critEffect = 0;

        if (pHpSteal < 0)
            pHpSteal = 0;
        if (mHpSteal < 0)
            mHpSteal = 0;

        if (tough < 0)
            tough = 0;
 
        if (atkSpeed > 2.0f)
            atkSpeed = 2.0f;

        if (cdReduce < 0)
            cdReduce = 0;

        if (MoveSpeed < 0)
            MoveSpeed = 0;
    }

    public void AddAttrs(NTGBattleMemberAttrs attrs)
    {
        baseAttrs.Hp += attrs.Hp;
        baseAttrs.Mp += attrs.Mp;

        baseAttrs.HpRecover += attrs.HpRecover;
        baseAttrs.MpRecover += attrs.MpRecover;

        baseAttrs.PAtk += attrs.PAtk;
        baseAttrs.MAtk += attrs.MAtk;
        baseAttrs.PDef += attrs.PDef;
        baseAttrs.MDef += attrs.MDef;

        baseAttrs.PPenetrate += attrs.PPenetrate;
        baseAttrs.MPenetrate += attrs.MPenetrate;
        baseAttrs.PPenetrateRate += attrs.PPenetrateRate;
        baseAttrs.MPenetrateRate += attrs.MPenetrateRate;

        baseAttrs.Crit += attrs.Crit;
        baseAttrs.CritEffect += attrs.CritEffect;

        baseAttrs.PHpSteal += attrs.PHpSteal;
        baseAttrs.MHpSteal += attrs.MHpSteal;

        baseAttrs.Tough += attrs.Tough;
        baseAttrs.AtkSpeed += attrs.AtkSpeed;
        baseAttrs.CdReduce += attrs.CdReduce;
        baseAttrs.MoveSpeed += attrs.MoveSpeed;

        ApplyBaseAttrs();
    }

    public void MinusAttrs(NTGBattleMemberAttrs attrs)
    {
        baseAttrs.Hp -= attrs.Hp;
        baseAttrs.Mp -= attrs.Mp;

        baseAttrs.HpRecover -= attrs.HpRecover;
        baseAttrs.MpRecover -= attrs.MpRecover;

        baseAttrs.PAtk -= attrs.PAtk;
        baseAttrs.MAtk -= attrs.MAtk;
        baseAttrs.PDef -= attrs.PDef;
        baseAttrs.MDef -= attrs.MDef;

        baseAttrs.PPenetrate -= attrs.PPenetrate;
        baseAttrs.MPenetrate -= attrs.MPenetrate;
        baseAttrs.PPenetrateRate -= attrs.PPenetrateRate;
        baseAttrs.MPenetrateRate -= attrs.MPenetrateRate;

        baseAttrs.Crit -= attrs.Crit;
        baseAttrs.CritEffect -= attrs.CritEffect;

        baseAttrs.PHpSteal -= attrs.PHpSteal;
        baseAttrs.MHpSteal -= attrs.MHpSteal;

        baseAttrs.Tough -= attrs.Tough;
        baseAttrs.AtkSpeed -= attrs.AtkSpeed;
        baseAttrs.CdReduce -= attrs.CdReduce;
        baseAttrs.MoveSpeed -= attrs.MoveSpeed;

        ApplyBaseAttrs();
    }

    //public void SyncHit(string targetId, string shooterId, int behavId)
    //{     
    //    netService.SendRequest(
    //        new TGNetService.NetRequest
    //        {
    //            Content =
    //                new JObject(new JProperty("Type", "Hit"),
    //                    new JProperty("T", targetId),
    //                    new JProperty("S", shooterId),
    //                    new JProperty("B", behavId)),
    //            FlowOpt = true
    //        });
    //}

    public void SyncHitDirect(string targetId, string shooterId, float effectValue, int effectType, int randIndex)
    {
        var request = netService.pool.NewRequest("Hit");
        if (request == null)
        {
            request = new TGNetService.NetRequest
            {
                Content =
                    new JObject(new JProperty("Type", "Hit"),
                        new JProperty("Id", targetId),
                        new JProperty("V", effectValue),
                        new JProperty("T", effectType),
                        new JProperty("S", shooterId),
                        new JProperty("I", randIndex)),
                FlowOpt = true
            };
        }
        else
        {
            request.Content["Id"] = targetId;
            request.Content["V"] = effectValue;
            request.Content["T"] = effectType;
            request.Content["S"] = shooterId;
            request.Content["I"] = randIndex;
        }

        netService.SendRequest(request);
    }

    public void SyncAddPassive(string passiveName, NTGBattleUnitController shooter, NTGBattleSkillController skillController, float[] p, string[] sp)
    {
        var request = netService.pool.NewRequest("AddPassive");
        if (request == null)
        {
            request = new TGNetService.NetRequest
            {
                Content =
                    new JObject(new JProperty("Type", "AddPassive"),
                        new JProperty("Id", id),
                        new JProperty("SId", shooter == null ? "" : shooter.id),
                        new JProperty("S", skillController == null ? 0 : skillController.id),
                        new JProperty("N", passiveName),
                        new JProperty("P", p),
                        new JProperty("SP", sp)),
                FlowOpt = true
            };
        }
        else
        {
            request.Content["Id"] = id;
            request.Content["SId"] = shooter == null ? "" : shooter.id;
            request.Content["S"] = skillController == null ? 0 : skillController.id;
            request.Content["N"] = passiveName;
            request.Content["P"] = JToken.FromObject(p);
            request.Content["SP"] = JToken.FromObject(sp);
        }

        netService.SendRequest(request);
    }

    public void SyncRemovePassive(string passiveName, NTGBattleUnitController shooter, NTGBattleSkillController skillController)
    {
        var request = netService.pool.NewRequest("RemovePassive");
        if (request == null)
        {
            request = new TGNetService.NetRequest
            {
                Content =
                    new JObject(new JProperty("Type", "RemovePassive"),
                        new JProperty("Id", id),
                        new JProperty("SId", shooter == null ? "" : shooter.id),
                        new JProperty("S", skillController == null ? 0 : skillController.id),
                        new JProperty("N", passiveName)),
                FlowOpt = true
            };
        }
        else
        {
            request.Content["Id"] = id;
            request.Content["SId"] = shooter == null ? "" : shooter.id;
            request.Content["S"] = skillController == null ? 0 : skillController.id;
            request.Content["N"] = passiveName;
        }

        netService.SendRequest(request);
    }

    public void SyncDest(Vector3 dest)
    {
        if (!master)
            return;

        var request = netService.pool.NewRequest("Dest");
        if (request == null)
        {
            request = new TGNetService.NetRequest
            {
                Content =
                    new JObject(new JProperty("Type", "Dest"),
                        new JProperty("Id", id),
                        new JProperty("X", dest.x),
                        new JProperty("Z", dest.z),
                        new JProperty("CX", transform.position.x),
                        new JProperty("CZ", transform.position.z)),
                FlowOpt = true
            };
        }
        else
        {
            request.Content["Id"] = id;
            request.Content["X"] = dest.x;
            request.Content["Z"] = dest.z;
            request.Content["CX"] = transform.position.x;
            request.Content["CZ"] = transform.position.z;
        }

        netService.SendRequest(request);
    }

    public void SyncShoot(int skillId, string targetId, float xOffset, float zOffset)
    {
        if (!master)
            return;

        var request = netService.pool.NewRequest("Shoot");
        if (request == null)
        {
            request = new TGNetService.NetRequest
            {
                Content = new JObject(new JProperty("Type", "Shoot"),
                    new JProperty("Id", id),
                    new JProperty("S", skillId),
                    new JProperty("T", targetId),
                    new JProperty("X", xOffset),
                    new JProperty("Z", zOffset)),
                FlowOpt = true
            };
        }
        else
        {
            request.Content["Id"] = id;
            request.Content["S"] = skillId;
            request.Content["T"] = targetId;
            request.Content["X"] = xOffset;
            request.Content["Z"] = zOffset;
        }

        netService.SendRequest(request);
    }

    public const float SyncTimeLimit = 0.5f;
    public float syncTime;

    public Vector3 serverPosition;
    public Vector3 serverVelocity;

    private void Sync()
    {
        if (navAgent == null)
            return;

        var request = netService.pool.NewRequest("Sync");
        if (request == null)
        {
            request = new TGNetService.NetRequest
            {
                Content =
                    new JObject(new JProperty("Type", "Sync"),
                        new JProperty("Id", id),
                        new JProperty("T", TGNetService.GetServerTime().Ticks),
                        new JProperty("X", transform.position.x),
                        new JProperty("Z", transform.position.z),
                        new JProperty("VX", navAgent.velocity.x),
                        new JProperty("VZ", navAgent.velocity.z)),
                FlowOpt = true
            };
        }
        else
        {
            request.Content["Id"] = id;
            request.Content["T"] = TGNetService.GetServerTime().Ticks;
            request.Content["X"] = transform.position.x;
            request.Content["Z"] = transform.position.z;
            request.Content["VX"] = navAgent.velocity.x;
            request.Content["VZ"] = navAgent.velocity.z;
        }

        netService.SendRequest(request);

        serverPosition = transform.position;
        serverVelocity = navAgent.velocity;
    }

    protected IEnumerator doSyncMaster()
    {
        float syncTime = 0;
        Vector3 syncPosition = transform.position;

        while (alive)
        {
            serverPosition += serverVelocity*Time.deltaTime;

            if ((transform.position - serverPosition).sqrMagnitude > 0.01f || (syncTime > (SyncTimeLimit - 0.05f) && (transform.position - syncPosition).sqrMagnitude > 0.01f))
            {
                Sync();

                syncTime = 0;
                syncPosition = transform.position;
            }

            yield return null;

            syncTime += Time.deltaTime;
        }
    }

    protected IEnumerator doSyncSlave()
    {
        serverPosition = transform.position;
        serverVelocity = Vector3.zero;

        while (alive)
        {
            serverPosition += serverVelocity*Time.deltaTime;

            var newPos = new Vector3(serverPosition.x, transform.position.y, serverPosition.z);
            if ((transform.position - newPos).sqrMagnitude > 5.0f)
            {
                transform.position = newPos;
            }

            var v = serverVelocity.sqrMagnitude;

            if (navAgent != null)
            {
                if (Moveable && syncTime < SyncTimeLimit && v > 0)
                {
                    if (navAgent.enabled)
                        navAgent.destination = newPos;
                }
                else
                {
                    if (alive && navAgent.enabled)
                        navAgent.ResetPath();
                }
            }
            else
            {
                if (v > 0)
                {
                    UnitMove(newPos);
                }
                else
                {
                    UnitMove(transform.position);
                }
            }

            yield return null;

            syncTime += Time.deltaTime;
        }
    }
}