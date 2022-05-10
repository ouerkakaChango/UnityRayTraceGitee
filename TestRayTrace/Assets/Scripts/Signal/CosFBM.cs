using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.CPURand;
using static MathHelper.XMathFunc;
using MathHelper;

public class CosFBM : MonoBehaviour
{
    public uint octaves = 1;
    public float lacunarity = 2.0f;
    public float gain = 0.5f;

    public float startAmplitude = 0.5f;
    public float startFrequency = 1.0f;
    public List<Vector2> dirs = new List<Vector2>();
    public List<float> phases = new List<float>();
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //###
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
        float a = startAmplitude;
        float f = startFrequency;
        float re = 0;
        for(uint i=0;i<octaves;i++)
        {
            re += a * CosFunc((int)i,f * Vec.VecXZ(pos));
            a *= gain;
            f *= lacunarity;
        }
        return re;
    }

    float DxOfCos(int octaveInx, float a, float f,Vector2 pos)
    {//-sin(u)*dirX*f
        return -sin(dot(dirs[octaveInx], f * pos) + phases[octaveInx]) * dirs[octaveInx].x * f * a;
    }
    float DyOfCos(int octaveInx, float a, float f, Vector2 pos)
    {//-sin(u)*dirY*f
        return -sin(dot(dirs[octaveInx], f * pos) + phases[octaveInx]) * dirs[octaveInx].y * f * a;
    }

    Vector2 SDF_GradDecent(Vector2 p, Vector3 target)
    {
        float a = startAmplitude;
        float f = startFrequency;
        float h = a*CosFunc(0, f * p);
        float gradX = 2 * (p.x - target.x) + 2 * (h - target.y) * DxOfCos(0, a, f, p);
        float gradZ = 2 * (p.y - target.z) + 2 * (h - target.y) * DyOfCos(0, a, f, p);
        return new Vector2(a*gradX, a*gradZ);
    }

    public Vector3 NearestPoint(Vector3 target, int loopNum, float step)
    {
        float a = startAmplitude;
        float f = startFrequency;
        Vector2 p = Vec.VecXZ(target);
        for(int i=0;i< loopNum; i++)
        {
            Vector2 grad = SDF_GradDecent(p, target);
            p -= grad * step;
        }
        float finalH = a * CosFunc(0, f * p);
        return new Vector3(p.x, finalH, p.y);
    }
    

    public void VisualizeByBound(Vector2 bound, float delta)
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
}
