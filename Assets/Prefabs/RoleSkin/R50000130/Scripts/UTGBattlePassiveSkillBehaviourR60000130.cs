using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR60000130 : NTGBattlePassiveSkillBehaviour {

    public int count = 0;

    public float pDuration;

    public UTGBattleSkillControllerR60000134 sc;

    public bool IsCorRun = false;

    public override void Respawn()
    {
        

        base.Respawn();

        sc.sbForCount = this;

        count = 0;

        pDuration = 0;

        skillFX.transform.localPosition = new Vector3(skillFX.transform.localPosition.x, 2.8f, skillFX.transform.localPosition.z);
        for (int i = 0; i < skillFX.transform.childCount; i++)
        {
            skillFX.transform.GetChild(i).gameObject.SetActive(false);
        }

        StartCoroutine(doCheck());
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if(e == NTGBattlePassive.Event.Shoot)
        {
            var p = (NTGBattlePassive.EventShootParam)param;
            if(p.controller.type == NTGBattleSkillType.Attack && p.shooter == owner)
            {
                if (count == this.param[0]+1)
                {
                    count = 0;
                }
                count++;
                if(count > 0 && count < 4)
                {
                    for (int i = 0; i < skillFX.transform.childCount;i++ )
                    {
                        skillFX.transform.GetChild(i).gameObject.SetActive(false);
                    }
                    skillFX.transform.GetChild(count - 1).gameObject.SetActive(true);
                    for (int i = 0; i < skillFX.transform.GetChild(count - 1).childCount;i++ )
                    {
                        skillFX.transform.GetChild(count - 1).GetChild(i).GetComponent<ParticleSystem>().Stop();
                        skillFX.transform.GetChild(count - 1).GetChild(i).GetComponent<ParticleSystem>().Play();
                    }
                    pDuration = this.param[1];
                }
                else if(count == this.param[0])
                {
                    for (int i = 0; i < skillFX.transform.childCount; i++)
                    {
                        skillFX.transform.GetChild(i).gameObject.SetActive(false);
                    }
                    skillFX.transform.GetChild(count - 1).gameObject.SetActive(true);
                    for (int i = 0; i < skillFX.transform.GetChild(count - 1).childCount; i++)
                    {
                        skillFX.transform.GetChild(count - 1).GetChild(i).GetComponent<ParticleSystem>().Stop();
                        skillFX.transform.GetChild(count - 1).GetChild(i).GetComponent<ParticleSystem>().Play();
                    }
                    pDuration = this.param[2];
                }
                else if(count == this.param[0]+1)
                {
                    for (int i = 0; i < skillFX.transform.childCount; i++)
                    {
                        skillFX.transform.GetChild(i).gameObject.SetActive(false);
                    }
                }

                if (IsCorRun == false)
                {
                    StartCoroutine(doCheck());
                }
            }
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            for (int i = 0; i < skillFX.transform.childCount; i++)
            {
                skillFX.transform.GetChild(i).gameObject.SetActive(false);
            }
            count = 0;
        }
    }

    private IEnumerator doCheck()
    {
        IsCorRun = true;
        while (pDuration > 0)
        {
            yield return new WaitForSeconds(0.1f);
            pDuration -= 0.1f;
        }
        for (int i = 0; i < skillFX.transform.childCount; i++)
        {
            skillFX.transform.GetChild(i).gameObject.SetActive(false);
        }
        count = 0;
        IsCorRun = false;
    }

    public void DoSpecialShootCount(int count)
    {
        this.count = count;
        if (count > 0 && count < 4)
        {
            for (int i = 0; i < skillFX.transform.childCount; i++)
            {
                skillFX.transform.GetChild(i).gameObject.SetActive(false);
            }
            skillFX.transform.GetChild(count - 1).gameObject.SetActive(true);
            for (int i = 0; i < skillFX.transform.GetChild(count - 1).childCount; i++)
            {
                skillFX.transform.GetChild(count - 1).GetChild(i).GetComponent<ParticleSystem>().Stop();
                skillFX.transform.GetChild(count - 1).GetChild(i).GetComponent<ParticleSystem>().Play();
            }
            pDuration = this.param[1];
        }
        else if (count == this.param[0])
        {
            for (int i = 0; i < skillFX.transform.childCount; i++)
            {
                skillFX.transform.GetChild(i).gameObject.SetActive(false);
            }
            skillFX.transform.GetChild(count - 1).gameObject.SetActive(true);
            for (int i = 0; i < skillFX.transform.GetChild(count - 1).childCount; i++)
            {
                skillFX.transform.GetChild(count - 1).GetChild(i).GetComponent<ParticleSystem>().Stop();
                skillFX.transform.GetChild(count - 1).GetChild(i).GetComponent<ParticleSystem>().Play();
            }
            pDuration = this.param[2];
        }
        else if (count == this.param[0] + 1)
        {
            for (int i = 0; i < skillFX.transform.childCount; i++)
            {
                skillFX.transform.GetChild(i).gameObject.SetActive(false);
            }
        }

        if (IsCorRun == false)
        {
            StartCoroutine(doCheck());
        }

    }
}
