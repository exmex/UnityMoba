using System;
using System.Collections.Generic;
using UnityEngine;

public class NTGRoleController : MonoBehaviour
{
    public Avatar roleAvatar;
    public Transform boneRoot;
    public RuntimeAnimatorController roleAC;
    public Dictionary<string, Transform> boneMap;

    public Animator animator;

    public Transform customWeapon;

    private AnimatorOverrideController aoc;

    public Transform weaponModel;
    public Transform bulletModel;
    public Transform bodyModel;
    public Transform braModel;

    public Transform fxAnchor;
    public Transform sfxAnchor;

    private string[] AnimationStateNames = {"Idle", "Standby", "Hurt", "Reload", "Victory", "Dead", "Attack", "Forward", "Backward", "Walk", "Walkback"};

    private Dictionary<NTGBattleUnitController.UnitStatus, string> AnimationEffectNames = new Dictionary<NTGBattleUnitController.UnitStatus, string>
    {
        {NTGBattleUnitController.UnitStatus.Knock, "Knock"},
        {NTGBattleUnitController.UnitStatus.Stun, "Stun"},
        {NTGBattleUnitController.UnitStatus.Blow, "Blow"},
    };

    public Dictionary<NTGBattleUnitController.UnitStatus, AnimationClip> AnimationEffectClips = new Dictionary<NTGBattleUnitController.UnitStatus, AnimationClip>();


    public void Awake()
    {
        boneMap = new Dictionary<string, Transform>();

        animator = GetComponent<Animator>();
        var dummy = transform.Find("Dummy");
        if (dummy != null)
        {
            DestroyImmediate(dummy.gameObject);
        }
    }

    public void ShowWeapon(bool show)
    {
        if (customWeapon != null)
        {
            customWeapon.gameObject.SetActive(show);
        }
    }

    public void SetIdle(bool idle)
    {
        if (animator == null)
            return;

        animator.SetBool("idle", idle);

        foreach (var ac in GetComponentsInChildren<NTGAnimatorController>())
        {
            ac.SetIdle(idle);
        }
    }

    public void SetWalking(bool walking, bool forward, bool running, float speed)
    {
        if (animator == null)
            return;

        animator.SetBool("walking", walking);
        animator.SetBool("forward", forward);
        animator.SetBool("running", running);
        animator.SetFloat("walkspeed", speed);

        foreach (var ac in GetComponentsInChildren<NTGAnimatorController>())
        {
            ac.SetWalking(walking);
        }
    }

    public void TriggerShoot()
    {
        if (animator == null)
            return;

        animator.SetTrigger("shoot");

        foreach (var ac in GetComponentsInChildren<NTGAnimatorController>())
        {
            ac.TriggerShoot();
        }
    }

    public void TriggerHurt()
    {
        if (animator == null)
            return;

        animator.SetTrigger("hurt");

        foreach (var ac in GetComponentsInChildren<NTGAnimatorController>())
        {
            ac.TriggerHurt();
        }
    }

    public void SetReload(bool inReload)
    {
        if (animator == null)
            return;

        animator.SetBool("reload", inReload);

        foreach (var ac in GetComponentsInChildren<NTGAnimatorController>())
        {
            ac.SetReload(inReload);
        }
    }

    public void SetDead(bool dead)
    {
        if (animator == null)
            return;

        animator.SetBool("dead", dead);

        foreach (var ac in GetComponentsInChildren<NTGAnimatorController>())
        {
            ac.SetDead(dead);
        }
    }

    public void TriggerVictory()
    {
        if (animator == null)
            return;

        animator.SetTrigger("victory");

        foreach (var ac in GetComponentsInChildren<NTGAnimatorController>())
        {
            ac.TriggerVictory();
        }
    }

    public void DisplayWeapon(bool display)
    {
        if (weaponModel != null)
            weaponModel.gameObject.SetActive(display);

        if (bulletModel != null)
            bulletModel.gameObject.SetActive(display);
    }

    public void DisplayBra(bool display)
    {
        if (braModel != null)
        {
            braModel.gameObject.SetActive(display);
            bodyModel.gameObject.SetActive(!display);
        }
    }


