using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFBakerExpression))]
public class SDFBakerExpressionEditor : Editor
{
    SDFBakerExpression Target;
    string testShowBakeResult;
    void OnEnable()
    {
        Target = (SDFBakerExpression)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        //if (GUILayout.Button("TestShowBake"))
        //{
        //    testShowBakeResult = Target.GetBakeCode();
        //
        //}
        var expression = serializedObject.FindProperty("expressionStr");
        GUILayout.Label("Expression");
        var newStr = GUILayout.TextArea(expression.stringValue);
        if(newStr!=expression.stringValue)
        {
            expression.stringValue = newStr;
        }
        if (EditorGUI.EndChangeCheck())
        {
            serializedObject.ApplyModifiedProperties();
        }
    }
}
