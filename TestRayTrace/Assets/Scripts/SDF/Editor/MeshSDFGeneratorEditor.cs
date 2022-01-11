using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;

[CustomEditor(typeof(MeshSDFGenerator))]
public class MeshSDFGeneratorEditor : Editor
{
    MeshSDFGenerator Target;
    void OnEnable()
    {
        Target = (MeshSDFGenerator)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("Generate"))
        {
            Target.Generate();
        }
    }
}
