using UnityEngine;
using System.Collections;

public class UTGBattlePassiveSkillBehaviourR600301502 : NTGBattlePassiveSkillBehaviour
{

    public bool addMagicDamage = false;

    public float count = 0;

    public ArrayList pBehaviourTemp;

    public NTGBattlePassiveSkillBehaviour pbTemp;

    public ArrayList pControllerTemp;

    public override void Respawn()
    {
        base.Respawn();

        pbTemp = skillController.pBehaviours[0];

        pBehaviourTemp = new ArrayList();

        pControllerTemp = new ArrayList();
    }

    public override void Notify(NTGBattlePassive.Event e, object param)
    {
        base.Notify(e, param);

        if (e == NTGBattlePassive.Event.Shoot)
        {
            var p = (NTGBattlePassive.EventShootParam)param;
            if (p.shooter == owner && (p.controller.type == NTGBattleSkillType.FriendlyPassive || p.controller.type == NTGBattleSkillType.FriendlySkill
                || p.controller.type == NTGBattleSkillType.HostilePassive || p.controller.type == NTGBattleSkillType.HostileSkill) && skillController.inCd <= 0)
            {
                addMagicDamage = true;
                count = 4;
                StartCoroutine(doCount());
            }

        }
        else if (e == NTGBattlePassive.Event.Hit)
        {
            var p = (NTGBattlePassive.EventHitParam)param;
            if (p.behaviour.type == NTGBattleSkillType.Attack && p.shooter == owner && addMagicDamage && p.target.alive)
            {
                addMagicDamage = false;

                StopAllCoroutines();
                p.target.AddPassive(pbTemp.passiveName, owner, skillController);
                skillController.StartCD();
            }
        }
        else if(e == NTGBattlePassive.Event.PassiveAdd)
        {
            var p = (NTGBattlePassiveSkillBehaviour)param;
            pBehaviourTemp.Add(p.skillController.pBehaviours[0]);
            pControllerTemp.Add(p.skillController);
            //Debug.Log("Length " + pBehaviourTemp.Count + " " + p.passiveName);
        }
        else if(e == NTGBattlePassive.Event.PassiveRemove)
        {
            
            if (pBehaviourTemp.Count != 0)
            {
                pbTemp = (NTGBattlePassiveSkillBehaviour)pBehaviourTemp[0];
                pBehaviourTemp.Remove(pBehaviourTemp[0]);
                skillController = (NTGBattlePassiveSkillController)pControllerTemp[0];
                pControllerTemp.Remove(pControllerTemp[0]);
                //Debug.Log("Remove " + pBehaviourTemp.Count);
            }
            else
            {
                pBehaviourTemp.Clear();
                pControllerTemp.Clear();
                Release();
            }
        }
    }

    private IEnumerator doCount()
    {
        while (count > 0)
        {
            yield return new WaitForSeconds(0.1f);
            count -= 0.1f;
        }
        addMagicDamage = false;
    }
}
