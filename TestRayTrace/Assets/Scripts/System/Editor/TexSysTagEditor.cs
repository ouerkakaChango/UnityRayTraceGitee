using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(TexSysTag),true)]
public class TexSysTagEditor : Editor
{
    TexSysTag Target;
    protected static bool showDetailFoldout = true;
    void OnEnable()
    {
        Target = (TexSysTag)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        //1.ԭ��listGUI,����ʾ�ڲ�Ԫ��
        var list = serializedObject.FindProperty("pbrTextures");
        EditorGUILayout.PropertyField(list, new GUIContent("pbrTextures"), true);

        showDetailFoldout = EditorGUILayout.Foldout(showDetailFoldout, "Detail");
        if (showDetailFoldout)
        {
            //2 �ֶ���ʾ�ڲ�Ԫ��
            SerializedProperty pbrSP = serializedObject.FindProperty("pbrTextures");
            EditorShowPBRTextureList(serializedObject, Target.pbrTextures.Count, pbrSP);
        }
    }

    //###############################################################
    public static void EditorShowPBRTextureList(SerializedObject serializedObject,int listCount, SerializedProperty listSP)
    {//name,albedo,normal,metallic,roughness,ao;
        for (int i = 0; i < listCount; i++)
        {
            SerializedProperty nameSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("name");
            SerializedProperty albedoSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("albedo");
            SerializedProperty normalSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("normal");
            SerializedProperty metallicSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("metallic");
            SerializedProperty roughnessSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("roughness");
            SerializedProperty aoSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("ao");
            EditorGUI.BeginChangeCheck();

            EditorGUILayout.PropertyField(nameSP, true);
            EditorGUILayout.PropertyField(albedoSP, true);
            EditorGUILayout.PropertyField(normalSP, true);
            EditorGUILayout.PropertyField(metallicSP, true);
            EditorGUILayout.PropertyField(roughnessSP, true);
            EditorGUILayout.PropertyField(aoSP, true);

            EditorGUILayout.Space();
            if (EditorGUI.EndChangeCheck())
            {
                serializedObject.ApplyModifiedProperties();
            }
        }
    }
}