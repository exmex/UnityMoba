using System;
using System.Collections.Generic;
using System.IO;
using LuaInterface;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using UnityEngine;
using System.Collections;


public class NTGBattleMainController : MonoBehaviour
{
    public string DebugRole;

    public enum TargetMode
    {
        Locked,
        Smart
    }

    public TargetMode targetMode;

    public float configA;
    public float configB;
    public float configX;
    public float configYPlayer;
    public float configYMob;

    public Transform unitsBase;
    public Transform poolBase;
    public Transform skillTemplates;
    public Transform respawn;
    public Transform prefabs;
    public Transform dynamics;
    public Transform globalPassives;
    public Transform miniMapScaler;
    public Camera mainCamera;
    public AudioSource voiceSource;

    public NTGBattleMainCameraController mainCameraController;
    public UTGBattleFogController fogController;
    public NTGBattleUIController uiController;

    public string localId;
    public int localGroup;
    public static int GroupCount = 3;

    public ArrayList groupInfos;

    private Dictionary<string, int> killCount;
    public float battleStartTime;

    public string host;
    public bool serverSimulation;
    public bool serverSimulator;

    public bool firstBlood;
    public NTGBattleSceneInfo sceneInfo;

    private TGNetService netService;

    public void OnDestroy()
    {
        //netService.RemoveEventHander("Connect", NetEventHanlder);
        netService.RemoveEventHander("Disconnect", NetEventHanlder);
        netService.RemoveEventHander("BattleEventReconnect", NetEventHanlder);
        netService.RemoveEventHander("BattleEventConnect", NetEventHanlder);
        netService.RemoveEventHander("BattleEventStart", NetEventHanlder);
        netService.RemoveEventHander("BattleEventRespawn", NetEventHanlder);
        netService.RemoveEventHander("BattleEventPVPEnd", NetEventHanlder);
        netService.RemoveEventHander("BattleEventReported", NetEventHanlder);
    }


    public NTGBattlePlayerController LoadPlayer(string id, int position, int group, string roleResource)
    {
        var player = prefabs.Find("Role" + roleResource);
        if (player == null)
        {
            var load = Resources.Load<GameObject>("Role" + roleResource);
            if (load == null)
            {
                Debug.LogError("Role" + roleResource + " Resources not Found ");
                return null;
            }
            player = load.transform;
        }

        player = Instantiate(player.gameObject).transform;
        player.name = String.Format("Player({0})", id);
        player.parent = respawn.Find("Start/Start-" + position);
        player.localPosition = Vector3.zero;
        player.localRotation = Quaternion.Euler(Vector3.zero);

        var pc = player.GetComponent<NTGBattlePlayerController>();
        pc.id = id;
        pc.position = position;
        pc.group = group;

        var groupBase = unitsBase.Find(group.ToString());
        if (groupBase == null)
        {
            groupBase = (new GameObject(group.ToString())).transform;
            groupBase.parent = unitsBase;
            groupBase.localPosition = Vector3.zero;
            groupBase.localRotation = Quaternion.identity;
        }
        player.parent = groupBase;

        return pc;
    }

    public NTGBattleMobController LoadMob(string type, string id, string resource, int position, int group)
    {
        var rs = resource.Split(',');
        if (rs.Length > 1)
        {
            if (group == localGroup)
            {
                resource = rs[0];
            }
            else
            {
                resource = rs[1];
            }
        }

        var building = prefabs.Find(type + resource);
        if (building == null)
        {
            var load = Resources.Load<GameObject>(type + resource);
            if (load == null)
            {
                Debug.LogError(type + " Resources not Found " + resource);
            }
            building = load.transform;
        }

        building = Instantiate(building.gameObject).transform;
        building.name = String.Format("{0}({1})", type, id);
        building.parent = respawn.Find(String.Format("{0}/{0}-{1}", type, position));
        building.localPosition = Vector3.zero;
        building.localRotation = Quaternion.Euler(Vector3.zero);

        var groupBase = unitsBase.Find(group.ToString());
        if (groupBase == null)
        {
            groupBase = (new GameObject(group.ToString())).transform;
            groupBase.parent = unitsBase;
            groupBase.localPosition = Vector3.zero;
            groupBase.localRotation = Quaternion.identity;
        }
        building.parent = groupBase;

        return building.GetComponent<NTGBattleMobController>();
    }

    public void PreLoadMob(string type, string resource)
    {
        var rs = resource.Split(',');
        foreach (var r in rs)
        {
            var mob = prefabs.Find(type + r);
            if (mob == null)
            {
                var load = Resources.Load<GameObject>(type + r);
                if (load == null)
                {
                    Debug.LogError(type + " Resources not Found " + r);
                }
                mob = Instantiate(load).transform;
            }

            mob.name = type + r;
            mob.parent = prefabs;
            mob.localPosition = Vector3.zero;
            mob.localRotation = Quaternion.Euler(Vector3.zero);
        }
    }

    public LuaTable NewUnitUI(NTGBattleUnitController unit)
    {
        if (uiController.unitUiMap.ContainsKey(unit))
        {
            //Debug.LogError("Unit UI Duplicate On New");
            return uiController.unitUiMap[unit];
        }

        string type;
        int subType;

        if (unit is NTGBattlePlayerController)
        {
            type = "Players";

            if (unit.group == localGroup)
            {
                if (unit.id == localId)
                {
                    subType = 3;
                }
                else
                {
                    subType = 1;
                }
            }
            else
            {
                subType = 2;
            }
        }
        else if (unit is NTGBattleMobTowerController || unit is NTGBattleMobBaseController)
        {
            type = "Towers";
            if (unit.group == localGroup)
            {
                subType = 4;
            }
            else
            {
                subType = 5;
            }
        }
        else
        {
            type = "Soldiers";
            if (unit.group == localGroup)
            {
                subType = 6;
            }
            else
            {
                subType = 7;
            }
        }


        var poolgroup = poolBase.Find(type);
        if (poolgroup == null)
        {
            poolgroup = (new GameObject(type)).transform;
            poolgroup.parent = poolBase;
            poolgroup.localPosition = Vector3.zero;
            poolgroup.localRotation = Quaternion.identity;
        }

        var unitUi = poolgroup.Find(type);
        if (unitUi == null)
        {
            unitUi = Instantiate(uiController.unitUiTemplate.gameObject).transform;
            unitUi.name = type;
        }

        unitUi.SetParent(uiController.unitUiBase.Find(type));
        unitUi.localScale = Vector3.one;
        unitUi.gameObject.SetActive(true);

        unit.unitUi = unitUi;

        foreach (var luaScript in unitUi.GetComponents<NTGLuaScript>())
        {
            if (luaScript.luaScript == "Logic.M022.UIBattle.UIPlayerInfo")
            {
                NTGApplicationController.Instance.LuaCall("UIPlayerInfo", "SetUIOwner", luaScript.self, subType);

                uiController.unitUiMap.Add(unit, luaScript.self);

                return luaScript.self;
            }
        }

        return null;
    }

    public void ReleaseUnitUI(NTGBattleUnitController unit)
    {
        if (poolBase == null || unit.unitUi == null)
            return;

        if (!uiController.unitUiMap.ContainsKey(unit))
        {
            //Debug.LogError("Unit UI Not Exist On Relase");
            return;
        }

        string type;
        if (unit is NTGBattlePlayerController)
        {
            type = "Players";
        }
        else if (unit is NTGBattleMobTowerController || unit is NTGBattleMobBaseController)
        {
            type = "Towers";
        }
        else
        {
            type = "Soldiers";
        }

        uiController.unitUiMap.Remove(unit);

        var poolgroup = poolBase.Find(type);
        if (poolgroup == null)
        {
            Debug.LogError("UnitUI Folder Not Found On Release " + type);
        }

        unit.unitUi.gameObject.SetActive(false);
        unit.unitUi.SetParent(poolgroup);
        unit.unitUi.localPosition = Vector3.zero;
        unit.unitUi = null;
    }

