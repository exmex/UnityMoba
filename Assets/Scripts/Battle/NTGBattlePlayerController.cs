using System;
using UnityEngine;
using System.Collections;

public class NTGBattlePlayerController : NTGBattleUnitController
{
    public UTGBattlePlayerVoiceController voiceController;

    public ArrayList equips;
    public NTGBattleUnitController targetUnit;

    private Vector3 samplePosition;
    private float sampleTime;

    public int roleId;
    public float exp;
    public float coin;
    public int skillPoint;

    public bool isAI;
    public bool isRobot;
    public UTGBattlePlayerAIController aic;

    public int atkType; //1:近战 2:远程

    public float expCap
    {
        get { return NTGBattleDataController.GetPlayerExpCap(level); }
    }

    public class KillRecord
    {
        public float time;
        public NTGBattlePlayerController victim;
    }

    public Queue killSteak;

    public class DeathRecord
    {
        public float time;
        public NTGBattleUnitController killer;
    }

    public Queue deathSteak;

    private void Awake()
    {
        base.Awake();

        //equips = new NTGBattleEquipController[6];
        equips = new ArrayList();

        killSteak = new Queue();
        deathSteak = new Queue();
    }

    //public void LateUpdate()
    //{
    //    transform.position = roleController.transform.position;
    //    transform.rotation = roleController.transform.rotation;

    //    roleController.transform.localPosition = Vector3.zero;
    //    roleController.transform.localRotation = Quaternion.identity;
    //}

    private void Start()
    {
        base.Start();

        sampleTime = Time.time;
        samplePosition = transform.position;

        StartCoroutine(doTargetUnitCheck());
    }

    public bool manualRotation;

    public float idleTime;
    public float movingTime;
    public bool walking;

    private void Update()
    {
        //if (navAgent != null)
        //{
        //    transform.position = navAgent.transform.position;
        //    transform.rotation = navAgent.transform.rotation;

        //    navAgent.transform.localPosition = Vector3.zero;
        //    navAgent.transform.localRotation = Quaternion.identity;
        //}

        var walkSpeedRatio = MoveSpeed/2.0f;
        walking = false;

        if (!Moveable)
        {
            navAgent.velocity = Vector3.zero;
        }

        //if (Time.time - sampleTime > 0.01f)
        //{
        if (Moveable && (transform.position - samplePosition).sqrMagnitude > Time.deltaTime*Time.deltaTime)
        {
            walking = true;

            if (voiceController != null)
            {
                if (idleTime > 6.0f)
                {
                    voiceController.StartMoving();
                }

                idleTime = 0;
                movingTime += Time.deltaTime;

                if (movingTime > 10.0f)
                {
                    voiceController.KeepMoving();
                    movingTime = 0;
                }
            }
        }
        else
        {
            if (voiceController != null)
            {
                idleTime += Time.deltaTime;
                movingTime = 0;
            }
        }

        unitAnimator.SetBool("walk", walking);
        //unitAnimator.SetFloat("walkspeed", walkSpeedRatio);

        //sampleTime = Time.time;
        samplePosition = transform.position;
        //}

        if (manualRotation)
        {
            navAgent.updateRotation = false;

            if (master)
            {
                if (Moveable && joystickDirection.sqrMagnitude > 0)
                    transform.forward = Vector3.RotateTowards(transform.forward, new Vector3(joystickDirection.x, 0, joystickDirection.z), 30.0f*Time.deltaTime, 0);
            }
            else
            {
                if (navAgent.velocity.sqrMagnitude > 0)
                    transform.forward = Vector3.RotateTowards(transform.forward, new Vector3(navAgent.velocity.x, 0, navAgent.velocity.z), 30.0f*Time.deltaTime, 0);
            }
        }
        else
        {
            navAgent.updateRotation = true;
        }
    }

    //public void LateUpdate()
    //{
    //    if (navAgent != null)
    //    {
    //        transform.position = navAgent.transform.position;
    //        transform.rotation = navAgent.transform.rotation;

