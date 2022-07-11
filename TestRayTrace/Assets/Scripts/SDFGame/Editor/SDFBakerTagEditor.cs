using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFBakerTag))]
public class SDFBakerTagEditor : Editor
{
    SDFBakerTag Target;
    //protected bool showBakeFoldout = true;
    //showBakeFoldout = EditorGUILayout.Foldout(showBakeFoldout, "Bake");
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
            Target.specialID = EditorGUILayout.IntField("SpecialID", Target.specialID);
        }
        else if(type == SDFShapeType.Font)
        {
            Target.fontCharacter = EditorGUILayout.TextField("Character",Target.fontCharacter.ToString())[0];
        }
    }
}
