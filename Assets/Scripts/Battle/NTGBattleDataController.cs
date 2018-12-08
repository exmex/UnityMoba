using System;
using System.Collections.Generic;
using LuaInterface;

public class NTGBattleDataController
{
    private static LuaTable data = null;

    public static void LoadData()
    {
        if (NTGApplicationController.Instance != null && NTGApplicationController.Instance.Initialized)
        {
            var result = NTGApplicationController.Instance.LuaCall("UTGData", "Instance");
            if (result != null && result.Length > 0)
            {
                data = (LuaTable) result[0];
            }
        }
    }

    private static int cachePlayerId = 0;

    public static int GetLocalPlayerId()
    {
        if (data == null)
            return 0;

        if (cachePlayerId == 0)
            cachePlayerId = Convert.ToInt32(((LuaTable) data["PlayerData"])["Id"]);

        return cachePlayerId;
    }

    public static int GetLocalPlayerBattlePosition()
    {
        return Convert.ToInt32(data["BattlePosition"]);
    }

    public static int GetLocalPlayerBattleGroup()
    {
        return Convert.ToInt32(data["BattleGroup"]);
    }

    private static Dictionary<string, float> cacheConfig = new Dictionary<string, float>();

    public static float GetConfig(string name)
    {
        if (!cacheConfig.ContainsKey(name))
            cacheConfig[name] = Convert.ToSingle(((LuaTable) ((LuaTable) data["ConfigData"])[name])["Float"]);

        return cacheConfig[name];
    }

    private static NTGBattleMemberAttrs ConvertToMemberAttrs(LuaTable attrs)
    {
        var memberAttrs = new NTGBattleMemberAttrs();

        memberAttrs.Hp = Convert.ToSingle(attrs["HP"]);
        memberAttrs.Mp = Convert.ToSingle(attrs["MP"]);

        memberAttrs.HpRecover = Convert.ToSingle(attrs["HpRecover5s"]);
        memberAttrs.MpRecover = Convert.ToSingle(attrs["MpRecover5s"]);

        memberAttrs.PAtk = Convert.ToSingle(attrs["PAtk"]);
        memberAttrs.MAtk = Convert.ToSingle(attrs["MAtk"]);
        memberAttrs.PDef = Convert.ToSingle(attrs["PDef"]);
        memberAttrs.MDef = Convert.ToSingle(attrs["MDef"]);

        memberAttrs.PPenetrate = Convert.ToSingle(attrs["PPenetrateValue"]);
        memberAttrs.MPenetrate = Convert.ToSingle(attrs["MPenetrateValue"]);
        memberAttrs.PPenetrateRate = Convert.ToSingle(attrs["PPenetrateRate"]);
        memberAttrs.MPenetrateRate = Convert.ToSingle(attrs["MPenetrateRate"]);


        memberAttrs.Crit = Convert.ToSingle(attrs["CritRate"]);
        memberAttrs.CritEffect = Convert.ToSingle(attrs["CritEffect"]);

        memberAttrs.PHpSteal = Convert.ToSingle(attrs["PHpSteal"]);
        memberAttrs.MHpSteal = Convert.ToSingle(attrs["MHpSteal"]);

        memberAttrs.Tough = Convert.ToSingle(attrs["Tough"]);
        memberAttrs.AtkSpeed = Convert.ToSingle(attrs["AtkSpeed"]);
        memberAttrs.CdReduce = Convert.ToSingle(attrs["CdReduce"]);
        memberAttrs.MoveSpeed = Convert.ToSingle(attrs["MoveSpeed"]);

        return memberAttrs;
    }

    private static Dictionary<int, NTGBattleMemberSkill> cacheMemberSkills = new Dictionary<int, NTGBattleMemberSkill>();