    //        navAgent.transform.localPosition = Vector3.zero;
    //        navAgent.transform.localRotation = Quaternion.identity;
    //    }
    //}


    private IEnumerator doTargetUnitCheck()
    {
        while (true)
        {
            if (targetUnit != null && (!targetUnit.Lockable(group) || (transform.position - targetUnit.transform.position).sqrMagnitude > sqrTargetRange))
            {
                targetUnit = null;
            }

            yield return new WaitForSeconds(0.1f);
        }
    }

    public Vector3 joystickDirection;

    public void SetVelocity(Vector3 v, bool slow = false)
    {
        joystickDirection = v;

        if (!Moveable)
        {
            return;
        }

        if (v.magnitude > 0)
        {
            SetStatus(UnitStatus.Approach, false);
            if (navAgent.enabled)
            {
                navAgent.ResetPath();
            }

            SetStatus(UnitStatus.Shoot, false);
            interruptSource = ShootInterruptSource.Move;
        }

        if (!GetStatus(UnitStatus.Approach))
        {
            if (v.magnitude > 0)
            {
                isShooting = false;

                //transform.LookAt(new Vector3(transform.position.x + v.x, transform.position.y, transform.position.z + v.z));
                //navAgent.acceleration = 0.1f;
                manualRotation = true;
                navAgent.velocity = v.normalized*MoveSpeed;
                //navAgent.velocity = v*MoveSpeed;
            }
            else
            {
                navAgent.velocity = Vector3.zero;
            }
        }
    }

    private bool isShooting = false;

    private IEnumerator doShoot()
    {
        while (alive && (isShooting || isShootDown))
        {
            if (!Shootable)
            {
                yield return null;
                continue;
            }

            SetStatus(UnitStatus.Approach, false);

            if (mainController.targetMode == NTGBattleMainController.TargetMode.Locked)
            {
                if (targetUnit == null || !targetUnit.Lockable(group))
                {
                    targetUnit = FindTarget(targetRange, type: TargetType.Player);
                    if (targetUnit == null)
                        targetUnit = FindTarget(targetRange);
                }
            }
            else if (mainController.targetMode == NTGBattleMainController.TargetMode.Smart)
            {
                if (targetUnit == null || !targetUnit.Lockable(group))
                {
                    targetUnit = SmartTarget(skills[0]);
                }
            }

            if (targetUnit == null)
            {
                isShooting = false;
            }

            if (skills[0].inCd > 0)
            {
                yield return null;
                continue;
            }

            if (skills[0].reqTarget == 1 && (targetUnit == null || (skills[0].mask & targetUnit.mask) == 0))
            {
                yield return null;
                continue;
            }

            if (skills[0].reqTarget == 1 && (transform.position - targetUnit.transform.position).sqrMagnitude > skills[0].sqrRange)
            {
                yield return null;
                continue;
            }

            if (!skills[0].ShootCheck(targetUnit))
            {
                yield return null;
                continue;
            }

            if (skills[0].reqTarget == 2 && targetUnit != null && (transform.position - targetUnit.transform.position).sqrMagnitude > skills[0].sqrRange)
            {
                Approach(skills[0]);
            }
            else
            {
                if (mp >= skills[0].mpCost)
                {
                    mp -= skills[0].mpCost;

                    if (targetUnit != null && skills[0].facingType == NTGBattleSkillFacingType.Target)
                    {
                        transform.LookAt(new Vector3(targetUnit.transform.position.x, transform.position.y, targetUnit.transform.position.z));
                    }

                    skills[0].Shoot(targetUnit);

                    yield return new WaitForSeconds(skills[0].inCd);
                }
            }

            yield return null;
        }
    }

    private Coroutine _doShoot;

    private bool isShootDown;

    public void ShootDown()
    {
        if (mainController.targetMode == NTGBattleMainController.TargetMode.Smart)
        {
            targetUnit = SmartTarget(skills[0]);
        }

        isShooting = true;
        isShootDown = true;
        if (_doShoot != null)
        {
            StopCoroutine(_doShoot);
        }
        _doShoot = StartCoroutine(doShoot());
    }