    public NTGBattleMobController NewMob(string type, string id, string resource, int position, int group, string formationResource = null, int slot = 0)
    {
        var rs = resource.Split(',');
        if (rs.Length > 1)
        {
            if (group == localGroup)
            {
                resource = rs[0];
            }
            else
            {
                resource = rs[1];
            }
        }

        var mobgroup = poolBase.Find(type + resource);
        if (mobgroup == null)
        {
            mobgroup = (new GameObject(type + resource)).transform;
            mobgroup.parent = poolBase;
            mobgroup.localPosition = Vector3.zero;
            mobgroup.localRotation = Quaternion.Euler(Vector3.zero);
        }

        var mob = mobgroup.Find(type + resource);
        if (mob == null)
        {
            mob = prefabs.Find(type + resource);
            if (mob == null)
            {
                Debug.LogError(type + " Resources not Preloaded" + resource);
            }

            mob = Instantiate(mob.gameObject).transform;
            mob.name = String.Format("{0}{1}", type, resource);
            mob.parent = mobgroup;
            mob.localPosition = Vector3.zero;
            mob.localRotation = Quaternion.Euler(Vector3.zero);
        }

        var gp = respawn.Find(String.Format("{0}/{0}-{1}", type, position));
        if (formationResource != null && formationResource != "")
        {
            var formation = GetFormation(formationResource);
            formation.position = gp.position;
            formation.rotation = gp.rotation;

            var mp = formation.Find(slot.ToString());
            mob.position = mp.position;
            mob.rotation = mp.rotation;

            formation.localPosition = Vector3.zero;
            formation.localRotation = Quaternion.identity;
        }
        else
        {
            mob.position = gp.position;
            mob.rotation = gp.rotation;
        }

        mob.gameObject.SetActive(true);

        var groupBase = unitsBase.Find(group.ToString());
        if (groupBase == null)
        {
            groupBase = (new GameObject(group.ToString())).transform;
            groupBase.parent = unitsBase;
            groupBase.localPosition = Vector3.zero;
            groupBase.localRotation = Quaternion.identity;
        }
        mob.parent = groupBase;

        return mob.gameObject.GetComponent<NTGBattleMobController>();
    }

    public void ReleaseMob(NTGBattleMobController mob)
    {
        var mobgroup = poolBase.Find(mob.gameObject.name);
        if (mobgroup == null)
        {
            Debug.LogError("Mob Folder Not Found On Release " + mob.gameObject.name);
        }

        if (mobgroup.childCount < 2)
        {
            NTGBattlePassiveSkillBehaviour[] pBebavs = new NTGBattlePassiveSkillBehaviour[mob.passives.Count];
            mob.passives.CopyTo(pBebavs);
            foreach (var pb in pBebavs)
            {
                ReleaseSkillBehaviour(pb);
            }

            mob.gameObject.SetActive(false);
            mob.transform.parent = mobgroup;
            mob.transform.localPosition = Vector3.zero;
            mob.transform.localRotation = Quaternion.Euler(Vector3.zero);
        }
        else
        {
            Destroy(mob.gameObject);
        }
    }

    private Transform GetFormation(string resource)
    {
        var formation = prefabs.Find("Formation" + resource);
        if (formation == null)
        {
            var load = Resources.Load<GameObject>("Formation" + resource);
            if (load == null)
            {
                Debug.LogError("Formation Resources not Found " + resource);
            }
            formation = Instantiate(load).transform;
        }

        formation.name = "Formation" + resource;
        formation.parent = prefabs;
        formation.localPosition = Vector3.zero;
        formation.localRotation = Quaternion.identity;

        return formation;
    }

    public NTGBattleSkillController AddPlayerSkill(NTGBattlePlayerController pc, string resource)
    {
        var skill = prefabs.Find("Skill" + resource);
        if (skill == null)
        {
            var load = Resources.Load<GameObject>("Skill" + resource);
            if (load == null)
            {
                Debug.LogError("Skill Resources not Found " + resource);
            }
            skill = Instantiate(load).transform;
            skill.name = "Skill" + resource;
            skill.parent = prefabs;
            skill.localPosition = Vector3.zero;
            skill.localRotation = Quaternion.identity;
        }

        skill = Instantiate(skill).transform;
        skill.name = "Skill" + resource;
        skill.parent = pc.transform;
        skill.localPosition = Vector3.zero;
        skill.localRotation = Quaternion.identity;

        var sc = skill.gameObject.GetComponent<NTGBattleSkillController>();
        sc.owner = pc;

        return sc;
    }

    public NTGBattleSkillBehaviour PreLoadSkillBehaviour(string resource)
    {
        var skill = prefabs.Find("Skill" + resource);
        if (skill == null)
        {
            var load = Resources.Load<GameObject>("Skill" + resource);
            if (load == null)
            {
                Debug.LogWarning("Skill Resources not found in native Resource trying to find assetbunle " + resource);
                load = NTGResourceController.Instance.LoadAsset("Skill" + resource, "Skill" + resource);
                if (load == null)
                {
                    Debug.LogError("Skill Resources not found in assetbunle " + resource);
                }
            }
            skill = Instantiate(load).transform;
        }

        skill.name = "Skill" + resource;
        skill.parent = prefabs;
        skill.localPosition = Vector3.zero;
        skill.localRotation = Quaternion.identity;

        return skill.GetComponent<NTGBattleSkillBehaviour>();
    }

    private Dictionary<string, NTGBattleSkillBehaviour> passiveSkillBehavioursMap = new Dictionary<string, NTGBattleSkillBehaviour>();

    public void RegisterPassiveSkillBehaviour(string name, NTGBattleSkillBehaviour behaviour)
    {
        passiveSkillBehavioursMap[name] = behaviour;
    }

    public NTGBattlePassiveSkillBehaviour NewPassiveSkillBehaviour(string name)
    {
        return NewSkillBehaviour(passiveSkillBehavioursMap[name]) as NTGBattlePassiveSkillBehaviour;
    }

    public NTGBattleSkillBehaviour NewSkillBehaviour(NTGBattleSkillBehaviour template)
    {
        var skillgroup = poolBase.Find(template.name);
        if (skillgroup == null)
        {
            skillgroup = (new GameObject(template.name)).transform;
            skillgroup.parent = poolBase;
            skillgroup.localPosition = Vector3.zero;
            skillgroup.localRotation = Quaternion.Euler(Vector3.zero);
        }

        var skill = skillgroup.Find(template.name);
        if (skill == null)
        {
            skill = Instantiate(template.gameObject).transform;
            skill.name = template.name;
            skill.parent = skillgroup;
            skill.localPosition = Vector3.zero;
            skill.localRotation = Quaternion.Euler(Vector3.zero);
        }

        skill.parent = dynamics;
        skill.gameObject.SetActive(true);

        var behaviour = skill.GetComponent<NTGBattleSkillBehaviour>();
        behaviour.Init(template);

        return behaviour;
    }

    public void ReleaseSkillBehaviour(NTGBattleSkillBehaviour skill)
    {
        var skillgroup = poolBase.Find(skill.gameObject.name);
        if (skillgroup == null)
        {
            Debug.LogError("Skill Folder Not Found On Release " + skill.gameObject.name);
        }

        var passive = skill as NTGBattlePassiveSkillBehaviour;
        if (passive != null)
        {
            skill.owner.passives.Remove(passive);
        }

        if (skillgroup.childCount < 2)
        {
            skill.gameObject.SetActive(false);
            skill.transform.parent = skillgroup;
            skill.transform.localPosition = Vector3.zero;
            skill.transform.localRotation = Quaternion.Euler(Vector3.zero);
        }
        else
        {
            Destroy(skill.gameObject);
        }
    }

