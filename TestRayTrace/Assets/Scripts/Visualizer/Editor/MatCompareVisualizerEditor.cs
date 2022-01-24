using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(MatCompareVisualizer))]
public class MatCompareVisualizerEditor : Editor
{
    MatCompareVisualizer Target;
    void OnEnable()
    {
        Target = (MatCompareVisualizer)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Generate"))
        {
            Target.Generate();
        }

        if (GUILayout.Button("Clear"))
        {
            Target.Clear();
        }
    }
}
