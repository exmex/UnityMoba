using UnityEngine;
using System.Collections;


public class NTGBattlePassiveSkillBehaviour : NTGBattleSkillBehaviour
{
    public string passiveName;

    protected void Awake()
    {
        base.Awake();

        passiveName = gameObject.name;
    }

    public virtual void Respawn()
    {
    }


    public virtual void Notify(NTGBattlePassive.Event e, object param)
    {
    }

    public virtual float Filter(NTGBattlePassive.Filter f, object param, float value)
    {
        return value;
    }
}