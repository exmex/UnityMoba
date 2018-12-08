using UnityEngine;
using System.Collections;

public class NTGBattleVisibilityChecker : MonoBehaviour
{
    public NTGBattleUnitController unit;

    private void Awake()
    {
        unit = GetComponentInParent<NTGBattleUnitController>();
    }

    public void OnBecameInvisible()
    {
        unit.rendererVisible = false;

        if (unit.unitUiAnchor != null)
        {
            unit.mainController.ReleaseUnitUI(unit);
        }

        unit.unitAnimator.enabled = false;
    }

    public void OnBecameVisible()
    {
        unit.rendererVisible = true;

        if (unit.unitUiAnchor != null && unit.alive)
        {
            unit.mainController.NewUnitUI(unit);
        }

        unit.unitAnimator.enabled = true;
    }
}