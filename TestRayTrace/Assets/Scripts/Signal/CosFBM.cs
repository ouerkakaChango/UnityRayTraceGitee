using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.CPURand;
using static MathHelper.XMathFunc;
using MathHelper;
using XUtility;

public class CosFBM : MonoBehaviour
{
    public Vector2 bound = new Vector2(50,50);
    public float delta = 6.0f;
    public uint octaves = 1;
    public float lacunarity = 2.0f;
    public float gain = 0.5f;

    public float startAmplitude = 0.5f;
    public float startFrequency = 1.0f;
    public List<Vector2> dirs = new List<Vector2>();
    public List<float> phases = new List<float>();
    public string funcName = "CosFBM";
    //[ReadOnly]
    public List<string> bakedHLSLCode;
    public Vector2Int texSize = new Vector2Int(1024, 1024);
    public HeightTexture heightTex;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //###############################################
    void Init()
    {
        Clear();
        for(int i=0;i<octaves;i++)
        {
            dirs.Add(RandDir2D());
            phases.Add(Random.Range(0.0f, 100.0f));
        }
    }

    void Clear()
    {
        dirs.Clear();
        phases.Clear();
    }

    float CosFunc(int octaveInx, Vector2 fpos)
    {
        return cos(dot(dirs[octaveInx], fpos) + phases[octaveInx]);
    }

    float GetVal(Vector3 pos)
    {
        return GetVal(Vec.VecXZ(pos));
    }

    float GetVal(Vector2 p)
    {
        float a = startAmplitude;
        float f = startFrequency;
        float re = 0;
        for (uint i = 0; i < octaves; i++)
        {
            re += a * CosFunc((int)i, f * p);
            a *= gain;
            f *= lacunarity;
        }
        return re;
    }

    Vector2 GetDxy(Vector2 p)
    {
        Vector2 re = Vector2.zero;
        float a = startAmplitude;
        float f = startFrequency;
        for (int i = 0; i < octaves; i++)
        {
            re.x += DxOfCos(i, a, f, p);
            re.y += DyOfCos(i, a, f, p);
            a *= gain;
            f *= lacunarity;
        }
        return re;
    }

    float DxOfCos(int octaveInx, float a, float f,Vector2 pos)
    {//-sin(u)*dirX*f*a
        return -sin(dot(dirs[octaveInx], f * pos) + phases[octaveInx]) * dirs[octaveInx].x * f * a;
    }
    float DyOfCos(int octaveInx, float a, float f, Vector2 pos)
    {//-sin(u)*dirY*f*a
        return -sin(dot(dirs[octaveInx], f * pos) + phases[octaveInx]) * dirs[octaveInx].y * f * a;
    }

    //https://www.bilibili.com/read/cv16563835
    Vector2 DisSquareGrad(Vector2 p, Vector3 target)
    {
        Vector2 re = 2.0f * (p - Vec.VecXZ(target)) + 2*(GetVal(p) - target.y)*GetDxy(p);
        return re;
    }

    public Vector3 NearestPoint(Vector3 target, int loopNum, float step)
    {
        Vector2 p = Vec.VecXZ(target);
        for(int i=0;i< loopNum; i++)
        {
            Vector2 grad = DisSquareGrad(p, target);
            p -= grad * step;
        }
        float finalH = GetVal(p);
        return new Vector3(p.x, finalH, p.y);
    }
    

    public void VisualizeByBound()
    {
        Init();
        var visual = GetComponent<PntsVisualizer>();
        if(!visual)
        {
            return;
        }
        visual.Clear();
        Vector3 center = transform.position;
        Vector3 start = center - new Vector3(bound.x * delta, 0, bound.y * delta);
        for(int j=0;j<bound.y*2;j++)
        {
            for(int i=0;i<bound.x*2;i++)
            {
                Vector3 samplePos = start + new Vector3(delta * i, 0, delta * j);
                float height = GetVal(samplePos);
                Vector3 pnt = new Vector3(samplePos.x, transform.position.y + height, samplePos.z);
                visual.Add(pnt);
            }
        }
    }

