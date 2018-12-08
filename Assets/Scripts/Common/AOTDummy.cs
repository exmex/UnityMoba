using UnityEngine;
using System.Collections;

public class AOTDummy : MonoBehaviour {

	// Use this for initialization
	void Start () {
        var x = Newtonsoft.Json.Linq.JObject.Parse("");
        Debug.Log(x[""].Value<int>(0));
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
