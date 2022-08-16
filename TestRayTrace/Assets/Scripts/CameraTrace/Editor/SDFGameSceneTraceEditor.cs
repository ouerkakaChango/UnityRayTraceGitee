using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFGameSceneTrace))]
public class SDFGameSceneTraceEditor : Editor
{
    protected SDFGameSceneTrace Target;
    void OnEnable()
    {
        Target = (SDFGameSceneTrace)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Refresh autoCS"))
        {
            Target.RefreshAutoCS();
            AssetDatabase.Refresh();
        }
    }
}