    public bool DebugMode;

    private LuaTable loadingApi;

    private void Start()
    {
        NTGResourceController.Instance.BattlePreClearAssetBundle();

        loadingApi = NTGApplicationController.Instance.LuaGetTable("PVPBattleLoadingAPI_1.Instance");
        NTGApplicationController.Instance.LuaCall("PVPBattleLoadingAPI_1", "SetLoadProgress", loadingApi, 51);

        NTGBattleDataController.LoadData();

        //var res = GameObject.Find("Respawn");
        //if (res != null)
        //{
        //    respawn = res.transform;
        //    Destroy(debugGround.gameObject);
        //    Destroy(GameObject.Find("RespawnPrefab"));
        //}
        //else
        //{
        //    respawn = GameObject.Find("RespawnPrefab").transform;
        //}
        respawn = GameObject.Find("Respawn").transform;
        miniMapScaler = respawn.Find("MiniMap");

        netService = TGNetService.GetInstance();
        //netService.AddEventHandler("Connect", NetEventHanlder);
        netService.AddEventHandler("Disconnect", NetEventHanlder);
        netService.AddEventHandler("BattleEventReconnect", NetEventHanlder);
        netService.AddEventHandler("BattleEventConnect", NetEventHanlder);
        netService.AddEventHandler("BattleEventStart", NetEventHanlder);
        netService.AddEventHandler("BattleEventRespawn", NetEventHanlder);
        netService.AddEventHandler("BattleEventPVPEnd", NetEventHanlder);
        netService.AddEventHandler("BattleEventReported", NetEventHanlder);

        groupInfos = new ArrayList();
        killCount = new Dictionary<string, int>();
        firstBlood = true;

        battleTowers = new NTGBattleMobTowerController[GroupCount][][];
        for (int i = 0; i < GroupCount; i++)
        {
            battleTowers[i] = new NTGBattleMobTowerController[10][];
            for (int j = 0; j < 10; j++)
            {
                battleTowers[i][j] = new NTGBattleMobTowerController[10];
            }
        }

        NTGApplicationController.Instance.LuaCall("PVPBattleLoadingAPI_1", "SetLoadProgress", loadingApi, 55);

        for (int i = 0; i < globalPassives.childCount; i++)
        {
            var p = globalPassives.GetChild(i).gameObject.GetComponent<NTGBattlePassiveSkillBehaviour>();
            RegisterPassiveSkillBehaviour(p.passiveName, p);
        }
        globalPassives.gameObject.SetActive(false);

        if (NTGBattleDataController.GetLocalPlayerId() != 0)
        {
            localId = NTGBattleDataController.GetLocalPlayerId().ToString();
            localGroup = NTGBattleDataController.GetLocalPlayerBattleGroup();

            serverSimulator = localGroup == 0;
            if (serverSimulator)
            {
                mainCamera.enabled = false;
            }

            configA = NTGBattleDataController.GetConfig("atkalpha");
            configB = NTGBattleDataController.GetConfig("atkbeta");

            configX = NTGBattleDataController.GetConfig("rewardtime");
            configYPlayer = NTGBattleDataController.GetConfig("rewardcoinratioplayer");
            configYMob = NTGBattleDataController.GetConfig("rewardcoinratiomob");
        }

        uiController.LoadUIPanel();

        StartCoroutine(InitBattleViews());

        Connect(0);

        NTGApplicationController.Instance.LuaCall("PVPBattleLoadingAPI_1", "SetLoadProgress", loadingApi, 60);

#if UNITY_EDITOR
        //this.StandaloneInputModule.enabled = true;
        DebugMode = NTGBattleDataController.GetLocalPlayerId() == 0;
        if (DebugMode)
        {
            //var dataFile = new StreamReader(Application.dataPath + @"\Temp\data.txt");
            //var data = dataFile.ReadToEnd();

            //NetEventHanlder(new TGNetService.NetEvent
            //{
            //    Type = "NTGBattleEventConnect",
            //    Content = JObject.Parse(data)
            //});

            ////uiController.localPlayerController.LoadSkin("R50000002", "R50000002", "R50000002", "R50000002", "R50000002");

            //uiController.localPlayerController.skills[0].reqTarget = 0;
            //uiController.localPlayerController.skills[1].reqTarget = 0;
            //uiController.localPlayerController.skills[1].cd = 0;
            //uiController.localPlayerController.skills[1].level = 1;
            //uiController.localPlayerController.skills[1].mpCost = 0;

            //uiController.localPlayerController.skills[2].reqTarget = 0;
            //uiController.localPlayerController.skills[2].cd = 0;
            //uiController.localPlayerController.skills[2].level = 1;
            //uiController.localPlayerController.skills[2].mpCost = 0;

            //uiController.localPlayerController.skills[3].reqTarget = 0;
            //uiController.localPlayerController.skills[3].cd = 0;
            //uiController.localPlayerController.skills[3].level = 1;
            //uiController.localPlayerController.skills[3].mpCost = 0;
            ////uiController.localPlayerController.skills[3].behaviours = new[] {uiController.localPlayerController.skills[3].behaviours[1]};

            //NetEventHanlder(new TGNetService.NetEvent
            //{
            //    Type = "NTGBattleEventStart"
            //});

            var player = LoadPlayer(localId, 10, 1, DebugRole);
            player.gameObject.AddComponent<AudioListener>();
            uiController.localPlayerController = player;
            mainCameraController.localPlayerController = player;

            //player.skills[2].Init(null, new float[0], new string[0]);

            uiController.InitUI();

            player.Respawn();
        }
#endif
    }

    public ArrayList battleUnits = new ArrayList();
    public ArrayList battleUnitsInActive = new ArrayList();

    public ArrayList[][] gridUnits;
    public int[][] gridViews;
    public ArrayList unitsInView;

    public float gridSize = 0.5f;
    public float mapSize = 120.0f;
    public float maxViewRange = 10.0f;

    public Transform viewDebugCube;
    public Transform[][] viewDebugCubes;


    public bool[][][][] views;
    public bool[][][] radViews;

