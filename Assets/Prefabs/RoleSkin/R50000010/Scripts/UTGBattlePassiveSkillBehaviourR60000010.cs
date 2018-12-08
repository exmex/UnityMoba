using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class UTGBattlePassiveSkillBehaviourR60000010 : NTGBattlePassiveSkillBehaviour {


    public List<NTGBattlePlayerController> alliedPlayers;//范围内的友方英雄
    public NTGBattlePlayerController buffPlayer;//范围内加了buff的友方英雄
    public NTGBattlePlayerController minHpPlayer;//范围内血量最少的友方英雄
    public NTGBattlePassiveSkillBehaviour pBehaviour;
    private Coroutine cor;
    public override void Respawn()
    {
        base.Respawn();

        collider.radius = this.range;
        collider.height = this.range * 2;
        collider.enabled = true;
        alliedPlayers = new List<NTGBattlePlayerController>();
        buffPlayer = null;
        minHpPlayer = null;
    }

    IEnumerator doPassive()
    {
        //Debugger.LogError("cor~~~~~~~~~");
        while (alliedPlayers.Count > 0)
        {
            if (buffPlayer != null && !buffPlayer.alive)
            {
                buffPlayer = null;
            }
            for (int i = alliedPlayers.Count-1; i >= 0; i--)
            {
                if (!alliedPlayers[i].alive)
                    alliedPlayers.Remove(alliedPlayers[i]);
            }
            if (alliedPlayers.Count == 0) break;

            minHpPlayer = alliedPlayers[0];
            foreach (var unit in alliedPlayers)
            {
                if (unit != minHpPlayer && unit.alive && unit.hp < minHpPlayer.hp)
                {
                    minHpPlayer = unit;
                }
            }
            if (minHpPlayer != buffPlayer)
            {
                AddBuff(owner);
                AddBuff(minHpPlayer);
                RemoveBuff(buffPlayer);
                buffPlayer = minHpPlayer;
            }
            yield return new WaitForSeconds(0.1f);
        }
        //Debugger.LogError("cor end ~~~~~~~~~~~");
        RemoveBuff(owner);
        RemoveBuff(buffPlayer);
        buffPlayer = null;
        minHpPlayer = null;
        cor = null;
    }

    private void AddBuff(NTGBattleUnitController unit)
    {
        if (unit == null) return;
        foreach (NTGBattlePassiveSkillBehaviour passive in unit.passives)
        {
            if (passive.name == pBehaviour.passiveName)
                break;
        }
        unit.AddPassive(pBehaviour.passiveName, owner);
    }

    private void RemoveBuff(NTGBattleUnitController unit)
    {
        if (unit == null) return;
        foreach (NTGBattlePassiveSkillBehaviour passive in unit.passives)
        {
            if (passive.name == pBehaviour.passiveName)
            {
                unit.RemovePassive(pBehaviour.passiveName, owner);
                break;
            }
        }
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {

        if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            RemoveBuff(owner);
            RemoveBuff(buffPlayer);
            Release();
        }
    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;
        var otherUnit = other.GetComponent<NTGBattlePlayerController>();
        if (otherUnit!=owner && otherUnit != null && otherUnit.alive && otherUnit.group == owner.group)
        {
            //Debugger.LogError("000"+otherUnit.name);
            if (!alliedPlayers.Contains(otherUnit))
                alliedPlayers.Add(otherUnit);
            if (alliedPlayers.Count > 0 && cor == null)
            {
                //Debugger.LogError(otherUnit.name);
                cor = StartCoroutine(doPassive());
            }
        }
    }

    public void OnTriggerExit(Collider other)
    {
        var otherUnit = other.GetComponent<NTGBattlePlayerController>();
        if (otherUnit != owner && otherUnit != null && otherUnit.alive && otherUnit.group == owner.group)
        {
            if (alliedPlayers.Contains(otherUnit))
                alliedPlayers.Remove(otherUnit);
                //Debugger.LogError("remove "+otherUnit.name);
        }
    }

}
