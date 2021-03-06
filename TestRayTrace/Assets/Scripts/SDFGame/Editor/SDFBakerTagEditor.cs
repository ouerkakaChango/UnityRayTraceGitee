using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFBakerTag))]
public class SDFBakerTagEditor : Editor
{
    SDFBakerTag Target;
    protected bool showMergeTag = true;
    //showMergeTag = EditorGUILayout.Foldout(showMergeTag, "MergeSetting");
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
    }
}
