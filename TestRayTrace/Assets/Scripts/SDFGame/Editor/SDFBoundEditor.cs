using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFBound))]
public class SDFBoundEditor : Editor
{
    SDFBound Target;
    //protected bool showBakeFoldout = true;
    //showBakeFoldout = EditorGUILayout.Foldout(showBakeFoldout, "Bake");
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
            if (type == AnchorStrategy.CustomSet)
            {
                //Target.specialID = EditorGUILayout.IntField("SpecialID", Target.specialID);
                Target.center = EditorGUILayout.Vector3Field("center", Target.center);
            }
            else if (type == AnchorStrategy.ByObject)
            {
                //Target.fontCharacter = EditorGUILayout.TextField("Character",Target.fontCharacter.ToString())[0];
                Target.center = Target.transform.position;
            }
        }

        {
            var type = Target.boundStrategy;
            if (type == SizeStrategy.CustomSet)
            {
                Target.bound = EditorGUILayout.Vector3Field("bound", Target.bound);
            }
            else if (type == SizeStrategy.AutoIfPossible)
            {
                Target.bound = Target.TryGetAutoBound();
            }
        }
    }
}
