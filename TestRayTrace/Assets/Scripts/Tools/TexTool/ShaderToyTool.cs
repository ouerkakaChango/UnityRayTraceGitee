using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using TextureHelper;

public sealed class ShaderToyTool
{
    public Texture2D noiseRGB;
    public Texture2D LUT_BRDF;
    public Texture2D perlinNoise1, voronoiNoise1,blueNoise, greyNoiseMedium;
    private static readonly ShaderToyTool instance = new ShaderToyTool();
    static ShaderToyTool()
    {
    }
    private ShaderToyTool()
    {
        var fileData = File.ReadAllBytes("Assets/Raw/ShaderToy/shiftTex.png");
        noiseRGB = new Texture2D(2, 2);
        noiseRGB.LoadImage(fileData);

        TexHelper.LoadTextureFromDisk(ref LUT_BRDF, "Assets/Raw/ShaderToy/LUT_BRDF.png");
        TexHelper.LoadTextureFromDisk(ref perlinNoise1, "Assets/Raw/ShaderToy/perlinNoise1.jpg");
        TexHelper.LoadTextureFromDisk(ref voronoiNoise1, "Assets/Raw/ShaderToy/voronoiNoise1.jpg");
        TexHelper.LoadTextureFromDisk(ref blueNoise, "Assets/Raw/ShaderToy/blueNoise.png");
        TexHelper.LoadTextureFromDisk(ref greyNoiseMedium, "Assets/Raw/ShaderToy/greyNoiseMedium.png");
    }
    public static ShaderToyTool Instance
    {
        get
        {
            return instance;
        }
    }
}