    private IEnumerator InitBattleViews()
    {
        int gridLength = (int) (mapSize/gridSize);
        gridUnits = new ArrayList[gridLength][];
        gridViews = new int[gridLength][];
        unitsInView = new ArrayList();

        viewDebugCubes = new Transform[gridLength][];

        for (int i = 0; i < gridLength; i++)
        {
            gridUnits[i] = new ArrayList[gridLength];
            gridViews[i] = new int[gridLength];

            viewDebugCubes[i] = new Transform[gridLength];

            for (int j = 0; j < gridLength; j++)
            {
                gridUnits[i][j] = new ArrayList();
                gridViews[i][j] = 0;

                //viewDebugCubes[i][j] = Instantiate(viewDebugCube.gameObject).transform;
                //viewDebugCubes[i][j].position = new Vector3(i*1.0f + 0.5f, 30.0f, j*1.0f + 0.5f);
                //viewDebugCubes[i][j].gameObject.SetActive(false);
            }
        }

        var maxViewLength = (int) (maxViewRange/gridSize);
        views = new bool[gridLength][][][];
        for (int i = 0; i < gridLength; i++)
        {
            views[i] = new bool[gridLength][][];
            for (int j = 0; j < gridLength; j++)
            {
                views[i][j] = new bool[2*maxViewLength + 1][];
                for (int k = 0; k < 2*maxViewLength + 1; k++)
                {
                    views[i][j][k] = new bool[2*maxViewLength + 1];
                }
            }
        }

        yield return null;

        var x = (int) miniMapScaler.position.x + 0.5f;
        var z = (int) miniMapScaler.position.z + 0.5f;
        var w = x + miniMapScaler.localScale.x/2;
        var h = z + miniMapScaler.localScale.z/2;
        while (x < w)
        {
            var zz = z;
            while (zz < h)
            {
                for (int k = 0; k < 2*maxViewLength + 1; k++)
                {
                    for (int l = 0; l < 2*maxViewLength + 1; l++)
                    {
                        RaycastHit castHit;
                        var visible = !Physics.Linecast(new Vector3(x, 1.0f, zz), new Vector3(x + k - maxViewLength, 1.0f, zz + l - maxViewLength), out castHit);
                        if (!visible && Physics.CheckSphere(new Vector3(x + k - maxViewLength, 1.0f, zz + l - maxViewLength), 0.01f))
                        {
                            views[(int) x][(int) zz][k][l] = true;
                        }
                        else
                        {
                            views[(int) x][(int) zz][k][l] = visible;
                        }
                    }
                }

                zz += 1.0f;
            }
            x += 1.0f;
        }

        Destroy(GameObject.Find("Blocks"));

        radViews = new bool[maxViewLength + 1][][];
        for (int i = 0; i < maxViewLength + 1; i++)
        {
            radViews[i] = new bool[2*maxViewLength + 1][];
            for (int j = 0; j < 2*maxViewLength + 1; j++)
            {
                radViews[i][j] = new bool[2*maxViewLength + 1];
                for (int k = 0; k < 2*maxViewLength + 1; k++)
                {
                    radViews[i][j][k] = (j - maxViewLength)*(j - maxViewLength) + (k - maxViewLength)*(k - maxViewLength) < i*i;
                }
            }
        }

        fogController.m_projecterPosition = new Vector3(miniMapScaler.position.x + miniMapScaler.localScale.x/4, 15.0f, miniMapScaler.position.z + miniMapScaler.localScale.z/4);
        fogController.Init(0, 0, (int) mapSize, (int) mapSize);

        var fogTex = new Texture2D(gridLength, gridLength, TextureFormat.Alpha8, false);
        fogTex.wrapMode = TextureWrapMode.Clamp;


        yield return null;

        var fogAlpha = 0.8f;
        var fogStep = fogAlpha/10;
        var fogPixels = new Color[gridLength*gridLength];        

        while (true)
        {
            //for (int i = 0; i < gridLength; i++)
            //{
            //    for (int j = 0; j < gridLength; j++)
            //    {
            //        if (gridViews[i][j] > 0)
            //        {
            //            var p = fogPixels[i + j*gridLength];
            //            if (p.a > 0)
            //            {
            //                p.a -= fogStep;
            //            }
            //            //viewDebugCubes[i][j].gameObject.SetActive(true);
            //            fogPixels[i + j*gridLength] = p;
            //        }
            //        else
            //        {
            //            var p = fogPixels[i + j*gridLength];
            //            if (p.a < fogAlpha)
            //            {
            //                p.a += fogStep;
            //            }
            //            //viewDebugCubes[i][j].gameObject.SetActive(false);
            //            fogPixels[i + j*gridLength] = p;
            //        }
            //    }
            //}

            //fogTex.SetPixels(fogPixels);


            for (int i = 0; i < gridLength; i++)
            {
                for (int j = 0; j < gridLength; j++)
                {
                    if (gridViews[i][j] > 0)
                    {
                        var p = fogPixels[i + j * gridLength];
                        if (p.a > 0)
                        {
                            p.a -= fogStep;
                            fogTex.SetPixel(i, j, p);
                            fogPixels[i + j*gridLength] = p;
                        }
                        
                    }
                    else
                    {
                        var p = fogPixels[i + j * gridLength];
                        if (p.a < fogAlpha)
                        {
                            p.a += fogStep;
                            fogTex.SetPixel(i, j, p);
                            fogPixels[i + j * gridLength] = p;
                        }
                        
                    }
                }
            }

            fogTex.Apply();
            fogController.SetFog(fogTex);

            yield return new WaitForSeconds(0.05f);
        }
    }

    private Coroutine doRespawnCo = null;
    private Coroutine doDeferRespawnCo = null;
    private Coroutine doUpdateMiniMapCo = null;
    private Coroutine doSalaryCo = null;
    private Coroutine doExpSalaryCo = null;

    public bool connected;

