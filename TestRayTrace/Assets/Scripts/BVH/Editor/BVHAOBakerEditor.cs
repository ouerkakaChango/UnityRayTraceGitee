using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;
using XFileHelper;

[CustomEditor(typeof(BVHAOBaker))]
public class BVHAOBakerEditor : Editor
{
    BVHAOBaker Target;
    void OnEnable()
    {
        Target = (BVHAOBaker)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Bake"))
        {
            Target.Bake();
        }
    }
}
