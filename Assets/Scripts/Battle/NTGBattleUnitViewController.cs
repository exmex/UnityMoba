using UnityEngine;
using System.Collections;

public class NTGBattleUnitViewController : MonoBehaviour
{
    public NTGBattleUnitController owner;

    private ArrayList _unitsInView = new ArrayList();

    public ArrayList unitsInView
    {
        get
        {
            _unitsInView.Clear();

            for (int x = gridX - viewGridLength; x <= gridX + viewGridLength; x++)
            {
                for (int z = gridZ - viewGridLength; z <= gridZ + viewGridLength; z++)
                {
                    if (owner.mainController.gridUnits[x][z].Count > 0 &&
                        owner.mainController.views[gridX][gridZ][x - gridX + maxViewLength][z - gridZ + maxViewLength] &&
                        owner.mainController.radViews[viewGridLength][x - gridX + maxViewLength][z - gridZ + maxViewLength])
                    {
                        for (int i = 0; i < owner.mainController.gridUnits[x][z].Count; i++)
                        {
                            _unitsInView.Add(owner.mainController.gridUnits[x][z][i]);
                        }
                    }
                }
            }

            return _unitsInView;
        }
    }

    public float gridSize;
    public int viewGridLength;
    public int maxViewLength;
    public int gridX;
    public int gridZ;

    public bool unitInView;

    public void Respawn(NTGBattleUnitController owner)
    {
        this.owner = owner;

        gridSize = owner.mainController.gridSize;
        viewGridLength = (int) (owner.targetRange/gridSize);
        maxViewLength = (int) (owner.mainController.maxViewRange/gridSize);

        gridX = (int) (owner.transform.position.x/gridSize);
        gridZ = (int) (owner.transform.position.z/gridSize);

        owner.mainController.gridUnits[gridX][gridZ].Add(owner);

        if (owner.group == owner.mainController.localGroup)
        {
            for (int x = gridX - viewGridLength; x <= gridX + viewGridLength; x++)
            {
                for (int z = gridZ - viewGridLength; z <= gridZ + viewGridLength; z++)
                {
                    if (owner.mainController.views[gridX][gridZ][x - gridX + maxViewLength][z - gridZ + maxViewLength] &&
                        owner.mainController.radViews[viewGridLength][x - gridX + maxViewLength][z - gridZ + maxViewLength])
                        owner.mainController.gridViews[x][z]++;
                }
            }

            UnitInView();
            StartCoroutine(doUpdateGrid());
        }
        else
        {
            if (owner is NTGBattleMobTowerController || owner is NTGBattleMobBaseController || owner is NTGBattleMobPoolController)
            {
                UnitInView();
            }
            else
            {
                StartCoroutine(doUpdateGrid());
            }
        }
    }

    public bool unitShow;

    public void UnitShow()
    {
        if (!unitShow)
        {
            owner.SetVisibility(true);

            if (owner is UTGBattleMobObjectController)
                return;

            if (owner is NTGBattlePlayerController)
            {
                if (owner.alive)
                    owner.mainController.uiController.MiniMapCreate(owner, 4, owner.group == owner.mainController.localGroup ? (owner.id == owner.mainController.localId ? 0 : 1) : 2, owner.icon);
            }
            else if (owner is NTGBattleMobCommonController)
            {
                owner.mainController.uiController.MiniMapCreate(owner, 5, owner.group == owner.mainController.localGroup ? 1 : 2, owner.icon);
            }
            else if (owner is NTGBattleMobTowerController)
            {
                owner.mainController.uiController.MiniMapCreate(owner, 2, owner.group == owner.mainController.localGroup ? 1 : 2, owner.icon);
            }
            else if (owner is NTGBattleMobBaseController)
            {
                owner.mainController.uiController.MiniMapCreate(owner, 1, owner.group == owner.mainController.localGroup ? 1 : 2, owner.icon);
            }
            else
            {
                owner.mainController.uiController.MiniMapCreate(owner, 5, owner.group == owner.mainController.localGroup ? 1 : 2, owner.icon);
            }

            if (owner.mainController.unitsInView.Contains(owner))
            {
                Debug.LogError("unit already in view!");
            }
            owner.mainController.unitsInView.Add(owner);

            unitShow = true;
        }
    }

