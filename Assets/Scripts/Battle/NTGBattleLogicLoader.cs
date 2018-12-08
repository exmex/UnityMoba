using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;

public class NTGBattleLogicLoader : MonoBehaviour
{
    private void Start()
    {
        if (gameObject.name == "Respawn")
        {
            Application.LoadLevelAdditive("NTGBattleLogic");

            //var load = SceneManager.LoadSceneAsync("NTGBattleLogic", LoadSceneMode.Additive);
        }
    }
}