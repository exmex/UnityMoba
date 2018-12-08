using System;
using UnityEngine;
using System.Collections;
using UnityEngine.Assertions.Comparers;

public class UTGBattleSkillBehaviourR60000141 : NTGBattleSkillBehaviour
{
    public float flyTime;
    public float flyResolution;
    public float shootAngle;

    public float physicFlyTime;

    private ArrayList flyPath;


    public void PreFly(float xOffset, float zOffset)
    {
        var targetPos = new Vector3(owner.transform.position.x + xOffset, owner.transform.position.y, owner.transform.position.z + zOffset);

        var tPos = owner.transform.worldToLocalMatrix.MultiplyPoint(targetPos);
        var bPos = owner.transform.worldToLocalMatrix.MultiplyPoint(owner.unitAnchors[skillAnchor].position);
        var angle = shootAngle*Mathf.PI/180;

        //Debug.Log(tPos);
        //Debug.Log(bPos);
        //Debug.Log(angle);

        var Sx = tPos.z - bPos.z;
        var Sy = tPos.y - bPos.y;
        float g = -(Physics.gravity.y*2.0f);

        var Vx = Sx/Mathf.Sqrt((Sx*Mathf.Tan(angle) - Sy)*2/g);
        var Vy = Vx*Mathf.Tan(angle);

        //Debug.Log(Vx);
        //Debug.Log(Vy);

        var t = Sx/Vx;
        physicFlyTime = t;
        //Debug.Log(t);

        flyPath = new ArrayList();
        Vector3 lp = new Vector3(0, 0, 0);
        float length = 0;

        flyPath.Add(owner.transform.localToWorldMatrix.MultiplyPoint(new Vector3(0, bPos.y, bPos.z)));

        float tt = 0;
        int i = 0;
        while (tt < t)
        {
            tt = i*flyResolution;

            var sx = tt*Vx + bPos.z;
            var sy = tt*Vy - g/2*tt*tt + bPos.y;

            var p = new Vector3(0, sy, sx);
            var pw = owner.transform.localToWorldMatrix.MultiplyPoint(p);

            flyPath.Add(pw);

            if (i > 0)
            {
                length += Vector3.Distance(lp, p);
            }

            lp = p;
            i++;
        }
    }

    public override void Shoot(NTGBattleUnitController lockedTarget, float xOffset, float zOffset)
    {
        base.Shoot(lockedTarget, xOffset, zOffset);

        startPos = transform.position;
        flyTime = (new Vector2(xOffset, zOffset)).magnitude/speed;

        PreFly(xOffset, zOffset);

        collider.radius = param[0];

        StartCoroutine(doFly(xOffset, zOffset));
    }

    private IEnumerator doFly(float xOffset, float zOffset)
    {
        FXEA();
        FXEB();

        float time = 0.0f;

        bool last = false;

        //Debug.LogWarning(String.Format("{0} {1} {2} {3} {4} {5}", flyTime, physicFlyTime, flyResolution, flyPath.Count, xOffset, zOffset));

        if (flyTime > 0)
        {
            while (!last)
            {
                int step = 0;
                if (time > flyTime)
                {
                    last = true;
                    step = flyPath.Count - 1;
                }
                else
                {
                    step = (int) (time/flyTime*physicFlyTime/flyResolution);
                }

                transform.position = (Vector3) flyPath[step];
                if (step == 0)
                {
                    transform.localRotation = Quaternion.Euler(shootAngle, 0, 0);
                }
                else
                {
                    var dir = (Vector3) flyPath[step] - (Vector3) flyPath[step - 1];
                    if (dir.x != 0 || dir.y != 0 || dir.z != 0)
                        transform.forward = dir;
                }

                yield return null;
                time += Time.deltaTime;
            }
        }

        FXExplode();
        collider.enabled = true;
        yield return new WaitForSeconds(0.1f);
        collider.enabled = false;

        yield return new WaitForSeconds(2.0f);

        Release();
    }

    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            otherUnit.Hit(shooter, this);

            otherUnit.AddPassive("Stun", owner, p: new[] {this.param[1]});

            FXHit(otherUnit);
        }
    }
}