using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFText))]
public class SDFTextEditor : Editor
{
    SDFText Target;
    string testShowBakeResult;
    void OnEnable()
    {
        Target = (SDFText)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("TestShowBake"))
        {
            testShowBakeResult = Target.GetBakeCode();
       
        }
        testShowBakeResult = GUILayout.TextArea(testShowBakeResult);
    }
}
