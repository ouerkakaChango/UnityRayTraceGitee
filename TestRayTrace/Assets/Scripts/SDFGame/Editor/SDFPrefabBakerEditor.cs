using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFPrefabBaker))]
public class SDFPrefabBakerEditor : Editor
{
    SDFPrefabBaker Target;
    void OnEnable()
    {
        Target = (SDFPrefabBaker)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("BakeSpecial"))
        {
            Target.BakeSpecial();
        }

        //if (GUILayout.Button("Dump All To Dir"))
        //{
        //    Target.DumpAllToDir();
        //}
        if (GUILayout.Button("Dump All To hlsl"))
        {
            Target.DumpAllToHLSL();
        }

        if (GUILayout.Button("Clear"))
        {
            Target.Clear();
        }
    }
}
