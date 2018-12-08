using UnityEngine;
using System.Collections;

public class NTGBattleEquipsMotionController : MonoBehaviour
{
    public NTGBattlePlayerController owner;

    public float accTime;
    public float speedRatio;

    // Use this for initialization
    private void Start()
    {
        owner = GetComponentInParent<NTGBattlePlayerController>();

        moving = false;

        position = owner.transform.position;
    }

    public bool moving;

    public Vector3 position;

    public float speed;
    public float acceleration;


    public void LateUpdate()
    {
        acceleration = owner.MoveSpeed/accTime;

        if (!moving && owner.transform.position != position)
        {
            moving = true;

            speed = 0;
        }

        if (moving && owner.transform.position == position)
        {
            moving = false;
        }

        transform.position += position - owner.transform.position;

        position = owner.transform.position;

        if (Vector3.Distance(owner.transform.position, transform.position) > accTime*owner.MoveSpeed*speedRatio)
        {
            transform.position = owner.transform.position;
        }

        if (Vector3.Distance(owner.transform.position, transform.position) > speed*Time.deltaTime)
        {
            transform.position += (owner.transform.position - transform.position).normalized*speed*Time.deltaTime;
        }
        else
        {
            transform.position = owner.transform.position;
        }

        speed += acceleration*Time.deltaTime;
        if (speed > owner.MoveSpeed*speedRatio)
            speed = owner.MoveSpeed*speedRatio;
    }
}