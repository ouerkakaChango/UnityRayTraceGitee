using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFSliceGizmo))]
public class SDFSliceGizmoEditor : Editor
{
    SDFSliceGizmo Target;
    string testShowBakeResult;
    void OnEnable()
    {
        Target = (SDFSliceGizmo)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Refresh"))
        {
            Target.Refresh();
        
        }
    }
}