    public void ShootUp()
    {
        //isShooting = false;
        isShootDown = false;
    }

    public ArrayList recentTargetedMobs = new ArrayList();
    public ArrayList recentTargetedPlayers = new ArrayList();

    public void SelectTarget(int index = 0, int skillIndex = 0)
    {
        if (index == 0)
        {
            targetUnit = FindTarget(targetRange);

            if (mainController.targetMode == NTGBattleMainController.TargetMode.Locked)
            {
                targetUnit = FindTarget(targetRange, type: TargetType.Player);
                if (targetUnit == null)
                    targetUnit = FindTarget(targetRange);
            }
            else if (mainController.targetMode == NTGBattleMainController.TargetMode.Smart)
            {
                targetUnit = SmartTarget(skills[skillIndex]);
            }
        }

        if (index == 1)
        {
            var target = FindTarget(targetRange, type: TargetType.Player, excludes: recentTargetedPlayers);
            if (target == null)
            {
                recentTargetedPlayers.Clear();
                target = FindTarget(targetRange, type: TargetType.Player);
            }
            if (target != null)
            {
                recentTargetedPlayers.Add(target);
                targetUnit = target;
            }
        }

        if (index == 2)
        {
            var target = FindTarget(targetRange, type: TargetType.Mob, excludes: recentTargetedMobs);
            if (target == null)
            {
                recentTargetedMobs.Clear();
                target = FindTarget(targetRange, type: TargetType.Mob);
            }
            if (target != null)
            {
                recentTargetedMobs.Add(target);
                targetUnit = target;
            }
        }
    }

    public void AddExp(float e)
    {
        exp += e;
        if (exp >= expCap)
        {
            AddPassive("LevelUp", p: new float[] {1});            
        }
    }

    public void AddCoin(float c)
    {
        coin += c;
        statistic.coin += c;
    }

    public override void LevelUp(int levels)
    {
        for (int l = levels; l > 0; l--)
        {
            if (NTGBattleDataController.CanPlayerLevelUp(level))
            {
                exp -= expCap;

                for (int i = passives.Count - 1; i >= 0; i--)
                {
                    var pBehaviour = (NTGBattlePassiveSkillBehaviour)passives[i];

                    pBehaviour.Notify(NTGBattlePassive.Event.LevelUp, null);
                }
                foreach (var pSkill in pSkills)
                {
                    pSkill.Notify(NTGBattlePassive.Event.LevelUp, null);
                }

                NTGBattleDataController.GrowPlayerMemberAttrs(ref baseAttrs, roleId);
                ApplyBaseAttrs();

                level++;
                skillPoint++;
            }
        }
    }

