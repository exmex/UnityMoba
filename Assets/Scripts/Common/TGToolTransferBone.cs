using System.Collections.Generic;
using UnityEngine;
using System.Collections;

public class TGToolTransferBone
{
    private static Transform DoTransferBone(Transform oBoneOld, Transform oBoneNewRoot)
    {
        string sBonePath = oBoneOld.name;
        Transform oNodeIterator = oBoneOld.parent;
        while (oNodeIterator.parent != null)
        {
            sBonePath = oNodeIterator.name + "/" + sBonePath;
            oNodeIterator = oNodeIterator.parent;
        }
        //Debug.Log("trying to find " + sBonePath + " in " + oBoneNewRoot.name);
        Transform oBoneNew = oBoneNewRoot.Find(sBonePath);
        if (oBoneNew == null)
            Debug.LogError("could not transfer bone '" + sBonePath + "' to new root '" + oBoneNewRoot + "'");
        return oBoneNew;
    }

    public static void Transfer(ref SkinnedMeshRenderer oSkinMeshRend, Transform oBoneNewRoot)
    {
        Transform[] aBones = oSkinMeshRend.bones;
        for (int nBone = 0; nBone < oSkinMeshRend.bones.Length; nBone++)
            aBones[nBone] = DoTransferBone(aBones[nBone], oBoneNewRoot);
        oSkinMeshRend.bones = aBones;
        oSkinMeshRend.rootBone = DoTransferBone(oSkinMeshRend.rootBone, oBoneNewRoot);
    }

    public static Transform CreateBone(Transform boneRoot, string bonePath, Transform baseBoneRoot, Dictionary<string, Transform> boneMap)
    {
        //Debug.Log("Creating Bone " + bonePath);
        var boneNames = bonePath.Split(new char[] {'/'});
        var boneParent = boneRoot;
        var baseBoneParent = baseBoneRoot;
        for (int i = 0; i < boneNames.Length; i++)
        {
            //if (boneNames[i].Contains("Finger") || boneNames[i].Contains("Hair") || boneNames[i].Contains("Skirt"))
            //if (boneNames[i].Contains("Finger"))
            if (false)
            {
                var boneChild = boneParent.Find(boneNames[i] + "Dummy");
                var baseBoneChild = baseBoneParent.Find(boneNames[i]);
                if (boneChild == null)
                {
                    boneChild = (new GameObject(boneNames[i] + "Dummy")).transform;
                    boneChild.parent = boneParent;
                }

                boneChild.localPosition = baseBoneChild.localPosition;
                boneChild.localRotation = baseBoneChild.localRotation;
                boneChild.localScale = baseBoneChild.localScale;
                boneParent = boneChild;
                baseBoneParent = baseBoneChild;

                boneMap[boneNames[i]] = boneChild;
            }
            else
            {
                var boneChild = boneParent.Find(boneNames[i]);
                var baseBoneChild = baseBoneParent.Find(boneNames[i]);
                if (boneChild == null)
                {
                    boneChild = (new GameObject(boneNames[i])).transform;
                    boneChild.parent = boneParent;
                }

                boneChild.localPosition = baseBoneChild.localPosition;
                boneChild.localRotation = baseBoneChild.localRotation;
                boneChild.localScale = baseBoneChild.localScale;
                boneParent = boneChild;
                baseBoneParent = baseBoneChild;

                boneMap[boneNames[i]] = boneChild;
            }
        }

        return boneParent;
    }

    private static Transform DoCreateBone(Transform oBoneOld, Transform oBoneNewRoot, Transform baseBoneRoot, Dictionary<string, Transform> boneMap)
    {
        string sBonePath = oBoneOld.name;
        Transform oNodeIterator = oBoneOld.parent;
        while (oNodeIterator.parent != null)
        {
            sBonePath = oNodeIterator.name + "/" + sBonePath;
            oNodeIterator = oNodeIterator.parent;
        }

        Transform oBoneNew = CreateBone(oBoneNewRoot, sBonePath, baseBoneRoot, boneMap);

        return oBoneNew;
    }

    public static void Create(SkinnedMeshRenderer oSkinMeshRend, Transform oBoneNewRoot, Transform baseBoneRoot, Dictionary<string, Transform> boneMap)
    {
        Transform[] aBones = oSkinMeshRend.bones;
        for (int nBone = 0; nBone < oSkinMeshRend.bones.Length; nBone++)
            aBones[nBone] = DoCreateBone(aBones[nBone], oBoneNewRoot, baseBoneRoot, boneMap);
        oSkinMeshRend.bones = aBones;
        oSkinMeshRend.rootBone = DoCreateBone(oSkinMeshRend.rootBone, oBoneNewRoot, baseBoneRoot, boneMap);
    }
}