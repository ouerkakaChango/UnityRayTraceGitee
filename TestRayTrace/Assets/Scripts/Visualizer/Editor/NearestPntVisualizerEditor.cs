using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;
using XFileHelper;

[CustomEditor(typeof(NearestPntVisualizer))]
public class NearestPntVisualizerEditor : Editor
{
    NearestPntVisualizer Target;
    void OnEnable()
    {
        Target = (NearestPntVisualizer)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("CosFBM"))
        {
            Target.CosFBM();
        }

    }
}
