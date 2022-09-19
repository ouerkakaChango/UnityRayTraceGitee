using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

using System.Linq;

[CustomEditor(typeof(SDFPrefabBaker))]
public class SDFPrefabBakerEditor : Editor
{
    SDFPrefabBaker Target;
    protected bool showLines = false;
    protected bool showBakeFoldout = true;
    protected bool showBakeSpecialFoldout = false;
    protected bool showBakeGroupFoldout = false;

    void OnEnable()
    {
        Target = (SDFPrefabBaker)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        showLines = EditorGUILayout.Foldout(showLines, "Lines:");
        if (showLines)
        {
            GUILayout.TextArea(Target.GetTotalString());
        }

        if (GUILayout.Button("Add Bake To hlsl"))
        {
            if (EditorUtility.DisplayDialog("confirm", "\'OK\' to continue", "ok", "cancel"))
            {
                Target.AddBakeToHLSL();
            }
        }

        if (GUILayout.Button("Dump All To hlsl"))
        {
            if (EditorUtility.DisplayDialog("confirm", "Are you sure? This will clear any prefab before.", "ok", "cancel"))
            {
                Target.DumpAllToHLSL();
            }
        }

        showBakeFoldout = EditorGUILayout.Foldout(showBakeFoldout, "Now Baked:");
        if (showBakeFoldout)
        {
            EditorGUI.BeginChangeCheck();
            var prefabs = serializedObject.FindProperty("prefabs");
            EditorShowSDFPrefabList(serializedObject, Target.prefabs.Count, prefabs);
            if (GUILayout.Button("Clear now baked prefabs"))
            {
                Target.Clear();
                EditorUtility.SetDirty(Target);
            }
        }

        showBakeSpecialFoldout = EditorGUILayout.Foldout(showBakeSpecialFoldout, "BakeSpcecial");
        if (showBakeSpecialFoldout)
        {
            //Target.specialID = EditorGUILayout.IntField("SpecialID", Target.specialID);
            var nid = EditorGUILayout.IntField("SpecialID", Target.specialID);
            if (nid != Target.specialID)
            {
                Undo.RecordObject(Target, "SpecialID");
                Target.specialID = nid;
            }
            if (GUILayout.Button("BakeSpecial"))
            {
                Target.BakeSpecial();
                EditorUtility.SetDirty(Target);
            }
        }

        showBakeGroupFoldout = EditorGUILayout.Foldout(showBakeGroupFoldout, "BakeGroup");
        if (showBakeGroupFoldout)
        {
            var groups = serializedObject.FindProperty("groups");
            EditorGUILayout.PropertyField(groups, new GUIContent("groups"), true);

            var nName = EditorGUILayout.TextField("name", Target.groupPrefabName);
            if(nName!=Target.groupPrefabName)
            {
                Undo.RecordObject(Target, "groupPrefabName");
                Target.groupPrefabName = nName;
            }

            if (GUILayout.Button("BakeGroup"))
            {
                Target.BakeGroup();
                EditorUtility.SetDirty(Target);
            }
        }

        //EditorGUI.BeginChangeCheck();
        //EditorGUI.EndChangeCheck();
        //serializedObject.ApplyModifiedProperties() 
        //EditorUtility.SetDirty(Target);
    }
    //########################################
    public static void EditorShowSDFPrefabList(SerializedObject serializedObject, int listCount, SerializedProperty listSP)
    {
        for (int i = 0; i < listCount; i++)
        {
            SerializedProperty nameSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("prefabName");

            EditorGUI.BeginChangeCheck();

            //EditorGUILayout.PropertyField(nameSP, true);
            EditorGUILayout.LabelField(nameSP.stringValue);

            EditorGUILayout.Space();
            if (EditorGUI.EndChangeCheck())
            {
                serializedObject.ApplyModifiedProperties();
            }
        }
    }
}
