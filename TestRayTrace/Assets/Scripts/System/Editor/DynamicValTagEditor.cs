using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(DynamicValTag),true)]
public class DynamicValTagEditor : Editor
{
    DynamicValTag Target;
    protected static bool showDetailFoldout = true;
    void OnEnable()
    {
        Target = (DynamicValTag)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
       
        {
            var floatVals = serializedObject.FindProperty("floatVals");
            EditorGUILayout.PropertyField(floatVals, new GUIContent("floatVals"), true);
            //showDetailFoldout = EditorGUILayout.Foldout(showDetailFoldout, "Detail");
            //if (showDetailFoldout)
            {
                EditorShowDynamicFloatList(serializedObject, Target.floatVals.Count, floatVals);
            }
        }

        serializedObject.ApplyModifiedProperties();
    }

    //###############################################################
    public static void EditorShowDynamicFloatList(SerializedObject serializedObject, int listCount, SerializedProperty listSP)
    {//type name val cv
        for (int i = 0; i < listCount; i++)
        {
            var elem = listSP.GetArrayElementAtIndex(i);
            SerializedProperty type = elem.FindPropertyRelative("type");
            SerializedProperty name = elem.FindPropertyRelative("name");

            EditorGUI.BeginChangeCheck();

            EditorGUILayout.PropertyField(name, true);
            EditorGUILayout.PropertyField(type, true);
            var arr = System.Enum.GetValues(typeof(DynamicType));
            DynamicType typeval = (DynamicType)arr.GetValue(type.enumValueIndex);
            if(typeval == DynamicType.Default)
            {
                SerializedProperty val = elem.FindPropertyRelative("val");
                EditorGUILayout.PropertyField(val, true);
            }
            else if (typeval == DynamicType.Curve)
            {
                SerializedProperty cv = elem.FindPropertyRelative("cv");
                EditorGUILayout.PropertyField(cv, true);
            }

            EditorGUILayout.Space();
            if (EditorGUI.EndChangeCheck())
            {
                serializedObject.ApplyModifiedProperties();
            }
        }
    }

}