    public override void Kill(NTGBattleUnitController killer)
    {
        if (alive)
        {
            base.Kill(killer);

            unitAnimator.SetBool("dead", true);
            mainController.NotifyPlayerKill(this);

            if (voiceController != null)
                voiceController.Kill(killer);

            var givecoinGrade = 0;
            if (killSteak.Count > 0 && deathSteak.Count > 0)
                Debug.LogError("Player KillSteak and DeathSteak Can not Both Has Value! " + id);
            if (killSteak.Count > 0)
                givecoinGrade = killSteak.Count;
            else if (deathSteak.Count > 0)
                givecoinGrade = -deathSteak.Count;


            killSteak.Clear();
            deathSteak.Enqueue(new DeathRecord() {time = Time.time, killer = killer});

            HitRecord lastPlayerHit = null;
            NTGBattleUnitController lastHitter = killer;
            ArrayList assistSet = new ArrayList();
            while (hitRecords.Count > 0)
            {
                var hitRecord = hitRecords.Dequeue() as HitRecord;
                if (hitRecord.hitType == NTGBattleSkillBehaviour.EffectType.HpRecover || hitRecord.hitType == NTGBattleSkillBehaviour.EffectType.MpRecover)
                    continue;

                var a = hitRecord.shooter as NTGBattlePlayerController;
                if (a != null)
                {
                    if (!assistSet.Contains(a))
                    {
                        a.statistic.assist++;
                        assistSet.Add(a);
                    }
                    lastPlayerHit = hitRecord;
                }
                lastHitter = hitRecord.shooter;
            }

            if (lastPlayerHit != null && Time.time - lastPlayerHit.time < mainController.configX)
            {
                var k = lastPlayerHit.shooter as NTGBattlePlayerController;
                k.statistic.assist--;
                assistSet.Remove(k);
                k.statistic.kill++;
                k.deathSteak.Clear();
                k.killSteak.Enqueue(new KillRecord() {time = Time.time, victim = this});
                if (k.killSteak.Count > k.statistic.maxKillSteak)
                    k.statistic.maxKillSteak = k.killSteak.Count;
                lastHitter = k;

                for (int i = k.passives.Count - 1; i >= 0; i--)
                {
                    var pBehaviour = (NTGBattlePassiveSkillBehaviour) k.passives[i];
                    pBehaviour.Notify(NTGBattlePassive.Event.Kill, new NTGBattlePassive.EventKillParam() {victim = this});
                }

                foreach (var pSkill in k.pSkills)
                {
                    pSkill.Notify(NTGBattlePassive.Event.Kill, new NTGBattlePassive.EventKillParam {victim = this});
                }
            }

            mainController.uiController.ShowPlayerKillMessage(lastHitter, this, new KillRecord() {time = Time.time, victim = this});

            var giveexpPlayers = new ArrayList();
            foreach (NTGBattleUnitController unit in mainController.battleUnits)
            {
                if (unit is NTGBattlePlayerController && unit.group != group && (transform.position - unit.transform.position).sqrMagnitude < rewardRange*rewardRange)
                {
                    giveexpPlayers.Add(unit);
                }
            }
            foreach (NTGBattleUnitController assist in assistSet)
            {
                if (!giveexpPlayers.Contains(assist))
                {
                    giveexpPlayers.Add(assist);
                }

                for (int i = assist.passives.Count - 1; i >= 0; i--)
                {
                    var pBehaviour = (NTGBattlePassiveSkillBehaviour) assist.passives[i];
                    pBehaviour.Notify(NTGBattlePassive.Event.Assist, new NTGBattlePassive.EventAssistParam() {victim = this});
                }

                foreach (var pSkill in assist.pSkills)
                {
                    pSkill.Notify(NTGBattlePassive.Event.Assist, new NTGBattlePassive.EventAssistParam {victim = this});
                }
            }
            var giveexp = NTGBattleDataController.GetPlayerGiveExp(level)/giveexpPlayers.Count;
            foreach (NTGBattlePlayerController player in giveexpPlayers)
            {
                player.AddExp(giveexp);

                if (mainController.firstBlood && player == lastHitter)
                {
                    player.AddExp(mainController.sceneInfo.FirstBloodExp);
                }
            }

            var lastPlayerHitter = lastHitter as NTGBattlePlayerController;
            if (lastPlayerHitter != null)
            {
                var givecoin = NTGBattleDataController.GetPlayerGiveCoin(givecoinGrade);

                if (mainController.firstBlood)
                {
                    lastPlayerHitter.AddCoin(mainController.sceneInfo.FirstBloodCoin + givecoin);
                    mainController.uiController.ShowUnitCoin(this, lastPlayerHitter, mainController.sceneInfo.FirstBloodCoin + givecoin);
                }
                else
                {
                    lastPlayerHitter.AddCoin(givecoin);
                    mainController.uiController.ShowUnitCoin(this, lastPlayerHitter, givecoin);
                }
                if (lastPlayerHitter == mainController.uiController.localPlayerController)
                {
                    PlayFXOnce(UnitFX.Coin);
                }

                assistSet.Remove(lastPlayerHitter);
                if (assistSet.Count > 0)
                {
                    givecoin *= mainController.configYPlayer/assistSet.Count;
                    foreach (NTGBattlePlayerController assist in assistSet)
                    {
                        assist.AddCoin(givecoin);
                        mainController.uiController.ShowUnitCoin(this, assist, givecoin);
                    }
                }
            }

            if (mainController.firstBlood)
            {
                mainController.firstBlood = false;
            }

            if (navAgent.enabled)
            {
                navAgent.ResetPath();
                navAgent.enabled = false;
            }

            mainController.uiController.HideUnitUI(this, false);
            mainController.uiController.MiniMapDestory(this);

            AddPassive("Revive");
        }
    }

