using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;
using XFileHelper;

[CustomEditor(typeof(BVHShadowBaker))]
public class BVHShadowBakerEditor : Editor
{
    BVHShadowBaker Target;
    void OnEnable()
    {
        Target = (BVHShadowBaker)target;
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
