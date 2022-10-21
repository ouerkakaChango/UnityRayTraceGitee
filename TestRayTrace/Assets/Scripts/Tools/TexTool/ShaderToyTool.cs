using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using TextureHelper;

public sealed class ShaderToyTool
{
    public Texture2D shiftNoiseTex;
    public Texture2D LUT_BRDF;
    public Texture2D perlinNoise1, voronoiNoise1,blueNoise, greyNoiseMedium, RGBANoiseMedium;
    private static readonly ShaderToyTool instance = new ShaderToyTool();
    static ShaderToyTool()
    {
    }
    private ShaderToyTool()
    {
        //TexHelper.LoadTextureFromDisk(ref shiftNoiseTex, "Assets/Raw/ShaderToy/shiftNoiseTex.png");
        //TexHelper.LoadTextureFromDisk(ref LUT_BRDF, "Assets/Raw/ShaderToy/LUT_BRDF.png");
        //TexHelper.LoadTextureFromDisk(ref perlinNoise1, "Assets/Raw/ShaderToy/perlinNoise1.jpg");
        //TexHelper.LoadTextureFromDisk(ref voronoiNoise1, "Assets/Raw/ShaderToy/voronoiNoise1.jpg");
        //TexHelper.LoadTextureFromDisk(ref blueNoise, "Assets/Raw/ShaderToy/blueNoise.png");
        //TexHelper.LoadTextureFromDisk(ref greyNoiseMedium, "Assets/Raw/ShaderToy/greyNoiseMedium.png");
        //TexHelper.LoadTextureFromDisk(ref RGBANoiseMedium, "Assets/Raw/ShaderToy/RGBANoiseMedium.png");

        shiftNoiseTex = Resources.Load<Texture2D>("ShaderToy/shiftNoiseTex");
        LUT_BRDF = Resources.Load<Texture2D>("ShaderToy/LUT_BRDF");
        shiftNoiseTex = Resources.Load<Texture2D>("ShaderToy/shiftNoiseTex");
        perlinNoise1 = Resources.Load<Texture2D>("ShaderToy/perlinNoise1");
        voronoiNoise1 = Resources.Load<Texture2D>("ShaderToy/voronoiNoise1");
        blueNoise = Resources.Load<Texture2D>("ShaderToy/blueNoise");
        greyNoiseMedium = Resources.Load<Texture2D>("ShaderToy/greyNoiseMedium");
        RGBANoiseMedium = Resources.Load<Texture2D>("ShaderToy/RGBANoiseMedium");
    }
    public static ShaderToyTool Instance
    {
        get
        {
            return instance;
        }
    }
}