    private bool NetEventHanlder(TGNetService.NetEvent e)
    {
        if (e.Type == "BattleEventReconnect")
        {
            uiController.ShowDisconnectTip(false);
            connected = true;
            return true;
        }

        if (e.Type == "Disconnect")
        {
            uiController.ShowDisconnectTip(true);
            connected = false;
            return false;
        }

        if (e.Type == "BattleEventRespawn")
        {
            var responses = JsonConvert.DeserializeObject<UTGBattleResapwnResponse[]>(e.Content["RR"].ToString());
            RespawnResponse(responses);

            return true;
        }

        if (e.Type == "BattleEventConnect")
        {
            connected = true;

#if UNITY_EDITOR
            //if (!DebugMode)
            //{
            //    var file = File.Create(Application.dataPath + @"\Temp\data.txt");
            //    var dataFile = new StreamWriter(file);
            //    dataFile.WriteLine(e.Content.ToString());
            //    dataFile.Close();
            //    file.Close();
            //}
#endif
            NTGApplicationController.Instance.LuaCall("PVPBattleLoadingAPI_1", "SetLoadProgress", loadingApi, 61);

            host = e.Content["Host"].ToObject<string>();
            serverSimulation = e.Content["SSim"].ToObject<bool>();
            sceneInfo = JsonConvert.DeserializeObject<NTGBattleSceneInfo>(e.Content["Info"].ToString());
            NTGBattleDataController.LevelUpType = sceneInfo.LevelUpType;

            NTGBattleUnitInfo[] playerInfos = JsonConvert.DeserializeObject<NTGBattleUnitInfo[]>(e.Content["Players"].ToString());
            NTGBattleGroupInfo[] groupInfos = JsonConvert.DeserializeObject<NTGBattleGroupInfo[]>(e.Content["Groups"].ToString());

            foreach (var groupInfo in groupInfos)
            {
                this.groupInfos.Add(groupInfo);
            }

            NTGApplicationController.Instance.LuaCall("PVPBattleLoadingAPI_1", "SetLoadProgress", loadingApi, 70);

            for (int playerIndex = 0; playerIndex < playerInfos.Length; playerIndex++)
            {
                var playerInfo = playerInfos[playerIndex];
                string Id = playerInfo.Id;
                int Position = playerInfo.Position;
                int Group = playerInfo.Group;

                NTGBattleMemberInfo info = playerInfo.Info;
                NTGBattleMemberAttrs attrs = playerInfo.Attrs;
                NTGBattleMemberSkill[] skills = playerInfo.Skills;

                var player = LoadPlayer(Id, Position, Group, info.SkinResource);
                if (player == null)
                {
                    Debug.LogError(String.Format("LoadPlayer Failed! Id:{0} Name:{1}", playerInfo.Id, playerInfo.Info.Name));
                }

                player.name = info.Name;
                player.level = info.Level;
                player.icon = info.Icon;
                player.roleId = info.RoleId;
                player.randMap = info.RandMap;
                player.randIndex = 0;
                player.targetRange = info.TargetRange;
                player.rewardRange = info.RewardRange;

                player.mask = 0x1;
                player.skillPoint = 1;

                player.InitAttrs(attrs);

                //TODO: zhxu use local datacontroller to get values
                player.atkType = NTGBattleDataController.GetRoleAtkType(info.RoleId);

                var skillList = new ArrayList();
                for (int i = 0; i < skills.Length - 2; i++)
                {
                    player.skills[i].Init(skills[i], new float[0], new string[0]);
                    player.skills[i].level = 0;
                    skillList.Add(player.skills[i]);
                }
                var pskill = skills[skills.Length - 2];
                player.pSkills[0].Init(pskill, pskill.Param, new string[0]);

                var playerSkill = skills[skills.Length - 1];
                var playerSkillController = AddPlayerSkill(player, playerSkill.Resource);
                playerSkillController.Init(playerSkill, new float[0], new string[0]);
                skillList.Add(playerSkillController);

                for (int i = 0; i < sceneInfo.Skills.Length; i++)
                {
                    var skill = AddPlayerSkill(player, sceneInfo.Skills[i].Resource);
                    skill.Init(sceneInfo.Skills[i], new float[0], new string[0]);
                    skillList.Add(skill);
                }

                player.skills = new NTGBattleSkillController[skillList.Count];
                skillList.CopyTo(player.skills);

                if (info.IsAI)
                {
                    player.isAI = true;

                    player.aic = player.gameObject.AddComponent<UTGBattlePlayerAIController>();
                    player.aic.Init(player, Position, info.AiParams);

                    if (localId == host)
                        player.master = true;

                    player.isRobot = info.IsRobot;
                }
                else
                {
                    if (Id == localId)
                    {
                        (NTGApplicationController.Instance.LuaGetTable("GameManager")["UIAudioListener"] as AudioListener).enabled = false;

                        player.gameObject.AddComponent<AudioListener>();
                        uiController.localPlayerController = player;
                        mainCameraController.localPlayerController = player;

                        var hc = prefabs.Find("SkillHint");
                        hc.parent = player.transform;
                        hc.localPosition = Vector3.zero;
                        hc.localRotation = Quaternion.identity;
                        uiController.hintController = hc.gameObject.GetComponent<UTGBattleSkillHintController>();
                        uiController.hintController.Init(player);

                        player.master = true;
                    }
                }

                NTGApplicationController.Instance.LuaCall("PVPBattleLoadingAPI_1", "SetLoadProgress", loadingApi, 70 + 20/playerInfos.Length*playerIndex);
            }

            NTGApplicationController.Instance.LuaCall("PVPBattleLoadingAPI_1", "SetLoadProgress", loadingApi, 90);

            uiController.InitUI();

            battleStartTime = float.MaxValue;
            //LocalRespawn();

            Connect(1);

            NTGApplicationController.Instance.LuaCall("PVPBattleLoadingAPI_1", "SetLoadProgress", loadingApi, 100);

            return true;
        }

        if (e.Type == "BattleEventStart")
        {
            foreach (NTGBattlePlayerController player in unitsBase.GetComponentsInChildren<NTGBattlePlayerController>())
            {
                player.Respawn();
            }

            //uiController.localPlayerController.Respawn();

            battleStartTime = Time.time;
            RespawnPreLoad();
            doRespawnCo = StartCoroutine(doRespawn());
            doDeferRespawnCo = StartCoroutine(doDeferRespawn());
            doUpdateMiniMapCo = StartCoroutine(doUpdateMiniMap());
            doSalaryCo = StartCoroutine(doSalary());
            doExpSalaryCo = StartCoroutine(doExpSalary());

            uiController.ShowMessage(0, 1);

            NTGApplicationController.Instance.LuaCall("PVPBattleLoadingAPI_1", "DestroySelf", loadingApi);            

            NTGResourceController.Instance.UnloadAssetBundle("pvpbattleloading.assetbundle", true, false);

            return true;
        }

        if (e.Type == "BattleEventPVPEnd")
        {
            int win = e.Content["Win"].ToObject<int>();

            if (serverSimulator || localId == host)
            {
                GenerateBattleReport();
            }

            StopCoroutine(doRespawnCo);
            StopCoroutine(doDeferRespawnCo);
            StopCoroutine(doUpdateMiniMapCo);
            StopCoroutine(doSalaryCo);
            StopCoroutine(doExpSalaryCo);

            foreach (NTGBattleUnitController battleUnit in battleUnits)
            {
                battleUnit.alive = false;
                battleUnit.MoveableCount++;
                battleUnit.ShootableCount++;
            }
            foreach (NTGBattleUnitController battleUnit in battleUnitsInActive)
            {
                battleUnit.alive = false;
                battleUnit.MoveableCount++;
                battleUnit.ShootableCount++;
            }

            if (!serverSimulator)
            {
                mainCameraController.StartBattleEndTracking(uiController.localPlayerController.FindTarget(1000.0f, ally: win != 1, type: NTGBattleUnitController.TargetType.Base).transform);

                uiController.StopAllCoroutines();

                var panelRoot = NTGApplicationController.Instance.LuaGetTable("GameManager")["PanelRoot"] as Transform;
                for (int i = 0; i < panelRoot.childCount; i++)
                {
                    panelRoot.GetChild(i).gameObject.SetActive(false);
                }

                uiController.LoadResultPanel(win);

                Destroy(uiController.localPlayerController.gameObject.GetComponent<AudioListener>());
                (NTGApplicationController.Instance.LuaGetTable("GameManager")["UIAudioListener"] as AudioListener).enabled = true;
            }

            return true;
        }

        if (e.Type == "BattleEventReported")
        {
            int log = e.Content["Log"].ToObject<int>();

            uiController.SetBattleLog(log);
            return true;
        }
        return false;
    }

    private void GenerateBattleReport()
    {
        var report = new UTGBattleReport();
        ArrayList TeamA = new ArrayList();
        ArrayList TeamB = new ArrayList();

        foreach (NTGBattleUnitController unit in battleUnits)
        {
            if (unit is NTGBattlePlayerController)
            {
                if (unit.group == 1)
                {
                    TeamA.Add(unit);
                }
                else if (unit.group == 2)
                {
                    TeamB.Add(unit);
                }
            }
        }

        foreach (NTGBattleUnitController unit in battleUnitsInActive)
        {
            if (unit is NTGBattlePlayerController)
            {
                if (unit.group == 1)
                {
                    TeamA.Add(unit);
                }
                else if (unit.group == 2)
                {
                    TeamB.Add(unit);
                }
            }
        }

        if (localGroup == 1)
        {
            report.TAScore = allyScore;
            report.TBScore = enemyScore;
        }
        else
        {
            report.TAScore = enemyScore;
            report.TBScore = allyScore;
        }

        report.TeamA = new UTGBattlePlayerReport[TeamA.Count];
        report.TeamB = new UTGBattlePlayerReport[TeamB.Count];

        for (int i = 0; i < TeamA.Count; i++)
        {
            var p = TeamA[i] as NTGBattlePlayerController;
            var r = new UTGBattlePlayerReport();

            r.IsAi = p.isAI && !p.isRobot;
            r.RoleId = p.roleId;
            if (!p.isAI || p.isRobot)
                r.PlayerId = Convert.ToInt32(p.id);
            r.PlayerName = p.name;
            r.Level = p.level;
            r.IsLegendary = false;
            r.TLStreakKill = p.statistic.maxKillSteak;
            r.RoleKill = p.statistic.kill;
            r.RoleDamage = p.statistic.damagePlayer;
            r.MobDamage = p.statistic.damageMob;
            r.NeutDamage = p.statistic.damageNeut;
            r.BuildingDamage = p.statistic.damageBuilding;
            r.PushTower = p.statistic.towerKill;
            r.Assistance = p.statistic.assist;
            r.SufferDamage = p.statistic.damageReceive;
            r.Death = p.statistic.death;
            r.Coin = (int) p.statistic.coin;
            r.IsEscape = false;
            r.BattleEquips = new int[p.equips.Count];
            for (int j = 0; j < p.equips.Count; j++)
                r.BattleEquips[j] = ((NTGBattleMemberEquip) p.equips[j]).Id;

            report.TeamA[i] = r;
        }
        for (int i = 0; i < TeamB.Count; i++)
        {
            var p = TeamB[i] as NTGBattlePlayerController;
            var r = new UTGBattlePlayerReport();

            r.IsAi = p.isAI && !p.isRobot;
            r.RoleId = p.roleId;
            if (!p.isAI || p.isRobot)
                r.PlayerId = Convert.ToInt32(p.id);
            r.PlayerName = p.name;
            r.Level = p.level;
            r.IsLegendary = false;
            r.TLStreakKill = p.statistic.maxKillSteak;
            r.RoleKill = p.statistic.kill;
            r.RoleDamage = p.statistic.damagePlayer;
            r.MobDamage = p.statistic.damageMob;
            r.NeutDamage = p.statistic.damageNeut;
            r.BuildingDamage = p.statistic.damageBuilding;
            r.PushTower = p.statistic.towerKill;
            r.Assistance = p.statistic.assist;
            r.SufferDamage = p.statistic.damageReceive;
            r.Death = p.statistic.death;
            r.Coin = (int) p.statistic.coin;
            r.IsEscape = false;
            r.BattleEquips = new int[p.equips.Count];
            for (int j = 0; j < p.equips.Count; j++)
                r.BattleEquips[j] = ((NTGBattleMemberEquip) p.equips[j]).Id;

            report.TeamB[i] = r;
        }

        netService.SendRequest(
            new TGNetService.NetRequest
            {
                Content = new JObject(
                    new JProperty("Type", "BattleReport"),
                    new JProperty("Report", JsonConvert.SerializeObject(report))
                    ),
                FlowOpt = true,
            });
    }

