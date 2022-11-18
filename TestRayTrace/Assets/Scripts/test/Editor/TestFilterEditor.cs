using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(TestFilter))]
public class TestFilterEditor : Editor
{
    protected TestFilter Target;
    void OnEnable()
    {
        Target = (TestFilter)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Process"))
        {
            Target.Process();
        }
    }
}
