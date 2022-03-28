using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MaterialUtility.MaterialFuncs;

[System.Serializable]
public struct IterMatReplace
{
    public GameObject obj;
    public Material oldMat;
    public Material newMat;
}
public class IterativeMaterialReplaceTool : MonoBehaviour
{
    public List<IterMatReplace> replaceList;
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    //#########################################################
    public void DoReplace()
    {
        for (int i = 0; i < replaceList.Count; i++)
        {
            var obj = replaceList[i].obj;
            var old = replaceList[i].oldMat;
            IterativeReplaceChildMaterial(obj, replaceList[i].oldMat, replaceList[i].newMat);
        }
    }

    public void DoReverseReplace()
    {
        for (int i = 0; i < replaceList.Count; i++)
        {
            var obj = replaceList[i].obj;
            var old = replaceList[i].oldMat;
            IterativeReplaceChildMaterial(obj, replaceList[i].newMat, replaceList[i].oldMat);
        }
    }

    void IterativeReplaceChildMaterial(GameObject father, Material oldm, Material newm)
    {
        for (int i = 0; i < father.transform.childCount; i++)
        {
            var child = father.transform.GetChild(i).gameObject;
            SafeReplaceMaterial(child, oldm, newm);
            IterativeReplaceChildMaterial(child, oldm, newm);
        }
    }
}
