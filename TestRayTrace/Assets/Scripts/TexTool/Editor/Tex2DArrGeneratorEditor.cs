using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Tex2DArrGenerator))]
public class Tex2DArrGeneratorEditor : Editor
{
    Tex2DArrGenerator Target;
    void OnEnable()
    {
        Target = (Tex2DArrGenerator)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("Generate"))
        {
            Debug.Log("Generate");
            Target.CreateTexArray();
            if (Target.outTex2DArr != null)
            {
                //Save 
                AssetDatabase.CreateAsset(Target.outTex2DArr, Target.savePath);
                AssetDatabase.Refresh();
            }
        }
    }
}