    public void UnitHide()
    {
        if (unitShow)
        {
            if (owner is UTGBattleMobObjectController)
                return;

            owner.SetVisibility(false);

            owner.mainController.unitsInView.Remove(owner);

            owner.mainController.uiController.MiniMapDestory(owner);

            unitShow = false;
        }
    }

    private void UnitInView()
    {
        if (owner.GroupVisibleCount[owner.mainController.localGroup - 1] <= 0)
        {
            UnitShow();
        }

        unitInView = true;
    }

    private void UnitOutView()
    {
        if (owner.GroupVisibleCount[owner.mainController.localGroup - 1] <= 0)
        {
            UnitHide();
        }

        unitInView = false;
    }

    public void Kill()
    {
        owner.mainController.gridUnits[gridX][gridZ].Remove(owner);

        if (owner.group == owner.mainController.localGroup)
        {
            for (int x = gridX - viewGridLength; x <= gridX + viewGridLength; x++)
            {
                for (int z = gridZ - viewGridLength; z <= gridZ + viewGridLength; z++)
                {
                    if (owner.mainController.views[gridX][gridZ][x - gridX + maxViewLength][z - gridZ + maxViewLength] &&
                        owner.mainController.radViews[viewGridLength][x - gridX + maxViewLength][z - gridZ + maxViewLength])
                        owner.mainController.gridViews[x][z]--;
                }
            }
        }

        if (unitInView)
            UnitOutView();
    }

    private IEnumerator doUpdateGrid()
    {
        while (owner.alive)
        {
            var gx = (int) (owner.transform.position.x/gridSize);
            var gz = (int) (owner.transform.position.z/gridSize);

            var offsetX = gx - gridX;
            var offsetZ = gz - gridZ;

            if (owner.group == owner.mainController.localGroup)
            {
                if (offsetX != 0 || offsetZ != 0)
                {
                    for (int x = gridX - viewGridLength; x <= gridX + viewGridLength; x++)
                    {
                        for (int z = gridZ - viewGridLength; z <= gridZ + viewGridLength; z++)
                        {
                            if (owner.mainController.views[gridX][gridZ][x - gridX + maxViewLength][z - gridZ + maxViewLength] &&
                                owner.mainController.radViews[viewGridLength][x - gridX + maxViewLength][z - gridZ + maxViewLength])
                                owner.mainController.gridViews[x][z]--;
                        }
                    }

                    for (int x = gx - viewGridLength; x <= gx + viewGridLength; x++)
                    {
                        for (int z = gz - viewGridLength; z <= gz + viewGridLength; z++)
                        {
                            if (owner.mainController.views[gx][gz][x - gx + maxViewLength][z - gz + maxViewLength] &&
                                owner.mainController.radViews[viewGridLength][x - gx + maxViewLength][z - gz + maxViewLength])
                                owner.mainController.gridViews[x][z]++;
                        }
                    }
                }
            }

            if (offsetX != 0 || offsetZ != 0)
            {
                owner.mainController.gridUnits[gridX][gridZ].Remove(owner);
                gridX = gx;
                gridZ = gz;
                owner.mainController.gridUnits[gridX][gridZ].Add(owner);
            }

            if (owner.group != owner.mainController.localGroup)
            {
                if (owner.mainController.gridViews[gridX][gridZ] > 0)
                {
                    if (!unitInView)
                    {
                        UnitInView();
                    }
                }
                else
                {
                    if (unitInView)
                    {
                        UnitOutView();
                    }
                }
            }

            yield return null;
        }
    }
}