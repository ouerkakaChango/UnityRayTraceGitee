using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;

[CustomEditor(typeof(SDFShadowBaker))]
public class SDFShadowBakerEditor : Editor
{
    SDFShadowBaker Target;
    void OnEnable()
    {
        Target = (SDFShadowBaker)target;
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
