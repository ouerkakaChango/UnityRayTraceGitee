using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFBakerTag))]
public class SDFBakerTagEditor : Editor
{
    SDFBakerTag Target;
    protected bool showMergeTag = false;
    protected bool showExtraTag = false;

    void OnEnable()
    {
        Target = (SDFBakerTag)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        var type = Target.shapeType;
        if(type == SDFShapeType.Special)
        {
            var nid = EditorGUILayout.IntField("SpecialID", Target.specialID);
            if(nid!=Target.specialID)
            {
                Undo.RecordObject(Target, "SpecialID");
                Target.specialID = nid;
            }
        }
        else if(type == SDFShapeType.Font)
        {
            if (Target.fontCharacter.ToString().Length > 0)
            {
                char nc = EditorGUILayout.TextField("Character", Target.fontCharacter.ToString())[0];
                if (nc != Target.fontCharacter)
                {
                    Undo.RecordObject(Target, "Character");
                    Target.fontCharacter = nc;
                }
            }
        }
        else if(type == SDFShapeType.Slice)
        {
            SerializedProperty sliceTexTag = serializedObject.FindProperty("sliceTexTag");
            EditorGUILayout.PropertyField(sliceTexTag, new GUIContent("sliceTexTag"), true);

            SerializedProperty hBound = serializedObject.FindProperty("hBound");
            EditorGUILayout.PropertyField(hBound, new GUIContent("hBound"), true);

            SerializedProperty SDF_offset2D = serializedObject.FindProperty("SDF_offset2D");
            EditorGUILayout.PropertyField(SDF_offset2D, new GUIContent("SDF_offset2D"), true);
        }

        showMergeTag = EditorGUILayout.Foldout(showMergeTag, "Merge");
        if (showMergeTag)
        {
            SDFMergeType nType = (SDFMergeType)EditorGUILayout.EnumPopup("MergeType",Target.mergeType);
            if(nType!=Target.mergeType)
            {
                Undo.RecordObject(Target, "MergeType");
                Target.mergeType = nType;
            }
        }
        showExtraTag = EditorGUILayout.Foldout(showExtraTag, "Extra");
        if (showExtraTag)
        {
            SerializedProperty needExtraCondition = serializedObject.FindProperty("needExtraCondition");
            EditorGUILayout.PropertyField(needExtraCondition, new GUIContent("needExtraCondition"), true);

            SerializedProperty extraCondition = serializedObject.FindProperty("extraCondition");
            EditorGUILayout.PropertyField(extraCondition, new GUIContent("extraCondition"), true);
        }
        serializedObject.ApplyModifiedProperties();

    }
}
