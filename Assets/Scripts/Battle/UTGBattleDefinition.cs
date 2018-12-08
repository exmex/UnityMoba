using UnityEngine;

public class NTGBattleSceneInfo
{
    public float[] Salary;
    public float[] SalaryCycle;
    public float[] SalaryTiming;

    public float[] ExpSalary;
    public float[] ExpSalaryCycle;
    public float[] ExpSalaryTiming;

    public float FirstBloodCoin;
    public float FirstBloodExp;

    public int LevelUpType;

    public NTGBattleMemberSkill[] Skills;
}

public class NTGBattleUnitInfo
{
    public string Id;
    public int Position;
    public int Group;

    public NTGBattleMemberInfo Info;
    public NTGBattleMemberAttrs Attrs;
    public NTGBattleMemberSkill[] Skills;
    public NTGBattleMemberEquip[] Equips;

    public NTGBattleCreatureInfo CInfo;
}

public class NTGBattleGroupInfo
{
    public int Id;
    public int Category;
    public int Position;
    public string Resource;
    public int Trigger;
    public float[] Params;

    public bool preLoaded;
    public bool remove;

    //Category 1 Params
    public float respawnTime;
    public int respawnCount;

    //Category 2 Params
    public float wipeTime;
    public float deathCount;

    public NTGBattleUnitInfo[] Units;

    public void UnitKilled()
    {
        deathCount++;
        if (deathCount == Units.Length)
        {
            wipeTime = Time.time;
        }
    }
}

public class NTGBattleMemberAttrs
{
    public float Hp;
    public float Mp;

    public float HpRecover;
    public float MpRecover;

    public float PAtk;
    public float MAtk;
    public float PDef;
    public float MDef;

    public float pAtkRate;
    public float mAtkRate;

    public float PPenetrate;
    public float MPenetrate;
    public float PPenetrateRate;
    public float MPenetrateRate;

    public float Crit;
    public float CritEffect;

    public float PHpSteal;
    public float MHpSteal;

    public float Tough;
    public float AtkSpeed;
    public float CdReduce;
    public float MoveSpeed;
}

public class NTGBattleMemberInfo
{
    public string Name;
    public int Level;
    public string Icon;
    public int RoleId;
    public float TargetRange;
    public float RewardRange;

    public string SkinResource;

    public int[] RandMap;
    public bool IsAI;
    public bool IsRobot;
    public float[] AiParams;
}

public class NTGBattleMemberSkillBehaviour
{
    public int Id;
    public float[] Param;

    public float Range;
    public float Speed;
    public float Duration;
    public float Pretime;
    public float Stiff;

    public float BaseValue;
    public float PAdd;
    public float MAdd;
    public float HPAdd;
    public float MPAdd;

    public int EffectType;

    public int Mask;
    public string Shock;
}

public class NTGBattleMemberSkill
{
    public int Id;
    public int Level;
    public int LevelCap;
    public int ReqLevel;
    public int ReqTarget;

    public float Cd;
    public float Range;
    public float MpCost;

    public string Icon;
    public string Name;

    public string Resource;
    public float[] Param;

    public int NextLevel;
    public int Mask;

    public int HintType;
    public float HintSize;

    public NTGBattleMemberSkillBehaviour[] Behaviours;
}

public class NTGBattleMemberEquip
{
    public int Id;
    public string Name;
    public string Icon;

    public NTGBattleMemberAttrs Attrs;
    public NTGBattleMemberSkill[] Skills;
}

public class NTGBattleCreatureInfo
{
    public int Type;
    public string Resource;

    public float GiveExp;
    public float GiveCoin;

    public NTGBattleMemberAttrs GrowAttrs;
    public float GrowGiveExp;
    public float GrowGiveCoin;
    public int GrowType;
    public float[] GrowTimings;

    public int Mask;

    public int RespawnPoint;
    public int RespawnCondition;
    public int[] RespawnLane;

    public float[] AiParams;
    public float[][] SkillAiParams;
}

public class UTGBattleReport
{
    public UTGBattlePlayerReport[] TeamA;
    public UTGBattlePlayerReport[] TeamB;
    public int TAScore;
    public int TBScore;
}

public class UTGBattlePlayerReport
{
    public bool IsAi;
    public int RoleId;
    public int PlayerId;
    public string PlayerName;
    public int Level;
    public bool IsLegendary;
    public int TLStreakKill;
    public int RoleKill;
    public float RoleDamage;
    public float MobDamage;
    public float NeutDamage;
    public float BuildingDamage;
    public int PushTower;
    public int Assistance;
    public float SufferDamage;
    public int Death;
    public int Coin;
    public bool IsEscape;
    public int[] BattleEquips;
}

public class UTGBattleRespawnRequest
{
    public int GId;
    public string CId;
    public float D;

    public string P;
    public string O;
}

public class UTGBattleResapwnResponse
{
    public int GId;
    public string CId;
    public string Id;
    public float D;

    public string P;
    public string O;
}