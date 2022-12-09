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

        GUILayout.Label("Expression");
        var expression = serializedObject.FindProperty("expressionStr");
        var newStr = GUILayout.TextArea(expression.stringValue);
        if(newStr!=expression.stringValue)
        {
            expression.stringValue = newStr;
        }

        GUILayout.Label("PostExpression");
        var postExpressionStr = serializedObject.FindProperty("postExpressionStr");
        newStr = GUILayout.TextArea(postExpressionStr.stringValue);
        if (newStr != postExpressionStr.stringValue)
        {
            postExpressionStr.stringValue = newStr;
        }

        if (EditorGUI.EndChangeCheck())
        {
            serializedObject.ApplyModifiedProperties();
        }
    }
}