    public void BakeHeightTex()
    {
        Texture2D height = new Texture2D(texSize.x, texSize.y);
        Texture2D grad = new Texture2D(texSize.x, texSize.y);
        Vector3 hBound = new Vector3(bound.x*delta, startAmplitude, bound.y * delta);
        //1.outHeight = (TexSample[height].r-0.5)*2*hBound.y
        //2.outGrad = normalize(TexSample[grad].xy)

        Color[] hColors = new Color[texSize.x * texSize.y];
        Color[] gColors = new Color[texSize.x * texSize.y];
        for (int j=0;j<texSize.y;j++)
        {
            for(int i=0;i<texSize.x;i++)
            {
                Vector2 ndc = new Vector2(i, j) / texSize;
                ndc = (ndc - Vec.ToVec2(0.5f)) * 2;
                Vector2 p2d = ndc * bound*delta;
                float h = GetVal(p2d);
                float hr = saturate((h + hBound.y) * 0.5f);
                Vector2 Dxy = GetDxy(p2d);
                hColors[i + texSize.x * j] = new Color(hr, 0, 0);
                gColors[i + texSize.x * j] = new Color(Dxy.x, Dxy.y, 0);
            }
        }

        height.SetPixels(hColors);
        grad.SetPixels(gColors);
        height.Apply();
        grad.Apply();
        heightTex.bound = hBound;
        heightTex.height = height;
        heightTex.grad = grad;
    }