    public override void Revive(NTGBattleUnitController healer)
    {
        StartCoroutine(doReviveCountDown());
    }

    public float reviveCountDown;

    private IEnumerator doReviveCountDown()
    {
        reviveCountDown = NTGBattleDataController.GetPlayerReviveDuration(level);
        if (id == mainController.localId)
        {
            mainController.uiController.StartPlayerReviveCountdown(reviveCountDown);
        }
        while (reviveCountDown > 0)
        {
            reviveCountDown -= Time.deltaTime;
            yield return null;
        }
        viewController.Kill();

        Respawn();
    }


    public void SkillUpgrade(int index)
    {
        if (skillPoint > 0 && skills[index] != null && skills[index].level < skills[index].levelCap)
        {
            AddPassive("SkillUpgrade", sp: new[] {skills[index].id.ToString()});
        }
    }

    public void SkillUpgradeById(int skillId)
    {
        foreach (var skill in skills)
        {
            if (skill != null & skill.id == skillId)
            {
                skillPoint--;
                skill.Upgrade();
            }
        }
    }

    public void TargetUnit(NTGBattleUnitController unit)
    {
        if (unit is NTGBattleMobPoolController)
            return;

        if (unit != null && unit.Lockable(group) && unit != this && (transform.position - unit.transform.position).sqrMagnitude < sqrTargetRange)
        {
            targetUnit = unit;
        }
    }

