using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MaterialUtility.MaterialFuncs;

[System.Serializable]
public struct MatSlot
{
    public int slot;
    public Material mat;
};
[System.Serializable]
public struct MatSlotReplace
{
    public GameObject obj;
    public List<MatSlot> newSlots;
}
public class MaterialSlotReplaceTool : MonoBehaviour
{
    public List<MatSlotReplace> replaceList;
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
            var list = replaceList[i].newSlots;
            for (int i1 = 0; i1 < list.Count; i1++)
            {
                SafeSetMaterialSlot(obj, list[i1].slot, list[i1].mat);
            }
        }
    }

    public void DoReplace(List<Material> mats)
    {
        int inx = 0;
        for (int i = 0; i < replaceList.Count; i++)
        {
            var obj = replaceList[i].obj;
            var list = replaceList[i].newSlots;
            for (int i1 = 0; i1 < list.Count; i1++)
            {
                SafeSetMaterialSlot(obj, list[i1].slot, mats[inx]);
                inx++;
            }
        }
    }
}
