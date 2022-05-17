using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(CosFBM))]
public class CosFBMEditor : Editor
{
    CosFBM Target;

    //protected bool showGenerateFoldout = true;
    //protected bool showResampleFoldout = true;
    protected bool showVisualizeFoldout = true;
    protected bool showBakeFoldout = true;

    void OnEnable()
    {
        Target = (CosFBM)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        //########
        //Generate
        //showGenerateFoldout = EditorGUILayout.Foldout(showGenerateFoldout, "Init");
        //if (showGenerateFoldout)
        //{
        //    if (GUILayout.Button("Init"))
        //    {
        //
        //        //Target.GenerateRand();
        //    }
        //}

        //########
        //Resample
        //showResampleFoldout = EditorGUILayout.Foldout(showResampleFoldout, "Resample");
        //if (showResampleFoldout)
        //{
        //    if (GUILayout.Button("Lanczos"))
        //    {
        //        //Target.Resample(ResampleType.Lanczos);
        //    }
        //
        //    if (GUILayout.Button("FSRLanczos"))
        //    {
        //        //Target.Resample(ResampleType.FSRLanczos);
        //    }
        //}

        //########
        //Visualize
        showVisualizeFoldout = EditorGUILayout.Foldout(showVisualizeFoldout, "Visualize");
        if (showVisualizeFoldout)
        {
            if (GUILayout.Button("VisualizeByBound"))
            {
                Target.VisualizeByBound();
            }
        }

        showBakeFoldout = EditorGUILayout.Foldout(showBakeFoldout, "Bake");
        if (showBakeFoldout)
        {
            if (GUILayout.Button("BakeHLSLCode"))
            {
                Target.BakeHLSLCode();
            }
            if (GUILayout.Button("BakeHLSLCodeWithTexture"))
            {
                if (Target.BakeHeightTex())
                {
                    Target.BakeHLSLCode(true);
                }
            }
            GUILayout.TextArea(Target.GetBakedHLSLString());
        }
    }
}
