using UnityEngine;
using System.Collections;

public class NTGBattleEquipSkillController : MonoBehaviour
{
    public NTGBattleEquipController equipController;
    public NTGBattleSkillController skillController;

    // Use this for initialization
    protected void Start()
    {
    }

    public virtual void Init(NTGBattleEquipController equipController, NTGBattleSkillController skillController, float[] p)
    {
        this.equipController = equipController;
        this.skillController = skillController;
    }

    public virtual void Respawn()
    {
    }
}