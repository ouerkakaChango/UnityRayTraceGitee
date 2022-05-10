using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(CosFBM))]
public class CosFBMEditor : Editor
{
    CosFBM Target;

    protected bool showGenerateFoldout = true;
    protected bool showResampleFoldout = true;
    protected bool showVisualizeFoldout = true;

    Vector2 bound = new Vector2(0,0);
    float delta = 0.1f;

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
            bound = EditorGUILayout.Vector2Field("bound", bound);
            delta = EditorGUILayout.FloatField("delta", delta);
            if (GUILayout.Button("VisualizeByBound"))
            {
                Target.VisualizeByBound(bound, delta);
            }
            //Target.v_heightScale = EditorGUILayout.FloatField("heightScale", Target.v_heightScale);
        }
    }
}
