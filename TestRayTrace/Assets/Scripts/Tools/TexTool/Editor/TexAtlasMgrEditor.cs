using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;

[CustomEditor(typeof(TexAtlasMgr))]
public class TexAtlasMgrEditor : Editor
{
    TexAtlasMgr Target;
    void OnEnable()
    {
        Target = (TexAtlasMgr)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("LoadFromFolder"))
        {
            Target.LoadFromFolder();
        }

        if(GUILayout.Button("PackAtlas"))
        {
            Target.PackAtlas();
        }

        if(GUILayout.Button("SaveOutTex"))
        {
            Target.SaveOutTex();
            AssetDatabase.Refresh();
        }

        if(GUILayout.Button("ClearAll"))
        {
            Target.ClearAll();
        }
    }
}
