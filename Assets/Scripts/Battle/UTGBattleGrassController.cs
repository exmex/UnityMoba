using UnityEngine;
using System.Collections;

public class UTGBattleGrassController : MonoBehaviour
{
    public ArrayList[] groupUnits;

    private void Awake()
    {
        groupUnits = new ArrayList[NTGBattleMainController.GroupCount];

        for (int i = 0; i < NTGBattleMainController.GroupCount; i++)
        {
            groupUnits[i] = new ArrayList();
        }
    }

    public void OnTriggerEnter(Collider other)
    {
        var unit = other.GetComponent<NTGBattleUnitController>();
        if (unit != null)
        {
            if (groupUnits[unit.group - 1].Count == 0 && unit.group != 3)
            {
                for (int i = 0; i < NTGBattleMainController.GroupCount; i++)
                {
                    if (i + 1 == unit.group)
                        continue;

                    foreach (NTGBattleUnitController groupUnit in groupUnits[i])
                    {
                        groupUnit.GroupVisibleCount[unit.group - 1]--;

                        if (unit.mainController.localGroup == unit.group && groupUnit.viewController.unitInView)
                            groupUnit.viewController.UnitShow();
                    }
                }
            }

            groupUnits[unit.group - 1].Add(unit);

            for (int i = 0; i < NTGBattleMainController.GroupCount; i++)
            {
                if (i + 1 == 3)
                    continue;

                if (groupUnits[i].Count == 0)
                {
                    unit.GroupVisibleCount[i]++;

                    if (unit.mainController.localGroup - 1 == i && unit.viewController.unitInView)
                        unit.viewController.UnitHide();
                }
            }

            unit.SetTransparent(true);
        }
    }

    public void OnTriggerExit(Collider other)
    {
        var unit = other.GetComponent<NTGBattleUnitController>();
        if (unit != null)
        {
            unit.SetTransparent(false);

            for (int i = 0; i < NTGBattleMainController.GroupCount; i++)
            {
                if (i + 1 == 3)
                    continue;

                if (groupUnits[i].Count == 0)
                {
                    unit.GroupVisibleCount[i]--;

                    if (unit.mainController.localGroup - 1 == i && unit.viewController.unitInView)
                        unit.viewController.UnitShow();
                }
            }

            groupUnits[unit.group - 1].Remove(unit);

            if (groupUnits[unit.group - 1].Count == 0 && unit.group != 3)
            {
                for (int i = 0; i < NTGBattleMainController.GroupCount; i++)
                {
                    if (i + 1 == unit.group)
                        continue;

                    foreach (NTGBattleUnitController groupUnit in groupUnits[i])
                    {
                        groupUnit.GroupVisibleCount[unit.group - 1]++;

                        if (unit.mainController.localGroup == unit.group && groupUnit.viewController.unitInView)
                            groupUnit.viewController.UnitHide();
                    }
                }
            }
        }
    }
}