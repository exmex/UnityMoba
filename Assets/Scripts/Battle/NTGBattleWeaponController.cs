using UnityEngine;
using System.Collections;

public class NTGBattleWeaponControllerLegacy : MonoBehaviour
{
    public NTGBattleUnitController owner;
    //public NTGBattleMemberWeapon weapon;

    public float pp;
    public float ppCost;
    public float ppCapacity;

    public float reloadTime;

    private void Awake()
    {
        owner = GetComponentInParent<NTGBattleUnitController>();
    }

    // Use this for initialization
    private void Start()
    {
    }

    // Update is called once per frame
    private void Update()
    {
    }

    //public void Respawn()
    //{
    //    StartCoroutine(doAutoReload());
    //}

    //private IEnumerator doAutoReload()
    //{
    //    while (true)
    //    {
    //        if (pp < ppCost)
    //        {
    //            Reload();
    //        }
    //        yield return new WaitForSeconds(1.0f);
    //    }
    //}

    //public bool GetBullet()
    //{
    //    bool bullet = false;
    //    if (inReload)
    //        return false;
    //    if (pp >= ppCost)
    //    {
    //        pp -= ppCost;
    //        bullet = true;
    //    }
    //    if (pp < ppCost)
    //    {
    //        Reload();
    //    }
    //    return bullet;
    //}


    public float reloadStartTime;
    public float reloadStartPp;
    public bool inReload;

    //public void Reload()
    //{
    //    var loadAmount = ppCapacity - pp;
    //    if (owner.pp < loadAmount)
    //    {
    //        loadAmount = owner.pp;
    //    }
    //    if (!inReload && loadAmount > 0)
    //    {
    //        owner.pp -= loadAmount;
    //        reloadStartTime = Time.time;
    //        reloadStartPp = pp;
    //        inReload = true;
    //        StartCoroutine(doReload(loadAmount));

    //        if (owner.pp < 0.1f)
    //        {
    //            owner.mainController.uiController.ShowPlayerTips(owner as NTGBattlePlayerController, NTGBattleUIController.PlayerTip.LastClip);
    //        }
    //        else
    //        {
    //            //owner.mainController.uiController.ShowPlayerTips(owner as NTGBattlePlayerController, NTGBattleUIController.PlayerTip.Reload);
    //        }
    //    }
    //}

    //private IEnumerator doReload(float loadAmount)
    //{
    //    owner.SetReload(true);
    //    while (Time.time - reloadStartTime < reloadTime)
    //    {
    //        pp = reloadStartPp + (Time.time - reloadStartTime)/reloadTime*loadAmount;
    //        yield return null;
    //    }
    //    pp = reloadStartPp + loadAmount;
    //    owner.SetReload(false);
    //    inReload = false;
    //}
}