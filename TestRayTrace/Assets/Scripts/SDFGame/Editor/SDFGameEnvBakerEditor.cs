using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TextureHelper;

[CustomEditor(typeof(SDFGameEnvBaker))]
public class SDFGameEnvBakerEditor : Editor
{
    SDFGameEnvBaker Target;

    void OnEnable()
    {
        Target = (SDFGameEnvBaker)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("SaveEnvEXR"))
        {
            TexHelper.SaveEXR(Target.outEnvTex, "Assets", "env_"+Target.outName);
        }

        if (GUILayout.Button("SaveCubePNG"))
        {
            //名称与工具对齐 https://danilw.github.io/GLSL-howto/cubemap_to_panorama_js/cubemap_to_panorama.html
            TexHelper.SavePNG(Target.cubeOut[0], "Assets", Target.outName + "_right");
            TexHelper.SavePNG(Target.cubeOut[1], "Assets", Target.outName + "_up");
            TexHelper.SavePNG(Target.cubeOut[2], "Assets", Target.outName + "_down");
            TexHelper.SavePNG(Target.cubeOut[3], "Assets", Target.outName + "_left");
            TexHelper.SavePNG(Target.cubeOut[4], "Assets", Target.outName + "_back");
            TexHelper.SavePNG(Target.cubeOut[5], "Assets", Target.outName + "_front");
        }

        if (GUILayout.Button("SaveCubeEXR"))
        {
            //名称与工具对齐 https://danilw.github.io/GLSL-howto/cubemap_to_panorama_js/cubemap_to_panorama.html
            TexHelper.SaveEXR(Target.cubeOut[0], "Assets", Target.outName + "_right");
            TexHelper.SaveEXR(Target.cubeOut[1], "Assets", Target.outName + "_up");
            TexHelper.SaveEXR(Target.cubeOut[2], "Assets", Target.outName + "_down");
            TexHelper.SaveEXR(Target.cubeOut[3], "Assets", Target.outName + "_left");
            TexHelper.SaveEXR(Target.cubeOut[4], "Assets", Target.outName + "_back");
            TexHelper.SaveEXR(Target.cubeOut[5], "Assets", Target.outName + "_front");
        }
    }
}
