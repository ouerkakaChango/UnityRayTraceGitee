using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public sealed class ShaderToyTool
{
    Texture2D noiseRGB;
    private static readonly ShaderToyTool instance = new ShaderToyTool();
    static ShaderToyTool()
    {
    }
    private ShaderToyTool()
    {
        var fileData = File.ReadAllBytes("Assets/Raw/ShaderToy/mnoise.png");
        //var fileData = File.ReadAllBytes("Assets/Raw/ShaderToy/noiseRGB.png");
        noiseRGB = new Texture2D(2, 2);
        noiseRGB.LoadImage(fileData);
    }
    public static ShaderToyTool Instance
    {
        get
        {
            return instance;
        }
    }

    public 
        Texture2D GetTexture(string name)
    {
        if (name == "NoiseRGBTex")
        {
            return noiseRGB;
        }
        return null;
    }
}
