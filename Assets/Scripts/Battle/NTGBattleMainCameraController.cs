using System;
using System.Collections.Generic;
using UnityEngine;
using System.Collections;

public class NTGBattleMainCameraController : MonoBehaviour
{
    public Transform LookPos;
    public NTGBattlePlayerController localPlayerController;
    private Vector3 mainPlayerTrackingOffset;

    public bool closeTrackingMode;
    public Transform closeTrackingLookPos;
    public Transform closeTrackingUnit;
    private Vector3 closeTrackingOffset;

    public bool endTrackingMode;

    public Vector3 shockOffset;

    // Use this for initialization
    private void Start()
    {
        closeTrackingMode = false;
        endTrackingMode = false;

        StartCoroutine(doShock());
    }

    private void OnEnable()
    {
        mainPlayerTrackingOffset = transform.position - LookPos.position;
        closeTrackingOffset = transform.position - closeTrackingLookPos.position;
    }

    public void ReverseCamera()
    {
        mainPlayerTrackingOffset = new Vector3(-mainPlayerTrackingOffset.x, mainPlayerTrackingOffset.y, -mainPlayerTrackingOffset.z);
        transform.Rotate(new Vector3(0, 1, 0), 180.0f, Space.World);
    }

    public void LateUpdate()
    {
        //if (closeTrackingMode)
        //{
        //    transform.position = closeTrackingUnit.position + closeTrackingOffset;
        //}
        //else
        //{

        if (endTrackingMode)
        {
            transform.position = LookPos.position + mainPlayerTrackingOffset;
        }
        else
        {
            if (localPlayerController == null)
            {
                return;
            }
            transform.position = localPlayerController.transform.position + mainPlayerTrackingOffset;
        }

        localPlayerController.mainController.uiController.UpdateUnitUIPosition();

        //}
        transform.Translate(shockOffset);
    }

    public Transform endTrackingUnit;
    public float endTrackingSpeed;

    public void StartBattleEndTracking(Transform trackingUnit)
    {
        LookPos.parent = null;
        LookPos.position = localPlayerController.transform.position;
        endTrackingUnit = trackingUnit;
        endTrackingSpeed = Vector3.Distance(endTrackingUnit.transform.position, LookPos.position)/3.0f;
        endTrackingMode = true;

        StartCoroutine(doEndTracking());
    }

    private IEnumerator doEndTracking()
    {
        while (Vector3.Distance(LookPos.position, endTrackingUnit.position) > 0.1)
        {
            LookPos.LookAt(endTrackingUnit);
            LookPos.Translate(0, 0, endTrackingSpeed*Time.deltaTime);
            yield return null;
        }
    }

    public void StartCloseTracking(Transform trackingUnit)
    {
        closeTrackingUnit = trackingUnit;
        closeTrackingMode = true;
    }

    public void StopCloseTracking()
    {
        closeTrackingMode = false;
    }

    public Animator shockAnimator;

    public enum CameraShockType
    {
        Small,
        Medium,
        Large
    }

    //public Dictionary<CameraShockType, string> shockMap = new Dictionary<CameraShockType, string>
    //{
    //    {CameraShockType.Small, "01"},
    //    {CameraShockType.Medium, "02"},
    //    {CameraShockType.Large, "03"},
    //};

    public void Shock(string type)
    {
        if (!String.IsNullOrEmpty(type) && shockAnimator.GetCurrentAnimatorStateInfo(0).IsName("Stop"))
            shockAnimator.SetTrigger(type);
    }

    private IEnumerator doShock()
    {
        while (true)
        {
            shockOffset = shockAnimator.transform.localPosition;
            yield return null;
        }
    }
}