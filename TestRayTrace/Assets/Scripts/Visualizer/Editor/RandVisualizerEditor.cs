using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;
using XFileHelper;

[CustomEditor(typeof(RandVisualizer))]
public class RandVisualizerEditor : Editor
{
    RandVisualizer Target;
    void OnEnable()
    {
        Target = (RandVisualizer)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("RandSphere"))
        {
            Target.RandSphere();
        }

    }
}
