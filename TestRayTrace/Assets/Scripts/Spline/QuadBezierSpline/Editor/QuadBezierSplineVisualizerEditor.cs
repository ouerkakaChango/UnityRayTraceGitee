using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(QuadBezierSplineVisualizer))]
public class QuadBezierSplineVisualizerEditor : Editor
{
    QuadBezierSplineVisualizer Target;
    void OnEnable()
    {
        Target = (QuadBezierSplineVisualizer)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Init"))
        {
            Target.Init();
        }

        if (GUILayout.Button("ShowKeys"))
        {
            Target.ShowKeys();
        }

        if (GUILayout.Button("ShowKeys3D"))
        {
            Target.ShowKeys3D();
        }
    }
}