    public static NTGBattleMemberSkill GetBattleMemberSkill(int skillId)
    {
        if (!cacheMemberSkills.ContainsKey(skillId))
        {
            var newSkillLua = (LuaTable) ((LuaTable) data["SkillsData"])[skillId.ToString()];
            var memberSkillLua = new NTGBattleMemberSkill();

            memberSkillLua.Id = Convert.ToInt32(newSkillLua["Id"]);
            memberSkillLua.Level = Convert.ToInt32(newSkillLua["Level"]);
            memberSkillLua.LevelCap = Convert.ToInt32(newSkillLua["LevelCap"]);
            memberSkillLua.ReqLevel = Convert.ToInt32(newSkillLua["RequireLevel"]);
            memberSkillLua.ReqTarget = Convert.ToInt32(newSkillLua["TargetType"]);

            memberSkillLua.Cd = Convert.ToSingle(newSkillLua["Cd"]);
            memberSkillLua.Range = Convert.ToSingle(newSkillLua["Range"]);
            memberSkillLua.MpCost = Convert.ToSingle(newSkillLua["MpCost"]);
            memberSkillLua.Icon = Convert.ToString(newSkillLua["Icon"]);
            memberSkillLua.Name = Convert.ToString(newSkillLua["Name"]);

            memberSkillLua.Resource = Convert.ToString(newSkillLua["Resource"]);
            {
                var Param = (LuaTable) newSkillLua["Param"];                
                var param = Param.ToArray();
                memberSkillLua.Param = new float[param.Length];                
                for (int i = 0; i < param.Length; i++)
                {
                    memberSkillLua.Param[i] = Convert.ToSingle(param[i]);
                }
            }

            memberSkillLua.NextLevel = Convert.ToInt32(newSkillLua["NextLevel"]);
            memberSkillLua.Mask = Convert.ToInt32(newSkillLua["Mask"]);

            memberSkillLua.HintType = Convert.ToInt32(newSkillLua["HintType"]);
            memberSkillLua.HintSize = Convert.ToSingle(newSkillLua["HintSize"]);

            {
                var SkillBehaviours = (LuaTable) newSkillLua["SkillBehaviours"];
                var skillBehaviours = SkillBehaviours.ToArray();
                memberSkillLua.Behaviours = new NTGBattleMemberSkillBehaviour[skillBehaviours.Length];
                for (int i = 0; i < skillBehaviours.Length; i++)
                {
                    memberSkillLua.Behaviours[i] = GetBattleMemberSkillBehaviour(Convert.ToInt32(skillBehaviours[i]));
                }
            }

            cacheMemberSkills[skillId] = memberSkillLua;
        }

        return cacheMemberSkills[skillId];
    }

    public static NTGBattleMemberSkillBehaviour GetBattleMemberSkillBehaviour(int behaviourId)
    {
        var newBehavLua = (LuaTable) ((LuaTable) data["SkillBehavioursData"])[behaviourId.ToString()];
        var memberSkillBehaviourLua = new NTGBattleMemberSkillBehaviour();

        memberSkillBehaviourLua.Id = Convert.ToInt32(newBehavLua["Id"]);

        {
            var Param = (LuaTable) newBehavLua["Param"];
            var param = Param.ToArray();
            memberSkillBehaviourLua.Param = new float[param.Length];
            for (int i = 0; i < param.Length; i++)
            {
                memberSkillBehaviourLua.Param[i] = Convert.ToSingle(param[i]);
            }
        }

        memberSkillBehaviourLua.Range = Convert.ToSingle(newBehavLua["Range"]);
        memberSkillBehaviourLua.Speed = Convert.ToSingle(newBehavLua["Speed"]);
        memberSkillBehaviourLua.Duration = Convert.ToSingle(newBehavLua["Duration"]);
        memberSkillBehaviourLua.Pretime = Convert.ToSingle(newBehavLua["PreTime"]);
        memberSkillBehaviourLua.Stiff = Convert.ToSingle(newBehavLua["Stiff"]);

        memberSkillBehaviourLua.BaseValue = Convert.ToSingle(newBehavLua["BaseValue"]);
        memberSkillBehaviourLua.PAdd = Convert.ToSingle(newBehavLua["PAtkAdd"]);
        memberSkillBehaviourLua.MAdd = Convert.ToSingle(newBehavLua["MAtkAdd"]);
        memberSkillBehaviourLua.HPAdd = Convert.ToSingle(newBehavLua["HpAdd"]);
        memberSkillBehaviourLua.MPAdd = Convert.ToSingle(newBehavLua["MpAdd"]);

        memberSkillBehaviourLua.EffectType = Convert.ToInt32(newBehavLua["DamageType"]);

        memberSkillBehaviourLua.Mask = Convert.ToInt32(newBehavLua["Mask"]);
        memberSkillBehaviourLua.Shock = Convert.ToString(newBehavLua["Shock"]);

        return memberSkillBehaviourLua;
    }

