using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;
using XFileHelper;

[CustomEditor(typeof(RayHitVisualizer))]
public class RayHitVisualizerEditor : Editor
{
    RayHitVisualizer Target;
    void OnEnable()
    {
        Target = (RayHitVisualizer)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("ClearAll"))
        {
            Target.ClearAll();
        }

        if (GUILayout.Button("ClearAllLines"))
        {
            Target.ClearAllLines();
        }

    }
}