    public NTGBattleUnitController SmartTarget(NTGBattleSkillController skill)
    {
        NTGBattleUnitController target = null;
        var units = viewController.unitsInView;

        float topScore = -1;
        NTGBattleUnitController lowPlayer = null;
        NTGBattleUnitController lowBuilding = null;
        NTGBattleUnitController lowMob = null;

        float lowPlayerHpPer = 1.0f;
        float lowBuildingHpPer = 1.0f;
        float lowMobHpPer = 1.0f;

        float lowPlayerScore = NTGBattleDataController.GetConfig("skill_player_hp");
        float lowBuildingScore = NTGBattleDataController.GetConfig("skill_building_hp");
        float lowMobScore = NTGBattleDataController.GetConfig("skill_mob_hp");

        if (skill.type != NTGBattleSkillType.Attack)
        {
            lowPlayerScore = NTGBattleDataController.GetConfig("atk_player_hp");
            lowBuildingScore = NTGBattleDataController.GetConfig("atk_building_hp");
            lowMobScore = NTGBattleDataController.GetConfig("atk_mob_hp");
        }

        for (int i = 0; i < units.Count; i++)
        {
            var unit = (NTGBattleUnitController) units[i];

            if (!unit.Lockable(group))
                continue;

            if ((skill.mask & unit.mask) == 0)
                continue;

            if (unit.group == group)
                continue;

            var sqrDist = (unit.transform.position - transform.position).sqrMagnitude;
            if (skill.reqTarget != 2 && sqrDist > skill.sqrRange)
                continue;

            float hpPercent = unit.hp/unit.hpMax;
            if (unit is NTGBattlePlayerController)
            {
                if (hpPercent < lowPlayerHpPer)
                {
                    lowPlayer = unit;
                    lowPlayerHpPer = hpPercent;
                }
            }
            else if (unit is NTGBattleMobController && (unit as NTGBattleMobController).type == 3)
            {
                if (hpPercent < lowBuildingHpPer)
                {
                    lowBuilding = unit;
                    lowBuildingHpPer = hpPercent;
                }
            }
            else
            {
                if (hpPercent < lowMobHpPer)
                {
                    lowMob = unit;
                    lowMobHpPer = hpPercent;
                }
            }
        }

        float sqrTopDist = float.MaxValue;
        for (int i = 0; i < units.Count; i++)
        {
            var unit = (NTGBattleUnitController) units[i];

            if (!unit.Lockable(group))
                continue;

            if ((skill.mask & unit.mask) == 0)
                continue;

            if (unit.group == group)
                continue;

            var sqrDist = (unit.transform.position - transform.position).sqrMagnitude;
            if (skill.reqTarget != 2 && sqrDist > skill.sqrRange)
                continue;

            float score = 0;
            if (skill.type == NTGBattleSkillType.Attack)
            {
                if (unit is NTGBattlePlayerController)
                {
                    score = NTGBattleDataController.GetConfig("atk_player");
                }
                else if (unit is NTGBattleMobController && (unit as NTGBattleMobController).type == 3)
                {
                    score = NTGBattleDataController.GetConfig("atk_building");
                }
                else
                {
                    score = NTGBattleDataController.GetConfig("atk_mob");
                }
            }
            else
            {
                if (unit is NTGBattlePlayerController)
                {
                    score = NTGBattleDataController.GetConfig("skill_player");
                }
                else if (unit is NTGBattleMobController && (unit as NTGBattleMobController).type == 3)
                {
                    score = NTGBattleDataController.GetConfig("skill_building");
                }
                else
                {
                    score = NTGBattleDataController.GetConfig("skill_mob");
                }
            }

            if (sqrDist > skill.sqrRange)
            {
                if (skill.type == NTGBattleSkillType.Attack)
                {
                    score -= NTGBattleDataController.GetConfig("atk_move")*((float) Math.Sqrt(sqrDist) - skill.range);
                }
                else
                {
                    score -= NTGBattleDataController.GetConfig("skill_move")*((float) Math.Sqrt(sqrDist) - skill.range);
                }
            }

            if (unit == lowPlayer)
                score += lowPlayerScore;
            else if (unit == lowBuilding)
                score += lowBuildingScore;
            else if (unit == lowMob)
                score += lowMobScore;

            if (score > topScore || (score == topScore && sqrDist < sqrTopDist))
            {
                target = unit;
                topScore = score;
                sqrTopDist = sqrDist;
            }
        }

        return target;
    }

    private int SkillShootRaw(int index, float xOffset = 0, float zOffset = 0)
    {
        if (!Shootable && !skills[index].OverideShootable())
        {
            return 0;
        }

        SetStatus(UnitStatus.Approach, false);

        if (mainController.targetMode == NTGBattleMainController.TargetMode.Smart)
        {
            targetUnit = SmartTarget(skills[index]);
        }
        else
        {
            if (targetUnit == null || !targetUnit.Lockable(group))
            {
                targetUnit = FindTarget(targetRange, type: TargetType.Player);
                if (targetUnit == null)
                    targetUnit = FindTarget(targetRange);
            }
        }

        if (skills[index] == null)
            return -1;

        if (skills[index].level == 0)
            return -1;

        if (skills[index].inCd > 0)
            return -1;

        if (skills[index].reqTarget == 1 && (targetUnit == null || (skills[index].mask & targetUnit.mask) == 0))
            return -1;

        if (skills[index].reqTarget == 3 && (targetUnit == null || (skills[index].mask & targetUnit.mask) == 0) && xOffset == 0 && zOffset == 0)
            return -1;

        float sqrTargetDist = 0;
        if (targetUnit != null)
            sqrTargetDist = (transform.position - targetUnit.transform.position).sqrMagnitude;

        if (skills[index].reqTarget == 3 && targetUnit != null && sqrTargetDist > skills[index].sqrRange && xOffset == 0 && zOffset == 0)
            return -1;

        if (skills[index].reqTarget == 1 && sqrTargetDist > skills[index].sqrRange)
            return -1;

        if (!skills[index].ShootCheck(targetUnit, xOffset, zOffset))
            return -1;

        if (skills[index].reqTarget == 2 && targetUnit != null && sqrTargetDist > skills[index].sqrRange)
        {
            Approach(skills[index]);
            return 1;
        }

        if (mp >= skills[index].mpCost)
        {
            mp -= skills[index].mpCost;

            if (targetUnit != null && skills[index].facingType == NTGBattleSkillFacingType.Target)
            {
                transform.LookAt(new Vector3(targetUnit.transform.position.x, transform.position.y, targetUnit.transform.position.z));
            }

            skills[index].Shoot(targetUnit, xOffset, zOffset);
            return 1;
        }

        return -1;
    }

