using UnityEngine;
using System.Collections;

public class NTGBattleEffectLevelUp : NTGBattlePassiveSkillBehaviour
{

    public float pDuration;
    private void Awake()
    {
        base.Awake();

        passiveName = "LevelUp";
    }

    public override void Respawn()
    {
        base.Respawn();

        owner.LevelUp((int)p[0]);

        if (owner is NTGBattlePlayerController)
        {
            if (owner.alive)
                FXEB();
            pDuration = 2.0f;
            StartCoroutine(doDuration());
        }
        else
        {
            Release();
        }
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if(e == NTGBattlePassive.Event.PassiveAdd)
        {
            owner.LevelUp((int)p[0]);

            if (owner is NTGBattlePlayerController)
            {
                if (owner.alive)
                    FXEB();
                pDuration = 2.0f;
            }
            else
            {
                Release();
            }
        }
    }

    private IEnumerator doDuration()
    {
        while(pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }

        Release();
    }
}