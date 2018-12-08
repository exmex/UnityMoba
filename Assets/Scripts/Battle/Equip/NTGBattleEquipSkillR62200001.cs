using UnityEngine;
using System.Collections;

public class NTGBattleEquipSkillR62200001 : NTGBattleEquipSkillController
{
    //public float cd;
    //public float rate;

    //public bool inCd;
    //public float lastUseTime;

    //// Use this for initialization
    //private void Start()
    //{
    //    base.Start();
    //}

    //public override void Init(NTGBattleEquipController equipController, NTGBattleSkillController skillController, float[] p)
    //{
    //    base.Init(equipController, skillController, p);

    //    //cd = p[0];
    //    //rate = p[1];

    //    cd = 0;
    //    rate = 10000;
    //}

    //public override void Respawn()
    //{
    //    base.Respawn();

    //    var master = equipController.owner.GetComponent<NTGBattleUnitSyncMaster>();
    //    if (master != null)
    //    {
    //        StartCoroutine(doShoot());
    //    }
    //}

    //private IEnumerator doShoot()
    //{
    //    while (equipController.owner.alive && equipController.active)
    //    {
    //        if (!inCd && equipController.targetUnit != null && equipController.targetUnit.alive && !skillController.inCd
    //            && equipController.targetAngle < 0.5f && (skillController.mask & equipController.targetUnit.mask) != 0
    //            && Vector3.Distance(transform.position, equipController.targetUnit.transform.position) < skillController.range)
    //        {
    //            if (equipController.owner.Shootable && Random.Range(0, 10000) < rate)
    //            {
    //                if (equipController.GetBullet())
    //                {
    //                    skillController.Shoot(equipController.targetUnit);

    //                    equipController.TriggerShoot();

    //                    inCd = true;
    //                    lastUseTime = Time.time;
    //                    StartCoroutine(doCD());
    //                }
    //            }
    //        }

    //        yield return null;
    //    }
    //}

    //private IEnumerator doCD()
    //{
    //    while (Time.time - lastUseTime < cd)
    //    {
    //        yield return null;
    //    }
    //    inCd = false;
    //}
}