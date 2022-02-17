using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(ImgCSProcessor))]
public class ImgCSProcessorEditor : Editor
{
    protected ImgCSProcessor Target;
    void OnEnable()
    {
        Target = (ImgCSProcessor)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Process"))
        {
            Target.Process();
        }
    }
}
