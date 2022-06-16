using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(ShaderConverter))]
public class ShaderConverterEditor : Editor
{
    ShaderConverter Target;
    Vector2 scroll_ori;
    Vector2 scroll_out;

    void OnEnable()
    {
        Target = (ShaderConverter)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        GUILayout.Label("OriCode");
        scroll_ori = EditorGUILayout.BeginScrollView(scroll_ori, GUILayout.Height(150));
        Target.oriString = EditorGUILayout.TextArea(Target.oriString, GUILayout.ExpandHeight(true));
        EditorGUILayout.EndScrollView();

        if (GUILayout.Button("AutoConvert"))
        {
            Target.AutoConvert();
        }

        GUILayout.Label("OutputCode");
        scroll_out = EditorGUILayout.BeginScrollView(scroll_out, GUILayout.Height(150));
        Target.outString = EditorGUILayout.TextArea(Target.outString, GUILayout.ExpandHeight(true));
        EditorGUILayout.EndScrollView();
    }
}
