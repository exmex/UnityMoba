using System;
using System.IO;
using LuaInterface;
using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;


public class NTGApplicationConfig
{
    public const bool Release = false;

#if UNITY_EDITOR
    public const bool LuaDebugMode = !Release;
    public const bool ResourceUpdateEnabled = Release;
    public const int ApplicationTargetFPS = 360;
#else
    public const bool LuaDebugMode = false;    
    public const bool ResourceUpdateEnabled = Release;
    public const int ApplicationTargetFPS = 30;
#endif

    public const bool LuaEncode = Release;

    public const string ResourceUpdateUrl_Android = Release ? "http://utggameupdate.oss-cn-hangzhou.aliyuncs.com/ntg/android/" : "http://10.10.0.100/ntg/android/";
    public const string ResourceUpdateUrl_IOS = Release ? "http://utggameupdate.oss-cn-hangzhou.aliyuncs.com/ntg/ios/" : "http://10.10.0.100/ntg/ios/";

    public const string ApplicationName = "NewToughGirl";

    public const bool AutoWrapMode = true;  

    public static string LuaBasePath
    {
        get { return Application.dataPath + "/uLua/Source/"; }
    }

    public static string LuaWrapPath
    {
        get { return LuaBasePath + "LuaWrap/"; }
    }
}

public class NTGApplicationController : MonoBehaviour
{
    public static Type GetType(string TypeName)
    {
        //var type = Type.GetType(TypeName);
        //if (type != null)
        //    return type;

        var type = Types.GetType(TypeName, "Assembly-CSharp");
        if (type != null)
            return type;

        var assemblyName = TypeName;
        while (assemblyName.LastIndexOf('.') != -1)
        {
            assemblyName = assemblyName.Substring(0, assemblyName.LastIndexOf('.'));
            type = Types.GetType(TypeName, assemblyName);
            if (type != null)
                return type;
        }

        return null;
    }

    private static NTGApplicationController _instance;

    public static NTGApplicationController Instance
    {
        get { return _instance; }
    }

    public static void SetShowQuality(bool show)
    {
        if (show)
        {
            QualitySettings.pixelLightCount = 4;
            QualitySettings.blendWeights = BlendWeights.TwoBones;
        }
        else
        {
            QualitySettings.pixelLightCount = 1;
            QualitySettings.blendWeights = BlendWeights.OneBone;
        }
    }

    private void Awake()
    {
        if (_instance == null)
        {
            _instance = this;
            DontDestroyOnLoad(gameObject);

            Application.targetFrameRate = NTGApplicationConfig.ApplicationTargetFPS;
            Screen.sleepTimeout = SleepTimeout.NeverSleep;

            if (Application.platform == RuntimePlatform.Android || Application.platform == RuntimePlatform.IPhonePlayer)
                Destroy(standaloneInputModule);

            InitResources();
        }
        else
        {
            DestroyImmediate(gameObject);
        }
    }

    private bool UpdateResourcePanelLoaded = false;
    private LuaTable UpdateResourcePanelApi;
    private GameObject UpdateResourcePanel;

    private void LoadUpdateResourcePanel()
    {
        if (!UpdateResourcePanelLoaded)
        {
            StartLua();

            var prefab = NTGResourceController.Instance.LoadAsset("UpdateResource", "UpdateResourcePanel");
            var panelRoot = GameObject.Find("GameLogic").transform.Find("PanelRoot");
            var go = Instantiate(prefab);
            go.name = "UpdateResourcePanel";
            go.transform.SetParent(panelRoot);
            go.transform.localScale = Vector3.one;
            go.transform.localPosition = Vector3.zero;
            go.SetActive(true);

            UpdateResourcePanel = go;
            UpdateResourcePanelApi = LuaGetTable("UpdateResourceAPI.Instance");

            LuaCall("UpdateResourceAPI", "DebugText", UpdateResourcePanelApi, "");

            UpdateResourcePanelLoaded = true;
        }
    }

    private void InitResources()
    {
        if (Directory.Exists(NTGResourceController.DataPath) && File.Exists(NTGResourceController.DataPath + "files.txt"))
        {
            LoadUpdateResourcePanel();
            StartCoroutine(doUpdateResources());
        }
        else
        {
            StartCoroutine(doExtractResources());
        }
    }

