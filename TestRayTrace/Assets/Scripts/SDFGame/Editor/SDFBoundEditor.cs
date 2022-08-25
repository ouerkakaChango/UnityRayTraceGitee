using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFBound))]
public class SDFBoundEditor : Editor
{
    SDFBound Target;
    protected bool showInnerBound = false;
    protected bool showSharedBound = false;

    void OnEnable()
    {
        Target = (SDFBound)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        {
            var type = Target.centerStrategy;
            Vector3 newv = Vector3.zero;
            if (type == AnchorStrategy.CustomSet)
            {
                //Target.specialID = EditorGUILayout.IntField("SpecialID", Target.specialID);
                newv = EditorGUILayout.Vector3Field("center", Target.center);
            }
            else if (type == AnchorStrategy.ByObject)
            {
                //Target.fontCharacter = EditorGUILayout.TextField("Character",Target.fontCharacter.ToString())[0];
                newv = Target.transform.position;
            }
            else if (type == AnchorStrategy.LocalBase)
            {
                newv = Target.GetCenterByLocalBase();
            }

            //var newOffset = EditorGUILayout.Vector3Field("centerOffset", Target.centerOffset);
            //if(newOffset!=Target.centerOffset)
            //{
            //    Target.centerOffset = newOffset;
            //}

            newv = newv + Target.centerOffset;

            if (Target.center != newv)
            {
                Target.center = newv;
            }
        }

        {
            var type = Target.boundStrategy;
            if (type == SizeStrategy.CustomSet)
            {
                var newv = EditorGUILayout.Vector3Field("bound", Target.bound);
                if(Target.bound != newv)
                {
                    Target.bound = newv;
                }
            }
            else if (type == SizeStrategy.AutoIfPossible)
            {
                var newv = Target.TryGetAutoBound();
                if (Target.bound != newv)
                {
                    Target.bound = newv;
                }
            }
        }

        showInnerBound = EditorGUILayout.Foldout(showInnerBound, "InnerBound");
        if(showInnerBound)
        {
            SerializedProperty enableInnerBound = serializedObject.FindProperty("enableInnerBound");
            EditorGUILayout.PropertyField(enableInnerBound, new GUIContent("enableInnerBound"), true);
            SerializedProperty innerBoundRelativeScale = serializedObject.FindProperty("innerBoundRelativeScale");
            EditorGUILayout.PropertyField(innerBoundRelativeScale, new GUIContent("innerBoundRelativeScale"), true);
            SerializedProperty iDown = serializedObject.FindProperty("iDown");
            EditorGUILayout.PropertyField(iDown, new GUIContent("DownScale"), true);
        }

        if (Target.type == SDFBoundType.SharedBound)
        {
            showSharedBound = EditorGUILayout.Foldout(showSharedBound, "SharedBound");
            if(showSharedBound)
            {
                SerializedProperty sharedTags = serializedObject.FindProperty("sharedTags");
                EditorGUILayout.PropertyField(sharedTags, new GUIContent("sharedTags"), true);
            }
        }

        serializedObject.ApplyModifiedProperties();
    }
}
