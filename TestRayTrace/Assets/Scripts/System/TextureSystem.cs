using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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
    public Texture2D height, grad;
    public Vector3 bound;
}

[System.Serializable]
public struct NamedTexture
{
    public string name;
    public Texture tex;
}

public class TextureSystem : MonoBehaviour
{
    public List<NamedTexture> outTextures;

    public TexSysTag[] tags;
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
        }
    }

    void PreRefresh()
    {
        outTextures.Clear();
        var allTags = (TexSysTag[])GameObject.FindObjectsOfType(typeof(TexSysTag));
        List<TexSysTag> tagList = new List<TexSysTag>();
        for (int i = 0; i < allTags.Length; i++)
        {
            if (allTags[i].active)
            {
                tagList.Add(allTags[i]);
            }
        }
        tags = tagList.ToArray();
    }

    void AddPBRTexture(in List<PBRTexture> pbrTextures)
    {
        for(int i=0;i<pbrTextures.Count;i++)
        {
            var pbrTex = pbrTextures[i];
            NamedTexture albedo, normal, metallic, roughness, ao;
            albedo.name = pbrTex.name + "_albedo";
            albedo.tex = pbrTex.albedo;
            normal.name = pbrTex.name + "_normal";
            normal.tex = pbrTex.normal;
            metallic.name = pbrTex.name + "_metallic";
            metallic.tex = pbrTex.metallic;
            roughness.name = pbrTex.name + "_roughness";
            roughness.tex = pbrTex.roughness;
            ao.name = pbrTex.name + "_ao";
            ao.tex = pbrTex.ao;

            outTextures.Add(albedo);
            outTextures.Add(normal);
            outTextures.Add(metallic);
            outTextures.Add(roughness);
            outTextures.Add(ao);
        }
    }
}
