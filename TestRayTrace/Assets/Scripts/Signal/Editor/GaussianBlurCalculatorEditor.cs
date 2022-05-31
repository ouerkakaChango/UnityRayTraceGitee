using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(GaussianBlurCalculator))]
public class GaussianBlurCalculatorEditor : Editor
{
    GaussianBlurCalculator Target;

    void OnEnable()
    {
        Target = (GaussianBlurCalculator)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if(GUILayout.Button("Calculate2D"))
        {
            Target.Calculate2D();
            Target.Print2D();
        }

        if(GUILayout.Button("CalculateSplit2D"))
        {
            Target.Calculate2D();
            Target.CalculateSplitFrom2D();
            Target.PrintSplit();
        }
    }
}
