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
            //Target.CreateShiftTex();
            //TexHelper.SavePNG(Target.outTex, "Assets","shiftTex");
        }

        //if (GUILayout.Button("GenerateAlphaMask"))
        //{
        //    Target.CreateAlphaMask();
        //    TexHelper.SavePNG(Target.outTex, "Assets", "alphaMask");
        //}
        //
        //if (GUILayout.Button("GenerateAlphaMaskHDR"))
        //{
        //    Target.CreateAlphaMaskHDR();
        //    TexHelper.SaveEXR(Target.outTex, "Assets", "alphaMaskHDR");
        //}
        //
        //if (GUILayout.Button("GenerateSphereSDF"))
        //{
        //    Target.CreateSphereSDF();
        //    TexHelper.SaveEXR(Target.outTex, "Assets", "sphereSDF");
        //    //TexHelper.SavePNG(Target.outTex, "Assets", "sphereSDF");
        //}
        //
        //if (GUILayout.Button("GenerateTestLightmap"))
        //{
        //    Target.CreateTestLightmap();
        //    TexHelper.SaveEXR(Target.outTex, "Assets", "testLightmap");
        //}
        //
        //if (GUILayout.Button("LogOutTexPixel"))
        //{
        //    Target.LogOutTexPixel();
        //}
    }
}
