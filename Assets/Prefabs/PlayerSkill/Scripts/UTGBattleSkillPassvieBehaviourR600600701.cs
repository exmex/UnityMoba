using UnityEngine;
using System.Collections;

public class UTGBattleSkillPassvieBehaviourR600600701 : NTGBattlePassiveSkillBehaviour {

    public float pDuration;

    public override void Respawn()
    {
        base.Respawn();

        pDuration = this.duration;

        StartCoroutine(doStun()); 
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            if (p.duration > pDuration)
            {
				owner.RemovePassive ("Stun");
				owner.AddPassive("Stun", owner, p: new[] { p.duration });
            }
            else
            {
                return;
            }
        }
        else if (e == NTGBattlePassive.Event.PassiveRemove)
        {
			owner.RemovePassive ("Stun");
        }
    }

    private IEnumerator doStun()
    {
        FXEA();
        FXEB();

        var d = duration;
        owner.AddPassive("Stun", owner, p: new[] { d });
        FXHit(owner, head: true);
        
        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }

        Release();
    }

}
