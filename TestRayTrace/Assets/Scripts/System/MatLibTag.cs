using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatLibTag : MonoBehaviour
{
    public string matTypeName = "null";
    public List<float> floatParams = new List<float>();
    public List<TexSysTag> texParams = new List<TexSysTag>();
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //##################################################
    public void BakeBrushedMetal(ref List<string> lines)
    {
        //if(inx==2)
        //{
        //	float2 uv = GetObjUV(minHit);
        //	SetMatLib_BrushedMetal(mat,uv);
        //}
        var sdftag = gameObject.GetComponent<SDFBakerTag>();
        if (sdftag == null)
        {
            Debug.LogError(gameObject.name + " don't have sdf baker tag!");
        }
        int objInx = sdftag.objInx;

        lines.Add("if(inx==" + objInx + ")");
        lines.Add("{");
        lines.Add("	float2 uv = GetObjUV(minHit);");
        if (floatParams.Count == 0)
        {
            lines.Add("	SetMatLib_BrushedMetal(mat,uv);");
        }
        else if (floatParams.Count == 1)
        {
            lines.Add("	SetMatLib_BrushedMetal(mat,uv, " + floatParams[0] + ");");
        }
        else
        {
            Debug.LogError("Not handled: BakeBrushedMetal params num > 1");
        }
        lines.Add("}");
    }

    public void BakeDiffuseMap(ref List<string> lines)
    {
        //if(inx == 2)
        //{
        //	float2 uv = GetObjUV(minHit);
        //  uv = s*uv+t;
        //	mat.albedo *= SampleRGB(texName, uv);
        //}

        Vector2 uv_scale = new Vector2(floatParams[0], floatParams[1]);
        Vector2 uv_offset = new Vector2(floatParams[2], floatParams[3]);
        string texName = texParams[0].plainTextures[0].name;

        int objInx = SafeGetObjInx();
        lines.Add("if(inx==" + objInx + ")");
        lines.Add("{");
        lines.Add("	float2 uv = GetObjUV(minHit);");
        lines.Add(" uv = "+ Bake(uv_scale) + "*uv+" + Bake(uv_offset) + ";");
        lines.Add("	mat.albedo *= SampleRGB("+texName+", uv);");
        lines.Add("}");
    }

    public void BakeNormalMap(ref List<string> lines)
    {
        //if(inx == 2)
        //{
        //	float2 uv = GetObjUV(minHit);
        //	float3 T,B;
        //	GetObjTB(T,B, minHit);
        //	minHit.N = SampleNormalMap(N_paper, s*uv+t, minHit.N,T,B,1.3);
        //}

        Vector2 uv_scale = new Vector2(floatParams[0], floatParams[1]);
        Vector2 uv_offset = new Vector2(floatParams[2], floatParams[3]);
        float normalIntensity = floatParams[4];

        int objInx = SafeGetObjInx();
        lines.Add("if(inx==" + objInx + ")");
        lines.Add("{");
        lines.Add("	float2 uv = GetObjUV(minHit);");
        lines.Add(" float3 T,B;");
        lines.Add("	GetObjTB(T,B, minHit);");
        lines.Add("	minHit.N = SampleNormalMap("+texParams[0].plainTextures[0].name+", "+Bake(uv_scale) +"*uv+"+ Bake(uv_offset) + ", minHit.N,T,B,"+ normalIntensity + ");");
        lines.Add("}");
    }

    public void BakeMarquetry(ref List<string> lines)
    {
        //if (inx == 9)
        //{
        //    float2 uv = GetObjUV(minHit);
        //    uv = uvs*uv+uvt;
        //    float3 T, B;
        //    GetObjTB(T, B, minHit);
        //    SetMatLib_Marquetry(mat, minHit, uv, T, B, WoodTexture, 7, -4);
        //}
        Vector2 uv_scale = new Vector2(floatParams[0], floatParams[1]);
        Vector2 uv_offset = new Vector2(floatParams[2], floatParams[3]);
        if(texParams.Count!=1)
        {
            Debug.LogError("BakeMarquetry: Error, need 1 tex for Marquetry wood");
            return;
        }
        string texName = texParams[0].plainTextures[0].name;

        int objInx = SafeGetObjInx();
        lines.Add("if(inx==" + objInx + ")");
        lines.Add("{");
        lines.Add(" float2 uv = GetObjUV(minHit);");
        lines.Add(" uv = "+Bake(uv_scale) +"*uv+"+Bake(uv_offset)+";");
        lines.Add(" float3 T,B;");
        lines.Add("	GetObjTB(T,B, minHit);");
        if (floatParams.Count ==4)
        {
            lines.Add(" SetMatLib_Marquetry(mat, minHit, uv, T, B, " + texName + ");");
        }
        else if(floatParams.Count == 6)
        {
            lines.Add(" SetMatLib_Marquetry(mat, minHit, uv, T, B, " + texName + ", "+ floatParams[4]+", "+ floatParams[5] + ");");
        }
        else
        {
            Debug.LogError("Incorrect params num for Marquetry");
        }
        lines.Add("}");
    }

    public void BakeSwirlGold(ref List<string> lines)
    {
        //if(inx == 13)
        //{
        //	float2 uv = GetObjUV(minHit);
        //	float3 T,B;
        //	GetObjTB(T,B, minHit);
        //	SetMatLib_SwirlGold(mat,minHit,uv,T,B);
        //}

        int objInx = SafeGetObjInx();
        lines.Add("if(inx==" + objInx + ")");
        lines.Add("{");
        lines.Add(" float2 uv = GetObjUV(minHit);");
        lines.Add(" float3 T,B;");
        lines.Add("	GetObjTB(T,B, minHit);");
        if (floatParams.Count == 0)
        {
            lines.Add(" SetMatLib_SwirlGold(mat, minHit, uv, T, B);");
        }
        else if (floatParams.Count == 2)
        {
            lines.Add(" SetMatLib_SwirlGold(mat, minHit, uv, T, B, " + floatParams[0] + ", " + floatParams[1] + ");");
        }
        else
        {
            Debug.LogError("Incorrect params num for SwirlGold");
        }
        lines.Add("}");
    }

    string Bake(Vector2 v)
    {
        return "float2(" + v.x + ", " + v.y + ")";
    }

    int SafeGetObjInx()
    {
        var sdftag = gameObject.GetComponent<SDFBakerTag>();
        if (sdftag == null)
        {
            Debug.LogError(gameObject.name + " don't have sdf baker tag!");
        }
        return sdftag.objInx;
    }
}
