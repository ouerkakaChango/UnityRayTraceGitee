using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(IBLSpecBaker))]
public class IBLSpecBakerEditor : Editor
{
    IBLSpecBaker Target;
    void OnEnable()
    {
        Target = (IBLSpecBaker)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("BakeSingle"))
        {
            Target.BakeSingle();
            AssetDatabase.Refresh();
        }
    }
}