    public void NotifyKill(string id)
    {
        if (!killCount.ContainsKey(id))
            killCount[id] = 0;

        killCount[id] = killCount[id] + 1;
    }

    public int allyScore;
    public int enemyScore;

    public void NotifyPlayerKill(NTGBattlePlayerController player)
    {
        if (player.group == localGroup)
        {
            enemyScore++;
        }
        else
        {
            allyScore++;
        }
    }

    public NTGBattleMobTowerController[][][] battleTowers;

    private void RespawnResponse(UTGBattleResapwnResponse[] responses)
    {
        StartCoroutine(doRespawnResponse(responses));
    }

    private IEnumerator doRespawnResponse(UTGBattleResapwnResponse[] responses)
    {
        for (int i = 0; i < responses.Length; i++)
        {
            foreach (NTGBattleGroupInfo groupInfo in groupInfos)
            {
                if (groupInfo.Id == responses[i].GId)
                {
                    foreach (var unitInfo in groupInfo.Units)
                    {
                        if (unitInfo.Id == responses[i].CId)
                        {
                            var unit = Respawn(groupInfo, unitInfo, responses[i].Id, responses[i].D);
                            if (responses[i].P != null && responses[i].P != "")
                            {
                                unit.AddPassive(responses[i].P, FindUnit(responses[i].O));
                            }
                            if (groupInfo.remove)
                            {
                                groupInfos.Remove(groupInfo);
                            }
                            break;
                        }
                    }

                    break;
                }
            }

            yield return null;
        }
    }

    private class RespawnUnit
    {
        public NTGBattleUnitController unit;
        public float time;
    }

    private Queue respawnUnitQueue = new Queue();
    private float preRespawnTime = 3.0f;

    private NTGBattleUnitController Respawn(NTGBattleGroupInfo groupInfo, NTGBattleUnitInfo unitInfo, string Id, float preTime)
    {
        NTGBattleMemberInfo info = unitInfo.Info;
        NTGBattleMemberAttrs attrs = unitInfo.Attrs;
        NTGBattleMemberSkill[] skills = unitInfo.Skills;
        NTGBattleCreatureInfo cinfo = unitInfo.CInfo;

        NTGBattleMobController mc = null;
        switch (groupInfo.Category)
        {
            case 1: //Mob
                mc = NewMob("Mob", Id, cinfo.Resource, groupInfo.Position, unitInfo.Group, groupInfo.Resource, cinfo.RespawnPoint);
                break;
            case 2: //Tower
                mc = LoadMob("Tower", Id, cinfo.Resource, groupInfo.Position, unitInfo.Group);
                battleTowers[unitInfo.Group - 1][cinfo.RespawnLane[0]][cinfo.RespawnLane[1]] = mc as NTGBattleMobTowerController;
                break;
            case 3: //Pool
                mc = LoadMob("Pool", Id, cinfo.Resource, groupInfo.Position, unitInfo.Group);
                break;
            case 4: //Base
                mc = LoadMob("Base", Id, cinfo.Resource, groupInfo.Position, unitInfo.Group);
                break;
            case 5: //Mob Object
                mc = NewMob("Object", Id, cinfo.Resource, groupInfo.Position, unitInfo.Group);
                break;
            case 6: //Summon Mob
                mc = NewMob("Mob", Id, cinfo.Resource, groupInfo.Position, unitInfo.Group, groupInfo.Resource, cinfo.RespawnPoint);
                break;
        }

        mc.id = Id;
        mc.position = groupInfo.Position;
        mc.group = unitInfo.Group;

        mc.name = info.Name;
        mc.level = info.Level;
        mc.icon = info.Icon;
        mc.randMap = info.RandMap;
        mc.randIndex = 0;
        mc.targetRange = info.TargetRange;
        mc.rewardRange = info.RewardRange;

        mc.type = cinfo.Type;
        mc.giveExp = cinfo.GiveExp;
        mc.giveCoin = cinfo.GiveCoin;

        mc.mask = cinfo.Mask;

        mc.groupInfo = groupInfo;
        mc.creatureInfo = cinfo;

        mc.InitAttrs(attrs);
        mc.Init(cinfo.AiParams);

        if (skills.Length != mc.skills.Length + mc.pSkills.Length)
        {
            Debug.LogError(String.Format("Skill Count not Match Mob {0}", mc.id));
        }
        for (int i = 0; i < mc.skills.Length; i++)
        {
            mc.skills[i].Init(skills[i], new float[0], new string[0]);
        }
        for (int i = 0; i < mc.pSkills.Length; i++)
        {
            mc.pSkills[i].Init(skills[mc.skills.Length + i], new float[0], new string[0]);
        }

        mc.master = localId == host;

        mc.SetVisibility(false);

        if (!battleUnitsInActive.Contains(mc))
            battleUnitsInActive.Add(mc);

        if (preTime == 0)
            mc.Respawn();
        else
            respawnUnitQueue.Enqueue(new RespawnUnit {unit = mc, time = Time.time + preTime});

        return mc;
    }

    private void ServerRespawn(ArrayList respawnRequests)
    {
        if (localId == host)
        {
            var requests = new UTGBattleRespawnRequest[respawnRequests.Count];
            respawnRequests.CopyTo(requests);

            netService.SendRequest(
                new TGNetService.NetRequest
                {
                    Content = new JObject(
                        new JProperty("Type", "BattleRespawn"),
                        new JProperty("RR", JsonConvert.SerializeObject(requests))
                        ),
                    FlowOpt = true
                });
        }
    }

    public ArrayList summonGroupInfos = new ArrayList();

