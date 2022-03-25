using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static XCUnityUtility.MaterialFuncs;

public class MaterialDebugger : MonoBehaviour
{
    public MaterialReplaceTool replaceTool;
    List<Material> oriMats = new List<Material>();
    bool bNewMat = false;
    void Start()
    {
        for (int i = 0; i < replaceTool.replaceList.Count; i++)
        {
            oriMats.Add(SafeGetMaterial(replaceTool.replaceList[i].obj));
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
}
