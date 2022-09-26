using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using ImageUtility;

public enum ImgAttachType
{
    BoxAttach,
}

public class ImgAttachTag : MonoBehaviour
{
    public ImgAttachType attachType;
    public TexSysTag img;

    //---Box
    public Vector2 src_uvmin, src_uvmax;
    public Vector2 tar_uvmin, tar_uvmax;
    //___

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //#############################################
    public void BakeBoxAttach(ref List<string> lines)
    {
        //if (inx == 3)
        //{
        //    float2 uv = GetObjUV(minHit);
        //    if (IsInBBox(uv, float2(0.2, 0.2), float2(0.6, 0.8)))
        //    {
        //        float2 uv2 = RemapUV(uv, x,x,x,x);
        //        mat.albedo = SampleRGB(blueNoise, uv2);
        //    }
        //}
        var sdftag = gameObject.GetComponent<SDFBakerTag>();
        int objInx = sdftag.objInx;

        NamedTexture tex = img.plainTextures[0];

        lines.Add("if (inx == " + objInx + ")");
        lines.Add("{");
        lines.Add("    float2 uv = GetObjUV(minHit);");
        lines.Add("    if (IsInBBox(uv, "+Bake(tar_uvmin)+", "+Bake(tar_uvmax)+"))");
        lines.Add("    {");
        lines.Add("        float2 uv2 = RemapUV(uv, "+Bake(src_uvmin)+" ,"+Bake(src_uvmax)+" ,"+Bake(tar_uvmin)+" ,"+Bake(tar_uvmax)+");");
        if (tex.channel == ImageUtility.ColorChannel.RGB)
        {
            lines.Add("        mat.albedo = SampleRGB(" + tex.name + ", uv2);");
        }
        else if (tex.channel == ColorChannel.RGBA)
        {
            //        float4 co = SampleRGBA(texName, uv2);
            //        mat.albedo = lerp(mat.albedo,co.rgb,co.a);
            lines.Add("        float4 co = SampleRGBA("+tex.name+", uv2);");
            lines.Add("        mat.albedo = lerp(mat.albedo,co.rgb,co.a);");
        }
        //else if (tex.channel == ColorChannel.A)
        //{
        //    //        float4 co = SampleRGBA(texName, uv2);
        //    //        mat.albedo = lerp(mat.albedo,co.rgb,co.a);
        //    lines.Add("        float4 co = SampleRGBA(" + tex.name + ", uv2);");
        //    lines.Add("        mat.albedo = lerp(mat.albedo,1,co.a);");
        //}
        else
        {
            Debug.LogError("Not handled");
        }
        lines.Add("    }");
        lines.Add("}");
    }

    string Bake(Vector2 v)
    {
        return "float2(" + v.x + ", " + v.y + ")";
    }
}