    public void SummonRespawn(int pos, Vector3 position, Quaternion rotation, int creatureId, string respawnPassive, string summonerId)
    {
        foreach (NTGBattleGroupInfo groupInfo in summonGroupInfos)
        {
            if (groupInfo.Position == pos)
            {
                foreach (var unitInfo in groupInfo.Units)
                {
                    if (unitInfo.Id == creatureId.ToString())
                    {
                        var gp = respawn.Find("Mob/Mob-" + pos);
                        gp.position = position;
                        gp.rotation = rotation;

                        var respawnRequests = new ArrayList();
                        respawnRequests.Add(new UTGBattleRespawnRequest {GId = groupInfo.Id, CId = unitInfo.Id, P = respawnPassive, O = summonerId, D = 0});
                        ServerRespawn(respawnRequests);

                        break;
                    }
                }

                break;
            }
        }
    }

    private bool mobRespawnStartMessageShowed;

    private ArrayList respawnRequests = new ArrayList();

    private void LocalRespawn()
    {
        foreach (NTGBattleGroupInfo groupInfo in groupInfos)
        {
            switch (groupInfo.Category)
            {
                case 1: //Mob
                    //if (!groupInfo.preLoaded)
                    //{
                    //    foreach (var unitInfo in groupInfo.Units)
                    //    {
                    //        PreLoadMob("Mob", unitInfo.CInfo.Resource);
                    //    }
                    //    groupInfo.preLoaded = true;
                    //}

                    switch (groupInfo.Trigger)
                    {
                        case 0: //Respawn Once
                            if (Time.time - battleStartTime > groupInfo.Params[0] - preRespawnTime && groupInfo.remove == false)
                            {
                                foreach (var unitInfo in groupInfo.Units)
                                {
                                    //ServerRespawn(groupInfo, unitInfo);
                                    respawnRequests.Add(new UTGBattleRespawnRequest {GId = groupInfo.Id, CId = unitInfo.Id, D = preRespawnTime});
                                }
                                groupInfo.remove = true;
                            }
                            break;
                        case 1: //Respawn Cycle
                            if (Time.time - battleStartTime > groupInfo.Params[0] - preRespawnTime && groupInfo.remove == false)
                            {
                                if (!mobRespawnStartMessageShowed)
                                {
                                    uiController.ShowMessage(0, 3);
                                    mobRespawnStartMessageShowed = true;
                                }

                                if (groupInfo.respawnCount < groupInfo.Params[2])
                                {
                                    if ((groupInfo.respawnCount == 0) || (Time.time - groupInfo.respawnTime > groupInfo.Params[1]))
                                    {
                                        foreach (var unitInfo in groupInfo.Units)
                                        {
                                            if (unitInfo.CInfo.RespawnCondition == 0)
                                            {
                                                //ServerRespawn(groupInfo, unitInfo);
                                                respawnRequests.Add(new UTGBattleRespawnRequest {GId = groupInfo.Id, CId = unitInfo.Id, D = preRespawnTime});
                                            }
                                            else
                                            {
                                                var g = 0;
                                                if (unitInfo.Group == 1)
                                                    g = 1;
                                                else if (unitInfo.Group == 2)
                                                    g = 0;
                                                var hasLaneTower = battleTowers[g][unitInfo.CInfo.RespawnLane[0]][0] != null &&
                                                                   battleTowers[g][unitInfo.CInfo.RespawnLane[0]][0].alive;

                                                if (unitInfo.CInfo.RespawnCondition == 1 && hasLaneTower)
                                                {
                                                    //ServerRespawn(groupInfo, unitInfo);
                                                    respawnRequests.Add(new UTGBattleRespawnRequest {GId = groupInfo.Id, CId = unitInfo.Id, D = preRespawnTime});
                                                }
                                                if (unitInfo.CInfo.RespawnCondition == 2 && !hasLaneTower)
                                                {
                                                    //ServerRespawn(groupInfo, unitInfo);
                                                    respawnRequests.Add(new UTGBattleRespawnRequest {GId = groupInfo.Id, CId = unitInfo.Id, D = preRespawnTime});

                                                    uiController.ShowMessage(0, 7, unitInfo.Group == localGroup);
                                                }
                                            }
                                        }
                                        if (groupInfo.respawnCount == 0)
                                        {
                                            groupInfo.respawnTime = Time.time;
                                        }
                                        else
                                        {
                                            groupInfo.respawnTime += groupInfo.Params[1];
                                        }
                                        groupInfo.respawnCount++;
                                    }
                                }
                                else
                                {
                                    groupInfo.remove = true;
                                }
                            }
                            break;
                        case 2: //Respawn Cycle After Death
                            if (Time.time - battleStartTime > groupInfo.Params[0] - preRespawnTime)
                            {
                                if ((groupInfo.respawnCount == 0) || (groupInfo.deathCount == groupInfo.Units.Length && (Time.time - groupInfo.wipeTime > groupInfo.Params[1])))
                                {
                                    foreach (var unitInfo in groupInfo.Units)
                                    {
                                        //ServerRespawn(groupInfo, unitInfo);
                                        respawnRequests.Add(new UTGBattleRespawnRequest {GId = groupInfo.Id, CId = unitInfo.Id, D = preRespawnTime});
                                    }
                                    groupInfo.respawnTime = Time.time;
                                    groupInfo.respawnCount++;

                                    groupInfo.deathCount = 0;
                                }
                            }
                            break;
                    }
                    break;
                case 2: //Tower
                case 3: //Pool
                case 4: //Base
                    if (groupInfo.remove == false)
                    {
                        foreach (var unitInfo in groupInfo.Units)
                        {
                            //ServerRespawn(groupInfo, unitInfo);
                            respawnRequests.Add(new UTGBattleRespawnRequest {GId = groupInfo.Id, CId = unitInfo.Id, D = 0});
                        }
                        groupInfo.remove = true;
                    }
                    break;
                case 5: //Field Objects
                    //if (!groupInfo.preLoaded)
                    //{
                    //    foreach (var unitInfo in groupInfo.Units)
                    //    {
                    //        PreLoadMob("Object", unitInfo.CInfo.Resource);
                    //    }
                    //    groupInfo.preLoaded = true;
                    //}

                    if (Time.time - battleStartTime > groupInfo.Params[0] - preRespawnTime)
                    {
                        if ((groupInfo.respawnCount == 0) || (groupInfo.deathCount == groupInfo.Units.Length && (Time.time - groupInfo.wipeTime > groupInfo.Params[1])))
                        {
                            foreach (var unitInfo in groupInfo.Units)
                            {
                                //ServerRespawn(groupInfo, unitInfo);
                                respawnRequests.Add(new UTGBattleRespawnRequest {GId = groupInfo.Id, CId = unitInfo.Id, D = preRespawnTime});
                            }
                            groupInfo.respawnTime = Time.time;
                            groupInfo.respawnCount++;

                            groupInfo.deathCount = 0;
                        }
                    }
                    break;
                case 6: //Summon Mobs
                    //if (!groupInfo.preLoaded)
                    //{
                    //    foreach (var unitInfo in groupInfo.Units)
                    //    {
                    //        PreLoadMob("Mob", unitInfo.CInfo.Resource);
                    //    }
                    //    groupInfo.preLoaded = true;

                    //    summonGroupInfos.Add(groupInfo);
                    //}
                    break;
            }
        }

        if (respawnRequests.Count > 0)
        {
            ServerRespawn(respawnRequests);
            respawnRequests.Clear();
        }
    }

