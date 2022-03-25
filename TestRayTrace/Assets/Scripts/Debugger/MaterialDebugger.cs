using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static XCUnityUtility.MaterialFuncs;

public class MaterialDebugger : MonoBehaviour
{
    public MaterialReplaceTool replaceTool;
    public MaterialSlotReplaceTool slotReplaceTool;
    public IterativeMaterialReplaceTool iterReplaceTool;
    List<Material> oriMats = new List<Material>();
    public List<Material> oriSlots = new List<Material>();
    bool bNewMat = false;
    bool bNewMatSlot = false;
    bool bNewMatIter = false;
    void Start()
    {
        if (replaceTool)
        {
            for (int i = 0; i < replaceTool.replaceList.Count; i++)
            {
                oriMats.Add(SafeGetMaterial(replaceTool.replaceList[i].obj));
            }
        }

        if (slotReplaceTool)
        {
            for (int objInx = 0; objInx < slotReplaceTool.replaceList.Count; objInx++)
            {
                var obj = slotReplaceTool.replaceList[objInx].obj;
                var slots = slotReplaceTool.replaceList[objInx].newSlots;
                for (int i = 0; i < slots.Count; i++)
                {
                    oriSlots.Add(SafeGetMaterialSlot(obj, slots[i].slot));
                }
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnGUI()
    {
        if (replaceTool)
        {
            if (GUI.Button(new Rect(Screen.width * 0.1f, Screen.height * 0.1f, Screen.width * 0.1f, Screen.height * 0.1f), "toggleMat"))
            {
                ToggleMat();
            }
        }

        if (slotReplaceTool)
        {
            if (GUI.Button(new Rect(Screen.width * 0.1f, Screen.height * 0.1f*2, Screen.width * 0.1f, Screen.height * 0.1f), "toggleMatSlot"))
            {
                ToggleMatSlot();
            }
        }

        if (iterReplaceTool)
        {
            if (GUI.Button(new Rect(Screen.width * 0.1f, Screen.height * 0.1f * 3, Screen.width * 0.1f, Screen.height * 0.1f), "toggleMatIterative"))
            {
                ToggleMatIterative();
            }
        }
    }
    //#################################################################
    void ToggleMat()
    {
        if (bNewMat)
        {
            replaceTool.DoReplace(oriMats);
        }
        else
        {
            replaceTool.DoReplace();
        }
        bNewMat = !bNewMat;
    }

    void ToggleMatSlot()
    {
        if (bNewMatSlot)
        {
            slotReplaceTool.DoReplace(oriSlots);
        }
        else
        {
            slotReplaceTool.DoReplace();
        }
        bNewMatSlot = !bNewMatSlot;
    }

    void ToggleMatIterative()
    {
        if (bNewMatIter)
        {
            iterReplaceTool.DoReverseReplace();
        }
        else
        {
            iterReplaceTool.DoReplace();
        }
        bNewMatIter = !bNewMatIter;
    }
}