    public void BakeHLSLCode(bool bakeHeightTex = false)
    {
        bakedHLSLCode.Clear();
        if (dirs.Count!=octaves || phases.Count!=octaves)
        {
            Debug.Log("CosFBM: Reinit for bake HLSL code");
            Init();
        }

        //@@@ Textures
        if(bakeHeightTex)
        {
            bakedHLSLCode.Add("Texture2D " + funcName + "_height;");
            bakedHLSLCode.Add("Texture2D " + funcName + "_grad;");
        }

        float a = startAmplitude;
        float f = startFrequency;

        bakedHLSLCode.Add("");
        //@@@ H(x,y)
        if (!bakeHeightTex)
        {
            ////float a = startAmplitude;
            ////float f = startFrequency;
            ////float re = 0;
            ////for (uint i = 0; i < octaves; i++)
            ////{
            ////    re += a * CosFunc((int)i, f * p);
            ////    a *= gain;
            ////    f *= lacunarity;
            ////}
            ////return re;
            bakedHLSLCode.Add("float " + funcName + "(float2 p)");
            bakedHLSLCode.Add("{");
            bakedHLSLCode.Add(" float re = 0;");
            for (int i = 0; i < octaves; i++)
            {
                bakedHLSLCode.Add(" re += " + a + "*cos(dot(" + Bake(dirs[i]) + "," + f + "*p)+" + phases[i] + ");");
                a *= gain;
                f *= lacunarity;
            }
            bakedHLSLCode.Add(" return re;");
            bakedHLSLCode.Add("}");
        }
        else
        {
            ////float CosFBM(float2 p)
            ////{
            ////    float3 hBound = float3(...);
            ////    float2 ndc = p / hBound.xz;
            ////    float2 uv = (1 + ndc) * 0.5;
            ////    uint2 texSize = GetSize(CosFBM_height);
            ////    float2 texPos = texSize * uv;
            ////    float hr = CosFBM_height[texPos].r;
            ////    hr = 2 * (hr - 0.5);
            ////    return hr * hBound.y;
            ////}
            bakedHLSLCode.Add("float " + funcName + "(float2 p)");
            bakedHLSLCode.Add("{");
            bakedHLSLCode.Add(" float3 hBound = "+Bake(heightTex.bound)+";");
            bakedHLSLCode.Add(" float2 ndc = p / hBound.xz;");
            bakedHLSLCode.Add(" float2 uv = (1 + ndc) * 0.5;");
            bakedHLSLCode.Add(" uint2 texSize = GetSize("+funcName+"_height);");
            bakedHLSLCode.Add(" float2 texPos = texSize * uv");
            bakedHLSLCode.Add(" float hr = "+funcName+"_height[texPos].");
            bakedHLSLCode.Add(" hr = 2 * (hr - 0.5);");
            bakedHLSLCode.Add(" return hr * hBound.y;");
            bakedHLSLCode.Add("}");
        }

        bakedHLSLCode.Add("");
        //@@@ H'x, H'y
        if (!bakeHeightTex)
        {
            ////Vector2 re = Vector2.zero;
            ////float a = startAmplitude;
            ////float f = startFrequency;
            ////for (int i = 0; i < octaves; i++)
            ////{
            ////    re.x += DxOfCos(i, a, f, p);
            ////    re.y += DyOfCos(i, a, f, p);
            ////    a *= gain;
            ////    f *= lacunarity;
            ////}
            ////return re;
            a = startAmplitude;
            f = startFrequency;
            bakedHLSLCode.Add("float2 " + funcName + "_Dxy(float2 p)");
            bakedHLSLCode.Add("{");
            bakedHLSLCode.Add(" float2 re=0;");
            for (int i = 0; i < octaves; i++)
            {
                bakedHLSLCode.Add("re+= -sin(dot(" + Bake(dirs[i]) + "," + f + "* p) + " + phases[i] + ") *" + Bake(dirs[i]) + " * " + f * a + ";");
                a *= gain;
                f *= lacunarity;
            }
            bakedHLSLCode.Add(" return re;");
            bakedHLSLCode.Add("}");
        }
        else
        {
            ////float2 CosFBM_Dxy(float2 p)
            ////{
            ////    float3 hBound = float3();
            ////    float2 ndc = p / hBound.xz;
            ////    float2 uv = (1 + ndc) * 0.5;
            ////    uint2 texSize = GetSize(CosFBM_height);
            ////    float2 texPos = texSize * uv;
            ////    return normalize(CosFBM_height[texPos].xy);
            ////}
            bakedHLSLCode.Add("float " + funcName + "_Dxy(float2 p)");
            bakedHLSLCode.Add("{");
            bakedHLSLCode.Add(" float3 hBound = " + Bake(heightTex.bound) + ";");
            bakedHLSLCode.Add(" float2 ndc = p / hBound.xz;");
            bakedHLSLCode.Add(" float2 uv = (1 + ndc) * 0.5;");
            bakedHLSLCode.Add(" uint2 texSize = GetSize(" + funcName + "_height);");
            bakedHLSLCode.Add(" float2 texPos = texSize * uv");
            bakedHLSLCode.Add(" return normalize("+funcName+"_height[texPos].xy);");
            bakedHLSLCode.Add("}");

        }

        //@@@ DisSquareGrad
        ////Vector2 re = 2.0f * (p - Vec.VecXZ(target)) + 2*(GetVal(p) - target.y)*GetDxy(p);
        bakedHLSLCode.Add("");
        bakedHLSLCode.Add("float2 "+ funcName+ "_DisSquareGrad(float2 p, float3 target)");
        bakedHLSLCode.Add("{");
        bakedHLSLCode.Add(" return 2*(p - target.xz) + 2*("+funcName+"(p) - target.y)*"+funcName+"_Dxy(p);");
        bakedHLSLCode.Add("}");

        //@@@ NearestPoint
        ////Vector2 p = Vec.VecXZ(target);
        ////for (int i = 0; i < loopNum; i++)
        ////{
        ////    Vector2 grad = DisSquareGrad(p, target);
        ////    p -= grad * step;
        ////}
        ////float finalH = GetVal(p);
        ////return new Vector3(p.x, finalH, p.y);
        bakedHLSLCode.Add("");
        bakedHLSLCode.Add("float3 " + funcName + "_NearestPoint(float3 target, int loopNum, float step)");
        bakedHLSLCode.Add("{");
        bakedHLSLCode.Add(" float2 p = target.xz;");
        bakedHLSLCode.Add(" for(int i=0;i<loopNum;i++)");
        bakedHLSLCode.Add(" {");
        bakedHLSLCode.Add("     p-= "+ funcName+ "_DisSquareGrad(p,target) * step;");
        bakedHLSLCode.Add(" }");
        bakedHLSLCode.Add(" return float3(p.x,"+ funcName+"(p),p.y);");
        bakedHLSLCode.Add("}");
    }

    public string GetBakedHLSLString()
    {
        string re = "";
        for(int i=0;i<bakedHLSLCode.Count;i++)
        {
            re += bakedHLSLCode[i] + "\n";
        }
        
        return re;
    }

    string Bake(Vector2 v)
    {
        return "float2(" + v.x + "," + v.y + ")";
    }

    string Bake(Vector3 v)
    {
        return "float3(" + v.x + "," + v.y + "," + v.z + ")";
    }
}
