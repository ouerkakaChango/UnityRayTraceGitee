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
        if (GUILayout.Button("InitGrid"))
        {
            Target.InitGrid();
        }

        if (GUILayout.Button("TestTrace"))
        {
            Target.TestTrace();
        }

        if (GUILayout.Button("TestSaveStandardSphere"))
        {
            Target.TestSaveStandardSphere();
            AssetDatabase.Refresh();
        }

        //if (GUILayout.Button("Bake"))
        //{
        //    Target.Bake();
        //}

        if (GUILayout.Button("BakeGPU"))
        {
            Target.BakeGPU();
        }

        if (GUILayout.Button("Save"))
        {
            Target.Save();
            AssetDatabase.Refresh();
        }

        if (GUILayout.Button("Parse"))
        {
            Target.Parse();
        }
    }
}
