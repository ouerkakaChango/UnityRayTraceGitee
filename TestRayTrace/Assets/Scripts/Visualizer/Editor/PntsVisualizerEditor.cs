using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;
using XFileHelper;

[CustomEditor(typeof(PntsVisualizer))]
public class PntsVisualizerEditor : Editor
{
    PntsVisualizer Target;
    void OnEnable()
    {
        Target = (PntsVisualizer)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Clear"))
        {
            Target.Clear();
        }

    }
}
