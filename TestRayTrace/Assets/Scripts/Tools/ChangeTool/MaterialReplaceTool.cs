using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MaterialUtility.MaterialFuncs;

[System.Serializable]
public struct MatReplace
{
    public GameObject obj;
    public Material mat;
}
public class MaterialReplaceTool : MonoBehaviour
{
    public List<MatReplace> replaceList;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void DoReplace()
    {
        for (int i = 0; i < replaceList.Count; i++)
        {
            var obj = replaceList[i].obj;
            var mat = replaceList[i].mat;
            SafeSetMaterial(obj, mat);
        }
    }

    public void DoReplace(List<Material> mats)
    {
        if (mats.Count != replaceList.Count)
        {
            Debug.LogError("replace num not match");
            return;
        }
        for (int i = 0; i < replaceList.Count; i++)
        {
            var obj = replaceList[i].obj;
            SafeSetMaterial(obj, mats[i]);
        }
    }
}
