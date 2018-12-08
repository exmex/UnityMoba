using UnityEngine;
using System.Collections;

public class NTGBattleMobController : NTGBattleUnitController
{
    public NTGBattleUnitController targetUnit;

    public int type; //1小兵 2野怪 3建筑 4召唤生物 5血包
    public float giveExp;
    public float giveCoin;

    public NTGBattleGroupInfo groupInfo;
    public NTGBattleCreatureInfo creatureInfo;

    public virtual void Init(float[] p)
    {
        //Debug.LogError("Mob Init Function Not Implemented!");
    }

    public virtual void PlayerHit(NTGBattlePlayerController player, NTGBattlePlayerController shooter)
    {
    }

    public override void Respawn()
    {
        base.Respawn();

        if (creatureInfo.GrowType == 0)
        {
            LevelUpCheck();
        }
        else if (creatureInfo.GrowType == 1)
        {
            StartCoroutine(doLevelUpCheck());
        }
    }

    private IEnumerator doLevelUpCheck()
    {
        while (alive)
        {
            LevelUpCheck();

            yield return new WaitForSeconds(1.0f);
        }
    }

    private void LevelUpCheck()
    {
        int levels = 0;
        for (int i = level - 1; i < creatureInfo.GrowTimings.Length; i++)
        {
            if (Time.time - mainController.battleStartTime < creatureInfo.GrowTimings[i])
            {
                break;
            }

            levels++;
        }

        if (levels > 0)
        {
            AddPassive("LevelUp", p: new float[] {levels});
        }
    }

    public override void LevelUp(int levels)
    {
        for (int l = levels; l > 0; l--)
        {
            if (level - 1 < creatureInfo.GrowTimings.Length)
            {
                var ohp = hp;
                var omp = mp;
                var ohpMax = hpMax;
                var ompMax = mpMax;

                AddAttrs(creatureInfo.GrowAttrs);
                giveExp += creatureInfo.GrowGiveExp;
                giveCoin += creatureInfo.GrowGiveCoin;

                hp = ohp + (hpMax - ohpMax);
                mp = omp + (mpMax - ompMax);

                level++;
            }
        }
    }

    public override void Kill(NTGBattleUnitController killer)
    {
        base.Kill(killer);

        groupInfo.UnitKilled();

        ArrayList players = new ArrayList();
        foreach (NTGBattleUnitController player in mainController.battleUnits)
        {
            if (player is NTGBattlePlayerController && player.group != group && player.group == killer.group && (transform.position - player.transform.position).sqrMagnitude < rewardRange*rewardRange)
            {
                players.Add(player);
            }
        }

        var giveexp = giveExp/players.Count;
        foreach (NTGBattlePlayerController player in players)
        {
            player.AddExp(giveexp);
            if (player == killer)
            {
                player.AddCoin(giveCoin);
                mainController.uiController.ShowUnitCoin(this, player, giveCoin);

                if (player == mainController.uiController.localPlayerController)
                {
                    PlayFXOnce(UnitFX.Coin);
                }
            }
            else
            {
                var givecoin = giveCoin*mainController.configYMob;
                player.AddCoin(givecoin);
                mainController.uiController.ShowUnitCoin(this, player, givecoin);
            }
        }

        StopCoroutine(doLevelUpCheck());
    }

    public Vector3 MovingDestination;
    public bool stopMovement;

    public void MoveTo(Vector3 dest)
    {
        RawMoveTo(dest);
        stopMovement = false;
    }

    public void StopMovement()
    {
        if (!stopMovement)
        {
            RawMoveTo(transform.position);
            stopMovement = true;
        }
    }

    private void RawMoveTo(Vector3 dest)
    {
        if (alive)
        {
            if (navAgent != null)
            {
                if (navAgent.SetDestination(dest))
                {
                    if (dest != MovingDestination)
                    {
                        SyncDest(dest);
                    }

                    MovingDestination = dest;
                }
            }
            else
            {
                if (UnitMove(dest))
                {
                    if (dest != MovingDestination)
                    {
                        SyncDest(dest);
                    }

                    MovingDestination = dest;
                }
            }
        }
    }
}