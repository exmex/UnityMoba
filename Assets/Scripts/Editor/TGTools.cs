using System;
using System.Reflection;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

public static class TGTools
{
    [MenuItem("TG/Add Mesh Collider")]
    public static void AddMeshCollider()
    {
        Add_Mesh_Collider(Selection.activeGameObject);
    }

    private static void Add_Mesh_Collider(GameObject o)
    {
        for (int i = 0; i < o.transform.childCount; i++)
        {
            Add_Mesh_Collider(o.transform.GetChild(i).gameObject);
        }
        o.AddComponent<MeshCollider>();
    }

    [MenuItem("TG/Add Road Tag")]
    public static void AddRoadTag()
    {
        Add_Road_Tag(Selection.activeGameObject);
    }

    private static void Add_Road_Tag(GameObject o)
    {
        for (int i = 0; i < o.transform.childCount; i++)
        {
            Add_Road_Tag(o.transform.GetChild(i).gameObject);
        }
        o.tag = "Road";
    }

    [MenuItem("TG/Load Role Animation")]
    public static void LoadRoleAnimation()
    {
        foreach (var go in Selection.gameObjects)
        {
            var path = AssetDatabase.GetAssetPath(go);
            string filename = System.IO.Path.GetFileNameWithoutExtension(path);
            Debug.Log(path);
            ModelImporter mi = AssetImporter.GetAtPath(path) as ModelImporter;

            ModelImporterClipAnimation[] clips = mi.clipAnimations;
            Debug.Log(clips.Length);
            if (clips.Length == 0)
            {
                clips = new ModelImporterClipAnimation[1];
                clips[0] = new ModelImporterClipAnimation();
                clips[0].name = filename;

                AnimationClip orgClip = (AnimationClip) AssetDatabase.LoadAssetAtPath(path, typeof (AnimationClip));
                clips[0].firstFrame = 0;
                clips[0].lastFrame = (int) (orgClip.length*orgClip.frameRate);
            }


            for (int i = 0; i < clips.Length; i++)
            {
                ModelImporterClipAnimation mica = clips[i];

                mica.loopTime = true;
                mica.loopPose = false;
                mica.lockRootRotation = false;
                mica.lockRootPositionXZ = false;
                mica.lockRootHeightY = false;
                mica.keepOriginalOrientation = false;
                mica.keepOriginalPositionXZ = false;
                mica.keepOriginalPositionY = false;
                mica.maskType = ClipAnimationMaskType.CopyFromOther;
                mica.maskSource = (UnityEditor.Animations.AvatarMask) AssetDatabase.LoadAssetAtPath("Assets/Prefabs/Role/TGRoleAll.mask", typeof (UnityEditor.Animations.AvatarMask));
            }
            mi.motionNodeName = "Root";
            mi.clipAnimations = clips;

            MethodInfo updateTransformMaskMethod = mi.GetType().GetMethod("UpdateTransformMask", BindingFlags.NonPublic | BindingFlags.Static);
            SerializedObject serializedObject = new SerializedObject(mi);
            SerializedProperty clipAnimationsProperty = serializedObject.FindProperty("m_ClipAnimations");
            for (int i = 0; i < clips.Length; i++)
            {
                SerializedProperty transformMaskProperty = clipAnimationsProperty.GetArrayElementAtIndex(i).FindPropertyRelative("transformMask");
                updateTransformMaskMethod.Invoke(mi, new System.Object[] {mi.clipAnimations[i].maskSource, transformMaskProperty});
            }
            serializedObject.ApplyModifiedProperties();

            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
            AssetDatabase.Refresh();


            var assets = AssetDatabase.LoadAllAssetsAtPath(path);
            foreach (var asset in assets)
            {
                if (asset.GetType() == typeof (AnimationClip))
                {
                    Debug.Log(asset.name);
                    if (asset.name.IndexOf("__preview__") >= 0)
                        continue;

                    AnimationClip orgClip = (AnimationClip) asset;
                    AnimationClip placeClip = new AnimationClip();
                    EditorUtility.CopySerialized(orgClip, placeClip);
                    AssetDatabase.CreateAsset(placeClip, System.IO.Path.GetDirectoryName(path) + "/Resources/" + placeClip.name + ".anim");
                }
            }
        }
    }

