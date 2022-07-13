using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

using System.Linq;

[CustomEditor(typeof(SDFPrefabBaker))]
public class SDFPrefabBakerEditor : Editor
{
    SDFPrefabBaker Target;
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

        if (GUILayout.Button("Dump All To hlsl"))
        {
            if (EditorUtility.DisplayDialog("confirm", "Are you sure? This will clear any prefab before.", "ok", "cancel"))
            {
                Target.DumpAllToHLSL();
            }
        }

        if (GUILayout.Button("Clear now baked prefabs"))
        {
            Target.Clear();
        }

        showBakeFoldout = EditorGUILayout.Foldout(showBakeFoldout, "Now Baked:");
        if (showBakeFoldout)
        {
            var prefabs = serializedObject.FindProperty("prefabs");
            //if (prefabs != null)
            {
                EditorGUILayout.PropertyField(prefabs, new GUIContent("prefabs"), true);
            }
        }

        showBakeSpecialFoldout = EditorGUILayout.Foldout(showBakeSpecialFoldout, "BakeSpcecial");
        if (showBakeSpecialFoldout)
        {
            Target.specialID = EditorGUILayout.IntField("SpecialID", Target.specialID);
            if (GUILayout.Button("BakeSpecial"))
            {
                Target.BakeSpecial();
            }
        }

        showBakeGroupFoldout = EditorGUILayout.Foldout(showBakeGroupFoldout, "BakeGroup");
        if (showBakeGroupFoldout)
        {
            var groups = serializedObject.FindProperty("groups");
            EditorGUILayout.PropertyField(groups, new GUIContent("groups"), true);
            Target.groupPrefabName = EditorGUILayout.TextField("name", Target.groupPrefabName);
            if (GUILayout.Button("BakeGroup"))
            {
                Target.BakeGroup();
            }
        }
    }
}
