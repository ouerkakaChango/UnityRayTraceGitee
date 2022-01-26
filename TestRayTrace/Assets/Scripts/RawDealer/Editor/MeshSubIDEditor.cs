using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(MeshSubIDTool))]
public class MeshSubIDToolEditor : Editor
{
    MeshSubIDTool Target;
    void OnEnable()
    {
        Target = (MeshSubIDTool)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("ShowSubID_pnts"))
        {
            //Target.Generate();
            Target.Init();
            Target.ShowPointsOfID(1);
        }

    }
}