    public void LoadSpecialWeapon(string weaponResource)
    {
        var weaponAnchor = TGToolTransferBone.CreateBone(transform, "Root/Bip/S Weapon Anchor", boneRoot, boneMap);
        for (int i = weaponAnchor.childCount - 1; i >= 0; i--)
        {
            Destroy(weaponAnchor.GetChild(i).gameObject);
        }

        GameObject weapon = Resources.Load<GameObject>(weaponResource);
        if (weapon != null)
        {
            var customWeapon = Instantiate(weapon).transform;
            customWeapon.gameObject.name = weapon.name;
            customWeapon.gameObject.layer = LayerMask.NameToLayer("Player");
            foreach (var t in customWeapon.transform.GetComponentsInChildren<Transform>())
            {
                t.gameObject.layer = LayerMask.NameToLayer("Player");
            }

            customWeapon.parent = weaponAnchor;
            customWeapon.localPosition = Vector3.zero;
            customWeapon.localRotation = Quaternion.Euler(0, 0, 0);

            foreach (Transform t in customWeapon.GetComponentsInChildren<Transform>())
            {
                if (t.name == "FXAnchor")
                {
                    sfxAnchor = t;
                }
            }

            var weaponAnimator = customWeapon.GetComponent<Animator>();
            if (weaponAnimator != null)
                weaponAnimator.gameObject.AddComponent<NTGAnimatorController>().Init();
        }
    }

    public void LoadSkin(string bodyResource = "", string faceResource = "", string hairResource = "", string legResource = "", string shoesResource = "", string sWeaponResource = "")
    {
        Dictionary<string, string> partMap = new Dictionary<string, string>
        {
            {"Body", bodyResource},
            {"Hair", hairResource},
            {"Face", faceResource},
            {"Leg", legResource},
            {"Shoes", shoesResource},
            {"Bra", "R71150030"},
        };

        foreach (var p in partMap)
        {
            if (p.Value == "")
            {
                continue;
            }

            var old = transform.Find(p.Key + "(Clone)");
            if (old != null)
            {
                DestroyImmediate(old.gameObject);
            }

            var role = Resources.Load<GameObject>(p.Value);
            if (role != null)
            {
                Transform model = role.transform.FindChild(p.Key);
                if (model != null)
                {
                    var obj = Instantiate(model.gameObject);
                    obj.transform.parent = transform;
                    obj.layer = LayerMask.NameToLayer("Player");
                    foreach (var t in obj.transform.GetComponentsInChildren<Transform>())
                    {
                        t.gameObject.layer = LayerMask.NameToLayer("Player");
                    }

                    SkinnedMeshRenderer render = obj.GetComponent<SkinnedMeshRenderer>();
                    TGToolTransferBone.Create(render, transform, boneRoot, boneMap);

                    if (p.Key == "Body")
                        bodyModel = obj.transform;
                    else if (p.Key == "Bra")
                    {
                        braModel = obj.transform;
                        braModel.gameObject.SetActive(false);
                    }
                }
            }
        }

        LoadSpecialWeapon(sWeaponResource);
    }

    public void LoadWeapon(string weaponResource)
    {
        var weaponAnchor = TGToolTransferBone.CreateBone(transform, "Root/Bip/Hips/Spine/Chest/Neck/R Shoulder/R Upper Arm/R Lower Arm/R Hand/R Weapon Anchor", boneRoot, boneMap);
        for (int i = weaponAnchor.childCount - 1; i >= 0; i--)
        {
            Destroy(weaponAnchor.GetChild(i).gameObject);
        }

        GameObject weapon = Resources.Load<GameObject>(weaponResource);
        if (weapon != null)
        {
            if (weaponModel != null)
            {
                Destroy(weaponModel.gameObject);
            }
            if (bulletModel != null)
            {
                Destroy(bulletModel.gameObject);
            }

            customWeapon = Instantiate(weapon).transform;
            customWeapon.gameObject.name = weapon.name;
            customWeapon.gameObject.layer = LayerMask.NameToLayer("Player");
            foreach (var t in customWeapon.transform.GetComponentsInChildren<Transform>())
            {
                t.gameObject.layer = LayerMask.NameToLayer("Player");
            }

            customWeapon.parent = weaponAnchor;
            customWeapon.localPosition = Vector3.zero;
            customWeapon.localRotation = Quaternion.Euler(0, 0, 0);

            weaponModel = customWeapon;
            bulletModel = customWeapon.Find("Bullet");

            foreach (Transform t in customWeapon.GetComponentsInChildren<Transform>())
            {
                if (t.name == "FXAnchor")
                {
                    fxAnchor = t;
                }
            }

            var weaponAnimator = customWeapon.GetComponent<Animator>();
            if (weaponAnimator != null)
                weaponAnimator.gameObject.AddComponent<NTGAnimatorController>().Init();
        }
    }

