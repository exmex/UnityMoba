using System;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class NTGBattleUIController : MonoBehaviour
{
    private TGNetService netService;

    public NTGBattleMainController mainController;
    public NTGBattlePlayerController localPlayerController;
    public NTGBattleMainCameraController mainCameraController;
    public UTGBattleSkillHintController hintController;

    public Transform unitsBase;
    public Transform guiBase;

    public Transform unitUiBase;
    public Transform unitUiTemplate;

    private NTGBattlePlayerController[] allyList;
    private NTGBattlePlayerController[] enemyList;

    private ArrayList allyPlayerList;
    private ArrayList enemyPlayerList;

    public Dictionary<NTGBattleUnitController, LuaTable> unitUiMap;

    public float ScreenX;
    public float ScreenY;

    public enum BattleAudio
    {
        SkillUpgrade,
        SkillCDDone,
    }

    public AudioClip[] battleAudioClips;
    public AudioSource audio;


    public void PlayBattleAudio(BattleAudio a)
    {
        audio.PlayOneShot(battleAudioClips[(int) a]);
    }

    private void Awake()
    {
        unitUiMap = new Dictionary<NTGBattleUnitController, LuaTable>();

        audio = GetComponent<AudioSource>();

        //var cs = GameObject.Find("PanelRoot").GetComponent<CanvasScaler>();
        ////TODO zhxu fix screen x y later
        //ScreenX = cs.referenceResolution.x;
        //ScreenY = cs.referenceResolution.y;

        var rt = GameObject.Find("PanelRoot").GetComponent<RectTransform>();
        //TODO zhxu fix screen x y later
        ScreenX = rt.sizeDelta.x;
        ScreenY = rt.sizeDelta.y;
    }

    private void Start()
    {
        netService = TGNetService.GetInstance();

        //StartCoroutine(doJoystick());
        //StartCoroutine(doScreenClick());
    }

    public float fps;
    private float fpsInterval = 0.5f;
    private int fpsFrames;
    private float fpsDuration;

    private void Update()
    {
        fpsFrames++;
        fpsDuration += Time.deltaTime*Time.timeScale;
        if (fpsDuration > fpsInterval)
        {
            fps = fpsFrames/fpsDuration;
            fpsFrames = 0;
            fpsDuration = 0;
        }
    }

    private IEnumerator doScreenClick()
    {
        while (true)
        {
            for (int i = 0; i < Input.touchCount; i++)
            {
                var t = Input.GetTouch(i);
                if (t.phase == TouchPhase.Began && t.position.x/Screen.width > 0.3 && t.position.y/Screen.height > 0.5)
                {
                    var ray = Camera.main.ScreenPointToRay(t.position);

                    RaycastHit hit;
                    if (EventSystem.current.currentSelectedGameObject == null && Physics.Raycast(ray, out hit))
                    {
                        Debug.Log(hit.collider.name);
                        var unit = hit.collider.GetComponent<NTGBattleUnitController>();
                        if (unit != null)
                        {
                            localPlayerController.TargetUnit(unit);
                        }
                    }
                    break;
                }
            }

#if UNITY_EDITOR
            if (Input.GetMouseButtonDown(0) && Input.mousePosition.x/Screen.width > 0.3 && Input.mousePosition.y/Screen.height > 0.5)
            {
                var ray = Camera.main.ScreenPointToRay(Input.mousePosition);

                RaycastHit hit;
                if (EventSystem.current.currentSelectedGameObject == null && Physics.Raycast(ray, out hit))
                {
                    Debug.Log(hit.collider.name);
                    var unit = hit.collider.GetComponent<NTGBattleUnitController>();
                    if (unit != null)
                    {
                        localPlayerController.TargetUnit(unit);
                    }
                }
            }
#endif
            yield return null;
        }
    }

    private IEnumerator doJoystick()
    {
        var moveJoyStick = (LuaTable) uiBattleAPI["moveJoyStick"];

        while (true)
        {
            var axis = (Vector2) moveJoyStick["inputAxis"];

            if (localPlayerController.group == 1)
            {
                localPlayerController.SetVelocity(new Vector3(axis.x, 0, axis.y));
            }
            else
            {
                localPlayerController.SetVelocity(new Vector3(-axis.x, 0, -axis.y));
            }

            yield return null;
        }
    }

    public void ShowMessage(int type, int subType, bool isAlly = true, string iconA = null, string iconB = null)
    {
        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "ShowMessage", uiBattleAPI, type, subType, isAlly, iconA, iconB);
    }

    public void ShowUnitKillMessage(NTGBattleUnitController killer, NTGBattleUnitController victim)
    {
        if (victim is NTGBattleMobTowerController)
            ShowMessage(0, 8, victim.group == mainController.localGroup, killer.icon, victim.icon);
    }

    public void ShowDisconnectTip(bool show)
    {
        if (uiBattleAPI != null)
            NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetReconnectTip", uiBattleAPI, show);
    }

    public void ShowPlayerKillMessage(NTGBattleUnitController killer, NTGBattlePlayerController victim, NTGBattlePlayerController.KillRecord killRecord)
    {
        if (mainController.serverSimulator)
            return;

        if (killer == null)
        {
            Debug.LogError("ShowPlayerKillMessage killer is null!");
            return;
        }

        int comboCount = 1;

        var playerkiller = killer as NTGBattlePlayerController;
        if (playerkiller != null)
        {
            comboCount = 0;
            foreach (NTGBattlePlayerController.KillRecord kr in playerkiller.killSteak)
            {
                if (killRecord.time - kr.time < mainController.configX)
                {
                    comboCount++;
                }
            }
            if (comboCount > 5)
                comboCount = 5;
        }

        if (mainController.firstBlood)
        {
            ShowMessage(1, 0, killer.group == mainController.localGroup, killer.icon, victim.icon);
        }
        else
        {
            ShowMessage(1, comboCount, killer.group == mainController.localGroup, killer.icon, victim.icon);
        }

        if (playerkiller != null && playerkiller.killSteak.Count > 2)
        {
            var steak = playerkiller.killSteak.Count;
            if (steak > 7)
                steak = 7;
            ShowMessage(2, steak, killer.group == mainController.localGroup, killer.icon, victim.icon);
        }
    }

    public void ShowUnitDamage(NTGBattleUnitController unit, float effectValue, NTGBattleSkillBehaviour.EffectType effectType, bool critical, NTGBattleUnitController shooter, NTGBattleSkillBehaviour behav)
    {
        if ((unit == localPlayerController || shooter == localPlayerController) && unitUiMap.ContainsKey(unit) && unit.GroupVisibleCount[mainController.localGroup - 1] <= 0)
        {
            var viewPoint = Camera.main.WorldToViewportPoint(unit.transform.position);

            //if (effectType != NTGBattleSkillBehaviour.EffectType.HpRecover && effectType != NTGBattleSkillBehaviour.EffectType.MpRecover)
            //{
            //    Debug.Log(behav.name + " " + behav.id + " " + effectValue + " " + effectType);
            //}

            NTGApplicationController.Instance.LuaCall("UIDamage", "ShowDamage", unitUiMap[unit]["UIDamage"], (int) effectType, effectValue, critical, (viewPoint.x - 0.5f)*ScreenX, (viewPoint.y - 0.5f)*ScreenY);
        }
    }

    public void ShowUnitCoin(NTGBattleUnitController mob, NTGBattlePlayerController player, float coin)
    {
        if (player == localPlayerController && unitUiMap.ContainsKey(mob))
        {
            NTGApplicationController.Instance.LuaCall("UIDamage", "ShowDamage", unitUiMap[mob]["UIDamage"], 6, coin, false);
        }
    }

    public void ShowUnitSign(NTGBattleUnitController mob)
    {
        if (mob.visibility && mob.rendererVisible && unitUiMap.ContainsKey(mob))
        {
            NTGApplicationController.Instance.LuaCall("UIPlayerInfo", "ShowSign", unitUiMap[mob], 1, true);
            StartCoroutine(doShowUnitSign(mob));
        }
    }

    public enum UnitStateType
    {
        Slow = 1,
        Recover = 2,
        Blow = 3,
        Stun = 4,
        Recall = 5,
    }

    public void SetUnitState(NTGBattleUnitController unit, UnitStateType type, float time)
    {
        if (unit is NTGBattlePlayerController && unit.visibility && unit.rendererVisible && unitUiMap.ContainsKey(unit))
        {
            NTGApplicationController.Instance.LuaCall("UIPlayerInfo", "SetState", unitUiMap[unit], (int) type, time);
        }
    }

    private IEnumerator doShowUnitSign(NTGBattleUnitController mob)
    {
        yield return new WaitForSeconds(1.0f);
        if (mob.visibility && mob.rendererVisible && unitUiMap.ContainsKey(mob))
        {
            NTGApplicationController.Instance.LuaCall("UIPlayerInfo", "ShowSign", unitUiMap[mob], 1, false);
        }
    }

    public void SelectAlly(int index)
    {
        localPlayerController.TargetUnit(allyPlayerList[index] as NTGBattlePlayerController);
    }

    public void SelectEnemy(int index)
    {
        localPlayerController.TargetUnit(enemyPlayerList[index] as NTGBattlePlayerController);
    }

    private LuaTable uiBattleAPI;
    private LuaTable pvpMallAPI;
    private LuaTable battleHeroDetailAPI;
    private LuaTable battleInfoAPI;

    public void OnDestroy()
    {
        NTGApplicationController.Instance.RemoveTableCache("PVPBattleLoadingAPI_1.Instance");

        NTGApplicationController.Instance.RemoveTableCache("BattleResult27API.Instance");
        NTGApplicationController.Instance.RemoveTableCache("UIBattleAPI.Instance");
        NTGApplicationController.Instance.RemoveTableCache("PVPMallAPI.Instance");
        NTGApplicationController.Instance.RemoveTableCache("BattleHeroDetailAPI.Instance");
        NTGApplicationController.Instance.RemoveTableCache("BattleInfoAPI.Instance");
    }

    public delegate void ButtonEventHandler();

    public delegate void ButtonClickHandler(string index);

    public delegate bool MallEventHandler(string id, double price);

    public delegate void SkillCancelHandler(bool cancel);

    public delegate void PlayerChatHandler(double id, double type, string msg);


    public void LoadResultPanel(int win)
    {
        var r = NTGApplicationController.Instance.LuaCall("GameManager", "CreatePanelAsync", "BattleResult27");

        StartCoroutine(doLoadResultPanel((LuaTable) r[0], win));
    }

    private LuaTable battleResultAPI;

    private IEnumerator doLoadResultPanel(LuaTable async, int win)
    {
        while (((bool) async["Done"]) == false)
        {
            yield return null;
        }

        var api = NTGApplicationController.Instance.LuaGetTable("BattleResult27API.Instance");
        NTGApplicationController.Instance.LuaCall("BattleResult27API", "SetBattleResult", api, win);
        battleResultAPI = api;
    }

    public void SetBattleLog(int log)
    {
        StartCoroutine(doSetBattleLog(log));
    }

    private IEnumerator doSetBattleLog(int log)
    {
        while (battleResultAPI == null)
        {
            yield return null;
        }
        NTGApplicationController.Instance.LuaCall("BattleResult27API", "SetBattleLogId", battleResultAPI, log);
    }

    public void LoadUIPanel()
    {
        var pvpMall = NTGApplicationController.Instance.LuaCall("GameManager", "CreatePanel", "PVPMall");
        ((Transform) pvpMall[0]).SetAsFirstSibling();

        var battleHeroDetail = NTGApplicationController.Instance.LuaCall("GameManager", "CreatePanel", "BattleHeroDetail");
        ((Transform) battleHeroDetail[0]).SetAsFirstSibling();

        var battleInfo = NTGApplicationController.Instance.LuaCall("GameManager", "CreatePanel", "BattleInfo");
        ((Transform) battleInfo[0]).SetAsFirstSibling();

        var r1 = NTGApplicationController.Instance.LuaCall("GameManager", "CreatePanel", "UIBattle");
        ((Transform) r1[0]).SetAsFirstSibling();
        //var r2 = NTGApplicationController.Instance.LuaCall("GameManager", "CreatePanel", "UIPlayer");
        //((Transform) r2[0]).SetAsFirstSibling();

        unitUiBase = ((Transform) r1[0]).Find("UIPlayerPanel");
        unitUiTemplate = unitUiBase.Find("PlayerUI");
        unitUiTemplate.gameObject.SetActive(false);
    }

    public RectTransform miniMapRectTransform;

    public void MiniMapCreate(NTGBattleUnitController unit, int type, int camp, string icon)
    {
        if (unit.unitMinimap == null)
        {
            var r = NTGApplicationController.Instance.LuaCall("UIBattleAPI", "MiniMapCreate", uiBattleAPI, unit.id, type, camp, icon);
            unit.unitMinimap = (r[0] as GameObject).transform;
        }
    }

    public void MiniMapDestory(NTGBattleUnitController unit)
    {
        if (unit.unitMinimap != null)
        {
            NTGApplicationController.Instance.LuaCall("UIBattleAPI", "MiniMapDestroy", uiBattleAPI, unit.id);
            unit.unitMinimap = null;
        }
    }

    public void StartPlayerReviveCountdown(float duration)
    {
        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "ReviveCountDown", uiBattleAPI, duration);
    }

    public void InitUI()
    {
        if (mainController.serverSimulator)
        {
            return;
        }

        if (localPlayerController.group == 2)
        {
            mainCameraController.ReverseCamera();
        }

        //StartCoroutine(doInitUI());

        doInitUI();
    }

    public bool updateSkillHint;

    public IEnumerator doUpdateSkillHint(int index)
    {
        if (localPlayerController.skills[index] == null)
            yield break;

        var shown = false;

        while (updateSkillHint)
        {
            var axis = (Vector2) uiBattleAPI["selectedAxis"];
            var x = axis.x;
            var z = axis.y;

            if (x == 0 && z == 0 && localPlayerController.targetUnit != null && (localPlayerController.transform.position - localPlayerController.targetUnit.transform.position).sqrMagnitude < localPlayerController.skills[index].sqrRange)
            {
                x = localPlayerController.targetUnit.transform.position.x - localPlayerController.transform.position.x;
                z = localPlayerController.targetUnit.transform.position.z - localPlayerController.transform.position.z;

                hintController.hintOffset = new Vector3(x, 0, z);
            }
            else
            {
                x *= localPlayerController.skills[index].range;
                z *= localPlayerController.skills[index].range;

                if (localPlayerController.group == 1)
                {
                    hintController.hintOffset = new Vector3(x, 0, z);
                }
                else
                {
                    hintController.hintOffset = new Vector3(-x, 0, -z);
                }
            }

            if (!shown && (index == 0 || localPlayerController.skills[index].inCd <= 0))
            {
                hintController.HintShow(localPlayerController.skills[index]);
                shown = true;
            }

            if (shown)
                hintController.UpdateHint();

            yield return null;
        }
    }

    public void doInitUI()
    {
        //yield return null;

        uiBattleAPI = NTGApplicationController.Instance.LuaGetTable("UIBattleAPI.Instance");

        StartCoroutine(doJoystick());

        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetRoleId", uiBattleAPI, localPlayerController.roleId);

        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "RegisterDelegateSendQuickMessage", uiBattleAPI, (PlayerChatHandler) ((id, type, msg) =>
        {
            var player = mainController.FindUnit(id.ToString()) as NTGBattlePlayerController;
            if (player != null)
            {
                if (type == 1)
                {
                    if (unitUiMap.ContainsKey(player))
                        NTGApplicationController.Instance.LuaCall("UIPlayerInfo", "ShowChat", unitUiMap[player], msg);
                }
                else if (type == 2)
                {
                    int camp;
                    if (player == localPlayerController)
                        camp = 0;
                    else if (player.group == localPlayerController.group)
                        camp = 1;
                    else
                        camp = 2;

                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "ShowChatTip", uiBattleAPI, msg, player.icon, camp);
                }
            }
        }));

        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "RegisterDelegateATKDown", uiBattleAPI, (ButtonEventHandler) localPlayerController.ShootDown);
        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "RegisterDelegateATKUp", uiBattleAPI, (ButtonEventHandler) localPlayerController.ShootUp);

        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "RegisterDelegateSkill", uiBattleAPI, (ButtonClickHandler) (i =>
        {
            var axis = (Vector2) uiBattleAPI["selectedAxis"];

            if (localPlayerController.group == 1)
            {
                localPlayerController.SkillShoot(Convert.ToInt32(i), axis.x, axis.y);
            }
            else
            {
                localPlayerController.SkillShoot(Convert.ToInt32(i), -axis.x, -axis.y);
            }
        }));

        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "RegisterDelegateUpgradeSkill", uiBattleAPI, (ButtonClickHandler) (i => localPlayerController.SkillUpgrade(Convert.ToInt32(i))));
        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "RegisterDelegateChooseTarget", uiBattleAPI, (ButtonClickHandler) (i => localPlayerController.SelectTarget(Convert.ToInt32(i))));

        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "RegisterDelegateSkillDown", uiBattleAPI, (ButtonClickHandler) (i =>
        {
            var index = Convert.ToInt32(i);
            if ((localPlayerController.skills[index] == null || localPlayerController.skills[index].level == 0) && index != 0)
                return;

            if (localPlayerController.targetUnit == null)
                localPlayerController.SelectTarget(skillIndex: index);

            updateSkillHint = true;
            StartCoroutine(doUpdateSkillHint(index));
        }));
        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "RegisterDelegateSkillUp", uiBattleAPI, (ButtonClickHandler) (i =>
        {
            updateSkillHint = false;

            var index = Convert.ToInt32(i);
            if (localPlayerController.skills[index] != null)
                hintController.HintHide();
        }));
        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "RegisterDelegateChangeRangeColor", uiBattleAPI, (SkillCancelHandler) (c => { hintController.HintCancel(c); }));

        for (int i = 1; i <= 6; i++)
        {
            if (i < localPlayerController.skills.Length && localPlayerController.skills[i] != null)
            {
                NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 9, localPlayerController.skills[i].name); //Skill Name
                NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 0, localPlayerController.skills[i].icon); // Skill Icon
                NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 1, localPlayerController.skills[i].levelCap); // Max Skill Level                

                if (i > 3)
                {
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 10, true, localPlayerController.roleId); // PlayerSkill Show
                }

                if (!mainController.DebugMode)
                {
                    //NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 6, ""); // Desc
                }
            }
            else
            {
                NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 1, 1); // Max Skill Level
                NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 2, 0); // Skill Level
                NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 3, 1.0f); // Max CD
                NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 4, 0.0f); // CD

                if (i > 3)
                {
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 10, false); // PlayerSkill Show
                }
                else
                {
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillUpgrade", uiBattleAPI, i, false);
                }
            }
        }

        allyList = new NTGBattlePlayerController[5];
        enemyList = new NTGBattlePlayerController[5];

        allyPlayerList = new ArrayList();
        enemyPlayerList = new ArrayList();

        foreach (var pc in unitsBase.GetComponentsInChildren<NTGBattlePlayerController>())
        {
            if (pc.group == localPlayerController.group)
            {
                allyList[pc.position%10] = pc;
            }
            else
            {
                enemyList[pc.position%10] = pc;
            }
        }
        var ally = new ArrayList();
        for (int i = 0; i < allyList.Length; i++)
        {
            if (allyList[i] != null && allyList[i].id != localPlayerController.id)
                allyPlayerList.Add(allyList[i]);

            if (allyList[i] != null)
                ally.Add(allyList[i]);
        }
        allyList = new NTGBattlePlayerController[ally.Count];
        ally.CopyTo(allyList);

        for (int i = 0; i < enemyList.Length; i++)
        {
            if (enemyList[i] != null)
                enemyPlayerList.Add(enemyList[i]);
        }
        enemyList = new NTGBattlePlayerController[enemyPlayerList.Count];
        enemyPlayerList.CopyTo(enemyList);

        for (int i = 1; i <= 4; i++)
        {
            if (i - 1 < allyPlayerList.Count)
            {
                NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetAllyInfo", uiBattleAPI, i, 5, true);
                NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetAllyInfo", uiBattleAPI, i, 0, (allyPlayerList[i - 1] as NTGBattlePlayerController).icon);
            }
            else
            {
                NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetAllyInfo", uiBattleAPI, i, 5, false);
            }
        }

        miniMapRectTransform = uiBattleAPI["miniMapRT"] as RectTransform;

        StartCoroutine(UpdateUI());
        //StartCoroutine(UpdatePlayerListUI());
        StartCoroutine(UpdateUnitUI());

        pvpMallAPI = NTGApplicationController.Instance.LuaGetTable("PVPMallAPI.Instance");

        NTGApplicationController.Instance.LuaCall("PVPMallAPI", "BuyEquip", pvpMallAPI, (MallEventHandler) localPlayerController.BuyEquip);
        NTGApplicationController.Instance.LuaCall("PVPMallAPI", "SellEquip", pvpMallAPI, (MallEventHandler) localPlayerController.SellEquip);

        NTGApplicationController.Instance.LuaCall("PVPMallAPI", "FirstTimeOpen", pvpMallAPI, localPlayerController.roleId);

        StartCoroutine(doUpdateMall());

        battleHeroDetailAPI = NTGApplicationController.Instance.LuaGetTable("BattleHeroDetailAPI.Instance");
        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "RegisterDelegateUpdateHeroDetailData", uiBattleAPI, (ButtonEventHandler) UpdateBattleHeroDetailPanel);


        battleInfoAPI = NTGApplicationController.Instance.LuaGetTable("BattleInfoAPI.Instance");
        NTGApplicationController.Instance.LuaCall("BattleInfoAPI", "OpenPanelReceiveData", battleInfoAPI, (ButtonEventHandler) StartUpdateBattleInfo);
        NTGApplicationController.Instance.LuaCall("BattleInfoAPI", "ClosePanelDontReceive", battleInfoAPI, (ButtonEventHandler) StopUpdateBattleInfo);
    }

    public void UpdateBattleHeroDetailPanel()
    {
        NTGApplicationController.Instance.LuaCall("BattleHeroDetailAPI", "UpdateData", battleHeroDetailAPI, localPlayerController.roleId, localPlayerController.level, localPlayerController.baseAttrs);
    }

    private IEnumerator doUpdateMall()
    {
        while (true)
        {
            NTGApplicationController.Instance.LuaCall("PVPMallAPI", "GetCurrentMoney", pvpMallAPI, localPlayerController.coin);

            yield return new WaitForSeconds(0.1f);
        }
    }

    //public LuaTable AddUnitUI(NTGBattleUnitController unit, string type)
    //{
    //    if (mainController.serverSimulator)
    //        return null;

    //    if (unitUiMap.ContainsKey(unit))
    //        return null;

    //    var unitUi = Instantiate(unitUiTemplate.gameObject);
    //    unitUi.transform.SetParent(unitUiBase.Find(type));
    //    unitUi.transform.localScale = unit.transform.localScale;
    //    unitUi.SetActive(true);

    //    unit.unitUi = unitUi.transform;

    //    foreach (var luaScript in unitUi.GetComponents<NTGLuaScript>())
    //    {
    //        if (luaScript.luaScript == "Logic.M022.UIBattle.UIPlayerInfo")
    //        {
    //            NTGApplicationController.Instance.LuaCall("UIPlayerInfo", "SetHeroUiMountPoint", luaScript.self, unit.unitUiAnchor);

    //            unitUiMap.Add(unit, luaScript.self);

    //            return luaScript.self;
    //        }
    //    }

    //    return null;
    //}

    public void HideUnitUI(NTGBattleUnitController unit, bool visibility)
    {
        if (unitUiMap.ContainsKey(unit))
        {
            NTGApplicationController.Instance.LuaCall("UIPlayerInfo", "HideHPInfo", unitUiMap[unit], visibility);
        }
    }

    //public void RemoveUnitUI(NTGBattleUnitController unit)
    //{
    //    if (unitUiMap.ContainsKey(unit))
    //    {
    //        Destroy(((NTGLuaScript) unitUiMap[unit]["this"]).gameObject);
    //        unitUiMap.Remove(unit);
    //    }
    //}

    public class BattleUpdateSkillData
    {
        public bool Valid;
        public int Id;
        public int Level;
        public int MPCost;
        public float CD;
        public int MaxCD;
        public bool MpEnough;
        public bool CanUpgrade;
    }

    public class BattleUpdatePlayerData
    {
        public bool Valid;
        public float HPRatio;
        public bool SkillReady;
        public int ReviveCount;
        public string Icon;
    }

    public class BattleUpdateData
    {
        public string GameDuration;
        public string FPS;
        public string TeamKill;
        public string EnemyTeamKill;
        public string PersonKill;
        public string PersonDead;
        public string PersonAssists;
        public string Coin;
        public string NetworkLatency;

        public bool TargetActive;
        public string TargetIcon;
        public float TargetHp;
        public float TargetHpMax;
        public float TargetMp;
        public float TargetMpMax;
        public float TargetPAtk;
        public float TargetMAtk;
        public float TargetPDef;
        public float TargetMDef;

        public NTGBattlePlayerController Player;

        public BattleUpdateSkillData[] SkillDatas;

        public BattleUpdatePlayerData[] Ally;
        public BattleUpdatePlayerData[] Enemy;
    }

    private IEnumerator UpdateUI()
    {
        var data = new BattleUpdateData();
        data.SkillDatas = new BattleUpdateSkillData[6];
        for (int i = 0; i < data.SkillDatas.Length; i++)
            data.SkillDatas[i] = new BattleUpdateSkillData();

        data.Ally = new BattleUpdatePlayerData[5];
        for (int i = 0; i < data.Ally.Length; i++)
            data.Ally[i] = new BattleUpdatePlayerData();

        data.Enemy = new BattleUpdatePlayerData[5];
        for (int i = 0; i < data.Enemy.Length; i++)
            data.Enemy[i] = new BattleUpdatePlayerData();


        var enemyList = new ArrayList();

        var updateFunction = NTGApplicationController.Instance.LuaGetFunction("UIBattleAPI", "BattleUpdate");

        while (true)
        {
            data.GameDuration = String.Format("{0:00}:{1:00}", (int) ((Time.time - mainController.battleStartTime)/60), (Time.time - mainController.battleStartTime)%60);
            data.FPS = ((int) Math.Round(fps)).ToString();
            data.TeamKill = mainController.allyScore.ToString();
            data.EnemyTeamKill = mainController.enemyScore.ToString();
            data.PersonKill = localPlayerController.statistic.kill.ToString();
            data.PersonDead = localPlayerController.statistic.death.ToString();
            data.PersonAssists = localPlayerController.statistic.assist.ToString();
            data.Coin = String.Format("{0}", (int) localPlayerController.coin);

            if (netService != null && netService.IsRunning())
            {
                data.NetworkLatency = String.Format("{0}ms", TGNetService.GetServerLatency());
            }
            if (localPlayerController.targetUnit == null)
            {
                data.TargetActive = false;
            }
            else
            {
                data.TargetActive = true;
                data.TargetIcon = localPlayerController.targetUnit.icon;
                data.TargetHp = localPlayerController.targetUnit.hp;
                data.TargetHpMax = localPlayerController.targetUnit.hpMax;
                data.TargetMp = localPlayerController.targetUnit.mp;
                data.TargetMpMax = localPlayerController.targetUnit.mpMax;
                data.TargetPAtk = localPlayerController.targetUnit.pAtk;
                data.TargetMAtk = localPlayerController.targetUnit.mAtk;
                data.TargetPDef = localPlayerController.targetUnit.pDef;
                data.TargetMDef = localPlayerController.targetUnit.mDef;

                if (data.TargetHp < 0)
                    data.TargetHp = 0;
            }
            data.Player = localPlayerController;

            for (int i = 1; i <= 6; i++)
            {
                if (i < localPlayerController.skills.Length && localPlayerController.skills[i] != null)
                {
                    data.SkillDatas[i - 1].Valid = true;
                    data.SkillDatas[i - 1].Id = localPlayerController.skills[i].id;
                    data.SkillDatas[i - 1].Level = localPlayerController.skills[i].level;
                    data.SkillDatas[i - 1].MPCost = (int) localPlayerController.skills[i].mpCost;
                    data.SkillDatas[i - 1].CD = localPlayerController.skills[i].inCd;
                    data.SkillDatas[i - 1].MaxCD = (int) localPlayerController.skills[i].cd;
                    data.SkillDatas[i - 1].MpEnough = localPlayerController.mp >= localPlayerController.skills[i].mpCost;
                    if (!mainController.DebugMode && i <= 3)
                    {
                        bool canUpgrade = localPlayerController.skillPoint > 0 && localPlayerController.level >= localPlayerController.skills[i].requireUpgradeLevel && localPlayerController.skills[i].level < localPlayerController.skills[i].levelCap;
                        data.SkillDatas[i - 1].CanUpgrade = canUpgrade;
                    }
                }
                else
                {
                    data.SkillDatas[i - 1].Valid = false;
                }
            }

            for (int i = 0; i < allyPlayerList.Count; i++)
            {
                var player = allyPlayerList[i] as NTGBattlePlayerController;

                data.Ally[i].Valid = true;
                data.Ally[i].HPRatio = player.hp/player.hpMax;
                if (player.skills[3] != null && player.skills[3].level > 0)
                {
                    data.Ally[i].SkillReady = player.skills[3].inCd <= 0;
                }
                else
                {
                    data.Ally[i].SkillReady = false;
                }
                data.Ally[i].ReviveCount = (int) player.reviveCountDown;
            }

            enemyList.Clear();
            for (int i = 0; i < enemyPlayerList.Count; i++)
            {
                var player = enemyPlayerList[i] as NTGBattlePlayerController;
                if (player.reviveCountDown > 0)
                {
                    int p = enemyList.Count;
                    for (int j = 0; j < enemyList.Count; j++)
                    {
                        var pc = enemyList[j] as NTGBattlePlayerController;
                        if (player.reviveCountDown < pc.reviveCountDown)
                        {
                            p = j;
                            break;
                        }
                    }
                    enemyList.Insert(p, player);
                }
            }

            for (int i = 1; i <= 5; i++)
            {
                if (i - 1 < enemyList.Count)
                {
                    var player = enemyList[i - 1] as NTGBattlePlayerController;

                    data.Enemy[i - 1].Valid = true;
                    data.Enemy[i - 1].Icon = player.icon;
                    data.Enemy[i - 1].ReviveCount = (int) player.reviveCountDown;
                }
                else
                {
                    data.Enemy[i - 1].Valid = false;
                }
            }


            //updateFunction.Call(uiBattleAPI, data);
            updateFunction.BeginPCall();
            updateFunction.Push(uiBattleAPI);
            updateFunction.Push(data);
            updateFunction.PCall();
            updateFunction.EndPCall();

            yield return new WaitForSeconds(0.1f);
        }
    }

    private bool[] skillInCd;
    private int[] skillLevel;

    private IEnumerator UpdateSkillUI()
    {
        skillInCd = new bool[3];
        skillLevel = new int[3];

        while (true)
        {
            for (int i = 1; i <= 6; i++)
            {
                if (i < localPlayerController.skills.Length && localPlayerController.skills[i] != null)
                {
                    //if (localPlayerController.skills[i].level > skillLevel[i - 1])
                    //{
                    //    PlayBattleAudio(BattleAudio.SkillUpgrade);
                    //}
                    //if (localPlayerController.skills[i].inCd <= 0 && skillInCd[i - 1])
                    //{
                    //    PlayBattleAudio(BattleAudio.SkillCDDone);
                    //}
                    //skillInCd[i - 1] = localPlayerController.skills[i].inCd > 0;
                    //skillLevel[i - 1] = localPlayerController.skills[i].level;

                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 2, localPlayerController.skills[i].level); // Skill Level
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 3, localPlayerController.skills[i].cd); // Max CD
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 4, localPlayerController.skills[i].inCd); // CD
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillInfo", uiBattleAPI, i, 5, localPlayerController.mp >= localPlayerController.skills[i].mpCost); // IsMpEnough                    

                    if (!mainController.DebugMode && i <= 3)
                    {
                        bool canUpgrade = localPlayerController.skillPoint > 0 && localPlayerController.level >= localPlayerController.skills[i].requireUpgradeLevel && localPlayerController.skills[i].level < localPlayerController.skills[i].levelCap;
                        NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetSkillUpgrade", uiBattleAPI, i, canUpgrade);
                    }
                }
            }


            yield return new WaitForSeconds(0.1f);
        }
    }

    private IEnumerator UpdatePlayerListUI()
    {
        var enemyList = new ArrayList();

        while (true)
        {
            for (int i = 0; i < allyPlayerList.Count; i++)
            {
                var player = allyPlayerList[i] as NTGBattlePlayerController;

                NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetAllyInfo", uiBattleAPI, i + 1, 2, player.hp/player.hpMax);

                if (player.skills[3] != null && player.skills[3].level > 0)
                {
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetAllyInfo", uiBattleAPI, i + 1, 3, player.skills[3].inCd <= 0);
                }
                else
                {
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetAllyInfo", uiBattleAPI, i + 1, 3, false);
                }

                if (player.reviveCountDown > 0)
                {
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetAllyInfo", uiBattleAPI, i + 1, 4, player.reviveCountDown);
                }
            }

            enemyList.Clear();
            for (int i = 0; i < enemyPlayerList.Count; i++)
            {
                var player = enemyPlayerList[i] as NTGBattlePlayerController;
                if (player.reviveCountDown > 0)
                {
                    int p = enemyList.Count;
                    for (int j = 0; j < enemyList.Count; j++)
                    {
                        var pc = enemyList[j] as NTGBattlePlayerController;
                        if (player.reviveCountDown < pc.reviveCountDown)
                        {
                            p = j;
                            break;
                        }
                    }
                    enemyList.Insert(p, player);
                }
            }

            for (int i = 1; i <= 5; i++)
            {
                if (i - 1 < enemyList.Count)
                {
                    var player = enemyList[i - 1] as NTGBattlePlayerController;
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetEnemyInfo", uiBattleAPI, i, 5, true);
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetEnemyInfo", uiBattleAPI, i, 0, player.icon);
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetEnemyInfo", uiBattleAPI, i, 4, player.reviveCountDown);
                }
                else
                {
                    NTGApplicationController.Instance.LuaCall("UIBattleAPI", "SetEnemyInfo", uiBattleAPI, i, 5, false);
                }
            }

            yield return new WaitForSeconds(0.1f);
        }
    }

    public void UpdateUnitUIPosition()
    {
        foreach (var m in unitUiMap)
        {
            var viewPoint = Camera.main.WorldToViewportPoint(m.Key.unitUiAnchor.position);
            m.Key.unitUi.localPosition = new Vector3((viewPoint.x - 0.5f)*ScreenX, (viewPoint.y - 0.5f)*ScreenY, 0);
        }
    }

    private IEnumerator UpdateUnitUI()
    {
        while (unitUiMap.Count == 0)
        {
            yield return null;
        }

        var SetPlayerInfo = NTGApplicationController.Instance.LuaGetFunction("UIPlayerInfo", "SetPlayerInfo");

        while (true)
        {
            foreach (var m in unitUiMap)
            {
                var player = m.Key as NTGBattlePlayerController;
                if (player != null)
                {
                    //SetPlayerInfo.Call(m.Value, m.Key.hpMax + m.Key.shield, m.Key.hp + m.Key.shield, m.Key.mpMax, m.Key.mp, m.Key.level, m.Key.name, player.expCap, player.exp, m.Key.shield);

                    SetPlayerInfo.BeginPCall();
                    SetPlayerInfo.Push(m.Value);
                    SetPlayerInfo.Push(m.Key.hpMax + m.Key.shield);
                    SetPlayerInfo.Push(m.Key.hp + m.Key.shield);
                    SetPlayerInfo.Push(m.Key.mpMax);
                    SetPlayerInfo.Push(m.Key.mp);
                    SetPlayerInfo.Push(m.Key.level);
                    SetPlayerInfo.Push(m.Key.name);
                    SetPlayerInfo.Push(player.expCap);
                    SetPlayerInfo.Push(player.exp);
                    SetPlayerInfo.Push(m.Key.shield);
                    SetPlayerInfo.PCall();
                    SetPlayerInfo.EndPCall();                    

                }
                else
                {
                    //SetPlayerInfo.Call(m.Value, m.Key.hpMax, m.Key.hp, m.Key.mpMax, m.Key.mp, m.Key.level, m.Key.name);

                    SetPlayerInfo.BeginPCall();
                    SetPlayerInfo.Push(m.Value);
                    SetPlayerInfo.Push(m.Key.hpMax);
                    SetPlayerInfo.Push(m.Key.hp);
                    SetPlayerInfo.Push(m.Key.mpMax);
                    SetPlayerInfo.Push(m.Key.mp);
                    SetPlayerInfo.Push(m.Key.level);
                    SetPlayerInfo.Push(m.Key.name);
                    SetPlayerInfo.PCall();
                    SetPlayerInfo.EndPCall();  
                }
            }

            yield return new WaitForSeconds(0.1f);
        }
    }

    public class UIBattleInfoItem
    {
        public int RoleId;
        public string SkinId;
        public string PlayerName;
        public int ZSkillId;
        public int Level;
        public int DeadCount;
        public int CDCount;
        public int Kill;
        public int Dead;
        public int Assistant;
        public int Money;
        public int Hp;
        public int PAtk;
        public int MAtk;
        public int PDef;
        public int MDef;
        public int[] Equips;
    }

    public bool updateBattleInfo;
    private UIBattleInfoItem[] allyInfos;
    private UIBattleInfoItem[] enemyInfos;

    public void StartUpdateBattleInfo()
    {
        updateBattleInfo = true;
        StartCoroutine(doUpdateBattleInfo());
    }

    public void StopUpdateBattleInfo()
    {
        updateBattleInfo = false;
    }

    private IEnumerator doUpdateBattleInfo()
    {
        if (allyInfos == null)
        {
            allyInfos = new UIBattleInfoItem[allyList.Length];
            for (int i = 0; i < allyInfos.Length; i++)
            {
                allyInfos[i] = new UIBattleInfoItem();
            }

            enemyInfos = new UIBattleInfoItem[enemyList.Length];
            for (int i = 0; i < enemyInfos.Length; i++)
            {
                enemyInfos[i] = new UIBattleInfoItem();
            }
        }

        while (updateBattleInfo)
        {
            for (int i = 0; i < allyInfos.Length; i++)
            {
                var player = allyList[i];
                allyInfos[i].RoleId = player.roleId;
                allyInfos[i].SkinId = player.icon;
                allyInfos[i].PlayerName = player.name;
                allyInfos[i].ZSkillId = player.skills[4].id;
                allyInfos[i].Level = player.level;
                allyInfos[i].DeadCount = (int) player.reviveCountDown;
                allyInfos[i].CDCount = (int) player.skills[4].inCd;
                allyInfos[i].Kill = player.statistic.kill;
                allyInfos[i].Dead = player.statistic.death;
                allyInfos[i].Assistant = player.statistic.assist;
                allyInfos[i].Money = (int) player.statistic.coin;
                allyInfos[i].Hp = (int) player.hpMax;
                allyInfos[i].PAtk = (int) player.pAtk;
                allyInfos[i].MAtk = (int) player.mAtk;
                allyInfos[i].PDef = (int) player.pDef;
                allyInfos[i].MDef = (int) player.mDef;
                allyInfos[i].Equips = new int[player.equips.Count];
                for (int j = 0; j < player.equips.Count; j++)
                {
                    allyInfos[i].Equips[j] = ((NTGBattleMemberEquip) player.equips[j]).Id;
                }
            }

            for (int i = 0; i < enemyInfos.Length; i++)
            {
                var player = enemyList[i];
                enemyInfos[i].RoleId = player.roleId;
                enemyInfos[i].SkinId = player.icon;
                enemyInfos[i].PlayerName = player.name;
                enemyInfos[i].ZSkillId = player.skills[4].id;
                enemyInfos[i].Level = player.level;
                enemyInfos[i].DeadCount = (int) player.reviveCountDown;
                enemyInfos[i].CDCount = (int) player.skills[4].inCd;
                enemyInfos[i].Kill = player.statistic.kill;
                enemyInfos[i].Dead = player.statistic.death;
                enemyInfos[i].Assistant = player.statistic.assist;
                enemyInfos[i].Money = (int) player.statistic.coin;
                enemyInfos[i].Hp = (int) player.hpMax;
                enemyInfos[i].PAtk = (int) player.pAtk;
                enemyInfos[i].MAtk = (int) player.mAtk;
                enemyInfos[i].PDef = (int) player.pDef;
                enemyInfos[i].MDef = (int) player.mDef;
                enemyInfos[i].Equips = new int[player.equips.Count];
                for (int j = 0; j < player.equips.Count; j++)
                {
                    enemyInfos[i].Equips[j] = ((NTGBattleMemberEquip) player.equips[j]).Id;
                }
            }

            NTGApplicationController.Instance.LuaCall("BattleInfoAPI", "UpdateData", battleInfoAPI, allyInfos, enemyInfos);

            yield return new WaitForSeconds(1.0f);
        }
    }
}