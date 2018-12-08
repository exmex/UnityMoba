using UnityEngine;
using System.Collections;

public class NTGBattleEffectTeleport : NTGBattlePassiveSkillBehaviour
{
    private void Awake()
    {
        base.Awake();

        passiveName = "Teleport";
    }

    public override void Respawn()
    {
        base.Respawn();

        if (owner.navAgent != null)
            owner.navAgent.enabled = false;

        owner.transform.position = new Vector3(p[0], p[1], p[2]);

        if (owner.navAgent != null)
            owner.navAgent.enabled = true;

        Release();
    }
}