using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;

[CustomEditor(typeof(SDFSliceBaker))]
public class SDFSliceBakerEditor : Editor
{
    SDFSliceBaker Target;

    void OnEnable()
    {
        Target = (SDFSliceBaker)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Bake"))
        {
            Target.Bake(); 
        }

        if (GUILayout.Button("SaveOutTex"))
        {
            TexHelper.SaveEXR(Target.outTex, "Assets", Target.outName);
        }

        if (GUILayout.Button("Clear"))
        {
            Target.Clear();
        }
    }
}
