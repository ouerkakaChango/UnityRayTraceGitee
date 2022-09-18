using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using ImageUtility;

[System.Serializable]
public struct PBRTexture
{
    public string name;
    public Texture2D albedo,normal,metallic,roughness,ao;
}

//1.outHeight = (TexSample[height].r-0.5)*2*hBound.y
//2.outGrad = normalize(TexSample[grad].xy)
[System.Serializable]
public struct HeightTexture
{
    public string name;
    public Texture2D height, grad;
    //??? (deprecated?)
    public Vector3 bound;
}

[System.Serializable]
public struct EnvTexture
{
    public string name;
    public Texture2DArray tex;
    public bool isPNGEnv;
}

[System.Serializable]
public struct NamedTexture
{
    public string name;
    public Texture tex;
    public ColorChannel channel;
}

public class TextureSystem : MonoBehaviour
{
    public List<NamedTexture> outTextures = new List<NamedTexture>();
    public TexSysTag[] tags;

    public List<string> bakedDeclares = new List<string>();
    public List<string> bakedEnvTexSettings = new List<string>();
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //##################################
    public void Refresh()
    {
        PreRefresh();
        for(int i=0;i<tags.Length;i++)
        {
            var tag = tags[i];
            if(tag.type == TexTagType.pbrTexture)
            {
                AddPBRTexture(tag.pbrTextures);
            }
            else if (tag.type == TexTagType.heightTextue)
            {
                AddHeightTexture(tag.heightTextures);
            }
            else if (tag.type == TexTagType.plainTexture)
            {
                for(int i1=0;i1<tag.plainTextures.Count;i1++)
                {
                    outTextures.Add(tag.plainTextures[i1]);
                }
            }
            else if (tag.type == TexTagType.envTexture)
            {
                for (int i1 = 0; i1 < tag.envTextures.Count; i1++)
                {
                    NamedTexture ttex = new NamedTexture();
                    ttex.name = tag.envTextures[i1].name;
                    ttex.tex = tag.envTextures[i1].tex;
                    outTextures.Add(ttex);
                }
            }
        }
        BakeCode();
    }

    void PreRefresh()
    {
        outTextures.Clear();
        var allTags = (TexSysTag[])GameObject.FindObjectsOfType(typeof(TexSysTag));
        List<TexSysTag> tagList = new List<TexSysTag>();
        for (int i = 0; i < allTags.Length; i++)
        {
            if (allTags[i].isActiveAndEnabled)
            {
                tagList.Add(allTags[i]);
            }
        }
        tags = tagList.ToArray();

        for(int i=0;i<tags.Length;i++)
        {
            tags[i].texInx = i;
        }
    }

    void AddPBRTexture(in List<PBRTexture> pbrTextures)
    {
        for(int i=0;i<pbrTextures.Count;i++)
        {
            var pbrTex = pbrTextures[i];
            NamedTexture albedo, normal, metallic, roughness, ao;
            albedo.name = pbrTex.name + "_albedo";
            albedo.tex = pbrTex.albedo;
            albedo.channel = ColorChannel.RGB;
            normal.name = pbrTex.name + "_normal";
            normal.tex = pbrTex.normal;
            normal.channel = ColorChannel.RGB;
            metallic.name = pbrTex.name + "_metallic";
            metallic.tex = pbrTex.metallic;
            metallic.channel = ColorChannel.R;
            roughness.name = pbrTex.name + "_roughness";
            roughness.tex = pbrTex.roughness;
            roughness.channel = ColorChannel.R;
            ao.name = pbrTex.name + "_ao";
            ao.tex = pbrTex.ao;
            ao.channel = ColorChannel.R;

            outTextures.Add(albedo);
            outTextures.Add(normal);
            outTextures.Add(metallic);
            outTextures.Add(roughness);
            outTextures.Add(ao);
        }
    }

    void AddHeightTexture(in List<HeightTexture> heightTextures)
    {
        for (int i = 0; i < heightTextures.Count; i++)
        {
            var heightTex = heightTextures[i];
            NamedTexture height,grad;
            height.name = heightTex.name + "_height";
            height.tex = heightTex.height;
            height.channel = ColorChannel.R;
            grad.name = heightTex.name + "_grad";
            grad.tex = heightTex.grad;
            grad.channel = ColorChannel.RG;

            outTextures.Add(height);
            outTextures.Add(grad);
        }
    }

    void ClearBake()
    {
        bakedDeclares.Clear();
        bakedEnvTexSettings.Clear();
    }

    void BakeCode()
    {
        ClearBake();

        //such as: Texture2D<float4> SphereSDFTex;
        for (int i=0;i<outTextures.Count;i++)
        {
            string line = "";
            string prefix = GetPrefex(outTextures[i]);
            line = prefix + " " + outTextures[i].name+";";
            bakedDeclares.Add(line);
        }

        for(int i=0;i<tags.Length;i++)
        {
            if(tags[i].type == TexTagType.envTexture)
            {
                AddBakeEnvTexSettings(tags[i]);
            }
        }
    }

    string GetPrefex(NamedTexture namedTexture)
    {
        if((namedTexture.tex).GetType() == typeof(Texture2DArray))
        {
            return "Texture2DArray";
        }

        var channel = namedTexture.channel;
        if (channel == ColorChannel.RGBA)
        {
            return "Texture2D<float4>";
        }
        else if (channel == ColorChannel.RGB)
        {
            return "Texture2D<float3>";
        }
        else if (channel == ColorChannel.RG)
        {
            return "Texture2D<float2>";
        }
        else if (channel == ColorChannel.R)
        {
            return "Texture2D<float>";
        }
        else
        {
            Debug.Log(namedTexture.name + " channel " + channel + " not handled prefix,turn to defalt \'Texture<float4>\'");
            return "Texture2D<float4>";
        }
    }

    void AddBakeEnvTexSettings(TexSysTag textag)
    {
        ////if(texInx == 233)
        ////{
        ////	isPNGEnv = false;
        ////	envTexArr = xxx;
        ////}
        bakedEnvTexSettings.Add("if(texInx == "+textag.texInx+")");
        bakedEnvTexSettings.Add("{");
        bakedEnvTexSettings.Add("   isPNGEnv = "+Bake(textag.envTextures[0].isPNGEnv)+";");
        bakedEnvTexSettings.Add("   envTexArr = " + textag.envTextures[0].name + ";");
        bakedEnvTexSettings.Add("}");
    }

    string Bake(bool v)
    {
        if(v)
        {
            return "true";
        }
        else
        {
            return "false";
        }
    }
}
