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

        if (Target.type == TexTagType.pbrTexture)
        {
            //1.原生listGUI,不显示内部元素
            var list = serializedObject.FindProperty("pbrTextures");
            EditorGUILayout.PropertyField(list, new GUIContent("pbrTextures"), true);

            showDetailFoldout = EditorGUILayout.Foldout(showDetailFoldout, "Detail");
            if (showDetailFoldout)
            {
                //2 手动显示内部元素
                SerializedProperty listSP = serializedObject.FindProperty("pbrTextures");
                EditorShowPBRTextureList(serializedObject, Target.pbrTextures.Count, listSP);
            }
        }
        else if (Target.type == TexTagType.heightTextue)
        {
            var list = serializedObject.FindProperty("heightTextures");
            EditorGUILayout.PropertyField(list, new GUIContent("heightTextures"), true);

            showDetailFoldout = EditorGUILayout.Foldout(showDetailFoldout, "Detail");
            if(showDetailFoldout)
            {
                SerializedProperty listSP = serializedObject.FindProperty("heightTextures");
                EditorShowHeightTextureList(serializedObject, Target.heightTextures.Count, listSP);
            }
        }
        else if (Target.type == TexTagType.plainTexture)
        {
            var list = serializedObject.FindProperty("plainTextures");
            EditorGUILayout.PropertyField(list, new GUIContent("plainTextures"), true);
            showDetailFoldout = EditorGUILayout.Foldout(showDetailFoldout, "Detail");
            if (showDetailFoldout)
            {
                SerializedProperty listSP = serializedObject.FindProperty("plainTextures");
                EditorShowPlainTextureList(serializedObject, Target.plainTextures.Count, listSP);
            }
        }
        else if (Target.type == TexTagType.envTexture)
        {
            var listSP = serializedObject.FindProperty("envTextures");
            EditorGUILayout.PropertyField(listSP, new GUIContent("envTextures"), true);
            showDetailFoldout = EditorGUILayout.Foldout(showDetailFoldout, "Detail");
            if (showDetailFoldout)
            {
                EditorShowEnvTextureList(serializedObject, Target.envTextures.Count, listSP);
            }
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

    public static void EditorShowHeightTextureList(SerializedObject serializedObject, int listCount, SerializedProperty listSP)
    {//name,height,grad,(bound?)
        for (int i = 0; i < listCount; i++)
        {
            SerializedProperty nameSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("name");
            SerializedProperty heightSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("height");
            SerializedProperty gradSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("grad");

            EditorGUI.BeginChangeCheck();

            EditorGUILayout.PropertyField(nameSP, true);
            EditorGUILayout.PropertyField(heightSP, true);
            EditorGUILayout.PropertyField(gradSP, true);

            EditorGUILayout.Space();
            if (EditorGUI.EndChangeCheck())
            {
                serializedObject.ApplyModifiedProperties();
            }
        }
    }

    public static void EditorShowPlainTextureList(SerializedObject serializedObject, int listCount, SerializedProperty listSP)
    {//name,height,grad,(bound?)
        for (int i = 0; i < listCount; i++)
        {
            SerializedProperty nameSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("name");
            SerializedProperty texSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("tex");
            SerializedProperty channelSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("channel");

            EditorGUI.BeginChangeCheck();

            EditorGUILayout.PropertyField(nameSP, true);
            EditorGUILayout.PropertyField(texSP, true);
            EditorGUILayout.PropertyField(channelSP, true);

            EditorGUILayout.Space();
            if (EditorGUI.EndChangeCheck())
            {
                serializedObject.ApplyModifiedProperties();
            }
        }
    }

    public static void EditorShowEnvTextureList(SerializedObject serializedObject, int listCount, SerializedProperty listSP)
    {//name,height,grad,(bound?)
        for (int i = 0; i < listCount; i++)
        {
            SerializedProperty nameSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("name");
            SerializedProperty texSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("tex");
            SerializedProperty isPNGEnvSP = listSP.GetArrayElementAtIndex(i).FindPropertyRelative("isPNGEnv");

            EditorGUI.BeginChangeCheck();

            EditorGUILayout.PropertyField(nameSP, true);
            EditorGUILayout.PropertyField(texSP, true);
            EditorGUILayout.PropertyField(isPNGEnvSP, true);

            EditorGUILayout.Space();
            if (EditorGUI.EndChangeCheck())
            {
                serializedObject.ApplyModifiedProperties();
            }
        }
    }

}
