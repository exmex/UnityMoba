using System;
using UnityEngine;
using System.Collections;

public class NTGBattleEquipR62100001 : NTGBattleEquipController
{
    public float trackRange;
    public float trackTime;
    public float trackMinAngle;
    public float trackMaxAngle;

    // Use this for initialization
    //private void Start()
    //{
    //    base.Start();
    //}

    //// Update is called once per frame
    //private void Update()
    //{
    //    base.Update();
    //}

    //public override void Init(float[] p)
    //{
    //    base.Init(p);

    //    trackRange = p[0];
    //    trackTime = p[1];
    //    trackMinAngle = p[2];
    //    trackMaxAngle = p[3];
    //}

    //public override void Respawn()
    //{
    //    base.Respawn();

    //    StartCoroutine(doTracking());
    //}

    //private IEnumerator doTracking()
    //{
    //    while (owner.alive && active)
    //    {
    //        targetUnit = owner.FindTarget(trackRange);

    //        if (targetUnit == null)
    //        {
    //            transform.forward = Vector3.RotateTowards(transform.forward, owner.transform.forward, trackingSpeed*Time.deltaTime/180*(float) Math.PI, 0);

    //            yield return new WaitForSeconds(1.0f);
    //            continue;
    //        }

    //        float time = 0;
    //        while (targetUnit != null && owner.alive && time < trackTime)
    //        {
    //            var targetVector = new Vector3(targetUnit.transform.position.x, 0, targetUnit.transform.position.z) - new Vector3(transform.position.x, 0, transform.position.z);
    //            targetAngle = Vector3.Angle(transform.forward, targetVector);

    //            Vector3 newForward;

    //            if (owner.transform.InverseTransformDirection(transform.forward).z*owner.transform.InverseTransformDirection(targetVector).z < 0 && Vector3.Angle(transform.forward, -owner.transform.right*transform.localScale.x) > 0.5f)
    //            {
    //                newForward = Vector3.RotateTowards(transform.forward, -owner.transform.right*transform.localScale.x, trackingSpeed*Time.deltaTime/180*(float) Math.PI, 0);
    //            }
    //            else
    //            {
    //                newForward = Vector3.RotateTowards(transform.forward, targetVector, trackingSpeed*Time.deltaTime/180*(float) Math.PI, 0);
    //            }

    //            var minDeg = 90.0f + transform.localScale.x*trackMinAngle;
    //            var maxDeg = 90.0f + transform.localScale.x*trackMaxAngle;

    //            var tv = owner.transform.InverseTransformDirection(targetVector);
    //            var targetDeg = Vector3.Angle(tv, new Vector3(1, 0, 0));
    //            if (tv.z < 0)
    //                targetDeg = 360.0f - targetDeg;

    //            if (transform.localScale.x > 0)
    //            {
    //                if (targetDeg >= minDeg && targetDeg <= maxDeg)
    //                {
    //                    transform.forward = newForward;
    //                }
    //            }
    //            else
    //            {
    //                if ((targetDeg >= 0 && targetDeg <= minDeg) || (targetDeg <= 0 && targetDeg >= maxDeg))
    //                {
    //                    transform.forward = newForward;
    //                }
    //            }

    //            yield return null;
    //            time += Time.deltaTime;
    //        }

    //        yield return new WaitForSeconds(1.0f);
    //    }
    //}
}