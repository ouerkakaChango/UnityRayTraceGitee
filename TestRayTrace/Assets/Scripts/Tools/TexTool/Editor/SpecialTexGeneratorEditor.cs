using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;

[CustomEditor(typeof(SpecialTexGenerator))]
public class SpecialTexGeneratorEditor : Editor
{
    SpecialTexGenerator Target;
    void OnEnable()
    {
        Target = (SpecialTexGenerator)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("GenerateShiftTex"))
        {
            Debug.Log("Generate");
            Target.CreateShiftTex();
            TexHelper.SavePNG(Target.outTex, "Assets","shiftTex");
        }

        if (GUILayout.Button("GenerateAlphaMask"))
        {
            Debug.Log("Generate");
            Target.CreateAlphaMask();
            TexHelper.SavePNG(Target.outTex, "Assets", "alphaMask");
        }
    }
}
