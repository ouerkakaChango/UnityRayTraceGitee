using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(IBLSpecBaker))]
public class IBLSpecBakerEditor : Editor
{
    void OnEnable()
    {
        AssetDatabase.Refresh();
    }
}