    public void LoadMainAnimation(string animationResource)
    {
        if (aoc == null)
        {
            aoc = new AnimatorOverrideController();
            aoc.name = "TGRoleOverrideAC";
            aoc.runtimeAnimatorController = roleAC;
        }

        foreach (var s in AnimationStateNames)
        {
            var load = Resources.Load<AnimationClip>(animationResource + "-" + s);

            aoc["Common" + "-" + s] = load;
            aoc["Leg" + "-" + s] = load;
        }

        foreach (var name in AnimationEffectNames)
        {
            AnimationEffectClips[name.Key] = Resources.Load<AnimationClip>(animationResource + "-" + name.Value);
        }

        if (animator != null)
        {
            DestroyImmediate(animator);
        }
        animator = gameObject.AddComponent<Animator>();
        animator.avatar = roleAvatar;
        animator.applyRootMotion = true;
        animator.cullingMode = AnimatorCullingMode.CullUpdateTransforms;
        animator.runtimeAnimatorController = aoc;
    }

    public void SetBattleEffect(NTGBattleUnitController.UnitStatus effect, bool inEffect)
    {
        if (animator == null)
            return;

        if (AnimationEffectClips.ContainsKey(effect) && AnimationEffectClips[effect] != null)
        {
            Debug.Log(effect.ToString() + "Setting to" + inEffect.ToString());

            aoc["Common-Effect"] = AnimationEffectClips[effect];

            animator.runtimeAnimatorController = null;
            animator.runtimeAnimatorController = aoc;

            animator.SetBool("effect", inEffect);
        }

        foreach (var ac in GetComponentsInChildren<NTGAnimatorController>())
        {
            ac.SetBattleEffect(effect, inEffect);
        }
    }

    public Dictionary<string, AnimationClip> SkillAnimationClips = new Dictionary<string, AnimationClip>();

