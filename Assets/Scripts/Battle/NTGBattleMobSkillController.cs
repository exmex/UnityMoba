using UnityEngine;
using System.Collections;

public class NTGBattleMobSkillController : MonoBehaviour
{
    public NTGBattleMobController mobController;
    public NTGBattleSkillController skillController;

    protected void Awake()
    {
        mobController = GetComponentInParent<NTGBattleMobController>();
        skillController = GetComponent<NTGBattleSkillController>();
    }

    public virtual void Init(float[] p)
    {
    }

    public virtual void Respawn()
    {
    }
}