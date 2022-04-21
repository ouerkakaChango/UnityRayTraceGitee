using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFBakerMgr))]
public class SDFBakerMgrEditor : Editor
{
    SDFBakerMgr Target;
    void OnEnable()
    {
        Target = (SDFBakerMgr)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Bake"))
        {
            Target.Bake();
        }

        if (GUILayout.Button("Hide/Show Transform"))
        {
            Target.ToggleHideTransform();
        }
    }
}
