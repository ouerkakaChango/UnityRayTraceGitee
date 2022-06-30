using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Spline;

[CustomEditor(typeof(QuadBezierSpline))]
public class QuadBezierSplineEditor : Editor
{
    QuadBezierSpline Target;

    protected bool showShapeFoldout = true;

    void OnEnable()
    {
        Target = (QuadBezierSpline)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        showShapeFoldout = EditorGUILayout.Foldout(showShapeFoldout, "ShapeDetail");
        if(showShapeFoldout)
        {
            if(Target.shape == SpineShapeType.Boxed)
            {
                Target.boxShapeSize = EditorGUILayout.Vector2Field("size", Target.boxShapeSize);
            }
        }

    }
}