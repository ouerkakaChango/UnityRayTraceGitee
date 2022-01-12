using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;
using XFileHelper;

[CustomEditor(typeof(BVHTool))]
public class BVHToolEditor : Editor
{
    BVHTool Target;
    void OnEnable()
    {
        Target = (BVHTool)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("GenerateBVH"))
        {
            //Target.Generate();
            var meshFiliter = Target.gameObject.GetComponent<MeshFilter>();
            var mesh = meshFiliter.sharedMesh;
            Debug.Log(mesh.vertices.Length);
            Debug.Log(mesh.triangles.Length);
            Target.Init();
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

        if (GUILayout.Button("Test"))
        {
            Target.Test();
        }
    }
}
