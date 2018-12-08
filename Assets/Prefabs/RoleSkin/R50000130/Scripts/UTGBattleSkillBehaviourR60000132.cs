using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

public class UTGBattleSkillBehaviourR60000132 : NTGBattleSkillBehaviour 
{

    float skillRadius,damageInterval,quantityOnce;
    List<NTGBattleMobCommonController> mobUnits = new List<NTGBattleMobCommonController>();
    List<NTGBattlePlayerController> playerUnits = new List<NTGBattlePlayerController>();
    List<int> mobUnitsIndex = new List<int>();
    List<int> playerUnitsIndex = new List<int>();
    List<NTGBattleUnitController> targetsInRange = new List<NTGBattleUnitController>();//

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {

        skillRadius = param[0];     //圆形半径
        damageInterval = param[1];  //伤害CD
        quantityOnce = param[2];    //单次攻击目标数量

        collider.radius = skillRadius;//
        collider.height = 7.4f; //高低差

        base.Shoot(lockedTarget, xOffset, zOffset);

        startPos = owner.transform.position;

        StartCoroutine(doFly());
        StartCoroutine(doDamage());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        float Timer = 0f;
        while (owner != null && Timer < duration)
        {
            Timer += Time.deltaTime;
            transform.Translate(0, 0, speed * Time.deltaTime); 
            ea.transform.position = transform.position;
            yield return null;
        }
        FXHit(null);

        Release();
    }

    private IEnumerator doDamage()
    {   
        while (true)
        {   
            mobUnits.Clear();
            playerUnits.Clear();
            targetsInRange.Clear();

            collider.enabled = true;//
            yield return new WaitForSeconds(0.1f);//
            collider.enabled = false;//

            //Collider[] cols = Physics.OverlapSphere(transform.position, skillRadius);//maskTarget
            //foreach (Collider col in cols)
            foreach (NTGBattleUnitController otherUnit in targetsInRange)// 
            {
                //var otherUnit = col.GetComponent<NTGBattleUnitController>();
                var mobUnit = otherUnit as NTGBattleMobCommonController;
                if (mobUnit != null)  //if (otherUnit.GetType() == typeof(NTGBattleMobCommonController))
                {
                    if (mobUnit.group != owner.group && mobUnit.alive)
                    { mobUnits.Add(mobUnit); }
                }
                else
                {
                    var playerUnit = otherUnit as NTGBattlePlayerController;
                    if (playerUnit != null)
                    {
                        if (playerUnit.group != owner.group && playerUnit.alive)
                        { playerUnits.Add(playerUnit); }
                    }
                }
            }
            
            
            int needAmount = (int)quantityOnce;
            int deltaAmount=needAmount-playerUnits.Count;
            if (needAmount > 0)
            {
                if (deltaAmount >= 0) //攻击全部Hero && 继续攻击其他类型
                {
                    foreach (var targetUnit in playerUnits) //造成伤害
                    {
                        Damage(targetUnit);
                    }
                }
                else //攻击部分Hero && Return
                {
                    playerUnitsIndex.Clear();
                    for (var i = 0; playerUnitsIndex.Count < needAmount; i++) //每次最多被攻击目标数量 对应的序号
                    {
                        var r = new System.Random(Guid.NewGuid().GetHashCode());
                        int n = r.Next(0, playerUnits.Count);
                        if (!playerUnitsIndex.Contains(n))
                        {
                            playerUnitsIndex.Add(n);
                        }
                        else
                        {
                            #region else不是必要的，加的这个种子随机到相同数字的可能性比较低
                            while (true)
                            {
                                if (n != needAmount - 1)
                                {
                                    if (!playerUnitsIndex.Contains(++n)) { playerUnitsIndex.Add(n); break; }
                                }
                                else
                                {
                                    n = 0;
                                    if (!playerUnitsIndex.Contains(++n)) { playerUnitsIndex.Add(n); break; }
                                }
                            }
                            #endregion
                        }
                    }
                    foreach (int i in playerUnitsIndex) //造成伤害
                    {
                        var targetUnit = playerUnits[i];
                        Damage(targetUnit);
                    }
                    //break;
                }
            }

            needAmount = deltaAmount;
            deltaAmount = needAmount - mobUnits.Count;
            if (needAmount > 0)
            {
                if (deltaAmount >= 0) //攻击全部Mob && 继续攻击其他类型
                {
                    foreach (var targetUnit in mobUnits) //造成伤害
                    {
                        Damage(targetUnit);
                    }
                }
                else //攻击部分Mob && Return
                {
                    mobUnitsIndex.Clear(); //Debug.LogError("_____________________________");  Debug.LogError("Mob数量"+mobUnits.Count);
                    for (var i = 0; mobUnitsIndex.Count < needAmount; i++) //每次最多被攻击目标数量 对应的序号
                    {
                        var r = new System.Random(Guid.NewGuid().GetHashCode());
                        int n = r.Next(0, mobUnits.Count); //Debug.LogError("Mob随机值" + n);
                        if (!mobUnitsIndex.Contains(n))
                        {
                            mobUnitsIndex.Add(n);
                        }
                        else
                        {
                            #region else不是必要的，加的这个种子随机到相同数字的可能性比较低
                            while (true)
                            {
                                if (n != needAmount - 1)
                                {
                                    if (!mobUnitsIndex.Contains(++n)) { mobUnitsIndex.Add(n); break; }
                                }
                                else
                                {
                                    n = 0;
                                    if (!mobUnitsIndex.Contains(++n)) { mobUnitsIndex.Add(n); break; }
                                }
                            }
                            #endregion
                        }
                    }
                    foreach (int i in mobUnitsIndex) //造成伤害
                    {
                        var targetUnit = mobUnits[i];
                        Damage(targetUnit);
                    }
                    //break;
                }
            }
            //没有可以继续攻击的类型

            yield return new WaitForSeconds(damageInterval - 0.1f);//
            //yield return new WaitForSeconds(damageInterval);

        }

    }

    private void Damage(NTGBattleUnitController otherUnit)
    {
        if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            otherUnit.Hit(shooter, this);
            FXHit(otherUnit);
        }
    }

    public void OnTriggerEnter(Collider other)//
    {
        if (owner == null)
            return;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            targetsInRange.Add(otherUnit);
        }
    }

}