    private IEnumerator ExtractFile(string infile, string outfile)
    {
        var dir = Path.GetDirectoryName(outfile);
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        if (Application.platform == RuntimePlatform.Android)
        {
            WWW www = new WWW(infile);
            yield return www;

            if (www.isDone)
            {
                File.WriteAllBytes(outfile, www.bytes);
            }
        }
        else
        {
            File.Copy(infile, outfile, true);
        }
    }

    private IEnumerator doExtractResources()
    {
        string dataPath = NTGResourceController.DataPath;
        string assetsPath = NTGResourceController.StreamingAssetsPath;

        //Debug.Log("Extracting from " + assetsPath + " to " + dataPath);

        string infile = assetsPath + "files.txt";
        string outfile = dataPath + "files.txt";
        yield return StartCoroutine(ExtractFile(infile, outfile));
        yield return null;

        int preload = 0;
        string[] files = File.ReadAllLines(outfile);
        for (int i = 0; i < files.Length; i++)
        {
            string file = files[i];
            if (!file.StartsWith("lua") || (file.StartsWith("lua/Logic") && !file.StartsWith("lua/Logic/UpdateResource")))
                continue;
            string[] fs = file.Split('|');
            infile = assetsPath + fs[0];
            outfile = dataPath + fs[0];

            //Debug.Log("Extracting System File:>" + infile);
            yield return StartCoroutine(ExtractFile(infile, outfile));
            yield return null;

            preload++;
        }

        infile = assetsPath + "updateresource.assetbundle";
        outfile = dataPath + "updateresource.assetbundle";
        //Debug.Log("Extracting UpdatePanel File:>" + infile);
        yield return StartCoroutine(ExtractFile(infile, outfile));
        yield return null;

        LoadUpdateResourcePanel();
        LuaCall("UpdateResourceAPI", "ShowUpdateInfo", UpdateResourcePanelApi, 3, 0);
        LuaCall("UpdateResourceAPI", "GetLoadingData", UpdateResourcePanelApi, -1, 0);

        for (int i = 0; i < files.Length; i++)
        {
            string file = files[i];
            if (!(!file.StartsWith("lua") || (file.StartsWith("lua/Logic") && !file.StartsWith("lua/Logic/UpdateResource"))))
            {
                LuaCall("UpdateResourceAPI", "GetLoadingData", UpdateResourcePanelApi, -1, ((float) i + 1)/(files.Length - preload));
                continue;
            }
            string[] fs = file.Split('|');
            infile = assetsPath + fs[0];
            outfile = dataPath + fs[0];

            //Debug.Log(String.Format("Extracting File:{0}->{1}", infile, outfile));
            //LuaCall("UpdateResourceAPI", "DebugText", UpdateResourcePanelApi, "解压:" + fs[0]);
            yield return StartCoroutine(ExtractFile(infile, outfile));
            yield return null;

            LuaCall("UpdateResourceAPI", "GetLoadingData", UpdateResourcePanelApi, -1, ((float) i + 1)/(files.Length - preload));
        }

        StartCoroutine(doUpdateResources());
    }