    [MenuItem("TG/Load Common Animation")]
    public static void LoadWeaponAnimation()
    {
        foreach (var go in Selection.gameObjects)
        {
            var path = AssetDatabase.GetAssetPath(go);
            string filename = System.IO.Path.GetFileNameWithoutExtension(path);
            Debug.Log(path);
            ModelImporter mi = AssetImporter.GetAtPath(path) as ModelImporter;

            ModelImporterClipAnimation[] clips = mi.clipAnimations;
            Debug.Log(clips.Length);
            if (clips.Length == 0)
            {
                clips = new ModelImporterClipAnimation[1];
                clips[0] = new ModelImporterClipAnimation();
                clips[0].name = filename;

                AnimationClip orgClip = (AnimationClip) AssetDatabase.LoadAssetAtPath(path, typeof (AnimationClip));
                clips[0].firstFrame = 0;
                clips[0].lastFrame = (int) (orgClip.length*orgClip.frameRate);
            }


            for (int i = 0; i < clips.Length; i++)
            {
                ModelImporterClipAnimation mica = clips[i];

                mica.loopTime = true;
                mica.loopPose = false;
                mica.lockRootRotation = true;
                mica.lockRootPositionXZ = true;
                mica.lockRootHeightY = true;
                mica.keepOriginalOrientation = true;
                mica.keepOriginalPositionXZ = true;
                mica.keepOriginalPositionY = true;
            }
            mi.clipAnimations = clips;

            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
            AssetDatabase.Refresh();

            var assets = AssetDatabase.LoadAllAssetsAtPath(path);
            foreach (var asset in assets)
            {
                if (asset.GetType() == typeof (AnimationClip))
                {
                    Debug.Log(asset.name);
                    if (asset.name.IndexOf("__preview__") >= 0)
                        continue;

                    AnimationClip orgClip = (AnimationClip) asset;
                    AnimationClip placeClip = new AnimationClip();
                    EditorUtility.CopySerialized(orgClip, placeClip);
                    AssetDatabase.CreateAsset(placeClip, System.IO.Path.GetDirectoryName(path) + "/Resources/" + placeClip.name + ".anim");
                }
            }
        }
    }


    [MenuItem("TG/Load UTG Animation")]
    public static void LoadUTGAnimation()
    {
        foreach (var go in Selection.gameObjects)
        {
            var path = AssetDatabase.GetAssetPath(go);
            string filename = System.IO.Path.GetFileNameWithoutExtension(path);
            Debug.Log(path);
            ModelImporter mi = AssetImporter.GetAtPath(path) as ModelImporter;

            ModelImporterClipAnimation[] clips = mi.clipAnimations;
            Debug.Log(clips.Length);
            if (clips.Length == 0)
            {
                clips = new ModelImporterClipAnimation[1];
                clips[0] = new ModelImporterClipAnimation();
                clips[0].name = filename;

                AnimationClip orgClip = (AnimationClip) AssetDatabase.LoadAssetAtPath(path, typeof (AnimationClip));
                clips[0].firstFrame = 0;
                clips[0].lastFrame = (int) (orgClip.length*orgClip.frameRate);
            }


            for (int i = 0; i < clips.Length; i++)
            {
                ModelImporterClipAnimation mica = clips[i];

                mica.loopTime = true;
                mica.loopPose = false;
                mica.lockRootRotation = false;
                mica.lockRootPositionXZ = false;
                mica.lockRootHeightY = false;
                mica.keepOriginalOrientation = false;
                mica.keepOriginalPositionXZ = false;
                mica.keepOriginalPositionY = false;
            }
            mi.motionNodeName = "Root";
            mi.clipAnimations = clips;

            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
            AssetDatabase.Refresh();

            var assets = AssetDatabase.LoadAllAssetsAtPath(path);
            foreach (var asset in assets)
            {
                if (asset.GetType() == typeof (AnimationClip))
                {
                    Debug.Log(asset.name);
                    if (asset.name.IndexOf("__preview__") >= 0)
                        continue;

                    AnimationClip orgClip = (AnimationClip) asset;
                    AnimationClip placeClip = new AnimationClip();
                    EditorUtility.CopySerialized(orgClip, placeClip);
                    AssetDatabase.CreateAsset(placeClip, System.IO.Path.GetDirectoryName(path) + "/" + placeClip.name + ".anim");
                }
            }
        }
    }
}