    public void TriggerSkill(string skillAnimResource, float speed)
    {
        if (animator == null)
            return;

        if (String.IsNullOrEmpty(skillAnimResource))
        {
            TriggerShoot();
            return;
        }

        if (!SkillAnimationClips.ContainsKey(skillAnimResource))
        {
            SkillAnimationClips[skillAnimResource] = Resources.Load<AnimationClip>(skillAnimResource + "-Skill");
        }

        if (SkillAnimationClips[skillAnimResource] == null)
        {
            TriggerShoot();
            return;
        }

        aoc["Leg-Skill"] = SkillAnimationClips[skillAnimResource];
        aoc["Common-Skill"] = SkillAnimationClips[skillAnimResource];

        animator.runtimeAnimatorController = null;
        animator.runtimeAnimatorController = aoc;

        animator.SetFloat("skillspeed", speed);
        animator.SetTrigger("skill");

        foreach (var ac in GetComponentsInChildren<NTGAnimatorController>())
        {
            ac.TriggerSkill(skillAnimResource, speed);
        }
    }

#if false //CombineSkinnedMeshRenderer
    private void CombineSkinnedMeshRenderer(List<SkinnedMeshRenderer> smRenderers)
    {
        bool hasNormalMaps = false;

        int maxAtlasSize = 2048;

        SkinnedMeshRenderer[] SMRs;

        int vertCount = 0;
        int normCount = 0;
        int tanCount = 0;
        int triCount = 0;
        int uvCount = 0;
        int boneCount = 0;
        int bpCount = 0;
        int bwCount = 0;

        Transform[] bones;
        Matrix4x4[] bindPoses;
        BoneWeight[] weights;

        Vector3[] verts;
        Vector3[] norms;
        Vector4[] tans;
        int[] tris;
        Vector2[] uvs;
        Texture2D[] textures;
        Texture2D[] normalmaps;

        int vertOffset = 0;
        int normOffset = 0;
        int tanOffset = 0;
        int triOffset = 0;
        int uvOffset = 0;
        int meshOffset = 0;

        int boneSplit = 0;
        int bNum = 0;

        int[] bCount;

        SMRs = smRenderers.ToArray();

        foreach (SkinnedMeshRenderer smr in SMRs)
        {
            vertCount += smr.sharedMesh.vertices.Length;
            normCount += smr.sharedMesh.normals.Length;
            tanCount += smr.sharedMesh.tangents.Length;
            triCount += smr.sharedMesh.triangles.Length;
            uvCount += smr.sharedMesh.uv.Length;
            boneCount += smr.bones.Length;
            bpCount += smr.sharedMesh.bindposes.Length;
            bwCount += smr.sharedMesh.boneWeights.Length;
            bNum++;
        }

        bCount = new int[3];
        bones = new Transform[boneCount];
        weights = new BoneWeight[bwCount];
        bindPoses = new Matrix4x4[bpCount];
        textures = new Texture2D[bNum];
        normalmaps = new Texture2D[bNum];

        foreach (SkinnedMeshRenderer smr in SMRs)
        {
            for (int b1 = 0; b1 < smr.bones.Length; b1++)
            {
                bones[bCount[0]] = smr.bones[b1];

                bCount[0]++;
            }

            for (int b2 = 0; b2 < smr.sharedMesh.boneWeights.Length; b2++)
            {
                weights[bCount[1]] = smr.sharedMesh.boneWeights[b2];
                weights[bCount[1]].boneIndex0 += boneSplit;
                weights[bCount[1]].boneIndex1 += boneSplit;
                weights[bCount[1]].boneIndex2 += boneSplit;
                weights[bCount[1]].boneIndex3 += boneSplit;

                bCount[1]++;
            }

            for (int b3 = 0; b3 < smr.sharedMesh.bindposes.Length; b3++)
            {
                bindPoses[bCount[2]] = smr.sharedMesh.bindposes[b3];

                bCount[2]++;
            }

            boneSplit += smr.bones.Length;
        }

        verts = new Vector3[vertCount];
        norms = new Vector3[normCount];
        tans = new Vector4[tanCount];
        tris = new int[triCount];
        uvs = new Vector2[uvCount];

        foreach (SkinnedMeshRenderer smr in SMRs)
        {
            foreach (int i in smr.sharedMesh.triangles)
            {
                tris[triOffset++] = i + vertOffset;
            }

            foreach (Vector3 v in smr.sharedMesh.vertices)
            {
                verts[vertOffset++] = v;
            }

            foreach (Vector3 n in smr.sharedMesh.normals)
            {
                norms[normOffset++] = n;
            }

            foreach (Vector4 t in smr.sharedMesh.tangents)
            {
                tans[tanOffset++] = t;
            }

            foreach (Vector2 uv in smr.sharedMesh.uv)
            {
                uvs[uvOffset++] = uv;
            }

            textures[meshOffset] = (Texture2D) smr.sharedMaterial.GetTexture("_MainTex");
            if (hasNormalMaps) normalmaps[meshOffset] = (Texture2D) smr.sharedMaterial.GetTexture("_BumpMap");

            meshOffset++;

            Destroy(smr.gameObject);
        }

        Texture2D tx = new Texture2D(1, 1);
        Rect[] r = tx.PackTextures(textures, 0, maxAtlasSize);

        Texture2D nm = new Texture2D(1, 1);

        if (hasNormalMaps)
        {
            nm.PackTextures(normalmaps, 0, maxAtlasSize);
        }

        uvOffset = 0;
        meshOffset = 0;

        foreach (SkinnedMeshRenderer smr in SMRs)
        {
            foreach (Vector2 uv in smr.sharedMesh.uv)
            {
                uvs[uvOffset].x = Mathf.Lerp(r[meshOffset].xMin, r[meshOffset].xMax, uv.x%1);
                uvs[uvOffset].y = Mathf.Lerp(r[meshOffset].yMin, r[meshOffset].yMax, uv.y%1);

                uvOffset ++;
            }

            meshOffset ++;
        }

        Material mat;
        if (hasNormalMaps) mat = new Material(Shader.Find("Bumped Diffuse"));
        else
        {
            //mat = new Material(Shader.Find("Diffuse"));
            mat = new Material(Shader.Find(SMRs[0].material.shader.name));
        }

        mat.SetTexture("_MainTex", tx);
        if (hasNormalMaps) mat.SetTexture("_BumpMap", nm);

        Mesh me = new Mesh();
        me.name = gameObject.name;
        me.vertices = verts;
        me.normals = norms;
        me.tangents = tans;
        me.boneWeights = weights;
        me.uv = uvs;
        me.triangles = tris;

        me.bindposes = bindPoses;

        SkinnedMeshRenderer newSMR = gameObject.AddComponent<SkinnedMeshRenderer>();

        newSMR.sharedMesh = me;
        newSMR.bones = bones;
        newSMR.updateWhenOffscreen = true;

        GetComponent<Renderer>().material = mat;
    }
#endif

#if false //old LoadAvatar
    public void LoadAvatar(string BodyId = "", string FaceId = "", string HairId = "", string WeaponId = "")
    {
        Dictionary<string, string> partMap = new Dictionary<string, string>
        {
            {"Body", BodyId},
            {"Hair", HairId},
            {"Face", FaceId},
            {"Weapon", WeaponId}
        };

        Dictionary<string, string> stateMap = new Dictionary<string, string>
        {
            {"Idle", "A0"},
            {"Play", "B0"},
            {"Walk", "C0"},
            {"Standby", "D0"},
            {"Hurt", "F0"},
            {"Victory", "G0"},
            {"Dead", "H0"},
            {"Attack", "I0"},
            {"Forward", "C0"},
            {"Backward", "J0"},
            {"Knock", "K0"},
            {"Stun", "L0"},
            {"Roll", "M0"},
        };

        if (aoc == null)
        {
            aoc = new AnimatorOverrideController();
            aoc.name = "TGRoleOverrideAC";
            aoc.runtimeAnimatorController = roleAC;
        }

        var smr = GetComponent<SkinnedMeshRenderer>();
        if (smr != null)
        {
            DestroyImmediate(smr);
        }

        List<SkinnedMeshRenderer> smRenderers = new List<SkinnedMeshRenderer>();

        foreach (var p in partMap)
        {
            if (p.Value == "")
            {
                continue;
            }
            var old = transform.Find(p.Key + "(Clone)");
            if (old != null)
            {
                DestroyImmediate(old.gameObject);
            }

            var role = Resources.Load<GameObject>(p.Value);
            if (role != null)
            {
                Transform model = role.transform.FindChild(p.Key);
                if (model != null)
                {
                    var obj = Instantiate(model.gameObject) as GameObject;
                    obj.transform.parent = transform;
                    obj.layer = LayerMask.NameToLayer("Player");
                    foreach (var t in obj.transform.GetComponentsInChildren<Transform>())
                    {
                        t.gameObject.layer = LayerMask.NameToLayer("Player");
                    }

                    SkinnedMeshRenderer render = obj.GetComponent<SkinnedMeshRenderer>();
                    //TGToolTransferBone.Transfer(ref render, transform);
                    TGToolTransferBone.Create(render, transform, boneRoot, boneMap);

                    smRenderers.Add(obj.GetComponent<SkinnedMeshRenderer>());
                }
            }

            /*
            foreach (var s in stateMap)
            {
                var load = Resources.Load<AnimationClip>(p.Value.Substring(0, 9) + "R" + s.Value);
                if (load == null)
                    continue;

                if (aoc[p.Key + "-" + s.Key] != null)
                {
                    Destroy(aoc[p.Key + "-" + s.Key]);
                }
                aoc[p.Key + "-" + s.Key] = Instantiate(load) as AnimationClip;
            }
            */
        }

        //CombineSkinnedMeshRenderer(smRenderers);
        //TGToolTransferBone.Create(GetComponent<SkinnedMeshRenderer>(), transform, boneRoot, boneMap);

        if (partMap["Weapon"] != "")
        {
            foreach (var s in stateMap)
            {
                var load = Resources.Load<AnimationClip>(partMap["Weapon"].Substring(0, 9) + "R" + s.Value);
                if (aoc["Leg" + "-" + s.Key] != null && aoc["Leg" + "-" + s.Key].name.Contains("(Clone)"))
                {
                    Destroy(aoc["Leg" + "-" + s.Key]);
                }
                aoc["Leg" + "-" + s.Key] = Instantiate(load) as AnimationClip;

                if (aoc["Weapon" + "-" + s.Key] != null && aoc["Weapon" + "-" + s.Key].name.Contains("(Clone)"))
                {
                    Destroy(aoc["Weapon" + "-" + s.Key]);
                }
                aoc["Weapon" + "-" + s.Key] = Instantiate(load) as AnimationClip;
            }

            //var weaponAnchor = transform.Find("Root/Hips/Spine/Chest/Neck/R Shoulder/R Upper Arm/R Lower Arm/R Hand/R Weapon Anchor");
            var weaponAnchor = TGToolTransferBone.CreateBone(transform, "Root/Hips/Spine/Chest/Neck/R Shoulder/R Upper Arm/R Lower Arm/R Hand/R Weapon Anchor", boneRoot, boneMap);
            for (int i = weaponAnchor.childCount - 1; i >= 0; i--)
            {
                Destroy(weaponAnchor.GetChild(i).gameObject);
            }

            GameObject weapon = Resources.Load<GameObject>(partMap["Weapon"] + "C");
            if (weapon != null)
            {
                if (weaponModel != null)
                {
                    Destroy(weaponModel.gameObject);
                }
                if (bulletModel != null)
                {
                    Destroy(bulletModel.gameObject);
                }

                customWeapon = ((GameObject) Instantiate(weapon)).transform;
                customWeapon.gameObject.layer = LayerMask.NameToLayer("Player");
                foreach (var t in customWeapon.transform.GetComponentsInChildren<Transform>())
                {
                    t.gameObject.layer = LayerMask.NameToLayer("Player");
                }
                customWeapon.parent = weaponAnchor;
                customWeapon.localPosition = Vector3.zero;
                customWeapon.localRotation = Quaternion.Euler(0, 0, 0);

                weaponModel = customWeapon;
                bulletModel = customWeapon.Find("Bullet");
                fxAnchor = customWeapon.Find("FXAnchor");

                weaponAnimator = customWeapon.GetComponent<Animator>();
                weaponAnimator.applyRootMotion = false;
                weaponAnimator.cullingMode = AnimatorCullingMode.CullUpdateTransforms;

                AnimatorOverrideController weaponAoc = new AnimatorOverrideController();
                weaponAoc.name = "TGWeaponOverrideAC";
                weaponAoc.runtimeAnimatorController = commonAC;

                foreach (var s in stateMap)
                {
                    var clip = Resources.Load<AnimationClip>(partMap["Weapon"].Substring(0, 15) + "C" + s.Value);
                    if (clip != null)
                    {
                        if (weaponAoc["Weapon-" + s.Key] != null)
                        {
                            Destroy(weaponAoc["Weapon-" + s.Key]);
                        }
                        weaponAoc["Weapon-" + s.Key] = Instantiate(clip) as AnimationClip;
                    }
                }

                weaponAnimator.runtimeAnimatorController = weaponAoc;
            }
        }


        if (animator != null)
        {
            DestroyImmediate(animator);
        }
        animator = gameObject.AddComponent<Animator>();
        animator.avatar = roleAvatar;
        animator.applyRootMotion = false;
        animator.cullingMode = AnimatorCullingMode.CullUpdateTransforms;
        animator.runtimeAnimatorController = aoc;

        /*
        GetComponent<Animator>().runtimeAnimatorController = null;
        GetComponent<Animator>().runtimeAnimatorController = aoc;
        */
    }
#endif
}