    private IEnumerator doUpdateResources()
    {
        if (!NTGApplicationConfig.ResourceUpdateEnabled)
        {
            StartGameManager();
            yield break;
        }

        LuaCall("UpdateResourceAPI", "ShowUpdateInfo", UpdateResourcePanelApi, 1, 0);

        string dataPath = NTGResourceController.DataPath; //数据目录
        string url = NTGApplicationConfig.ResourceUpdateUrl_Android;

        if (Application.platform == RuntimePlatform.IPhonePlayer || Application.platform == RuntimePlatform.OSXEditor)
            url = NTGApplicationConfig.ResourceUpdateUrl_IOS;

        WWW www = new WWW(url + "files.txt");
        yield return www;
        if (www.error != null)
        {
            Debug.LogError("Update Resources Failed! :" + www.error.ToString());
            StartGameManager();
            yield break;
        }

        var updateUrls = new ArrayList();
        var updateFiles = new ArrayList();

        File.WriteAllBytes(dataPath + "files.txt", www.bytes);
        string[] files = www.text.Split('\n');
        for (int i = 0; i < files.Length; i++)
        {
            var file = files[i];
            if (string.IsNullOrEmpty(file))
                continue;

            string[] keyValue = file.Split('|');
            string filename = keyValue[0];
            string localfile = (dataPath + filename).Trim();
            string path = Path.GetDirectoryName(localfile);
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            string fileUrl = url + filename;
            bool needUpdate = !File.Exists(localfile);
            if (!needUpdate)
            {
                string remoteMd5 = keyValue[1].Trim();
                string localMd5 = NTGResourceController.GetFileMD5(localfile);
                needUpdate = !remoteMd5.Equals(localMd5);
            }

            if (needUpdate)
            {
                updateUrls.Add(fileUrl);
                updateFiles.Add(localfile);
            }
        }

        LuaCall("UpdateResourceAPI", "ShowUpdateInfo", UpdateResourcePanelApi, 2, 0);
        LuaCall("UpdateResourceAPI", "GetLoadingData", UpdateResourcePanelApi, 0, 0);
        for (int i = 0; i < updateFiles.Count; i++)
        {
            File.Delete((string) updateFiles[i]);

            var downloader = new NTGResourceController.FileDownloder();

            Debug.Log("Updating File:>" + updateUrls[i]);
            //LuaCall("UpdateResourceAPI", "DebugText", UpdateResourcePanelApi, "下载:" + keyValue[0]);

            downloader.DownloadFile((string) updateUrls[i], (string) updateFiles[i]);
            while (!downloader.DownloadComplete)
            {
                yield return null;
                LuaCall("UpdateResourceAPI", "GetLoadingData", UpdateResourcePanelApi, downloader.DownloadingSpeed, ((float) i)/updateUrls.Count);
            }

            LuaCall("UpdateResourceAPI", "GetLoadingData", UpdateResourcePanelApi, downloader.DownloadingSpeed, ((float) i + 1)/updateUrls.Count);
            yield return null;
        }

        StartGameManager();
    }

    private LuaState lua = null;
    private LuaLooper looper = null;

    public bool Initialized;

    public Transform panelRoot;
    public Transform gameRoot;
    public StandaloneInputModule standaloneInputModule;

    private void StartLua()
    {
        NTGResourceController.Instance.InitBundleDependencies();

        lua = new LuaState();

#if UNITY_STANDALONE_OSX || UNITY_EDITOR_OSX
        lua.OpenLibs(LuaDLL.luaopen_bit);
#endif

        lua.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
        lua.OpenLibs(LuaDLL.luaopen_cjson);
        lua.LuaSetField(-2, "cjson");

        lua.OpenLibs(LuaDLL.luaopen_cjson_safe);
        lua.LuaSetField(-2, "cjson.safe");

        lua.LuaSetTop(0);
        
        LuaBinder.Bind(lua);

        lua.Start();

        looper = gameObject.AddComponent<LuaLooper>();
        looper.luaState = lua;

        Initialized = true;
    }

    private void StartGameManager()
    {
        LuaCall("UpdateResourceAPI", "ShowUpdateInfo", UpdateResourcePanelApi, 4, 0);

        if (UpdateResourcePanel != null)
            Destroy(UpdateResourcePanel);

        NTGResourceController.Instance.InitBundleDependencies();

        var script = gameObject.AddComponent<NTGLuaScript>();
        script.transforms = new[] {panelRoot, gameRoot};
        script.Load("Logic.GameManager");
    }

    public object[] LuaDoFile(string scriptName)
    {
        if (lua != null && Initialized)
        {
            return lua.DoFile(NTGResourceController.LuaPath(scriptName));
        }
        return null;
    }

    public object[] LuaCall(string module, string name, params object[] args)
    {
        if (lua != null && Initialized)
        {
            string funcName = module + "." + name;
            var func = lua.GetFunction(funcName);
            var result = func.Call(args);
            func.Dispose();
            return result;
        }
        return null;
    }

    public LuaFunction LuaGetFunction(string module, string func)
    {
        if (lua != null && Initialized)
        {
            string funcName = module + "." + func;
            return lua.GetFunction(funcName);
        }
        return null;
    }

    public LuaTable LuaGetTable(string name)
    {
        if (lua != null && Initialized)
        {
            return lua.GetTable(name);
        }
        return null;
    }

    public void RemoveTableCache(string fullPath)
    {
        if (lua != null && Initialized)
        {
            lua.RemoveTableCache(fullPath);
        }
    }

    public void LuaReleaseTable(LuaTable table)
    {
        if (lua != null && Initialized)
        {
            lua.CollectRef(table.GetReference(), table.name);
        }
    }

    private void OnDestroy()
    {
        if (lua != null)
        {
            lua.Dispose();
            lua = null;
        }

        TGNetService.GetInstance().Stop();
    }
}