using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Signal1D))]
public class Signal1DEditor : Editor
{
    Signal1D Target;

    protected bool showGenerateFoldout = true;
    protected bool showResampleFoldout = true;
    protected bool showVisualizeFoldout = true;

    void OnEnable()
    {
        Target = (Signal1D)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        //########
        //Generate
        showGenerateFoldout = EditorGUILayout.Foldout(showGenerateFoldout, "Generate");
        if (showGenerateFoldout)
        {
            if (GUILayout.Button("Rand"))
            {
                Target.GenerateRand();
            }
        }

        //########
        //Resample
        showResampleFoldout = EditorGUILayout.Foldout(showResampleFoldout, "Resample");
        if (showResampleFoldout)
        {
            if (GUILayout.Button("Lanczos"))
            {
                Target.Resample(ResampleType.Lanczos);
            }

            if (GUILayout.Button("FSRLanczos"))
            {
                Target.Resample(ResampleType.FSRLanczos);
            }
        }

        //########
        //Visualize
        showVisualizeFoldout = EditorGUILayout.Foldout(showVisualizeFoldout, "Visualize");
        if (showVisualizeFoldout)
        {
            if (GUILayout.Button("CheckVisualize"))
            {
                Target.CheckVisualize();
            }
            Target.v_heightScale = EditorGUILayout.FloatField("heightScale", Target.v_heightScale);
        }
    }
}