    private void RespawnPreLoad()
    {
        foreach (NTGBattleGroupInfo groupInfo in groupInfos)
        {
            switch (groupInfo.Category)
            {
                case 1: //Mob
                    if (!groupInfo.preLoaded)
                    {
                        foreach (var unitInfo in groupInfo.Units)
                        {
                            PreLoadMob("Mob", unitInfo.CInfo.Resource);
                        }
                        groupInfo.preLoaded = true;
                    }
                    break;
                case 5: //Field Objects
                    if (!groupInfo.preLoaded)
                    {
                        foreach (var unitInfo in groupInfo.Units)
                        {
                            PreLoadMob("Object", unitInfo.CInfo.Resource);
                        }
                        groupInfo.preLoaded = true;
                    }
                    break;
                case 6: //Summon Mobs
                    if (!groupInfo.preLoaded)
                    {
                        foreach (var unitInfo in groupInfo.Units)
                        {
                            PreLoadMob("Mob", unitInfo.CInfo.Resource);
                        }
                        groupInfo.preLoaded = true;

                        summonGroupInfos.Add(groupInfo);
                    }
                    break;
            }
        }
    }

    private IEnumerator doDeferRespawn()
    {
        while (true)
        {
            while (respawnUnitQueue.Count > 0 && (respawnUnitQueue.Peek() as RespawnUnit).time <= Time.time)
            {
                (respawnUnitQueue.Dequeue() as RespawnUnit).unit.Respawn();
            }

            yield return null;
        }
    }

    private IEnumerator doRespawn()
    {
        while (groupInfos.Count > 0)
        {
            LocalRespawn();

            yield return new WaitForSeconds(0.5f);
        }

        /*
        while (respawnGroups.Count > 0)
        {
            var remove = new ArrayList();
            foreach (var respawnGroup in respawnGroups)
            {
                var canRespawn = false;
                switch (respawnGroup.Value.trigger)
                {
                    case 1: //range
                        foreach (var pc in unitsBase.GetComponentsInChildren<NTGBattlePlayerController>())
                        {
                            if (Vector3.Distance(pc.transform.position, respawnGroup.Value.position) < respawnGroup.Value.param)
                            {
                                canRespawn = true;
                                break;
                            }
                        }
                        break;
                    case 2: //kill count
                        int count = 0;
                        foreach (var kill in killCount)
                        {
                            count += kill.Value;
                        }
                        if (count >= respawnGroup.Value.param)
                        {
                            canRespawn = true;
                        }
                        break;
                    case 3: //time
                        if (Time.time - startTime > respawnGroup.Value.param)
                        {
                            canRespawn = true;
                        }
                        break;
                    case 4: //kill monster
                        if (killCount.ContainsKey(respawnGroup.Value.param.ToString()))
                        {
                            canRespawn = true;
                        }
                        break;
                }

                if (canRespawn)
                {
                    foreach (NTGBattleMobLegacyController mc in respawnGroup.Value.units)
                    {
                        mc.Respawn();
                    }
                    remove.Add(respawnGroup.Key);
                }
            }

            foreach (int key in remove)
            {
                respawnGroups.Remove(key);
            }

            yield return new WaitForSeconds(1.0f);
        }
         */
    }

    private void Connect(int stage)
    {
        netService.SendRequest(
            new TGNetService.NetRequest
            {
                Content = new JObject(new JProperty("Type", "BattleConnect"), new JProperty("Stage", stage)),
                Handler = delegate(TGNetService.NetEvent e)
                {
                    if (e.Type == "BattleConnect")
                    {
                        if (e.Content["Result"].ToObject<int>() == 0)
                        {
                            //TGSceneLoader.ExitScene();
                        }
                        return true;
                    }
                    return false;
                }
            });
    }

    //public void CameraShock(string type)
    //{
    //    mainCameraController.Shock(type);
    //}

    public NTGBattleUnitController FindUnit(string id)
    {
        if (id == "")
            return null;

        for (int i = 0; i < battleUnits.Count; i++)
        {
            var unit = battleUnits[i] as NTGBattleUnitController;
            if (unit.id == id)
            {
                return unit;
            }
        }

        for (int i = 0; i < battleUnitsInActive.Count; i++)
        {
            var unit = battleUnitsInActive[i] as NTGBattleUnitController;
            if (unit.id == id)
            {
                return unit;
            }
        }

        Debug.LogWarning(String.Format("Unit Id {0} not Found", id));

        return null;
    }

    private IEnumerator doUpdateMiniMap()
    {
        while (true)
        {
            for (int i = 0; i < unitsInView.Count; i++)
            {
                var unit = unitsInView[i] as NTGBattleUnitController;

                if (unit.unitMinimap == null)
                    continue;

                var pos = miniMapScaler.InverseTransformPoint(unit.transform.position);
                if (localGroup == 1)
                {
                    unit.unitMinimap.localPosition = new Vector3(uiController.miniMapRectTransform.sizeDelta.x*(pos.x*2 - 0.5f), uiController.miniMapRectTransform.sizeDelta.y*(pos.z*2 - 0.5f), 0);
                }
                else
                {
                    unit.unitMinimap.localPosition = new Vector3(uiController.miniMapRectTransform.sizeDelta.x*(1 - pos.x*2 - 0.5f), uiController.miniMapRectTransform.sizeDelta.y*(1 - pos.z*2 - 0.5f), 0);
                }
            }

            yield return null;
        }
    }

    public void NotifyStealthChange()
    {
        foreach (NTGBattleUnitController unit in battleUnits)
        {
            if (unit.group == localGroup)
            {
                if (unit.Stealth > 0)
                {
                    //TODO: add stealth effect here
                }
            }
            else
            {
                if ((unit.Stealth - uiController.localPlayerController.AntiStealth) > 0)
                {
                    foreach (var r in unit.GetComponentsInChildren<MeshRenderer>())
                    {
                        r.enabled = false;
                    }
                    foreach (var r in unit.GetComponentsInChildren<SkinnedMeshRenderer>())
                    {
                        r.enabled = false;
                    }
                }
                else
                {
                    foreach (var r in unit.GetComponentsInChildren<MeshRenderer>())
                    {
                        r.enabled = true;
                    }
                    foreach (var r in unit.GetComponentsInChildren<SkinnedMeshRenderer>())
                    {
                        r.enabled = true;
                    }
                }
            }
        }
    }

    public IEnumerator doSalary()
    {
        int nextTiming = 0;
        float cycle = 0.1f;
        float salary = 0;

        while (true)
        {
            if (nextTiming < sceneInfo.SalaryTiming.Length && Time.time - battleStartTime >= sceneInfo.SalaryTiming[nextTiming])
            {
                cycle = sceneInfo.SalaryCycle[nextTiming];
                salary = sceneInfo.Salary[nextTiming];

                nextTiming++;
            }

            foreach (NTGBattleUnitController unit in battleUnits)
            {
                var pc = unit as NTGBattlePlayerController;
                if (pc != null)
                {
                    pc.AddCoin(salary);
                }
            }

            foreach (NTGBattleUnitController unit in battleUnitsInActive)
            {
                var pc = unit as NTGBattlePlayerController;
                if (pc != null)
                {
                    pc.AddCoin(salary);
                }
            }

            yield return new WaitForSeconds(cycle);
        }
    }

    public IEnumerator doExpSalary()
    {
        int nextTiming = 0;
        float cycle = 0.1f;
        float salary = 0;

        while (true)
        {
            if (nextTiming < sceneInfo.ExpSalaryTiming.Length && Time.time - battleStartTime >= sceneInfo.ExpSalaryTiming[nextTiming])
            {
                cycle = sceneInfo.ExpSalaryCycle[nextTiming];
                salary = sceneInfo.ExpSalary[nextTiming];

                nextTiming++;
            }

            foreach (NTGBattleUnitController unit in battleUnits)
            {
                var pc = unit as NTGBattlePlayerController;
                if (pc != null)
                {
                    pc.AddExp(salary);
                }
            }

            foreach (NTGBattleUnitController unit in battleUnitsInActive)
            {
                var pc = unit as NTGBattlePlayerController;
                if (pc != null)
                {
                    pc.AddExp(salary);
                }
            }

            yield return new WaitForSeconds(cycle);
        }
    }
}