    private Coroutine doSkillShootCoroutine;

    private IEnumerator doSkillShoot(int index, float xOffset, float zOffset)
    {
        var d = 1.0f;
        while (d > 0)
        {
            var r = SkillShootRaw(index, xOffset, zOffset);
            if (r == 1)
            {
                if (voiceController != null)
                    voiceController.SkillShoot(index);
            }
            if (r == -1 || r == 1)
                break;

            yield return null;
            d -= Time.deltaTime;
        }
        doSkillShootCoroutine = null;
    }

    public void SkillShoot(int index, float xOffset = 0, float zOffset = 0)
    {
        if (doSkillShootCoroutine != null)
        {
            StopCoroutine(doSkillShootCoroutine);
        }
        doSkillShootCoroutine = StartCoroutine(doSkillShoot(index, xOffset, zOffset));
    }

    public override void SkillShoot(int skillId, string targetId, float xOffset, float zOffset)
    {
        for (int i = 0; i < skills.Length; i++)
        {
            if (skills[i].id == skillId)
            {
                if (!Shootable)
                {
                    return;
                }

                targetUnit = mainController.FindUnit(targetId);

                if (targetUnit != null && skills[i].facingType == NTGBattleSkillFacingType.Target)
                {
                    transform.LookAt(new Vector3(targetUnit.transform.position.x, transform.position.y, targetUnit.transform.position.z));
                }

                if (mp >= skills[i].mpCost)
                {
                    mp -= skills[i].mpCost;

                    skills[i].Shoot(targetUnit, xOffset, zOffset);
                }

                break;
            }
        }

        //foreach (var equip in equips)
        //{
        //    if (equip != null)
        //        equip.SkillShoot(skillId, targetId);
        //}
    }

    private void Approach(NTGBattleSkillController skill)
    {
        if (_doApproach != null)
        {
            StopCoroutine(_doApproach);
        }
        SetStatus(UnitStatus.Approach, true);
        _doApproach = StartCoroutine(doApproach(skill));
    }

    private Coroutine _doApproach;

