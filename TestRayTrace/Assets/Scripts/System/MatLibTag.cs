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

    public void BakeNormalMap(ref List<string> lines)
    {
        //if(inx == 2)
        //{
        //	float2 uv = GetObjUV(minHit);
        //	float3 T,B;
        //	GetObjTB(T,B, minHit);
        //	minHit.N = SampleNormalMap(N_paper, 4*uv, minHit.N,T,B,1.3);
        //}
        var sdftag = gameObject.GetComponent<SDFBakerTag>();
        if (sdftag == null)
        {
            Debug.LogError(gameObject.name + " don't have sdf baker tag!");
        }

        Vector2 uv_scale = new Vector2(floatParams[0], floatParams[1]);
        Vector2 uv_offset = new Vector2(floatParams[2], floatParams[3]);
        float normalIntensity = floatParams[4];

        int objInx = sdftag.objInx;
        lines.Add("if(inx==" + objInx + ")");
        lines.Add("{");
        lines.Add("	float2 uv = GetObjUV(minHit);");
        lines.Add(" float3 T,B;");
        lines.Add("	GetObjTB(T,B, minHit);");
        lines.Add("	minHit.N = SampleNormalMap("+texParams[0].plainTextures[0].name+", "+Bake(uv_scale) +"*uv+"+ Bake(uv_offset) + ", minHit.N,T,B,"+ normalIntensity + ");");
        lines.Add("}");
    }

    string Bake(Vector2 v)
    {
        return "float2(" + v.x + ", " + v.y + ")";
    }
}