    private static Dictionary<int, NTGBattleMemberEquip> cacheMemberEquips = new Dictionary<int, NTGBattleMemberEquip>();

    public static NTGBattleMemberEquip GetBattleMemberEquip(int equipId)
    {
        if (!cacheMemberEquips.ContainsKey(equipId))
        {
            var newEquipLua = (LuaTable) ((LuaTable) data["EquipsData"])[equipId.ToString()];
            var equipLua = new NTGBattleMemberEquip();

            equipLua.Id = Convert.ToInt32(newEquipLua["Id"]);
            equipLua.Name = Convert.ToString(newEquipLua["Name"]);
            equipLua.Icon = Convert.ToString(newEquipLua["Icon"]);

            equipLua.Attrs = ConvertToMemberAttrs((LuaTable) newEquipLua["Attr"]);
            {
                var PassiveSkills = (LuaTable) newEquipLua["PassiveSkills"];
                var passiveSkills = PassiveSkills.ToArray();
                equipLua.Skills = new NTGBattleMemberSkill[passiveSkills.Length];
                for (int i = 0 ; i < passiveSkills.Length; i++)
                {
                    equipLua.Skills[i] = GetBattleMemberSkill(Convert.ToInt32(passiveSkills[i]));
                }
            }

            cacheMemberEquips[equipId] = equipLua;
        }

        return cacheMemberEquips[equipId];
    }

    public static int LevelUpType;

    private static Dictionary<int, bool> cacheCanPlayerLevelUp = new Dictionary<int, bool>();

    public static bool CanPlayerLevelUp(int level)
    {
        if (!cacheCanPlayerLevelUp.ContainsKey(level + 1))
        {
            cacheCanPlayerLevelUp[level + 1] = ((LuaTable) (((LuaTable) data["PVPLevelUpsData"])[LevelUpType.ToString()]))[(level + 1).ToString()] != null;
        }
        return cacheCanPlayerLevelUp[level + 1];
    }


    private static Dictionary<int, float> cacheGetPlayerExpCap = new Dictionary<int, float>();

    public static float GetPlayerExpCap(int level)
    {
        if (!cacheGetPlayerExpCap.ContainsKey(level))
        {
            if (((LuaTable) (((LuaTable) data["PVPLevelUpsData"])[LevelUpType.ToString()]))[(level+1).ToString()] != null)
            {
                cacheGetPlayerExpCap[level] = Convert.ToSingle(((LuaTable) ((LuaTable) (((LuaTable) data["PVPLevelUpsData"])[LevelUpType.ToString()]))[level.ToString()])["ExpNeed"]);
            }
            else
            {
                cacheGetPlayerExpCap[level] = float.MaxValue;
            }
        }

        return cacheGetPlayerExpCap[level];
    }

    private static Dictionary<int, float> cacheGetPlayerGiveExp = new Dictionary<int, float>();

    public static float GetPlayerGiveExp(int level)
    {
        if (!cacheGetPlayerGiveExp.ContainsKey(level))
        {
            cacheGetPlayerGiveExp[level] = Convert.ToSingle(((LuaTable) ((LuaTable) (((LuaTable) data["PVPLevelUpsData"])[LevelUpType.ToString()]))[level.ToString()])["GiveExp"]);
        }

        return cacheGetPlayerGiveExp[level];
    }

    private static Dictionary<int, float> cacheGetPlayerReviveDuration = new Dictionary<int, float>();

    public static float GetPlayerReviveDuration(int level)
    {
        if (!cacheGetPlayerReviveDuration.ContainsKey(level))
        {
            cacheGetPlayerReviveDuration[level] = Convert.ToSingle(((LuaTable) ((LuaTable) (((LuaTable) data["PVPLevelUpsData"])[LevelUpType.ToString()]))[level.ToString()])["Reborn"]);
        }

        return cacheGetPlayerReviveDuration[level];
    }

