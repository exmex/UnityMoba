using UnityEngine;


public class NTGBattlePassive
{
    public enum Event
    {
        Respawn,
        Shoot,
        Hit,
        Engage,
        Disengage,
        Kill,
        Death,
        Assist,
        LevelUp,

        PassiveAdd,
        PassiveUpdate,
        PassiveRemove,
    }

    public class EventHitParam
    {
        public float damage;
        public NTGBattleUnitController target;
        public NTGBattleUnitController shooter;
        public NTGBattleSkillBehaviour behaviour;
        public bool critical;
    }

    public class EventShootParam
    {
        public NTGBattleUnitController target;
        public NTGBattleUnitController shooter;
        public NTGBattleSkillController controller;
    }

    public class EventKillParam
    {
        public NTGBattleUnitController victim;
    }

    public class EventDeathParam
    {
        public NTGBattleUnitController killer;
    }

    public class EventAssistParam
    {
        public NTGBattleUnitController victim;
    }

    public class EventLevelUpParam
    {

    }

    public enum Filter
    {
        Hit,
    }
}

public class NTGBattlePassiveSkillController : NTGBattleSkillController
{
    public virtual void Notify(NTGBattlePassive.Event e, object param)
    {
    }

    public virtual void Respawn()
    {
    }

    public virtual void Release()
    {
    }
}