using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using TextureHelper;

public sealed class ShaderToyTool
{
    public Texture2D noiseRGB;
    public Texture2D LUT_BRDF;
    private static readonly ShaderToyTool instance = new ShaderToyTool();
    static ShaderToyTool()
    {
    }
    private ShaderToyTool()
    {
        var fileData = File.ReadAllBytes("Assets/Raw/ShaderToy/shiftTex.png");
        noiseRGB = new Texture2D(2, 2);
        noiseRGB.LoadImage(fileData);

        TexHelper.LoadPNG(ref LUT_BRDF, "Assets/Raw/ShaderToy/LUT_BRDF.png");
    }
    public static ShaderToyTool Instance
    {
        get
        {
            return instance;
        }
    }
}