    private IEnumerator doApproach(NTGBattleSkillController skill)
    {
        while (alive && Moveable && GetStatus(UnitStatus.Approach) == true && targetUnit != null && targetUnit.Lockable(group) && (transform.position - targetUnit.transform.position).sqrMagnitude > skill.sqrRange)
        {
            //navAgent.acceleration = 1000.0f;
            manualRotation = false;
            navAgent.destination = targetUnit.transform.position;

            yield return new WaitForSeconds(0.1f);
        }

        if (alive && navAgent.enabled)
            navAgent.ResetPath();

        if (alive && Shootable && GetStatus(UnitStatus.Approach) == true && targetUnit != null && targetUnit.Lockable(group) && skill.ShootCheck(targetUnit))
        {
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

        SetStatus(UnitStatus.Approach, false);
    }

    public override void Hit(NTGBattleUnitController shooter, NTGBattleSkillBehaviour behav)
    {
        base.Hit(shooter, behav);

        var hitter = shooter as NTGBattlePlayerController;

        if (hitter != null && (behav.type == NTGBattleSkillType.Attack || behav.type == NTGBattleSkillType.HostileSkill || behav.type == NTGBattleSkillType.HostilePassive))
        {
            foreach (var unit in mainController.battleUnits)
            {
                var mc = unit as NTGBattleMobController;
                if (mc != null)
                {
                    mc.PlayerHit(this, hitter);
                }
            }
        }
    }


    public override void Respawn()
    {
        base.Respawn();

        var respawnPoint = mainController.respawn.Find("Start/Start-" + position);
        transform.position = respawnPoint.position;
        transform.rotation = respawnPoint.rotation;

        gameObject.SetActive(true);
        navAgent.enabled = true;

        unitAnimator.SetBool("dead", false);

        LoadBaseAttrs();

        mainController.uiController.HideUnitUI(this, true);

        var ai = gameObject.GetComponent<UTGBattlePlayerAIController>();
        if (ai != null)
        {
            ai.Respawn();
        }

        if (!isAI)
        {
            if (master)
            {
                StartCoroutine(doSyncMaster());
            }
            else
            {
                StartCoroutine(doSyncSlave());
            }
        }

        if (voiceController != null)
        {
            voiceController.Init(this);
            idleTime = 10.0f;
        }
    }

    public bool BuyEquip(string equipId, double price)
    {
        if (coin >= price && equips.Count < 6)
        {
            AddPassive("EquipChange", sp: new[] {"Add", equipId});
            coin -= (float) price;
            return true;
        }

        return false;
    }

    public void AddEquip(string equipId)
    {
        var equip = NTGBattleDataController.GetBattleMemberEquip(Convert.ToInt32(equipId));

        equips.Add(equip);

        AddAttrs(equip.Attrs);

        var skillList = new ArrayList();
        for (int i = 0; i < pSkills.Length; i++)
        {
            skillList.Add(pSkills[i]);
        }

        for (int i = 0; i < equip.Skills.Length; i++)
        {
            var skill = mainController.AddPlayerSkill(this, equip.Skills[i].Resource);
            skill.Init(equip.Skills[i], new float[0], new string[0]);
            (skill as NTGBattlePassiveSkillController).Respawn();
            skillList.Add(skill);
        }

        pSkills = new NTGBattlePassiveSkillController[skillList.Count];
        skillList.CopyTo(pSkills);
    }

    public bool SellEquip(string equipId, double price)
    {
        foreach (NTGBattleMemberEquip e in equips)
        {
            if (e.Id.ToString() == equipId)
            {
                AddPassive("EquipChange", sp: new[] {"Remove", equipId});
                coin += (float) price;
                return true;
            }
        }

        return false;
    }

    public void RemoveEquip(string equipId)
    {
        NTGBattleMemberEquip remove = null;
        foreach (NTGBattleMemberEquip e in equips)
        {
            if (e.Id.ToString() == equipId)
            {
                remove = e;
                break;
            }
        }

        if (remove != null)
        {
            var skillList = new ArrayList();
            for (int i = 0; i < pSkills.Length; i++)
            {
                skillList.Add(pSkills[i]);
            }

            for (int i = 0; i < remove.Skills.Length; i++)
            {
                for (int j = skillList.Count - 1; j >= 0; j--)
                {
                    var skill = (NTGBattlePassiveSkillController) skillList[j];
                    if (skill.id == remove.Skills[i].Id)
                    {
                        skill.Release();
                        skillList.RemoveAt(j);
                        Destroy(skill.gameObject);

                        break;
                    }
                }
            }
            pSkills = new NTGBattlePassiveSkillController[skillList.Count];
            skillList.CopyTo(pSkills);

            if (pSkills.Length > 1)
            {
                for (int i = 1; i < pSkills.Length; i++)
                {
                    pSkills[i].Respawn();
                }
            }

            MinusAttrs(remove.Attrs);

            equips.Remove(remove);
        }
    }
}