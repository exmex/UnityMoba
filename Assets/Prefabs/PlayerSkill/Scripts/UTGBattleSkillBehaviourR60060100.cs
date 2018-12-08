using UnityEngine;
using System.Collections;

public class UTGBattleSkillBehaviourR60060100 : NTGBattleSkillBehaviour
{
    public float pDuration;

    private float rotation;

    private float rateX,rateY;

    public override void Shoot(NTGBattleUnitController target, float xOffset, float zOffset)
    {
        base.Shoot(target, xOffset, zOffset);

        collider.radius = range;

        rotation = transform.eulerAngles.y;

        StartCoroutine(doFly());
    }

    private IEnumerator doFly()
    {
        FXEA();
        FXEB();
        FXExplode();


        float pDistance = this.param[0] * 0.6f ;

        rateX = Mathf.Sin(Mathf.Deg2Rad * rotation);
        rateY = Mathf.Cos(Mathf.Deg2Rad * rotation);

        skillController.StartCD();

        yield return new WaitForSeconds(0.1f);

        owner.transform.GetComponent<NavMeshAgent>().enabled = false;

        float height = owner.transform.localPosition.y;


        owner.transform.localPosition = new Vector3(owner.transform.localPosition.x, 2, owner.transform.localPosition.z);
        owner.transform.localPosition = new Vector3(owner.transform.localPosition.x + pDistance * rateX
                                        , owner.transform.localPosition.y, owner.transform.localPosition.z + pDistance * rateY);
        owner.transform.localPosition = new Vector3(owner.transform.localPosition.x, height, owner.transform.localPosition.z);
        owner.transform.GetComponent<NavMeshAgent>().enabled = true;
        
        //owner.transform.localPosition = Vector3.forward * pDistance;

        Release();
    }
}