    public static void GrowPlayerMemberAttrs(ref NTGBattleMemberAttrs attrs, int roleId)
    {
        var grow = (LuaTable) ((LuaTable) data["PVPRoleGrowsData"])[roleId.ToString()];

        attrs.Hp += Convert.ToSingle(grow["HP"]);
        attrs.Mp += Convert.ToSingle(grow["MP"]);

        attrs.HpRecover += Convert.ToSingle(grow["HpRecover5s"]);
        attrs.MpRecover += Convert.ToSingle(grow["MpRecover5s"]);

        attrs.PAtk += Convert.ToSingle(grow["PAtk"]);
        attrs.MAtk += Convert.ToSingle(grow["MAtk"]);
        attrs.PDef += Convert.ToSingle(grow["PDef"]);
        attrs.MDef += Convert.ToSingle(grow["MDef"]);

        attrs.PPenetrate += Convert.ToSingle(grow["PpenetrateValue"]);
        attrs.MPenetrate += Convert.ToSingle(grow["MpenetrateValue"]);
        attrs.PPenetrateRate += Convert.ToSingle(grow["PpenetrateRate"]);
        attrs.MPenetrateRate += Convert.ToSingle(grow["MpenetrateRate"]);

        attrs.Crit += Convert.ToSingle(grow["CritRate"]);
        attrs.CritEffect += Convert.ToSingle(grow["CritEffect"]);

        attrs.PHpSteal += Convert.ToSingle(grow["PHpSteal"]);
        attrs.MHpSteal += Convert.ToSingle(grow["MHpSteal"]);

        attrs.Tough += Convert.ToSingle(grow["Tough"]);
        attrs.AtkSpeed += Convert.ToSingle(grow["AtkSpeed"]);
        attrs.CdReduce += Convert.ToSingle(grow["CdReduce"]);
        attrs.MoveSpeed += Convert.ToSingle(grow["MoveSpeed"]);

        return;
    }

    private static Dictionary<int, float> cacheGetPlayerGiveCoin = new Dictionary<int, float>();

    public static float GetPlayerGiveCoin(int grade)
    {
        if (!cacheGetPlayerGiveCoin.ContainsKey(grade))
        {
            var v = ((LuaTable) (((LuaTable) data["PVPKillStreaksData"])[grade.ToString()]))["GiveCoin"];
            cacheGetPlayerGiveCoin[grade] = Convert.ToSingle(v);
        }

        return cacheGetPlayerGiveCoin[grade];
    }

    private static Dictionary<int, int> cacheGetSkillRequireLevel = new Dictionary<int, int>();

    public static int GetSkillRequireLevel(int skillId)
    {
        if (!cacheGetSkillRequireLevel.ContainsKey(skillId))
        {
            cacheGetSkillRequireLevel[skillId] = Convert.ToInt32(((LuaTable) ((LuaTable) data["SkillsData"])[skillId.ToString()])["RequireLevel"]);
        }

        return cacheGetSkillRequireLevel[skillId];
    }

    private static Dictionary<int, string> cacheGetSkillDesc = new Dictionary<int, string>();

    public static string GetSkillDesc(int skillId)
    {
        if (!cacheGetSkillDesc.ContainsKey(skillId))
        {
            cacheGetSkillDesc[skillId] = Convert.ToString(((LuaTable) ((LuaTable) data["SkillsData"])[skillId.ToString()])["Desc"]);
        }

        return cacheGetSkillDesc[skillId];
    }

    private static Dictionary<int, int> cacheGetRoleAtkType = new Dictionary<int, int>();

    public static int GetRoleAtkType(int roleId)
    {
        if (!cacheGetRoleAtkType.ContainsKey(roleId))
        {
            cacheGetRoleAtkType[roleId] = Convert.ToInt32(((LuaTable)((LuaTable)data["RolesData"])[roleId.ToString()])["AtkType"]);
        }

        return cacheGetRoleAtkType[roleId];
    }
}