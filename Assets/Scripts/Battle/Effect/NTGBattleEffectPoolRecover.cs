using UnityEngine;
using System.Collections;

public class NTGBattleEffectPoolRecover : NTGBattlePassiveSkillBehaviour
{
    private void Awake()
    {
        base.Awake();

        passiveName = "PoolRecover";
    }

    public override void Respawn()
    {
        base.Respawn();

        StartCoroutine(doRecover());
        FXEB();
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        if (e == NTGBattlePassive.Event.PassiveRemove)
        {
            StopCoroutine(doRecover());
            FXReset();
            
            Release();
        }
    }

    private IEnumerator doRecover()
    {
        while (true)
        {
            if (owner.alive)
            {
                var hpp = owner.hp;
                owner.hp += owner.hpMax*0.2f;
                if (owner.hp > owner.hpMax)
                    owner.hp = owner.hpMax;
                hpp = owner.hp - hpp;
                if (hpp > 0.1)
                    owner.mainController.uiController.ShowUnitDamage(owner, hpp, EffectType.HpRecover, false, null, null);
                owner.mp += owner.mpMax*0.2f;
                if (owner.mp > owner.mpMax)
                    owner.mp = owner.mpMax;

                //var player = owner as NTGBattlePlayerController;
                //if (player != null)
                //{
                //    //var equipActiveCount = 0;
                //    //foreach (var equip in player.equips)
                //    //{
                //    //    if (equip != null && equip.active)
                //    //    {
                //    //        equipActiveCount++;
                //    //    }
                //    //}
                //    //var hpPercent = player.hp/player.hpMax;
                //    //if ((hpPercent > 0.65 && equipActiveCount < 6)
                //    //    || (hpPercent > 0.55 && equipActiveCount < 5)
                //    //    || (hpPercent > 0.45 && equipActiveCount < 4)
                //    //    || (hpPercent > 0.35 && equipActiveCount < 3)
                //    //    || (hpPercent > 0.25 && equipActiveCount < 2)
                //    //    || (hpPercent > 0.15 && equipActiveCount < 1))
                //    //{
                //    //    foreach (var equip in player.equips)
                //    //    {
                //    //        if (equip != null && !equip.active)
                //    //        {
                //    //            player.AddPassive("EquipRepair", null, new[] {equip.equip.Id.ToString()});
                //    //            break;
                //    //        }
                //    //    }
                //    //}

                //    //if (hpPercent > 0.15)
                //    //    player.RemovePassive("Broken");
                //}
            }

            yield return new WaitForSeconds(1.0f);
        }
    }
}